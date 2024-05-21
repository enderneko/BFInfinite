local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitIsCharmed = UnitIsCharmed
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- health
---------------------------------------------------------------------
local function UpdateHealthStates(self)
    local unit = self.root.displayedUnit

    self.health = UnitHealth(unit)
    self.healthMax = UnitHealthMax(unit)
    self.shields = UnitGetTotalAbsorbs(unit)

    if self.healthMax == 0 then
        self.healthMax = 1
        self.healthPercent = 0
        self.shieldPercent = 0
    else
        self.healthPercent = self.health / self.healthMax
        self.shieldPercent = self.shields / self.healthMax
    end
end

local function UpdateHealthMax(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    UpdateHealthStates(self)
    self:SetBarMinMaxValues(0, self.healthMax)
end

local function UpdateHealth(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    UpdateHealthStates(self)
    self:SetBarValue(self.health)
end

---------------------------------------------------------------------
-- shield
---------------------------------------------------------------------
local function UpdateShield(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    -- overshieldGlow
    if not self.shieldEnabled or not self.overshieldGlowEnabled then
        self.overshieldGlow:Hide()
        self.overshieldGlowR:Hide()
    end

    if not self.shieldEnabled then
        self.shield:Hide()
        return
    end

    UpdateHealthStates(self)

    local overs = self.shieldPercent + self.healthPercent > 1

    if self.shieldReverseFill and overs then -- reverse
        self.shield:ClearAllPoints()
        self.shield:SetPoint("TOPRIGHT")
        self.shield:SetPoint("BOTTOMRIGHT")
    else
        self.shield:ClearAllPoints()
        self.shield:SetPoint("TOPLEFT", self.texture, "TOPRIGHT")
        self.shield:SetPoint("BOTTOMLEFT", self.texture, "BOTTOMRIGHT")
    end

    if self.shields > 0 then
        local barWidth = self:GetWidth()

        if overs then -- overshield
            if self.shieldReverseFill then -- reverse
                local p = self.shieldPercent
                if p > 1 then p = 1 end
                self.shield:SetWidth(p * barWidth)
                self.shield:Show()

                if self.overshieldGlowEnabled then
                    self.overshieldGlowR:Show()
                end
                self.overshieldGlow:Hide()
            else -- normal
                local p = 1 - self.healthPercent
                if p ~= 0 then
                    self.shield:SetWidth(p * barWidth)
                    self.shield:Show()
                else
                    self.shield:Hide()
                end

                if self.overshieldGlowEnabled then
                    self.overshieldGlow:Show()
                end
                self.overshieldGlowR:Hide()
            end
        else
            self.shield:SetWidth(self.shieldPercent * barWidth)
            self.shield:Show()
            self.overshieldGlow:Hide()
            self.overshieldGlowR:Hide()
        end
    else
        self.shield:Hide()
        self.overshieldGlow:Hide()
        self.overshieldGlowR:Hide()
    end
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function GetClassColor(type, class, inVehicle)
    if type == "class_color" then
        if inVehicle then
            return AW.GetColorRGB("FRIENDLY")
        else
            return AW.GetClassColor(class)
        end
    elseif type == "class_color_dark" then
        if inVehicle then
            return AW.GetColorRGB("FRIENDLY", nil, 0.2)
        else
            return AW.GetClassColor(class, nil, 0.2)
        end
    end
end

local function GetReactionColor(type, unit)
    if type == "class_color" then
        return AW.GetReactionColor(unit)
    elseif type == "class_color_dark" then
        return AW.GetReactionColor(unit, nil, 0.2)
    end
end

local function GetHealthColor(self, unit)
    if not (self.color and self.lossColor) then return end

    local class = UnitClassBase(unit)
    local inVehicle = UnitHasVehicleUI(unit)

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = self.color.alpha
    lossA = self.lossColor.alpha

    if U.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r, g, b = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        elseif UnitIsCharmed(unit) then
            r, g, b = 0.5, 0, 1
            lossR, lossG, lossB = barR*0.2, barG*0.2, barB*0.2
        else
            -- bar
            if self.color.type == "custom_color" then
                r, g, b = unpack(self.color.rgb)
            else
                r, g, b = GetClassColor(self.color.type, class, inVehicle)
            end

            -- loss
            if self.lossColor.type == "custom_color" then
                lossR, lossG, lossB = unpack(self.lossColor.rgb)
            else
                lossR, lossG, lossB = GetClassColor(self.lossColor.type, class, inVehicle)
            end
        end
    else
        -- bar
        if self.color.type == "custom_color" then
            r, g, b = unpack(self.color.rgb)
        else
            r, g, b = GetReactionColor(self.color.type, unit)
        end

        -- loss
        if self.lossColor.type == "custom_color" then
            lossR, lossG, lossB = unpack(self.lossColor.rgb)
        else
            lossR, lossG, lossB = GetReactionColor(self.lossColor.type, unit)
        end
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end

local function UpdateHealthColor(self)
    local unit = self.root.unit
    if not unit then return end

    -- healthBar
    local r, g, b, a, lossR, lossG, lossB, lossA = GetHealthColor(self, unit)
    self:SetStatusBarColor(r, g, b, a)
    self.loss:SetVertexColor(lossR, lossG, lossB, lossA)

    -- healPrediction
    if not self.healPredictionUseCustomColor then
        self.healPrediction:SetVertexColor(r, g, b, 0.4)
    end
end

---------------------------------------------------------------------
-- heal prediction
---------------------------------------------------------------------
local function UpdateHealPrediction(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    if not self.healPredictionEnabled then
        self.healPrediction:Hide()
        return
    end

    UpdateHealthStates(self)

    local value = UnitGetIncomingHeals(unit) or 0
    local lostP = 1 - self.healthPercent

    if lostP ~= 0 and value > 0 then
        local p = value / self.healthMax
        if p > lostP then p = lostP end
        self.healPrediction:SetWidth(p * self:GetWidth())
        self.healPrediction:Show()
    else
        self.healPrediction:Hide()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth, UpdateShield, UpdateHealPrediction)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealthMax, UpdateHealth, UpdateShield, UpdateHealPrediction)
    self:RegisterEvent("UNIT_NAME_UPDATE", UpdateHealthColor)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateShield)
    self:RegisterEvent("UNIT_HEAL_PREDICTION", UpdateHealPrediction)

    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function HealthBar_Update(self)
    UpdateHealthColor(self)
    UpdateHealthMax(self)
    UpdateHealth(self)
    UpdateShield(self)
    UpdateHealPrediction(self)
end

---------------------------------------------------------------------
-- basic
---------------------------------------------------------------------
local function HealthBar_SetColor(self, color)
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end

local function HealthBar_SetLossColor(self, color)
    self.loss:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function HealthBar_SetBackgroudColor(self, color)
    self.container:SetBackdropColor(unpack(color))
end

local function HealthBar_SetBorderColor(self, color)
    self.container:SetBackdropBorderColor(unpack(color))
end

local function ShieldBar_SetColor(self, color)
    self.shield:SetVertexColor(unpack(color))
end

local function OvershieldGlow_SetColor(self, color)
    self.overshieldGlow:SetVertexColor(unpack(color))
    self.overshieldGlowR:SetVertexColor(unpack(color))
end

local function HealPrediction_SetColor(self, color)
    self.healPrediction:SetVertexColor(unpack(color))
end

-- local function HealthBar_SetOrientation(self, orientation)
--     self:SetOrientation(orientation)
--     self.loss:ClearAllPoints()
--     if orientation == "HORIZONTAL" then
--         self.loss:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT")
--         self.loss:SetPoint("BOTTOMRIGHT")
--     else
--         self.loss:SetPoint("TOPLEFT")
--         self.loss:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "TOPRIGHT")
--     end
-- end

