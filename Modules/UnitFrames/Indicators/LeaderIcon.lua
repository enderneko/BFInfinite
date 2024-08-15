---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
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
--! CodePoints -> Unicode -> Decimal
-- https://onlinetools.com/unicode/convert-code-points-to-unicode
local GLYPHS = {
    leader = "\238\128\133",
    assistant = "\238\128\134",
}

local function UpdateLeaderIcon(self)
    local unit = self.root.unit

    local isLeader = UnitIsGroupLeader(unit)
    local isAssistant = IsInRaid() and UnitIsGroupAssistant(unit)

    if isLeader then
        -- self.icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        self.text:SetText(GLYPHS.leader)
        self:Show()
    elseif isAssistant then
        -- self.icon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        self.text:SetText(GLYPHS.assistant)
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
    self.text:SetFont(AW.GetFont("glyphs4"), config.width, "OUTLINE")
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
    text:SetTextColor(AW.GetColorRGB("leader"))

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = LeaderIcon_Enable
    frame.Update = LeaderIcon_Update
    frame.LoadConfig = LeaderIcon_LoadConfig

    return frame
end