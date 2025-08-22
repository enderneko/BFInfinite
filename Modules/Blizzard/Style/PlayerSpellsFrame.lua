---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework


---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    if not _G.PlayerSpellsFrame then return end

    S.StyleTitledFrame(_G.PlayerSpellsFrame)
end
-- AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)
AF.RegisterAddonLoaded("Blizzard_PlayerSpells", StyleBlizzard)