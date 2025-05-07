---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

--@debug@
BFI.debugMode = true
--@end-debug@

function BFI.Debug(arg, ...)
    if not BFI.debugMode then return end
    AF.Debug(arg, ...)
end

--@debug@
AF.RegisterCallback("BFI_UpdateConfigs", function(_, tbl, name, ...)
    BFI.Debug(AF.WrapTextInColor("BFI_UpdateConfigs:", "sand"), name, ...)
end, "high")

AF.RegisterCallback("BFI_UpdateModules", function(_, name, ...)
    BFI.Debug(AF.WrapTextInColor("BFI_UpdateModules:", "orange"), name, ...)
end, "high")
--@end-debug@