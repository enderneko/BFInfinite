---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.M_NamePlates

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitClassBase = UnitClassBase
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
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function ClassIcon_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.RePoint(self.icon)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ClassIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    NP.LoadIndicatorPosition(self, config)
    AW.SetSize(self, config.width, config.height)
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
    iconBG:SetTexture(AW.GetTexture("Circle", true), nil, nil, "TRILINEAR")
    iconBG:SetVertexColor(AW.GetColorRGB("black"))
    iconBG:SetAllPoints()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AW.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
    AW.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)

    -- mask
    local mask = frame:CreateMaskTexture()
    mask:SetTexture(AW.GetTexture("Circle", true), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)

    -- functions
    frame.Enable = ClassIcon_Enable
    frame.Update = ClassIcon_Update
    frame.LoadConfig = ClassIcon_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, ClassIcon_UpdatePixels)

    return frame
end