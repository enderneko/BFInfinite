local _, BFI = ...
local AW = BFI.AW

--@debug@
local debugMode = true
--@end-debug@

function BFI.Debug(arg, ...)
    if not debugMode then return end
    if type(arg) == "string" or type(arg) == "number" then
        print(arg, ...)
    elseif type(arg) == "function" then
        arg(...)
    elseif arg == nil then
        return debugMode
    end
end

--@debug@
BFI.RegisterCallback("InitConfigs", "Debug", function(tbl, name, ...)
    print(AW.WrapTextInColor("InitConfigs:", "sand"), name, ...)
end)

BFI.RegisterCallback("InitModules", "Debug", function(name, ...)
    print(AW.WrapTextInColor("InitModules:", "orange"), name, ...)
end)

BFI.RegisterCallback("UpdateModules", "Debug", function(name, ...)
    print(AW.WrapTextInColor("UpdateModules:", "orange"), name, ...)
end)
--@end-debug@