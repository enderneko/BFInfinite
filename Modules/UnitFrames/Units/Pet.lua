---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.M_UnitFrames

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
    local name = "BFIUF_Pet"
    pet = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    pet:SetAttribute("unit", "pet")

    -- mover
    AW.CreateMover(pet, "UnitFrames", name)

    -- pixel perfect
    AW.AddToPixelUpdater(pet)

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
            UnregisterAttributeDriver(pet, "state-visibility")
        end
        return
    end

    if not pet then
        CreatePet()
    end

    -- setup
    UF.SetupUnitButton(pet, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(pet, "state-visibility", "[petbattle] hide; [nopet] hide; show")
end
BFI.RegisterCallback("UpdateModules", "UF_Pet", UpdatePet)