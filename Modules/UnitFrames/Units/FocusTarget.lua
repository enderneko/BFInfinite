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
    "levelText",
    "targetCounter",
    "portrait",
    "castBar",
    "targetHighlight",
    "mouseoverHighlight",
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

    -- setup
    UF.SetupUnitButton(focustarget, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
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