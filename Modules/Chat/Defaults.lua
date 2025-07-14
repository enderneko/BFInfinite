---@class BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.Chat
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    enabled = true,
    position = {"BOTTOMLEFT", 1, 1},
    editBoxPosition = {"BOTTOMLEFT", "TOPLEFT", -3, 3},
    width = 470,
    height = 178,
    font = {"BFI", 13, "none", true},
    tabFont = {"BFI", 13, "none", true},
    fading = true,
    fadeTime = 120,
    maxLines = 100,
    bgColor = AF.GetColorTable("background"),
    borderColor = AF.GetColorTable("border"),
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["chat"] then
        t["chat"] = AF.Copy(defaults)
    end
    C.config = t["chat"]
end)

function C.GetDefaults()
    return AF.Copy(defaults)
end