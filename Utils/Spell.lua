---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

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