---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.UnitFrames

local player
local indicators = {
    "healthBar",
    "powerBar",
    "extraManaBar",
    "classPowerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
    "staggerBar",
    "combatIcon",
    "leaderIcon",
    "leaderText",
    "levelText",
    "targetCounter",
    "statusTimer",
    "statusIcon",
    "raidIcon",
    "readyCheckIcon",
    "roleIcon",
    "factionIcon",
    "restingIndicator",
    "targetHighlight",
    "mouseoverHighlight",
    "threatGlow",
    "incDmgHealText",
    {"auras", "buffs", "HELPFUL"},
    {"auras", "debuffs", "HARMFUL"},
}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreatePlayer()
    local name = "BFIUF_Player"
    player = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    player:SetAttribute("unit", "player")

    -- mover
    AW.CreateMover(player, "UnitFrames", name)

    -- pixel perfect
    -- AW.AddToPixelUpdater(player)

    -- indicators
    player.hasCastBarTicks = true
    player.hasLatency = true
    UF.CreateIndicators(player, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePlayer(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "player" then return end

    local config = UF.config.player

    if not config.enabled then
        if player then
            UF.DisableIndicators(player)
            UnregisterAttributeDriver(player, "state-visibility")
            player:Hide()
        end
        return
    end

    if not player then
        CreatePlayer()
    end

    -- setup
    UF.SetupUnitFrame(player, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(player, "state-visibility", "[petbattle] hide; show")
end
BFI.RegisterCallback("UpdateModules", "UF_Player", UpdatePlayer)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitPlayer()
--     CreatePlayer()
--     UpdatePlayer()
-- end
-- BFI.RegisterCallback("InitModules", "UF_Player", InitPlayer)