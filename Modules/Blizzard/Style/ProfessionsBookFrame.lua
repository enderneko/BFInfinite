---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local professionFrame

---------------------------------------------------------------------
-- style
---------------------------------------------------------------------
local function CreateBGs(frame, isSecondary)
    local bgLeft = AF.CreateTexture(frame, nil, nil, "BACKGROUND")
    frame.bgLeft = bgLeft
    if isSecondary then
        AF.SetPoint(bgLeft, "TOPLEFT", 0, 7)
        AF.SetPoint(bgLeft, "BOTTOMLEFT", 0, -7)
    else
        AF.SetPoint(bgLeft, "TOPLEFT")
        AF.SetPoint(bgLeft, "BOTTOMLEFT")
    end
    AF.SetWidth(bgLeft, 2)

    local bgRight = AF.CreateGradientTexture(frame, "HORIZONTAL", AF.GetColorTable("background2", 0.5), AF.GetColorTable("background2", 0), nil, "BACKGROUND")
    frame.bgRight = bgRight
    AF.SetPoint(bgRight, "TOPLEFT", bgLeft, "TOPRIGHT", 1, 0)
    AF.SetPoint(bgRight, "RIGHT")
    AF.SetPoint(bgRight, "BOTTOM", bgLeft)
end

local function UpdateGeneralStyle(frame)
    frame.professionName:SetTextColor(AF.GetColorRGB("BFI"))
    frame.missingHeader:SetTextColor(AF.GetColorRGB("BFI"))
    frame.missingText:SetTextColor(AF.GetColorRGB("white"))

    S.StyleSpellItemButton(frame.SpellButton1)
    S.StyleSpellItemButton(frame.SpellButton2)

    _G[frame.SpellButton1:GetName() .. "NameFrame"]:Hide()
    _G[frame.SpellButton2:GetName() .. "NameFrame"]:Hide()

    local function UpdateFlash(button)
        button.Flash:SetTexture(AF.GetTexture("IconBorder"))
        button.Flash:SetVertexColor(AF.GetColorRGB("yellow", 0.25))
        button.Flash:SetAllPoints()
    end
    UpdateFlash(frame.SpellButton1)
    UpdateFlash(frame.SpellButton2)
end

local function StylePrimaryProfession(frame)
    UpdateGeneralStyle(frame)
    CreateBGs(frame)

    -- icon
    _G[frame:GetName() .. "IconBorder"]:Hide()
    S.StyleIcon(frame.icon, true)
    AF.ClearPoints(frame.icon)
    AF.SetPoint(frame.icon, "LEFT", 10, 0)

    -- bar
    frame.statusBar:ClearAllPoints()
    frame.statusBar:SetPoint("LEFT", frame.professionName)
    frame.statusBar:SetPoint("BOTTOM", 0, 2)

    -- rank
    frame.rank:ClearAllPoints()
    frame.rank:SetPoint("BOTTOMLEFT", frame.statusBar, "TOPLEFT", 0, 3)
end

local function StyleSecondaryProfession(frame)
    frame.professionName:SetFontObject("QuestFont_Large")
    UpdateGeneralStyle(frame)
    CreateBGs(frame, true)

    -- name
    frame.professionName:ClearAllPoints()
    frame.professionName:SetPoint("TOPLEFT", 10, 3)

    -- rank
    frame.rank:ClearAllPoints()
    frame.rank:SetPoint("TOPLEFT", frame.professionName, "BOTTOMLEFT", 0, -3)

    -- bar
    frame.statusBar:ClearAllPoints()
    frame.statusBar:SetPoint("TOPLEFT", frame.rank, "BOTTOMLEFT", 0, -3)

    -- missingHeader
    frame.missingHeader:ClearAllPoints()
    frame.missingHeader:SetPoint("LEFT", 10, 0)
end

---------------------------------------------------------------------
-- hooks
---------------------------------------------------------------------
local function UpdateProfession(frame, index)
    -- profession icon
    if frame.icon then
        frame.icon:SetBlendMode("DISABLE")
        if index then
            frame.icon:SetAlpha(1)
            frame.icon:SetDesaturated(false)
        else
            frame.icon:SetAlpha(0.75)
            frame.icon:SetDesaturated(true)
        end
    end

    -- unlearn button
    if frame.UnlearnButton then
        frame.UnlearnButton:ClearAllPoints()
        frame.UnlearnButton:SetPoint("BOTTOMRIGHT", frame.icon)
    end

    -- status bar and rank text
    S.StyleStatusBar(frame.statusBar)
    if frame.icon then
        -- frame.statusBar:SetPoint("BOTTOMLEFT")
        frame.rank:ClearAllPoints()
        frame.rank:SetPoint("BOTTOMLEFT", frame.statusBar, "TOPLEFT", 0, 2)
    end

    -- bgLeft
    frame.bgLeft:SetColor(index and "BFI" or "disabled")

    --? spell buttons
    frame.SpellButton1:GetHighlightTexture():SetColorTexture(AF.GetColorRGB("white", 0.25))
    frame.SpellButton2:GetHighlightTexture():SetColorTexture(AF.GetColorRGB("white", 0.25))
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function DoStyle()
    professionFrame = _G.ProfessionsBookFrame
    _G.ProfessionsBookFrameTutorialButton:Hide()

    S.StyleTitledFrame(professionFrame)

    S.RemoveNineSliceAndBackground(professionFrame.Inset)
    _G.ProfessionsBookPage1:Hide()
    _G.ProfessionsBookPage2:Hide()

    StylePrimaryProfession(_G.PrimaryProfession1)
    StylePrimaryProfession(_G.PrimaryProfession2)
    StyleSecondaryProfession(_G.SecondaryProfession1)
    StyleSecondaryProfession(_G.SecondaryProfession2)
    StyleSecondaryProfession(_G.SecondaryProfession3)

    hooksecurefunc("FormatProfession", UpdateProfession)
end

local function DoStyleNonCombat()
    _G.PrimaryProfession1:ClearAllPoints()
    _G.PrimaryProfession1:SetPoint("TOP", professionFrame.Inset, 0, -40)
end

local function StyleBlizzard()
    DoStyle()
    if InCombatLockdown() then
        S:RegisterEventOnce("PLAYER_REGEN_ENABLED", DoStyleNonCombat)
    else
        DoStyleNonCombat()
    end
end
AF.RegisterAddonLoaded("Blizzard_ProfessionsBook", StyleBlizzard)