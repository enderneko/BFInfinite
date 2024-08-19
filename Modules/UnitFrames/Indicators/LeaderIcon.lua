---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.Shared
local UF = BFI.UnitFrames

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
        -- self.icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        self.text:SetText(S.LeaderGlyphs.leader.char)
        self.text:SetTextColor(AW.UnpackColor(S.LeaderGlyphs.leader.color))
        self:Show()
    elseif isAssistant then
        -- self.icon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        self.text:SetText(S.LeaderGlyphs.assistant.char)
        self.text:SetTextColor(AW.UnpackColor(S.LeaderGlyphs.assistant.color))
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
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LeaderIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs"), config.width, "OUTLINE")
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function LeaderIcon_EnableConfigMode(self)
    self.Enable = LeaderIcon_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self.text:SetText(S.LeaderGlyphs.leader.char)
    self.text:SetTextColor(AW.UnpackColor(S.LeaderGlyphs.leader.color))
    self:Show()
end

local function LeaderIcon_DisableConfigMode(self)
    self.Enable = LeaderIcon_Enable
    self.Update = LeaderIcon_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLeaderIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    -- frame.icon = frame:CreateTexture(nil, "ARTWORK")
    -- frame.icon:SetAllPoints()

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = LeaderIcon_Enable
    frame.Update = LeaderIcon_Update
    frame.EnableConfigMode = LeaderIcon_EnableConfigMode
    frame.DisableConfigMode = LeaderIcon_DisableConfigMode
    frame.LoadConfig = LeaderIcon_LoadConfig

    return frame
end