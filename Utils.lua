---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- cvar
---------------------------------------------------------------------
local GetCVar = GetCVar
function F.GetCVarNumber(name)
    return tonumber(GetCVar(name)) or 0
end

---------------------------------------------------------------------
-- module
---------------------------------------------------------------------
function F.GetModuleNames()
    return {
        "ActionBars",
        "Auras",
        "BuffsDebuffs",
        "Chat",
        "Colors",
        "DataBars",
        "DisableBlizzard",
        "Maps",
        -- "Misc",
        "Nameplates",
        -- "Style"
        "Tooltip",
        "UIWidgets",
        "UnitFrames",
    }
end

function F.GetModuleDefaults(module)
    module = module and BFI.modules[module]
    if module and module.GetDefaults then
        return module.GetDefaults()
    end
end

---------------------------------------------------------------------
-- hide frame
---------------------------------------------------------------------
function F.Hide(region)
    if not region then return end
    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
        region:SetParent(AF.hiddenParent)
    else
        region.Show = region.Hide
    end
    region:Hide()
end

---------------------------------------------------------------------
-- disable edit mode
---------------------------------------------------------------------
function F.DisableEditMode(region)
    region.HighlightSystem = AF.noop
    region.ClearHighlight = AF.noop
end

---------------------------------------------------------------------
-- loot spec
---------------------------------------------------------------------
function F.GetLootSpecInfo()
    local id = GetLootSpecialization()
    if id == 0 then
        -- current spec
        id = AF.player.specID
    end
    local _, name, _, icon = GetSpecializationInfoByID(id)
    return id, name, icon
end