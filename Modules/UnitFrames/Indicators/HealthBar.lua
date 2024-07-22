local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local C = BFI.M_Color
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitIsCharmed = UnitIsCharmed
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitClassBase = UnitClassBase
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = C_UnitAuras.GetAuraSlots

---------------------------------------------------------------------
-- health
---------------------------------------------------------------------
local function UpdateHealthStates(self)
    local unit = self.root.displayedUnit

    self.health = UnitHealth(unit)
    self.healthMax = UnitHealthMax(unit)

    if self.healthMax == 0 then
        self.healthPercent = 0
        self.healthMax = 1
    else
        self.healthPercent = self.health / self.healthMax
    end
end

local function UpdateHealthMax(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    UpdateHealthStates(self)
    self:SetBarMinMaxValues(0, self.healthMax)
end

local function UpdateHealth(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    UpdateHealthStates(self)
    self:SetBarValue(self.health)
end

---------------------------------------------------------------------
-- shield
---------------------------------------------------------------------
local function UpdateShield(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    -- overshieldGlow
    if not self.shieldEnabled or not self.overshieldGlowEnabled then
        self.overshieldGlow:Hide()
        self.overshieldGlowR:Hide()
    end

    if not self.shieldEnabled then
        self.shield:Hide()
        return
    end

    self.shields = UnitGetTotalAbsorbs(unit)

    if self.shields > 0 then
        local barWidth = self:GetBarWidth()

        UpdateHealthStates(self)
        self.shieldPercent = self.shields / self.healthMax

        local overs = self.shieldPercent + self.healthPercent > 1

        if self.shieldReverseFill and overs then -- reverse
            self.shield:ClearAllPoints()
            self.shield:SetPoint("TOPRIGHT", self.bg)
            self.shield:SetPoint("BOTTOMRIGHT", self.bg)
        else
            self.shield:ClearAllPoints()
            self.shield:SetPoint("TOPLEFT", self.fg, "TOPRIGHT")
            self.shield:SetPoint("BOTTOMLEFT", self.fg, "BOTTOMRIGHT")
        end

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
-- healAbsorb
---------------------------------------------------------------------
local function UpdateHealAbsorb(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    -- overabsorbGlow
    if not self.healAbsorbEnabled or not self.overabsorbGlowEnabled then
        self.overabsorbGlow:Hide()
    end

    if not self.healAbsorbEnabled then
        self.healAbsorb:Hide()
        return
    end


    self.healAbsorbs = UnitGetTotalHealAbsorbs(unit)

    if self.healAbsorbs > 0 then
        local barWidth = self:GetBarWidth()

        UpdateHealthStates(self)
        self.healAbsorbPercent = self.healAbsorbs / self.healthMax

        local p = min(self.healthPercent, self.healAbsorbPercent)

        self.healAbsorb:SetWidth(p * barWidth)
        self.healAbsorb:Show()

        if self.overabsorbGlowEnabled and self.healAbsorbPercent > self.healthPercent then
            self.overabsorbGlow:Show()
        end
    else
        self.healAbsorb:Hide()
        self.overabsorbGlow:Hide()
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

local function UpdateHealthColor(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    -- healthBar
    local r, g, b, a, lossR, lossG, lossB, lossA = GetHealthColor(self, unit)
    self:SetColor(r, g, b, a)
    self:SetLossColor(lossR, lossG, lossB, lossA)

    -- healPrediction
    if not self.healPredictionUseCustomColor then
        self.healPrediction:SetVertexColor(r, g, b, 0.4)
    end
end

---------------------------------------------------------------------
-- heal prediction
---------------------------------------------------------------------
local function UpdateHealPrediction(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

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
        self.healPrediction:SetWidth(p * self:GetBarWidth())
        self.healPrediction:Show()
    else
        self.healPrediction:Hide()
    end
end

---------------------------------------------------------------------
-- dispel highlight
---------------------------------------------------------------------
local function ForEachAura(self, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select("#", ...)
    for i = 1, n do
        local slot = select(i, ...)
        local auraData = GetAuraDataBySlot(self.root.displayedUnit, slot)
        local auraType = auraData.dispelName -- TODO: bleeds
        if auraType and auraType ~= "" then
            self.dispelTypes[auraType] = true
        end
    end
end

local dispel_order = {"Magic", "Curse", "Disease", "Poison"}

local function UpdateDispelHighlight(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    if not self.dispelHighlightEnabled then
        self.dispelHighlight:Hide()
        return
    end

    -- reset
    wipe(self.dispelTypes)

    -- iterate
    ForEachAura(self, GetAuraSlots(self.root.displayedUnit, "HARMFUL"))

    -- show
    local found

    for _, type in pairs(dispel_order) do
        if self.dispelTypes[type] then
            if not self.dispelHighlightOnlyDispellable or U.CanDispel(type) then
                self.dispelHighlight:SetVertexColor(C.GetAuraTypeColor(type))
                found = true
                break
            end
        end
    end

    self.dispelHighlight:SetShown(found)
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
    UpdateDispelHighlight(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth, UpdateShield, UpdateHealPrediction)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealthMax, UpdateHealth, UpdateShield, UpdateHealPrediction)
    -- self:RegisterEvent("UNIT_NAME_UPDATE", UpdateHealthColor)
    -- self:RegisterEvent("UNIT_FACTION", UpdateHealthColor)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateShield)
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateHealAbsorb)
    self:RegisterEvent("UNIT_HEAL_PREDICTION", UpdateHealPrediction)

    if self.dispelHighlightEnabled then
        self:RegisterEvent("UNIT_AURA", UpdateDispelHighlight)
    else
        self:UnregisterEvent("UNIT_AURA")
    end

    self:Show()
    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function HealthBar_Disable(self)
    self:UnregisterAllEvents()
    self:Hide()
    self.health = nil
    self.healthMax = nil
    self.healthPercent = nil
    self.shields = nil
    self.shieldPercent = nil
    self.healAbsorbs = nil
    self.healAbsorbPercent = nil
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function ShieldBar_SetColor(self, color)
    self.shield:SetVertexColor(unpack(color))
end

local function OvershieldGlow_SetColor(self, color)
    self.overshieldGlow:SetVertexColor(unpack(color))
    self.overshieldGlowR:SetVertexColor(unpack(color))
end

local function HealAbsorbBar_SetColor(self, color)
    self.healAbsorb:SetVertexColor(unpack(color))
end

local function OverabsorbGlow_SetColor(self, color)
    self.overabsorbGlow:SetVertexColor(unpack(color))
end

local function HealPrediction_SetColor(self, color)
    self.healPrediction:SetVertexColor(unpack(color))
end

local function DispelHighlight_Setup(self, config)
    self.dispelHighlight:SetBlendMode(config.blendMode)
    self.dispelHighlight:SetAlpha(config.alpha)
end

local function MouseoverHighlight_SetColor(self, color)
    self.mouseoverHighlight:SetColorTexture(AW.UnpackColor(color))
end

local function MouseoverHighlight_OnEnter(self)
    if self.indicators.healthBar.mouseoverHighlightEnabled then
        self.indicators.healthBar.mouseoverHighlight:Show()
    end
end

local function MouseoverHighlight_OnLeave(self)
    self.indicators.healthBar.mouseoverHighlight:Hide()
end

local function HealthBar_SetTexture(self, texture)
    self.fg:SetTexture(texture)
    self.loss:SetTexture(texture)
    self.healPrediction:SetTexture(texture)
    self.dispelHighlight:SetTexture(texture)
end

local function HealthBar_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.ReSize(self.fg)
    AW.RePoint(self.fg)
    AW.RePoint(self.loss)
    AW.ReSize(self.overshieldGlow)
    AW.ReSize(self.overshieldGlowR)
    AW.RePoint(self.overshieldGlowR)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthBar_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)

    HealthBar_SetTexture(self, U.GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))
    self:SetSmoothing(config.smoothing)

    ShieldBar_SetColor(self, config.shield.color)
    OvershieldGlow_SetColor(self, config.overshieldGlow.color)

    HealAbsorbBar_SetColor(self, config.healAbsorb.color)
    OverabsorbGlow_SetColor(self, config.overabsorbGlow.color)

    MouseoverHighlight_SetColor(self, config.mouseoverHighlight.color)

    if config.healPrediction.useCustomColor then
        HealPrediction_SetColor(self, config.healPrediction.color)
    end

    DispelHighlight_Setup(self, config.dispelHighlight)

    self.color = config.color
    self.lossColor = config.lossColor
    self.shieldReverseFill = config.shield.reverseFill
    self.shieldEnabled = config.shield.enabled
    self.overshieldGlowEnabled = config.overshieldGlow.enabled
    self.healAbsorbEnabled = config.healAbsorb.enabled
    self.overabsorbGlowEnabled = config.overabsorbGlow.enabled
    self.healPredictionEnabled = config.healPrediction.enabled
    self.healPredictionUseCustomColor = config.healPrediction.useCustomColor
    self.mouseoverHighlightEnabled = config.mouseoverHighlight.enabled
    self.dispelHighlightEnabled = config.dispelHighlight.enabled
    self.dispelHighlightOnlyDispellable = config.dispelHighlight.dispellable
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
-- TODO: gradient texture & mask
function UF.CreateHealthBar(parent, name)
    -- bar
    local bar = AW.CreateSimpleBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    BFI.AddEventHandler(bar)

    -- healPrediction
    local healPrediction = bar:CreateTexture(name.."HealPrediction", "ARTWORK", nil, 1)
    bar.healPrediction = healPrediction
    healPrediction:Hide()
    healPrediction:SetPoint("TOPLEFT", bar.fg, "TOPRIGHT")
    healPrediction:SetPoint("BOTTOMLEFT", bar.fg, "BOTTOMRIGHT")

    -- shield
    local shield = bar:CreateTexture(name.."Shield", "ARTWORK", nil, 2)
    bar.shield = shield
    shield:Hide()
    shield:SetPoint("TOPLEFT", bar.fg, "TOPRIGHT")
    shield:SetPoint("BOTTOMLEFT", bar.fg, "BOTTOMRIGHT")
    shield:SetTexture(AW.GetTexture("Shield"), "REPEAT", "REPEAT")
    shield:SetHorizTile(true)
    shield:SetVertTile(true)

    -- overshield
    local overshieldGlow = bar:CreateTexture(name.."OvershieldGlow", "ARTWORK", nil, 3)
    bar.overshieldGlow = overshieldGlow
    overshieldGlow:Hide()
    overshieldGlow:SetTexture(AW.GetTexture("Overshield"))
    AW.SetPoint(overshieldGlow, "TOPRIGHT", bar.loss)
    AW.SetPoint(overshieldGlow, "BOTTOMRIGHT", bar.loss)
    AW.SetWidth(overshieldGlow, 4)

    -- overshieldR
    local overshieldGlowR = bar:CreateTexture(name.."OvershieldGlowR", "ARTWORK", nil, 3)
    bar.overshieldGlowR = overshieldGlowR
    overshieldGlowR:Hide()
    overshieldGlowR:SetTexture(AW.GetTexture("OvershieldR"))
    AW.SetPoint(overshieldGlowR, "TOPLEFT", shield, "TOPLEFT", -4, 0)
    AW.SetPoint(overshieldGlowR, "BOTTOMLEFT", shield, "BOTTOMLEFT", -4, 0)
    AW.SetWidth(overshieldGlowR, 8)

    -- healAbsorb
    local healAbsorb = bar:CreateTexture(name.."HealAbsorb", "ARTWORK", nil, 4)
    bar.healAbsorb = healAbsorb
    healAbsorb:Hide()
    healAbsorb:SetPoint("TOPRIGHT", bar.fg)
    healAbsorb:SetPoint("BOTTOMRIGHT", bar.fg)
    healAbsorb:SetTexture(AW.GetTexture("Shield"), "REPEAT", "REPEAT")
    healAbsorb:SetHorizTile(true)
    healAbsorb:SetVertTile(true)

    -- overabsorb
    local overabsorbGlow = bar:CreateTexture(name.."OverabsorbGlow", "ARTWORK", nil, 5)
    bar.overabsorbGlow = overabsorbGlow
    overabsorbGlow:Hide()
    overabsorbGlow:SetTexture(AW.GetTexture("Overabsorb"))
    AW.SetPoint(overabsorbGlow, "TOPLEFT", bar.fg)
    AW.SetPoint(overabsorbGlow, "BOTTOMLEFT", bar.fg)
    AW.SetWidth(overabsorbGlow, 4)

    -- mouseover highlight
    local mouseoverHighlight = bar:CreateTexture(name.."MouseoverHighlight", "ARTWORK", nil, 7)
    -- local mouseoverHighlight = AW.CreateGradientTexture(bar, "VERTICAL", nil, {1, 1, 1, 0.1}, nil, "ARTWORK", 7)
    bar.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetAllPoints(bar.bg)
    mouseoverHighlight:Hide()

    parent:HookScript("OnEnter", MouseoverHighlight_OnEnter)
    parent:HookScript("OnLeave", MouseoverHighlight_OnLeave)

    -- dispel highlight
    local dispelHighlight = bar:CreateTexture(name.."DispelHighlight", "ARTWORK", nil, 1)
    bar.dispelHighlight = dispelHighlight
    dispelHighlight:SetAllPoints(bar.fg)
    dispelHighlight:Hide()

    bar.dispelTypes = {}

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.Disable = HealthBar_Disable
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar, HealthBar_UpdatePixels)

    return bar
end