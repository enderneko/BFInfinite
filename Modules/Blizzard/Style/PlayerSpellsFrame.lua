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

    -- activate button
    for specContentFrame in specFrame.SpecContentFramePool:EnumerateActive() do
        S.StyleButton(specContentFrame.ActivateButton)
    end
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

    S.StyleDropdownButton(talentsFrame.LoadSystem.Dropdown)
    S.StyleEditBox(talentsFrame.SearchBox, -4, -2, nil, 2)
    S.StyleButton(talentsFrame.ApplyButton, "BFI", "BFI")
    S.StyleButton(talentsFrame.InspectCopyButton, "BFI", "BFI")

    local searchPreview = talentsFrame.SearchPreviewContainer
    AF.ClearPoints(searchPreview)
    AF.SetPoint(searchPreview, "TOPLEFT", talentsFrame.SearchBox, "BOTTOMLEFT", -4, 1)
    AF.SetPoint(searchPreview, "TOPRIGHT", talentsFrame.SearchBox, "BOTTOMRIGHT", 0, 1)
    S.StyleSpellSearchPreviewContainer(searchPreview)
end

---------------------------------------------------------------------
-- SpellBookFrame
---------------------------------------------------------------------
local function StyleSpellBookFrame()
    local spellBookFrame = spellFrame.SpellBookFrame
    S.RemoveBackground(spellBookFrame)
    spellBookFrame.TopBar:SetAlpha(0)

    -- tab
    local tabSystem = spellBookFrame.CategoryTabSystem
    S.StyleTabSystem(tabSystem, true)
    AF.ClearPoints(tabSystem)
    AF.SetPoint(tabSystem, "BOTTOMLEFT", spellBookFrame.PagedSpellsFrame, "TOPLEFT", 10, 10)

    -- search
    local searchBox = spellBookFrame.SearchBox
    S.StyleEditBox(searchBox, -4)
    AF.ClearPoints(searchBox)
    AF.SetPoint(searchBox, "BOTTOMLEFT", tabSystem, "BOTTOMRIGHT", 14, 0)
    AF.SetHeight(searchBox, 27)

    local searchPreview = spellBookFrame.SearchPreviewContainer
    AF.ClearPoints(searchPreview)
    AF.SetPoint(searchPreview, "TOPLEFT", searchBox, "BOTTOMLEFT", -4, -1)
    AF.SetPoint(searchPreview, "TOPRIGHT", searchBox, "BOTTOMRIGHT", 0, -1)
    S.StyleSpellSearchPreviewContainer(searchPreview)

    -- setting
    hooksecurefunc(spellBookFrame, "UpdateAttic", function()
        AF.ClearPoints(spellBookFrame.SettingsDropdown)
        AF.SetPoint(spellBookFrame.SettingsDropdown, "LEFT", searchBox, "RIGHT", 5, 0)
    end)

    -- assisted
    local assistedFrame = spellBookFrame.AssistedCombatRotationSpellFrame
    S.RemoveTextures(assistedFrame)
    AF.ClearPoints(assistedFrame)
    AF.SetPoint(assistedFrame, "BOTTOMRIGHT", spellBookFrame.PagedSpellsFrame, "TOPRIGHT", -10, 10)

    local button = assistedFrame.Button
    S.StyleSpellItemButton(button)
    button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))

    -- page button
    local prevButton = spellBookFrame.PagedSpellsFrame.PagingControls.PrevPageButton
    S.StyleIconButton(prevButton, nil, AF.GetIcon("ArrowLeft2"), 16)
    AF.SetSize(prevButton, 23, 23)

    local nextButton = spellBookFrame.PagedSpellsFrame.PagingControls.NextPageButton
    S.StyleButton(nextButton)
    S.StyleIconButton(nextButton, nil, AF.GetIcon("ArrowRight2"), 16)
    AF.SetSize(nextButton, 23, 23)

    hooksecurefunc(spellBookFrame.PagedSpellsFrame.PagingControls, "LayoutChildren", function()
        local pageText = spellBookFrame.PagedSpellsFrame.PagingControls.PageText
        AF.ClearPoints(prevButton)
        AF.SetPoint(prevButton, "RIGHT", pageText, "LEFT", -7, 0)
        AF.ClearPoints(nextButton)
        AF.SetPoint(nextButton, "LEFT", pageText, "RIGHT", 7, 0)
    end)

    -- help
    spellBookFrame.HelpPlateButton:Hide()
end

local function StyleHeroTalentsSelectionDialog()
    local dialog = _G.HeroTalentsSelectionDialog
    S.StyleTitledFrame(dialog)

    -- activate button
    hooksecurefunc(dialog, "ShowDialog", function()
        for specContentFrame in dialog.SpecContentFramePool:EnumerateActive() do
            S.StyleButton(specContentFrame.ActivateButton)
            S.StyleButton(specContentFrame.ApplyChangesButton)
        end
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    spellFrame = _G.PlayerSpellsFrame

    S.StyleTitledFrame(spellFrame)
    S.StyleTabSystem(spellFrame.TabSystem)

    StyleSpecFrame()
    StyleTalentsFrame()
    StyleSpellBookFrame()
    StyleHeroTalentsSelectionDialog()
end
-- AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)
AF.RegisterAddonLoaded("Blizzard_PlayerSpells", StyleBlizzard)