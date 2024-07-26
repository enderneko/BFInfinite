---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.M_NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitIsConnected = UnitIsConnected
local UnitClassBase = UnitClassBase
local FormatNumber = U.FormatNumber

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateHealth(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    self.health = UnitHealth(unit)
    self.healthMax = UnitHealthMax(unit)
    self.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if self.healthMax == 0 then
        self.healthMax = 1
    end

    self:SetFormattedText("%s%s%s",
        self.GetNumeric(self.health, self.totalAbsorbs),
        self.delimiter,
        self.GetPercent(self.health, self.healthMax, self.totalAbsorbs))
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            local class = UnitClassBase(unit)
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
    else -- custom_color
        r, g, b = unpack(self.color.rgb)
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthText_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealth)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateHealth)

    self:Show()
    if self.root:IsVisible() then self:Update() end
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

    current = function(current, absorbs)
        return current
    end,

    current_short = function(current, absorbs)
        return FormatNumber(current)
    end,

    current_absorbs = function(current, absorbs)
        if absorbs == 0 then
            return current
        else
            return format("%s+%s", current, absorbs)
        end
    end,

    current_absorbs_sum = function(current, absorbs)
        return current + absorbs
    end,

    current_absorbs_short = function(current, absorbs)
        if absorbs == 0 then
            return FormatNumber(current)
        else
            return format("%s+%s", FormatNumber(current), FormatNumber(absorbs))
        end
    end,

    current_absorbs_short_sum = function(current, absorbs)
        return FormatNumber(current + absorbs)
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
        return format("%.1f%%", current/max*100):gsub("%.0%%$", "%%")
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
        return format("%.1f", current/max*100):gsub("%.0$", "")
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

    if format.useAsianUnits and BFI.vars.isAsian then
        FormatNumber = U.FormatNumber_Asian
    else
        FormatNumber = U.FormatNumber
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    HealthText_SetFormat(self, config.format)
    NP.LoadIndicatorPosition(self, config)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateHealthText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY", AW.GetFontName("normal"))
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = HealthText_Enable
    text.Update = HealthText_Update
    text.LoadConfig = HealthText_LoadConfig

    return text
end