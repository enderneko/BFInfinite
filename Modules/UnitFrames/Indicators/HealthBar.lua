---@class BFI
local BFI = select(2, ...)
local UF = BFI.modules.UnitFrames
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
            self.shield:SetPoint("TOPLEFT", self.fg.mask, "TOPRIGHT")
            self.shield:SetPoint("BOTTOMLEFT", self.fg.mask, "BOTTOMRIGHT")
        end

        if overs then -- overshield
            if self.shieldReverseFill then -- reverse
                local p = self.shieldPercent
                if p > 1 then p = 1 end
                self.shield:SetWidth(p * barWidth)
                self.shield:Show()

                if self.overshieldGlowEnabled then
                    if p == 1 then
                        self.overshieldGlowR:Hide()
                        self.fullOvershieldGlowR:Show()
                    else
                        self.overshieldGlowR:Show()
                        self.fullOvershieldGlowR:Hide()
                    end
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
                self.fullOvershieldGlowR:Hide()
            end
        else
            self.shield:SetWidth(self.shieldPercent * barWidth)
            self.shield:Show()
            self.overshieldGlow:Hide()
            self.overshieldGlowR:Hide()
            self.fullOvershieldGlowR:Hide()
        end
    else
        self.shield:Hide()
        self.overshieldGlow:Hide()
        self.overshieldGlowR:Hide()
        self.fullOvershieldGlowR:Hide()
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
        else
            self.overabsorbGlow:Hide()
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

local function GetHealthColor(self, unit, colorTable)
    local class = UnitClassBase(unit) or "UNKNOWN"
    local inVehicle = UnitHasVehicleUI(unit)

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2

    if AF.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r1, g1, b1 = AF.GetColorRGB("OFFLINE")
        elseif UnitIsCharmed(unit) then
            r1, g1, b1 = AF.GetColorRGB("CHARMED")
        else
            if colorTable.type == "custom_color" then
                if colorTable.gradient == "disabled" then
                    r1, g1, b1 = AF.UnpackColor(colorTable.rgb)
                else
                    r1, g1, b1 = AF.UnpackColor(colorTable.rgb[1])
                end
            else -- class_color, class_color_dark
                r1, g1, b1 = GetClassColor(colorTable.type, class, inVehicle)
            end
        end
    else
        if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
            r1, g1, b1 = AF.GetColorRGB("TAP_DENIED")
        elseif colorTable.type == "custom_color" then
            if colorTable.gradient == "disabled" then
                r1, g1, b1 = AF.UnpackColor(colorTable.rgb)
            else
                r1, g1, b1 = AF.UnpackColor(colorTable.rgb[1])
            end
        else -- class_color, class_color_dark
            r1, g1, b1 = GetReactionColor(colorTable.type, unit)
        end
    end

    if colorTable.gradient == "disabled" then
        a1 = colorTable.alpha
        return nil, r1, g1, b1, a1
    else
        a1, a2 = colorTable.alpha[1], colorTable.alpha[2]
        if #colorTable.rgb == 4 then
            r2, g2, b2 = AF.UnpackColor(colorTable.rgb)
        else
            r2, g2, b2 = AF.UnpackColor(colorTable.rgb[2])
        end

        orientation = colorTable.gradient:find("^vertical") and "VERTICAL" or "HORIZONTAL"
        if colorTable.gradient:find("flipped$") then
            return orientation, r2, g2, b2, a2, r1, g1, b1, a1
        else
            return orientation, r1, g1, b1, a1, r2, g2, b2, a2
        end
    end
end

