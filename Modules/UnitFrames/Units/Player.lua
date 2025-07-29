---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

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
    local name = "BFI_Player"
    player = CreateFrame("Button", name, UF.Parent, "BFIUnitButtonTemplate")
    player:SetAttribute("unit", "player")

    -- mover
    AF.CreateMover(player, "BFI: " .. L["Unit Frames"], _G.PLAYER)

    -- preview rect
    UF.CreatePreviewRect(player)

    -- config mode
    UF.AddToConfigMode("player", player)

    -- indicators
    player.hasCastBarTicks = true
    player.hasLatency = true
    UF.CreateIndicators(player, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePlayer(_, module, which, skipIndicatorUpdate)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "player" then return end

    local config = UF.config.player

    if not config.general.enabled then
        if player then
            UF.DisableIndicators(player)
            UnregisterUnitWatch(player)
            player:Hide()
        end
        return
    end

    if not player then
        CreatePlayer()
    end

    -- setup
    UF.SetupUnitFrame(player, config, indicators, skipIndicatorUpdate)

    -- visibility NOTE: show must invoke after settings applied
    RegisterUnitWatch(player)
end
AF.RegisterCallback("BFI_UpdateModule", UpdatePlayer)