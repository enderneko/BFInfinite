---@class BFI
local BFI = select(2, ...)
---@class UIWidgets
local UI = BFI.UIWidgets
local AW = BFI.AW
local U = BFI.utils

local defaults = {
    powerBarWidget = {
        scale = 0.8,
        position = {"TOP", 0, -70},
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