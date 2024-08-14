---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

local READY_CHECK_STATUS = {
    waiting = AW.GetIcon("ReadyCheck_Waiting", true),
    ready = AW.GetIcon("ReadyCheck_Ready", true),
    notready = AW.GetIcon("ReadyCheck_NotReady", true),
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
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ReadyCheckIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
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
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = ReadyCheckIcon_Enable
    frame.Update = ReadyCheckIcon_Update
    frame.LoadConfig = ReadyCheckIcon_LoadConfig

    return frame
end