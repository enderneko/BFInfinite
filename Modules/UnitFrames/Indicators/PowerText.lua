local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local find = string.find
local gsub = string.gsub
local format = string.format
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

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

    self:SetFormattedText("%s%s%s",
        self.GetNumeric(self.power),
        self.delimiter,
        self.GetPercent(self.power, self.powerMax))
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local class = U.UnitClassBase(unit)

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
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
    -- if self:IsVisible() then self:Update() end
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
        return U.FormatNumber(current)
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
    if format.noPercentSign then
        self.GetPercent = percent_np[format.percent]
    else
        self.GetPercent = percent[format.percent]
    end

    if format.numeric == "none" or format.percent == "none" then
        self.delimiter = ""
    else
        self.delimiter = format.delimiter
    end
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function PowerText_SetColor(self, color)
    self:SetTextColor(unpack(color))
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function PowerText_LoadConfig(self, config)
    self:SetHealthFont(unpack(config.font))
    self:SetFormat(config.format)
    UF.LoadTextPosition(self, config)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePowerText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY", AW.GetFontName("normal"))
    text.root = parent

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = PowerText_Enable
    text.Update = PowerText_Update
    text.SetColor = PowerText_SetColor
    text.SetFormat = PowerText_SetFormat
    text.SetHealthFont = U.SetFont
    text.LoadConfig = PowerText_LoadConfig

    return text
end