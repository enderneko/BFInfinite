---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.Shared
local UF = BFI.UnitFrames

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
        self.text:SetText(S.FactionGlyphs[faction].char)
        self.text:SetTextColor(AW.UnpackColor(S.FactionGlyphs[faction].color))
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
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function FactionIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs"), config.width, "OUTLINE")

    if config.style == "text" then
        self.text:Show()
        self.icon:Hide()
    else -- "icon"
        self.icon:Show()
        self.text:Hide()
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function FactionIcon_EnableConfigMode(self)
    self.Enable = FactionIcon_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:Show()

    UnitFactionGroup = UF.CFG_UnitFactionGroup

    FactionIcon_Update(self)
end

local function FactionIcon_DisableConfigMode(self)
    self.Enable = FactionIcon_Enable
    self.Update = FactionIcon_Update

    UnitFactionGroup = UF.UnitFactionGroup
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
    frame.EnableConfigMode = FactionIcon_EnableConfigMode
    frame.DisableConfigMode = FactionIcon_DisableConfigMode
    frame.LoadConfig = FactionIcon_LoadConfig

    return frame
end