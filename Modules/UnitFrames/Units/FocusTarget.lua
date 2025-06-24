---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

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
    local name = "BFI_FocusTarget"
    focustarget = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    focustarget:SetAttribute("unit", "focustarget")
    focustarget._refreshOnUpdate = true
    focustarget._updateOnUnitTargetChanged = "focus"
    focustarget.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AF.CreateMover(focustarget, "BFI: " .. L["Unit Frames"], L["Focus Target"])

    -- config mode
    UF.AddToConfigMode("focustarget", focustarget)

    -- indicators
    UF.CreateIndicators(focustarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateFocusTarget(_, module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "focustarget" then return end

    local config = UF.config.focustarget

    if not config.enabled then
        if focustarget then
            UF.DisableIndicators(focustarget)
            UnregisterUnitWatch(focustarget)
            focustarget:Hide()
        end
        return
    end

    if not focustarget then
        CreateFocusTarget()
    end

    -- setup
    UF.SetupUnitFrame(focustarget, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(focustarget)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateFocusTarget)