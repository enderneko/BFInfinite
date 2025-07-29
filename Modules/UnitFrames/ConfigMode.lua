---@class BFI
local BFI = select(2, ...)
---@class UnitFrames
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- config mode random functions
---------------------------------------------------------------------
UF.UnitHealth = UnitHealth
function UF.CFG_UnitHealth()
    return random(25, 75)
end

UF.UnitHealthMax = UnitHealthMax
function UF.CFG_UnitHealthMax()
    return 100
end

UF.UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
function UF.CFG_UnitGetTotalAbsorbs()
    return random(25, 50)
end

UF.UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
function UF.CFG_UnitGetTotalHealAbsorbs()
    return random(25, 50)
end

function UF.CFG_UnitClassBase()
    return AF.player.class
end

-- UF.UnitName = UnitName
-- function UF.CFG_UnitName(unit)
--     return AF.UpperFirst(unit)
-- end

UF.UnitHasVehicleUI = UnitHasVehicleUI
function UF.CFG_UnitHasVehicleUI()
    return false
end

-- UF.UnitPowerType = UnitPowerType
-- function UF.CFG_UnitPowerType()
--     -- return Enum.PowerType[random(0, 3)]
--     return UnitPowerType("player")
-- end

UF.UnitPower = UnitPower
function UF.CFG_UnitPower()
    return random(20, 100)
end

UF.UnitPowerMax = UnitPowerMax
function UF.CFG_UnitPowerMax()
    return 100
end

UF.GetRaidTargetIndex = GetRaidTargetIndex
function UF.CFG_GetRaidTargetIndex()
    return random(1, 8)
end

local name, texture
local spell = Spell:CreateFromSpellID(19750)
spell:ContinueOnSpellLoad(function()
    name = spell:GetSpellName()
    texture = spell:GetSpellTexture()
end)
UF.UnitCastingInfo = UnitCastingInfo
function UF.CFG_UnitCastingInfo()
    local start = GetTime() * 1000
    return name, nil, texture, start, start + 3000
end

UF.UnitIsUnit = UnitIsUnit
function UF.CFG_UnitIsUnit()
    return true
end

UF.UnitStagger = UnitStagger
function UF.CFG_UnitStagger()
    return 50
end

UF.UnitFactionGroup = UnitFactionGroup
function UF.CFG_UnitFactionGroup()
    return UnitFactionGroup("player")
end

function UF.CFG_UnitIsPlayer()
    return true
end

UF.UnitGUID = UnitGUID
function UF.CFG_UnitGUID()
    return "TEST"
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local configModeGroups = {
    -- [group] = {
    --     ["enabled"] = (boolean),
    --     ["container"] = frame,
    --     ["headers"] = {...},
    --     ["children"] = {...},
    -- }
}

BFI.configModeGroups = configModeGroups

function UF.AddToConfigMode(group, frame)
    local main, sub = strsplit(".", group)

    if not configModeGroups[main] then
        configModeGroups[main] = {enabled = true}
    end

    if sub == "container" then
        configModeGroups[main]["container"] = frame
    elseif sub == "header" then
        if not configModeGroups[main]["headers"] then
            configModeGroups[main]["headers"] = {}
        end
        tinsert(configModeGroups[main]["headers"], frame)
    else
        if not configModeGroups[main]["children"] then
            configModeGroups[main]["children"] = {}
        end
        tinsert(configModeGroups[main]["children"], frame)
    end
end

function UF.RemoveFromConfigMode(group)
    if not configModeGroups[group] then return end
    configModeGroups[group] = nil
end

---------------------------------------------------------------------
-- force show/hide
---------------------------------------------------------------------
local function ForceShowGroup(group)
    for i, frame in pairs(configModeGroups[group]["children"]) do
        frame:Show()
    end

    if configModeGroups[group]["container"] then
        configModeGroups[group]["container"]:Show()
    end
end

local function ForceHideGroup(group)
    for i, frame in pairs(configModeGroups[group]["children"]) do
        frame:Hide()
    end

    if configModeGroups[group]["container"] then
        configModeGroups[group]["container"]:Hide()
    end
end

---------------------------------------------------------------------
-- enable config mode
---------------------------------------------------------------------
local function EnableConfigModeForGroup(group)
    for i, frame in pairs(configModeGroups[group]["children"]) do
        frame.inConfigMode = true
        frame.oldUnit = frame.unit
        UnregisterUnitWatch(frame)
        frame:Hide()
        frame:SetAttribute("unit", "player")
        frame.unit = "player"
        frame.displayedUnit = "player"
        frame:EnableMouse(false)

        -- force show indicators
        for _, indicator in pairs(frame.indicators) do
            if indicator.enabled and indicator.EnableConfigMode then
                indicator:EnableConfigMode()
            end
        end
    end

    if configModeGroups[group]["headers"] then
        for _, header in pairs(configModeGroups[group]["headers"]) do
            header.inConfigMode = true
            header:SetAttribute("startingIndex", 1 - header:GetNumChildren())
        end
    end

    if configModeGroups[group]["container"] then
        UnregisterAttributeDriver(configModeGroups[group]["container"])
    end

    if configModeGroups[group]["enabled"] then
        ForceShowGroup(group)
    end
end

---------------------------------------------------------------------
-- disable config mode
---------------------------------------------------------------------
local function DisableConfigModeForGroup(group)
    for _, frame in pairs(configModeGroups[group]["children"]) do
        -- restore indicators
        for _, indicator in pairs(frame.indicators) do
            if indicator.enabled and indicator.DisableConfigMode then
                indicator:DisableConfigMode()
            end
        end

        -- restore unit
        UnregisterUnitWatch(frame)
        RegisterUnitWatch(frame)
        frame:SetAttribute("unit", frame.oldUnit)
        frame.oldUnit = nil
        frame.inConfigMode = nil
        frame:EnableMouse(true)
        frame:Hide()
    end

    if configModeGroups[group]["headers"] then
        for _, header in pairs(configModeGroups[group]["headers"]) do
            header.inConfigMode = nil
            header:SetAttribute("startingIndex", 1)
        end
    end

    if configModeGroups[group]["container"] then
        local container = configModeGroups[group]["container"]
        RegisterAttributeDriver(container, container.driverKey, container.driverValue)
    end
end

---------------------------------------------------------------------
-- toggle
---------------------------------------------------------------------
local function EnableConfigMode()
    UF.configModeEnabled = true
    for group, t in pairs(configModeGroups) do
        EnableConfigModeForGroup(group)
    end
end

local function DisableConfigMode()
    UF.configModeEnabled = false
    for group in pairs(configModeGroups) do
        DisableConfigModeForGroup(group)
    end
end

local function ToggleConfigMode(_, module, group)
    if InCombatLockdown() then return end
    if module and module ~= "UnitFrames" then return end

    if group then
        if UF.configModeEnabled then
            configModeGroups[group]["enabled"] = not configModeGroups[group]["enabled"]
            if configModeGroups[group]["enabled"] then
                ForceShowGroup(group)
            else
                ForceHideGroup(group)
            end
        end
    else
        UF.configModeEnabled = not UF.configModeEnabled

        if UF.configModeEnabled then
            UF:RegisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
            EnableConfigMode()
        else
            UF:UnregisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
            DisableConfigMode()
        end
    end
end
AF.RegisterCallback("BFI_ConfigMode", ToggleConfigMode)