---@class BFI
local BFI = select(2, ...)
---@class Tooltip
local T = BFI.Tooltip
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    enabled = true,
    position = {"BOTTOMRIGHT", -10, 10},
    cursorAnchor = {
        type = "ANCHOR_CURSOR_LEFT", -- false, "ANCHOR_CURSOR", "ANCHOR_CURSOR_RIGHT"
        x = -5,
        y = 0,
    },
    combatModifierKey = false,
    healthBar = {
        enabled = true,
        text = {
            enabled = true,
            font = {"BFI", 12, "none", true},
            useAsianUnits = false,
        }
    },
    lines = {
        {type = "name", showServer = true, showTitle = true},
        {type = "guild", showRankName = true, showRankIndex = true},
        {type = "npc_subtitle"},
        {type = "level_race", showGender = true},
        {type = "spec"},
        {type = "npc_faction"},
        {type = "npc_pvp"},
    }
}

AF.RegisterCallback("BFI_UpdateConfigs", function(_, t)
    if not t["tooltip"] then
        t["tooltip"] = AF.Copy(defaults)
    end
    T.config = t["tooltip"]
end)

function T.GetDefaults()
    return AF.Copy(defaults)
end