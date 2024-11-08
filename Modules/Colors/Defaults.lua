---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local C = BFI.Colors
---@class AbstractFramework
local AF = _G.AbstractFramework

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
        FRIENDLY = AF.GetColorTable("FRIENDLY"),
        HOSTILE = AF.GetColorTable("HOSTILE"),
        NEUTRAL = AF.GetColorTable("NEUTRAL"),
        OFFLINE = AF.GetColorTable("UNKNOWN"),
        CHARMED = {0.5, 0, 1},
        TAP_DENIED = {0.5, 0.5, 0.5},
    },

    spells = {
        -- [8936] = {0.29, 0.86, 0.68, 1},
    },
}

AF.RegisterCallback("UpdateConfigs", "Colors", function(t)
    if not t["colors"] then
        t["colors"] = U.Copy(defaults)
    end
    for _, st in pairs(t["colors"]) do
        AF.AddColors(st)
    end
end, 1)

function C.ResetDefaults(which)
    if not which then
        BFI.vars.currentConfigTable["colors"] = U.Copy(defaults)
    else
        BFI.vars.currentConfigTable["colors"][which] = U.Copy(defaults[which])
    end

    for _, t in pairs(BFI.vars.currentConfigTable["colors"]) do
        AF.AddColors(t)
    end

    -- TODO: fire
end

---------------------------------------------------------------------
-- GetAuraTypeColor
---------------------------------------------------------------------
function C.GetAuraTypeColor(auraType)
    if auraType == "Curse" then
        return AF.GetColorRGB("debuff_curse")
    elseif auraType == "Disease" then
        return AF.GetColorRGB("debuff_disease")
    elseif auraType == "Magic" then
        return AF.GetColorRGB("debuff_magic")
    elseif auraType == "Poison" then
        return AF.GetColorRGB("debuff_disease")
    elseif auraType == "Bleed" then
        return AF.GetColorRGB("debuff_bleed")
    elseif auraType == "None" then
        return AF.GetColorRGB("debuff_none")
    elseif auraType == "castByMe" then
        return AF.GetColorRGB("aura_castbyme")
    elseif auraType == "dispellable" then
        return AF.GetColorRGB("aura_dispellable")
    else
        return AF.GetColorRGB("black")
    end
end