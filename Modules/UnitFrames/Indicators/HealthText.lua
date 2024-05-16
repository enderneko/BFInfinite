local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local format = string.format

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
-- format
---------------------------------------------------------------------
local function HealthText_SetHealth(self, current, max, absorbs)
    self:SetFormattedText("%s%s%s", self.GetNumeric(current, max, absorbs), self.delimiter, self.GetPercent(current, max, absorbs))
end

local function HealthText_SetFormat(self, format)
    self.GetNumeric = numeric[format.numeric]
    self.GetPercent = percent[format.percent]
    self.delimiter = format.delimiter
end

---------------------------------------------------------------------
-- others
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

local function HealthText_SetFont(self, font, size, flags)
    font = U.GetFont(font)

    if flags == "shadow" then
        self:SetFont(font, size, "")
        self:SetShadowOffset(1, -1)
        self:SetShadowColor(0, 0, 0, 1)
    else
        if flags == "none" then
            flags = ""
        elseif flags == "outline" then
            flags = "OUTLINE"
        else
            flags = "OUTLINE,MONOCHROME"
        end
        self:SetFont(font, size, flags)
        self:SetShadowOffset(0, 0)
        self:SetShadowColor(0, 0, 0, 0)
    end
end

local function HealthText_LoadConfig(self, config)
    self:SetHealthFont(unpack(config.font))
    self:SetFormat(config.format)

    local button = self:GetParent():GetParent()
    if config.anchorTo == "button" then
        AW.LoadWidgetPosition(self, config.position)
        self.relativeTo = button
    else
        if config.anchorTo == "healthBar" then
            AW.LoadWidgetPosition(self, config.position, button.indicators.healthBar)
            self.relativeTo = button.indicators.healthBar
        elseif config.anchorTo == "powerBar" then
            AW.LoadWidgetPosition(self, config.position, button.indicators.powerBar)
            self.relativeTo = button.indicators.powerBar
        end
    end

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateHealthText(parent)
    local text = parent.overlay:CreateFontString(nil, "OVERLAY", AW.GetFontName("normal"))

    text.SetHealth = HealthText_SetHealth
    text.SetColor = HealthText_SetColor
    text.SetFormat = HealthText_SetFormat
    text.SetHealthFont = HealthText_SetFont
    text.LoadConfig = HealthText_LoadConfig

    return text
end