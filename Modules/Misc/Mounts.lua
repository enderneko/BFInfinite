---@class BFI
local BFI = select(2, ...)
---@class Misc
local M = BFI.Misc
---@type AbstractFramework
local AF = _G.AbstractFramework

local GetMountIDs = C_MountJournal.GetMountIDs
local GetMountInfoByID = C_MountJournal.GetMountInfoByID
local GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID

local mountSpellToID = {}
local mountInfo = {}
local trailingLineBreaks = "|n|n$"

AF.RegisterCallback("AF_PLAYER_LOGIN", function()
    for _, mountID in next, GetMountIDs() do
        local name, spellID, icon, _, _, _, _, _, faction = GetMountInfoByID(mountID)
        mountSpellToID[spellID] = mountID

        if faction == 0 then
            faction = "Horde"
        elseif faction == 1 then
            faction = "Alliance"
        end

        local source = select(3, GetMountInfoExtraByID(mountID))
        mountInfo[mountID] = {
            name = name,
            icon = icon,
            spellID = spellID,
            source = source:gsub(trailingLineBreaks, ""),
            faction = faction,
        }
    end
end)

function M.GetMountInfo(mountID)
    return mountInfo[mountID]
end

function M.GetMountInfoFromSpell(spellID)
    local mountID = spellID and mountSpellToID[spellID]
    if not mountID then return end
    return M.GetMountInfo(mountID)
end