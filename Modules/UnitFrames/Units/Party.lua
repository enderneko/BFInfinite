---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

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
-- create -- TODO: pet & target
---------------------------------------------------------------------
local function CreateParty()
    local name = "BFI_Party"
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
        header[i].enableUnitButtonMapping = true
        UF.AddToConfigMode("party", header[i])
        UF.CreateIndicators(header[i], indicators)
        UF.CreatePreviewRect(header[i])
    end

    -- mover
    AF.CreateMover(party, "BFI: " .. L["Unit Frames"], _G.PARTY)

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(party, nil, true)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateParty(_, module, which, skipIndicatorUpdates)
    if module and module ~= "unitFrames" then return end
    if which and which ~= "party" then return end

    local config = UF.config.party

    if not config.general.enabled then
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
    local unitCount = 5 -- config.general.showPlayer and 5 or 4

    -- strata & level
    -- party:SetFrameStrata(config.general.frameStrata)
    -- party:SetFrameLevel(config.general.frameLevel)

    -- mover
    AF.UpdateMoverSave(party, config.general.position)

    -- position
    AF.LoadPosition(party, config.general.position)

    -- container size
    if config.general.orientation == "top_to_bottom" or config.general.orientation == "bottom_to_top" then
        AF.SetWidth(party, config.general.width)
        AF.SetListHeight(party, unitCount, config.general.height, config.general.spacing)
    else
        AF.SetHeight(party, config.general.height)
        AF.SetListWidth(party, unitCount, config.general.width, config.general.spacing)
    end

    -- buttons
    for i = 1, 5 do
        local button = header[i]
        button:ClearAllPoints()

        -- size
        AF.SetSize(button, config.general.width, config.general.height)
        -- out of range alpha
        button.oorAlpha = config.general.oorAlpha
        -- tooltip
        button.tooltip = config.general.tooltip
        -- color
        AF.ApplyDefaultBackdropWithColors(button, config.general.bgColor, config.general.borderColor)
        -- indicators
        if not skipIndicatorUpdates then
            UF.SetupIndicators(button, indicators, config)
        end
    end

    -- header
    local _, rp, _, x, y, _, _, hp = AF.GetAnchorPoints_Simple(config.general.anchor, config.general.orientation, config.general.spacing)
    header:ClearAllPoints()
    header:SetPoint(config.general.anchor, party)
    header:SetAttribute("point", hp)
    header:SetAttribute("xOffset", x)
    header:SetAttribute("yOffset", y)
    header:SetAttribute("buttonWidth", AF.ConvertPixelsForRegion(config.general.width, party))
    header:SetAttribute("buttonHeight", AF.ConvertPixelsForRegion(config.general.height, party))
    header:SetAttribute("showPlayer", config.general.showPlayer)
    header:SetAttribute("sortMethod", config.general.sortMethod)
    header:SetAttribute("sortDir", config.general.sortDir)
    header:SetAttribute("groupingOrder", config.general.groupingOrder)
    header:SetAttribute("groupBy", config.general.groupBy)
    header:SetSize(config.general.width, config.general.height)
    header:SetAttribute("unitsPerColumn", 5)
    header:Show()

    if not UF.configModeEnabled then
        -- visibility NOTE: show must invoke after settings applied
        RegisterAttributeDriver(party, party.driverKey, party.driverValue)
    end
end
AF.RegisterCallback("BFI_UpdateModule", UpdateParty)