---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.UnitFrames

local UnitGUID = UnitGUID
local UnitName = UnitName
local GetUnitName = GetUnitName
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local UnitIsAFK = UnitIsAFK
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
-- local UnitInRange = UnitInRange
-- local UnitIsVisible = UnitIsVisible
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local GetTime = GetTime
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitHasVehicleUI = UnitHasVehicleUI
-- local UnitInVehicle = UnitInVehicle
-- local UnitUsingVehicle = UnitUsingVehicle
local UnitIsCharmed = UnitIsCharmed
local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InCombatLockdown = InCombatLockdown
local UnitPhaseReason = UnitPhaseReason
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local IsInRaid = IsInRaid
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitClassBase = U.UnitClassBase
local IsDelveInProgress = C_PartyInfo.IsDelveInProgress

---------------------------------------------------------------------
-- states
---------------------------------------------------------------------
local function UnitButton_UpdateBaseStates(self)
    local unit = self.unit
    if not unit then return end

    self.states.name = UnitName(unit)
    self.states.fullName = U.UnitFullName(unit)
    self.states.class = UnitClassBase(unit)
    self.states.guid = UnitGUID(unit)
    self.states.isPlayer = UnitIsPlayer(unit)
    self.states.inVehicle = UnitHasVehicleUI(unit)

    if self.states.inVehicle then
        if unit == "player" then
            self.displayedUnit = "vehicle"
        elseif strfind(unit, "%d$") then
            local prefix, id = strmatch(unit, "([^%d]+)([%d]+)")
            self.displayedUnit = prefix.."pet"..id
        else
            self.displayedUnit = unit.."pet"
        end
    else
        self.displayedUnit = self.unit
    end

    if unit == "pet" then
        if UnitHasVehicleUI("player") then
            self.displayedUnit = "player"
        else
            self.displayedUnit = "pet"
        end
    end
end

---------------------------------------------------------------------
-- health states
---------------------------------------------------------------------
local function UnitButton_UpdateHealthStates(self)
    local unit = self.displayedUnit
    if not unit then return end

    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)

    self.states.health = health
    self.states.healthMax = healthMax
    self.states.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if healthMax == 0 then
        self.states.healthPercent = 0
    else
        self.states.healthPercent = health / healthMax
    end

    self.states.wasDead = self.states.isDead
    self.states.isDead = health == 0

    self.states.wasDeadOrGhost = self.states.isDeadOrGhost
    self.states.isDeadOrGhost = UnitIsDeadOrGhost(unit)

    if self.states.wasDead ~= self.states.isDead or self.states.wasDeadOrGhost ~= self.states.isDeadOrGhost then
    end
end

---------------------------------------------------------------------
-- power states
---------------------------------------------------------------------
local function UnitButton_UpdatePowerStates(self)
    local unit = self.displayedUnit
    if not unit then return end

    self.states.power = UnitPower(unit)
    self.states.powerMax = UnitPowerMax(unit)
    self.states.powerType, self.states.powerTypeToken = UnitPowerType(unit)
end

---------------------------------------------------------------------
-- all states
---------------------------------------------------------------------
local function UnitButton_UpdateAllStates(self)
    UnitButton_UpdateBaseStates(self)
    -- UnitButton_UpdateHealthStates(self)
    -- UnitButton_UpdatePowerStates(self)
end

---------------------------------------------------------------------
-- range
---------------------------------------------------------------------
local function UnitButton_UpdateInRange(self, ir)
    local unit = self.displayedUnit
    if not unit then return end

    local inRange = U.IsInRange(unit)

    self.states.inRange = inRange
    if self.states.inRange ~= self.states.wasInRange then
        if inRange then
            AW.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
        else
            AW.FrameFadeOut(self, 0.25, self:GetAlpha(), self.oorAlpha or 1)
        end
    end
    self.states.wasInRange = inRange
end

---------------------------------------------------------------------
-- update all
---------------------------------------------------------------------
--- @param force boolean tell some indicator to perform a force update
local function UnitButton_UpdateAll(self, force)
    if not self:IsVisible() or self.inConfigMode then return end

    -- update indicators
    UF.UpdateIndicators(self, force)

    -- states
    UnitButton_UpdateAllStates(self)

    -- range
    UnitButton_UpdateInRange(self)
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
local function UnitButton_RegisterEvents(self)
    -- health states
    -- self:RegisterEvent("UNIT_HEALTH")
    -- self:RegisterEvent("UNIT_MAXHEALTH")
    -- self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

    -- powers states
    -- self:RegisterEvent("UNIT_POWER_UPDATE")
    -- self:RegisterEvent("UNIT_MAXPOWER")
    -- self:RegisterEvent("UNIT_DISPLAYPOWER")

    self:RegisterEvent("UNIT_CONNECTION")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITED_VEHICLE")
    -- self:RegisterEvent("PARTY_MEMBER_ENABLE")
    -- self:RegisterEvent("PARTY_MEMBER_DISABLE")
    -- self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    if self._updateOnGroupUpdate then
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end

    if self._updateOnPlayerTargetChanged then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    if self._updateOnUnitTargetChanged then
        self:RegisterEvent("UNIT_TARGET")
    end
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.displayedUnit == unit or self.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self._updateRequired = true

        elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealthStates(self)

        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerStates(self)
        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            -- FIXME:
            if IsDelveInProgress() then
                self.__tickCount = 2
                self.__updateElapsed = 0.25
            else
                self._updateRequired = true
            end

        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitExists(self.unit) then
                UnitButton_UpdateAll(self, true)
            end

        elseif event == "UNIT_TARGET" then
            if self._updateOnUnitTargetChanged == unit and not UnitIsUnit("player", unit) then
                if UnitExists(self.unit) then
                    UnitButton_UpdateAll(self, true)
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- onUpdate
---------------------------------------------------------------------
BFI.vars.guids = {} -- guid to unitid
BFI.vars.names = {} -- name to unitid
BFI.vars.units = {} -- unitid to button

