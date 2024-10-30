---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Maps
local M = BFI.Maps
---@class AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    minimap = {
        enabled = true,
        position = {"BOTTOM", -410, 1},
        width = 150,
        height = 150,
        expansionButton = {
            enabled = true,
            position = {"BOTTOMLEFT", "BOTTOMLEFT", -2, -2},
            scale = 1,
            width = 35,
            height = 35,
        },
        trackingButton = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0},
            width = 20,
            height = 20,
        },
        mailFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -20, 0},
            width = 20,
            height = 20,
        },
        craftingOrderFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 20},
            width = 20,
            height = 20,
        },
        zoneText = {
            enabled = true,
            position = {"TOPLEFT", "TOPLEFT", 1, -1},
            length = 0.75,
            font = {"BFI", 12, "outline", false},
        },
        addonButtonHolder = {
            enabled = true,
            position = {"LEFT", "LEFT", -1, 0},
            width = 22,
            height = 22,
            numPerLine = 3,
            orientation = "left_to_right",
            spacing = 3,
            anchor = "TOPLEFT",
            bgColor = AF.GetColorTable("black", 0.27),
            fadeOut = true,
        },
        calendar = {
            enabled = true,
            position = {"RIGHT", "RIGHT", 0, 0},
            width = 19,
            height = 18,
        },
        clock = {
            enabled = true,
            position = {"BOTTOM", "BOTTOM", 0, 0},
            font = {"Expressway", 12, "outline", false},
            color = AF.GetColorTable("white"),
        },
        instanceDifficulty = {
            enabled = true,
            position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
            font = {"Expressway", 12, "outline", false},
            normalColor = AF.GetColorTable("white"),
            guildColor = AF.GetColorTable("guild"),
            difficulties = {
                normal = {text = "N", color = AF.GetColorTable("orange")},
                heroic = {text = "H", color = AF.GetColorTable("orangered")},
                mythic = {text = "M", color = AF.GetColorTable("firebrick")},
                mythicKeystone = {text = "M+", color = AF.GetColorTable("firebrick")},
                lookingForRaid = {text = "LFR", color = AF.GetColorTable("yellow")},
                timewalking = {text = "TW", color = AF.GetColorTable("skyblue")},
                event = {text = "E", color = AF.GetColorTable("classicrose")},
                -- TODO: delves
            },
        },
    },
}

BFI.RegisterCallback("UpdateConfigs", "Maps", function(t)
    if not t["maps"] then
        t["maps"] = U.Copy(defaults)
    end
    M.config = t["maps"]
end)

function M.GetDefaults()
    return U.Copy(defaults)
end