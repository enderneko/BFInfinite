---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local G = AF.Glyphs
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
        G.SetGlyph(self.text, G.Group.leader)
        self:Show()
    elseif isAssistant then
        -- self.icon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        G.SetGlyph(self.text, G.Group.assistant)
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
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.size, config.size)
    G.SetFont(self.text, config.size, "outline")
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function LeaderIcon_EnableConfigMode(self)
    self.Enable = LeaderIcon_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    G.SetGlyph(self.text, G.Group.leader)
    self:SetShown(self.enabled)
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
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = LeaderIcon_Enable
    frame.Update = LeaderIcon_Update
    frame.EnableConfigMode = LeaderIcon_EnableConfigMode
    frame.DisableConfigMode = LeaderIcon_DisableConfigMode
    frame.LoadConfig = LeaderIcon_LoadConfig

    return frame
end