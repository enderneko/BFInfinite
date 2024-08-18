---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local C = BFI.Colors

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

    threat = {
        threat_low = {0.059, 0.588, 0.902},
        threat_medium = {1, 1, 0},
        threat_high = {1, 0, 0},
        threat_offtank = {0.392, 1, 0.392},
    },

    unit = {
        FRIENDLY = AW.GetColorTable("FRIENDLY"),
        HOSTILE = AW.GetColorTable("HOSTILE"),
        NEUTRAL = AW.GetColorTable("NEUTRAL"),
        OFFLINE = AW.GetColorTable("UNKNOWN"),
        CHARMED = {0.5, 0, 1},
        TAP_DENIED = {0.5, 0.5, 0.5},
    },

    spells = {
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