---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW

---------------------------------------------------------------------
-- colors preset for modules, no persistence requirement
---------------------------------------------------------------------
local uf_colors = {
    uf = {0.135, 0.135, 0.135}, -- unitframe foreground
    uf_loss = {0.6, 0, 0}, -- unitframe background
    uf_power = {0.7, 0.7, 0.7}, -- unitframe background

    target_highlight = AW.GetColorTable("accent", 0.6),
    mouseover_highlight = {1, 1, 1, 0.6},

    cast_normal = {0.4, 0.4, 0.4, 0.9},
    cast_failed = {0.7, 0.3, 0.3, 0.9},
    cast_succeeded = {0.3, 0.7, 0.3, 0.9},
    cast_interruptible = {0.7, 0.7, 0.3, 0.9},
    cast_uninterruptible = {0.4, 0.4, 0.4, 0.9},
    cast_uninterruptible_texture = {1, 0.2, 0.2, 0.6},
    cast_spark = {0.9, 0.9, 0.9, 0.6},
    cast_tick = {1, 1, 0, 0.3},
    cast_latency = {1, 0, 0, 0.4},

    shield = {1, 1, 1, 1},
    absorb = {1, 0.1, 0.1, 1},
    heal_prediction = {1, 1, 1, 0.4},

    aura_percent = {1, 1, 0},
    aura_seconds = {1, 0.3, 0.3},

    marker_1 = {1, 0.9, 0},
    marker_2 = {1, 0.5, 0},
    marker_3 = {0.98, 0.47, 0.98},
    marker_4 = {0.34, 0.94, 0.31},
    marker_5 = {0.84, 0.92, 0.97},
    marker_6 = {0, 0.64, 1},
    marker_7 = {1, 0.33, 0.22},
    marker_8 = {1, 1, 0.99},

    range_5 = {1, 1, 1},
    range_20 = {0.055, 0.875, 0.825},
    range_30 = {0.035, 0.865, 0},
    range_40 = {1.0, 0.82, 0},
    range_out = {0.9, 0.055, 0.075, 1},

    swing = {1, 1, 0.1, 1},
    damage = {1, 0.1, 0.1, 1},
    heal = {0.1, 1, 0.1, 1},

    guild = {0.251, 1, 0.251},

    exp_normal_start = {0.34, 0.39, 1, 1},
    exp_normal_end = {0.78, 0.38, 1, 1},
    exp_complete = {1, 0.59, 0, 1},
    exp_incomplete = {1, 0.82, 0.31, 1},
    exp_rested = {0.31, 0.56, 1, 0.35},

    honor = {1, 0.3, 0.14, 1},
}
AW.AddColors(uf_colors)