local function UpdateHealthColor(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    -- color
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor(self, unit, self.color)
    if orientation then
        self:SetGradientColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetColor(r1, g1, b1, a1)
    end

    -- lossColor
    orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetHealthColor(self, unit, self.lossColor)
    if orientation then
        self:SetGradientLossColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetLossColor(r1, g1, b1, a1)
    end

    -- healPrediction
    if not self.healPredictionUseCustomColor then
        self.healPrediction:SetVertexColor(r1, g1, b1, 0.4)
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
        local auraType = AF.GetDebuffType(auraData)
        if auraType then
            self.dispelTypes[auraType] = true
        end
    end
end

local dispel_order = {"Magic", "Curse", "Disease", "Poison", "Bleed"}

local function UpdateDispelHighlight(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end
    if UnitCanAttack("player", unit) then return end

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

    for _, type in next, dispel_order do
        if self.dispelTypes[type] then
            if not self.dispelHighlightOnlyDispellable or AF.CanDispel(type) then
                self.dispelHighlight:SetVertexColor(AF.GetAuraTypeColor(type, self.dispelHighlightAlpha))
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
    UpdateHealAbsorb(self)
    UpdateHealPrediction(self)
    UpdateDispelHighlight(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth, UpdateShield, UpdateHealAbsorb, UpdateHealPrediction)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealthMax, UpdateHealth, UpdateShield, UpdateHealAbsorb, UpdateHealPrediction)
    self:RegisterEvent("UNIT_FACTION", UpdateHealthColor)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateShield)
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateHealAbsorb)
    self:RegisterEvent("UNIT_HEAL_PREDICTION", UpdateHealPrediction)

    if self.dispelHighlightEnabled then
        self:RegisterEvent("UNIT_AURA", UpdateDispelHighlight)
    else
        self:UnregisterEvent("UNIT_AURA")
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
local function ShieldBar_SetTexture(self, texture)
    if texture == "default" then
        texture = AF.GetTexture("Stripe")
    else
        texture = AF.LSM_GetBarTexture(texture)
    end
    self.shield:SetTexture(texture, "REPEAT", "REPEAT")
end

local function ShieldBar_SetColor(self, color)
    self.shield:SetVertexColor(AF.UnpackColor(color))
end

local function OvershieldGlow_SetColor(self, color)
    self.overshieldGlow:SetVertexColor(AF.UnpackColor(color))
    self.overshieldGlowR:SetVertexColor(AF.UnpackColor(color))
end

local function HealAbsorbBar_SetTexture(self, texture)
    if texture == "default" then
        texture = AF.GetTexture("Stripe")
    else
        texture = AF.LSM_GetBarTexture(texture)
    end
    self.healAbsorb:SetTexture(texture, "REPEAT", "REPEAT")
end

local function HealAbsorbBar_SetColor(self, color)
    self.healAbsorb:SetVertexColor(AF.UnpackColor(color))
end

local function OverabsorbGlow_SetColor(self, color)
    self.overabsorbGlow:SetVertexColor(AF.UnpackColor(color))
end

local function HealPrediction_SetColor(self, color)
    self.healPrediction:SetVertexColor(AF.UnpackColor(color))
end

local function DispelHighlight_Setup(self, config)
    self.dispelHighlight:SetBlendMode(config.blendMode)
end

local function MouseoverHighlight_SetColor(self, color)
    self.mouseoverHighlight:SetColorTexture(AF.UnpackColor(color))
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
    self:SetTexture(texture)
    self.healPrediction:SetTexture(texture)
    self.dispelHighlight:SetTexture(texture)
end

