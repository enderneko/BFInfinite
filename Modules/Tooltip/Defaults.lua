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
        height = 4,
        text = {
            enabled = true,
            font = {"BFI", 12, "none", true},
            useAsianUnits = false,
        },
    },
    -- factionIcon = {
    --     enabled = true,
    --     position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -2, 2},
    --     size = 50,
    --     alpha = 0.4,
    -- },
    lines = {
        {type = "name", enabled = true, showServer = true, showTitle = true},
        {type = "guild", enabled = true, showRankName = true, showRankIndex = true},
        {type = "npc_subtitle", enabled = true},
        {type = "level_race", enabled = true, showGender = true},
        {type = "spec", enabled = true},
        {type = "npc_faction", enabled = true},
        {type = "npc_pvp", enabled = true},
        {type = "mythic_plus_rating", enabled = true, showBestRunLevel = true},
        {type = "target", enabled = true},
        {type = "targeted_by", enabled = true, includeSelf = true, enChars = 5, nonEnChars = 2},
        {type = "mount", enabled = true, showIfOutOfCombat = true},
        {type = "item_level", enabled = true},
    },
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