---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant

---------------------------------------------------------------------
-- show/hide
---------------------------------------------------------------------
local function UpdateLeaderIcon(self)
    local unit = self.root.unit

    local isLeader = UnitIsGroupLeader(unit)
    local isAssistant = IsInRaid() and UnitIsGroupAssistant(unit)

    if isLeader then
        self.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        self:Show()
    elseif isAssistant then
        self.texture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function LeaderIcon_Update(self)
    UpdateLeaderIcon(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function LeaderIcon_Enable(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateLeaderIcon)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LeaderIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLeaderIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent

    -- texture
    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetAllPoints()

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = LeaderIcon_Enable
    frame.Disable = LeaderIcon_Disable
    frame.Update = LeaderIcon_Update
    frame.LoadConfig = LeaderIcon_LoadConfig

    return frame
end