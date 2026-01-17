---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local PVEFrame = _G.PVEFrame
local GroupFinderFrame = _G.GroupFinderFrame
local LFDQueueFrame = _G.LFDQueueFrame
local LFGListFrame = _G.LFGListFrame
local RaidFinderQueueFrame = _G.RaidFinderQueueFrame
local PVPQueueFrame
local WorldBattlesTexture -- atlasName

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function CreateBackground(frame)
    -- local bg = AF.CreateTexture(frame, nil, "background_lighter", "BACKGROUND")
    local bg = AF.CreateGradientTexture(frame, "HORIZONTAL", AF.GetColorTable("BFI", 0), AF.GetColorTable("BFI", 0.05), nil, "BACKGROUND")
    frame._BFIBackground = bg
    AF.SetPoint(bg, "TOPLEFT", PVEFrame, 200, 0)
    AF.SetPoint(bg, "BOTTOMRIGHT", -1, 1)
end

local function StyleGroupButton(button)
    -- S.StyleButton(button, "widget", "widget_highlight")
    button:ClearHighlightTexture()

    local bg = button.bg or button.Background
    bg:Hide()

    local ring = button.ring or button.Ring
    ring:Hide()

    button.CircleMask:Hide()

    local icon = button.icon or button.Icon
    AF.ClearPoints(icon)
    AF.SetPoint(icon, "LEFT", button, 5, 0)
    AF.SetSize(icon, 64, 64)

    local mask = button:CreateMaskTexture()
    button.iconMask = mask
    mask:SetTexture(AF.GetTexture("Square_Soft_Edge"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    AF.SetInside(mask, icon, 7)
    icon:AddMaskTexture(mask)

    S.CreateBackdrop(button)
    button.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    button:HookScript("OnEnter", function(self)
        if not self:IsEnabled() then return end
        self.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget_highlight"))
    end)
    button:HookScript("OnLeave", function(self)
        self.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    end)
end

local function SharedStyleRoleButton(button)
    -- incentiveIcon
    local incentiveIcon = button.incentiveIcon
    if incentiveIcon then
        if incentiveIcon.CircleMask then
            incentiveIcon.CircleMask:Hide()
        end
        incentiveIcon.border:Hide()
        S.StyleIcon(incentiveIcon.texture, true)
    end

    -- checkButton
    button.checkButton:SetScale(1)
end

local function StyleRoleButton(button)
    -- LFDRoleButtonTemplate -> LFGRoleButtonWithBackgroundAndRewardTemplate -> LFGRoleButtonWithBackgroundTemplate -> LFGRoleButtonTemplate
    SharedStyleRoleButton(button)

    -- background
    -- if button.background then
    --     hooksecurefunc(button.background, "Hide", function(self)
    --         self:Show()
    --         self:SetDesaturated(true)
    --     end)
    --     hooksecurefunc(button.background, "Show", function(self)
    --         self:SetDesaturated(false)
    --     end)
    -- end

    -- checkButton
    S.StyleCheckButton(button.checkButton, 14)
    button.checkButton.BFIBackdrop:ClearAllPoints()
    button.checkButton.BFIBackdrop:SetPoint("BOTTOMLEFT", 2, 2)
end

local function StyleRefreshButton(button)
    button:SetSize(24, 24)
    S.StyleIconButton(button, nil, 16, "yellow_text", "widget")
    button.BFIIcon:SetTexture(AF.GetIcon("Refresh_Round"), nil, nil, "TRILINEAR")
end

local function StyleColumnHeader(header)
    -- LFGListColumnHeaderTemplate
    header:DisableDrawLayer("BACKGROUND")
    S.CreateBackdrop(header)
    AF.ClearPoints(header.BFIBackdrop)
    AF.SetPoint(header.BFIBackdrop, "TOPLEFT")
    AF.SetPoint(header.BFIBackdrop, "BOTTOMRIGHT", -1, 0)
end

local function StyleOverlayFrame(frame)
    local name = frame:GetName()
    _G[name .. "BlackFilter"]:SetColorTexture(AF.GetColorRGB("mask", 0.95))

    local back = _G[name .. "BackfillButton"]
    if back then
        S.StyleButton(back, "red")
        back:SetSize(130, 20)
    end

    local noBack = _G[name .. "NoBackfillButton"]
    if noBack then
        S.StyleButton(noBack, "red")
        noBack:SetSize(130, 20)
    end

    local leaveQueueButton = _G[name .. "LeaveQueueButton"]
    if leaveQueueButton then
        S.StyleButton(leaveQueueButton, "red")
        leaveQueueButton:SetSize(130, 20)
    end
end

local function StyleRoleList(roleList)
    -- PVPRoleButtonTemplate -> LFGRoleButtonWithShortageRewardTemplate
    for _, button in next, roleList.RoleIcons do
        SharedStyleRoleButton(button)

        -- checkButton
        local checkButton = button.checkButton
        S.StyleCheckButton(checkButton, 12)
        AF.ClearPoints(checkButton.BFIBackdrop)
        checkButton.BFIBackdrop:SetPoint("BOTTOMLEFT", button, -1, -1)

        -- incentiveIcon
    end
end

local function StyleConquestBar(bar)
    S.StyleStatusBar(bar)
    bar.Border:Hide()
    bar.Background:Hide()

    local Reward = bar.Reward
    Reward:SetPoint("LEFT", bar, "RIGHT", -8, 0)
    Reward.Ring:Hide()
    Reward.CircleMask:Hide()
    S.StyleIcon(Reward.Icon, true)
end

local function StylePVPCasualActivityButton(button)
    -- PVPCasualStandardButtonTemplate -> PVPCasualActivityButton
    if button._BFIStyled then return end
    button._BFIStyled = true

    button.SelectedTexture:SetTexture(AF.GetEmptyTexture())
    button:SetNormalTexture(AF.GetEmptyTexture())
    button:SetPushedTexture(AF.GetEmptyTexture())

    S.CreateBackdrop(button, true)
    AF.ClearPoints(button.BFIBackdrop)
    AF.SetPoint(button.BFIBackdrop, "TOPLEFT")
    AF.SetPoint(button.BFIBackdrop, "BOTTOMRIGHT", 0, 2)

    local highlightTexture = button:GetHighlightTexture()
    AF.SetOnePixelInside(highlightTexture, button.BFIBackdrop)
    highlightTexture:SetTexture(AF.GetPlainTexture())
    highlightTexture:SetVertexColor(AF.GetColorRGB("highlight_add"))

    local bg = button.BFIBackdrop:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(button:GetParent().WorldBattlesTexture)
    bg:SetTexture(AF.GetTexture(WorldBattlesTexture, BFI.name))

    local mask = button.BFIBackdrop:CreateMaskTexture(nil, "BACKGROUND")
    mask:SetTexture(AF.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    bg:AddMaskTexture(mask)
    AF.SetOnePixelInside(mask, button.BFIBackdrop)

    -- "PushedTextOffset"
    button.Anchor:SetPoint("TOPLEFT", 0, 2)
    button.Anchor:SetPoint("BOTTOMRIGHT", 0, 2)
    button:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            self.Anchor:SetPoint("TOPLEFT", 0, 1)
            self.Anchor:SetPoint("BOTTOMRIGHT", 0, 1)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.Anchor:SetPoint("TOPLEFT", 0, 2)
        self.Anchor:SetPoint("BOTTOMRIGHT", 0, 2)
    end)
end

-- PVPInstanceListEntryButtonTemplate
local function StyleEntryButton(button)
    if button._BFIStyled then
        if button.SelectedTexture:IsShown() then
            button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
        else
            button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
        end
    else
        button._BFIStyled = true

        button.Bg:Hide()
        button.Border:Hide()
        button.SelectedTexture:SetTexture(AF.GetEmptyTexture())

        S.CreateBackdrop(button)
        AF.ClearPoints(button.BFIBackdrop)
        AF.SetPoint(button.BFIBackdrop, "TOPLEFT")
        AF.SetPoint(button.BFIBackdrop, "BOTTOMRIGHT", 0, 1)

        button.Icon:ClearAllPoints()
        button.Icon:SetPoint("LEFT", button.BFIBackdrop, 3, 0)
        button.Icon:SetSize(33, 33)
        S.StyleIcon(button.Icon, true)

        local NameText = button.NameText
        NameText:ClearAllPoints()
        NameText:SetPoint("LEFT", button.Icon, "RIGHT", 5, 0)

        local SizeText = button.SizeText
        SizeText:ClearAllPoints()
        SizeText:SetPoint("BOTTOMRIGHT", button.BFIBackdrop, "RIGHT", -7, 2)

        local InfoText = button.InfoText
        InfoText:ClearAllPoints()
        InfoText:SetPoint("TOPRIGHT", button.BFIBackdrop, "RIGHT", -7, -2)

        local highlightTexture = button:GetHighlightTexture()
        AF.SetOnePixelInside(highlightTexture, button.BFIBackdrop)
        highlightTexture:SetTexture(AF.GetPlainTexture())
        highlightTexture:SetVertexColor(AF.GetColorRGB("highlight_add"))
    end
end

---------------------------------------------------------------------
-- tabs
---------------------------------------------------------------------
local function StyleTabs()
    local i = 1
    local tab, last = _G["PVEFrameTab" .. i]

    while tab do
        S.StyleTab(tab)

        AF.ClearPoints(tab)
        if last then
            AF.SetPoint(tab, "TOPLEFT", last, "TOPRIGHT", 1, 0)
        else
            AF.SetPoint(tab, "TOPLEFT", PVEFrame, "BOTTOMLEFT", 0, -1)
        end
        last = tab

        i = i + 1
        tab = _G["PVEFrameTab" .. i]
    end
end

---------------------------------------------------------------------
--   _____   _____ ___
--  | _ \ \ / / __| __| _ __ _ _ __  ___
--  |  _/\ V /| _|| _| '_/ _` | '  \/ -_)
--  |_|   \_/ |___|_||_| \__,_|_|_|_\___|
--
---------------------------------------------------------------------
local function StylePVEFrame()
    S.StyleTitledFrame(PVEFrame)
    F.Hide(_G.PVEFrameLeftInset)
    F.Hide(PVEFrame.shadows)
    S.RemoveTextures(PVEFrame)

    -- local bg = AF.CreateGradientTexture(PVEFrame, "HORIZONTAL", AF.GetColorTable("BFI", 0), AF.GetColorTable("BFI", 0.05), nil, "BACKGROUND", 1)
    -- AF.SetPoint(bg, "TOPLEFT")
    -- AF.SetPoint(bg, "BOTTOMRIGHT", PVEFrame, "BOTTOMLEFT", 219, 0)

    -- GroupFinderGroupButtonTemplate
    for i = 1, 4 do
        StyleGroupButton(_G["GroupFinderFrameGroupButton" .. i])
    end

    hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
        for i = 1, 4 do
            local button = _G["GroupFinderFrameGroupButton" .. i]
            if i == index then
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
            else
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
            end
        end
    end)
end

---------------------------------------------------------------------
-- LFDQueueFrame
---------------------------------------------------------------------
local function StyleLFDQueueFrame()
    CreateBackground(LFDQueueFrame)

    S.RemoveTextures(_G.LFDParentFrame)
    _G.LFDQueueFrameBackground:Hide()
    _G.LFDParentFrameInset:Hide()

    S.StyleDropdownButton(LFDQueueFrame.TypeDropdown)
    S.StyleButton(_G.LFDQueueFrameFindGroupButton, "BFI")

    --------------------------------------------------
    -- role buttons
    --------------------------------------------------
    StyleRoleButton(_G.LFDQueueFrameRoleButtonTank)
    StyleRoleButton(_G.LFDQueueFrameRoleButtonHealer)
    StyleRoleButton(_G.LFDQueueFrameRoleButtonDPS)
    StyleRoleButton(_G.LFDQueueFrameRoleButtonLeader)

    --------------------------------------------------
    -- scroll
    --------------------------------------------------
    S.StyleScrollBar(LFDQueueFrame.Follower.ScrollBar)
    S.StyleScrollBar(LFDQueueFrame.Specific.ScrollBar)
    S.StyleScrollBar(_G.LFDQueueFrameRandomScrollFrame.ScrollBar)

    local function UpdateEach(frame, dungeonID, enabled, checkedList)
        if not frame.BFIStyled then
            frame.BFIStyled = true

            S.StyleIconButton(frame.expandOrCollapseButton, AF.GetIcon("Plus_Small"), 12, nil, "red")
            frame.expandOrCollapseButton:SetScript("OnMouseDown", nil)
            frame.expandOrCollapseButton:SetScript("OnMouseUp", nil)

            S.StyleCheckButton(frame.enableButton, 13)
        end

        -- 130751: Interface\\Buttons\\UI-CheckBox-Check
        -- 347250: Interface\\Buttons\\UI-MultiCheck-Up
        S.ReStyleCheckButtonTexture(frame.enableButton, checkedList[dungeonID] == 1)

        if frame.isCollapsed then
            frame.expandOrCollapseButton.BFIIcon:SetTexture(AF.GetIcon("Plus_Small"))
        else
            frame.expandOrCollapseButton.BFIIcon:SetTexture(AF.GetIcon("Minus_Small"))
        end
    end

    hooksecurefunc("LFGDungeonListButton_SetDungeon", UpdateEach)

    -- local function Update(scrollBox)
    --     scrollBox:ForEachFrame(UpdateEach)
    -- end
    -- hooksecurefunc(_G.LFDQueueFrameFollower.ScrollBox, "Update", Update)

    --------------------------------------------------
    -- overlays
    --------------------------------------------------
    StyleOverlayFrame(_G.LFDQueueFramePartyBackfill)
    _G.LFDQueueFramePartyBackfill:SetPoint("BOTTOMRIGHT", -6, 28)
    StyleOverlayFrame(_G.LFDQueueFrameNoLFDWhileLFR)
    _G.LFDQueueFrameNoLFDWhileLFR:SetPoint("BOTTOMRIGHT", -6, 28)

    --------------------------------------------------
    -- rewards
    --------------------------------------------------
    local rewardFrame = _G.LFDQueueFrameRandomScrollFrameChildFrame

    -- moneyReward - LargeItemButtonTemplate
    local moneyReward = rewardFrame.MoneyReward
    S.StyleLargeItemButton(rewardFrame.MoneyReward)

    -- LFGRewardsFrame_SetItemButton - LFGRewardsLootTemplate -> LargeItemButtonTemplate
    -- S.StyleLargeItemButton(_G.LFDQueueFrameRandomScrollFrameChildFrameItem1)
    local function UpdateItemButton(parentFrame, dungeonID, index, id, name, texture, numItems, rewardType, rewardID, quality, shortageIndex, showTankIcon, showHealerIcon, showDamageIcon)
        S.StyleLargeItemButton(_G[parentFrame:GetName() .. "Item" .. index])
    end
    hooksecurefunc("LFGRewardsFrame_SetItemButton", UpdateItemButton)
end

---------------------------------------------------------------------
-- RaidFinderQueueFrame
---------------------------------------------------------------------
local function StyleRaidFinderQueueFrame()
    CreateBackground(RaidFinderQueueFrame)

    _G.RaidFinderFrameRoleBackground:Hide()
    _G.RaidFinderFrameRoleInset:Hide()
    _G.RaidFinderFrameBottomInset:Hide()
    _G.RaidFinderQueueFrameBackground:Hide()

    S.StyleDropdownButton(RaidFinderQueueFrame.SelectionDropdown)
    S.StyleButton(_G.RaidFinderFrameFindRaidButton, "BFI")
    S.StyleScrollBar(_G.RaidFinderQueueFrameScrollFrame.ScrollBar)

    --------------------------------------------------
    -- role buttons
    --------------------------------------------------
    StyleRoleButton(_G.RaidFinderQueueFrameRoleButtonTank)
    StyleRoleButton(_G.RaidFinderQueueFrameRoleButtonHealer)
    StyleRoleButton(_G.RaidFinderQueueFrameRoleButtonDPS)
    StyleRoleButton(_G.RaidFinderQueueFrameRoleButtonLeader)

    --------------------------------------------------
    -- overlays
    --------------------------------------------------
    StyleOverlayFrame(_G.RaidFinderQueueFramePartyBackfill)
    _G.RaidFinderQueueFramePartyBackfill:SetPoint("BOTTOMRIGHT", -6, 30)
    StyleOverlayFrame(_G.RaidFinderQueueFrameIneligibleFrame)
    _G.RaidFinderQueueFrameIneligibleFrame:SetPoint("BOTTOMRIGHT", -6, 30)

    --------------------------------------------------
    -- rewards
    --------------------------------------------------
    local rewardFrame = _G.RaidFinderQueueFrameScrollFrameChildFrame

    -- moneyReward - LargeItemButtonTemplate
    local moneyReward = rewardFrame.MoneyReward
    S.StyleLargeItemButton(rewardFrame.MoneyReward)

    -- NOTE: RaidFinderQueueFrameRewards_UpdateFrame -> LFGRewardsFrame_UpdateFrame -> LFGRewardsFrame_SetItemButton
end

---------------------------------------------------------------------
-- LFGListFrame
---------------------------------------------------------------------
local HasSearchResultInfo = C_LFGList.HasSearchResultInfo
local GetApplicationInfo = C_LFGList.GetApplicationInfo
local UnitIsGroupLeader = UnitIsGroupLeader

local function StyleLFGListFrame()
    CreateBackground(_G.LFGListPVEStub)

    local CategorySelection = LFGListFrame.CategorySelection
    CategorySelection.Inset:Hide()

    S.StyleButton(CategorySelection.StartGroupButton, "BFI")
    S.StyleButton(CategorySelection.FindGroupButton, "BFI")

    CategorySelection.StartGroupButton:SetPoint("BOTTOMLEFT", 0, 4)

    -- LFGListCategoryTemplate - CategorySelection.CategoryButtons
    local function StyleCategoryButton(self, btnIndex, categoryID, filters)
        local button = self.CategoryButtons[btnIndex]

        if button._BFIStyled then
            local selected = self.selectedCategory == categoryID and self.selectedFilters == filters
            button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB(selected and "BFI" or "border"))
        else
            button._BFIStyled = true
            S.CreateBackdrop(button, true)

            button:SetPushedTextOffset(0, -1)
            button.Cover:Hide()
            button.Icon:SetAllPoints()
            button.SelectedTexture:SetTexture(AF.GetEmptyTexture())

            local highlightTexture = button:GetHighlightTexture()
            AF.SetOnePixelInside(highlightTexture, button.BFIBackdrop)
            highlightTexture:SetTexture(AF.GetPlainTexture())
            highlightTexture:SetVertexColor(AF.GetColorRGB("highlight_add"))
        end
    end

    hooksecurefunc("LFGListCategorySelection_AddButton", StyleCategoryButton)

    --------------------------------------------------
    -- SearchPanel
    --------------------------------------------------
    local SearchPanel = LFGListFrame.SearchPanel

    S.StyleButton(SearchPanel.BackButton, "BFI")
    S.StyleButton(SearchPanel.SignUpButton, "BFI")
    S.StyleButton(SearchPanel.BackToGroupButton, "BFI")
    S.StyleButton(SearchPanel.ScrollBox.StartGroupButton, "BFI")
    S.StyleScrollBar(SearchPanel.ScrollBar)

    local ResultsInset = SearchPanel.ResultsInset
    ResultsInset:SetPoint("TOPLEFT", 0, -81)
    ResultsInset:SetPoint("BOTTOMRIGHT", -25, 29)
    S.RemoveNineSliceAndBackground(ResultsInset)
    S.CreateBackdrop(ResultsInset)
    AF.SetOnePixelInside(SearchPanel.ScrollBox, ResultsInset)

    SearchPanel.BackButton:SetPoint("BOTTOMLEFT", 0, 4)
    SearchPanel.BackToGroupButton:SetPoint("BOTTOMLEFT", 0, 4)

    local FilterButton = SearchPanel.FilterButton
    S.StyleDropdownButton(FilterButton)
    FilterButton:SetHeight(20)

    local SearchBox = SearchPanel.SearchBox
    S.StyleEditBox(SearchBox, -4)
    SearchBox:SetHeight(20)
    SearchBox:ClearAllPoints()
    SearchBox:SetPoint("LEFT", ResultsInset, 4, 0)
    SearchBox:SetPoint("RIGHT", FilterButton, "LEFT", -2, 0)
    SearchBox:SetPoint("TOP", FilterButton)

    local RefreshButton = SearchPanel.RefreshButton
    StyleRefreshButton(RefreshButton)
    RefreshButton:ClearAllPoints()
    RefreshButton:SetPoint("CENTER", SearchPanel.CategoryName, 0, 1)
    RefreshButton:SetPoint("RIGHT", FilterButton)

    -- LFGListSearchEntryTemplate
    hooksecurefunc("LFGListSearchPanel_InitButton", function(button, elementData)
        if button._BFIStyled then return end
        button._BFIStyled = true

        button.Highlight:SetTexture(AF.GetPlainTexture())
        button.Highlight:SetVertexColor(AF.GetColorRGB("white", 0.08))

        button.CancelButton:SetSize(21, 21)
        S.StyleIconButton(button.CancelButton, AF.GetIcon("ReadyCheck_NotReady"), 16, nil, "widget")
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(button)
        button.BackgroundTexture:SetTexture(AF.GetPlainTexture())
        if button.isNowFilteredOut then
            button.BackgroundTexture:SetVertexColor(AF.GetColorRGB("red", 0.12))
        elseif button.isApplication then
            button.BackgroundTexture:SetVertexColor(AF.GetColorRGB("green", 0.12))
        elseif button.isSelected then
            button.BackgroundTexture:SetVertexColor(AF.GetColorRGB("yellow", 0.12))
        else
            -- button.BackgroundTexture:Hide()
        end
    end)

    --------------------------------------------------
    -- EntryCreation
    --------------------------------------------------
    local EntryCreation = LFGListFrame.EntryCreation

    EntryCreation.Inset:Hide()

    S.StyleDropdownButton(EntryCreation.GroupDropdown)
    S.StyleDropdownButton(EntryCreation.ActivityDropdown)
    S.StyleEditBox(EntryCreation.Name, -4)
    S.StyleInputScrollFrame(EntryCreation.Description)
    S.StyleDropdownButton(EntryCreation.PlayStyleDropdown)

    S.StyleEditBox(EntryCreation.ItemLevel.EditBox, -4)
    S.StyleCheckButton(EntryCreation.ItemLevel.CheckButton, 14)
    S.StyleEditBox(EntryCreation.PvpItemLevel.EditBox, -4)
    S.StyleCheckButton(EntryCreation.PvpItemLevel.CheckButton, 14)
    S.StyleEditBox(EntryCreation.PVPRating.EditBox, -4)
    S.StyleCheckButton(EntryCreation.PVPRating.CheckButton, 14)
    S.StyleEditBox(EntryCreation.MythicPlusRating.EditBox, -4)
    S.StyleCheckButton(EntryCreation.MythicPlusRating.CheckButton, 14)
    S.StyleEditBox(EntryCreation.VoiceChat.EditBox, -4)
    S.StyleCheckButton(EntryCreation.VoiceChat.CheckButton, 14)

    S.StyleCheckButton(EntryCreation.CrossFactionGroup.CheckButton, 14)
    S.StyleCheckButton(EntryCreation.PrivateGroup.CheckButton, 14)

    S.StyleButton(EntryCreation.CancelButton, "BFI")
    S.StyleButton(EntryCreation.ListGroupButton, "BFI")

    EntryCreation.CancelButton:SetPoint("BOTTOMLEFT", 0, 4)

    --------------------------------------------------
    -- EntryCreation.ActivityFinder
    --------------------------------------------------
    local ActivityFinder = EntryCreation.ActivityFinder
    ActivityFinder:SetPoint("TOPLEFT", -5, -21)
    ActivityFinder:SetPoint("BOTTOMRIGHT", -1, 2)

    ActivityFinder.Background:SetColorTexture(AF.GetColorRGB("mask", 0.5))

    local Dialog = ActivityFinder.Dialog
    Dialog.Bg:Hide()
    Dialog.Border:Hide()
    S.CreateBackdrop(Dialog)
    S.RemoveNineSliceAndBackground(Dialog.BorderFrame)
    S.CreateBackdrop(Dialog.BorderFrame)
    S.StyleEditBox(Dialog.EntryBox, -4)
    S.StyleScrollBar(Dialog.ScrollBar)
    S.StyleButton(Dialog.SelectButton, "BFI")
    S.StyleButton(Dialog.CancelButton, "BFI")

    hooksecurefunc("LFGListEntryCreationActivityFinder_InitButton", function(button, elementData)
        if button._BFIStyled then return end
        button._BFIStyled = true

        button:SetPushedTextOffset(0, 0)
        button.Selected:SetTexture(AF.GetPlainTexture())
        button.Selected:SetVertexColor(AF.GetColorRGB("highlight_add"))
    end)

    --------------------------------------------------
    -- ApplicationViewer
    --------------------------------------------------
    local ApplicationViewer = LFGListFrame.ApplicationViewer

    local InfoBackground = ApplicationViewer.InfoBackground
    S.CreateBackdrop(InfoBackground, true)
    InfoBackground:ClearAllPoints()
    InfoBackground:SetPoint("TOPLEFT", 0, -23)
    InfoBackground:SetSize(335, 95)
    InfoBackground:SetTexCoord(AF.CalcTexCoordPreCrop(0.1, 335 / 95, 333 / 96, nil, true))

    S.StyleCheckButton(ApplicationViewer.AutoAcceptButton, 14)

    local RefreshButton = ApplicationViewer.RefreshButton
    StyleRefreshButton(RefreshButton)
    RefreshButton:ClearAllPoints()
    RefreshButton:SetPoint("RIGHT", InfoBackground)
    RefreshButton:SetPoint("BOTTOM", ApplicationViewer.NameColumnHeader)

    -- ApplicationViewer.Inset:Hide()
    ApplicationViewer.Inset:SetPoint("TOPLEFT", 0, -150)
    ApplicationViewer.Inset:SetPoint("BOTTOMRIGHT", -25, 29)
    S.RemoveNineSliceAndBackground(ApplicationViewer.Inset)
    S.CreateBackdrop(ApplicationViewer.Inset)

    AF.SetOnePixelInside(ApplicationViewer.UnempoweredCover, ApplicationViewer.Inset)
    ApplicationViewer.UnempoweredCover.Background:SetColorTexture(AF.GetColorRGB("mask", 0.5))

    StyleColumnHeader(ApplicationViewer.NameColumnHeader)
    AF.AdjustPointsOffset(ApplicationViewer.NameColumnHeader, 0, 1)
    StyleColumnHeader(ApplicationViewer.RoleColumnHeader)
    StyleColumnHeader(ApplicationViewer.ItemLevelColumnHeader)
    StyleColumnHeader(ApplicationViewer.RatingColumnHeader)

    S.StyleScrollBar(ApplicationViewer.ScrollBar)
    S.StyleButton(ApplicationViewer.BrowseGroupsButton, "BFI")
    S.StyleButton(ApplicationViewer.RemoveEntryButton, "BFI")
    S.StyleButton(ApplicationViewer.EditButton, "BFI")

    ApplicationViewer.BrowseGroupsButton:SetPoint("BOTTOMLEFT", 0, 4)

    hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(self)
        self.RemoveEntryButton:ClearAllPoints()
        if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
            self.RemoveEntryButton:SetPoint("BOTTOMRIGHT", self.EditButton, "BOTTOMLEFT", -2, 0)
        else
            self.RemoveEntryButton:SetPoint("BOTTOMLEFT", 0, 4)
        end
    end)

    -- LFGListApplicantMemberTemplate
    hooksecurefunc("LFGListApplicationViewer_InitButton", function(button, elementData)
        if button._BFIStyled then return end
        button._BFIStyled = true

        -- button.DeclineButton:SetSize(21, 21)
        S.StyleIconButton(button.DeclineButton, AF.GetIcon("ReadyCheck_NotReady"), 16, nil, "widget")
        S.StyleButton(button.InviteButton, "widget")
        -- button.InviteButtonSmall:SetSize(21, 21)
        S.StyleIconButton(button.InviteButtonSmall, AF.GetIcon("ReadyCheck_Ready"), 16, nil, "widget")
    end)

    -- hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button, id)
    --     button.InviteButton:Hide()
    --     button.InviteButtonSmall:Show()
    -- end)
end

---------------------------------------------------------------------
-- LFDRoleCheckPopup
---------------------------------------------------------------------
local function StyleLFDRoleCheckPopup()

end

---------------------------------------------------------------------
-- LFGInvitePopup
---------------------------------------------------------------------
local function StyleLFGInvitePopup()
    --[[ test code - (inviter, roleTankAvailable, roleHealerAvailable, roleDamagerAvailable, allowMultipleRoles, isQuestSessionActive)
    LFGInvitePopup_Update("BB7", true, true, true, true, true)
    LFGInvitePopup:SetPoint("CENTER")
    LFGInvitePopup:Show()
    ]]
end

-- TODO: LFGDungeonReadyDialog

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    StyleTabs()

    StylePVEFrame()
    StyleLFDQueueFrame()
    StyleLFGListFrame()
    StyleRaidFinderQueueFrame()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)


---------------------------------------------------------------------
--   _____   _____ _   _ ___ ___
--  | _ \ \ / / _ \ | | |_ _| __| _ __ _ _ __  ___
--  |  _/\ V /|  _/ |_| || || _| '_/ _` | '  \/ -_)
--  |_|   \_/ |_|  \___/|___|_||_| \__,_|_|_|_\___|
--
---------------------------------------------------------------------
local function StylePVPUIFrame()
    PVPQueueFrame = _G.PVPQueueFrame

    for _, button in next, PVPQueueFrame.CategoryButtons do
        StyleGroupButton(button)
    end

    hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
        for i = 1, 4 do
            local button = PVPQueueFrame.CategoryButtons[i]
            if i == index then
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
            else
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
            end
        end
    end)

    --  hooksecurefunc("PVPUIFrame_UpdateRoleShortages", function(roleShortageBonus, roleButtons)
    --     for _, button in next, roleButtons do
    --         button:EnableRoleShortagePulseAnim(true)
    --     end
    -- end)
end

---------------------------------------------------------------------
-- HonorFrame
---------------------------------------------------------------------
local function StyleHonorFrame()
    local HonorFrame = _G.HonorFrame
    HonorFrame.Inset:Hide()
    StyleConquestBar(HonorFrame.ConquestBar)
    StyleRoleList(HonorFrame.RoleList)
    S.StyleDropdownButton(HonorFrame.TypeDropdown)
    S.StyleButton(HonorFrame.QueueButton, "BFI")

    --------------------------------------------------
    -- BonusFrame
    --------------------------------------------------
    local BonusFrame = HonorFrame.BonusFrame
    BonusFrame.ShadowOverlay:Hide()

    WorldBattlesTexture = BonusFrame.WorldBattlesTexture:GetAtlas()
    BonusFrame.WorldBattlesTexture:Hide()

    local buttons = {
		BonusFrame.RandomBGButton,
		BonusFrame.Arena1Button,
		BonusFrame.RandomEpicBGButton,
		BonusFrame.BrawlButton,
		BonusFrame.BrawlButton2,
	}

    hooksecurefunc("HonorFrameBonusFrame_Update", function()
        for _, button in next, buttons do
            StylePVPCasualActivityButton(button)
            -- check selection
            if BonusFrame.selectedButton == button then
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
            end
            -- test
            -- button.Reward.EnlistmentBonus:Show()
            -- button.Reward.RoleShortageBonus:Show()
            -- button.Reward.RoleShortageBonus.Icon:SetTexture(QUESTION_MARK_ICON)
        end
    end)

    hooksecurefunc("HonorFrameBonusFrame_SetButtonState", function(button, enable, minLevel)
        if button.BFIBackdrop and not enable then
            button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
        end
    end)

    hooksecurefunc("HonorFrameBonusFrame_SelectButton", function(button)
        if not button.BFIBackdrop then return end
        for _, b in next, buttons do
            if b == button then
                b.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
            else
                b.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
            end
        end
    end)

    hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, honor, experience, itemRewards, currencyRewards, roleShortageBonus)
        -- Reward: PVPCasualStandardButtonTemplate -> PVPRewardTemplate
        if not rewardFrame._BFIStyled then
            rewardFrame._BFIStyled = true
            rewardFrame:SetSize(34, 34)
            rewardFrame:SetHitRectInsets(0, 0, 0, 0)
            rewardFrame.Border:Hide()
            rewardFrame.Icon:RemoveMaskTexture(rewardFrame.CircleMask)
            rewardFrame.Icon:SetAllPoints()
            S.StyleIcon(rewardFrame.Icon, true)

            -- EnlistmentBonus
            local EnlistmentBonus = rewardFrame.EnlistmentBonus
            EnlistmentBonus:DisableDrawLayer("ARTWORK") -- honorsystem-icon-enlistmentbonus
            EnlistmentBonus:SetSize(16, 16)
            EnlistmentBonus:ClearAllPoints()
            EnlistmentBonus:SetPoint("CENTER", rewardFrame.Icon, "TOPRIGHT", -4, -4)
            AF.SetFrameLevel(EnlistmentBonus, 2)
            AF.ShowNormalGlow(EnlistmentBonus, "sand", 3)
            EnlistmentBonus.Icon:SetAllPoints()
            S.StyleIcon(EnlistmentBonus.Icon, true)

            -- RoleShortageBonus
            local RoleShortageBonus = rewardFrame.RoleShortageBonus
            RoleShortageBonus.Border:Hide()
            RoleShortageBonus:SetSize(16, 16)
            RoleShortageBonus:ClearAllPoints()
            RoleShortageBonus:SetPoint("CENTER", rewardFrame.Icon, "TOPRIGHT", -4, -4)
            AF.SetFrameLevel(RoleShortageBonus, 2)
            AF.ShowNormalGlow(RoleShortageBonus, "sand", 3)
            RoleShortageBonus.Icon:SetAllPoints()
            RoleShortageBonus:DisableDrawLayer("OVERLAY") -- CircleMaskScalable
            S.StyleIcon(RoleShortageBonus.Icon, true)
        end

        if rewardFrame.itemID then
            AF.LoadItemQualityAsync(rewardFrame.itemID, function(quality)
                rewardFrame.Icon.BFIBackdrop:SetBackdropBorderColor(AF.GetItemQualityColor(quality))
            end)
        end
    end)

    --------------------------------------------------
    -- SpecificScrollBox
    --------------------------------------------------
    S.StyleScrollBar(HonorFrame.SpecificScrollBar)
    -- HonorFrame.SpecificScrollBox:GetView():SetPadding(0, 0, 0, 0, 2) -- TAINT!

    -- PVPSpecificBattlegroundButtonTemplate -> PVPInstanceListEntryButtonTemplate
    local function Update(scrollBox)
        scrollBox:ForEachFrame(StyleEntryButton)
    end
    hooksecurefunc(HonorFrame.SpecificScrollBox, "Update", Update)
    -- HonorFrame_InitSpecificButton
end

---------------------------------------------------------------------
-- HonorInset
---------------------------------------------------------------------
local function StyleHonorInset()
    local HonorInset = PVPQueueFrame.HonorInset
    S.RemoveNineSliceAndBackground(HonorInset)

    local bg = AF.CreateGradientTexture(HonorInset, "VERTICAL", "none", AF.GetColorTable(AF.player.faction, 0.75), nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 0, 5)
    bg:SetPoint("BOTTOMRIGHT", 0, -15)

    local mask = HonorInset:CreateMaskTexture()
    mask:SetTexture(AF.GetTexture("Square_Soft_Edge"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(bg)
    bg:AddMaskTexture(mask)
end

---------------------------------------------------------------------
-- TrainingGroundsFrame
---------------------------------------------------------------------
local function StyleTrainingGroundsFrame()
    local TrainingGroundsFrame = _G.TrainingGroundsFrame
    TrainingGroundsFrame.Inset:Hide()
    StyleConquestBar(TrainingGroundsFrame.ConquestBar)
    StyleRoleList(TrainingGroundsFrame.RoleList)
    S.StyleDropdownButton(TrainingGroundsFrame.TypeDropdown)
    S.StyleButton(TrainingGroundsFrame.QueueButton, "BFI")

    --------------------------------------------------
    -- BonusTrainingGroundList
    --------------------------------------------------
    local BonusTrainingGroundList = TrainingGroundsFrame.BonusTrainingGroundList
    BonusTrainingGroundList.ShadowOverlay:Hide()
    BonusTrainingGroundList.WorldBattlesTexture:Hide()

    for _, button in next, BonusTrainingGroundList.BonusTrainingGroundButtons do
        StylePVPCasualActivityButton(button)
    end

    hooksecurefunc(BonusTrainingGroundList, "SetSelectedQueueOption", function()
        for _, button in next, BonusTrainingGroundList.BonusTrainingGroundButtons do
            if button:IsEnabled() and button:IsSelected() then
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("BFI"))
            else
                button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
            end
        end
    end)

    --------------------------------------------------
    -- SpecificTrainingGroundList
    --------------------------------------------------
    local SpecificTrainingGroundList = TrainingGroundsFrame.SpecificTrainingGroundList
    S.StyleScrollBar(SpecificTrainingGroundList.ScrollBar)
    -- SpecificTrainingGroundList.ScrollBox:GetView():SetPadding(0, 0, 0, 0, 2) -- TAINT! (actually no taint for this, but for that in HonorFrame)

    -- PVPSpecificTrainingGroundButtonTemplate -> PVPInstanceListEntryButtonTemplate
    local function Update(scrollBox)
        scrollBox:ForEachFrame(StyleEntryButton)
    end
    hooksecurefunc(SpecificTrainingGroundList.ScrollBox, "Update", Update)

    -- local selectionBehavior = ScrollUtil.AddSelectionBehavior(SpecificTrainingGroundList.ScrollBox, SelectionBehaviorFlags.Intrusive)
    -- selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
    --     local button = SpecificTrainingGroundList.ScrollBox:FindFrame(elementData)
    --     if button then
    --         print(selected)
    --     end
    -- end, SpecificTrainingGroundList)
end

---------------------------------------------------------------------
-- NewSeasonPopup
---------------------------------------------------------------------
local function StyleNewSeasonPopup()
    local NewSeasonPopup = PVPQueueFrame.NewSeasonPopup
    S.RemoveTextures(NewSeasonPopup)
    S.StyleButton(NewSeasonPopup.Leave, "BFI")

    S.CreateBackdrop(NewSeasonPopup)

    local BFIBackdrop = NewSeasonPopup.BFIBackdrop
    BFIBackdrop:EnableMouse(true)
    AF.ClearPoints(BFIBackdrop)
    AF.SetPoint(BFIBackdrop, "LEFT")
    AF.SetPoint(BFIBackdrop, "TOP", PVEFrame.BFIHeader, "BOTTOM", 0, -1)
    AF.SetPoint(BFIBackdrop, "BOTTOMRIGHT", PVEFrame.BFIBg, -2, 2)
    BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget", 0.99))

    --------------------------------------------------
    -- reward
    --------------------------------------------------
    local SeasonRewardFrame = NewSeasonPopup.SeasonRewardFrame
    SeasonRewardFrame.CircleMask:Hide()
    SeasonRewardFrame.Ring:Hide()
    S.StyleIcon(SeasonRewardFrame.Icon, true)

    hooksecurefunc(SeasonRewardFrame, "Update", function(self)
        if self.rewardItemID then
            AF.LoadItemQualityAsync(self.rewardItemID, function(quality)
                self.Icon.BFIBackdrop:SetBackdropBorderColor(AF.GetItemQualityColor(quality))
            end)
        end
    end)

    --------------------------------------------------
    -- texts
    --------------------------------------------------
    local function UpdateText(text, color)
        text:SetTextColor(AF.GetColorRGB(color))
        text:SetShadowColor(AF.GetColorRGB("black"))
        text:SetShadowOffset(1, -1)
    end

    NewSeasonPopup:HookScript("OnShow", function(self)
        UpdateText(self.NewSeason, "yellow_text")
        UpdateText(self.SeasonDescriptionHeader, "white")
        for _, text in next, self.SeasonDescriptions do
            UpdateText(text, "white")
        end
        UpdateText(self.SeasonRewardText, "yellow_text")
    end)
end

---------------------------------------------------------------------
-- ConquestFrame
---------------------------------------------------------------------
local function StyleConquestFrame()
    local ConquestFrame = _G.ConquestFrame
    ConquestFrame.Inset:Hide()
    StyleConquestBar(ConquestFrame.ConquestBar)
    StyleRoleList(ConquestFrame.RoleList)
    S.StyleButton(ConquestFrame.JoinButton, "BFI")
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
AF.RegisterAddonLoaded("Blizzard_PVPUI", function()
    StylePVPUIFrame()
    StyleHonorFrame()
    StyleHonorInset()
    StyleTrainingGroundsFrame()
    StyleNewSeasonPopup()
    StyleConquestFrame()
end)