---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local achievementFrame

---------------------------------------------------------------------
-- general
---------------------------------------------------------------------
local function StyleAchievement(button)
    S.CreateBackdrop(button)
    button.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))

    S.RemoveNineSliceAndBackground(button)
    button.Glow:Hide()
    button.TitleBar:Hide()

    button.Icon.frame:Hide()
    button.Icon.bling:Hide()
    S.StyleIcon(button.Icon.texture)
    S.CreateBackdrop(button.Icon.texture, true, 1)

    button.BFITitleBar = AF.CreateGradientTexture(button.BFIBackdrop, "VERTICAL", "none", "none", nil, "BORDER", -1)
    button.BFITitleBar:SetPoint("TOPLEFT")
    button.BFITitleBar:SetPoint("TOPRIGHT")
    button.BFITitleBar:SetPoint("BOTTOM", button.Label, 0, -1)
    button.BFITitleBar:Hide()

    button.Highlight = AF.CreateBorderedFrame(button)
    button.Highlight:SetAllPoints()
    button.Highlight:SetBackgroundColor("none")
    button.Highlight:SetBorderColor("BFI")
    button.Highlight:Hide()
end

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

    local function UpdateEach(f)
        if f.Button._BFIStyled then return end
        S.StyleButton(f.Button)
        f.Button:SetHeight(23) -- for spacing, or use ScrollBoxLinearBaseViewMixin:SetPadding
        f.Button:BFI_HookHighlight()
    end

    local function Update(scrollBox)
        scrollBox:ForEachFrame(UpdateEach)
    end

    hooksecurefunc(categories.ScrollBox, "Update", Update)
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

    local function UpdateHeader(header)
        header:SetPoint("TOPLEFT")
        header:SetPoint("BOTTOMRIGHT")
        header:SetTexture(AF.GetTexture("Gradient_Linear_Horizontal_CenterToEdges"))
        header:SetTexCoord(0, 1, 0, 1)
        header:SetVertexColor(AF.GetColorRGB("BFI", 0.2))
    end

    --------------------------------------------------
    -- AchievementFrameSummaryAchievements
    --------------------------------------------------
    local achievements = _G.AchievementFrameSummaryAchievements
    achievements:ClearAllPoints()
    achievements:SetPoint("TOPLEFT", summary, "TOPLEFT", 5, 0)
    achievements:SetPoint("TOPRIGHT", summary, "TOPRIGHT", -5, 0)

    UpdateHeader(_G.AchievementFrameSummaryAchievementsHeaderHeader)

    hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
        for i, button in ipairs(achievements.buttons) do
            if not button._BFIStyled then
                button._BFIStyled = true

                StyleAchievement(button)

                -- AF.ClearPoints(button.BFIBackdrop)
                -- AF.SetPoint(button.BFIBackdrop, "TOPLEFT")
                -- AF.SetPoint(bu)

                button.Description:SetTextColor(AF.GetColorRGB("white"))

                button:ClearAllPoints()
                if i == 1 then
                    button:SetPoint("TOPLEFT", _G.AchievementFrameSummaryAchievementsHeader, "BOTTOMLEFT", 18, -1)
                    button:SetPoint("TOPRIGHT", _G.AchievementFrameSummaryAchievementsHeader, "BOTTOMRIGHT", -18, -1)
                else
                    button:SetPoint("TOPLEFT", achievements.buttons[i - 1], "BOTTOMLEFT", 0, -1)
                    button:SetPoint("TOPRIGHT", achievements.buttons[i - 1], "BOTTOMRIGHT", 0, -1)
                end
            end

            if button.accountWide then
                button.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable("skyblue", 0.4), "none")
                button.BFITitleBar:Show()
            else
                button.BFITitleBar:Hide()
            end
        end
    end)

    --------------------------------------------------
    -- AchievementFrameSummaryCategories
    --------------------------------------------------
    local categories = _G.AchievementFrameSummaryCategories
    categories:ClearAllPoints()
    categories:SetPoint("TOPLEFT", achievements, "BOTTOMLEFT", 0, -10)
    categories:SetPoint("TOPRIGHT", achievements, "BOTTOMRIGHT", 0, -10)

    UpdateHeader(_G.AchievementFrameSummaryCategoriesHeaderTexture)

    local function UpdateBar(bar)
        local name = bar:GetName()
        S.StyleStatusBar(bar, 1)
        bar:SetStatusBarColor(AF.GetColorRGB("lime"))

        local left = bar.Label or _G[name .. "Title"]
        left:SetPoint("LEFT", 6, 0)

        local right = bar.Text or _G[name .. "Text"]
        right:SetPoint("RIGHT", -6, 0)

        local highlight = AF.CreateBorderedFrame(_G[name .. "Button"])
        _G[name .. "ButtonHighlight"] = highlight
        highlight:SetAllPoints(bar.BFIBackdrop)
        highlight:SetBackgroundColor("none")
        highlight:SetBorderColor("BFI")
        highlight:Hide()
    end

    local bar = _G.AchievementFrameSummaryCategoriesStatusBar
    UpdateBar(bar)
    bar:SetPoint("TOP", _G.AchievementFrameSummaryCategoriesHeader, "BOTTOM", 0, -2)

    for i = 1, 12 do
        UpdateBar(_G["AchievementFrameSummaryCategoriesCategory" .. i])
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
    S.StyleScrollBar(stats.ScrollBar)

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

    -- AchievementTemplateMixin:UpdatePlusMinusTexture
    -- local function UpdatePlusMinusTexture(button)
    --     local id = button.id
    --     if ( not id ) then
    --         return
    --     end

    --     local display = false
    --     if GetAchievementNumCriteria(id) ~= 0 then
    --         display = true
    --     elseif button.completed and GetPreviousAchievement(id) then
    --         display = true
    --     elseif not button.completed and GetAchievementGuildRep(id) then
    --         display = true
    --     end

    --     AF.SetSize(button.PlusMinus, 13, 13)

    --     if display then
    --         if button.collapsed then
    --             button.PlusMinus:SetTexture(AF.GetIcon("Plus_Small"))
    --         else
    --             button.PlusMinus:SetTexture(AF.GetIcon("Minus_Small"))
    --         end
    --         button.PlusMinus:SetTexCoord(0, 1, 0, 1)
    --         button.PlusMinus:Show()
    --     else
    --         button.PlusMinus:Hide()
    --     end
    -- end

    achievements.ScrollBox:GetView():SetPadding(0, 0, 0, 0, 4)

    local function UpdateEach(button)
        if not button._BFIStyled then
            button._BFIStyled = true

            StyleAchievement(button)

            S.StyleCheckButton(button.Tracked, 11)
            F.Hide(button.Check)
            button.RewardBackground:SetAlpha(0)
            button:DisableDrawLayer("BORDER") -- XxxTsunami

            F.Hide(button.PlusMinus)
            -- UpdatePlusMinusTexture(button)
            -- hooksecurefunc(button, "UpdatePlusMinusTexture", UpdatePlusMinusTexture)
        end

        button.Label:SetTextColor(AF.GetColorRGB(button.completed and "white" or "gray"))
        button.Description:SetTextColor(AF.GetColorRGB(button.completed and "white" or "gray"))
        button.Reward:SetTextColor(AF.GetColorRGB(button.completed and "yellow_text" or "gray"))
        button.BFIBackdrop:SetBackdropColor(AF.GetColorRGB(button.completed and "widget" or "widget_darker"))

        if button.accountWide then
            button.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable(button.completed and "skyblue" or "darkgray", 0.4), "none")
            button.BFITitleBar:Show()
        else
            button.BFITitleBar:Hide()
        end
    end

    local function Update(scrollBox)
        scrollBox:ForEachFrame(UpdateEach)
    end

    hooksecurefunc(achievements.ScrollBox, "Update", Update)
end

---------------------------------------------------------------------
-- AchievementFrameAchievementsObjectives
---------------------------------------------------------------------
local function StyleObjectives()
    local objectives = _G.AchievementFrameAchievementsObjectives

    hooksecurefunc("AchievementButton_LocalizeProgressBar", function(frame)
        if frame._BFIStyled then return end
        frame.Text:ClearAllPoints()
        frame.Text:SetPoint("CENTER")
        S.StyleStatusBar(frame, 1)
    end)

    hooksecurefunc("AchievementButton_LocalizeMiniAchievement", function(frame)
        if frame._BFIStyled then return end
        frame._BFIStyled = true

        frame.Border:Hide()
        frame.Shield:Hide()

        AF.SetInside(frame.Icon, frame, 5, 5)
        S.StyleIcon(frame.Icon)
        S.CreateBackdrop(frame.Icon, true, 1)

        local font, size = frame.Points:GetFont()
        frame.Points:SetFont(font, size, "OUTLINE")
        frame.Points:SetShadowOffset(0, 0)
        frame.Points:SetShadowColor(0, 0, 0, 0)
    end)
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
    StyleObjectives()
end
AF.RegisterAddonLoaded("Blizzard_AchievementUI", StyleBlizzard)