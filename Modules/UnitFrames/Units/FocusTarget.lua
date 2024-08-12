---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.M_UnitFrames

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
local function CreateFocusTarget()
    local name = "BFIUF_FocusTarget"
    focustarget = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    focustarget:SetAttribute("unit", "focustarget")
    focustarget._refreshOnUpdate = true
    focustarget._updateOnUnitTargetChanged = "focus"
    focustarget.skipDataCache = true -- BFI.vars.guids/names

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
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "focustarget" then return end

    local config = UF.config.focustarget

    if not config.enabled then
        if focustarget then
            UF.DisableIndicators(focustarget)
            UnregisterUnitWatch(focustarget)
        end
        return
    end

    if not focustarget then
        CreateFocusTarget()
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
-- local function InitFocusTarget()
--     CreateFocusTarget()
--     UpdateFocusTarget()
-- end
-- BFI.RegisterCallback("InitModules", "UF_FocusTarget", InitFocusTarget)