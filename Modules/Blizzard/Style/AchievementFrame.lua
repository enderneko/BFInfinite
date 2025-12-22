---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local achievementFrame
local guildTab

local UnitClassBase = UnitClassBase
local PanelTemplates_SetTabEnabled = PanelTemplates_SetTabEnabled
local GetNumFilteredAchievements = GetNumFilteredAchievements
local CRITERIA_TYPE_ACHIEVEMENT = _G.CRITERIA_TYPE_ACHIEVEMENT
local EVALUATION_TREE_FLAG_PROGRESS_BAR = _G.EVALUATION_TREE_FLAG_PROGRESS_BAR
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function StyleAchievement(frame)
    S.CreateBackdrop(frame)
    frame.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))

    S.RemoveNineSliceAndBackground(frame)
    frame.Glow:Hide()
    frame.TitleBar:Hide()

    frame.Icon.frame:Hide()
    frame.Icon.bling:Hide()
    S.StyleIcon(frame.Icon.texture)
    S.CreateBackdrop(frame.Icon.texture, true, 1)

    frame.BFITitleBar = AF.CreateGradientTexture(frame.BFIBackdrop, "VERTICAL", "none", "none", nil, "BORDER", -1)
    frame.BFITitleBar:Hide()
    frame.BFITitleBar:SetPoint("TOPLEFT")
    frame.BFITitleBar:SetPoint("TOPRIGHT")
    if frame.Label then
        frame.BFITitleBar:SetPoint("BOTTOM", frame.Label, 0, -1)
    else
        frame.BFITitleBar:SetHeight(24)
    end

    frame.Highlight = AF.CreateBorderedFrame(frame)
    frame.Highlight:SetAllPoints()
    frame.Highlight:SetBackgroundColor("none")
    frame.Highlight:SetBorderColor("BFI")
    frame.Highlight:Hide()
end

local function RemoveAchivementGoldBorderBackdrop(frame)
    -- AchivementGoldBorderBackdrop, an anonymous frame
    for _, region in next, {frame:GetChildren()} do
        if region.backdropColorAlpha and region.backdropBorderColor then
            region:Hide()
            break
        end
    end
end

local function Stat_Highlight(button)
    if button.isHeader then return end
    button.highlight:Show()
end

local function Stat_Dehighlight(button)
    button.highlight:Hide()
end

local function Stat_UpdateEach(button)
    if not button._BFIStyled then
        button._BFIStyled = true

        S.RemoveTextures(button)

        button.Title:ClearAllPoints()
        button.Title:SetPoint("CENTER")

        button.Middle:ClearAllPoints()
        button.Middle:SetPoint("LEFT")
        button.Middle:SetPoint("RIGHT")
        button.Middle:SetHeight(22)
        button.Middle:SetTexCoord(0, 1, 0, 1)
        button.Middle:SetTexture(AF.GetTexture("Gradient_Linear_Horizontal_CenterToEdges"))
        button.Middle:SetVertexColor(AF.GetColorRGB("BFI", 0.2))

        button.Background:SetTexture(AF.GetPlainTexture())
        button.Background:ClearAllPoints()
        button.Background:SetPoint("LEFT")
        button.Background:SetPoint("RIGHT")

        local highlight = AF.CreateTexture(button, nil, "widget_highlight", "BACKGROUND", 2)
        button.highlight = highlight
        highlight:Hide()
        highlight:SetAllPoints(button.Background)
        button:HookScript("OnEnter", Stat_Highlight)
        button:HookScript("OnLeave", Stat_Dehighlight)
    end

    local colorIndex = button:GetElementData().colorIndex
    button.Background:SetTexCoord(0, 1, 0, 1)
    button.Background:SetHeight(22)
    button.Background:SetAlpha(1)
    button.Background:SetBlendMode("DISABLE")
    if colorIndex == 1 then
        button.Background:SetVertexColor(AF.GetColorRGB("widget_darker"))
    else
        button.Background:SetVertexColor(AF.GetColorRGB("widget"))
    end
end

local function Stat_Update(scrollBox)
    scrollBox:ForEachFrame(Stat_UpdateEach)
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
    RemoveAchivementGoldBorderBackdrop(summary)

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

                button:ClearAllPoints()
                if i == 1 then
                    button:SetPoint("TOPLEFT", _G.AchievementFrameSummaryAchievementsHeader, "BOTTOMLEFT", 18, -1)
                    button:SetPoint("TOPRIGHT", _G.AchievementFrameSummaryAchievementsHeader, "BOTTOMRIGHT", -18, -1)
                else
                    button:SetPoint("TOPLEFT", achievements.buttons[i - 1], "BOTTOMLEFT", 0, -1)
                    button:SetPoint("TOPRIGHT", achievements.buttons[i - 1], "BOTTOMRIGHT", 0, -1)
                end
            end

            button.Description:SetTextColor(AF.GetColorRGB("white"))

            if guildTab.isSelected then
                -- button.saturatedStyle is nil if not completed
                button.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable(button.saturatedStyle and "softlime" or "darkgray", 0.4), "none")
                button.BFITitleBar:Show()
            elseif button.accountWide then
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
    RemoveAchivementGoldBorderBackdrop(stats)
    hooksecurefunc(stats.ScrollBox, "Update", Stat_Update)
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
    RemoveAchivementGoldBorderBackdrop(achievements)

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
            button.GuildCornerL:SetAlpha(0)
            button.GuildCornerR:SetAlpha(0)

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

        if guildTab.isSelected then
            -- button.saturatedStyle is nil if not completed
            button.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable(button.saturatedStyle and "softlime" or "darkgray", 0.4), "none")
            button.BFITitleBar:Show()
        elseif button.accountWide then
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

    hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
        local textStrings, progressBars, metas = 0, 0, 0
        local numCriteria = GetAchievementNumCriteria(id)
        local label, border, icon

        for i = 1, numCriteria do
            local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i)
            if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
                metas = metas + 1
                local metaCriteria = objectivesFrame:GetMeta(metas)
                label = metaCriteria.Label
                border = metaCriteria.Border
                icon = metaCriteria.Icon

                local highlight = metaCriteria:GetHighlightTexture()
                highlight:SetTexture(AF.GetPlainTexture())
                highlight:SetVertexColor(AF.GetColorRGB("highlight", 0.1))

            elseif bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then
                -- NOTE: already styled in AchievementButton_LocalizeProgressBar
                label, border, icon = nil, nil, nil
            else
                textStrings = textStrings + 1
			    local criteria = objectivesFrame:GetCriteria(textStrings)
                label = criteria.Name
                border, icon = nil, nil
            end

            if label then
                if objectivesFrame.completed and completed then
                    label:SetTextColor(AF.GetColorRGB("white"))
                elseif completed then
                    label:SetTextColor(AF.GetColorRGB("green"))
                else
                    label:SetTextColor(AF.GetColorRGB("darkgray"))
                end
                label:SetShadowOffset(1, -1)
            end

            if border and icon then
                border:Hide()
                AF.ApplyDefaultTexCoord(icon)
                S.CreateBackdrop(icon, true, 1)
            end
        end
    end)
end

