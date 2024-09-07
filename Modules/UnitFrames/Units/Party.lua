---@class BFI
local BFI = select(2, ...)
local L = BFI.L
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
    party = CreateFrame("Frame", name, UF.Parent, "SecureFrameTemplate")
    UF.AddToConfigMode("party.container", party)

    local header = CreateFrame("Frame", name .. "Header", party, "SecureGroupHeaderTemplate")
    party.header = header
    UF.AddToConfigMode("party.header", header)
    header:SetAttribute("template", "BFIUnitButtonTemplate")
    header:SetAttribute("showSolo", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)

    --! to make needButtons == 5 in SecureGroupHeaders.lua
    header:SetAttribute("startingIndex", -4)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    header:HookScript("OnAttributeChanged", function(self, attr)
        if not self.inConfigMode then return end
        if self:GetAttribute("startingIndex") ~= -4 then
            self:SetAttribute("startingIndex", -4)
        end
    end)

    party.driverKey = "state-visibility"
    party.driverValue = "[@raid1,exists] hide;[@party1,exists] show;[group:party] show;hide"

    for i = 1, 5 do
        header[i]._updateOnGroupUpdate = true
        UF.AddToConfigMode("party", header[i])
        UF.CreateIndicators(header[i], indicators)
    end

    -- mover
    AW.CreateMover(party, L["Unit Frames"], _G.PARTY)

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
            for i = 1, 5 do
                UF.DisableIndicators(party.header[i])
            end
            UF.RemoveFromConfigMode("party")
            party.enabled = false -- for mover
            party:Hide()
        end
        return
    end

    if not party then
        CreateParty()
    end

    party.enabled = true -- for mover

    -- setup
    local header = party.header
    local unitCount = config.general.showPlayer and 5 or 4

    -- strata & level
    -- party:SetFrameStrata(config.general.frameStrata)
    -- party:SetFrameLevel(config.general.frameLevel)

    -- mover
    AW.UpdateMoverSave(party, config.general.position)

    -- position
    AW.LoadPosition(party, config.general.position)

    -- container size
    if config.general.orientation == "top_to_bottom" or config.general.orientation == "bottom_to_top" then
        AW.SetWidth(party, config.general.width)
        AW.SetListHeight(party, unitCount, config.general.height, config.general.spacing)
    else
        AW.SetHeight(party, config.general.height)
        AW.SetListWidth(party, unitCount, config.general.width, config.general.spacing)
    end

    -- buttons
    for i = 1, 5 do
        local button = header[i]
        button:ClearAllPoints()

        -- size
        AW.SetSize(button, config.general.width, config.general.height)
        -- out of range alpha
        button.oorAlpha = config.general.oorAlpha
        -- tooltip
        UF.SetupTooltip(button, config.general.tooltip)
        -- color
        AW.StylizeFrame(button, config.general.bgColor, config.general.borderColor)
        -- indicators
        UF.SetupIndicators(button, indicators, config)
    end

    -- header
    local p, rp, x, y, hp = UF.GetSimplePositionArgs(config)
    header:ClearAllPoints()
    header:SetPoint(p, party)
    header:SetAttribute("point", hp)
    header:SetAttribute("xOffset", x)
    header:SetAttribute("yOffset", y)
    header:SetAttribute("buttonWidth", AW.ConvertPixelsForRegion(config.general.width, party))
    header:SetAttribute("buttonHeight", AW.ConvertPixelsForRegion(config.general.height, party))
    header:SetAttribute("showPlayer", config.general.showPlayer)
    header:SetSize(config.general.width, config.general.height)
    header:SetAttribute("unitsPerColumn", 5)
    header:Show()

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(party, party.driverKey, party.driverValue)
end
BFI.RegisterCallback("UpdateModules", "UF_Party", UpdateParty)