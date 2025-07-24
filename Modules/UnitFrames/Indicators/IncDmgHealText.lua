---@class BFI
local BFI = select(2, ...)
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local FormatNumber = AF.FormatNumber

---------------------------------------------------------------------
-- event
---------------------------------------------------------------------
local EVENT_COLORS = {}

local function UpdateText(self, _, unit, event, flag, amount, schoolMask)
    -- event: HEAL, DODGE, BLOCK, WOUND, MISS, PARRY, RESIST, ...
    event = event == "HEAL" and "HEAL" or "DAMAGE"
    if not EVENT_COLORS[event] then return end
    self:SetTextColor(AF.UnpackColor(EVENT_COLORS[event]))
    self:SetFormattedText("%s%s", self.GetNumeric(amount), (flag == "CRITICAL" or flag == "CRUSHING") and "!" or "")
    self:FadeInOut()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function IncDmgHealText_Update(self)
    -- UpdateText(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function IncDmgHealText_Enable(self)
    self:RegisterUnitEvent("UNIT_COMBAT", "player", UpdateText)
    -- self:Update()
end

---------------------------------------------------------------------
-- numeric
---------------------------------------------------------------------
local numeric = {
    current = function(current)
        return current
    end,

    current_short = function(current)
        return FormatNumber(current)
    end,
}

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function UpdateEvents(config)
    EVENT_COLORS["DAMAGE"] = config.damage.enabled and config.damage.color
    EVENT_COLORS["HEAL"] = config.healing.enabled and config.healing.color
end

local function IncDmgHealText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)
    UpdateEvents(config.types)

    self.GetNumeric = numeric[config.format.numeric]
    if config.format.useAsianUnits and AF.isAsian then
        FormatNumber = AF.FormatNumber_Asian
    else
        FormatNumber = AF.FormatNumber
    end

    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function IncDmgHealText_EnableConfigMode(self)
    self.Enable = IncDmgHealText_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:Show()

    self:SetTextColor(AF.UnpackColor(EVENT_COLORS["DAMAGE"]))
    self:SetFormattedText("%s!", self.GetNumeric(1234567))
end

local function IncDmgHealText_DisableConfigMode(self)
    self.Enable = IncDmgHealText_Enable
    self.Update = IncDmgHealText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateIncDmgHealText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- fade
    AF.CreateContinualFadeInOutAnimation(text)

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = IncDmgHealText_Enable
    text.Update = IncDmgHealText_Update
    text.EnableConfigMode = IncDmgHealText_EnableConfigMode
    text.DisableConfigMode = IncDmgHealText_DisableConfigMode
    text.LoadConfig = IncDmgHealText_LoadConfig

    return text
end