---@type BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.modules.Chat
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    enabled = true,
    position = {"BOTTOMLEFT", 1, 1},
    editBoxDockedPosition = "TOP",
    editBoxUndockedPosition = "BOTTOM",
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

function C.ResetToDefaults()
    wipe(C.config)
    AF.Merge(C.config, defaults)
end