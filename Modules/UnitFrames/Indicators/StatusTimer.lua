---@class BFI
local BFI = select(2, ...)
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
-- update
---------------------------------------------------------------------
local function StatusTimer_Update(self)
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
    if self:IsVisible() then self:Update() end
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
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateStatusTimer(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- updater
    text.updater = CreateFrame("Frame", nil, parent)
    text.updater:Hide()
    text.updater:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            self.elapsed = 0
            local sec = GetTime() - text.start
            text:SetFormattedText("%s %02d:%02d", text.status, sec / 60, sec % 60)
        end
    end)

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = StatusTimer_Enable
    text.Disable = StatusTimer_Disable
    text.Update = StatusTimer_Update
    text.LoadConfig = StatusTimer_LoadConfig

    return text
end