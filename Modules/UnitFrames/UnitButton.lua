---@class BFI
local BFI = select(2, ...)
local UF = BFI.modules.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local issecretvalue = issecretvalue
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
local UnitClassBase = AF.UnitClassBase

---------------------------------------------------------------------
-- states
---------------------------------------------------------------------
local function UnitButton_UpdateStates(self)
    local unit = self.unit
    if not unit then return end

    self.states.name = GetUnitName(unit, true)
    self.states.class = UnitClassBase(unit)
    self.states.guid = UnitGUID(unit)
    self.states.isPlayer = UnitIsPlayer(unit)
    self.states.inVehicle = UnitHasVehicleUI(unit)

    if self.states.inVehicle then
        if unit == "player" then
            self.effectiveUnit = "vehicle"
        elseif strfind(unit, "%d$") then
            local prefix, id = strmatch(unit, "([^%d]+)([%d]+)")
            self.effectiveUnit = prefix .. "pet" .. id
        else
            self.effectiveUnit = unit .. "pet"
        end
    else
        self.effectiveUnit = self.unit
    end

    if unit == "pet" then
        if UnitHasVehicleUI("player") then
            self.effectiveUnit = "player"
        else
            self.effectiveUnit = "pet"
        end
    end
end

---------------------------------------------------------------------
-- range
---------------------------------------------------------------------
local function UnitButton_UpdateInRange(self, ir)
    if true then return end -- FIXME: disable for now

    if not self.oorAlpha then return end

    local unit = self.effectiveUnit
    if not unit then return end

    local inRange = AF.IsInRange(unit)

    self.states.inRange = inRange
    if self.states.inRange ~= self.states.wasInRange then
        if inRange then
            AF.FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
        else
            AF.FrameFadeOut(self, 0.25, self:GetAlpha(), self.oorAlpha)
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

    -- states
    UnitButton_UpdateStates(self)

    -- update indicators
    UF.UpdateIndicators(self, force)

    -- range
    UnitButton_UpdateInRange(self)
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
local function UnitButton_RegisterEvents(self)
    self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
    self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", self.unit)
    self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", self.unit)
    self:RegisterEvent("UNIT_FLAGS")
    self:RegisterEvent("UNIT_NAME_UPDATE")

    if self._updateOnGroupUpdate then
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end

    if self._updateOnPlayerTargetChanged then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    if self._updateOnUnitTargetChanged then
        self:RegisterUnitEvent("UNIT_TARGET", self._updateOnUnitTargetChanged)
    end

    if self._updateOnEvent then
        self:RegisterEvent(self._updateOnEvent)
    end
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit, arg)
    if unit and (self.effectiveUnit == unit or self.unit == unit) then
        if event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION"
            or event == "UNIT_FLAGS" or event == "UNIT_NAME_UPDATE"
        then
            self._updateRequired = true
        end
    else
        if event == "GROUP_ROSTER_UPDATE" then
            self._updateRequired = true
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
        elseif event == self._updateOnEvent then
            self._updateRequired = true
        end
    end
end

---------------------------------------------------------------------
-- onUpdate
---------------------------------------------------------------------
-- BFI.vars.guids = {} -- guid to unitid
-- BFI.vars.names = {} -- name to unitid
BFI.vars.units = {} -- unitid to button

local UNKNOWN = _G.UNKNOWN
local UNKNOWNOBJECT = _G.UNKNOWNOBJECT
local function UnitButton_OnTick(self)
    self.__tickCount = (self.__tickCount or 0) + 1
    if self.__tickCount >= 2 then -- every 0.5 second
        self.__tickCount = 0

        if self.unit and self.effectiveUnit then
            self.__effectiveGuid = UnitGUID(self.effectiveUnit)

            local guid = UnitGUID(self.unit)

            -- NOTE: player GUID is non-secret, but be careful with "(enemy)target" units
            if not issecretvalue(guid) and UnitIsPlayer(self.unit) and not self._skipDataCache then
                if guid and guid ~= self.__unitGuid then
                    -- NOTE: unit entity changed
                    self.__unitGuid = guid

                    -- if not self._skipDataCache then
                    --     BFI.vars.guids[guid] = self.unit
                    -- end

                    if self._enableUnitButtonMapping then
                        BFI.vars.units[self.unit] = self
                    end

                    -- NOTE: save players' names
                    -- local name = GetUnitName(self.unit, true)
                    -- if (name and self.__nameRetries and self.__nameRetries >= 4) or (name and name ~= UNKNOWN and name ~= UNKNOWNOBJECT) then
                    --     self.__unitName = name
                    --     self.__nameRetries = nil

                    --     if not self._skipDataCache then
                    --         BFI.vars.names[name] = self.unit
                    --     end
                    -- else
                    --     -- NOTE: update on next tick
                    --     self.__nameRetries = (self.__nameRetries or 0) + 1
                    --     self.__unitGuid = nil
                    -- end
                end
            end
        end
    end

    UnitButton_UpdateInRange(self)

    if self._refreshOnUpdate then
        --! for Xtarget
        UnitButton_UpdateAll(self)
    elseif self._updateRequired then
        self._updateRequired = nil
        UnitButton_UpdateAll(self, true)
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
    -- print(AF.WrapTextInColor(GetTime(), "darkgray"), "[OnShow]", self:GetName(), self.effectiveUnit)
    self._updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.

    UnitButton_RegisterEvents(self)
    UnitButton_UpdateStates(self)
    UnitButton_UpdateInRange(self)
    UF.OnButtonShow(self)
    -- local success, result = pcall(UnitButton_UpdateAll, self, true)
    -- if not success then
    --     AF.Debug("|cffabababUpdateAll FAILED|r", self:GetName(), result)
    -- end
