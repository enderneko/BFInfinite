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
    "portrait",
    "castBar",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffsByMe", "HARMFUL", "mine"},
    {"auras", "debuffsByOthers", "HARMFUL", "others", true},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTargetTarget()
    local name = "BFIUF_Target"
    targettarget = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    targettarget:SetAttribute("unit", "targettarget")
    targettarget._refreshOnUpdate = true
    targettarget._updateOnPlayerTargetChanged = true
    targettarget._updateOnUnitTargetChanged = "target"

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
    if module and module ~= "UnitFrame" then return end
    if which and which ~= "targettarget" then return end

    local config = UF.config.targettarget

    if not config.enabled then
        UF.DisableIndicators(targettarget)
        UnregisterUnitWatch(targettarget)
        return
    end

    -- mover
    AW.UpdateMoverSave(targettarget, config.general.position)

    -- size
    AW.SetSize(targettarget, config.general.width, config.general.height)

    -- position
    if config.general.anchorTo then
        AW.LoadPosition(targettarget, config.general.position)
    else
        AW.LoadPosition(targettarget, config.general.position)
    end

    -- out of range alpha
    targettarget.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(targettarget, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(targettarget, indicators, config)

    RegisterUnitWatch(targettarget)
end
BFI.RegisterCallback("UpdateModules", "UF_Target", UpdateTargetTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitTargetTarget()
    CreateTargetTarget()
    UpdateTargetTarget()
end
BFI.RegisterCallback("InitModules", "UF_TargetTarget", InitTargetTarget)