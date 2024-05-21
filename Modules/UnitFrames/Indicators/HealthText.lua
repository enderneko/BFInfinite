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
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateHealth(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    self.health = UnitHealth(unit)
    self.healthMax = UnitHealthMax(unit)
    self.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if self.healthMax == 0 then
        self.healthMax = 1
    end

    self:SetValue(self.health, self.healthMax, self.totalAbsorbs)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthText_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealth)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateHealth)

    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function HealthText_Update(self)
    UpdateHealth(self)
end

---------------------------------------------------------------------
-- numeric
---------------------------------------------------------------------
local numeric = {
    none = function()
        return ""
    end,

    current = function(current, max, absorbs)
        return current
    end,

    current_short = function(current, max, absorbs)
        return U.FormatNumber(current)
    end,

    current_absorbs = function(current, max, absorbs)
        if absorbs == 0 then
            return current
        else
            return format("%s+%s", current, absorbs)
        end
    end,

    current_absorbs_sum = function(current, max, absorbs)
        return current + absorbs
    end,

    current_absorbs_short = function(current, max, absorbs)
        if absorbs == 0 then
            return U.FormatNumber(current)
        else
            return format("%s+%s", U.FormatNumber(current), U.FormatNumber(absorbs))
        end
    end,

    current_absorbs_short_sum = function(current, max, absorbs)
        return U.FormatNumber(current + absorbs)
    end,
}

---------------------------------------------------------------------
-- percent
---------------------------------------------------------------------
local percent = {
    none = function()
        return ""
    end,

    current = function(current, max, absorbs)
        return format("%d%%", current/max*100)
    end,

    current_decimal = function(current, max, absorbs)
        return format("%.1f%%", current/max*100)
    end,

    current_absorbs = function(current, max, absorbs)
        if absorbs == 0 then
            return format("%d%%", current/max*100)
        else
            return format("%d%%+%d%%", current/max*100, absorbs/max*100)
        end
    end,

    current_absorbs_decimal = function(current, max, absorbs)
        if absorbs == 0 then
            return format("%.1f%%", current/max*100):gsub("%.0%%$", "%%")
        else
            return format("%.1f%%+%.1f%%", current/max*100, absorbs/max*100):gsub("%.0%%", "%%")
        end
    end,

    current_absorbs_sum = function(current, max, absorbs)
        return format("%d%%", (current+absorbs)/max*100)
    end,

    current_absorbs_sum_decimal = function(current, max, absorbs)
        return format("%.1f%%", (current+absorbs)/max*100):gsub("%.0%%$", "%%")
    end,
}

---------------------------------------------------------------------
-- percent (no percent sign)
---------------------------------------------------------------------
local percent_np = {
    none = function()
        return ""
    end,

    current = function(current, max, absorbs)
        return format("%d", current/max*100)
    end,

    current_decimal = function(current, max, absorbs)
        return format("%.1f", current/max*100)
    end,

    current_absorbs = function(current, max, absorbs)
        if absorbs == 0 then
            return format("%d", current/max*100)
        else
            return format("%d+%d", current/max*100, absorbs/max*100)
        end
    end,

    current_absorbs_decimal = function(current, max, absorbs)
        if absorbs == 0 then
            return format("%.1f", current/max*100):gsub("%.0$", "")
        else
            return format("%.1f+%.1f", current/max*100, absorbs/max*100):gsub("%.0", "")
        end
    end,

    current_absorbs_sum = function(current, max, absorbs)
        return format("%d", (current+absorbs)/max*100)
    end,

    current_absorbs_sum_decimal = function(current, max, absorbs)
        return format("%.1f", (current+absorbs)/max*100):gsub("%.0$", "")
    end,
}

---------------------------------------------------------------------
-- format
---------------------------------------------------------------------
local function HealthText_SetValue(self, current, max, absorbs)
    self:SetFormattedText("%s%s%s", self.GetNumeric(current, max, absorbs), self.delimiter, self.GetPercent(current, max, absorbs))
end

local function HealthText_SetFormat(self, format)
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
local function HealthText_SetColor(self, unit, class)
    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
    else
        if U.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AW.GetClassColor(class)
            else
                r, g, b = unpack(self.color.rgb)
            end
        else
            r, g, b = unpack(self.color.rgb)
        end
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthText_LoadConfig(self, config)
    self:SetHealthFont(unpack(config.font))
    self:SetFormat(config.format)

    if config.anchorTo == "button" then
        self:SetParent(self.root)
    else
        self:SetParent(self.root.indicators[config.anchorTo])
    end
    AW.LoadWidgetPosition(self, config.position)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateHealthText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY", AW.GetFontName("normal"))
    text.root = parent

    -- events
    BFI.SetEventHandler(text)

    -- functions
    text.Enable = HealthText_Enable
    text.Update = HealthText_Update
    text.SetValue = HealthText_SetValue
    text.SetColor = HealthText_SetColor
    text.SetFormat = HealthText_SetFormat
    text.SetHealthFont = U.SetFont
    text.LoadConfig = HealthText_LoadConfig

    return text
end