local _, BFI = ...
local AW = BFI.AW

---------------------------------------------------------------------
-- colors preset for modules
---------------------------------------------------------------------
local uf_colors = {
    uf = {0.125, 0.125, 0.125}, -- unitframe foreground
    uf_loss = {0.6, 0, 0}, -- unitframe background
    uf_power = {0.7, 0.7, 0.7}, -- unitframe background
    cast_normal = {0.4, 0.4, 0.4, 0.9},
    cast_failed = {0.7, 0.3, 0.3, 0.9},
    cast_succeeded = {0.3, 0.7, 0.3, 0.9},
    cast_uninterruptible = {1, 0, 0, 0.4},
    cast_spark = {0.9, 0.9, 0.9, 0.6},
    cast_tick = {1, 1, 0, 0.3},
    cast_latency = {1, 0, 0, 0.4},
    shield = {1, 1, 1, 1},
    absorb = {1, 0.1, 0.1, 1},
    heal_prediction = {1, 1, 1, 0.4},
}
AW.AddColors(uf_colors)