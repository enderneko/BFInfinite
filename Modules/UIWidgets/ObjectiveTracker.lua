---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local W = BFI.modules.UIWidgets
local S = BFI.modules.Style
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local tracker = _G.ObjectiveTrackerFrame
local manager = _G.ObjectiveTrackerManager

local scenarioTracker = _G.ScenarioObjectiveTracker
local rewardsFrame = _G.ScenarioRewardsFrame

local trackerContainer

local GenerateClosure = GenerateClosure

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTrackerContainer()
    trackerContainer = AF.CreateScrollFrame(AF.UIParent, "BFI_ObjectiveTrackerContainer", 275, nil, "none", "none")

    -- mover
    AF.CreateMover(trackerContainer, "BFI: " .. L["UI Widgets"], _G.HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local function SetupTracker()
    F.DisableEditMode(tracker)
    tracker.isManagedFrame = false -- prevent re-parenting by Blizzard
    tracker.systemInfo.isInDefaultPosition = false
    tracker.editModeHeight = 1000
    tracker.topModulePadding = 20 + 10 -- 38
    tracker.moduleSpacing = 7 -- 10
    -- tracker.systemInfo.anchorInfo.point = "TOPRIGHT"
    -- tracker.systemInfo.anchorInfo.relativeTo = trackerContainer.scrollContent
    -- tracker.systemInfo.anchorInfo.relativePoint = "TOPRIGHT"
    -- tracker.systemInfo.anchorInfo.offsetX = 0
    -- tracker.systemInfo.anchorInfo.offsetY = 0
    tracker:SetClampedToScreen(false)

    --------------------------------------------------
    -- position
    --------------------------------------------------
    tracker:SetParent(trackerContainer.scrollContent)
    tracker:ClearAllPoints()
    tracker:SetPoint("TOPRIGHT", trackerContainer.scrollContent, "TOPRIGHT", 0, 0)
    hooksecurefunc(tracker, "SetPoint", function(_, _, relativeTo)
        if relativeTo ~= trackerContainer.scrollContent then
            tracker:ClearAllPoints()
            tracker:SetPoint("TOPRIGHT", trackerContainer.scrollContent, "TOPRIGHT", 0, 0)
        end
    end)

    --------------------------------------------------
    -- header style
    --------------------------------------------------
    local function UpdateHeaderStyle(module)
        local header = module.Header
        module.headerHeight = 20
        header:SetHeight(20)

        header.Text:SetTextColor(AF.GetColorRGB("BFI"))
        header.Background:Hide()
        header.MinimizeButton:Hide()
        header:SetScript("OnMouseDown", function()
            module:ToggleCollapsed()
        end)

        local underline = AF.CreateSeparator(header, nil, 1, "BFI", AF.GetColorTable("BFI", 0))
        header.underline = underline
        AF.SetPoint(underline, "BOTTOMLEFT", 1, 1)
        AF.SetPoint(underline, "BOTTOMRIGHT", -1, 1)

        local highlight = AF.CreateGradientTexture(header, "HORIZONTAL", AF.GetColorTable("BFI", 0.5), AF.GetColorTable("BFI", 0), nil, "BACKGROUND")
        header.highlight = highlight
        AF.SetPoint(highlight, "TOPLEFT", 1, 0)
        AF.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
        highlight:Hide()
        header:SetScript("OnEnter", function()
            header.Text:SetTextColor(AF.GetColorRGB("white"))
            highlight:Show()
        end)
        header:SetScript("OnLeave", function()
            header.Text:SetTextColor(AF.GetColorRGB("BFI"))
            highlight:Hide()
        end)

        if module == tracker then
            local originalWidth = header:GetWidth()
            hooksecurefunc(module, "SetCollapsed", function(_, collapsed)
                header:ClearAllPoints()
                if collapsed then
                    header:SetPoint("TOPRIGHT")
                    header:SetWidth(max(header.Text:GetStringWidth() + 30, 100))
                else
                    header:SetPoint("TOPLEFT")
                    header:SetWidth(originalWidth)
                end
            end)
        else
            hooksecurefunc(module, "SetCollapsed", function(_, collapsed)
                if collapsed then
                    underline:SetColor("darkgray", AF.GetColorTable("darkgray", 0))
                    highlight:SetColor("HORIZONTAL", AF.GetColorTable("darkgray", 0.5), AF.GetColorTable("darkgray", 0))
                else
                    underline:SetColor("BFI", AF.GetColorTable("BFI", 0))
                    highlight:SetColor("HORIZONTAL", AF.GetColorTable("BFI", 0.5), AF.GetColorTable("BFI", 0))
                end
            end)
        end
    end

    UpdateHeaderStyle(tracker)

    --------------------------------------------------
    -- scroll content height
    --------------------------------------------------
    local function UpdateScrollContentHeight()
        local height = tracker.topModulePadding
        for _, module in next, tracker.modules do
            local moduleHeight = module:GetContentsHeight()
            if moduleHeight > 0 then
                height = height + moduleHeight + tracker.moduleSpacing
            end
        end
        trackerContainer:SetContentHeight(height, true, true)
    end

    hooksecurefunc(tracker, "AddModule", function(_, module)
        -- print("MODULE ADDED:", module.headerText)
        if not module._BFIHooked then
            module._BFIHooked = true
            hooksecurefunc(module, "UpdateHeight", UpdateScrollContentHeight)
            hooksecurefunc(module, "Hide", UpdateScrollContentHeight)
            UpdateHeaderStyle(module)
        end
    end)

    -- hooksecurefunc(tracker, "RemoveModule", function(_, module)
    --     print("MODULE REMOVED:", module.headerText)
    -- end)

    -- hooksecurefunc(tracker, "RemoveAllModules", function()
    --     print("ALL MODULES REMOVED")
    -- end)
end

local function SetupReward_Main(main)
    main._BFIStyled = true

    main.Anim:Stop()
    main.Header:SetAlpha(1)
    main.Anim = main:CreateAnimationGroup()

    local dummy = main:CreateTexture(nil, "BACKGROUND")
    main.Anim.RewardsBottomAnim = main.Anim:CreateAnimation("Translation")
    main.Anim.RewardsBottomAnim:SetTarget(dummy)
    main.Anim.RewardsShadowAnim = main.Anim:CreateAnimation("Scale")
    main.Anim.RewardsShadowAnim:SetTarget(dummy)

    local top = AF.CreateTexture(main, AF.GetTexture("Gradient_Linear_Horizontal_CenterToEdges"), AF.GetColorTable("BFI", 0.7), "BACKGROUND")
    AF.SetPoint(top, "LEFT")
    AF.SetPoint(top, "RIGHT")
    AF.SetPoint(top, "TOP", main.Header, 0, 3)
    AF.SetPoint(top, "BOTTOM", main.Header, 0, -3)

    local fadeIn = main.Anim:CreateAnimation("Alpha")
    fadeIn:SetDuration(0.25)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetOrder(1)

    local alpha1 = main.Anim:CreateAnimation("Alpha")
    alpha1:SetDuration(0.5)
    alpha1:SetFromAlpha(0.7)
    alpha1:SetToAlpha(1)
    alpha1:SetOrder(1)
    alpha1:SetTarget(top)

    local alpha2 = main.Anim:CreateAnimation("Alpha")
    alpha2:SetDuration(0.5)
    alpha2:SetFromAlpha(1)
    alpha2:SetToAlpha(0.7)
    alpha2:SetStartDelay(0.2)
    alpha2:SetOrder(2)
    alpha2:SetTarget(top)

    local fadeOut = main.Anim:CreateAnimation("Alpha")
    fadeOut:SetDuration(1)
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetStartDelay(2.5)
    fadeOut:SetOrder(2)

    main.Anim:Play()
end

local function SetupReward_Sub(sub)
    sub._BFIStyled = true
    S.CreateBackdrop(sub.ItemIcon, true, nil, 1)
    sub:SetSize(27, 27)
    -- Anim
    sub.Anim:Stop()
    sub.Anim = sub:CreateAnimationGroup()
    -- ItemIcon
    sub.ItemIcon:SetSize(27, 27)
    AF.ApplyDefaultTexCoord(sub.ItemIcon)
    sub.ItemIcon:SetAlpha(1)
    -- ItemBorder
    sub.ItemBorder:Hide()
    sub.ItemBorder = AF.CreateGradientTexture(sub, "HORIZONTAL", "border", AF.GetColorTable("border", 0), AF.GetPlainTexture(), "BACKGROUND")
    sub.ItemBorder:SetPoint("TOPLEFT", sub.ItemIcon, "TOPRIGHT", 2, 0)
    sub.ItemBorder:SetPoint("BOTTOMLEFT", sub.ItemIcon, "BOTTOMRIGHT", 2, 0)
    sub.ItemBorder:SetWidth(81)
end

local function SetupOrder(order)
    -- ObjectiveTrackerManager:OnPlayerEnteringWorld
    -- print(GetTime(), "SetupOrder called")
    local orderedModules = {}
    for i, moduleName in ipairs(order) do
        tinsert(orderedModules, _G[moduleName])
    end
    manager:AssignModulesOrder(orderedModules, true)
    for i, module in ipairs(orderedModules) do
        manager:SetModuleContainer(module, tracker)
    end
    manager:UpdateAll()
end

local function SetupManager()
    -- hooksecurefunc(manager, "OnPlayerEnteringWorld", function(_, isInitialLogin, isReloadingUI)
    --     if not (isInitialLogin or isReloadingUI) then return end
    -- end)
    hooksecurefunc(manager, "AssignModulesOrder", function(_, _, override)
        if not override then
            SetupOrder(W.config.objectiveTracker.order)
        end
    end)

    --[[ NOTE: test code
    ObjectiveTrackerManager:ShowRewardsToast({
        {count = 1, font = "AF_FONT_NORMAL", label = "TEST1", texture = 7137575},
        {count = 2, font = "AF_FONT_NORMAL", label = "TEST2", texture = 7137575},
        {count = 3, font = "AF_FONT_NORMAL", label = "TEST3", texture = 7137575},
    }, ScenarioObjectiveTracker)

    ScenarioRewardsFrame:DisplayRewards(1000, 2000000)
    ]]

    hooksecurefunc(manager, "ShowRewardsToast", function()
        local font = W.config.objectiveTracker.font
        for toast in manager.rewardsToastPool:EnumerateActive() do
            AF.SetFont(toast.Header, font, font[2] + 1, "outline", false)

            if not toast._BFIStyled then
                SetupReward_Main(toast)
                toast.Anim:SetScript("OnFinished", GenerateClosure(toast.OnAnimateRewardsDone, toast))
            end

            for frame in toast.framePool:EnumerateActive() do
                AF.SetFont(frame.Label, font)
                if not frame._BFIStyled then
                    SetupReward_Sub(frame)
                end
            end
        end
    end)
end

local function SetupScenarioObjectiveTracker()
    -- scenarioTracker.fromHeaderOffsetY = -5
    scenarioTracker.lineSpacing = 7

    S.CreateBackdrop(scenarioTracker.StageBlock)
    AF.SetInside(scenarioTracker.StageBlock.BFIBackdrop, scenarioTracker.StageBlock.NormalBG, 3, 3)

    -- texture
    F.Hide(scenarioTracker.StageBlock.NormalBG)
    F.Hide(scenarioTracker.StageBlock.FinalBG)
    F.Hide(scenarioTracker.StageBlock.GlowTexture)

    rewardsFrame:SetScale(1)

    -- font
    hooksecurefunc(rewardsFrame, "DisplayRewards", function()
        local font = W.config.objectiveTracker.font
        AF.SetFont(rewardsFrame.Header, font, font[2] + 1, "outline", false)

        if not rewardsFrame._BFIStyled then
            SetupReward_Main(rewardsFrame)
            rewardsFrame.Anim:SetScript("OnFinished", GenerateClosure(rewardsFrame.OnAnimFinished, rewardsFrame))
        end

        for frame in rewardsFrame.framePool:EnumerateActive() do
            AF.SetFont(frame.Label, font)
            if not frame._BFIStyled then
                SetupReward_Sub(frame)
            end
        end
    end)
end

local function SetupQuestBlock()
    local function UpdatePOIButton(self, quest)
        local questID = quest:GetID()
        -- local block, isExistingBlock = questTracker:GetBlock(questID)
        local block = self.usedBlocks[self.blockTemplate][questID]
        if block and block.poiButton then
            block.poiButton:SetScale(0.85)
        end
    end
    hooksecurefunc(_G.QuestObjectiveTracker, "UpdateSingle", UpdatePOIButton)
    hooksecurefunc(_G.CampaignQuestObjectiveTracker, "UpdateSingle", UpdatePOIButton)

    local font = W.config.objectiveTracker.font

    local function UpdateProgressBar(self, key)
        local bar = self.usedProgressBars[key].Bar
        if bar and not bar._BFIStyled then
            S.StyleStatusBar(bar)
            if bar.Label then
                AF.SetFont(bar.Label, font)
                bar.Label:SetPoint("CENTER")
            end
        end
    end
    hooksecurefunc(_G.QuestObjectiveTracker, "GetProgressBar", UpdateProgressBar)
    hooksecurefunc(_G.CampaignQuestObjectiveTracker, "GetProgressBar", UpdateProgressBar)

    local function UpdateTimerBar(self, key)
        local bar = self.usedTimerBars[key].Bar
        if bar and not bar._BFIStyled then
            S.StyleStatusBar(bar)
            AF.SetFont(bar.Label, font)
            bar.Label:SetPoint("CENTER")
        end
    end
    hooksecurefunc(_G.QuestObjectiveTracker, "GetTimerBar", UpdateTimerBar)
    hooksecurefunc(_G.CampaignQuestObjectiveTracker, "GetTimerBar", UpdateTimerBar)
end

---------------------------------------------------------------------
-- fonts
---------------------------------------------------------------------
local function UpdateFonts(font)
    -- NOTE: some widgets require a reload to update fonts: progressBar, timerBar ...

    -- EditModeObjectiveTrackerSystemMixin:UpdateSystemSettingTextSize -> ObjectiveTrackerManager:SetTextSize
    AF.SetFont(ObjectiveTrackerLineFont, font)
    AF.SetFont(ObjectiveTrackerHeaderFont, font, font[2] + 1)

    -- ScenarioObjectiveTracker
    AF.SetFont(scenarioTracker.StageBlock.Stage, font, font[2] + 4) -- QuestTitleFont > QuestFont_Shadow_Huge > QuestFont_Huge
    AF.SetFont(scenarioTracker.StageBlock.CompleteLabel, font, font[2] + 4) -- QuestTitleFont > QuestFont_Shadow_Huge > QuestFont_Huge
    AF.SetFont(scenarioTracker.StageBlock.Name, font, font[2] + 1) -- GameFontNormal > SystemFont_Shadow_Med1
    if rewardsFrame.framePool then
        for frame in rewardsFrame.framePool:EnumerateActive() do
            AF.SetFont(frame.Label, font)
        end
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateObjectiveTracker(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "objectiveTracker" then return end

    local config = W.config.objectiveTracker
    if not config.enabled then
        -- do nothing here, since this requires a reload
        return
    end

    if not trackerContainer then
        CreateTrackerContainer()
        SetupTracker()
        SetupManager()
        SetupScenarioObjectiveTracker()
        SetupQuestBlock()
    end

    trackerContainer.enabled = true

    AF.SetHeight(trackerContainer, config.height)
    UpdateFonts(config.font)
    if which == "objectiveTracker" then
        SetupOrder(config.order)
    end

    -- mover
    AF.UpdateMoverSave(trackerContainer, config.position)

    -- position4
    AF.LoadPosition(trackerContainer, config.position)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateObjectiveTracker)