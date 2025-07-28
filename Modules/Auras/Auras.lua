---@class BFI
local BFI = select(2, ...)
---@class Auras
local A = BFI.Auras
---@type AbstractFramework
local AF = _G.AbstractFramework

local blacklist = {}
local auraPriorities = {}
local auraColors = {}

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function A.GetAuraPriority(spellId)
    return auraPriorities[spellId] or 9999
end

function A.GetAuraColor(spellId)
    if auraColors[spellId] then
        return AF.UnpackColor(auraColors[spellId])
    end
end

function A.IsBlacklisted(spellId)
    return blacklist[spellId] == true
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateAuras(_, module, which, operation, index, value)
    if module and module ~= "Auras" then return end

    local config = A.config

    if not which then
        blacklist = config.blacklist
        auraPriorities = config.priorities
        auraColors = config.colors
        return
    end
end
AF.RegisterCallback("BFI_UpdateModule", UpdateAuras, "high")