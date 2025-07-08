---@class BFI
local BFI = select(2, ...)
---@class General
local G = BFI.General
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    gameMenuScale = 0.8,
}

AF.RegisterCallback("BFI_UpdateGeneral", function(_, t)
    if not t["general"] then
        t["general"] = AF.Copy(defaults)
    end
    G.config = t["general"]
end)

function G.GetDefaults()
    return AF.Copy(defaults)
end