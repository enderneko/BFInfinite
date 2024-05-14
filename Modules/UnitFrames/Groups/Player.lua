local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local player

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreatePlayer()
    local name = "BFI_UnitFrame_Player"
    player = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    player:SetAttribute("unit", "player")

    -- mover
    AW.CreateMover(player, "UnitFrames", name, function(p,x,y) print(name..":", p, x, y) end)

    -- indicators
    player.indicators.healthBar = UF.CreateStatusBar(player)
    player.indicators.powerBar = UF.CreateStatusBar(player)
    player.indicators.nameText = UF.CreateNameText(player)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdatePlayer(module)
    if module and module ~= "UnitFrame" then return end

    local config = UF.config.player

    -- size & point
    AW.SetSize(player, config.general.width, config.general.height)
    AW.LoadPosition(player, config.general.position)
    
    -- texture

    -- color
    AW.StylizeFrame(player, config.general.bgColor, config.general.borderColor)
    
    -- indicators
    for n, i in pairs(player.indicators) do
        i:LoadConfig(config.indicators[n], true)
    end
    
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