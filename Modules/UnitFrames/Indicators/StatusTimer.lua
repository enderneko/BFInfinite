---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitGUID = UnitGUID
local UnitIsPlayer = AF.UnitIsPlayer
local UnitClassBase = AF.UnitClassBase
local UnitIsConnected = UnitIsConnected
local UnitIsAFK = UnitIsAFK
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    local r, g, b
    if self.color.type == "class_color" then
        if UnitIsPlayer(unit) then
            local class = UnitClassBase(unit)
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    else
        r, g, b = unpack(self.color.rgb)
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- timer
---------------------------------------------------------------------
local timers = {}
local function ShowTimer(self)
    local guid = UnitGUID(self.root.unit)
    if not guid then return end

    if not timers[guid] then
        timers[guid] = {status = self.status, start = GetTime()}
    elseif timers[guid]["status"] ~= self.status then
        timers[guid]["status"] = self.status
        timers[guid]["start"] = GetTime()
    end

    self.start = timers[guid]["start"]
    self.elapsed = 1
    self.updater:Show()
end

local function HideTimer(self)
    local guid = UnitGUID(self.root.unit)
    if guid then
        timers[guid] = nil
    end
    self.updater:Hide()
    self:SetText("")
    self.info = nil
end

---------------------------------------------------------------------
-- status
---------------------------------------------------------------------
local function SetStatus(self, status)
    if self.useEn then
        self.status = status
    else
        self.status = status and L[status]
    end

    if self.showTimer then
        if status then
            ShowTimer(self)
        else
            HideTimer(self)
        end
    else
        self:SetText(self.status or "")
    end
end

local function UpdateStatus(self)
    local unit = self.root.unit

    if not UnitIsPlayer(unit) then
        SetStatus(self)
        return
    end

    if not UnitIsConnected(unit) then
        SetStatus(self, "OFFLINE")
    elseif UnitIsAFK(unit) then
        SetStatus(self, "AFK")
    elseif UnitIsDeadOrGhost(unit) then
        if UnitIsGhost(unit) then
            SetStatus(self, "GHOST")
        else
            SetStatus(self, "DEAD")
        end
    else
        SetStatus(self)
    end
end

---------------------------------------------------------------------
-- onupdate
---------------------------------------------------------------------
local function StatusTimer_OnUpdate(updater, elapsed)
    updater.elapsed = (updater.elapsed or 0) + elapsed
    if updater.elapsed >= 1 then
        updater.elapsed = 0
        local sec = GetTime() - updater.text.start
        updater.text:SetFormattedText("%s %02d:%02d", updater.text.status, sec / 60, sec % 60)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function StatusTimer_Update(self)
    self.updater.elapsed = 1
    UpdateStatus(self)
    UpdateColor(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function StatusTimer_Enable(self)
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", UpdateStatus)
    self:RegisterEvent("UNIT_FLAGS", UpdateStatus)
    self:Show()
    self.updater.elapsed = 1
    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function StatusTimer_Disable(self)
    self:UnregisterAllEvents()
    self:Hide()
    self.updater:Hide()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function StatusTimer_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
    self.useEn = config.useEn
    self.showTimer = config.showTimer

    if config.showTimer then
        self.updater:SetScript("OnUpdate", StatusTimer_OnUpdate)
    else
        self.updater:SetScript("OnUpdate", nil)
        self.updater:Hide()
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function StatusTimer_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = StatusTimer_EnableConfigMode
    self.Update = AF.noop

    UnitGUID = UF.CFG_UnitGUID
    UnitIsPlayer = UF.CFG_UnitIsPlayer
    UnitClassBase = UF.CFG_UnitClassBase

    timers["TEST"] = nil
    self.updater.elapsed = 1
    SetStatus(self, "AFK")

    self:SetShown(self.enabled)
end

local function StatusTimer_DisableConfigMode(self)
    self.Enable = StatusTimer_Enable
    self.Update = StatusTimer_Update

    UnitGUID = UF.UnitGUID
    UnitIsPlayer = AF.UnitIsPlayer
    UnitClassBase = UnitClassBase
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateStatusTimer(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- updater
    local updater = CreateFrame("Frame", nil, parent)
    text.updater = updater
    updater:Hide()
    updater.text = text

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = StatusTimer_Enable
    text.Disable = StatusTimer_Disable
    text.Update = StatusTimer_Update
    text.EnableConfigMode = StatusTimer_EnableConfigMode
    text.DisableConfigMode = StatusTimer_DisableConfigMode
    text.LoadConfig = StatusTimer_LoadConfig

    return text
end