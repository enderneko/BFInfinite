---@class BFI
local BFI = select(2, ...)
---@class Tooltip
local T = BFI.Tooltip
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    enabled = true,
    position = {"BOTTOMRIGHT", -10, 10},
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