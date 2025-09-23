---@class BFI
local BFI = select(2, ...)
local L = BFI.L
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
local moduleLocalizedNames = {
    -- common
    general = L["General"],
    enhancements = L["Enhancements"],
    colors = L["Colors"],
    auras = L["Auras"],
    -- profile
    actionBars = L["Action Bars"],
    buffsDebuffs = L["Buffs & Debuffs"],
    chat = L["Chat"],
    dataBars = L["Data Bars"],
    maps = L["Maps"],
    nameplates = L["Nameplates"],
    tooltip = L["Tooltip"],
    uiWidgets = L["UI Widgets"],
    unitFrames = L["Unit Frames"],
    disableBlizzard = L["Disable Blizzard"],
    -- special
    profiles = L["Profiles"],
    about = L["About"],
}

function F.GetModuleLocalizedName(moduleKey)
    return moduleLocalizedNames[moduleKey] or moduleKey
end

function F.GetModuleClassName(moduleKey)
    return AF.UpperFirst(moduleKey)
end

function F.GetModuleKey(moduleClassName)
    return AF.LowerFirst(moduleClassName)
end

function F.GetProfileModuleClassNames()
    return {
        "ActionBars",
        "BuffsDebuffs",
        "Chat",
        "DataBars",
        "Maps",
        "Nameplates",
        "Tooltip",
        "UIWidgets",
        "UnitFrames",
        "DisableBlizzard",
    }
end

function F.GetModuleDefaults(moduleClassName)
    local module = moduleClassName and BFI.modules[moduleClassName]
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