---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

local READY_CHECK_STATUS = {
    waiting = AF.GetIcon("ReadyCheck_Waiting"),
    ready = AF.GetIcon("ReadyCheck_Ready"),
    notready = AF.GetIcon("ReadyCheck_NotReady"),
}

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local GetReadyCheckStatus = GetReadyCheckStatus

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function ReadyCheckIcon_Update(self)
    local unit = self.root.unit
    self.status = GetReadyCheckStatus(unit)

    if self.status and READY_CHECK_STATUS[self.status] then
        self.icon:SetTexture(READY_CHECK_STATUS[self.status])
        self:Show()
    else
        self:Hide()
    end
end

local function ReadyCheckIcon_Finish(self)
    if self.status == "waiting" then
        self.icon:SetTexture(READY_CHECK_STATUS["notready"])
    end
    C_Timer.After(6, function()
        self:Hide()
    end)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function ReadyCheckIcon_Enable(self)
    self:RegisterEvent("READY_CHECK", ReadyCheckIcon_Update)
    self:RegisterEvent("READY_CHECK_CONFIRM", ReadyCheckIcon_Update)
    self:RegisterEvent("READY_CHECK_FINISHED", ReadyCheckIcon_Finish)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ReadyCheckIcon_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.size, config.size)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ReadyCheckIcon_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = ReadyCheckIcon_EnableConfigMode
    self.Update = AF.noop

    self.icon:SetTexture(READY_CHECK_STATUS.waiting)

    self:SetShown(self.enabled)
end

local function ReadyCheckIcon_DisableConfigMode(self)
    self.Enable = ReadyCheckIcon_Enable
    self.Update = ReadyCheckIcon_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateReadyCheckIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    frame:SetIgnoreParentAlpha(true)

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = ReadyCheckIcon_Enable
    frame.Update = ReadyCheckIcon_Update
    frame.EnableConfigMode = ReadyCheckIcon_EnableConfigMode
    frame.DisableConfigMode = ReadyCheckIcon_DisableConfigMode
    frame.LoadConfig = ReadyCheckIcon_LoadConfig

    return frame
end