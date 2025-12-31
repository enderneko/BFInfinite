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
                frame.Background:SetColorTexture(AF.GetColorRGB(frame:HasRewardsClaimed() and "widget_darker" or "widget", 0.9))
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
    -- SidePanelToggle
    --------------------------------------------------
    local SidePanelToggle = map.SidePanelToggle
    SidePanelToggle._BFIStyled = true
    SidePanelToggle:SetSize(25, 25)
    SidePanelToggle.OpenButton:SetSize(25, 25)
    SidePanelToggle.CloseButton:SetSize(25, 25)
    S.StyleIconButton(SidePanelToggle.OpenButton, "BFI_hover", AF.GetIcon("ArrowRight1"), 20)
    S.StyleIconButton(SidePanelToggle.CloseButton, "BFI_hover", AF.GetIcon("ArrowLeft1"), 20)

    --------------------------------------------------
    -- NavBar
    --------------------------------------------------
    local NavBar = map.NavBar
    NavBar._BFIStyled = true

    --------------------------------------------------
    -- other overlay frames
    --------------------------------------------------
    -- hooksecurefunc(map, "AddOverlayFrame", function(_, templateName, templateType, anchorPoint, relativeFrame, relativePoint, offsetX, offsetY)
    --     print(templateName, templateType, AF.GetLast(map.overlayFrames))
    -- end)
    hooksecurefunc(map, "RefreshOverlayFrames", function()
        for _, frame in next, map.overlayFrames do
            if not frame._BFIStyled then
                local objType = frame:GetObjectType()

                if frame.Arrow then
                    -- WorldMapFloorNavigationFrameTemplate -> WowStyle1DropdownTemplate
                    S.StyleDropdownButton(frame)
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", map:GetCanvasContainer(), 2, -2)

                elseif frame.FilterCounterBanner then
                    -- WorldMapTrackingOptionsButtonTemplate
                    frame:SetSize(25, 25)
                    S.StyleIconButton(frame, nil, AF.GetIcon("Map-Filter-Button", BFI.name), 24)

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

                elseif frame.ActiveTexture then
                    -- WorldMapTrackingPinButtonTemplate
                    frame:SetSize(25, 25)
                    S.StyleIconButton(frame, nil, "Waypoint-MapPin-Untracked", 23)
                end

                -- local type = frame:GetObjectType()
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