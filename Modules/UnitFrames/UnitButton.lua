local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.M_UF

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

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function UnitButton_UpdateBase(self)
    local unit = self.states.unit
    if not unit then return end

    self.states.class = UnitClassBase(unit)
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UnitButton_UpdateHealthColor(self)
    local unit = self.states.unit
    if not unit then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = UF.GetHealthColor(self, unit)
    self.indicators.healthBar:SetStatusBarColor(r, g, b, a)
    self.indicators.healthBar.loss:SetVertexColor(lossR, lossG, lossB, lossA)
end

local function UnitButton_UpdatePowerColor(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = UF.GetPowerColor(self, unit)
    self.indicators.powerBar:SetStatusBarColor(r, g, b, a)
    self.indicators.powerBar.loss:SetVertexColor(lossR, lossG, lossB, lossA)
end

---------------------------------------------------------------------
-- health
---------------------------------------------------------------------
local function UpdateUnitHealthState(self)
    local unit = self.states.displayedUnit

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
        -- UnitButton_UpdateHealthColor(self)
    end
end

local function UnitButton_UpdateHealthMax(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    self.indicators.healthBar:SetBarMinMaxValues(0, self.states.healthMax)
end

local function UnitButton_UpdateHealth(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    self.indicators.healthBar:SetBarValue(self.states.health)
end

---------------------------------------------------------------------
-- power
---------------------------------------------------------------------
local function UnitButton_UpdatePowerMax(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    self.states.powerMax = UnitPowerMax(unit)
    if self.states.powerMax < 0 then self.states.powerMax = 1 end
    
    self.indicators.powerBar:SetBarMinMaxValues(0, self.states.powerMax)
end

local function UnitButton_UpdatePower(self)
    local unit = self.states.displayedUnit
    if not unit then return end

    self.states.power = UnitPower(unit)

    self.indicators.powerBar:SetBarValue(self.states.power)
end


---------------------------------------------------------------------
-- update all
---------------------------------------------------------------------
local function UnitButton_UpdateAll(self)
    if not self:IsVisible() then return end

    --! Update Base Info
    UnitButton_UpdateBase(self)

    -- color
    UnitButton_UpdateHealthColor(self)
    UnitButton_UpdatePowerColor(self)
    -- health
    UnitButton_UpdateHealthMax(self)
    UnitButton_UpdateHealth(self)
    -- power
    UnitButton_UpdatePowerMax(self)
    UnitButton_UpdatePower(self)
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
local function UnitButton_RegisterEvents(self)
    -- self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    
    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_DISPLAYPOWER")
    
    -- self:RegisterEvent("UNIT_AURA")
    
    -- self:RegisterEvent("UNIT_HEAL_PREDICTION")
    -- self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    -- self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    
    -- self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    -- self:RegisterEvent("UNIT_EXITED_VEHICLE")
    
    -- self:RegisterEvent("INCOMING_SUMMON_CHANGED")
    -- self:RegisterEvent("UNIT_FLAGS") -- afk
    -- self:RegisterEvent("UNIT_FACTION") -- mind control
    
    -- self:RegisterEvent("UNIT_CONNECTION") -- offline
    -- self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    -- self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    -- -- self:RegisterEvent("PARTY_LEADER_CHANGED") -- GROUP_ROSTER_UPDATE
    -- -- self:RegisterEvent("PLAYER_ROLES_ASSIGNED") -- GROUP_ROSTER_UPDATE
    -- self:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    -- self:RegisterEvent("RAID_TARGET_UPDATE")
    
    -- self:RegisterEvent("READY_CHECK")
    -- self:RegisterEvent("READY_CHECK_FINISHED")
    -- self:RegisterEvent("READY_CHECK_CONFIRM")
    
    -- self:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- pet summoned far away
    
    local success, result = pcall(UnitButton_UpdateAll, self)
    if not success then
        BFI.Debug("|cffabababUpdateAll FAILED|r", self:GetName(), result)
    end
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.states.displayedUnit == unit or self.states.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self._updateRequired = 1
            self._powerBarUpdateRequired = 1

        elseif event == "UNIT_NAME_UPDATE" then
            -- UnitButton_UpdateName(self)
            -- UnitButton_UpdateNameColor(self)
            UnitButton_UpdateHealthColor(self)

        elseif event == "UNIT_MAXHEALTH" then
            UnitButton_UpdateHealthMax(self)
            UnitButton_UpdateHealth(self)
            -- UnitButton_UpdateHealPrediction(self)
            -- UnitButton_UpdateShieldAbsorbs(self)
            -- UnitButton_UpdateHealAbsorbs(self)
  
        elseif event == "UNIT_HEALTH" then
            UnitButton_UpdateHealth(self)
            -- UnitButton_UpdateHealPrediction(self)
            -- UnitButton_UpdateShieldAbsorbs(self)
            -- UnitButton_UpdateHealAbsorbs(self)
            -- UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_HEAL_PREDICTION" then
            UnitButton_UpdateHealPrediction(self)

        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateShieldAbsorbs(self)

        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealAbsorbs(self)

        elseif event == "UNIT_MAXPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)

        elseif event == "UNIT_POWER_FREQUENT" then
            UnitButton_UpdatePower(self)

        elseif event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerColor(self)

        elseif event == "UNIT_AURA" then
            UnitButton_UpdateAuras(self, arg)

        -- elseif event == "UNIT_IN_RANGE_UPDATE" then
        --     UnitButton_UpdateInRange(self, arg)

        elseif event == "UNIT_TARGET" then
            UnitButton_UpdateTargetRaidIcon(self)

        elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FLAGS" or event == "INCOMING_SUMMON_CHANGED" then
            -- if CELL_SUMMON_ICONS_ENABLED then UnitButton_UpdateStatusIcon(self) end
            UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_FACTION" then -- mind control
            UnitButton_UpdateNameColor(self)
            UnitButton_UpdateHealthColor(self) 

        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            UnitButton_UpdateThreat(self)

        -- elseif event == "INCOMING_RESURRECT_CHANGED" or event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
            -- UnitButton_UpdateStatusIcon(self)

        elseif event == "READY_CHECK_CONFIRM" then
            UnitButton_UpdateReadyCheck(self)

        elseif event == "UNIT_PORTRAIT_UPDATE" then -- pet summoned far away
            if self.states.healthMax == 0 then
                self._updateRequired = 1
                self._powerBarUpdateRequired = 1
            end
        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = 1
            self._powerBarUpdateRequired = 1

        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UnitButton_UpdateLeader(self, event)

        elseif event == "PLAYER_TARGET_CHANGED" then
            if self._updateOnPlayerTargetChanged and UnitExists(self.states.unit) then
                UnitButton_UpdateAll(self)
            end
            -- UnitButton_UpdateTarget(self)
            -- UnitButton_UpdateThreatBar(self)

        elseif event == "UNIT_THREAT_LIST_UPDATE" then
            UnitButton_UpdateThreatBar(self)

        elseif event == "RAID_TARGET_UPDATE" then
            UnitButton_UpdatePlayerRaidIcon(self)
            UnitButton_UpdateTargetRaidIcon(self)

        elseif event == "READY_CHECK" then
            UnitButton_UpdateReadyCheck(self)

        elseif event == "READY_CHECK_FINISHED" then
            UnitButton_FinishReadyCheck(self)

        elseif event == "ZONE_CHANGED_NEW_AREA" then
            -- BFI.Debug("|cffbbbbbb=== ZONE_CHANGED_NEW_AREA ===")
            -- self._updateRequired = 1
            UnitButton_UpdateStatusText(self)

        -- elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
        -- 	VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED
        end
    end
end

---------------------------------------------------------------------
-- onUpdate
---------------------------------------------------------------------
BFI.vars.guids = {} -- guid to unitid
BFI.vars.names = {} -- name to unitid

local UNKNOWN = _G.UNKNOWN
local UNKNOWNOBJECT = _G.UNKNOWNOBJECT
local function UnitButton_OnTick(self)
    self.__tickCount = (self.__tickCount or 0) + 1
    if self.__tickCount >= 2 then -- every 0.5 second
        self.__tickCount = 0
        
        if self.states.unit and self.states.displayedUnit then
            local displayedGuid = UnitGUID(self.states.displayedUnit)
            if displayedGuid ~= self.__displayedGuid then
                -- NOTE: displayed unit entity changed
                U.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
                self.__displayedGuid = displayedGuid
                self._updateRequired = 1
            end

            local guid = UnitGUID(self.states.unit)
            if guid and guid ~= self.__unitGuid then
                -- NOTE: unit entity changed
                self.__unitGuid = guid
                BFI.vars.guids[guid] = self.states.unit

                -- NOTE: only save players' names
                if UnitIsPlayer(self.states.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.states.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        BFI.vars.names[name] = self.states.unit
                        self.__nameRetries = nil
                    else
                        -- NOTE: update on next tick
                        self.__nameRetries = (self.__nameRetries or 0) + 1
                        self.__unitGuid = nil 
                    end
                end
            end
        end
    end

    -- UnitButton_UpdateInRange(self)
    
    if self._updateRequired and self._indicatorsReady then
        self._updateRequired = nil
        UnitButton_UpdateAll(self)
    end

    --! for Xtarget
    if self:GetAttribute("refreshOnUpdate") then
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
    -- self._updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    -- self._powerBarUpdateRequired = 1
    UnitButton_RegisterEvents(self)
end

local function UnitButton_OnHide(self)
    -- print(GetTime(), "OnHide", self:GetName())
    UnitButton_UnregisterEvents(self)

    if self.__unitGuid then
        BFI.vars.guids[self.__unitGuid] = nil
        self.__unitGuid = nil
    end
    if self.__unitName then
        BFI.vars.names[self.__unitName] = nil
        self.__unitName = nil
    end
    self.__displayedGuid = nil
    U.RemoveElementsExceptKeys(self.states, "unit", "displayedUnit")
end

---------------------------------------------------------------------
-- onAttributeChanged
---------------------------------------------------------------------
local function UnitButton_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.states.unit then
            -- NOTE: when unitId for this button changes
            if self.__unitGuid then -- self.__unitGuid is deleted when hide
                BFI.vars.guids[self.__unitGuid] = nil
                self.__unitGuid = nil
            end
            if self.__unitName then
                BFI.vars.names[self.__unitName] = nil
                self.__unitName = nil
            end
            wipe(self.states)
        end

        -- private auras
        -- if self.states.unit ~= value then
        --     self.indicators.privateAuras:UpdatePrivateAuraAnchor(value)
        -- end

        if type(value) == "string" then
            self.states.unit = value
            self.states.displayedUnit = value

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
function BFIUnitButton_OnLoad(button)
    -- tables
    button.states = {}
    button.indicators = {}

    -- ping system
    UnitButton_SetupPing(button)

    -- click
    button:RegisterForClicks("AnyDown")
    button:SetAttribute("type1", "target")
    button:SetAttribute("type2", "togglemenu")

    -- events
    button:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
    button:HookScript("OnShow", UnitButton_OnShow)
    button:HookScript("OnHide", UnitButton_OnHide) -- use _onhide for click-castings
    -- button:HookScript("OnEnter", UnitButton_OnEnter) -- SecureHandlerEnterLeaveTemplate
    -- button:HookScript("OnLeave", UnitButton_OnLeave) -- SecureHandlerEnterLeaveTemplate
    button:SetScript("OnUpdate", UnitButton_OnUpdate)
    button:SetScript("OnEvent", UnitButton_OnEvent)

    -- pixel perfect
    button.UpdatePixels = UnitButton_UpdatePixels
    AW.AddToPixelUpdater(button)

    -- TODO:
    button._indicatorsReady = true
end