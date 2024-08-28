---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.Shared
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RaidIcon_Update(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    local index = GetRaidTargetIndex(unit)
    if index and index <= 8 then
        SetRaidTargetIconTexture(self.icon, index)
        self.text:SetText(S.MarkerGlyphs[index].char)
        self.text:SetTextColor(AW.UnpackColor(S.MarkerGlyphs[index].color))
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RaidIcon_Enable(self)
    self:RegisterEvent("RAID_TARGET_UPDATE", RaidIcon_Update)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RaidIcon_LoadConfig(self, config)
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
local function RaidIcon_EnableConfigMode(self)
    self.Enable = RaidIcon_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:Show()

    GetRaidTargetIndex = UF.CFG_GetRaidTargetIndex

    RaidIcon_Update(self)
end

local function RaidIcon_DisableConfigMode(self)
    self.Enable = RaidIcon_Enable
    self.Update = RaidIcon_Update

    GetRaidTargetIndex = UF.GetRaidTargetIndex
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRaidIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = RaidIcon_Enable
    frame.Update = RaidIcon_Update
    frame.EnableConfigMode = RaidIcon_EnableConfigMode
    frame.DisableConfigMode = RaidIcon_DisableConfigMode
    frame.LoadConfig = RaidIcon_LoadConfig

    return frame
end