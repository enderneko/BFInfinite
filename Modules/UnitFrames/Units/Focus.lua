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
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "focus" then return end

    local config = UF.config.focus

    if not config.enabled then
        UF.DisableIndicators(focus)
        UnregisterUnitWatch(focus)
        return
    end

    -- setup
    UF.SetupUnitButton(focus, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
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