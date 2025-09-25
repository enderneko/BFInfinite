---@type BFI
local BFI = select(2, ...)
---@class Misc
local M = BFI.modules.Misc
---@type AbstractFramework
local AF = _G.AbstractFramework

local GetMountIDs = C_MountJournal.GetMountIDs
local GetMountInfoByID = C_MountJournal.GetMountInfoByID
local GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID
local ForEachAura = AuraUtil.ForEachAura

local mountSpellToID = {}
local mountInfo = {}
local trailingLineBreaks = "|n|n$"

local function CacheMount(mountID)
    if not mountID then return end

    local name, spellID, icon, _, _, _, _, _, faction, _, isCollected = GetMountInfoByID(mountID)
    mountSpellToID[spellID] = mountID

    if faction == 0 then
        faction = "Horde"
    elseif faction == 1 then
        faction = "Alliance"
    end

    local source = select(3, GetMountInfoExtraByID(mountID))
    mountInfo[mountID] = {
        id = mountID,
        name = name,
        icon = icon,
        spellID = spellID,
        source = source:gsub(trailingLineBreaks, ""),
        faction = faction,
        isCollected = isCollected,
    }
end

AF.RegisterCallback("AF_PLAYER_LOGIN", function()
    for _, mountID in next, GetMountIDs() do
        CacheMount(mountID)
    end
end)

M:RegisterEvent("NEW_MOUNT_ADDED", function(_, _, mountID)
    CacheMount(mountID)
end)

function M.GetMountInfo(mountID)
    return mountInfo[mountID]
end

function M.GetMountInfoFromSpell(spellID)
    local mountID = spellID and mountSpellToID[spellID]
    if not mountID then return end
    return mountInfo[mountID]
end

function M.GetMountInfoFromUnit(unit)
    if not unit then return end
    local info
    ForEachAura(unit, "HELPFUL", nil, function(data)
        if data and data.spellId and mountSpellToID[data.spellId] then
            info = mountInfo[mountSpellToID[data.spellId]]
            return true
        end
    end, true)
    return info
end