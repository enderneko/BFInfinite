---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class DisableBlizzard
local DB = BFI.DisableBlizzard
---@class AbstractFramework
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

BFI.RegisterCallback("UpdateConfigs", "DisableBlizzard", function(t)
    if not t["disableBlizzard"] then
        t["disableBlizzard"] = U.Copy(defaults)
    end
    DB.config = t["disableBlizzard"]
end)

function DB.GetDefaults()
    return U.Copy(defaults)
end