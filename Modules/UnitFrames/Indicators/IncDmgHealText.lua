---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- cleu
---------------------------------------------------------------------
local CLEU_EVENTS = {}
local CLEU_EVENT_COLORS = {}

local function CLEU(self)
    local _, event, _, _, _, _, _, destGUID, _, _, _, swing_amount, env_amount, _, amount, _, _, swing_heal_critical, _, _, spell_critical = CombatLogGetCurrentEventInfo()

    if not CLEU_EVENTS[event] then return end
    if destGUID ~= BFI.vars.playerGUID then return end

    self:SetTextColor(AW.UnpackColor(CLEU_EVENT_COLORS[event]))
    if event == "SWING_DAMAGE" then
        self:SetFormattedText("%s%s", swing_amount, swing_heal_critical and "!" or "")
    elseif strfind(event, "^SPELL_.*HEAL$") then
        self:SetFormattedText("%s%s", amount, swing_heal_critical and "!" or "")
    elseif strfind(event, "^SPELL_.*DAMAGE$") then
        self:SetFormattedText("%s%s", amount, spell_critical and "!" or "")
    else
        self:SetText(env_amount)
    end
    self:FadeInOut()
end

---------------------------------------------------------------------w
-- update
---------------------------------------------------------------------
local function IncDmgHealText_Update(self)
    CLEU(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function IncDmgHealText_Enable(self)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CLEU)

    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function UpdateEvents(config)
    CLEU_EVENTS["SWING_DAMAGE"] = config.swing.enabled
    CLEU_EVENTS["SPELL_DAMAGE"] = config.damage.enabled
    CLEU_EVENTS["SPELL_PERIODIC_DAMAGE"] = config.damage.enabled
    CLEU_EVENTS["ENVIRONMENTAL_DAMAGE"] = config.damage.enabled
    CLEU_EVENTS["SPELL_HEAL"] = config.heal.enabled
    CLEU_EVENTS["SPELL_PERIODIC_HEAL"] = config.heal.enabled

    CLEU_EVENT_COLORS["SWING_DAMAGE"] = config.swing.color
    CLEU_EVENT_COLORS["SPELL_DAMAGE"] = config.damage.color
    CLEU_EVENT_COLORS["SPELL_PERIODIC_DAMAGE"] = config.damage.color
    CLEU_EVENT_COLORS["ENVIRONMENTAL_DAMAGE"] = config.damage.color
    CLEU_EVENT_COLORS["SPELL_HEAL"] = config.heal.color
    CLEU_EVENT_COLORS["SPELL_PERIODIC_HEAL"] = config.heal.color
end

local function IncDmgHealText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)
    UpdateEvents(config.types)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateIncDmgHealText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- fade
    AW.CreateContinualFadeInOutAnimation(text)

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = IncDmgHealText_Enable
    text.Update = IncDmgHealText_Update
    text.LoadConfig = IncDmgHealText_LoadConfig

    return text
end