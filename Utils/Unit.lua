---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

--! for AI followers
function U.UnitClassBase(unit)
    return select(2, UnitClass(unit))
end

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
local IsSpellInRange = IsSpellInRange
local IsItemInRange = IsItemInRange
local CheckInteractDistance = CheckInteractDistance
local UnitIsDead = UnitIsDead
local GetSpellTabInfo = GetSpellTabInfo
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellBookItemName = GetSpellBookItemName
local UnitClassBase = UnitClassBase
local BOOKTYPE_SPELL = BOOKTYPE_SPELL

local playerClass = UnitClassBase("player")

local friendSpells = {
    ["DEATHKNIGHT"] = 61999,
    -- ["DEMONHUNTER"] = ,
    ["DRUID"] = BFI.vars.isRetail and 8936 or 5185,
    ["EVOKER"] = 361469,
    ["HUNTER"] = 136,
    ["MAGE"] = 1459,
    ["MONK"] = 116670,
    ["PALADIN"] = BFI.vars.isRetail and 19750 or 635,
    ["PRIEST"] = BFI.vars.isRetail and 2061 or 2050,
    ["ROGUE"] = 2764,
    ["SHAMAN"] = BFI.vars.isRetail and 8004 or 331,
    ["WARLOCK"] = 20707,
    -- ["WARRIOR"] = ,
}

local harmSpells = {
    ["DEATHKNIGHT"] = 47541,
    ["DEMONHUNTER"] = 185123,
    ["DRUID"] = 5176,
    ["EVOKER"] = 361469,
    ["HUNTER"] = 75,
    ["MAGE"] = 116,
    ["MONK"] = 117952,
    ["PALADIN"] = 20271,
    ["PRIEST"] = BFI.vars.isRetail and 589 or 585,
    -- ["ROGUE"] = ,
    ["SHAMAN"] = BFI.vars.isRetail and 188196 or 403,
    ["WARLOCK"] = 686,
    ["WARRIOR"] = 355,
}

local friendItems = {
    ["DEATHKNIGHT"] = 34471,
    ["DEMONHUNTER"] = 34471,
    ["DRUID"] = 34471,
    ["EVOKER"] = 1180, -- 30y
    ["HUNTER"] = 34471,
    ["MAGE"] = 34471,
    ["MONK"] = 34471,
    ["PALADIN"] = 34471,
    ["PRIEST"] = 34471,
    ["ROGUE"] = 34471,
    ["SHAMAN"] = 34471,
    ["WARLOCK"] = 34471,
    ["WARRIOR"] = 34471,
}

local harmItems = {
    ["DEATHKNIGHT"] = 28767,
    ["DEMONHUNTER"] = 28767,
    ["DRUID"] = 28767,
    ["EVOKER"] = 24268, -- 25y
    ["HUNTER"] = 28767,
    ["MAGE"] = 28767,
    ["MONK"] = 28767,
    ["PALADIN"] = 28767,
    ["PRIEST"] = 28767,
    ["ROGUE"] = 28767,
    ["SHAMAN"] = 28767,
    ["WARLOCK"] = 28767,
    ["WARRIOR"] = 28767,
}

local function GetNumSpells()
    local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs())
    return offset + numSpells
end

local function FindSpellIndex(spellName)
    if not spellName or spellName == "" then
        return nil
    end
    for i = 1, GetNumSpells() do
        local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if spell == spellName then
            return i
        end
    end
    return nil
end

-- do
--     -- NOTE: convert ID to NAME then to INDEX
--     for k, id in pairs(friendSpells) do
--         friendSpells[k] = FindSpellIndex(GetSpellInfo(id))
--     end
--     for k, id in pairs(harmSpells) do
--         harmSpells[k] = FindSpellIndex(GetSpellInfo(id))
--     end
-- end

local function UnitInSpellRange(spellIndex, unit)
    if not spellIndex then return end
    return IsSpellInRange(spellIndex, BOOKTYPE_SPELL, unit) == 1
end

