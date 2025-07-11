---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

-- AFConfig.debug.BFInfinite needs to be true to enable debug events
AF.DEBUG_EVENTS["BFI_UpdateConfigs"] = "orange"
AF.DEBUG_EVENTS["BFI_UpdateModules"] = "sand"
AF.DEBUG_EVENTS["BFI_ShowOptionsPanel"] = "lightblue"