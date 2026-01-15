---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local map = _G.WorldMapFrame
local quest = _G.QuestMapFrame

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function CreateBackdrop(frame)
    S.CreateBackdrop(frame)
    frame.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("background_lighter", 0.1))
    AF.ClearPoints(frame.BFIBackdrop)
    AF.SetPoint(frame.BFIBackdrop, "TOPLEFT", 0, 1)
    AF.SetPoint(frame.BFIBackdrop, "BOTTOMRIGHT", 0, -1)
end

---------------------------------------------------------------------
-- backdrop
---------------------------------------------------------------------
local function StyleBackdrop()
    F.Hide(map.BorderFrame.Tutorial)
    map.BorderFrame.InsetBorderTop:Hide()
    S.StyleTitledFrame(map.BorderFrame)
    AF.SetFrameLevel(map.BorderFrame.BFIBg, -1, map)
end

---------------------------------------------------------------------
-- quest tabs
---------------------------------------------------------------------
local function StyleQuestTabs()
    for i, tab in ipairs(quest.TabButtons) do
        S.StyleSideTab(tab)
        tab:SetChecked(tab.displayMode == quest.displayMode)

        AF.ClearPoints(tab)
        if i == 1 then
            AF.SetPoint(tab, "TOPLEFT", quest, "TOPRIGHT", 4, -28)
        else
            AF.SetPoint(tab, "TOPLEFT", quest.TabButtons[i - 1], "BOTTOMLEFT", 0, -1)
        end
    end
end

---------------------------------------------------------------------
-- QuestMapFrame.QuestsFrame
---------------------------------------------------------------------
local function StyleQuestsFrame()
    local scroll = quest.QuestsFrame.ScrollFrame -- QuestScrollFrame
    scroll.BorderFrame:Hide()
    scroll.Background:Hide()

    CreateBackdrop(scroll)
    S.StyleScrollBar(scroll.ScrollBar)
    S.StyleEditBox(scroll.SearchBox, -4)

    local contents = scroll.Contents

    -- separator
    local separator = AF.CreateSeparator(contents, nil, 1, AF.GetColorTable("disabled", 0.5))
    separator:SetPoint("LEFT", contents.Separator)
    separator:SetPoint("RIGHT", contents.Separator)
    contents.Separator.Divider:Hide()
    contents.Separator.Divider = separator

    -- stroy header
    -- local storyHeader = contents.StoryHeader

    -- storyHeader.HighlightTexture = AF.CreateTexture(storyHeader, nil, "widget_highlight", "OVERLAY", -1, nil, nil, "ADD")

    local function UpdateCollapsedState(collapseButton, collapsed)
        collapseButton.collapsed = collapsed
        local texture = collapsed and AF.GetIcon("Plus_Small") or AF.GetIcon("Minus_Small")
        collapseButton.Icon:SetSize(16, 16)
        collapseButton.Icon:SetTexture(texture)
        collapseButton:SetHighlightTexture(texture)
    end

    local function UpdateCollapseButton(header)
        local collapseButton = header.CollapseButton
        -- collapseButton.Icon:SetSize(16, 16) -- SetAtlas(xx, true) will override size
        collapseButton.Icon:SetAlpha(0.5)

        -- collapseButton.UpdateCollapsedState = UpdateCollapsedState --! taint
        hooksecurefunc(collapseButton, "UpdateCollapsedState", UpdateCollapsedState)
        UpdateCollapsedState(collapseButton, collapseButton.collapsed)
    end

    --! CampaignHeaderTemplate (Frame)
    local function UpdateCampaignHeader(header)
        if header._BFIStyled then return end
        header._BFIStyled = true

        header.TopFiligree:Hide()
        UpdateCollapseButton(header)

        local left = AF.CreateGradientTexture(header, "VERTICAL", "none", "border", nil, "OVERLAY")
        AF.SetWidth(left, 1)
        AF.SetPoint(left, "TOPLEFT", -1, 0)
        AF.SetPoint(left, "BOTTOMLEFT", -1, 0)

        local right = AF.CreateGradientTexture(header, "VERTICAL", "none", "border", nil, "OVERLAY")
        AF.SetWidth(right, 1)
        AF.SetPoint(right, "TOPRIGHT", 1, 0)
        AF.SetPoint(right, "BOTTOMRIGHT", 1, 0)

        local top = AF.CreateTexture(header, nil, "border", "OVERLAY")
        AF.SetHeight(top, 1)
        top:SetPoint("TOPLEFT")
        top:SetPoint("TOPRIGHT")
    end

    --! CovenantCallingsHeaderTemplate (Button)
    local function UpdateCovenantHeader(header)
        if header._BFIStyled then return end
        header._BFIStyled = true
        UpdateCollapseButton(header)
    end

    --! QuestLogHeaderTemplate/CampaignHeaderMinimalTemplate (Button)
    local function UpdateHeader(header)
        if header._BFIStyled then return end
        S.StyleButton(header)
        UpdateCollapseButton(header)
    end

    --! QuestLogTitleTemplate (Button)
    local function UpdateTitle(title)
        if title._BFIStyled then return end
        title._BFIStyled = true

        local checkbox = title.Checkbox -- QuestLogTrackCheckboxTemplate
        S.RemoveTextures(checkbox)
        S.CreateBackdrop(checkbox)
        checkbox.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))

        checkbox.CheckMark:SetColorTexture(AF.GetColorRGB("BFI", 0.7))
        AF.SetOnePixelInside(checkbox.CheckMark, checkbox)

        local highlight = AF.CreateTexture(checkbox, nil, AF.GetColorTable("BFI", 0.1), "HIGHLIGHT")
        AF.SetOnePixelInside(highlight, checkbox)
    end

    --! QuestLogObjectiveTemplate (Frame)
    local function UpdateObjective(objective)
        if objective._BFIStyled then return end
        objective._BFIStyled = true
    end

    hooksecurefunc("QuestLogQuests_Update", function()
        -- print("QuestLogQuests_Update")

        -- campaign header
        for header in scroll.campaignHeaderFramePool:EnumerateActive() do
            UpdateCampaignHeader(header)
        end

        -- campain header minimal
        for header in scroll.campaignHeaderMinimalFramePool:EnumerateActive() do
            UpdateHeader(header)
        end

        -- covenant header
        for header in scroll.covenantCallingsHeaderFramePool:EnumerateActive() do
            UpdateCovenantHeader(header)
        end

        -- header
        for header in scroll.headerFramePool:EnumerateActive() do
            UpdateHeader(header)
        end

        -- title
        for title in scroll.titleFramePool:EnumerateActive() do
            UpdateTitle(title)
        end

        -- objective
        for objective in scroll.objectiveFramePool:EnumerateActive() do
            UpdateObjective(objective)
        end
    end)
