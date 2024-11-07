---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local IsResting = IsResting

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RestingIndicator_Update(self)
    self:SetShown(IsResting())
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RestingIndicator_Enable(self)
    self:RegisterEvent("PLAYER_UPDATE_RESTING", RestingIndicator_Update)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", RestingIndicator_Update)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RestingIndicator_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function RestingIndicator_EnableConfigMode(self)
    self.Enable = RestingIndicator_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:Show()
end

local function RestingIndicator_DisableConfigMode(self)
    self.Enable = RestingIndicator_Enable
    self.Update = RestingIndicator_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRestingIndicator(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()
    icon:SetTexture(AF.GetTexture("Resting", BFI.name), nil, nil, "TRILINEAR")
    icon:SetParentKey("Flipbook")
    icon:SetVertexColor(1, 0.84, 0.1)

    local ag = frame:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local flip = ag:CreateAnimation("FlipBook")
    flip:SetDuration(1.8)
    flip:SetFlipBookColumns(4)
    flip:SetFlipBookRows(8)
    flip:SetFlipBookFrames(32)
    flip:SetChildKey("Flipbook")
    flip:SetEndDelay(0.2)

    frame:SetScript("OnShow", function()
        ag:Play()
    end)

    frame:SetScript("OnHide", function()
        ag:Stop()
    end)

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = RestingIndicator_Enable
    frame.Update = RestingIndicator_Update
    frame.EnableConfigMode = RestingIndicator_EnableConfigMode
    frame.DisableConfigMode = RestingIndicator_DisableConfigMode
    frame.LoadConfig = RestingIndicator_LoadConfig

    return frame
end