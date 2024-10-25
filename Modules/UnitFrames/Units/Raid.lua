---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local UF = BFI.UnitFrames

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
    AW.CreateMover(raid, L["Unit Frames"], _G.RAID)

    -- pixel perfect
    AW.AddToPixelUpdater(raid)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateRaid(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "raid" then return end

    local config = UF.config.raid

    if not config.enabled then
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
    AW.UpdateMoverSave(raid, config.general.position)

    -- position
    AW.LoadPosition(raid, config.general.position)

    -- container size
    if strfind(config.general.orientation, "^[top|bottom]") then
        AW.SetGridSize(raid, config.general.width, config.general.height,
            config.general.spacingH, config.general.spacingV,
            config.general.maxColumns, config.general.unitsPerColumn
        )
    else
        AW.SetGridSize(raid, config.general.width, config.general.height,
            config.general.spacingH, config.general.spacingV,
            config.general.unitsPerColumn, config.general.maxColumns
        )
    end

    -- buttons
    for i = 1, 40 do
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
    local p, rp, x, y, cs, hp, cp = AW.GetAnchorPoints_GroupHeader(config.general.orientation, config.general.spacingH, config.general.spacingV)
    header:SetSize(config.general.width, config.general.height)
    header:ClearAllPoints()
    header:SetPoint(p, raid)
    header:SetAttribute("point", hp)
    header:SetAttribute("columnAnchorPoint", cp)
    header:SetAttribute("columnSpacing", cs)
    header:SetAttribute("xOffset", x)
    header:SetAttribute("yOffset", y)
    header:SetAttribute("buttonWidth", AW.ConvertPixelsForRegion(config.general.width, raid))
    header:SetAttribute("buttonHeight", AW.ConvertPixelsForRegion(config.general.height, raid))
    header:SetAttribute("maxColumns", config.general.maxColumns)
    header:SetAttribute("unitsPerColumn", config.general.unitsPerColumn)
    header:Show()

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(raid, raid.driverKey, raid.driverValue)
end
BFI.RegisterCallback("UpdateModules", "UF_Raid", UpdateRaid)