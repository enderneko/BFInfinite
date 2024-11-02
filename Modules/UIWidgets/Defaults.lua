---@class BFI
local BFI = select(2, ...)
---@class UIWidgets
local UI = BFI.UIWidgets
---@class AbstractFramework
local AF = _G.AbstractFramework
local U = BFI.utils

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
        enabled = true,
        position = {"BOTTOM", 0, 200},
        scale = 1,
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

BFI.RegisterCallback("UpdateConfigs", "UIWidgets", function(t)
    if not t["uiWidgets"] then
        t["uiWidgets"] = U.Copy(defaults)
    end
    UI.config = t["uiWidgets"]
end)

function UI.GetDefaults()
    return U.Copy(defaults)
end