---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitClassBase = AF.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self)
    local unit = self.root.unit

    local r, g, b
    if self.color.type == "class_color" then
        if AF.UnitIsPlayer(unit) then
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
-- text
---------------------------------------------------------------------
local function UpdateLeaderText(self)
    local unit = self.root.unit

    local isLeader = UnitIsGroupLeader(unit)
    local isAssistant = IsInRaid() and UnitIsGroupAssistant(unit)

    if isLeader then
        self:SetText("L")
    elseif isAssistant then
        self:SetText("A")
    else
        self:SetText("")
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function LeaderText_Update(self)
    UpdateLeaderText(self)
    UpdateColor(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function LeaderText_Enable(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateLeaderText, UpdateColor)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LeaderText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function LeaderText_EnableConfigMode(self)
    self.Enable = LeaderText_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:SetShown(self.enabled)

    self:SetText("L")
    UpdateColor(self)
end

local function LeaderText_DisableConfigMode(self)
    self.Enable = LeaderText_Enable
    self.Update = LeaderText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLeaderText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = LeaderText_Enable
    text.Update = LeaderText_Update
    text.EnableConfigMode = LeaderText_EnableConfigMode
    text.DisableConfigMode = LeaderText_DisableConfigMode
    text.LoadConfig = LeaderText_LoadConfig

    return text
end