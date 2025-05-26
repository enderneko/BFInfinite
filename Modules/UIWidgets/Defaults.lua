---@class BFI
local BFI = select(2, ...)
---@class UIWidgets
local UI = BFI.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    microMenu = {
        enabled = true,
        position = {"BOTTOMLEFT", 1, 183},
        alpha = 0,
        width = 20,
        height = 25,
        spacing = 2,
        buttonsPerRow = 11,
    },
    powerBarWidget = {
        enabled = true,
        position = {"TOP", 0, -70},
        scale = 0.8,
    },
    altPowerBar = {
        position = {"BOTTOM", 0, 211},
        useBlizzardStyle = false,
        scale = 0.75,
        width = 170,
        height = 19,
        texture = "BFI",
        color = AF.GetColorTable(BFI.name),
        bgColor = AF.GetColorTable("background"),
        borderColor = AF.GetColorTable("border"),
        texts = {
            font = {"BFI", 12, "none", true},
            color = AF.GetColorTable("white"),
            leftFormat = "[name]",
            centerFormat = "",
            rightFormat = "[current] / [total]",
        },
    },
    buffTimer = {
        position = {"BOTTOM", 0, 209},
        scale = 0.75,
    },
    vehicleSeats = {
        position = {"BOTTOMLEFT", 381, 183},
        scale = 0.7,
    },
    queueStatus = {
        position = {"BOTTOM", -469, 152},
        scale = 0.7,
    },
    durability = {
        position = {"BOTTOM", -244, 153},
        scale = 0.7,
    },
    battlenetToast = {
        position = {"BOTTOMLEFT", 1, 238},
        scale = 1,
    },
    quickJoinToast = {
        enabled = true,
        position = {"BOTTOMLEFT", 1, 212},
        font = {"BFI", 12, "none", true},
    },
}

AF.RegisterCallback("BFI_UpdateConfigs", function(_, t)
    if not t["uiWidgets"] then
        t["uiWidgets"] = AF.Copy(defaults)
    end
    UI.config = t["uiWidgets"]
end)

function UI.GetDefaults()
    return AF.Copy(defaults)
end