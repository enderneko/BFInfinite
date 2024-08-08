---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self)
    local unit = self.root.unit

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
    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LeaderText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLeaderText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = LeaderText_Enable
    text.Update = LeaderText_Update
    text.LoadConfig = LeaderText_LoadConfig

    return text
end