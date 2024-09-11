---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AW = BFI.AW
local UF = BFI.UnitFrames

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
    AW.CreateMover(pettarget, L["Unit Frames"], L["Pet Target"])

    -- config mode
    UF.AddToConfigMode("pettarget", pettarget)

    -- pixel perfect
    -- AW.AddToPixelUpdater(pettarget)

    -- indicators
    UF.CreateIndicators(pettarget, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePetTarget(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "pettarget" then return end

    local config = UF.config.pettarget

    if not config.enabled then
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
    UF.SetupUnitFrame(pettarget, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(pettarget)
end
BFI.RegisterCallback("UpdateModules", "UF_PetTarget", UpdatePetTarget)