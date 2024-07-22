---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

-- for AI followers
-- function U.UnitClassBase(unit)
--     return select(2, UnitClass(unit))
-- end

---------------------------------------------------------------------
-- IsXXX
---------------------------------------------------------------------
local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI

function U.UnitIsPlayer(unit)
    return UnitIsPlayer(unit) or UnitInPartyIsAI(unit)
end

function U.IsPlayer(guid)
    return strfind(guid, "^Player")
end

function U.IsPet(guid)
    return strfind(guid, "^Pet")
end

function U.IsNPC(guid)
    return strfind(guid, "^Creature")
end

function U.IsVehicle(guid)
    return strfind(guid, "^Vehicle")
end

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local GetUnitName = GetUnitName
local GetNormalizedRealmName = GetNormalizedRealmName

function U.UnitFullName(unit)
    if not unit or not UnitIsPlayer(unit) then return end

    local name = GetUnitName(unit, true)

    if name and not string.find(name, "-") then
        local server = GetNormalizedRealmName()
        if server then
            name = name.."-"..server
        end
    end

    return name
end

---------------------------------------------------------------------
-- in group
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit
local UnitInParty = UnitInParty
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitInRaid = UnitInRaid
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty

function U.UnitInGroup(unit, ignorePets)
    if ignorePets then
        return UnitIsUnit(unit, "player") or UnitInParty(unit) or UnitInRaid(unit) or UnitInPartyIsAI(unit)
    else
        return UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") or UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit) or UnitInPartyIsAI(unit)
    end
end

---------------------------------------------------------------------
-- iterate group members
---------------------------------------------------------------------
function U.GroupMembersIterator()
    local groupType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    local i

    if groupType == "party" then
        i = 0
        numGroupMembers = numGroupMembers - 1
    else
        i = 1
    end

    return function()
        local ret
        if i == 0 then
            ret = "player"
        elseif i <= numGroupMembers and i > 0 then
            ret = groupType .. i
        end
        i = i + 1
        return ret
    end
end

-------------------------------------------------
-- range checker
-------------------------------------------------
local UnitIsVisible = UnitIsVisible
local UnitInRange = UnitInRange
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitCanCooperate = UnitCanCooperate
local IsSpellInRange = (C_Spell and C_Spell.IsSpellInRange) and C_Spell.IsSpellInRange or IsSpellInRange
local IsItemInRange = (C_Spell and C_Item.IsItemInRange) and C_Item.IsItemInRange or IsItemInRange
local CheckInteractDistance = CheckInteractDistance
local UnitIsDead = UnitIsDead
local IsSpellKnown = IsSpellKnown

local UnitInSamePhase
if UnitPhaseReason then
    UnitInSamePhase = function(unit)
        return not UnitPhaseReason(unit)
    end
else
    UnitInSamePhase = UnitInPhase
end

local playerClass = UnitClassBase("player")

local friendSpells = {
    ["DEATHKNIGHT"] = 61999,
    -- ["DEMONHUNTER"] = ,
    ["DRUID"] = BFI.vars.isRetail and 8936 or 5185,
    ["EVOKER"] = 361469,
    -- ["HUNTER"] = 136,
    ["MAGE"] = 1459,
    ["MONK"] = 116670,
    ["PALADIN"] = BFI.vars.isRetail and 19750 or 635,
    ["PRIEST"] = BFI.vars.isRetail and 2061 or 2050,
    ["ROGUE"] = BFI.vars.isWrath and 57934,
    ["SHAMAN"] = BFI.vars.isRetail and 8004 or 331,
    ["WARLOCK"] = 20707,
    ["WARRIOR"] = 3411,
}

local deadSpells = {
    ["EVOKER"] = 361227, -- resurrection range, need separately for evoker
}

local petSpells = {
    ["HUNTER"] = 136,
}

local harmSpells = {
    ["DEATHKNIGHT"] = 47541,
    ["DEMONHUNTER"] = 185123,
    ["DRUID"] = 5176,
    ["EVOKER"] = 361469,
    ["HUNTER"] = 75,
    ["MAGE"] = BFI.vars.isRetail and 116 or 133,
    ["MONK"] = 117952,
    ["PALADIN"] = 20271,
    ["PRIEST"] = BFI.vars.isRetail and 589 or 585,
    ["ROGUE"] = 1752,
    ["SHAMAN"] = BFI.vars.isRetail and 188196 or 403,
    ["WARLOCK"] = 686,
    ["WARRIOR"] = 355,
}

