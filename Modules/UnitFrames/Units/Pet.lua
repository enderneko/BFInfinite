---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

local pet
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    "combatIcon",
    "levelText",
    "targetCounter",
    "raidIcon",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreatePet()
    local name = "BFI_Pet"
    pet = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    pet:SetAttribute("unit", "pet")

    -- mover
    AF.CreateMover(pet, L["Unit Frames"], _G.PET)

    -- config mode
    UF.AddToConfigMode("pet", pet)

    -- pixel perfect
    -- AF.AddToPixelUpdater(pet)

    -- indicators
    UF.CreateIndicators(pet, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePet(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "pet" then return end

    local config = UF.config.pet

    if not config.enabled then
        if pet then
            UF.DisableIndicators(pet)
            UnregisterUnitWatch(pet)
            pet:Hide()
        end
        return
    end

    if not pet then
        CreatePet()
    end

    -- setup
    UF.SetupUnitFrame(pet, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(pet)
end
BFI.RegisterCallback("UpdateModules", "UF_Pet", UpdatePet)