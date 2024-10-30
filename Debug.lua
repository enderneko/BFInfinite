---@class BFI
local BFI = select(2, ...)
---@class AbstractFramework
local AF = _G.AbstractFramework

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
        return true
    end
end

--@debug@
BFI.RegisterCallback("UpdateConfigs", "Debug", function(tbl, name, ...)
    print(AF.WrapTextInColor("UpdateConfigs:", "sand"), name, ...)
end, 1)

-- BFI.RegisterCallback("InitModules", "Debug", function(name, ...)
--     print(AF.WrapTextInColor("InitModules:", "orange"), name, ...)
-- end)

BFI.RegisterCallback("UpdateModules", "Debug", function(name, ...)
    print(AF.WrapTextInColor("UpdateModules:", "orange"), name, ...)
end, 1)
--@end-debug@