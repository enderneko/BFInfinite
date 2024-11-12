---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit

---------------------------------------------------------------------
-- target
---------------------------------------------------------------------
local function UpdateTarget(self)
    local unit = self.root.unit

    if UnitIsUnit(unit, "focus") then
        self.icon:SetTexture(AF.GetTexture(self.focusTexture, BFI.name))
        self.icon:SetVertexColor(AF.UnpackColor(self.focusColor))
        self:Show()
    elseif UnitIsUnit(unit, "target") then
        self.icon:SetTexture(AF.GetTexture(self.targetTexture, BFI.name))
        self.icon:SetVertexColor(AF.UnpackColor(self.targetColor))
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function TargetIndicator_Update(self)
    UpdateTarget(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function TargetIndicator_Enable(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget)
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", UpdateTarget)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function TargetIndicator_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    AF.SetSize(self, config.width, config.height)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.targetTexture = config.target.texture
    self.targetColor = config.target.color
    self.focusTexture = config.focus.texture
    self.focusColor = config.focus.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateTargetIndicator(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- events
    AF.AddEventHandler(frame, true)

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()

    -- functions
    frame.Enable = TargetIndicator_Enable
    frame.Update = TargetIndicator_Update
    frame.LoadConfig = TargetIndicator_LoadConfig

    return frame
end