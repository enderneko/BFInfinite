---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

--! NOTE: only available for PLAYER
local class = BFI.vars.playerClass

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitStagger = UnitStagger
local UnitHealthMax = UnitHealthMax
local UnitHasVehicleUI = UnitHasVehicleUI
local FormatNumber = U.FormatNumber

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateStagger(self, event, unitId)
    if unitId and unitId ~= "player" then return end

    local stagger = UnitStagger("player") or 0
    local staggerMax = UnitHealthMax("player")

    local p = stagger / staggerMax
    if p >= 0.6 then
		self:SetColor(AW.GetColorRGB("STAGGER_RED"))
    elseif p >= 0.3 then
        self:SetColor(AW.GetColorRGB("STAGGER_YELLOW"))
    else
        self:SetColor(AW.GetColorRGB("STAGGER_GREEN"))
	end

    if self.textEnabled then
        self.text:SetFormattedText("%s%s%s",
                self.GetNumeric(stagger),
                self.delimiter,
                self.GetPercent(p))
    end

    self:SetBarMinMaxValues(0, staggerMax)
    self:SetBarValue(stagger)
end


---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
local function Check(self, event, unitId)
    if event ~= "ACTIVE_TALENT_GROUP_CHANGED" and unitId and unitId ~= "player" then return end

    if class ~= "MONK" or GetSpecialization() ~= 1 or UnitHasVehicleUI("player") then
        self:Hide()
        self:UnregisterEvent("UNIT_AURA")
        self._enabled = nil
        return
    end

    self._enabled = true

    -- register events
    self:RegisterEvent("UNIT_AURA", UpdateStagger)

    -- update now
    self:Show()
    UpdateStagger(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function StaggerBar_Enable(self)
    if class ~= "MONK" then
        self:Hide()
        return
    end

    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Check)
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", Check)
    self:RegisterEvent("UNIT_EXITED_VEHICLE", Check)

    Check(self)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function StaggerBar_Update(self)
    if self._enabled then
        UpdateStagger(self)
    end
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

    current = function(p)
        return format("%d%%", p*100)
    end,

    current_decimal = function(p)
        return format("%.1f%%", p*100):gsub("%.0%%$", "%%")
    end,
}

---------------------------------------------------------------------
-- percent (no percent sign)
---------------------------------------------------------------------
local percent_np = {
    none = function()
        return ""
    end,

    current = function(p)
        return format("%d", p*100)
    end,

    current_decimal = function(p)
        return format("%.1f", p*100):gsub("%.0$", "")
    end,
}

---------------------------------------------------------------------
-- text
---------------------------------------------------------------------
local function StaggerText_SetFormat(self, format)
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

local function StaggerBar_SetupText(self, config)
    U.SetFont(self.text, config.font)
    UF.LoadIndicatorPosition(self, config.position)
    self.text:SetTextColor(AW.UnpackColor(config.color))
    StaggerText_SetFormat(self, config.format)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function StaggerBar_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)

    self:SetTexture(U.GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))

    self.textEnabled = config.text.enabled
    if self.textEnabled then
        StaggerBar_SetupText(self, config.text)
        self.text:Show()
    else
        self.text:Hide()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateStaggerBar(parent, name)
    -- bar
    local bar = AW.CreateSimpleBar(parent, name)
    bar.root = parent
    bar:Hide()

    bar:SetLossColor(0, 0, 0, 0)

    -- text
    bar.text = bar:CreateFontString(nil, "OVERLAY")

    -- events
    BFI.AddEventHandler(bar)

    -- functions
    bar.Update = StaggerBar_Update
    bar.Enable = StaggerBar_Enable
    bar.LoadConfig = StaggerBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar)

    return bar
end