local rc = CreateFrame("Frame")
rc:RegisterEvent("SPELLS_CHANGED")

if playerClass == "EVOKER" then
    local spell_dead, spell_alive, spell_harm
    rc:SetScript("OnEvent", function()
        spell_dead = FindSpellIndex(GetSpellInfo(361227))
        spell_alive = FindSpellIndex(GetSpellInfo(361469))
        spell_harm = FindSpellIndex(GetSpellInfo(361469))
    end)

    -- NOTE: UnitInRange for evoker is around 50y
    function U.IsInRange(unit, check)
        if not UnitIsVisible(unit) then
            return false
        end

        if UnitIsUnit("player", unit) then
            return true
        -- elseif not check and U.UnitInGroup(unit) then
        --     -- NOTE: UnitInRange only works with group players/pets
        --     local checked
        --     inRange, checked = UnitInRange(unit)
        --     if not checked then
        --         return U.IsInRange(unit, true)
        --     end
        --     return inRange
        else
            -- UnitCanCooperate works with cross-faction, UnitCanAssist does not
            if UnitCanAssist("player", unit) or UnitCanCooperate("player", unit) then
                -- print("CanAssist", unit)
                if UnitIsDead(unit) then
                    return UnitInSpellRange(spell_dead, unit) -- 40y
                else
                    return UnitInSpellRange(spell_alive, unit) -- 25/30y
                end
            elseif UnitCanAttack("player", unit) then
                -- print("CanAttack", unit)
                return UnitInSpellRange(spell_harm, unit)
            end

            -- print("InRange", unit)
            return UnitInRange(unit)
        end
    end
else
    local spell_friend, spell_harm
    rc:SetScript("OnEvent", function()
        spell_friend = FindSpellIndex(GetSpellInfo(friendSpells[playerClass]))
        spell_harm = FindSpellIndex(GetSpellInfo(harmSpells[playerClass]))
    end)

    if BFI.vars.isRetail then
        function U.IsInRange(unit, check)
            if not UnitIsVisible(unit) then
                return false
            end

            if UnitIsUnit("player", unit) then
                return true
            elseif not check and U.UnitInGroup(unit) then
                -- NOTE: UnitInRange only works with group players/pets --! but not available for PLAYER PET when SOLO
                local checked
                inRange, checked = UnitInRange(unit)
                if not checked then
                    return U.IsInRange(unit, true)
                end
                return inRange
            else
                if UnitCanAssist("player", unit) or UnitCanCooperate("player", unit) then
                    -- print("CanAssist", unit)
                    if spell_friend then
                        return UnitInSpellRange(spell_friend, unit)
                    end
                elseif UnitCanAttack("player", unit) then
                    -- print("CanAttack", unit)
                    if spell_harm then
                        return UnitInSpellRange(spell_harm, unit)
                    end
                end

                -- print("InRange", unit)
                return UnitInRange(unit)
            end
        end
    else
        function U.IsInRange(unit, check)
            if not UnitIsVisible(unit) then
                return false
            end

            if UnitIsUnit("player", unit) then
                return true
            elseif not check and U.UnitInGroup(unit) then
                -- NOTE: UnitInRange only works with group players/pets --! but not available for PLAYER PET when SOLO
                local checked
                inRange, checked = UnitInRange(unit)
                if not checked then
                    return U.IsInRange(unit, true)
                end
                return inRange
            else
                if UnitCanAssist("player", unit) then
                    -- print("CanAssist", unit)
                    if spell_friend then
                        return UnitInSpellRange(spell_friend, unit)
                    else
                        return IsItemInRange(friendItems[playerClass], unit)
                    end
                elseif UnitCanAttack("player", unit) then
                    -- print("CanAttack", unit)
                    if spell_harm then
                        return UnitInSpellRange(spell_harm, unit)
                    else
                        return IsItemInRange(harmItems[playerClass], unit)
                    end
                end

                -- print("CheckInteractDistance", unit)
                return CheckInteractDistance(unit, 4) -- 28 yards
            end
        end
    end
end