---------------------------------------------------------------------
-- AchievementFrameComparison
---------------------------------------------------------------------
local function StyleComparison()
    local comparison = _G.AchievementFrameComparison
    AF.ClearPoints(comparison)
    AF.SetPoint(comparison, "TOPLEFT", _G.AchievementFrameCategories, "TOPRIGHT", 35, 0)
    AF.SetPoint(comparison, "BOTTOM", _G.AchievementFrameCategories)

    RemoveAchivementGoldBorderBackdrop(comparison)
    S.RemoveTextures(comparison)

    --------------------------------------------------
    -- header
    --------------------------------------------------
    local header = _G["AchievementFrameComparisonHeader"]
    -- header:Hide()
    header.Shield:Hide()
    _G["AchievementFrameComparisonHeaderBG"]:Hide()

    local points = header.Points
    points:SetSize(0, 0)
    -- points:SetParent(achievementFrame.BFIHeader)
    points:ClearAllPoints()
    points:SetPoint("RIGHT", achievementFrame.SearchBox, "LEFT", -15, 0)

    local name = _G["AchievementFrameComparisonHeaderName"]
    name:SetSize(0, 0)
    -- name:SetParent(achievementFrame.BFIHeader)
    name:ClearAllPoints()
    name:SetPoint("RIGHT", points, "LEFT", -5, 0)

    hooksecurefunc("AchievementFrameComparison_SetUnit", function(unit)
        local class = UnitClassBase(unit)
        name:SetTextColor(AF.GetColorRGB(class))
    end)

    local portrait = _G["AchievementFrameComparisonHeaderPortrait"]
    -- portrait:SetParent(achievementFrame.BFIHeader)
    portrait:ClearAllPoints()
    portrait:SetPoint("RIGHT", name, "LEFT", -5, 0)
    AF.SetSize(portrait, 27, 20)
    portrait:SetTexCoord(AF.CalcTexCoordPreCrop(nil, 27 / 20, 1, nil, true))
    S.CreateBackdrop(portrait, true, 0, 1)

    --------------------------------------------------
    -- summary
    --------------------------------------------------
    local function UpdateSummary(frame)
        S.RemoveNineSliceAndBackground(frame)
        S.RemoveTextures(frame)
        S.StyleStatusBar(frame.StatusBar, 1)
        frame.StatusBar:SetStatusBarColor(AF.GetColorRGB("lime"))
        frame.StatusBar.Title:ClearAllPoints()
        frame.StatusBar.Title:SetPoint("LEFT", 6, 0)
        frame.StatusBar.Text:ClearAllPoints()
        frame.StatusBar.Text:SetPoint("RIGHT", -6, 0)
    end

    UpdateSummary(comparison.Summary.Player)
    UpdateSummary(comparison.Summary.Friend)

    --------------------------------------------------
    -- AchievementContainer
    --------------------------------------------------
    local achievementContainer = comparison.AchievementContainer
    S.StyleScrollBar(achievementContainer.ScrollBar)

    local function Highlight(frame)
        frame.Player.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
        frame.Friend.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
    end

    local function Dehighlight(frame)
        frame.Player.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
        frame.Friend.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
    end

    local function UpdateEach(frame)
        local player = frame.Player
        local friend = frame.Friend

        if not frame._BFIStyled then
            frame._BFIStyled = true

            StyleAchievement(player)
            AF.SetPoint(player.BFIBackdrop, "BOTTOMRIGHT", -1, 0)
            StyleAchievement(friend)

            frame:HookScript("OnEnter", Highlight)
            frame:HookScript("OnLeave", Dehighlight)
        end

        player.Label:SetTextColor(AF.GetColorRGB(player.completed and "white" or "gray"))
        player.Description:SetTextColor(AF.GetColorRGB(player.completed and "white" or "gray"))
        player.BFIBackdrop:SetBackdropColor(AF.GetColorRGB(player.completed and "widget" or "widget_darker"))
        friend.BFIBackdrop:SetBackdropColor(AF.GetColorRGB(friend.completed and "widget" or "widget_darker"))

        if player.accountWide then
            player.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable(player.completed and "skyblue" or "darkgray", 0.4), "none")
            player.BFITitleBar:Show()
            friend.BFITitleBar:SetColor("HORIZONTAL", AF.GetColorTable(friend.completed and "skyblue" or "darkgray", 0.4), "none")
            friend.BFITitleBar:Show()
        else
            player.BFITitleBar:Hide()
            friend.BFITitleBar:Hide()
        end
    end

    local function Update(scrollBox)
        scrollBox:ForEachFrame(UpdateEach)
    end

    hooksecurefunc(achievementContainer.ScrollBox, "Update", Update)
    achievementContainer.ScrollBox:GetView():SetPadding(0, 0, 0, 0, 1)

    --------------------------------------------------
    -- StatContainer
    --------------------------------------------------
    local statContainer = comparison.StatContainer
    S.StyleScrollBar(statContainer.ScrollBar)

    hooksecurefunc(statContainer.ScrollBox, "Update", Stat_Update)
    statContainer.ScrollBox:GetView():SetPadding(0, 0, 0, 4, 1)
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

    local comparison = _G.AchievementFrameComparison

    local function UpdateTabs()
        PanelTemplates_SetTabEnabled(achievementFrame, 2, not comparison:IsShown())

        local i = 1
        local tab = _G["AchievementFrameTab" .. i]
        while tab do
            tab.Text:ClearAllPoints()
            tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
            tab:Show()
            i = i + 1
            tab = _G["AchievementFrameTab" .. i]
        end
    end

    hooksecurefunc("AchievementFrame_UpdateTabs", UpdateTabs) -- before
    hooksecurefunc("AchievementFrame_SetTabs", UpdateTabs) -- after
    hooksecurefunc("AchievementFrame_SetComparisonTabs", UpdateTabs) -- after
