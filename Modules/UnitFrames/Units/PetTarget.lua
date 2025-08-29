---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.modules.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local pettarget
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
local function CreatePetTarget()
    local name = "BFI_PetTarget"
    pettarget = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    pettarget:SetAttribute("unit", "pettarget")
    pettarget._refreshOnUpdate = true
    pettarget._updateOnUnitTargetChanged = "pet"
    pettarget.skipDataCache = true -- BFI.vars.guids/names

    -- mover
    AF.CreateMover(pettarget, "BFI: " .. L["Unit Frames"], L["Pet Target"])

    -- preview rect
    UF.CreatePreviewRect(pettarget)

    -- config mode
    UF.AddToConfigMode("pettarget", pettarget)

    -- indicators
    UF.CreateIndicators(pettarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePetTarget(_, module, which, skipIndicatorUpdates)
    if module and module ~= "unitFrames" then return end
    if which and which ~= "pettarget" then return end

    local config = UF.config.pettarget

    if not config.general.enabled then
        if pettarget then
            UF.DisableIndicators(pettarget)
            UnregisterUnitWatch(pettarget)
            pettarget:Hide()
        end
        return
    end

    if not pettarget then
        CreatePetTarget()
    end

    -- setup
    UF.SetupUnitFrame(pettarget, config, indicators, skipIndicatorUpdates)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(pettarget)
end
AF.RegisterCallback("BFI_UpdateModule", UpdatePetTarget)