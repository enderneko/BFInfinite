---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local boss
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
    "raidIcon",
    "targetHighlight",
    "mouseoverHighlight",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateBoss()
    local name = "BFI_Boss"
    boss = CreateFrame("Frame", name, AF.UIParent, "SecureFrameTemplate")
    UF.AddToConfigMode("boss.container", boss)

    for i = 1, 8 do
        boss[i] = CreateFrame("Button", name .. i, boss, "BFIUnitButtonTemplate")
        boss[i]:SetAttribute("unit", "boss" .. i)
        UF.AddToConfigMode("boss", boss[i])
        UF.CreateIndicators(boss[i], indicators)
        RegisterUnitWatch(boss[i])
    end

    boss.driverKey = "state-visibility"
    boss.driverValue = "[@boss1,exists] show;hide"

    -- mover
    AF.CreateMover(boss, "BFI: " .. L["Unit Frames"], _G.BOSS)

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(boss, nil, true)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateBoss(_, module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "boss" then return end

    local config = UF.config.boss

    if not config.enabled then
        if boss then
            UnregisterAttributeDriver(boss)
            for i = 1, 8 do
                UnregisterUnitWatch(boss[i])
                UF.DisableIndicators(boss[i])
            end
            boss:Hide()
        end
        return
    end

    if not boss then
        CreateBoss()
    end

    -- setup
    UF.SetupUnitGroup(boss, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(boss, boss.driverKey, boss.driverValue)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateBoss)