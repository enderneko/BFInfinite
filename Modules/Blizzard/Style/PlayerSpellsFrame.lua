---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework


---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard(_, which)
    if type(which) == "string" and which ~= "playerspells" then return end
    if not _G.PlayerSpellsFrame then return end

    S.StyleTitledFrame(_G.PlayerSpellsFrame)
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)
AF.RegisterAddonLoaded("Blizzard_PlayerSpells", StyleBlizzard)