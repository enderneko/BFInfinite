---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local spellFrame

---------------------------------------------------------------------
-- SpecFrame
---------------------------------------------------------------------
local function StyleSpecFrame()
    local specFrame = spellFrame.SpecFrame
    S.RemoveBackground(specFrame)
end

---------------------------------------------------------------------
-- TalentsFrame
---------------------------------------------------------------------
local function StyleTalentsFrame()
    local talentsFrame = spellFrame.TalentsFrame
    -- S.RemoveBackground(talentsFrame)
    talentsFrame.BlackBG:SetAlpha(0)
    talentsFrame.BottomBar:SetAlpha(0)
    talentsFrame.Background:SetAlpha(0.5)
end

---------------------------------------------------------------------
-- SpellBookFrame
---------------------------------------------------------------------
local function StyleSpellBookFrame()
    local spellBookFrame = spellFrame.SpellBookFrame
    S.RemoveBackground(spellBookFrame)
    spellBookFrame.TopBar:SetAlpha(0)
    S.StyleTabSystem(spellBookFrame.CategoryTabSystem, true)
    S.StyleEditBox(spellBookFrame.SearchBox, -4)

    local button = spellBookFrame.AssistedCombatRotationSpellFrame.Button
    S.StyleSpellItemButton(button)
    button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    spellFrame = _G.PlayerSpellsFrame

    S.StyleTitledFrame(spellFrame)
    S.StyleTabSystem(spellFrame.TabSystem)
    S.StyleTitledFrame(_G.HeroTalentsSelectionDialog)

    StyleSpecFrame()
    StyleTalentsFrame()
    StyleSpellBookFrame()
end
-- AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)
AF.RegisterAddonLoaded("Blizzard_PlayerSpells", StyleBlizzard)