local function HealthBar_SetTexture(self, texture)
    texture = U.GetBarTexture(texture)
    self:SetStatusBarTexture(texture)
    self:GetStatusBarTexture():SetDrawLayer("OVERLAY", 0)
    self.loss:SetTexture(texture)
    self.loss:SetDrawLayer("OVERLAY", 0)
    self.healPrediction:SetTexture(texture)
    self.healPrediction:SetDrawLayer("OVERLAY", 1)
end

local function HealthBar_SetSmoothing(self, smoothing)
    self:ResetSmoothedValue()
    if smoothing then
        self.SetBarValue = self.SetSmoothedValue
        self.SetBarMinMaxValues = self.SetMinMaxSmoothedValue
    else
        self.SetBarValue = self.SetValue
        self.SetBarMinMaxValues = self.SetMinMaxValues
    end
end

local function HealthBar_UpdatePixels(self)
    AW.RePoint(self)
    AW.ReSize(self.overshieldGlow)
    AW.ReSize(self.overshieldGlowR)
    AW.RePoint(self.overshieldGlowR)
    AW.ReSize(self.container)
    AW.RePoint(self.container)
    AW.ReBorder(self.container)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthBar_LoadConfig(self, config)
    self.container:SetFrameLevel(self.root:GetFrameLevel() + config.frameLevel)
    AW.LoadWidgetPosition(self.container, config.position)
    AW.SetSize(self.container, config.width, config.height)

    self:SetTexture(config.texture)
    self:SetBackgroundColor(config.bgColor)
    self:SetBorderColor(config.borderColor)
    self:SetSmoothing(config.smoothing)

    self:SetShieldColor(config.shield.color)
    self:SetOvershieldGlowColor(config.overshieldGlow.color)

    if config.healPrediction.useCustomColor then
        self:SetHealPredictionColor(config.healPrediction.color)
    end

    self.color = config.color
    self.lossColor = config.lossColor
    self.shieldReverseFill = config.shield.reverseFill
    self.shieldEnabled = config.shield.enabled
    self.overshieldGlowEnabled = config.overshieldGlow.enabled
    self.healPredictionEnabled = config.healPrediction.enabled
    self.healPredictionUseCustomColor = config.healPrediction.useCustomColor
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateHealthBar(parent, name)
    -- container
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    AW.SetDefaultBackdrop(container)

    -- bar
    local bar = CreateFrame("StatusBar", name, container)
    AW.SetOnePixelInside(bar, container)

    bar:SetStatusBarTexture(AW.GetTexture("StatusBar")) -- or GetStatusBarTexture() will be nil
    bar.texture = bar:GetStatusBarTexture()

    bar.root = parent
    bar.container = container

    Mixin(bar, SmoothStatusBarMixin)
    bar:SetScript("OnHide", function()
        bar:ResetSmoothedValue()
    end)

    -- events
    BFI.SetEventHandler(bar)

    -- loss texture
    local loss = bar:CreateTexture(name.."Loss", "OVERLAY", nil, 0)
    bar.loss = loss
    loss:SetPoint("TOPLEFT", bar.texture, "TOPRIGHT")
    loss:SetPoint("BOTTOMRIGHT")

    -- shield
    local shield = bar:CreateTexture(name.."Shield", "OVERLAY", nil, 2)
    bar.shield = shield
    shield:Hide()
    shield:SetPoint("TOPLEFT", bar.texture, "TOPRIGHT")
    shield:SetPoint("BOTTOMLEFT", bar.texture, "BOTTOMRIGHT")
    shield:SetTexture(AW.GetTexture("Shield"), "REPEAT", "REPEAT")
    shield:SetHorizTile(true)
    shield:SetVertTile(true)

    -- overshield
    local overshieldGlow = bar:CreateTexture(name.."OvershieldGlow", "OVERLAY", nil, 3)
    bar.overshieldGlow = overshieldGlow
    overshieldGlow:Hide()
    overshieldGlow:SetTexture(AW.GetTexture("Overshield"))
    AW.SetPoint(overshieldGlow, "TOPRIGHT")
    AW.SetPoint(overshieldGlow, "BOTTOMRIGHT")
    AW.SetWidth(overshieldGlow, 4)

    -- overshieldR
    local overshieldGlowR = bar:CreateTexture(name.."OvershieldGlowR", "OVERLAY", nil, 3)
    bar.overshieldGlowR = overshieldGlowR
    overshieldGlowR:Hide()
    overshieldGlowR:SetTexture(AW.GetTexture("Overshield2"))
    AW.SetPoint(overshieldGlowR, "TOPLEFT", shield, "TOPLEFT", -4, 0)
    AW.SetPoint(overshieldGlowR, "BOTTOMLEFT", shield, "BOTTOMLEFT", -4, 0)
    AW.SetWidth(overshieldGlowR, 8)

    -- healPrediction
    local healPrediction = bar:CreateTexture(name.."HealPrediction", "OVERLAY", nil, 1)
    bar.healPrediction = healPrediction
    healPrediction:Hide()
    healPrediction:SetPoint("TOPLEFT", bar.texture, "TOPRIGHT")
    healPrediction:SetPoint("BOTTOMLEFT", bar.texture, "BOTTOMRIGHT")

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.SetColor = HealthBar_SetColor
    bar.SetTexture = HealthBar_SetTexture
    bar.SetLossColor = HealthBar_SetLossColor
    bar.SetBorderColor = HealthBar_SetBorderColor
    bar.SetBackgroundColor = HealthBar_SetBackgroudColor
    bar.SetShieldColor = ShieldBar_SetColor
    bar.SetOvershieldGlowColor = OvershieldGlow_SetColor
    bar.SetHealPredictionColor = HealPrediction_SetColor
    bar.SetSmoothing = HealthBar_SetSmoothing
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar, HealthBar_UpdatePixels)

    return bar
end