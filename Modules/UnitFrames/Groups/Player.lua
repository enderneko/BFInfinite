local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local player
local indicators = {
    "healthBar",
    "powerBar",
    "nameText",
    "healthText",
    "powerText",
    "portrait",
    "castBar",
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

    -- mover
    AW.UpdateMoverSave(player, config.general.position)

    -- size & point
    AW.SetSize(player, config.general.width, config.general.height)
    AW.LoadPosition(player, config.general.position)

    -- color
    AW.StylizeFrame(player, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.LoadConfigForIndicators(player, indicators, config)

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