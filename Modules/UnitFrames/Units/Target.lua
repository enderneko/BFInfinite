---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local UF = BFI.UnitFrames

local target
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    "combatIcon",
    "leaderIcon",
    "leaderText",
    "levelText",
    "targetCounter",
    "rangeText",
    "statusTimer",
    "statusIcon",
    "raidIcon",
    "roleIcon",
    "factionIcon",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL", true},
    -- {"auras", "debuffsByMe", "HARMFUL", "castByMe"},
    -- {"auras", "debuffsByOthers", "HARMFUL", "castByOthers"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTarget()
    local name = "BFI_Target"
    target = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    target:SetAttribute("unit", "target")
    target._updateOnPlayerTargetChanged = true
    target.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AW.CreateMover(target, L["Unit Frames"], _G.TARGET)

    -- config mode
    UF.AddToConfigMode("target", target)

    -- pixel perfect
    -- AW.AddToPixelUpdater(target)

    -- indicators
    UF.CreateIndicators(target, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTarget(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "target" then return end

    local config = UF.config.target

    if not config.enabled then
        if target then
            UF.DisableIndicators(target)
            UnregisterUnitWatch(target)
            UF.RemoveFromConfigMode("target")
            target.enabled = false -- for mover
            target:Hide()
        end
        return
    end

    if not target then
        CreateTarget()
    end

    target.enabled = true -- for mover

    -- setup
    UF.SetupUnitFrame(target, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(target)
end
BFI.RegisterCallback("UpdateModules", "UF_Target", UpdateTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitTarget()
--     CreateTarget()
--     UpdateTarget()
-- end
-- BFI.RegisterCallback("InitModules", "UF_Target", InitTarget)