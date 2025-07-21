---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local targettarget
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "levelText",
    "targetCounter",
    "portrait",
    "castBar",
    "raidIcon",
    "roleIcon",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTargetTarget()
    local name = "BFI_TargetTarget"
    targettarget = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    targettarget:SetAttribute("unit", "targettarget")
    targettarget._refreshOnUpdate = true
    targettarget._updateOnPlayerTargetChanged = true
    targettarget._updateOnUnitTargetChanged = "target"
    targettarget.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AF.CreateMover(targettarget, "BFI: " .. L["Unit Frames"], L["Target Target"])

    -- config mode
    UF.AddToConfigMode("targettarget", targettarget)

    -- indicators
    UF.CreateIndicators(targettarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTargetTarget(_, module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "targettarget" then return end

    local config = UF.config.targettarget

    if not config.enabled then
        if targettarget then
            UF.DisableIndicators(targettarget)
            UnregisterUnitWatch(targettarget)
            targettarget.enabled = false -- for mover
            targettarget:Hide()
        end
        return
    end

    if not targettarget then
        CreateTargetTarget()
    end

    targettarget.enabled = true -- for mover

    -- setup
    UF.SetupUnitFrame(targettarget, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(targettarget)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateTargetTarget)