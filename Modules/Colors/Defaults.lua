local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local C = BFI.M_C

---------------------------------------------------------------------
-- shared colors
---------------------------------------------------------------------
local defaults = {
    debuffs = {
        debuff_curse = {0.6, 0, 1},
        debuff_disease = {0.6, 0.4, 0},
        debuff_magic = {0.2, 0.6, 1},
        debuff_poison = {0, 0.6, 0},
        debuff_bleed = {1, 0.2, 0.6},
        debuff_none = {0.8, 0, 0},
    },

    empowerStages = {
        empowerstage1 = {1, 0.26, 0.2},
        empowerstage2 = {1, 0.8, 0.26},
        empowerstage3 = {1, 1, 0.26},
        empowerstage4 = {0.66, 1, 0.4},
    }
}

BFI.RegisterCallback("InitConfigs", "Colors", function(t)
    if not t["colors"] then
        t["colors"] = U.Copy(defaults)
    end
    for _, st in pairs(t["colors"]) do
        AW.AddColors(st)
    end
end)

function C.ResetDefaults(which)
    if not which then
        BFI.vars.currentConfigTable["colors"] = U.Copy(defaults)
    else
        BFI.vars.currentConfigTable["colors"][which] = U.Copy(defaults[which])
    end

    for _, t in pairs(BFI.vars.currentConfigTable["colors"]) do
        AW.AddColors(t)
    end

    -- TODO: fire
end