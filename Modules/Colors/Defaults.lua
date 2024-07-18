local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local C = BFI.M_C

---------------------------------------------------------------------
-- shared colors
---------------------------------------------------------------------
local defaults = {
    auras = {
        debuff_curse = {0.6, 0, 1},
        debuff_disease = {0.6, 0.4, 0},
        debuff_magic = {0.2, 0.6, 1},
        debuff_poison = {0, 0.6, 0},
        debuff_bleed = {1, 0.2, 0.6},
        debuff_none = {0.8, 0, 0},
        aura_castbyme = {0, 0.8, 0},
        aura_dispellable = {1, 1, 0},
    },

    empowerStages = {
        empowerstage1 = {1, 0.26, 0.2},
        empowerstage2 = {1, 0.8, 0.26},
        empowerstage3 = {1, 1, 0.26},
        empowerstage4 = {0.66, 1, 0.4},
    },

    ranges = {
        range_5 = {1, 1, 1},
        range_20 = {0.055, 0.875, 0.825},
        range_30 = {0.035, 0.865, 0},
        range_40 = {1.0, 0.82, 0},
        range_out = {0.9, 0.055, 0.075, 1},
    },
}

BFI.RegisterCallback("UpdateConfigs", "Colors", function(t)
    if not t["colors"] then
        t["colors"] = U.Copy(defaults)
    end
    for _, st in pairs(t["colors"]) do
        AW.AddColors(st)
    end
end, 1)

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

---------------------------------------------------------------------
-- GetAuraTypeColor
---------------------------------------------------------------------
function C.GetAuraTypeColor(auraType)
    if auraType == "Curse" then
        return AW.GetColorRGB("debuff_curse")
    elseif auraType == "Disease" then
        return AW.GetColorRGB("debuff_disease")
    elseif auraType == "Magic" then
        return AW.GetColorRGB("debuff_magic")
    elseif auraType == "Poison" then
        return AW.GetColorRGB("debuff_disease")
    elseif auraType == "Bleed" then
        return AW.GetColorRGB("debuff_bleed")
    elseif auraType == "None" then
        return AW.GetColorRGB("debuff_none")
    elseif auraType == "castByMe" then
        return AW.GetColorRGB("aura_castbyme")
    elseif auraType == "dispellable" then
        return AW.GetColorRGB("aura_dispellable")
    else
        return AW.GetColorRGB("black")
    end
end