end

---------------------------------------------------------------------
-- SearchPreviewContainer
---------------------------------------------------------------------
local function StyleSearchPreview()
    local container = achievementFrame.SearchPreviewContainer
    AF.ClearPoints(container)
    AF.SetPoint(container, "TOPLEFT", achievementFrame.SearchBox, "BOTTOMLEFT", -4, -1)

    S.RemoveTextures(container)
    -- S.CreateBackdrop(container)
    -- hooksecurefunc("AchievementFrame_ShowSearchPreviewResults", function()
    --     local numResults = GetNumFilteredAchievements()
    --     if numResults > 5 then
    --         AF.SetPoint(container.BFIBackdrop, "BOTTOMRIGHT", container.ShowAllSearchResults, "BOTTOMRIGHT", 1, -1)
    --     elseif numResults > 0 then
    --         AF.SetPoint(container.BFIBackdrop, "BOTTOMRIGHT", container.searchPreviews[numResults], "BOTTOMRIGHT", 1, -1)
    --     end
    -- end)

    local lastButton
    for i, button in ipairs(container.searchPreviews) do
        S.StyleButton(button)

        S.StyleIcon(button.Icon, true)
        button.Icon:SetAlpha(1)
        button.Icon:Show()
        button.Icon:ClearAllPoints()
        button.Icon:SetPoint("LEFT", 3, 0)
        button.Icon:SetSize(21, 21)

        if i > 1 then
            AF.ClearPoints(button)
            AF.SetPoint(button, "TOPLEFT", lastButton, "BOTTOMLEFT", 0, 1)
        end
        lastButton = button
    end
    S.StyleButton(container.ShowAllSearchResults)
    AF.ClearPoints(container.ShowAllSearchResults)
    AF.SetPoint(container.ShowAllSearchResults, "TOPLEFT", lastButton, "BOTTOMLEFT", 0, 1)
    AF.SetPoint(container.ShowAllSearchResults, "TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 1)
end

---------------------------------------------------------------------
-- SearchResults
---------------------------------------------------------------------
local function StyleSearchResults()
    local searchResults = achievementFrame.SearchResults
    S.StyleTitledFrame(searchResults)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    achievementFrame = _G.AchievementFrame
    guildTab = _G.AchievementFrameTab2

    StyleAchievementFrame()
    StyleTabs()
    StyleCategories()
    StyleSummary()
    StyleStats()
    StyleAchievements()
    StyleObjectives()
    StyleComparison()
    StyleSearchPreview()
    StyleSearchResults()
end
AF.RegisterAddonLoaded("Blizzard_AchievementUI", StyleBlizzard)