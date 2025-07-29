---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local focus
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    "levelText",
    "targetCounter",
    "rangeText",
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
local function CreateFocus()
    local name = "BFI_Focus"
    focus = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    focus:SetAttribute("unit", "focus")

    focus.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AF.CreateMover(focus, "BFI: " .. L["Unit Frames"], L["Focus"])

    -- preview rect
    UF.CreatePreviewRect(focus)

    -- config mode
    UF.AddToConfigMode("focus", focus)

    -- indicators
    UF.CreateIndicators(focus, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateFocus(_, module, which, skipIndicatorUpdate)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "focus" then return end

    local config = UF.config.focus

    if not config.general.enabled then
        if focus then
            UF.DisableIndicators(focus)
            UnregisterUnitWatch(focus)
            focus:Hide()
        end
        return
    end

    if not focus then
        CreateFocus()
    end

    -- setup
    UF.SetupUnitFrame(focus, config, indicators, skipIndicatorUpdate)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(focus)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateFocus)