---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitGUID = UnitGUID
local UnitIsPlayer = U.UnitIsPlayer
local UnitClassBase = U.UnitClassBase
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
    self.status = status
    if status then
        if not self.useEn then
            self.status = L[status]
        end
        ShowTimer(self)
    else
        HideTimer(self)
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
local function StatusTimer_OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        local sec = GetTime() - self.text.start
        if self.text.showLabel then
            self.text:SetFormattedText("%s %02d:%02d", self.text.status, sec / 60, sec % 60)
        else
            self.text:SetFormattedText("%02d:%02d", sec / 60, sec % 60)
        end
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
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
    self.useEn = config.useEn
    self.showLabel = config.showLabel
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function StatusTimer_EnableConfigMode(self)
    self.Enable = StatusTimer_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()

    UnitGUID = UF.CFG_UnitGUID
    UnitIsPlayer = UF.CFG_UnitIsPlayer
    UnitClassBase = UF.CFG_UnitClassBase

    timers["TEST"] = nil
    self.updater.elapsed = 1
    SetStatus(self, "AFK")
    self:Show()
end

local function StatusTimer_DisableConfigMode(self)
    self.Enable = StatusTimer_Enable
    self.Update = StatusTimer_Update

    UnitGUID = UF.UnitGUID
    UnitIsPlayer = U.UnitIsPlayer
    UnitClassBase = U.UnitClassBase
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

    updater:SetScript("OnUpdate", StatusTimer_OnUpdate)

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = StatusTimer_Enable
    text.Disable = StatusTimer_Disable
    text.Update = StatusTimer_Update
    text.EnableConfigMode = StatusTimer_EnableConfigMode
    text.DisableConfigMode = StatusTimer_DisableConfigMode
    text.LoadConfig = StatusTimer_LoadConfig

    return text
end