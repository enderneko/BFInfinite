local _, BFI = ...
local AW = BFI.AW
local UF = BFI.M_UF

local target

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTarget()
    local name = "BFI_UnitFrame_Target"
    target = CreateFrame("Button", name, AW.UIParent, "BFIUnitButtonTemplate")
    target:SetAttribute("unit", "target")
    target._updateOnPlayerTargetChanged = true

    -- mover
    AW.CreateMover(target, "UnitFrames", name, function(p,x,y) print(name..":", p, x, y) end)

    -- indicators
    target.indicators.healthBar = UF.CreateStatusBar(target)
    target.indicators.powerBar = UF.CreateStatusBar(target)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateTarget(module)
    if module and module ~= "UnitFrame" then return end

    local config = UF.config.target

    -- size & point
    AW.SetSize(target, config.general.width, config.general.height)
    AW.LoadPosition(target, config.general.position)
    
    -- texture

    -- color
    AW.StylizeFrame(target, config.general.bgColor, config.general.borderColor)
    
    -- indicators
    for n, i in pairs(target.indicators) do
        i:LoadConfig(config.indicators[n], true)
    end
    
    RegisterUnitWatch(target)
end
BFI.RegisterCallback("UpdateModules", "UF_Target", UpdateTarget)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitTarget()
    CreateTarget()
    UpdateTarget()
end
BFI.RegisterCallback("InitModules", "UF_Target", InitTarget)