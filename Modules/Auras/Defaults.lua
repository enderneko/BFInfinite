---@class BFI
local BFI = select(2, ...)
---@class Auras
local A = BFI.Auras
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- shared colors
---------------------------------------------------------------------
local defaults = {
    blacklist = {
        [8936] = true,
    },
    priorities = {
        [373862] = 1,
    },
    colors = {
        [373862] = {0, 1, 0, 1},
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["auras"] then
        t["auras"] = AF.Copy(defaults)
    end
    A.config = t["auras"]
end, "high")

function A.GetDefaults()
    return AF.Copy(defaults)
end