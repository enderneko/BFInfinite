---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.modules.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

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
    AF.CreateMover(target, "BFI: " .. L["Unit Frames"], _G.TARGET)

    -- preview rect
    UF.CreatePreviewRect(target)

    -- config mode
    UF.AddToConfigMode("target", target)

    -- indicators
    UF.CreateIndicators(target, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTarget(_, module, which, skipIndicatorUpdates)
    if module and module ~= "unitFrames" then return end
    if which and which ~= "target" then return end

    local config = UF.config.target

    if not config.general.enabled then
        if target then
            UF.DisableIndicators(target)
            UnregisterUnitWatch(target)
            UF.RemoveFromConfigMode("target")
            target:Hide()
        end
        return
    end

    if not target then
        CreateTarget()
    end

    -- setup
    UF.SetupUnitFrame(target, config, indicators, skipIndicatorUpdates)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(target)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateTarget)