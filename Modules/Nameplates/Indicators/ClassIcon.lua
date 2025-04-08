---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitClassBase = U.UnitClassBase
local UnitIsPlayer = UnitIsPlayer

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function ClassIcon_Update(self)
    local unit = self.root.unit
    if not UnitIsPlayer(unit) then
        self:Hide()
        return
    end

    local class = UnitClassBase(unit)
    if class then
        self.icon:SetAtlas("classicon-"..class)
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function ClassIcon_Enable(self)
    self:Update()
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function ClassIcon_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.RePoint(self.icon)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ClassIcon_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateClassIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- iconBG
    local iconBG = frame:CreateTexture(nil, "BORDER")
    frame.iconBG = iconBG
    iconBG:SetTexture(AF.GetTexture("Circle1"), nil, nil, "TRILINEAR")
    iconBG:SetVertexColor(AF.GetColorRGB("black"))
    iconBG:SetAllPoints()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AF.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
    AF.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)

    -- mask
    local mask = frame:CreateMaskTexture()
    mask:SetTexture(AF.GetTexture("Circle1"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)

    -- functions
    frame.Enable = ClassIcon_Enable
    frame.Update = ClassIcon_Update
    frame.LoadConfig = ClassIcon_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater(frame, ClassIcon_UpdatePixels)

    return frame
end