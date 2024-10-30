---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

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
    AF.CreateMover(focus, L["Unit Frames"], L["Focus"])

    -- config mode
    UF.AddToConfigMode("focus", focus)

    -- pixel perfect
    -- AF.AddToPixelUpdater(focus)

    -- indicators
    UF.CreateIndicators(focus, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateFocus(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "focus" then return end

    local config = UF.config.focus

    if not config.enabled then
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
    UF.SetupUnitFrame(focus, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(focus)
end
BFI.RegisterCallback("UpdateModules", "UF_Focus", UpdateFocus)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitFocus()
--     CreateFocus()
--     UpdateFocus()
-- end
-- BFI.RegisterCallback("InitModules", "UF_Focus", InitFocus)