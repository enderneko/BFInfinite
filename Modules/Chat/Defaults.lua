---@class BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.Chat
local U = BFI.utils

local defaults = {
    enabled = true,
    position = {"BOTTOMLEFT", 20, 20},
    width = 400,
    height = 200,
}

BFI.RegisterCallback("UpdateConfigs", "Chat", function(t)
    if not t["chat"] then
        t["chat"] = U.Copy(defaults)
    end
    C.config = t["chat"]
end)

function C.GetDefaults()
    return U.Copy(defaults)
end