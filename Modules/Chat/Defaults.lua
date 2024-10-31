---@class BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.Chat
local U = BFI.utils

local defaults = {
    enabled = true,
    position = {"BOTTOMLEFT", 20, 20},
    editBoxPosition = {"BOTTOMLEFT", "TOPLEFT", -3, 3},
    width = 400,
    height = 200,
    font = {"BFI", 13, "none", true},
    tabFont = {"BFI", 13, "none", true},
    fading = true,
    fadeTime = 120,
    maxLines = 100,
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