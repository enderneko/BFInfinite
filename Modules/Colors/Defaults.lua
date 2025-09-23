---@class BFI
local BFI = select(2, ...)
---@class Colors
local C = BFI.modules.Colors
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- shared colors
---------------------------------------------------------------------
local defaults = {
    auras = {
        aura_curse = {0.6, 0, 1},
        aura_disease = {0.6, 0.4, 0},
        aura_magic = {0.2, 0.6, 1},
        aura_poison = {0, 0.6, 0},
        aura_bleed = {1, 0.2, 0.6},
        aura_none = {0.8, 0, 0},
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

    casts = {
        cast_normal = {0.5, 0.5, 0.5, 0.9},
        cast_failed = {0.7, 0.3, 0.3, 0.9},
        cast_succeeded = {0.3, 0.7, 0.3, 0.9},
        cast_interruptible = {0.7, 0.7, 0.3, 0.9},
        cast_uninterruptible = {0.4, 0.4, 0.4, 0.9},
        cast_uninterruptible_texture = {1, 0.2, 0.2, 0.6},
        cast_spark = {0.9, 0.9, 0.9, 0.6},
        cast_tick = {1, 1, 0, 0.5},
        cast_latency = {1, 0, 0, 0.4},
    },

    spells = {
        -- [8936] = {0.29, 0.86, 0.68, 1},
    },
}

AF.RegisterCallback("BFI_UpdateConfig", function(_, module)
    if module then return end -- init

    if not BFIConfig.colors then
        BFIConfig.colors = AF.Copy(defaults)
    end
    -- add / overwrite colors
    for _, st in next, BFIConfig.colors do
        AF.AddColors(st)
    end
    C.config = BFIConfig.colors
end)

function C.GetDefaults()
    return AF.Copy(defaults)
end

function C.ResetToDefaults(which)
    if not which then
        for k, v in next, BFIConfig["colors"] do
            wipe(BFIConfig["colors"][k])
            AF.Merge(BFIConfig["colors"][k], defaults[k])
            AF.AddColors(BFIConfig["colors"][k])
        end
    else
        wipe(BFIConfig["colors"][which])
        AF.Merge(BFIConfig["colors"][which], defaults[which])
        AF.AddColors(BFIConfig["colors"][which])
    end
end