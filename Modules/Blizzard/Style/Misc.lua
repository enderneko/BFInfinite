---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)