end

local function UnitButton_OnHide(self)
    -- print(AF.WrapTextInColor(GetTime(), "darkgray"), "[OnHide]", self:GetName(), self.effectiveUnit)
    UnitButton_UnregisterEvents(self)
    UF.OnButtonHide(self)

    -- if self.__unitGuid then
    --     if not self._skipDataCache then BFI.vars.guids[self.__unitGuid] = nil end
    --     self.__unitGuid = nil
    -- end
    -- if self.__unitName then
    --     if not self._skipDataCache then BFI.vars.names[self.__unitName] = nil end
    --     self.__unitName = nil
    -- end
    if self.unit and self._enableUnitButtonMapping then
        BFI.vars.units[self.unit] = nil
    end

    self.__unitGuid = nil
    self.__effectiveGuid = nil
    wipe(self.states)
end

---------------------------------------------------------------------
-- onAttributeChanged
---------------------------------------------------------------------
local function UnitButton_OnUnitChanged(self)
    print(AF.WrapTextInColor(GetTime(), "darkgray"), "[OnUnitChanged]", self:GetName(), self.effectiveUnit)

    -- TODO: private auras indicator

    UnitButton_UpdateStates(self)
    UnitButton_UpdateInRange(self)
    UF.OnButtonShow(self)
end

local function UnitButton_OnAttributeChanged(self, name, value)
    if name == "unit" then
        -- print(AF.WrapTextInColor(GetTime(), "darkgray"), "OnAttributeChanged", self:GetName(), name, value)
        if not value or value ~= self.unit then
            -- NOTE: when unitId for this button changes
            -- if self.__unitGuid then -- self.__unitGuid is deleted when hide
            --     if not self._skipDataCache then BFI.vars.guids[self.__unitGuid] = nil end
            --     self.__unitGuid = nil
            -- end
            -- if self.__unitName then
            --     if not self._skipDataCache then BFI.vars.names[self.__unitName] = nil end
            --     self.__unitName = nil
            -- end
            if self.unit and self._enableUnitButtonMapping then
                BFI.vars.units[self.unit] = nil
            end
            wipe(self.states)
        end

        if value and value ~= self.unit then
            -- print(AF.WrapTextInColor(GetTime(), "darkgray"), "UnitButton_OnAttributeChanged", self:GetName(), value)
            self.unit = value
            self.effectiveUnit = value
            if self._updateOnUnitChange then
                UnitButton_OnUnitChanged(self)
            end
        end
    end
end

---------------------------------------------------------------------
-- OnEnter/Leave
---------------------------------------------------------------------
local function UnitButton_OnEnter(self)
    if self.tooltip.enabled then
        if self.tooltip.anchorTo == "self" then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint(self.tooltip.position[1], self, self.tooltip.position[2], self.tooltip.position[3], self.tooltip.position[4])
        elseif self.tooltip.anchorTo == "parent" then -- party/raid
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint(self.tooltip.position[1], self:GetParent():GetParent(), self.tooltip.position[2], self.tooltip.position[3], self.tooltip.position[4])
        else -- default
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        end
        GameTooltip:SetUnit(self.unit)

        -- NOTE: moved to OnTooltipSetUnit
        -- for GameTooltip_OnUpdate
        -- self.UpdateTooltip = UnitButton_OnEnter
    end
end

local function UnitButton_OnLeave(self)
    -- NOTE: moved to OnTooltipSetUnit
    -- for GameTooltip_OnUpdate
    -- self.UpdateTooltip = nil
    if self.tooltip.enabled then
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- update pixels
---------------------------------------------------------------------
-- local function UnitButton_UpdatePixels(self)
--     AF.ReSize(self)
--     AF.RePoint(self)
--     AF.ReBorder(self)
-- end

---------------------------------------------------------------------
-- ping system
---------------------------------------------------------------------
local function UnitButton_SetupPing(button)
    Mixin(button, PingableType_UnitFrameMixin)
    button:SetAttribute("ping-receiver", true)

    function button:GetTargetPingGUID()
        return button.__effectiveGuid
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
    -- AF.SetFrameLevel(self.overlay, 60, self)
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
    AF.AddToPixelUpdater_Auto(self, nil, true)
end

---------------------------------------------------------------------
-- resfresh all when enter/leave instance
---------------------------------------------------------------------
local function UpdateAllUnitButtons()
    for _, b in next, BFI.vars.unitButtons do
        UnitButton_UpdateAll(b)
    end
end
AF.RegisterCallback("AF_INSTANCE_CHANGE", UpdateAllUnitButtons)