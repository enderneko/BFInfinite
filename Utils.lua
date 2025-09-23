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
local moduleNames = {
    -- common
    general = {localized = L["General"]},
    enhancements = {localized = L["Enhancements"], class = "Enhancements"},
    colors = {localized = L["Colors"], class = "Colors"},
    auras = {localized = L["Auras"], class = "Auras"},
    -- profile
    actionBars = {localized = L["Action Bars"], class = "ActionBars"},
    buffsDebuffs = {localized = L["Buffs & Debuffs"], class = "BuffsDebuffs"},
    chat = {localized = L["Chat"], class = "Chat"},
    dataBars = {localized = L["Data Bars"], class = "DataBars"},
    maps = {localized = L["Maps"], class = "Maps"},
    nameplates = {localized = L["Nameplates"], class = "Nameplates"},
    tooltip = {localized = L["Tooltip"], class = "Tooltip"},
    uiWidgets = {localized = L["UI Widgets"], class = "UIWidgets"},
    unitFrames = {localized = L["Unit Frames"], class = "UnitFrames"},
    disableBlizzard = {localized = L["Disable Blizzard"], class = "DisableBlizzard"},
    -- special
    profiles = {localized = L["Profiles"]},
    about = {localized = L["About"]},
}

local moduleClassMap = {}
for key, info in next, moduleNames do
    if info.class then
        moduleClassMap[info.class] = key
    end
end

function F.GetModuleLocalizedName(moduleKey)
    return moduleNames[moduleKey] and moduleNames[moduleKey].localized or moduleKey
end

function F.GetModuleClassName(moduleKey)
    return moduleNames[moduleKey] and moduleNames[moduleKey].class or AF.UpperFirst(moduleKey)
end

function F.GetModuleKey(moduleClassName)
    return moduleClassMap[moduleClassName] or AF.LowerFirst(moduleClassName)
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