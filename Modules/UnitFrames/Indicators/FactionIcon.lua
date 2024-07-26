---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitFactionGroup = UnitFactionGroup

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function FactionIcon_Update(self)
    local unit = self.root.unit
    local faction = UnitFactionGroup(unit)

    if faction == "Horde" or faction == "Alliance" then
        self.icon:SetTexture(AW.GetTexture(faction))
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function FactionIcon_Enable(self)
    -- self:RegisterEvent("UNIT_FACTION", FactionIcon_Update)
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function FactionIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateFactionIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = FactionIcon_Enable
    frame.Update = FactionIcon_Update
    frame.LoadConfig = FactionIcon_LoadConfig

    return frame
end