---@type BFI
local BFI = select(2, ...)
local UF = BFI.modules.UnitFrames
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local RunNextFrame = RunNextFrame

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function HealthBar_Update(self)
    self:UpdateAll()
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:SetUnit(self.root.effectiveUnit)
    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function HealthBar_Disable(self)
    self:ClearUnit()
    self:Hide()
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
    else
        self:ClearHealPredictionColor()
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
    self:EnableDispelHighlight(config.dispelHighlight.enabled, config.dispelHighlight.dispellable)
    self:SetDispelHighlightBlendMode(config.dispelHighlight.blendMode)
    self:SetDispelHighlightAlpha(config.dispelHighlight.alpha)

    -- mouseover highlight
    self:EnableMouseoverHighlight(config.mouseoverHighlight.enabled)
    self:SetMouseoverHighlightColor(AF.UnpackColor(config.mouseoverHighlight.color))

    -- color
    self:SetupFillColor(config.fillColor)
    self:SetupUnfillColor(config.unfillColor)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function HealthBar_EnableConfigMode(self, isRepeatCall)
    self:UnregisterAllEvents()
    self.Enable = HealthBar_EnableConfigMode
    self.Update = AF.noop

    UnitGetTotalAbsorbs = UF.CFG_UnitGetTotalAbsorbs
    UnitGetTotalHealAbsorbs = UF.CFG_UnitGetTotalHealAbsorbs

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