---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitFactionGroup = UnitFactionGroup

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
--! CodePoints -> Unicode -> Decimal
-- https://onlinetools.com/unicode/convert-code-points-to-unicode
local GLYPHS = {
    Horde = "\238\128\128",
    Alliance = "\238\128\129",
}

local function FactionIcon_Update(self)
    local unit = self.root.unit
    local faction = UnitFactionGroup(unit)

    if faction == "Horde" or faction == "Alliance" then
        self.icon:SetTexture(AW.GetTexture(faction))
        self.text:SetText(GLYPHS[faction])
        self.text:SetTextColor(AW.GetColorRGB(faction))
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
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs"), config.width, "OUTLINE")

    if config.style == "font" then
        self.text:Show()
        self.icon:Hide()
    else -- "icon"
        self.icon:Show()
        self.text:Hide()
    end
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

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")
    -- text:SetJustifyH("CENTER")
    -- text:SetJustifyV("MIDDLE")

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = FactionIcon_Enable
    frame.Update = FactionIcon_Update
    frame.LoadConfig = FactionIcon_LoadConfig

    return frame
end