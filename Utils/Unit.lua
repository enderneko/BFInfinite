---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

-- for AI followers
function U.UnitClassBase(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- class
---------------------------------------------------------------------
local GetClassInfo = GetClassInfo
local localizedClass = LocalizedClassList()
local classFileToID = {}
local localizedClassToID = {}

do
    -- WARRIOR = 1,
    -- PALADIN = 2,
    -- HUNTER = 3,
    -- ROGUE = 4,
    -- PRIEST = 5,
    -- DEATHKNIGHT = 6,
    -- SHAMAN = 7,
    -- MAGE = 8,
    -- WARLOCK = 9,
    -- MONK = 10,
    -- DRUID = 11,
    -- DEMONHUNTER = 12,
    -- EVOKER = 13,
    for i = 1, GetNumClasses() do
        local classFile = select(2, GetClassInfo(i))
        if classFile then -- returns nil for classes not exist in Classic
            classFileToID[classFile] = i
            localizedClassToID[localizedClass[classFile]] = i
        end
    end
end

function U.GetClassID(class)
    return classFileToID[class] or localizedClassToID[class]
end

---@param class number|string
function U.GetClassFileName(class)
    if type(class) == "number" then
        return select(2, GetClassInfo(class))
    elseif type(class) == "string" then
        local id = localizedClassToID[class]
        if id then
            return select(2, GetClassInfo(id))
        end
    end
end

---@param class number|string
function U.GetClassLocalizedName(class)
    if type(class) == "number" then
        return GetClassInfo(class)
    elseif type(class) == "string" then
        local id = classFileToID[class]
        if id then
            return GetClassInfo(id)
        end
    end
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
    if not name or name == "" then return end

    if not string.find(name, "-") then
        local server = GetNormalizedRealmName()
        if server then
            name = name.."-"..server
        end
    end

    return name
end

function U.ToShortName(fullName)
    if not fullName then return "" end
    local shortName = strsplit("-", fullName)
    return shortName
end

function U.ToFullName(shortName)
    if not shortName then return "" end
    local fullName = shortName
    if not string.find(fullName, "-") then
        local server = GetNormalizedRealmName()
        if server then
            fullName = fullName.."-"..server
        end
    end
    return fullName
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
-- pet
---------------------------------------------------------------------
function U.GetPetUnit(playerUnit)
    if not strfind(playerUnit, "^[p|r]") then return end

    local unit
    if playerUnit == "player" then
        unit = "pet"
    elseif strfind(playerUnit, "^party") then
        unit = playerUnit:gsub("party", "partypet")
    elseif strfind(playerUnit, "^raid") then
        unit = playerUnit:gsub("raid", "raidpet")
    end
    return unit
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
-- range check
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
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown

local UnitInSamePhase
if BFI.vars.isRetail then
    UnitInSamePhase = function(unit)
        return not UnitPhaseReason(unit)
    end
else
    UnitInSamePhase = UnitInPhase
end

local playerClass = UnitClassBase("player")

local friendSpells = {
    -- ["DEATHKNIGHT"] = 47541,
    -- ["DEMONHUNTER"] = ,
    ["DRUID"] = (BFI.vars.isWrath or BFI.vars.isVanilla) and 5185 or 8936, -- 治疗之触 / 愈合
    -- FIXME: [361469 活化烈焰] 会被英雄天赋 [431443 时序烈焰] 替代，但它而且有问题
    -- IsSpellInRange 始终返回 nil
    ["EVOKER"] = 355913, -- 翡翠之花
    -- ["HUNTER"] = 136,
    ["MAGE"] = 1459, -- 奥术智慧 / 奥术光辉
    ["MONK"] = 116670, -- 活血术
    ["PALADIN"] = BFI.vars.isRetail and 19750 or 635, -- 圣光闪现 / 圣光术
    ["PRIEST"] = (BFI.vars.isWrath or BFI.vars.isVanilla) and 2050 or 2061, -- 次级治疗术 / 快速治疗
    -- ["ROGUE"] = BFI.vars.isWrath and 57934,
    ["SHAMAN"] = BFI.vars.isRetail and 8004 or 331, -- 治疗之涌 / 治疗波
    ["WARLOCK"] = 5697, -- 无尽呼吸
    -- ["WARRIOR"] = 3411,
}

local deadSpells = {
    ["EVOKER"] = 461526, -- resurrection range, need separately for evoker
}

local petSpells = {
    ["HUNTER"] = 136,
}

local harmSpells = {
    ["DEATHKNIGHT"] = 47541, -- 凋零缠绕
    ["DEMONHUNTER"] = 185123, -- 投掷利刃
    ["DRUID"] = 5176, -- 愤怒
    -- FIXME: [361469 活化烈焰] 会被英雄天赋 [431443 时序烈焰] 替代，但它而且有问题
    -- IsSpellInRange 始终返回 nil
    ["EVOKER"] = 362969, -- 碧蓝打击
    ["HUNTER"] = 75, -- 自动射击
    ["MAGE"] = BFI.vars.isRetail and 116 or 133, -- 寒冰箭 / 火球术
    ["MONK"] = 117952, -- 碎玉闪电
    ["PALADIN"] = 20271, -- 审判
    ["PRIEST"] = BFI.vars.isRetail and 589 or 585, -- 暗言术：痛 / 惩击
    ["ROGUE"] = 1752, -- 影袭
    ["SHAMAN"] = BFI.vars.isRetail and 188196 or 403, -- 闪电箭
    ["WARLOCK"] = 234153, -- 吸取生命
    ["WARRIOR"] = 355, -- 嘲讽
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
    ["DEMONHUNTER"] = 28767, -- 40y
    ["DRUID"] = 28767, -- 40y
    ["EVOKER"] = 24268, -- 25y
    ["HUNTER"] = 28767, -- 40y
    ["MAGE"] = 28767, -- 40y
    ["MONK"] = 28767, -- 40y
    ["PALADIN"] = 835, -- 30y
    ["PRIEST"] = 28767, -- 40y
    ["ROGUE"] = 28767, -- 40y
    ["SHAMAN"] = 28767, -- 40y
    ["WARLOCK"] = 28767, -- 40y
    ["WARRIOR"] = 28767, -- 40y
}

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

local spell_friend, spell_pet, spell_harm, spell_dead
BFI_RANGE_CHECK_FRIENDLY = {}
BFI_RANGE_CHECK_HOSTILE = {}
BFI_RANGE_CHECK_DEAD = {}
BFI_RANGE_CHECK_PET = {}

local function SPELLS_CHANGED()
    spell_friend = BFI_RANGE_CHECK_FRIENDLY[playerClass] or friendSpells[playerClass]
    spell_harm = BFI_RANGE_CHECK_HOSTILE[playerClass] or harmSpells[playerClass]
    spell_dead = BFI_RANGE_CHECK_DEAD[playerClass] or deadSpells[playerClass]
    spell_pet = BFI_RANGE_CHECK_PET[playerClass] or petSpells[playerClass]

    if spell_friend and IsSpellKnownOrOverridesKnown(spell_friend) then
        spell_friend = U.GetSpellInfo(spell_friend)
    else
        spell_friend = nil
    end
    if spell_harm and IsSpellKnownOrOverridesKnown(spell_harm) then
        spell_harm = U.GetSpellInfo(spell_harm)
    else
        spell_harm = nil
    end
    if spell_dead and IsSpellKnownOrOverridesKnown(spell_dead) then
        spell_dead = U.GetSpellInfo(spell_dead)
    else
        spell_dead = nil
    end
    if spell_pet and IsSpellKnownOrOverridesKnown(spell_pet) then
        spell_pet = U.GetSpellInfo(spell_pet)
    else
        spell_pet = nil
    end

    -- BFI.Debug(
    --     "[RANGE CHECK]",
    --     "\nfriend:", spell_friend or "nil",
    --     "\npet:", spell_pet or "nil",
    --     "\nharm:", spell_harm or "nil",
    --     "\ndead:", spell_dead or "nil"
    -- )
end

local timer
local function DELAYED_SPELLS_CHANGED()
    if timer then timer:Cancel() end
    timer = C_Timer.After(1, SPELLS_CHANGED)
end

U:RegisterEvent("SPELLS_CHANGED", DELAYED_SPELLS_CHANGED)

function U.IsInRange(unit)
    if not UnitIsVisible(unit) then
        return false
    end

    if UnitIsUnit("player", unit) then
        return true

    -- elseif not check and F:UnitInGroup(unit) then
    --     -- NOTE: UnitInRange only works with group players/pets --! but not available for PLAYER PET when SOLO
    --     local inRange, checked = UnitInRange(unit)
    --     if not checked then
    --         return F:IsInRange(unit, true)
    --     end
    --     return inRange

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