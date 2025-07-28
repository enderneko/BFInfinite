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
    },
    priorities = {
        [980] = 1,
        [32390] = 2,
        [316099] = 3,
        [48181] = 4,
    },
    colors = {
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["auras"] then
        t["auras"] = AF.Copy(defaults)
    end
    A.config = t["auras"]
end, "high")

function A.GetDefaults(which)
    if which then
        return AF.Copy(defaults[which])
    end
    return AF.Copy(defaults)
end