-- local friendItems = {
--     ["DEATHKNIGHT"] = 34471,
--     ["DEMONHUNTER"] = 34471,
--     ["DRUID"] = 34471,
--     ["EVOKER"] = 1180, -- 30y
--     ["HUNTER"] = 34471,
--     ["MAGE"] = 34471,
--     ["MONK"] = 34471,
--     ["PALADIN"] = 34471,
--     ["PRIEST"] = 34471,
--     ["ROGUE"] = 34471,
--     ["SHAMAN"] = 34471,
--     ["WARLOCK"] = 34471,
--     ["WARRIOR"] = 34471,
-- }

local harmItems = {
    ["DEATHKNIGHT"] = 28767, -- 40y
    ["DEMONHUNTER"] = 28767,
    ["DRUID"] = 28767,
    ["EVOKER"] = 24268, -- 25y
    ["HUNTER"] = 28767,
    ["MAGE"] = 28767,
    ["MONK"] = 28767,
    ["PALADIN"] = 835, -- 30y
    ["PRIEST"] = 28767,
    ["ROGUE"] = 28767,
    ["SHAMAN"] = 28767,
    ["WARLOCK"] = 28767,
    ["WARRIOR"] = 28767,
}

-- local FindSpellIndex
-- if C_SpellBook and C_SpellBook.FindSpellBookSlotForSpell then
--     FindSpellIndex = function(spellName)
--         if not spellName or spellName == "" then return end
--         return C_SpellBook.FindSpellBookSlotForSpell(spellName)
--     end
-- else
--     local function GetNumSpells()
--         local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs())
--         return offset + numSpells
--     end

--     FindSpellIndex = function(spellName)
--         if not spellName or spellName == "" then return end
--         for i = 1, GetNumSpells() do
--             local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
--             if spell == spellName then
--                 return i
--             end
--         end
--     end
-- end

local UnitInSpellRange
if C_Spell and C_Spell.IsSpellInRange then
    UnitInSpellRange = function(spellName, unit)
        return IsSpellInRange(spellName, unit)
    end
else
    UnitInSpellRange = function(spellName, unit)
        return IsSpellInRange(spellName, unit) == 1
    end
end

local rc = CreateFrame("Frame")
rc:RegisterEvent("SPELLS_CHANGED")

local spell_friend, spell_pet, spell_harm, spell_dead
rc:SetScript("OnEvent", function()
    if friendSpells[playerClass] and IsSpellKnown(friendSpells[playerClass]) then
        spell_friend = U.GetSpellInfo(friendSpells[playerClass])
    end
    if petSpells[playerClass] and IsSpellKnown(petSpells[playerClass]) then
        spell_pet = U.GetSpellInfo(petSpells[playerClass])
    end
    if harmSpells[playerClass] and IsSpellKnown(harmSpells[playerClass]) then
        spell_harm = U.GetSpellInfo(harmSpells[playerClass])
    end
    if deadSpells[playerClass] and IsSpellKnown(deadSpells[playerClass]) then
        spell_dead = U.GetSpellInfo(deadSpells[playerClass])
    end
end)

function U.IsInRange(unit)
    if not UnitIsVisible(unit) then
        return false
    end

    if UnitIsUnit("player", unit) then
        return true

    else
        if UnitCanAssist("player", unit) then
            if not (UnitIsConnected(unit) and UnitInSamePhase(unit)) then
                return false
            end

            if UnitIsDead(unit) then
                if spell_dead then
                    return UnitInSpellRange(spell_dead, unit)
                end
            elseif spell_friend then
                return UnitInSpellRange(spell_friend, unit)
            end

            local inRange, checked = UnitInRange(unit)
            if checked then
                return inRange
            end

            if UnitIsUnit(unit, "pet") and spell_pet then
                -- no spell_friend, use spell_pet
                return UnitInSpellRange(spell_pet, unit)
            end

        elseif UnitCanAttack("player", unit) then
            if UnitIsDead(unit) then
                return CheckInteractDistance(unit, 4) -- 28 yards
            elseif spell_harm then
                return UnitInSpellRange(spell_harm, unit)
            end
            return IsItemInRange(harmItems[playerClass], unit)
        end

        if not InCombatLockdown() then
            return CheckInteractDistance(unit, 4) -- 28 yards
        end

        return true
    end
end