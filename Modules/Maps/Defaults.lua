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
        },
        addonButtonHolder = {
            enabled = true,
            position = {"LEFT", "LEFT", -1, 0},
            width = 22,
            height = 22,
            numPerLine = 4,
            orientation = "left_to_right_then_bottom",
            spacing = 3,
            anchor = "TOPLEFT",
            bgColor = AF.GetColorTable("black", 0.27),
            fadeOut = true,
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
                mythicKeystone = {text = "M+", color = AF.GetColorTable("firebrick")},
                lookingForRaid = {text = "LFR", color = AF.GetColorTable("yellow")},
                timewalking = {text = "TW", color = AF.GetColorTable("skyblue")},
                event = {text = "E", color = AF.GetColorTable("vividblue")},
                scenario = {text = "SC", color = AF.GetColorTable("vividblue")},
                pvp = {text = "PvP", color = AF.GetColorTable("lightred")},
                delve = {text = "DV", color = AF.GetColorTable("gold")},
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
        wipe(M.config)
        AF.Merge(M.config, defaults)
    elseif not sub then
        wipe(M.config[which])
        AF.Merge(M.config[which], defaults[which])
    else
        wipe(M.config[which][sub])
        AF.Merge(M.config[which][sub], defaults[which][sub])
    end
end
