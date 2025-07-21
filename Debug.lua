---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

-- AFConfig.debug.BFInfinite needs to be true to enable debug events
AF.DEBUG_EVENTS["BFI_UpdateConfig"] = "skyblue"
AF.DEBUG_EVENTS["BFI_UpdateProfile"] = "orange"
AF.DEBUG_EVENTS["BFI_UpdateColor"] = "gray"
AF.DEBUG_EVENTS["BFI_IncorrectAnchor"] = "red"
-- AF.DEBUG_EVENTS["BFI_UpdateLocale"] = "orange"
AF.DEBUG_EVENTS["BFI_UpdateModule"] = "sand"
AF.DEBUG_EVENTS["BFI_ShowOptionsPanel"] = "lightblue"