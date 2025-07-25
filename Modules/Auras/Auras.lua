---@class BFI
local BFI = select(2, ...)
---@class Auras
local A = BFI.Auras
---@type AbstractFramework
local AF = _G.AbstractFramework

local auraPriorities = {}
local auraColors = {}

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function A.GetAuraPriority(spellId)
    if auraPriorities[spellId] then
        return auraPriorities[spellId].priority
    end
end

function A.GetAuraColor(spellId)
    if auraColors[spellId] then
        return AF.UnpackColor(auraColors[spellId].color)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateAuras(_, module, which, operation, index, value)
    if module and module ~= "Auras" then return end

    local config = A.config

    if not which then
        auraPriorities = config.priorities
        auraColors = config.colors
        return
    end
end
AF.RegisterCallback("BFI_UpdateModule", UpdateAuras)