local function HealthBar_UpdatePixels(self)
    self:DefaultUpdatePixels()
    AF.ReSize(self.overshieldGlow)
    AF.ReSize(self.overshieldGlowR)
    AF.RePoint(self.overshieldGlowR)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function HealthBar_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    HealthBar_SetTexture(self, AF.LSM_GetBarTexture(config.texture))
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))
    self:SetSmoothing(config.smoothing)

    ShieldBar_SetTexture(self, config.shield.texture)
    ShieldBar_SetColor(self, config.shield.color)
    OvershieldGlow_SetColor(self, config.overshieldGlow.color)

    HealAbsorbBar_SetTexture(self, config.healAbsorb.texture)
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
    self.dispelHighlightAlpha = config.dispelHighlight.alpha
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
        C_Timer.After(0.01, function()
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
    local bar = AF.CreateSimpleStatusBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    AF.AddEventHandler(bar)

    -- healPrediction
    local healPrediction = bar:CreateTexture(name .. "HealPrediction", "ARTWORK", nil, 1)
    bar.healPrediction = healPrediction
    healPrediction:Hide()
    healPrediction:SetPoint("TOPLEFT", bar.fg.mask, "TOPRIGHT")
    healPrediction:SetPoint("BOTTOMLEFT", bar.fg.mask, "BOTTOMRIGHT")

    -- shield
    local shield = bar:CreateTexture(name .. "Shield", "ARTWORK", nil, 2)
    bar.shield = shield
    shield:Hide()
    shield:SetPoint("TOPLEFT", bar.fg.mask, "TOPRIGHT")
    shield:SetPoint("BOTTOMLEFT", bar.fg.mask, "BOTTOMRIGHT")
    shield:SetHorizTile(true)
    shield:SetVertTile(true)

    -- overshield
    local overshieldGlow = bar:CreateTexture(name .. "OvershieldGlow", "ARTWORK", nil, 3)
    bar.overshieldGlow = overshieldGlow
    overshieldGlow:Hide()
    overshieldGlow:SetTexture(AF.GetTexture("Overshield", BFI.name))
    AF.SetPoint(overshieldGlow, "TOPRIGHT", bar.loss.mask)
    AF.SetPoint(overshieldGlow, "BOTTOMRIGHT", bar.loss.mask)
    AF.SetWidth(overshieldGlow, 4)

    -- overshieldR
    local overshieldGlowR = bar:CreateTexture(name .. "OvershieldGlowR", "ARTWORK", nil, 3)
    bar.overshieldGlowR = overshieldGlowR
    overshieldGlowR:Hide()
    overshieldGlowR:SetTexture(AF.GetTexture("OvershieldR", BFI.name))
    AF.SetPoint(overshieldGlowR, "TOP", shield, "TOPLEFT")
    AF.SetPoint(overshieldGlowR, "BOTTOM", shield, "BOTTOMLEFT")
    AF.SetWidth(overshieldGlowR, 6)

    local fullOvershieldGlowR = bar:CreateTexture(name .. "FullOvershieldGlowR", "ARTWORK", nil, 3)
    bar.fullOvershieldGlowR = fullOvershieldGlowR
    fullOvershieldGlowR:Hide()
    fullOvershieldGlowR:SetTexture(AF.GetTexture("Overabsorb", BFI.name))
    AF.SetPoint(fullOvershieldGlowR, "TOPLEFT", bar.fg.mask)
    AF.SetPoint(fullOvershieldGlowR, "BOTTOMLEFT", bar.fg.mask)
    AF.SetWidth(fullOvershieldGlowR, 4)

    -- healAbsorb
    local healAbsorb = bar:CreateTexture(name .. "HealAbsorb", "ARTWORK", nil, 4)
    bar.healAbsorb = healAbsorb
    healAbsorb:Hide()
    healAbsorb:SetPoint("TOPRIGHT", bar.fg.mask)
    healAbsorb:SetPoint("BOTTOMRIGHT", bar.fg.mask)
    healAbsorb:SetHorizTile(true)
    healAbsorb:SetVertTile(true)

    -- overabsorb
    local overabsorbGlow = bar:CreateTexture(name .. "OverabsorbGlow", "ARTWORK", nil, 5)
    bar.overabsorbGlow = overabsorbGlow
    overabsorbGlow:Hide()
    overabsorbGlow:SetTexture(AF.GetTexture("Overabsorb", BFI.name))
    AF.SetPoint(overabsorbGlow, "TOPLEFT", bar.fg.mask)
    AF.SetPoint(overabsorbGlow, "BOTTOMLEFT", bar.fg.mask)
    AF.SetWidth(overabsorbGlow, 4)

    -- mouseover highlight
    local mouseoverHighlight = bar:CreateTexture(name .. "MouseoverHighlight", "ARTWORK", nil, 7)
    -- local mouseoverHighlight = AF.CreateGradientTexture(bar, "VERTICAL", nil, {1, 1, 1, 0.1}, nil, "ARTWORK", 7)
    bar.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetAllPoints(bar.bg)
    mouseoverHighlight:Hide()

    parent:HookScript("OnEnter", MouseoverHighlight_OnEnter)
    parent:HookScript("OnLeave", MouseoverHighlight_OnLeave)

    -- dispel highlight
    local dispelHighlight = bar:CreateTexture(name .. "DispelHighlight", "ARTWORK", nil, 1)
    bar.dispelHighlight = dispelHighlight
    dispelHighlight:SetAllPoints(bar.fg.mask)
    dispelHighlight:Hide()

    bar.dispelTypes = {}

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.Disable = HealthBar_Disable
    bar.EnableConfigMode = HealthBar_EnableConfigMode
    bar.DisableConfigMode = HealthBar_DisableConfigMode
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(bar, HealthBar_UpdatePixels)

    return bar
end