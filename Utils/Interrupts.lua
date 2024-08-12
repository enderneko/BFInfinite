---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

local IsSpellKnown = IsSpellKnown
local GetSpellCooldown = C_Spell.GetSpellCooldown

local INTERRUPT_SPELLS = {
    WARRIOR = {},
    PALADIN = {},
    HUNTER = {
        187707, -- 压制
    },
    ROGUE = {},
    PRIEST = {},
    DEATHKNIGHT = {},
    SHAMAN = {},
    MAGE = {},
    WARLOCK = {},
    MONK = {},
    DRUID = {},
    DEMONHUNTER = {},
    EVOKER = {},
}

local interrupt_spell

local function SPELLS_CHANGED()
    local found
    for _, spell in pairs(INTERRUPT_SPELLS[BFI.vars.playerClass]) do
        if IsSpellKnown then
            found = spell
            break
        end
    end
    interrupt_spell = found
end

local timer
local function DELAYED_SPELLS_CHANGED()
    if timer then timer:Cancel() end
    timer = C_Timer.After(1, SPELLS_CHANGED)
end

U:RegisterEvent("SPELLS_CHANGED", DELAYED_SPELLS_CHANGED)

function U.InterruptUsable()
    if interrupt_spell then
        return GetSpellCooldown(interrupt_spell).duration == 0
    end
end