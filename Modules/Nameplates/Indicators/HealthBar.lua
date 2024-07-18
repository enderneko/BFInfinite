---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local C = BFI.M_C
local NP = BFI.M_NP

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

---------------------------------------------------------------------
-- health
---------------------------------------------------------------------
local function UpdateHealthStates(self)
    local unit = self.root.unit

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
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    UpdateHealthStates(self)
    self:SetBarMinMaxValues(0, self.healthMax)
end

local function UpdateHealth(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    UpdateHealthStates(self)
    self:SetBarValue(self.health)
end

---------------------------------------------------------------------
-- shield
---------------------------------------------------------------------
local function UpdateShield(self, event, unitId)
    local unit = self.root.unit
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
-- color
---------------------------------------------------------------------
local function GetHealthColor(self, unit)
    local class = U.UnitClassBase(unit)

    local r, g, b, lossR, lossG, lossB

    -- TODO: OverrideColor, threat color
    local marker = GetRaidTargetIndex(unit)

    if marker and self.colorByMarker then
        r, g, b = AW.GetColorRGB("marker_" .. marker)

    elseif U.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r, g, b = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        else
            -- bar
            if self.colorByClass then
                r, g, b = AW.GetClassColor(class)
            else
                r, g, b = AW.GetReactionColor(unit)
            end
        end

    else
        r, g, b = AW.GetReactionColor(unit)
    end

    if not lossR then
        lossR, lossG, lossB = r * 0.2, g * 0.2, b * 0.2
    end

    return r, g, b, lossR, lossG, lossB
end

local function UpdateHealthColor(self)
    local unit = self.root.unit
    if not unit then return end

    -- healthBar
    local r, g, b, lossR, lossG, lossB = GetHealthColor(self, unit)
    self:SetColor(r, g, b)
    self:SetLossColor(lossR, lossG, lossB)
end

---------------------------------------------------------------------
-- mouseover
---------------------------------------------------------------------
local function UpdateMouseover(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.1 then
        self.elapsed = 0
        local unit = self.root.unit
        if unit and UnitExists("mouseover") and UnitIsUnit("mouseover", unit) then
            self.mouseoverHighlight:Show()
        else
            self.mouseoverHighlight:Hide()
        end
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function HealthBar_Update(self)
    UpdateHealthColor(self)
    UpdateHealthMax(self)
    UpdateHealth(self)
    UpdateShield(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:RegisterEvent("UNIT_HEALTH", UpdateHealth, UpdateShield)
    self:RegisterEvent("UNIT_MAXHEALTH", UpdateHealthMax, UpdateHealth, UpdateShield)
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", UpdateShield)
    if self.colorByMarker then
        self:RegisterEvent("RAID_TARGET_UPDATE", UpdateHealthColor)
    else
        self:UnregisterEvent("RAID_TARGET_UPDATE")
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

local function MouseoverHighlight_Setup(self, config)
    self.mouseoverHighlight:SetColorTexture(AW.UnpackColor(config.color))
    if config.enabled then
        self:SetScript("OnUpdate", UpdateMouseover)
    else
        self:SetScript("OnUpdate", nil)
        self.mouseoverHighlight:Hide()
    end
end

local function HealthBar_SetTexture(self, texture)
    self.fg:SetTexture(texture)
    self.loss:SetTexture(texture)
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
    NP.LoadIndicatorPosition(self, config)
    AW.SetSize(self, config.width, config.height)

    HealthBar_SetTexture(self, U.GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))

    ShieldBar_SetColor(self, config.shield.color)
    OvershieldGlow_SetColor(self, config.overshieldGlow.color)
    MouseoverHighlight_Setup(self, config.mouseoverHighlight)

    self.shieldReverseFill = config.shield.reverseFill
    self.shieldEnabled = config.shield.enabled
    self.colorByClass = config.colorByClass
    self.colorByThreat = config.colorByThreat
    self.colorByMarker = config.colorByMarker
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateHealthBar(parent, name)
    -- bar
    local bar = AW.CreateSimpleBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    BFI.AddEventHandler(bar)

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

    -- mouseover highlight
    local mouseoverHighlight = bar:CreateTexture(name.."MouseoverHighlight", "ARTWORK", nil, 7)
    -- local mouseoverHighlight = AW.CreateGradientTexture(bar, "VERTICAL", nil, {1, 1, 1, 0.1}, nil, "ARTWORK", 7)
    bar.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetAllPoints(bar.bg)
    mouseoverHighlight:Hide()

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.Disable = HealthBar_Disable
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar, HealthBar_UpdatePixels)

    return bar
end