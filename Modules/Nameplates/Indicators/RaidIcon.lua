---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local G = AF.Glyphs
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RaidIcon_Update(self)
    local unit = self.root.unit
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
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)
    G.SetFont(self.text, config.width, "outline")

    if config.style == "text" then
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
function NP.CreateRaidIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    icon:SetAllPoints()

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = RaidIcon_Enable
    frame.Update = RaidIcon_Update
    frame.LoadConfig = RaidIcon_LoadConfig

    return frame
end