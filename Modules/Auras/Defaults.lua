---@class BFI
local BFI = select(2, ...)
---@class Auras
local A = BFI.Auras
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    enabled = true,
    buffs = {
        position = {"TOPRIGHT", -4, -4},
        width = 26,
        height = 26,
        orientation = "right_to_left_then_bottom",
        spacingX = 4,
        spacingY = 6,
        separateOwn = 0,
        sortMethod = "TIME",
        sortDirection = "-",
        maxWraps = 1, -- rows
        wrapAfter = 25, -- buttons per row
        stack = {
            enabled = true,
            position = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            font = {"Expressway", 11, "outline", false},
            color = AF.GetColorTable("white"),
        },
        duration = {
            enabled = true,
            position = {"BOTTOM", "BOTTOM", 1, -3},
            font = {"Expressway", 10, "outline", false},
            color = {
                AF.GetColorTable("white"),
                AF.GetColorTable("aura_seconds"),
            },
            colorBy = "expiring",
            showSecondsUnit = true,
        },

    },
    debuffs = {
        position = {"TOPRIGHT", -4, -40},
        width = 26,
        height = 26,
        orientation = "right_to_left_then_bottom",
        spacingX = 4,
        spacingY = 6,
        separateOwn = 0,
        sortMethod = "TIME",
        sortDirection = "-",
        maxWraps = 1, -- rows
        wrapAfter = 25, -- buttons per row
        stack = {
            enabled = true,
            position = {"TOPRIGHT", "TOPRIGHT", 0, 3},
            font = {"Expressway", 11, "outline", false},
            color = AF.GetColorTable("white"),
        },
        duration = {
            enabled = true,
            position = {"BOTTOM", "BOTTOM", 1, -3},
            font = {"Expressway", 10, "outline", false},
            color = {
                AF.GetColorTable("white"),
                AF.GetColorTable("aura_seconds"),
            },
            colorBy = "expiring",
            showSecondsUnit = true,
        },
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["auras"] then
        t["auras"] = AF.Copy(defaults)
    end
    A.config = t["auras"]
end)

function A.GetDefaults()
    return AF.Copy(defaults)
end