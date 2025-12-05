---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local map = _G.WorldMapFrame
local quest = _G.QuestMapFrame

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    F.Hide(map.BorderFrame.Tutorial)
    S.StyleTitledFrame(map.BorderFrame)
    AF.SetFrameLevel(map.BorderFrame.BFIBg, -1, map)
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)