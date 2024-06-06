local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local focustarget
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateFocusTarget()
    local name = "BFIUF_FocusTarget"
    focustarget = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    focustarget:SetAttribute("unit", "focustarget")
    focustarget._refreshOnUpdate = true
    focustarget._updateOnUnitTargetChanged = "focus"

    -- mover
    AW.CreateMover(focustarget, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(focustarget)

    -- indicators
    UF.CreateIndicators(focustarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateFocusTarget(module, which)
    if module and module ~= "UnitFrame" then return end
    if which and which ~= "focustarget" then return end

    local config = UF.config.focustarget

    if not config.enabled then
        UF.DisableIndicators(focustarget)
        UnregisterUnitWatch(focustarget)
        return
    end

    -- mover
    AW.UpdateMoverSave(focustarget, config.general.position)

    -- tooltip
    UF.SetupTooltip(focustarget, config.general.tooltip)

    -- size
    AW.SetSize(focustarget, config.general.width, config.general.height)

    -- position
    if config.general.anchorTo then
        AW.LoadPosition(focustarget, config.general.position)
    else
        AW.LoadPosition(focustarget, config.general.position)
    end

    -- out of range alpha
    focustarget.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(focustarget, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(focustarget, indicators, config)

    RegisterUnitWatch(focustarget)
end
BFI.RegisterCallback("UpdateModules", "UF_FocusTarget", UpdateFocusTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitFocusTarget()
    CreateFocusTarget()
    UpdateFocusTarget()
end
BFI.RegisterCallback("InitModules", "UF_FocusTarget", InitFocusTarget)