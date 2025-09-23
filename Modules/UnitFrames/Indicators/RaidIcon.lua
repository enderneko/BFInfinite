---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local G = AF.Glyphs
local UF = BFI.modules.UnitFrames

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
    if index then
        SetRaidTargetIconTexture(self.icon, index)
        G.SetGlyph(self.text, G.Marker[index])
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
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.size, config.size)
    G.SetFont(self.text, config.size, "outline")

    if UF.config.general.raidIconStyle == "af" then
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
    self:UnregisterAllEvents()
    self.Enable = RaidIcon_EnableConfigMode
    self.Update = AF.noop

    GetRaidTargetIndex = UF.CFG_GetRaidTargetIndex

    RaidIcon_Update(self)

    self:SetShown(self.enabled)
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
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = RaidIcon_Enable
    frame.Update = RaidIcon_Update
    frame.EnableConfigMode = RaidIcon_EnableConfigMode
    frame.DisableConfigMode = RaidIcon_DisableConfigMode
    frame.LoadConfig = RaidIcon_LoadConfig

    return frame
end