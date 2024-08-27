---@class BFI
local BFI = select(2, ...)
---@class UnitFrames
local UF = BFI.UnitFrames
local U = BFI.utils

---------------------------------------------------------------------
-- config mode random functions
---------------------------------------------------------------------
UF.UnitHealth = UnitHealth
function UF.CFG_UnitHealth()
    return random(20, 100)
end

UF.UnitHealthMax = UnitHealthMax
function UF.CFG_UnitHealthMax()
    return 100
end

UF.UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
function UF.CFG_UnitGetTotalAbsorbs()
    return random(0, 60)
end

-- UF.UnitClassBase = U.UnitClassBase
-- function UF.CFG_UnitClassBase()
--     -- return CLASS_SORT_ORDER[random(1, 13)]
--     return BFI.vars.playerClass
-- end

-- UF.UnitName = UnitName
-- function UF.CFG_UnitName(unit)
--     return U.UpperFirst(unit)
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

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local configModeGroups = {
    -- [group] = {
    --     ["container"] = frame,
    --     ["headers"] = {...},
    --     ["children"] = {...},
    -- }
}

BFI.configModeGroups = configModeGroups

function UF.AddToConfigMode(group, frame)
    local main, sub = strsplit(".", group)

    if not configModeGroups[main] then
        configModeGroups[main] = {}
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

local function EnableConfigModeForGroup(group)
    for i, frame in pairs(configModeGroups[group]["children"]) do
        frame.inConfigMode = true
        frame.oldUnit = frame.unit
        UnregisterUnitWatch(frame)
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

        -- force show frame as player
        frame:Show()
    end

    if configModeGroups[group]["headers"] then
        for _, header in pairs(configModeGroups[group]["headers"]) do
            header.inConfigMode = true
            header:SetAttribute("startingIndex", -4)
        end
    end

    if configModeGroups[group]["container"] then
        UnregisterAttributeDriver(configModeGroups[group]["container"])
        configModeGroups[group]["container"]:Show()
    end
end

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

local EnableConfigMode, DisableConfigMode

function EnableConfigMode(group)
    UF.configModeEnabled = true
    UF:RegisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
    if group then
        EnableConfigModeForGroup(group)
    else
        for group in pairs(configModeGroups) do
            EnableConfigModeForGroup(group)
        end
    end
end

function DisableConfigMode()
    UF.configModeEnabled = nil
    UF:UnregisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)

    for group in pairs(configModeGroups) do
        DisableConfigModeForGroup(group)
    end
end

local function ToggleConfigMode(module)
    if InCombatLockdown() then return end
    if module and module ~= "UnitFrames" then return end
    if UF.configModeEnabled then
        DisableConfigMode()
    else
        EnableConfigMode()
    end
end
BFI.RegisterCallback("ConfigMode", "UnitFrames", ToggleConfigMode)