---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitClassification = UnitClassification

---------------------------------------------------------------------
-- icon
---------------------------------------------------------------------
local function UpdateIcon(self)
    local unit = self.root.unit
    local classification = UnitClassification(unit)
    if strfind(classification, "^rare") then
    -- if strfind(classification, "elite$") then
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RareIndicator_Update(self)
    UpdateIcon(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RareIndicator_Enable(self)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RareIndicator_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.SetSize(self, config.width, config.height)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    self.icon:SetVertexColor(AW.UnpackColor(config.color))
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateRareIndicator(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetTexture(AW.GetTexture("Rare"))
    icon:SetAllPoints()

    -- functions
    frame.Enable = RareIndicator_Enable
    frame.Update = RareIndicator_Update
    frame.LoadConfig = RareIndicator_LoadConfig

    return frame
end