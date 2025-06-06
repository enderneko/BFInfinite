---@class BFI
local BFI = select(2, ...)
---@class DisableBlizzard
local DB = BFI.DisableBlizzard
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    player = true,
    target = true,
    focus = true,
    party = true,
    raid = true,
    boss = true,
    -- arena = true, -- TODO:
    manager = true,
    castBar = true,
    actionBars = true,
    auras = true,
}

AF.RegisterCallback("BFI_UpdateConfigs", function(_, t)
    if not t["BFI_DisableBlizzard"] then
        t["BFI_DisableBlizzard"] = AF.Copy(defaults)
    end
    DB.config = t["BFI_DisableBlizzard"]
end)

function DB.GetDefaults()
    return AF.Copy(defaults)
end