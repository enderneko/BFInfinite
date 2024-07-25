---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

---------------------------------------------------------------------
-- spells
---------------------------------------------------------------------
function U.GetSpellInfo(spellId)
    local info = C_Spell.GetSpellInfo(spellId)
    if not info then return end

    if not info.iconID then -- when?
        info.iconID = C_Spell.GetSpellTexture(spellId)
    end

    return info.name, info.iconID
end

---------------------------------------------------------------------
-- auras
---------------------------------------------------------------------
function U.FindAuraById(unit, filter, spellId)
    local i = 1
    repeat
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
        if auraData then
            if auraData.spellId == spellId then
                return auraData
            end
            i = i + 1
        end
    until not auraData
end