end

---------------------------------------------------------------------
-- QuestMapFrame.EventsFrame
---------------------------------------------------------------------
local function StyleEventsFrame()
    local eventsFrame = quest.EventsFrame
    S.RemoveTextures(eventsFrame) -- a weird yellow texture?
    S.StyleScrollBar(eventsFrame.ScrollBar)
    eventsFrame.BorderFrame:Hide()
    eventsFrame.ScrollBox.Background:Hide()

    CreateBackdrop(eventsFrame)

    local EntryType = EnumUtil.MakeEnum(
        "OngoingHeader", -- "EventSchedulerOngoingHeaderTemplate"
        "OngoingEvent", -- "EventSchedulerOngoingEntryTemplate"
        "ScheduledHeader", -- "EventSchedulerScheduledHeaderTemplate"
        "ScheduledEvent", -- "EventSchedulerScheduledEntryTemplate"
        "Date", -- "EventSchedulerDateLabelTemplate"
        "HiddenEventsLabel", -- "EventSchedulerHiddenEventsLabelTemplate"
        "NoEventsLabel" -- "EventSchedulerNoEventsLabelTemplate"
    )

    local function UpdateEach(frame)
        local data = frame:GetData()

        local entryType = data.entryType
        if entryType == EntryType.OngoingHeader or entryType == EntryType.ScheduledHeader then
            -- header
            if frame._BFIStyled then return end
            -- style the frame
            frame.Background:Hide()
            S.CreateBackdrop(frame)
            AF.ClearPoints(frame.BFIBackdrop)
            frame.BFIBackdrop:SetPoint("LEFT")
            frame.BFIBackdrop:SetPoint("RIGHT", -2, 0)
            frame.BFIBackdrop:SetHeight(21)

        elseif entryType == EntryType.OngoingEvent or entryType == EntryType.ScheduledEvent then
            -- event entry
            if entryType == EntryType.OngoingEvent then
                frame.Background:SetColorTexture(AF.GetColorRGB(frame:HasRewardsClaimed() and "widget_dark" or "widget", 0.9))
            end

            if frame._BFIStyled then return end
            -- style the frame
            frame.Name:ClearAllPoints()
            frame.Location:ClearAllPoints()
            frame.Background:ClearAllPoints()
            frame.Background:SetPoint("BOTTOMRIGHT", -3, 1)

            frame.Highlight:SetAllPoints(frame.Background)
            frame.Highlight:SetBlendMode("ADD")
            frame.Highlight:SetColorTexture(AF.GetColorRGB("widget_highlight", 0.5))

            if entryType == EntryType.OngoingEvent then
                frame.Name:SetPoint("TOPLEFT", 37, -4)
                frame.Location:SetPoint("BOTTOMLEFT", 37, 4)
                frame.Background:SetPoint("TOPLEFT", 1, -1)
            else
                frame.Name:SetPoint("TOPLEFT", 22, -4)
                frame.Location:SetPoint("BOTTOMLEFT", 22, 4)
                frame.Background:SetPoint("TOPLEFT", 2, -1)
                frame.Background:SetColorTexture(0.588, 0.482, 0.051, 0.45)
            end

        end

        frame._BFIStyled = true
    end

    local function Update(scorllBox)
        scorllBox:ForEachFrame(UpdateEach)
    end

    hooksecurefunc(eventsFrame.ScrollBox, "Update", Update)
