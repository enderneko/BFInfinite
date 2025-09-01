---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.modules.Nameplates

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
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    AF.SetSize(self, config.size, config.size)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    self.icon:SetVertexColor(AF.UnpackColor(config.color))
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
    icon:SetTexture(AF.GetTexture("Rare", BFI.name))
    icon:SetAllPoints()

    -- functions
    frame.Enable = RareIndicator_Enable
    frame.Update = RareIndicator_Update
    frame.LoadConfig = RareIndicator_LoadConfig

    return frame
end