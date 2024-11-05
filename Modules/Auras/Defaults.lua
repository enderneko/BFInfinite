---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Auras
local A = BFI.Auras

local defaults = {
    enabled = true,
    buffs = {
        position = {"CENTER", 0, 0},
        width = 30,
        height = 30,
        orientation = "right_to_left_then_bottom",
        spacingH = 5,
        spacingV = 10,
        sortMethod = "INDEX",
        sortDirection = "+",
        maxWraps = 2, -- rows
        wrapAfter = 20, -- buttons per row
    },
    debuffs = {
        position = {"TOPRIGHT", -5, -5},
        width = 25,
        height = 25,
    },
}

BFI.RegisterCallback("UpdateConfigs", "Auras", function(t)
    if not t["auras"] then
        t["auras"] = U.Copy(defaults)
    end
    A.config = t["auras"]
end)

function A.GetDefaults()
    return U.Copy(defaults)
end