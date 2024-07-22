local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

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
    local name = "BFIUF_TargetTarget"
    targettarget = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    targettarget:SetAttribute("unit", "targettarget")
    targettarget._refreshOnUpdate = true
    targettarget._updateOnPlayerTargetChanged = true
    targettarget._updateOnUnitTargetChanged = "target"
    targettarget.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AW.CreateMover(targettarget, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(targettarget)

    -- indicators
    UF.CreateIndicators(targettarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTargetTarget(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "targettarget" then return end

    local config = UF.config.targettarget

    if not config.enabled then
        if targettarget then
            UF.DisableIndicators(targettarget)
            UnregisterUnitWatch(targettarget)
        end
        return
    end

    if not targettarget then
        CreateTargetTarget()
    end

    -- setup
    UF.SetupUnitButton(targettarget, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(targettarget)
end
BFI.RegisterCallback("UpdateModules", "UF_TargetTarget", UpdateTargetTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitTargetTarget()
--     CreateTargetTarget()
--     UpdateTargetTarget()
-- end
-- BFI.RegisterCallback("InitModules", "UF_TargetTarget", InitTargetTarget)