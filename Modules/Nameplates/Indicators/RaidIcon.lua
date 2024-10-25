---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local S = BFI.Shared
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
        if S.MarkerGlyphs[index] then
            self.text:SetText(S.MarkerGlyphs[index].char)
            self.text:SetTextColor(AW.UnpackColor(S.MarkerGlyphs[index].color))
        else
            self.text:SetText("")
        end
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
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs", BFI.name), config.width, "OUTLINE")

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
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = RaidIcon_Enable
    frame.Update = RaidIcon_Update
    frame.LoadConfig = RaidIcon_LoadConfig

    return frame
end