local UNKNOWN = _G.UNKNOWN
local UNKNOWNOBJECT = _G.UNKNOWNOBJECT
local function UnitButton_OnTick(self)
    self.__tickCount = (self.__tickCount or 0) + 1
    if self.__tickCount >= 2 then -- every 0.5 second
        self.__tickCount = 0

        if self.unit and self.displayedUnit then
            local displayedGuid = UnitGUID(self.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                self.__displayedGuid = displayedGuid

                wipe(self.states)
                UnitButton_UpdateAll(self, not strfind(self.unit, "target$"))
            end

            local guid = UnitGUID(self.unit)
            if guid and guid ~= self.__unitGuid then
                -- NOTE: unit entity changed
                self.__unitGuid = guid

                if not self.skipDataCache then
                    BFI.vars.guids[guid] = self.unit
                end

                if self.enableUnitButtonMapping then
                    BFI.vars.units[self.unit] = self
                end

                -- NOTE: only save players' names
                if UnitIsPlayer(self.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        self.__nameRetries = nil

                        if not self.skipDataCache then
                            BFI.vars.names[name] = self.unit
                        end
                    else
                        -- NOTE: update on next tick
                        self.__nameRetries = (self.__nameRetries or 0) + 1
                        self.__unitGuid = nil
                    end
                end
            end
        end
    end

    UnitButton_UpdateInRange(self)

    if self._updateRequired then
        self._updateRequired = nil
        UnitButton_UpdateAll(self, true)
    end

    --! for Xtarget
    if self._refreshOnUpdate then
        UnitButton_UpdateAll(self)
    end
end

local function UnitButton_OnUpdate(self, elapsed)
    self.__updateElapsed = (self.__updateElapsed or 0) + elapsed
    if self.__updateElapsed >= 0.25 then
        self.__updateElapsed = 0
        UnitButton_OnTick(self)
    end
end

---------------------------------------------------------------------
-- onShow/Hide
---------------------------------------------------------------------
local function UnitButton_OnShow(self)
    -- print(GetTime(), "OnShow", self:GetName())
    self._updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.

    UnitButton_RegisterEvents(self)
    UnitButton_UpdateAllStates(self)
    UnitButton_UpdateInRange(self)
    UF.OnButtonShow(self)
    -- local success, result = pcall(UnitButton_UpdateAll, self, true)
    -- if not success then
    --     BFI.Debug("|cffabababUpdateAll FAILED|r", self:GetName(), result)
    -- end
end

local function UnitButton_OnHide(self)
    -- print(GetTime(), "OnHide", self:GetName())
    UnitButton_UnregisterEvents(self)
    UF.OnButtonHide(self)

    if self.__unitGuid then
        if not self.skipDataCache then BFI.vars.guids[self.__unitGuid] = nil end
        self.__unitGuid = nil
    end
    if self.__unitName then
        if not self.skipDataCache then BFI.vars.names[self.__unitName] = nil end
        self.__unitName = nil
    end
    if self.unit and self.enableUnitButtonMapping then
        BFI.vars.units[self.unit] = nil
    end
    self.__displayedGuid = nil
    wipe(self.states)
end

---------------------------------------------------------------------
-- onAttributeChanged
---------------------------------------------------------------------
local function UnitButton_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.unit then
            -- NOTE: when unitId for this button changes
            if self.__unitGuid then -- self.__unitGuid is deleted when hide
                if not self.skipDataCache then BFI.vars.guids[self.__unitGuid] = nil end
                self.__unitGuid = nil
            end
            if self.__unitName then
                if not self.skipDataCache then BFI.vars.names[self.__unitName] = nil end
                self.__unitName = nil
            end
            if self.unit and self.enableUnitButtonMapping then
                BFI.vars.units[self.unit] = nil
            end
            wipe(self.states)
        end

        -- private auras
        -- if self.unit ~= value then
        --     self.indicators.privateAuras:UpdatePrivateAuraAnchor(value)
        -- end

        if type(value) == "string" then
            self.unit = value
            self.displayedUnit = value

            -- for omnicd
            -- if string.match(value, "raid%d") then
            --     local i = string.match(value, "%d")
            --     _G["CellRaidFrameMember"..i] = self
            --     self.unit = value
            -- end
        end
    end
end

---------------------------------------------------------------------
-- OnEnter/Leave
---------------------------------------------------------------------
local function UnitButton_OnEnter(self)
    if self.tooltipEnabled then
        if self.tooltipAnchorTo == "self" then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint(self.tooltipPosition[1], self, self.tooltipPosition[2], self.tooltipPosition[3], self.tooltipPosition[4])
        elseif self.tooltipAnchorTo == "container" then -- party/raid
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint(self.tooltipPosition[1], self:GetParent():GetParent(), self.tooltipPosition[2], self.tooltipPosition[3], self.tooltipPosition[4])
        else -- default
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        end
        GameTooltip:SetUnit(self.unit)
    end
end

local function UnitButton_OnLeave(self)
    if self.tooltipEnabled then
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- update pixels
---------------------------------------------------------------------
local function UnitButton_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
end

---------------------------------------------------------------------
-- ping system
---------------------------------------------------------------------
local function UnitButton_SetupPing(button)
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__unitGuid
    end
end

---------------------------------------------------------------------
-- onload
---------------------------------------------------------------------
BFI.vars.unitButtons = {}

function BFIUnitButton_OnLoad(self)
    BFI.vars.unitButtons[self:GetName()] = self

    -- tables
    self.states = {}
    self.indicators = {}

    -- ping system
    UnitButton_SetupPing(self)

    -- click
    self:RegisterForClicks("AnyDown")
    self:SetAttribute("type1", "target")
    self:SetAttribute("type2", "togglemenu")

    -- overlay
    -- self.overlay = CreateFrame("Frame", self:GetName(), self)
    -- AW.SetFrameLevel(self.overlay, 60, self)
    -- self:SetAllPoints()

    -- events
    self:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
    self:HookScript("OnShow", UnitButton_OnShow)
    self:HookScript("OnHide", UnitButton_OnHide) -- use _onhide for click-castings
    self:SetScript("OnEnter", UnitButton_OnEnter)
    self:SetScript("OnLeave", UnitButton_OnLeave)
    self:SetScript("OnUpdate", UnitButton_OnUpdate)
    self:SetScript("OnEvent", UnitButton_OnEvent)

    -- pixel perfect
    AW.AddToPixelUpdater(self, UnitButton_UpdatePixels)
end

---------------------------------------------------------------------
-- resfresh all when enter/leave instance
---------------------------------------------------------------------
local function UpdateAllUnitButtons()
    for _, b in pairs(BFI.vars.unitButtons) do
        UnitButton_UpdateAll(b)
    end
end
BFI.RegisterCallback("EnterInstance", "BFI_UnitFrames", UpdateAllUnitButtons)
BFI.RegisterCallback("LeaveInstance", "BFI_UnitFrames", UpdateAllUnitButtons)