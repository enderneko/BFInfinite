---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- colors preset for modules, no persistence requirement
---------------------------------------------------------------------
local uf_colors = {
    uf = {0.135, 0.135, 0.135, 1}, -- unitframe foreground
    uf_loss = {0.6, 0, 0, 1}, -- unitframe background
    uf_power = {0.7, 0.7, 0.7, 1}, -- unitframe background

    target_highlight = AF.GetColorTable("BFI", 0.6),
    mouseover_highlight = {1, 1, 1, 0.6},

    -- cast_background = {0.175, 0.175, 0.175, 1},

    shield = {1, 1, 1, 1},
    absorb = {1, 0.1, 0.1, 1},
    heal_prediction = {1, 1, 1, 0.4},

    aura_percent = {1, 1, 0},
    aura_seconds = {1, 0.3, 0.3},

    marker_1 = {1, 0.9, 0, 1},
    marker_2 = {1, 0.5, 0, 1},
    marker_3 = {0.98, 0.47, 0.98, 1},
    marker_4 = {0.34, 0.94, 0.31, 1},
    marker_5 = {0.84, 0.92, 0.97, 1},
    marker_6 = {0, 0.64, 1, 1},
    marker_7 = {1, 0.33, 0.22, 1},
    marker_8 = {1, 1, 0.99, 1},

    range_5 = {1, 1, 1, 1},
    range_20 = {0.055, 0.875, 0.825, 1},
    range_30 = {0.035, 0.865, 0, 1},
    range_40 = {1.0, 0.82, 0, 1},
    range_out = {0.9, 0.055, 0.075, 1},

    -- swing = {1, 1, 0.1, 1},
    damage = {1, 0.1, 0.1, 1},
    healing = {0.1, 1, 0.1, 1},

    exp_normal_start = {0.34, 0.39, 1, 1},
    exp_normal_end = {0.78, 0.38, 1, 1},
    exp_complete = {1, 0.59, 0, 1},
    exp_incomplete = {1, 0.82, 0.31, 1},
    exp_rested = {0.31, 0.56, 1, 0.35},

    honor_start = {0.95, 0.15, 0.07, 1},
    honor_end = {0.96, 0.69, 0.1, 1},

    button_highlight = {1, 1, 1, 0.25},
}
AF.AddColors(uf_colors)