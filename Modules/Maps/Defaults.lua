---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Maps
local M = BFI.Maps

local defaults = {
    minimap = {
        enabled = true,
        position = {"BOTTOM", -410, 10},
        width = 150,
        height = 150,
        expansionButton = {
            enabled = true,
            position = {"BOTTOMLEFT", -2, -2},
            scale = 1,
            width = 35,
            height = 35,
        },
        trackingButton = {
            enabled = true,
            position = {"BOTTOMRIGHT", 0, 0},
            width = 20,
            height = 20,
        },
        mailFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", -20, 0},
            width = 20,
            height = 20,
        },
        craftingOrderFrame = {
            enabled = true,
            position = {"BOTTOMRIGHT", 0, 20},
            width = 20,
            height = 20,
        },
        zoneText = {
            enabled = true,
            position = {"TOPLEFT", 0, 0},
            length = 0.75,
            font = {"BFI 1", 12, "none", true},
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
            fadeOut = true,
        },
        calendar = {
            enabled = true,
            position = {"RIGHT", 0, 0},
            width = 19,
            height = 18,
        },

        dungeonDifficulty = {
            enabled = true,
            position = {"TOPRIGHT", 0, 0},
            width = 50,
            height = 50,
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