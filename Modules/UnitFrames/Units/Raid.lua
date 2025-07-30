---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local raid
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    -- "powerText",
    "leaderIcon",
    -- "targetCounter",
    "statusTimer",
    "statusIcon",
    "raidIcon",
    "readyCheckIcon",
    "roleIcon",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

-- bottom_to_top_then_left
-- bottom_to_top_then_right
-- top_to_bottom_then_left
-- top_to_bottom_then_right
-- left_to_right_then_bottom
-- left_to_right_then_top
-- right_to_left_then_bottom
-- right_to_left_then_top

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateRaid()
    local name = "BFI_Raid"
    raid = CreateFrame("Frame", name, UF.Parent, "SecureFrameTemplate")
    UF.AddToConfigMode("raid.container", raid)

    local header = CreateFrame("Frame", name .. "Header", raid, "SecureGroupHeaderTemplate")
    raid.header = header
    UF.AddToConfigMode("raid.header", header)
    header:SetAttribute("template", "BFIUnitButtonTemplate")
    header:SetAttribute("showSolo", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)

    --! to make needButtons == 40 in SecureGroupHeaders.lua
    header:SetAttribute("startingIndex", -39)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    header:HookScript("OnAttributeChanged", function(self, attr)
        if not self.inConfigMode then return end
        if self:GetAttribute("startingIndex") ~= -39 then
            self:SetAttribute("startingIndex", -39)
        end
    end)

    raid.driverKey = "state-visibility"
    raid.driverValue = "[@raid1,exists] show; hide"

    for i = 1, 40 do
        header[i]._updateOnGroupUpdate = true
        header[i].enableUnitButtonMapping = true
        UF.AddToConfigMode("raid", header[i])
        UF.CreateIndicators(header[i], indicators)
    end

    -- mover
    AF.CreateMover(raid, "BFI: " .. L["Unit Frames"], _G.RAID)

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(raid, nil, true)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateRaid(_, module, which)
    if C_AddOns.IsAddOnLoaded("Cell") then
        return
    end

    if module and module ~= "unitFrames" then return end
    if which and which ~= "raid" then return end

    local config = UF.config.raid

    if not config.general.enabled then
        if raid then
            UnregisterAttributeDriver(raid)
            for i = 1, 40 do
                UF.DisableIndicators(raid.header[i])
            end
            UF.RemoveFromConfigMode("raid")
            raid.enabled = false -- for mover
            raid:Hide()
        end
        return
    end

    if not raid then
        CreateRaid()
    end

    raid.enabled = true -- for mover

    -- setup
    local header = raid.header

    -- mover
    AF.UpdateMoverSave(raid, config.general.position)

    -- position
    AF.LoadPosition(raid, config.general.position)

    -- container size
    if strfind(config.general.orientation, "^[top|bottom]") then
        AF.SetGridSize(raid, config.general.width, config.general.height,
            config.general.spacingX, config.general.spacingY,
            config.general.maxColumns, config.general.unitsPerColumn
        )
    else
        AF.SetGridSize(raid, config.general.width, config.general.height,
            config.general.spacingX, config.general.spacingY,
            config.general.unitsPerColumn, config.general.maxColumns
        )
    end

    -- buttons
    for i = 1, 40 do
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
        UF.SetupIndicators(button, indicators, config)
    end

    -- header
    local p, rp, x, y, cs, hp, cp = AF.GetAnchorPoints_GroupHeader(config.general.orientation, config.general.spacingX, config.general.spacingY)
    header:SetSize(config.general.width, config.general.height)
    header:ClearAllPoints()
    header:SetPoint(p, raid)
    header:SetAttribute("point", hp)
    header:SetAttribute("columnAnchorPoint", cp)
    header:SetAttribute("columnSpacing", cs)
    header:SetAttribute("xOffset", x)
    header:SetAttribute("yOffset", y)
    header:SetAttribute("sortMethod", config.general.sortMethod)
    header:SetAttribute("sortDir", config.general.sortDir)
    header:SetAttribute("groupingOrder", config.general.groupingOrder)
    header:SetAttribute("groupBy", config.general.groupBy)
    header:SetAttribute("buttonWidth", AF.ConvertPixelsForRegion(config.general.width, raid))
    header:SetAttribute("buttonHeight", AF.ConvertPixelsForRegion(config.general.height, raid))
    header:SetAttribute("maxColumns", config.general.maxColumns)
    header:SetAttribute("unitsPerColumn", config.general.unitsPerColumn)
    header:Show()

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(raid, raid.driverKey, raid.driverValue)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateRaid)