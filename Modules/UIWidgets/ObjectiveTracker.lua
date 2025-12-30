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
    -- trackerContainer = AF.CreateScrollFrame(AF.UIParent, "BFI_ObjectiveTrackerContainer", 275, nil, "none", "none")
    trackerContainer = AF.CreateFrame(AF.UIParent, "BFI_ObjectiveTrackerContainer", 275)

    -- background
    -- local background = AF.CreateTexture(tracker, nil, AF.GetColorTable("background", 0.5), "BACKGROUND")
    -- trackerContainer.background = background
    -- background:SetPoint("TOPLEFT", tracker.NineSlice)
    -- -- background:SetPoint("TOPRIGHT", trackerContainer)
    -- background:SetPoint("BOTTOMRIGHT", tracker.NineSlice)

    -- mover
    AF.CreateMover(trackerContainer, "BFI: " .. L["UI Widgets"], _G.HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
--[[
local function ApplyModuleOrder()
    local order = W.config.objectiveTracker.order

    -- simulate container allocation: start with availableHeight
    local availableHeight = tracker:GetAvailableHeight()
    print("ObjectiveTracker availableHeight:", availableHeight)

    -- update modules in configured order, allocating availableHeight sequentially
    for _, moduleName in ipairs(order) do
        local module = _G[moduleName]
        if module then
            module:Update(availableHeight, false) --! SHIIT, TAINT
            local heightUsed = module:GetContentsHeight()
            if heightUsed > 0 then
                availableHeight = availableHeight - heightUsed
            end
            if module:IsTruncated() then
                availableHeight = 0
            end
        end
    end

    -- reposition visuals according to configured order (do not alter tracker.modules)
    for _, module in next, tracker.modules do
        module:ClearAllPoints() -- NOTE: prevent "Cannot anchor to a region dependent on it"
    end

    local prevModule
    for _, moduleName in ipairs(order) do
        local module = _G[moduleName]
        if module then
            local heightUsed = module:GetContentsHeight()
            if heightUsed > 0 then
                if prevModule then
                    AF.FrameSetPoint(module, "TOP", prevModule, "BOTTOM", 0, -tracker.moduleSpacing)
                else
                    AF.FrameSetPoint(module, "TOP", 0, -tracker.topModulePadding)
                end
                AF.FrameSetPoint(module, "LEFT", module.leftMargin, 0)
                prevModule = module
            end
        end
    end
end
]]

--[[ --! TAINT
local function SetupOrder(_, dirtyUpdate, skip)
    local order = W.config.objectiveTracker.order
    order = AF.TransposeTable(order)

    table.sort(tracker.modules, function(a, b)
        local aIndex = order[a:GetName()] or math.huge
        local bIndex = order[b:GetName()] or math.huge
        return aIndex < bIndex
    end)
    tracker.needsSorting = false

    tracker:Update(false, true)
end
]]

local function SetupTracker()
    F.DisableEditMode(tracker)
    -- tracker.topModulePadding = 20 + 10 -- 38 --! TAINT
    -- tracker.moduleSpacing = 7 -- 10
    tracker:SetClampedToScreen(false)

    --------------------------------------------------
    -- parent & position
    --------------------------------------------------
    -- tracker.systemInfo.isInDefaultPosition = false
    tracker.IsInDefaultPosition = AF.noop_false -- REVIEW: TAINT?
    tracker.ignoreFramePositionManager = true
    tracker.isManagedFrame = false
    tracker.isRightManagedFrame = false
    _G.UIParentRightManagedFrameContainer:RemoveManagedFrame(tracker)
    -- tracker:SetParent(trackerContainer) --! will cause weird issues ... so I give up on making it scrollable
    tracker:ClearAllPoints()
    tracker:SetPoint("TOPRIGHT", trackerContainer.scrollContent)
    -- tracker:SetScript("OnShow", function(self)
    --     self:UpdateHeight()
    -- end)
    -- tracker:SetScript("OnHide", nil)
    -- hooksecurefunc(tracker, "Hide", function()
    --     AF.PrintStack()
    -- end)
    hooksecurefunc(tracker, "SetPoint", function()
        tracker:ClearAllPoints()
        AF.FrameSetPoint(tracker, "TOPRIGHT", trackerContainer)
    end)
    -- hooksecurefunc(tracker, "UpdateHeight", function()
    --     print(tracker:GetHeight())
    -- end)

    --------------------------------------------------
    -- header style
    --------------------------------------------------
    local function UpdateHeaderStyle(module)
        local header = module.Header
        -- module.headerHeight = 20 --! TAINT
        header:SetHeight(20)

        header.Text:SetTextColor(AF.GetColorRGB("BFI"))
        header.Background:Hide()
        -- header.MinimizeButton:Hide()
        header.MinimizeButton:SetAllPoints(header)
        S.RemoveTextures(header.MinimizeButton, true)

        local underline = AF.CreateSeparator(header, nil, 1, "BFI", AF.GetColorTable("BFI", 0))
        header.underline = underline
        AF.SetPoint(underline, "BOTTOMLEFT", 1, 1)
        AF.SetPoint(underline, "BOTTOMRIGHT", -1, 1)

        local highlight = AF.CreateGradientTexture(header, "HORIZONTAL", AF.GetColorTable("BFI", 0.5), AF.GetColorTable("BFI", 0), nil, "BACKGROUND")
        header.highlight = highlight
        AF.SetPoint(highlight, "TOPLEFT", 1, 0)
        AF.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
        highlight:Hide()

        header.MinimizeButton:HookScript("OnEnter", function()
            header.Text:SetTextColor(AF.GetColorRGB("white"))
            highlight:Show()
        end)
        header.MinimizeButton:HookScript("OnLeave", function()
            header.Text:SetTextColor(AF.GetColorRGB("BFI"))
            highlight:Hide()
        end)
        -- header:SetScript("OnMouseDown", function()
        --     module:ToggleCollapsed() --! TAINT
        -- end)

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
    -- module & scroll content height
    --------------------------------------------------
    -- local function UpdateScrollContentHeight()
    --     local height = tracker.topModulePadding
    --     for _, module in next, tracker.modules do
    --         local moduleHeight = module:GetContentsHeight()
    --         if moduleHeight > 0 then
    --             height = height + moduleHeight + tracker.moduleSpacing
    --         end
    --     end
    --     trackerContainer:SetContentHeight(height, true, true)
    -- end

    local function UpdateHeaderAnimation(header)
        S.RemoveTextures(header)
    end

    hooksecurefunc(tracker, "AddModule", function(_, module)
        -- print("MODULE ADDED:", module.headerText)
        if not module._BFIHooked then
            module._BFIHooked = true
            -- hooksecurefunc(module, "UpdateHeight", UpdateScrollContentHeight)
            -- hooksecurefunc(module, "Hide", UpdateScrollContentHeight)
            UpdateHeaderAnimation(module.Header)
            UpdateHeaderStyle(module)
        end
    end)

    --------------------------------------------------
    -- update order --! TAINT everywhere, no idea how to make it work
    --------------------------------------------------
    -- -- hooksecurefunc(tracker, "Update", ApplyModuleOrder)
    -- -- hooksecurefunc(tracker, "MarkDirty", ApplyModuleOrder)
    -- hooksecurefunc(tracker, "Show", ApplyModuleOrder)

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

--! TAINT
-- local function SetupOrder(order)
--     -- ObjectiveTrackerManager:OnPlayerEnteringWorld
--     -- print(GetTime(), "SetupOrder called")
--     local orderedModules = {}
--     for i, moduleName in ipairs(order) do
--         tinsert(orderedModules, _G[moduleName])
--     end
--     manager:AssignModulesOrder(orderedModules, true) --! TAINT, modified .uiOrder
--     for i, module in ipairs(orderedModules) do
--         manager:SetModuleContainer(module, tracker)
--     end
--     manager:UpdateAll()
-- end

local function SetupManager()
    -- hooksecurefunc(manager, "OnPlayerEnteringWorld", function(_, isInitialLogin, isReloadingUI)
    --     if not (isInitialLogin or isReloadingUI) then return end
    -- end)
    -- hooksecurefunc(manager, "AssignModulesOrder", function(_, _, override)
    --     if not override then
    --         SetupOrder(W.config.objectiveTracker.order)
    --     end
    -- end)

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
    -- scenarioTracker.lineSpacing = 7 --! TAINT

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
    local font = W.config.objectiveTracker.font

    local function UpdateProgressBar(self, key)
        local bar = self.usedProgressBars[key].Bar
        if bar and not bar._BFIStyled then
            S.StyleStatusBar(bar, 1)
            if bar.Label then
                AF.SetFont(bar.Label, font)
                bar.Label:SetPoint("CENTER")
            end
        end
    end

    local function UpdateTimerBar(self, key)
        local bar = self.usedTimerBars[key].Bar
        if bar and not bar._BFIStyled then
            S.StyleStatusBar(bar, 1)
            AF.SetFont(bar.Label, font)
            bar.Label:SetPoint("CENTER")
        end
    end

    -- local function UpdatePOIButton(self, quest)
    --     local questID = quest:GetID()
    --     -- local block, isExistingBlock = questTracker:GetBlock(questID)
    --     local block = self.usedBlocks[self.blockTemplate][questID]
    --     if block and block.poiButton then
    --         block.poiButton:SetScale(0.85)
    --     end
    -- end
    -- hooksecurefunc(_G.QuestObjectiveTracker, "UpdateSingle", UpdatePOIButton)

    local function StyleItemButton(button)
        if button._BFIStyled then return end
        button:SetNormalTexture(AF.GetEmptyTexture())
        button:SetPushedTexture(AF.GetEmptyTexture())
        button:GetHighlightTexture():SetColorTexture(AF.GetColorRGB("highlight"))
        S.StyleIcon(button.icon, true)
    end

    local function UpdateBlock(self, block)
        if block.poiButton then
            block.poiButton:SetScale(0.85)
        end
        if block.ItemButton then
            StyleItemButton(block.ItemButton)
        end
    end

    -- hooksecurefunc(CampaignQuestObjectiveTracker, "GetRightEdgeFrame", function(_, settings, identifier)
    --     print(tostring(settings) .. identifier)
    -- end)

    local trackers = {
        _G.QuestObjectiveTracker,
        _G.CampaignQuestObjectiveTracker,
    }

    for _, tracker in next, trackers do
        hooksecurefunc(tracker, "GetProgressBar", UpdateProgressBar)
        hooksecurefunc(tracker, "GetTimerBar", UpdateTimerBar)
        hooksecurefunc(tracker, "AddBlock", UpdateBlock)
    end
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
    AF.SetFont(scenarioTracker.StageBlock.Stage, font, font[2] + 4) -- QuestTitleFont -> QuestFont_Shadow_Huge -> QuestFont_Huge
    AF.SetFont(scenarioTracker.StageBlock.CompleteLabel, font, font[2] + 4) -- QuestTitleFont -> QuestFont_Shadow_Huge -> QuestFont_Huge
    AF.SetFont(scenarioTracker.StageBlock.Name, font, font[2] + 1) -- GameFontNormal -> SystemFont_Shadow_Med1
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
    -- hooksecurefunc(tracker, "Show", function()
    --     print("ObjectiveTrackerFrame Show")
    -- end)
    -- hooksecurefunc(tracker, "Hide", function()
    --     AF.PrintStack()
    -- end)
    -- hooksecurefunc(tracker, "SetShown", function(_, shown)
    --     print("ObjectiveTrackerFrame SetShown", shown)
    -- end)

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

    -- height
    trackerContainer:SetHeight(config.height)
    tracker.editModeHeight = config.height
    tracker:UpdateHeight()

    -- font
    UpdateFonts(config.font)
    tracker:Update()

    -- order
    -- if which == "objectiveTracker" then
    --     ApplyModuleOrder()
    -- end

    -- mover
    AF.UpdateMoverSave(trackerContainer, config.position)

    -- position
    AF.LoadPosition(trackerContainer, config.position)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateObjectiveTracker)