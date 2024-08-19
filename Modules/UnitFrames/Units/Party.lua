---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.UnitFrames

local party
local indicators = {
    "healthBar",
    "powerBar",
    "portrait",
    "castBar",
    "nameText",
    "healthText",
    "powerText",
    "levelText",
    "leaderText",
    "combatIcon",
    "leaderIcon",
    "targetCounter",
    "statusTimer",
    "statusIcon",
    "raidIcon",
    "readyCheckIcon",
    "roleIcon",
    "factionIcon",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateParty()
    local name = "BFIUF_Party"
    party = CreateFrame("Frame", name, AW.UIParent, "SecureFrameTemplate")

    for i = 1, 4 do
        party[i] = CreateFrame("Button", name .. i, party, "BFIUnitButtonTemplate")
        party[i]._updateOnGroupChanged = true
        -- party[i]:SetAttribute("unit", "player")
        party[i]:SetAttribute("unit", "party" .. i)
        UF.AddToConfigMode("party", party[i])
    end

    -- mover
    AW.CreateMover(party, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(party)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateParty(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "party" then return end

    local config = UF.config.party

    if not config.enabled then
        if party then
            UnregisterAttributeDriver(party)
            for i = 1, 4 do
                UF.DisableIndicators(party[i])
                -- UnregisterAttributeDriver(party[i], "state-visibility")
                UnregisterUnitWatch(party[i])
                UF.RemoveFromConfigMode("party", party[i])
            end
            party:Hide()
        end
        return
    end

    if not party then
        CreateParty()
    end

    -- setup
    UF.SetupUnitGroup(party, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(party, "state-visibility", "[petbattle] hide;[@raid1,exists] hide;[@party1,exists] show;[group:party] show;hide")
    for i = 1, 4 do
        -- RegisterAttributeDriver(party[i], "state-visibility", "[@party" .. i .. ",exists] show;hide")
        RegisterUnitWatch(party[i])
    end
end
BFI.RegisterCallback("UpdateModules", "UF_Party", UpdateParty)