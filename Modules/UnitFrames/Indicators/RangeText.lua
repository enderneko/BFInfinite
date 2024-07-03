---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF
local LRC = BFI.libs.LRC

AW.AddColors({
    range_5 = {1, 1, 1},
    range_20 = {0.055, 0.875, 0.825},
    range_30 = {0.035, 0.865, 0},
    range_40 = {1.0, 0.82, 0},
    range_out = {0.9, 0.055, 0.075, 1},
})

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, maxRange)
    if not maxRange then
        self:SetTextColor(AW.GetColorRGB("range_out"))
    elseif maxRange <= 5 then
        self:SetTextColor(AW.GetColorRGB("range_5"))
    elseif maxRange <= 20 then
        self:SetTextColor(AW.GetColorRGB("range_20"))
    elseif maxRange <= 30 then
        self:SetTextColor(AW.GetColorRGB("range_30"))
    elseif maxRange <= 40 then
        self:SetTextColor(AW.GetColorRGB("range_40"))
    else
        self:SetTextColor(AW.GetColorRGB("range_out"))
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
    U.SetFont(self, unpack(config.font))
    UF.LoadTextPosition(self, config)

    self.color = config.color
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
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = RangeText_Enable
    text.Disable = RangeText_Disable
    text.Update = RangeText_Update
    text.LoadConfig = RangeText_LoadConfig

    return text
end