---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit
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
-- level
---------------------------------------------------------------------
local function UpdateCounter(self)
    local unit = self.root.displayedUnit

    local n = 0
    for member in U.GroupMembersIterator() do
        if UnitIsUnit(member.."target", unit) then
            n = n + 1
        end
    end

    if n > 0 then
        self:SetText(n)
    else
        self:SetText("")
    end
end

local function Check(self)
    self._enabled = IsInGroup()
    if self._enabled then
        self:Show()
        self:RegisterEvent("UNIT_TARGET", UpdateCounter)
        self:Update()
    else
        self:Hide()
        self:UnregisterEvent("UNIT_TARGET")
    end
end

local function DelayedCheck(self)
    if self.timer then self.timer:Cancel() end
    self.timer = C_Timer.NewTimer(0.5, function()
        Check(self)
    end)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function TargetCounter_Update(self)
    if self._enabled then
        UpdateCounter(self)
        UpdateColor(self)
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function TargetCounter_Enable(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", DelayedCheck)
    Check(self)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function TargetCounter_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateTargetCounter(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = TargetCounter_Enable
    text.Update = TargetCounter_Update
    text.LoadConfig = TargetCounter_LoadConfig

    return text
end