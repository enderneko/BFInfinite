---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local achievementFrame

---------------------------------------------------------------------
-- AchievementFrame
---------------------------------------------------------------------
local function StyleAchievementFrame()
    S.RemoveTextures(achievementFrame)

    -- bg
    local bg = AF.CreateBorderedFrame(achievementFrame)
    achievementFrame.BFIBg = bg
    bg:SetAllPoints(achievementFrame)
    AF.SetFrameLevel(bg)
    AF.RemoveFromPixelUpdater(bg)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", bg)

    -- close
    local closeButton = _G.AchievementFrameCloseButton
    S.StyleCloseButton(closeButton)

    -- header
    local header = AF.CreateBorderedFrame(achievementFrame, nil, nil, nil, "header", "border")
    achievementFrame.BFIHeader = header
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    AF.SetHeight(header, 20)
    -- AF.SetFrameLevel(header, 1)
    AF.RemoveFromPixelUpdater(header)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", header)

    header.tex = AF.CreateGradientTexture(header, "HORIZONTAL", AF.GetColorTable("BFI", 0.3), AF.GetColorTable("BFI", 0), nil, "ARTWORK")
    AF.SetOnePixelInside(header.tex, header)
    AF.RemoveFromPixelUpdater(header.tex)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", header.tex)

    achievementFrame.Header:SetParent(AF.hiddenParent)

    local title = achievementFrame.Header.Title
    title:SetParent(header)
    title:SetJustifyH("LEFT")
    title:ClearAllPoints()
    title:SetPoint("LEFT", header, 10, 0)
    title:SetSize(0, 0)

    local points = achievementFrame.Header.Points
    points:SetParent(header)
    points:SetJustifyH("LEFT")
    points:ClearAllPoints()
    points:SetPoint("LEFT", title, "RIGHT", 10, 0)

    _G.AchievementFrameWaterMark:Hide()

    -- search box
    local searchBox = achievementFrame.SearchBox
    S.StyleEditBox(searchBox, -4)
    AF.SetSize(searchBox, 150, 20)
    AF.ClearPoints(searchBox)
    AF.SetPoint(searchBox, "TOPRIGHT", closeButton, "TOPLEFT", 1, 0)

    -- dropdown
    local dropdown = achievementFrame.FilterDropdown
    S.StyleDropdownButton(dropdown)
    AF.SetSize(dropdown, 150, 20)
    dropdown.displacedRegions = nil -- WowStyle1FilterDropdownMixin

    AF.ClearPoints(dropdown)
    AF.SetPoint(dropdown, "TOPRIGHT", searchBox, "TOPLEFT", -3, 0)

    local anchor = AnchorUtil.CreateAnchor("TOPLEFT", dropdown, "BOTTOMLEFT", 0, 0)
	dropdown:SetMenuAnchor(anchor)

    dropdown:SetText(_G.ACHIEVEMENTFRAME_FILTER_ALL)
    hooksecurefunc(dropdown, "UpdateToMenuSelections", function(_, menuDescription, currentSelections)
        dropdown:SetText(currentSelections[1].text)
    end)

    dropdown.Text:SetJustifyH("LEFT")
    dropdown.Text:ClearAllPoints()
    dropdown.Text:SetPoint("LEFT", 10, 0)
end

---------------------------------------------------------------------
-- AchievementFrameCategories
---------------------------------------------------------------------
local function StyleCategories()
    local categories = _G.AchievementFrameCategories
    AF.ClearPoints(categories)
    AF.SetPoint(categories, "TOPLEFT", achievementFrame, 10, -25)
    AF.SetPoint(categories, "BOTTOMLEFT", achievementFrame, 10, 10)

    S.RemoveNineSliceAndBackground(categories)
    S.StyleScrollBar(categories.ScrollBar)
end

---------------------------------------------------------------------
-- AchievementFrameSummary
---------------------------------------------------------------------
local function StyleSummary()
    local summary = _G.AchievementFrameSummary
    AF.ClearPoints(summary)
    AF.SetPoint(summary, "TOPLEFT", _G.AchievementFrameCategories, "TOPRIGHT", 30, 0)
    AF.SetPoint(summary, "BOTTOM", _G.AchievementFrameCategories)

    S.RemoveBackground(summary)

    -- AchivementGoldBorderBackdrop
    -- an anonymous frame
    for _, region in next, {summary:GetChildren()} do
        if region.backdropColorAlpha and region.backdropBorderColor then
            region:Hide()
            break
        end
    end
end

---------------------------------------------------------------------
-- AchievementFrameStats
---------------------------------------------------------------------
local function StyleStats()
    local stats = _G.AchievementFrameStats
    AF.ClearPoints(stats)
    AF.SetPoint(stats, "TOPLEFT", _G.AchievementFrameCategories, "TOPRIGHT", 40, 0)
    AF.SetPoint(stats, "BOTTOM", _G.AchievementFrameCategories)

    -- S.RemoveBackground(stats)
    _G.AchievementFrameStatsBG:Hide()

    -- AchivementGoldBorderBackdrop
    -- an anonymous frame
    for _, region in next, {stats:GetChildren()} do
        if region.backdropColorAlpha and region.backdropBorderColor then
            region:Hide()
            break
        end
    end
end

---------------------------------------------------------------------
-- AchievementFrameAchievements
---------------------------------------------------------------------
local function StyleAchievements()
    local achievements = _G.AchievementFrameAchievements
    AF.ClearPoints(achievements)
    AF.SetPoint(achievements, "TOPLEFT", _G.AchievementFrameCategories, "TOPRIGHT", 40, 0)
    AF.SetPoint(achievements, "BOTTOM", _G.AchievementFrameCategories)

    -- S.RemoveBackground(achievements)
    S.RemoveTextures(achievements) -- an anonymous texture
    S.StyleScrollBar(achievements.ScrollBar)

    -- AchivementGoldBorderBackdrop
    -- an anonymous frame
    for _, region in next, {achievements:GetChildren()} do
        if region.backdropColorAlpha and region.backdropBorderColor then
            region:Hide()
            break
        end
    end
end

---------------------------------------------------------------------
-- tabs
---------------------------------------------------------------------
local function StyleTabs()
    local i = 1
    local tab, last = _G["AchievementFrameTab" .. i]
    while tab do
        S.StyleTab(tab)

        AF.ClearPoints(tab)
        if last then
            AF.SetPoint(tab, "TOPLEFT", last, "TOPRIGHT", 1, 0)
        else
            AF.SetPoint(tab, "TOPLEFT", achievementFrame, "BOTTOMLEFT", 0, -1)
        end
        last = tab

        i = i + 1
        tab = _G["AchievementFrameTab" .. i]
    end

    hooksecurefunc("AchievementFrame_UpdateTabs", function()
        local i = 1
        local tab = _G["AchievementFrameTab" .. i]
        while tab do
            tab.Text:ClearAllPoints()
            tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
            i = i + 1
            tab = _G["AchievementFrameTab" .. i]
        end
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    achievementFrame = _G.AchievementFrame

    StyleAchievementFrame()
    StyleTabs()
    StyleCategories()
    StyleSummary()
    StyleStats()
    StyleAchievements()
end
AF.RegisterAddonLoaded("Blizzard_AchievementUI", StyleBlizzard)