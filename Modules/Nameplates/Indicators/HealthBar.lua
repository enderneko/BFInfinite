---@class BFI
local BFI = select(2, ...)
local C = BFI.Colors
local NP = BFI.NamePlates
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitThreatSituation = UnitThreatSituation
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsUnit = UnitIsUnit
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
local UnitClassBase = AF.UnitClassBase
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsTapDenied = UnitIsTapDenied
local IsInInstance = AF.IsInInstance

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function GetHealthColor(self, unit)
    local r, g, b, lossR, lossG, lossB

    local marker = GetRaidTargetIndex(unit)

    if marker and marker <= 8 and self.colorByMarker then
        r, g, b = AF.GetColorRGB("marker_" .. marker)

    elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
        r, g, b = AF.GetColorRGB("TAP_DENIED")

    elseif self.threatSituation and self.colorByThreat then
        r, g, b = AF.GetColorRGB("threat_" .. self.threatSituation)

    elseif AF.UnitIsPlayer(unit) then
        local class = UnitClassBase(unit)
        if not UnitIsConnected(unit) then
            r, g, b = AF.GetColorRGB("OFFLINE")
            lossR, lossG, lossB = AF.GetColorRGB("OFFLINE")
        else
            -- bar
            if self.colorByClass then
                r, g, b = AF.GetClassColor(class)
            else
                r, g, b = AF.GetReactionColor(unit)
            end
        end

    else
        r, g, b = AF.GetReactionColor(unit)
    end

    if not lossR then
        if self.lossColor.useDarkerForground then
            lossR, lossG, lossB = r * 0.2, g * 0.2, b * 0.2
        else
            lossR, lossG, lossB = AF.UnpackColor(self.lossColor.rgb)
        end
    end

    return r, g, b, lossR, lossG, lossB
end

local function UpdateHealthColor(self)
    local unit = self.root.unit
    if not unit then return end

    -- healthBar
    local r, g, b, lossR, lossG, lossB = GetHealthColor(self, unit)
    self:SetColor(r, g, b, self.colorAlpha)
    self:SetLossColor(lossR, lossG, lossB, self.lossColor.alpha)
end

---------------------------------------------------------------------
-- threat
---------------------------------------------------------------------
local threatSituations = {
    [0] = "low",
    [1] = "medium",
    [2] = "medium",
    [3] = "high",
}

local function IsTank(unit)
    return UnitGroupRolesAssigned(unit) == "TANK"
end

local OFFTANK_PETS = {
    ["61056"] = true, -- 原始土元素
    ["95072"] = true, -- 巨型土元素
    ["61146"] = true, -- 玄牛雕像
    ["103822"] = true, -- 树人
}

local creatureCache = {}
local function WipeCache()
    wipe(creatureCache)
end

-- from ThreatPlates
local function IsOffTankCreature(unit)
    local guid = UnitGUID(unit)
    if not guid then return end

    local isOffTank = creatureCache[guid]
    if isOffTank == nil then
      local unitType, _,  _, _, _, npcId = strsplit("-", guid)
      isOffTank = OFFTANK_PETS[npcId] and "Creature" == unitType
      creatureCache[guid] = isOffTank
    end

    return isOffTank
end

local function IsOffTank(unit)
    return UnitExists(unit) and (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) and
        ((IsTank(unit) and not UnitIsUnit("player", unit)) or (UnitIsUnit(unit, "pet") or UnitIsOtherPlayersPet(unit)) or IsOffTankCreature(unit))
end

local function UpdateThreat(self, event, unitId)
    local unit = self.root.unit
    if unitId and unitId ~= unit then return end

    if AF.UnitIsPlayer(unit) then
        self.threatSituation = nil
        self.threat:Hide()
        return
    end

    local status = UnitThreatSituation("player", unit)

    if not status then
        if IsInInstance() and UnitAffectingCombat(unit) then
            local target = unit .. "target"
            if UnitExists(target) then
                if UnitIsUnit(target, "player") or UnitIsUnit(target, "vehicle") then
                    status = 3
                elseif UnitPlayerOrPetInRaid(target) or UnitPlayerOrPetInParty(target) then
                    status = 0
                end
            end
        end
    end

    if status then
        status = threatSituations[status]

        -- check if is offtanked
        if IsInInstance() and status == "low" and IsTank("player") then
            if IsOffTank(unit .. "target") then
                status = "offtank"
            end
        end

        if self.threatGlowEnabled then
            self.threat:SetBackdropBorderColor(AF.GetColorRGB("threat_" .. status))
            self.threat:Show()
        else
            self.threat:Hide()
        end
    else
        self.threat:Hide()
    end

    if self.colorByThreat then
        self.threatSituation = status
        UpdateHealthColor(self)
    else
        self.threatSituation = nil
    end
end


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

    if self.thresholdEnabled then
        self.threshold:Hide()
        for _, t in next, self.thresholdValues do
            if self.healthPercent <= t.value then
                matched = true
                self.threshold:Show()
                self.threshold:SetPoint("CENTER", self.bg, "LEFT", self:GetBarWidth() * t.value, 0)
                self.threshold:SetVertexColor(AF.UnpackColor(t.color))
                break
            end
        end
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
    UpdateThreat(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function HealthBar_Enable(self)
    self:RegisterUnitEvent("UNIT_HEALTH", self.root.unit, UpdateHealth, UpdateShield)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self.root.unit, UpdateHealthMax, UpdateHealth, UpdateShield)
    self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.root.unit, UpdateShield)
    self:RegisterUnitEvent("UNIT_FACTION", self.root.unit, UpdateHealthColor)
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.root.unit, UpdateHealthColor)

    if self.colorByMarker then
        self:RegisterEvent("RAID_TARGET_UPDATE", UpdateHealthColor)
    else
        self:UnregisterEvent("RAID_TARGET_UPDATE")
    end

    if self.threatGlowEnabled or self.colorByThreat then
        -- self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", UpdateThreat)
        self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", self.root.unit, UpdateThreat)
        AF.RegisterCallback("AF_INSTANCE_CHANGE", WipeCache)
    else
        self.threatSituation = nil
        -- self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")
        self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE")
        AF.UnregisterCallback("AF_INSTANCE_CHANGE", WipeCache)
    end

    self:Show()
    self:Update()
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
    self.threatSituation = nil
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
    self.mouseoverHighlight:SetColorTexture(AF.UnpackColor(config.color))
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

local function Thresholds_Setup(self, config)
    if not config.enabled then
        self.threshold:Hide()
        return
    end
    AF.SetSize(self.threshold, config.width, config.height)
end

local function ThreatGlow_Setup(self, config)
    if not config.enabled then
        self.threat:Hide()
        return
    end
    AF.SetOutside(self.threat, self, config.size)
    self.threat:SetBackdrop({edgeFile=AF.GetTexture("StaticGlow"), edgeSize=AF.ConvertPixelsForRegion(config.size, self)})
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
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    HealthBar_SetTexture(self, AF.LSM_GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))

    ShieldBar_SetColor(self, config.shield.color)
    OvershieldGlow_SetColor(self, config.overshieldGlow.color)
    MouseoverHighlight_Setup(self, config.mouseoverHighlight)
    Thresholds_Setup(self, config.thresholds)
    ThreatGlow_Setup(self, config.threatGlow)

    self.shieldReverseFill = config.shield.reverseFill
    self.shieldEnabled = config.shield.enabled
    self.colorByClass = config.colorByClass
    self.colorByThreat = config.colorByThreat
    self.colorByMarker = config.colorByMarker
    self.colorAlpha = config.colorAlpha
    self.lossColor = config.lossColor
    self.thresholdEnabled = config.thresholds.enabled
    self.thresholdValues = config.thresholds.values
    self.threatAlpha = config.threatGlow.alpha
    self.threatGlowEnabled = config.threatGlow.enabled
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateHealthBar(parent, name)
    -- bar
    local bar = AF.CreateSimpleStatusBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    AF.AddEventHandler(bar)

    -- shield
    local shield = bar:CreateTexture(name.."Stripe", "ARTWORK", nil, 2)
    bar.shield = shield
    shield:Hide()
    shield:SetPoint("TOPLEFT", bar.fg.mask, "TOPRIGHT")
    shield:SetPoint("BOTTOMLEFT", bar.fg.mask, "BOTTOMRIGHT")
    shield:SetTexture(AF.GetTexture("Stripe"), "REPEAT", "REPEAT")
    shield:SetHorizTile(true)
    shield:SetVertTile(true)

    -- overshield
    local overshieldGlow = bar:CreateTexture(name.."OvershieldGlow", "ARTWORK", nil, 3)
    bar.overshieldGlow = overshieldGlow
    overshieldGlow:Hide()
    overshieldGlow:SetTexture(AF.GetTexture("Overshield", BFI.name))
    AF.SetPoint(overshieldGlow, "TOPRIGHT", bar.loss.mask)
    AF.SetPoint(overshieldGlow, "BOTTOMRIGHT", bar.loss.mask)
    AF.SetWidth(overshieldGlow, 4)

    -- overshieldR
    local overshieldGlowR = bar:CreateTexture(name.."OvershieldGlowR", "ARTWORK", nil, 3)
    bar.overshieldGlowR = overshieldGlowR
    overshieldGlowR:Hide()
    overshieldGlowR:SetTexture(AF.GetTexture("OvershieldR", BFI.name))
    AF.SetPoint(overshieldGlowR, "TOPLEFT", shield, "TOPLEFT", -4, 0)
    AF.SetPoint(overshieldGlowR, "BOTTOMLEFT", shield, "BOTTOMLEFT", -4, 0)
    AF.SetWidth(overshieldGlowR, 8)

    local fullOvershieldGlowR = bar:CreateTexture(name.."FullOvershieldGlowR", "ARTWORK", nil, 3)
    bar.fullOvershieldGlowR = fullOvershieldGlowR
    fullOvershieldGlowR:Hide()
    fullOvershieldGlowR:SetTexture(AF.GetTexture("Overabsorb", BFI.name))
    AF.SetPoint(fullOvershieldGlowR, "TOPLEFT", bar.fg.mask)
    AF.SetPoint(fullOvershieldGlowR, "BOTTOMLEFT", bar.fg.mask)
    AF.SetWidth(fullOvershieldGlowR, 4)

    -- mouseover highlight
    local mouseoverHighlight = bar:CreateTexture(name.."MouseoverHighlight", "ARTWORK", nil, 5)
    bar.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:SetAllPoints(bar.bg)
    mouseoverHighlight:Hide()

    -- threshold
    local threshold = bar:CreateTexture(name.."Threshold", "ARTWORK", nil, 7)
    bar.threshold = threshold
    threshold:Hide()
    threshold:SetTexture(AF.GetTexture("Spark", BFI.name))

    -- threatGlow
    local threat = CreateFrame("Frame", name.."ThreatGlow", bar, "BackdropTemplate")
    bar.threat = threat

    -- functions
    bar.Update = HealthBar_Update
    bar.Enable = HealthBar_Enable
    bar.Disable = HealthBar_Disable
    bar.LoadConfig = HealthBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(bar, HealthBar_UpdatePixels)

    return bar
end