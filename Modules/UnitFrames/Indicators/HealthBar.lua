---@type BFI
local BFI = select(2, ...)
local UF = BFI.modules.UnitFrames
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitIsCharmed = UnitIsCharmed
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitClassBase = AF.UnitClassBase
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local UnitCanAttack = UnitCanAttack
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local UnitHealthPercent = UnitHealthPercent
local RunNextFrame = RunNextFrame

---------------------------------------------------------------------
-- health
---------------------------------------------------------------------
local function UpdateHealthStates(self)
    local unit = self.root.effectiveUnit

    self.health = UnitHealth(unit)
    self.healthMax = UnitHealthMax(unit)
end

local function UpdateHealthMax(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    self.healthMax = UnitHealthMax(unit)
    self:SetMinMaxValues(0, self.healthMax)
end

local function UpdateHealth(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    self.health = UnitHealth(unit)
    self:SetValue(self.health)

    -- REVIEW:
    if UnitIsDeadOrGhost(unit) then
        self.fill:Hide()
    else
        self.fill:Show()
    end
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function GetClassColor(type, class, inVehicle)
    if type == "class_color" then
        if inVehicle then
            return AF.GetColorRGB("FRIENDLY")
        else
            return AF.GetClassColor(class)
        end
    elseif type == "class_color_dark" then
        if inVehicle then
            return AF.GetColorRGB("FRIENDLY", nil, 0.2)
        else
            return AF.GetClassColor(class, nil, 0.2)
        end
    end
end

local function GetReactionColor(type, unit)
    if type == "class_color" then
        return AF.GetReactionColor(unit)
    elseif type == "class_color_dark" then
        return AF.GetReactionColor(unit, nil, 0.2)
    end
end

local function GetHealthColor(self, unit, colorTable, skipTapDeniedCheck)
    local class = UnitClassBase(unit) or "UNKNOWN"
    local inVehicle = UnitHasVehicleUI(unit)

    local ctype = colorTable.type
    local gradient = colorTable.gradient
    local rgb = colorTable.rgb
    local alpha = colorTable.alpha

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2

    if AF.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r1, g1, b1 = AF.GetColorRGB("OFFLINE")
        elseif UnitIsCharmed(unit) then
            r1, g1, b1 = AF.GetColorRGB("CHARMED")
        elseif ctype == "custom_color" then
            if gradient == "disabled" then
                r1, g1, b1 = AF.UnpackColor(rgb)
            else
                r1, g1, b1 = AF.UnpackColor(rgb[1])
            end
        else -- class_color, class_color_dark
            r1, g1, b1 = GetClassColor(ctype, class, inVehicle)
        end
    else
        if not skipTapDeniedCheck and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
            r1, g1, b1 = AF.GetColorRGB("TAP_DENIED")
        elseif ctype == "custom_color" then
            if gradient == "disabled" then
                r1, g1, b1 = AF.UnpackColor(rgb)
            else
                r1, g1, b1 = AF.UnpackColor(rgb[1])
            end
        else -- class_color, class_color_dark
            r1, g1, b1 = GetReactionColor(ctype, unit)
        end
    end

    if gradient == "disabled" then
        a1 = alpha
        return nil, r1, g1, b1, a1
    else
        a1, a2 = alpha[1], alpha[2]
        if #rgb == 4 then
            r2, g2, b2 = AF.UnpackColor(rgb)
        else
            r2, g2, b2 = AF.UnpackColor(rgb[2])
        end

        orientation = gradient:find("^vertical") and "VERTICAL" or "HORIZONTAL"
        if gradient:find("flipped$") then
            return orientation, r2, g2, b2, a2, r1, g1, b1, a1
        else
            return orientation, r1, g1, b1, a1, r2, g2, b2, a2
        end
    end
end

local function UpdateHealthColor(self, event, unitId)
    local unit = self.root.unit
    -- if unitId and unit ~= unitId then return end

    -- fill
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor(self, unit, self.fillColor)
    if orientation then
        self:SetGradientFillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetFillColor(r1, g1, b1, a1)
    end

    -- healPrediction
    if not self.healPredictionUseCustomColor then
        self.healPrediction:SetStatusBarColor(r1, g1, b1, 0.4)
    end
end

local function UpdateHealthLossColor(self, event, unitId)
    local unit = self.root.unit
    -- if unitId and unit ~= unitId then return end

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor(self, unit, self.unfillColor, true)
    if orientation then
        self:SetGradientUnfillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetUnfillColor(r1, g1, b1, a1)
    end
end

local function GetHealthColor_Curve(self, unit, colorTable, curve, skipTapDeniedCheck)
    local r1, g1, b1, a1, r2, g2, b2, a2

    local gradient = colorTable.gradient
    local rgb = colorTable.rgb

    if AF.UnitIsPlayer(unit) then
       if not UnitIsConnected(unit) then
            r1, g1, b1, a1 = AF.GetColorRGB("OFFLINE")
        elseif UnitIsCharmed(unit) then
            r1, g1, b1, a1 = AF.GetColorRGB("CHARMED")
        else
            r1, g1, b1, a1 = UnitHealthPercent(unit, nil, curve):GetRGBA()
        end
    else
        if not skipTapDeniedCheck and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
            r1, g1, b1, a1 = AF.GetColorRGB("TAP_DENIED")
        else
            r1, g1, b1, a1 = UnitHealthPercent(unit, nil, curve):GetRGBA()
        end
    end


    if gradient == "disabled" then
        return nil, r1, g1, b1, a1
    else
        r2, g2, b2, a2 = AF.UnpackColor(rgb[4])

        -- NOTE: low efficiency
        -- orientation = gradient:find("^vertical") and "VERTICAL" or "HORIZONTAL"

        if gradient == "horizontal" then
            return "HORIZONTAL", r1, g1, b1, a1, r2, g2, b2, a2
        elseif gradient == "horizontal_flipped" then
            return "HORIZONTAL", r2, g2, b2, a2, r1, g1, b1, a1
        elseif gradient == "vertical" then
            return "VERTICAL", r1, g1, b1, a1, r2, g2, b2, a2
        elseif gradient == "vertical_flipped" then
            return "VERTICAL", r2, g2, b2, a2, r1, g1, b1, a1
        end
    end
end

local function UpdateHealthColor_Curve(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    -- fill
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor_Curve(self, unit, self.fillColor, self.curve)
    if orientation then
        self:SetGradientFillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetFillColor(r1, g1, b1, a1)
    end

    -- healPrediction
    if not self.healPredictionUseCustomColor then
        self:SetHealPredictionColor(r1, g1, b1, 0.4)
    end
end

local function UpdateHealthLossColor_Curve(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor_Curve(self, unit, self.unfillColor, self.lossCurve, true)
    if orientation then
        self:SetGradientUnfillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetUnfillColor(r1, g1, b1, a1)
    end
end

---------------------------------------------------------------------
-- healPrediction
---------------------------------------------------------------------
local function UpdateHealPrediction(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    self:UpdateHealPrediction(unit)
end

---------------------------------------------------------------------
-- damageAbsorb
---------------------------------------------------------------------
local function UpdateDamageAbsorb(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    self:UpdateDamageAbsorb(unit)
end

---------------------------------------------------------------------
-- healAbsorb
---------------------------------------------------------------------
local function UpdateHealAbsorb(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    self:UpdateHealAbsorb(unit)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function HealthBar_Update(self)
    self:UpdateHealthColor()
    self:UpdateHealthLossColor()
    UpdateHealthMax(self)
    UpdateHealth(self)
    if self.healPredictionEnabled then
        UpdateHealPrediction(self)
    end
    if self.shieldEnabled then
        UpdateDamageAbsorb(self)
    end
    if self.healAbsorbEnabled then
        UpdateHealAbsorb(self)
    end
    if self.dispelHighlightEnabled then
        self:UpdateDispelHighlight()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    local unit = self.root.unit
    local effectiveUnit = self.root.effectiveUnit

    self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateHealth)--, UpdateShield, UpdateHealAbsorb, UpdateHealPrediction)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", effectiveUnit, UpdateHealthMax, UpdateHealth)--, UpdateShield, UpdateHealAbsorb, UpdateHealPrediction)

    if self.fillColor.type:find("^health") then
        self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateHealthColor_Curve)
        self:UnregisterEvent("UNIT_FACTION", UpdateHealthColor)
    else
        self:UnregisterEvent("UNIT_HEALTH", UpdateHealthColor_Curve)
        self:RegisterUnitEvent("UNIT_FACTION", unit, UpdateHealthColor)
    end

    if self.unfillColor.type:find("^health") then
        self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateHealthLossColor_Curve)
        self:UnregisterEvent("UNIT_FACTION", UpdateHealthLossColor)
    else
        self:UnregisterEvent("UNIT_HEALTH", UpdateHealthLossColor_Curve)
        self:RegisterUnitEvent("UNIT_FACTION", unit, UpdateHealthLossColor)
    end

    if self.healPredictionEnabled then
        self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", effectiveUnit, UpdateHealPrediction)
        self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateHealPrediction)
        self:RegisterUnitEvent("UNIT_MAXHEALTH", effectiveUnit, UpdateHealPrediction)
    else
        self:UnregisterEvent("UNIT_HEAL_PREDICTION")
        self:UnregisterEvent("UNIT_HEALTH", UpdateHealPrediction)
        self:UnregisterEvent("UNIT_MAXHEALTH", UpdateHealPrediction)
    end

    if self.shieldEnabled then
        self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", effectiveUnit, UpdateDamageAbsorb)
        self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateDamageAbsorb)
        self:RegisterUnitEvent("UNIT_MAXHEALTH", effectiveUnit, UpdateDamageAbsorb)
    else
        self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
        self:UnregisterEvent("UNIT_HEALTH", UpdateDamageAbsorb)
        self:UnregisterEvent("UNIT_MAXHEALTH", UpdateDamageAbsorb)
    end

    if self.healAbsorbEnabled then
        self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", effectiveUnit, UpdateHealAbsorb)
        self:RegisterUnitEvent("UNIT_HEALTH", effectiveUnit, UpdateHealAbsorb)
        self:RegisterUnitEvent("UNIT_MAXHEALTH", effectiveUnit, UpdateHealAbsorb)
    else
        self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
        self:UnregisterEvent("UNIT_HEALTH", UpdateHealAbsorb)
        self:UnregisterEvent("UNIT_MAXHEALTH", UpdateHealAbsorb)
    end

    if self.dispelHighlightEnabled then
        self:EnableDispelHighlight(effectiveUnit, self.dispelHighlightOnlyDispellable)
    end

    self:Show()
    -- C_Timer.After(1, function()
    self:Update()
    -- end)
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function HealthBar_Disable(self)
    self:UnregisterAllEvents()
    self:DisableDispelHighlight()
    self:Hide()
    self:Reset()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthBar_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)
    self:SetSmoothing(config.smoothing)

    self:LSM_SetTexture(config.texture)
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))

    -- heal prediction
    self:EnableHealPrediction(config.healPrediction.enabled)
    self:LSM_SetHealPredictionTexture(config.texture)
    if config.healPrediction.useCustomColor then
        self:SetHealPredictionColor(AF.UnpackColor(config.healPrediction.color))
    end

    -- damage absorb
    self:EnableDamageAbsorb(config.damageAbsorb.enabled)
    self:LSM_SetDamageAbsorbTexture(config.damageAbsorb.texture)
    self:SetDamageAbsorbColor(AF.UnpackColor(config.damageAbsorb.color))
    self:SetDamageAbsorbExcessGlowColor(AF.UnpackColor(config.damageAbsorb.excessGlow.color))
    if config.damageAbsorb.style == "border" then
        self:SetupDamageAbsorb_BorderStyle(config.damageAbsorb.thickness)
    elseif config.damageAbsorb.style == "overlay" then
        self:SetupDamageAbsorb_OverlayStyle(config.damageAbsorb.excessGlow.enabled)
    else
        self:SetupDamageAbsorb_NormalStyle(config.damageAbsorb.reverseFill, config.damageAbsorb.excessGlow.enabled)
    end

    -- heal absorb
    self:EnableHealAbsorb(config.healAbsorb.enabled)
    self:LSM_SetHealAbsorbTexture(config.healAbsorb.texture)
    self:SetHealAbsorbColor(AF.UnpackColor(config.healAbsorb.color))
    self:SetHealAbsorbExcessGlowColor(AF.UnpackColor(config.healAbsorb.excessGlow.color))
    if config.healAbsorb.style == "overlay" then
        self:SetupHealAbsorb_OverlayStyle(config.healAbsorb.excessGlow.enabled)
    else
        self:SetupHealAbsorb_NormalStyle(config.healAbsorb.excessGlow.enabled)
    end

    -- dispel highlight
    self:SetDispelHighlightBlendMode(config.dispelHighlight.blendMode)
    self:SetDispelHighlightAlpha(config.dispelHighlight.alpha)
    if not config.dispelHighlight.enabled then
        self:DisableDispelHighlight()
    end

    -- mouseover highlight
    self:EnableMouseoverHighlight(config.mouseoverHighlight.enabled)
    self:SetMouseoverHighlightColor(AF.UnpackColor(config.mouseoverHighlight.color))

    -- DispelHighlight_Setup(self, config.dispelHighlight)

    self.fillColor = config.fillColor
    if self.fillColor.type:find("^health") then
        self.UpdateHealthColor = UpdateHealthColor_Curve
        self.curve = F.GetColorCurve(self.fillColor.type, self.fillColor.thresholds, self.fillColor.rgb)
    else
        self.UpdateHealthColor = UpdateHealthColor
    end

    self.unfillColor = config.unfillColor
    if self.unfillColor.type:find("^health") then
        self.UpdateHealthLossColor = UpdateHealthLossColor_Curve
        self.lossCurve = F.GetColorCurve(self.unfillColor.type, self.unfillColor.thresholds, self.unfillColor.rgb)
    else
        self.UpdateHealthLossColor = UpdateHealthLossColor
    end

    self.shieldEnabled = config.damageAbsorb.enabled
    self.healAbsorbEnabled = config.healAbsorb.enabled
    self.healPredictionEnabled = config.healPrediction.enabled
    self.healPredictionUseCustomColor = config.healPrediction.useCustomColor
    self.dispelHighlightEnabled = config.dispelHighlight.enabled
    self.dispelHighlightOnlyDispellable = config.dispelHighlight.dispellable
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local _UpdateHealthStates = UpdateHealthStates
local function HealthBar_EnableConfigMode(self, isRepeatCall)
    self:UnregisterAllEvents()
    self.Enable = HealthBar_EnableConfigMode
    self.Update = AF.noop

    UnitGetTotalAbsorbs = UF.CFG_UnitGetTotalAbsorbs
    UnitGetTotalHealAbsorbs = UF.CFG_UnitGetTotalHealAbsorbs
    UpdateHealthStates = AF.noop

    self.health = UF.CFG_UnitHealth()
    self.healthMax = UF.CFG_UnitHealthMax()
    self.healthPercent = self.health / self.healthMax

    HealthBar_Update(self)

    if not isRepeatCall then
        -- fix shield
        RunNextFrame(function()
            HealthBar_EnableConfigMode(self, true)
        end)
    end

    self:SetShown(self.enabled)
end

local function HealthBar_DisableConfigMode(self)
    self.Enable = HealthBar_Enable
    self.Update = HealthBar_Update

    UnitGetTotalAbsorbs = UF.UnitGetTotalAbsorbs
    UnitGetTotalHealAbsorbs = UF.UnitGetTotalHealAbsorbs
    UpdateHealthStates = _UpdateHealthStates
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
-- TODO: gradient texture & mask
function UF.CreateHealthBar(parent, name)
    -- bar
    local bar = AF.CreateSecretHealthBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    AF.AddEventHandler(bar)

    -- -- dispel highlight
    -- local dispelHighlight = bar:CreateTexture(name .. "DispelHighlight", "ARTWORK", nil, 1)
    -- bar.dispelHighlight = dispelHighlight
    -- dispelHighlight:SetAllPoints(bar.fill.mask)
    -- dispelHighlight:Hide()

    -- bar.dispelTypes = {}

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.Disable = HealthBar_Disable
    bar.EnableConfigMode = HealthBar_EnableConfigMode
    bar.DisableConfigMode = HealthBar_DisableConfigMode
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(bar, bar.DefaultUpdatePixels)

    return bar
end