local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local player
local indicators = {
    "healthBar",
    "powerBar",
    "extraManaBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
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
    AW.AddToPixelUpdater(player)

    -- indicators
    player.hasCastBarTicks = true
    player.hasLatency = true
    UF.CreateIndicators(player, indicators)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePlayer(module, which)
    if module and module ~= "UnitFrame" then return end
    if which and which ~= "player" then return end

    local config = UF.config.player

    if not config.enabled then
        UF.DisableIndicators(player)
        UnregisterAttributeDriver(player, "state-visibility")
        return
    end

    -- setup
    UF.SetupUnitButton(player, config, indicators)

    -- visibility NOTE: show must invoke after settings applied
    RegisterAttributeDriver(player, "state-visibility", "[petbattle] hide; show")
end
BFI.RegisterCallback("UpdateModules", "UF_Player", UpdatePlayer)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitPlayer()
    CreatePlayer()
    UpdatePlayer()
end
BFI.RegisterCallback("InitModules", "UF_Player", InitPlayer)