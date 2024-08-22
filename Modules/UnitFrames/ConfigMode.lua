---@class BFI
local BFI = select(2, ...)
---@class UnitFrame
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- config mode random functions
---------------------------------------------------------------------
function UF.UnitHealth()
    return random(20, 90)
end

function UF.UnitHealthMax()
    return 100
end

function UF.UnitClassBase()
    return CLASS_SORT_ORDER[random(1, 13)]
end

-- function UF.

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
        -- force show frame as player
        frame.inConfigMode = true
        frame.oldUnit = frame.unit
        frame:SetAttribute("unit", "player")
        UnregisterUnitWatch(frame)
        RegisterUnitWatch(frame, true)
        frame:EnableMouse(false)
        frame:Show()

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
        -- restore unit
        UnregisterUnitWatch(frame)
        RegisterUnitWatch(frame)
        frame:SetAttribute("unit", frame.oldUnit)
        frame.oldUnit = nil
        frame.inConfigMode = nil
        frame:EnableMouse(true)
        frame:Hide()

        -- restore indicators
        for _, indicator in pairs(frame.indicators) do
            if indicator.enabled and indicator.DisableConfigMode then
                indicator:DisableConfigMode()
            end
        end
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

function DisableConfigMode(group)
    UF.configModeEnabled = nil
    UF:UnregisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
    if group and configModeGroups[group] then
        DisableConfigModeForGroup(group)
    else
        for group in pairs(configModeGroups) do
            DisableConfigModeForGroup(group)
        end
    end
end

local function ToggleConfigMode(module, which)
    if InCombatLockdown() then return end
    if module and module ~= "UnitFrames" then return end
    if UF.configModeEnabled then
        DisableConfigMode(which)
    else
        EnableConfigMode(which)
    end
end
BFI.RegisterCallback("ConfigMode", "UnitFrames", ToggleConfigMode)