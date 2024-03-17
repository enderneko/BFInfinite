local addonName, BFI = ...
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local AB = BFI.M_AB

local LAB = BFI.libs.LAB



---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitStanceBar()
    for i in pairs(ACTION_BAR_LIST) do
        AB.CreateBar(i)
    end
    UpdateMainBars()

    LAB.RegisterCallback(AB, "OnFlyoutSpells", ActionBar_FlyoutSpells)
    -- LAB.RegisterCallback(AB, "OnFlyoutUpdate", ActionBar_FlyoutUpdate)
    -- LAB.RegisterCallback(AB, "OnFlyoutButtonCreated", ActionBar_FlyoutCreated)

    AB.RegisterEvent("UPDATE_BINDINGS", AssignBindings)

    if BFI.vars.isRetail then
        AB.RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
        AB.RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
    end

    if BFI.vars.isRetail and C_PetBattles.IsInBattle() then
        RemoveBindings()
    else
        AssignBindings()
    end
end
BFI.RegisterCallback("InitModules", "StanceBar", InitMainBars)