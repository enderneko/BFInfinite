---@class BFI
local BFI = select(2, ...)
---@class Auras
local A = BFI.modules.Auras
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

AF.RegisterCallback("BFI_UpdateConfig", function(_, module)
    if module then return end -- init

    if not BFIConfig.auras then
        BFIConfig.auras = AF.Copy(defaults)
    end
    A.config = BFIConfig.auras
end, "high")

function A.GetDefaults(which)
    if which then
        return AF.Copy(defaults[which])
    end
    return AF.Copy(defaults)
end

function A.ResetToDefaults(which)
    if not which then
        for k, v in next, BFIConfig["auras"] do
            wipe(BFIConfig["auras"][k])
            AF.Merge(BFIConfig["auras"][k], defaults[k])
        end
    else
        wipe(BFIConfig["auras"][which])
        AF.Merge(BFIConfig["auras"][which], defaults[which])
    end
end