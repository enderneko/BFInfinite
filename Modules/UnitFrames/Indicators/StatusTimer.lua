---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsPlayer = UnitIsPlayer
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            local class = UnitClassBase(unit)
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
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
        self.text:SetFormattedText("%s %02d:%02d", self.text.status, sec / 60, sec % 60)
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
    self.updater:SetScript("OnUpdate", StatusTimer_OnUpdate)
    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function StatusTimer_Disable(self)
    self:UnregisterAllEvents()
    self:Hide()
    self.updater:SetScript("OnUpdate", nil)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function StatusTimer_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
    self.useEn = config.useEn
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function StatusTimer_EnableConfigMode(self)
    self.Enable = StatusTimer_EnableConfigMode
    self.Update = BFI.dummy

    self.updater:Hide()
    self:UnregisterAllEvents()
    if self.useEn then
        self:SetText("AFK 00:30")
    else
        self:SetText(L["AFK"] .. " 00:30")
    end
    self:Show()
end

local function StatusTimer_DisableConfigMode(self)
    self.Enable = StatusTimer_Enable
    self.Update = StatusTimer_Update
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