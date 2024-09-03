---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local B = BFI.Blizzard

local defaults = {
    disableBlizzard = {
        player = true,
        target = true,
        focus = true,
        party = true,
        raid = true,
        manager = true,
    },
}

BFI.RegisterCallback("UpdateConfigs", "Blizzard", function(t)
    if not t["blizzard"] then
        t["blizzard"] = U.Copy(defaults)
    end
    B.config = t["blizzard"]
end)

function B.GetDefaults()
    return U.Copy(defaults)
end