local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local focus
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
local function CreateFocus()
    local name = "BFIUF_Focus"
    focus = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    focus:SetAttribute("unit", "focus")

    -- mover
    AW.CreateMover(focus, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(focus)

    -- indicators
    UF.CreateIndicators(focus, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateFocus(module, which)
    if module and module ~= "UnitFrame" then return end
    if which and which ~= "focus" then return end

    local config = UF.config.focus

    if not config.enabled then
        UF.DisableIndicators(focus)
        UnregisterUnitWatch(focus)
        return
    end

    -- mover
    AW.UpdateMoverSave(focus, config.general.position)

    -- size
    AW.SetSize(focus, config.general.width, config.general.height)

    -- position
    if config.general.anchorTo then
        AW.LoadPosition(focus, config.general.position)
    else
        AW.LoadPosition(focus, config.general.position)
    end

    -- out of range alpha
    focus.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(focus, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(focus, indicators, config)

    RegisterUnitWatch(focus)
end
BFI.RegisterCallback("UpdateModules", "UF_Focus", UpdateFocus)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitFocus()
    CreateFocus()
    UpdateFocus()
end
BFI.RegisterCallback("InitModules", "UF_Focus", InitFocus)