end

---------------------------------------------------------------------
-- QuestMapFrame.MapLegend, MapLegendScrollFrame
---------------------------------------------------------------------
local function StyleMapLegend()
    local legend = quest.MapLegend
    legend.BorderFrame:Hide()

    CreateBackdrop(legend)

    local scroll = _G.MapLegendScrollFrame
    S.StyleScrollBar(scroll.ScrollBar)
    scroll.Background:Hide()
end

---------------------------------------------------------------------
-- WorldMapMixin:AddOverlayFrames
---------------------------------------------------------------------
local function StyleOverlayFrames()
    --------------------------------------------------
    -- NavBar
    --------------------------------------------------
    local function StyleNavBar(frame)
        S.RemoveTextures(frame)
        frame.overlay:Hide()

        S.CreateBackdrop(frame)
        AF.ClearPoints(frame.BFIBackdrop)
        AF.SetPoint(frame.BFIBackdrop, "TOPLEFT", -1, -1)
        AF.SetPoint(frame.BFIBackdrop, "BOTTOMRIGHT")
        -- frame.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("background_lighter", 0.1))

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", map.TitleCanvasSpacerFrame, 10, -25)
        frame:SetPoint("BOTTOMRIGHT", map.TitleCanvasSpacerFrame, "BOTTOMRIGHT", -4, 9)
    end

    -- map.NavBar.home.xoffset = 0
    local function SetupTexture(obj, texture, color, alpha, offset)
        obj:SetTexture(AF.GetTexture(texture))
        obj:SetTexCoord(0, 1, 0, 1)
        obj:SetVertexColor(AF.GetColorRGB(color, alpha))

        if offset then
            obj:ClearAllPoints()
            obj:SetPoint("TOPLEFT")
            obj:SetPoint("BOTTOMRIGHT", offset, 0)
        end
    end

    local overflowButton = map.NavBar.overflow
    S.RemoveTextures(overflowButton)
    SetupTexture(overflowButton:GetNormalTexture(), "Gradient_Linear_Right", "widget_highlight", 0.8, overflowButton.xoffset)
    SetupTexture(overflowButton:GetPushedTexture(), "Gradient_Linear_Right", "widget_highlight", 0.8, overflowButton.xoffset)
    SetupTexture(overflowButton:GetHighlightTexture(), "Gradient_Linear_Right", "widget_highlight", 0.2, overflowButton.xoffset)

    -- overflowButton icon
    local icon = overflowButton:CreateTexture(nil, "ARTWORK", nil, 7)
    overflowButton.icon = icon
    AF.SetPoint(icon, "CENTER", overflowButton.xoffset / 2, 0)
    AF.SetSize(icon, 16, 16)
    icon:SetTexture(AF.GetIcon("ArrowLeft2"))
    icon:SetVertexColor(AF.GetColorRGB("darkgray"))
    overflowButton:SetScript("OnMouseDown", function()
        icon:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(overflowButton))
    end)
    overflowButton:SetScript("OnMouseUp", function()
        AF.RePoint(icon)
    end)
    overflowButton:SetScript("OnShow", function()
        AF.RePoint(icon)
    end)
    overflowButton:HookScript("OnEnter", function()
        icon:SetVertexColor(AF.GetColorRGB("white"))
    end)
    overflowButton:HookScript("OnLeave", function()
        icon:SetVertexColor(AF.GetColorRGB("darkgray"))
    end)


    local function MenuArrowButton_OnEnter(self)
        self.BFIIcon:SetVertexColor(AF.GetColorRGB("white"))
    end
    local function MenuArrowButton_OnLeave(self)
        self.BFIIcon:SetVertexColor(AF.GetColorRGB("darkgray"))
    end

    hooksecurefunc("NavBar_AddButton", function(self, buttonData)
        for _, button in next, self.navList do
            if not button._BFIStyled then
                button._BFIStyled = true

                S.RemoveTextures(button)
                button:SetPushedTextOffset(0, -1)

                local offset
                if button == map.NavBar.home then
                    offset = button.xoffset
                end

                local normalTexture = button:GetNormalTexture()
                SetupTexture(normalTexture, "Gradient_Linear_Right", "widget_highlight", 0.8, offset)

                local pushedTexture = button:GetPushedTexture()
                SetupTexture(pushedTexture, "Gradient_Linear_Right", "widget_highlight", 0.8, offset)

                local highlightTexture = button:GetHighlightTexture()
                SetupTexture(highlightTexture, "Gradient_Linear_Right", "widget_highlight", 0.2, offset)

                if button.selected then
                    SetupTexture(button.selected, "Gradient_Linear_Right", "BFI", 0.2)
                end

                if button.MenuArrowButton then
                    local MenuArrowButton = button.MenuArrowButton
                    S.StyleIconButton(MenuArrowButton, AF.GetIcon("ArrowDown2"), 16)
                    AF.ClearBackdrop(MenuArrowButton.BFIBackdrop)
                    MenuArrowButton.BFIBg:Hide()
                    MenuArrowButton.BFIIcon:SetVertexColor(AF.GetColorRGB("darkgray"))
                    MenuArrowButton:HookScript("OnEnter", MenuArrowButton_OnEnter)
                    MenuArrowButton:HookScript("OnLeave", MenuArrowButton_OnLeave)
                end
            end
        end
    end)

    --------------------------------------------------
    -- SidePanelToggle
    --------------------------------------------------
    local function StyleSidePanelToggle(frame)
        frame:SetSize(25, 25)
        frame.OpenButton:SetSize(25, 25)
        frame.CloseButton:SetSize(25, 25)
        S.StyleIconButton(frame.OpenButton, AF.GetIcon("ArrowRight1"), 20, nil, "BFI_hover")
        S.StyleIconButton(frame.CloseButton, AF.GetIcon("ArrowLeft1"), 20, nil, "BFI_hover")
    end

    --------------------------------------------------
    -- FloorDropdown
    --------------------------------------------------
    local function StyleFloorDropdown(frame)
        -- WorldMapFloorNavigationFrameTemplate -> WowStyle1DropdownTemplate
        S.StyleDropdownButton(frame)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", map:GetCanvasContainer(), 2, -2)
    end

    --------------------------------------------------
    -- TrackingOptionsButton
    --------------------------------------------------
    local function StyleTrackingOptionsButton(frame)
        -- WorldMapTrackingOptionsButtonTemplate
        frame:SetSize(25, 25)
        S.StyleIconButton(frame, AF.GetIcon("Map-Filter-Button", BFI.name), 24)

        frame.FilterCounter:ClearAllPoints()
        frame.FilterCounter:SetPoint("RIGHT", frame, "LEFT", 2, 0)

        frame.FilterCounterBanner:ClearAllPoints()
        frame.FilterCounterBanner:SetPoint("TOPRIGHT", frame, "TOPLEFT")
        frame.FilterCounterBanner:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT")
        frame.FilterCounterBanner:SetWidth(50)
        frame.FilterCounterBanner:SetTexture(AF.GetTexture("Gradient_Linear_Right"))
        frame.FilterCounterBanner:SetVertexColor(AF.GetColorRGB("background", 0.5))
        frame.FilterCounterBanner:SetAlpha(1)
        frame.FilterCounterBanner:Show()

        frame.ResetButton:ClearAllPoints()
        frame.ResetButton:SetPoint("CENTER", frame, "TOPRIGHT", -2, -2)
        frame.ResetButton:SetSize(20, 20)
    end

    --------------------------------------------------
    -- TrackingPinButton
    --------------------------------------------------
    local function StyleTrackingPinButton(frame)
        -- WorldMapTrackingPinButtonTemplate
        frame:SetSize(25, 25)
        S.StyleIconButton(frame, "Waypoint-MapPin-Untracked", 23)
    end

    --------------------------------------------------
    -- hook
    --------------------------------------------------
    -- hooksecurefunc(map, "AddOverlayFrame", function(_, templateName, templateType, anchorPoint, relativeFrame, relativePoint, offsetX, offsetY)
    --     print(templateName, templateType, AF.GetLast(map.overlayFrames))
    -- end)
    hooksecurefunc(map, "RefreshOverlayFrames", function()
        for _, frame in next, map.overlayFrames do
            if not frame._BFIStyled then

                if frame == map.NavBar then
                    StyleNavBar(frame)
                elseif frame == map.SidePanelToggle then
                    StyleSidePanelToggle(frame)
                elseif frame.Arrow then
                    StyleFloorDropdown(frame)
                elseif frame.FilterCounterBanner then
                    StyleTrackingOptionsButton(frame)
                elseif frame.ActiveTexture then
                    StyleTrackingPinButton(frame)
                end

                frame._BFIStyled = true
            end
        end
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    StyleBackdrop()
    StyleQuestTabs()
    StyleQuestsFrame()
    StyleEventsFrame()
    StyleMapLegend()
    StyleOverlayFrames()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)