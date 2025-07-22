---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local find = string.find
local gsub = string.gsub
local format = string.format
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitClassBase = AF.UnitClassBase
local FormatNumber = AF.FormatNumber

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePower(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    self.power = UnitPower(unit)
    self.powerMax = UnitPowerMax(unit)

    if self.powerMax == 0 then
        self.powerMax = 1
    end

    if self.hideIfEmpty and self.power == 0 then
        self:Hide()
        return
    end

    if self.hideIfFull and self.power >= self.powerMax then
        self:Hide()
        return
    end

    self:SetFormattedText("%s%s%s",
        self.GetNumeric(self.power),
        self.delimiter,
        self.GetPercent(self.power, self.powerMax))
    self:Show()
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local class = UnitClassBase(unit)

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if AF.UnitIsPlayer(unit) then
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    elseif self.color.type == "power_color" then
        local powerType = select(2, UnitPowerType(unit))
        r, g, b = AF.GetPowerColor(powerType, unit)
    else
        r, g, b = unpack(self.color.rgb)
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function PowerText_Enable(self)
    if self.frequent then
        self:RegisterEvent("UNIT_POWER_FREQUENT", UpdatePower)
        self:UnregisterEvent("UNIT_POWER_UPDATE")
    else
        self:RegisterEvent("UNIT_POWER_UPDATE", UpdatePower)
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
    end
    self:RegisterEvent("UNIT_MAXPOWER", UpdatePower)
    self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateColor, UpdatePower)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function PowerText_Update(self)
    UpdatePower(self)
    UpdateColor(self)
end

---------------------------------------------------------------------
-- numeric
---------------------------------------------------------------------
local numeric = {
    none = function()
        return ""
    end,

    current = function(current)
        return current
    end,

    current_short = function(current)
        return FormatNumber(current)
    end,
}

---------------------------------------------------------------------
-- percent
---------------------------------------------------------------------
local percent = {
    none = function()
        return ""
    end,

    current = function(current, max)
        return format("%d%%", current/max*100)
    end,

    current_decimal = function(current, max)
        return format("%.1f%%", current/max*100):gsub("%.0%%$", "%%")
    end,
}

---------------------------------------------------------------------
-- percent (no percent sign)
---------------------------------------------------------------------
local percent_np = {
    none = function()
        return ""
    end,

    current = function(current, max)
        return format("%d", current/max*100)
    end,

    current_decimal = function(current, max)
        return format("%.1f", current/max*100):gsub("%.0$", "")
    end,
}

---------------------------------------------------------------------
-- format
---------------------------------------------------------------------
local function PowerText_SetFormat(self, format)
    self.GetNumeric = numeric[format.numeric]
    if format.showPercentSign then
        self.GetPercent = percent[format.percent]
    else
        self.GetPercent = percent_np[format.percent]
    end

    if format.numeric == "none" or format.percent == "none" then
        self.delimiter = ""
    else
        self.delimiter = format.delimiter
    end

    if format.useAsianUnits and AF.isAsian then
        FormatNumber = AF.FormatNumber_Asian
    else
        FormatNumber = AF.FormatNumber
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function PowerText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    PowerText_SetFormat(self, config.format)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
    self.frequent = config.frequent
    self.hideIfFull = config.hideIfFull
    self.hideIfEmpty = config.hideIfEmpty
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function PowerText_EnableConfigMode(self)
    self.Enable = PowerText_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:Show()

    UnitPower = UF.CFG_UnitPower
    UnitPowerMax = UF.CFG_UnitPowerMax

    PowerText_Update(self)
end

local function PowerText_DisableConfigMode(self)
    self.Enable = PowerText_Enable
    self.Update = PowerText_Update

    UnitPower = UF.UnitPower
    UnitPowerMax = UF.UnitPowerMax
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePowerText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY", "AF_FONT_NORMAL")
    text.root = parent
    text:Hide()

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = PowerText_Enable
    text.Update = PowerText_Update
    text.EnableConfigMode = PowerText_EnableConfigMode
    text.DisableConfigMode = PowerText_DisableConfigMode
    text.LoadConfig = PowerText_LoadConfig

    return text
end