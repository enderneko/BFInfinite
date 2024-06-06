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
local strfind = string.find

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

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
    UnitButton_UpdateHealthStates(self)
    UnitButton_UpdatePowerStates(self)
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
    if not self:IsVisible() then return end

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
-- TODO: REFACTOR
local function UnitButton_RegisterEvents(self)
    -- self:RegisterEvent("GROUP_ROSTER_UPDATE")

    -- health states
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

    -- powers states
    self:RegisterEvent("UNIT_POWER_UPDATE")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_DISPLAYPOWER")

    -- self:RegisterEvent("UNIT_AURA")

    -- self:RegisterEvent("UNIT_HEAL_PREDICTION")
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
    -- self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    -- self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    -- -- self:RegisterEvent("PARTY_LEADER_CHANGED") -- GROUP_ROSTER_UPDATE
    -- -- self:RegisterEvent("PLAYER_ROLES_ASSIGNED") -- GROUP_ROSTER_UPDATE
    -- self:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- self:RegisterEvent("PLAYER_REGEN_DISABLED")

    if self._updateOnPlayerTargetChanged then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    if self._updateOnUnitTargetChanged then
        self:RegisterEvent("UNIT_TARGET")
    end

    -- self:RegisterEvent("RAID_TARGET_UPDATE")

    -- self:RegisterEvent("READY_CHECK")
    -- self:RegisterEvent("READY_CHECK_FINISHED")
    -- self:RegisterEvent("READY_CHECK_CONFIRM")

    -- self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    -- self:RegisterEvent("UNIT_MODEL_CHANGED")
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.displayedUnit == unit or self.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self._updateRequired = true
            -- self._powerBarUpdateRequired = 1

        elseif event == "UNIT_AURA" then
            UnitButton_UpdateAuras(self, arg)

        elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealthStates(self)

        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerStates(self)

        elseif event == "UNIT_HEAL_PREDICTION" then
            UnitButton_UpdateHealPrediction(self)

        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealAbsorbs(self)

        elseif event == "UNIT_MAXHEALTH" then
            UnitButton_UpdateHealthStates(self)
            -- UnitButton_UpdateHealPrediction(self)
            -- UnitButton_UpdateHealAbsorbs(self)

        elseif event == "UNIT_TARGET" then
            UnitButton_UpdateTargetRaidIcon(self)

        elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FLAGS" or event == "INCOMING_SUMMON_CHANGED" then
            -- if CELL_SUMMON_ICONS_ENABLED then UnitButton_UpdateStatusIcon(self) end
            UnitButton_UpdateStatusText(self)

        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            UnitButton_UpdateThreat(self)

        -- elseif event == "INCOMING_RESURRECT_CHANGED" or event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
            -- UnitButton_UpdateStatusIcon(self)

        elseif event == "READY_CHECK_CONFIRM" then
            UnitButton_UpdateReadyCheck(self)

        end

    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = true
            -- self._powerBarUpdateRequired = 1

        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UnitButton_UpdateLeader(self, event)

        elseif event == "PLAYER_TARGET_CHANGED" then
            if UnitExists(self.unit) then
                UnitButton_UpdateAll(self, true)
            end
            -- UnitButton_UpdateTarget(self)
            -- UnitButton_UpdateThreatBar(self)

        elseif event == "UNIT_TARGET" then
            if self._updateOnUnitTargetChanged == unit and not UnitIsUnit("player", unit) then
                local exists = UnitExists(self.unit)
                if type(self._refreshOnUpdate) == "boolean" then
                    self._refreshOnUpdate = exists
                end
                if exists then
                    UnitButton_UpdateAll(self, true)
                end
            end

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
            -- self._updateRequired = true
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
                BFI.vars.guids[guid] = self.unit

                -- NOTE: only save players' names
                if UnitIsPlayer(self.unit) then
                    -- update Cell.vars.names
                    local name = GetUnitName(self.unit, true)
                    if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                        self.__unitName = name
                        BFI.vars.names[name] = self.unit
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
    -- self._powerBarUpdateRequired = 1

    UnitButton_RegisterEvents(self)
    UF.OnButtonShow(self)
    local success, result = pcall(UnitButton_UpdateAll, self, true)
    if not success then
        BFI.Debug("|cffabababUpdateAll FAILED|r", self:GetName(), result)
    end
end

local function UnitButton_OnHide(self)
    -- print(GetTime(), "OnHide", self:GetName())
    UnitButton_UnregisterEvents(self)
    UF.OnButtonHide(self)

    if self.__unitGuid then
        BFI.vars.guids[self.__unitGuid] = nil
        self.__unitGuid = nil
    end
    if self.__unitName then
        BFI.vars.names[self.__unitName] = nil
        self.__unitName = nil
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
function BFIUnitButton_OnLoad(self)
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
    self.overlay = CreateFrame("Frame", self:GetName(), self)
    AW.SetFrameLevel(self.overlay, 60, self)
    self:SetAllPoints()

    -- events
    self:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
    self:HookScript("OnShow", UnitButton_OnShow)
    self:HookScript("OnHide", UnitButton_OnHide) -- use _onhide for click-castings
    self:SetScript("OnEnter", UnitButton_OnEnter)
    self:SetScript("OnLeave", UnitButton_OnLeave)
    self:SetScript("OnUpdate", UnitButton_OnUpdate)
    self:SetScript("OnEvent", UnitButton_OnEvent)

    -- pixel perfect
    self.UpdatePixels = UnitButton_UpdatePixels
    AW.AddToPixelUpdater(self)
end

---------------------------------------------------------------------
-- shared functions
---------------------------------------------------------------------
function UF.SetupUnitButton(self, config, indicators)
    -- mover
    AW.UpdateMoverSave(self, config.general.position)

    -- strata & level
    self:SetFrameStrata(config.general.frameStrata)
    self:SetFrameLevel(config.general.frameLevel)

    -- tooltip
    UF.SetupTooltip(self, config.general.tooltip)

    -- size & point
    AW.SetSize(self, config.general.width, config.general.height)
    AW.LoadPosition(self, config.general.position)

    -- out of range alpha
    self.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(self, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(self, indicators, config)
end

function UF.SetupTooltip(self, config)
    if config.enabled then
        self.tooltipEnabled = true
        self.tooltipAnchorTo = config.anchorTo
        self.tooltipPosition = config.position
    else
        self.tooltipEnabled = nil
        self.tooltipAnchorTo = nil
        self.tooltipPosition = nil
    end
end