---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames
local LRC = BFI.libs.LRC

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, maxRange)
    if not maxRange then
        self:SetTextColor(AF.GetColorRGB("range_out"))
    elseif maxRange <= 5 then
        self:SetTextColor(AF.GetColorRGB("range_5"))
    elseif maxRange <= 20 then
        self:SetTextColor(AF.GetColorRGB("range_20"))
    elseif maxRange <= 30 then
        self:SetTextColor(AF.GetColorRGB("range_30"))
    elseif maxRange <= 40 then
        self:SetTextColor(AF.GetColorRGB("range_40"))
    else
        self:SetTextColor(AF.GetColorRGB("range_out"))
    end
end

---------------------------------------------------------------------
-- range
---------------------------------------------------------------------
local function UpdateRange(self)
    local unit = self.root.unit

    if UnitIsUnit(unit, "player") then
        self:SetText("")
        return
    end

    local minRange, maxRange = LRC:GetRange(unit, true)
    if not minRange then
        self:SetText("")
    elseif not maxRange then
        UpdateColor(self)
        self:SetText(minRange .. "+")
    else
        UpdateColor(self, maxRange)
        self:SetText(minRange .. "-" .. maxRange)
    end
end

local function RangeText_OnUpdate(updater, elapsed)
    updater.elapsed = (updater.elapsed or 0) + elapsed
    if updater.elapsed >= 0.2 then
        updater.elapsed = 0
        UpdateRange(updater.text)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RangeText_Update(self)
    UpdateRange(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RangeText_Enable(self)
    self:Show()
    self.updater:Show()
    UpdateRange(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RangeText_Disable(self)
    self:Hide()
    self.updater:Hide()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RangeText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function RangeText_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = RangeText_EnableConfigMode
    self.Update = AF.noop

    self:SetText("30-35")
    UpdateColor(self, 35)
    self.updater:Hide()

    self:SetShown(self.enabled)
end

local function RangeText_DisableConfigMode(self)
    self.Enable = RangeText_Enable
    self.Update = RangeText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRangeText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- updater
    local updater = CreateFrame("Frame", nil, parent)
    text.updater = updater
    updater.text = text
    updater:Hide()
    updater:SetScript("OnUpdate", RangeText_OnUpdate)

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = RangeText_Enable
    text.Disable = RangeText_Disable
    text.Update = RangeText_Update
    text.EnableConfigMode = RangeText_EnableConfigMode
    text.DisableConfigMode = RangeText_DisableConfigMode
    text.LoadConfig = RangeText_LoadConfig

    return text
end