local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local target
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffsByMe", "HARMFUL", "castByMe"},
    {"auras", "debuffsByOthers", "HARMFUL", "castByOthers"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTarget()
    local name = "BFIUF_Target"
    target = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    target:SetAttribute("unit", "target")
    target._updateOnPlayerTargetChanged = true

    -- mover
    AW.CreateMover(target, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(target)

    -- indicators
    UF.CreateIndicators(target, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTarget(module, which)
    if module and module ~= "UnitFrame" then return end
    if which and which ~= "target" then return end

    local config = UF.config.target

    if not config.enabled then
        UF.DisableIndicators(target)
        UnregisterUnitWatch(target)
        return
    end

    -- mover
    AW.UpdateMoverSave(target, config.general.position)

    -- size & point
    AW.SetSize(target, config.general.width, config.general.height)
    AW.LoadPosition(target, config.general.position)

    -- out of range alpha
    target.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(target, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(target, indicators, config)

    RegisterUnitWatch(target)
end
BFI.RegisterCallback("UpdateModules", "UF_Target", UpdateTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitTarget()
    CreateTarget()
    UpdateTarget()
end
BFI.RegisterCallback("InitModules", "UF_Target", InitTarget)