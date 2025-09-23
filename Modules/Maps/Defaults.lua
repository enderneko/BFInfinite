---@class BFI
local BFI = select(2, ...)
---@class Maps
local M = BFI.modules.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    minimap = {
        general = {
            enabled = true,
            position = {"BOTTOM", -410, 1},
            size = 150,
        },
        expansionButton = {
            enabled = true,
            position = {"BOTTOMLEFT", "BOTTOMLEFT", -2, -2},
            size = 35,
        },
        trackingButton = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 20},
            scale = 1,
        },
        mailFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 40},
            scale = 1,
        },
        craftingOrderFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 60},
            scale = 1,
        },
        calendar = {
            enabled = true,
            position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0},
            size = 19,
        },
        zoneText = {
            enabled = true,
            position = {"TOPLEFT", "TOPLEFT", 1, -1},
            length = 0.75,
            font = {"BFI", 12, "outline", false},
            alwaysShow = false,
        },
        coordinates = {
            enabled = true,
            relativeTo = "zoneText", -- "zoneText" or "minimap"
            position = {"TOPLEFT", "BOTTOMLEFT", 0, -3},
            font = {"BFI", 12, "outline", false},
            color = AF.GetColorTable("gray"),
            format = "1decimal", -- "integer", "1decimal", "2decimals"
            alwaysShow = false,
        },
        ping = {
            enabled = true,
            position = {"BOTTOM", "BOTTOM", 0, 20},
            font = {"BFI", 12, "outline", false},
        },
        addonButtonTray = {
            enabled = true,
            position = {"LEFT", "LEFT", -1, 0},
            size = 20,
            numPerLine = 4,
            arrangement = "left_to_right_then_up",
            spacing = 3,
            anchor = "TOPLEFT",
            bgColor = AF.GetColorTable("black", 0.27),
            alwaysShow = false,
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
            types = {
                normal = {text = "N", color = AF.GetColorTable("orange")},
                heroic = {text = "H", color = AF.GetColorTable("orangered")},
                mythic = {text = "M", color = AF.GetColorTable("firebrick")},
                mythicPlus = {text = "M+", color = AF.GetColorTable("firebrick")},
                raidFinder = {text = "RF", color = AF.GetColorTable("yellow")},
                raidStory = {text = "RS", color = AF.GetColorTable("vividblue")},
                timewalking = {text = "TW", color = AF.GetColorTable("skyblue")},
                scenario = {text = "SC", color = AF.GetColorTable("vividblue")},
                delve = {text = "DV", color = AF.GetColorTable("gold")},
                followerDungeon = {text = "FD", color = AF.GetColorTable("orange")},
                event = {text = "E", color = AF.GetColorTable("vividblue")},
                pvp = {text = "PvP", color = AF.GetColorTable("lightred")},
            },
        },
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["maps"] then
        t["maps"] = AF.Copy(defaults)
    end
    M.config = t["maps"]
end)

function M.GetDefaults()
    return AF.Copy(defaults)
end

function M.ResetToDefaults(which, sub)
    if not which then
        for map, t in next, defaults do
            for k, v in next, t do
                wipe(M.config[map][k])
                AF.Merge(M.config[map][k], v)
            end
        end
    elseif not sub then
        for k, v in next, defaults[which] do
            wipe(M.config[which][k])
            AF.Merge(M.config[which][k], v)
        end
    else
        wipe(M.config[which][sub])
        AF.Merge(M.config[which][sub], defaults[which][sub])
    end
end
