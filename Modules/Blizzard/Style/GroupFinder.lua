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
    button.bg:Hide()
    button.ring:Hide()
    button.CircleMask:Hide()

    local mask = button:CreateMaskTexture()
    button.iconMask = mask
    mask:SetTexture(AF.GetTexture("Square_Soft_Edge"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    AF.SetInside(mask, button.icon, 7)
    button.icon:AddMaskTexture(mask)

    AF.ClearPoints(button.icon)
    AF.SetPoint(button.icon, "LEFT", button, 5, 0)
    AF.SetSize(button.icon, 64, 64)

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

local function StyleRoleButton(button)
    -- LFDRoleButtonTemplate -> LFGRoleButtonWithBackgroundAndRewardTemplate -> LFGRoleButtonWithBackgroundTemplate -> LFGRoleButtonTemplate

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

    -- incentiveIcon

    -- checkButton
    button.checkButton:SetScale(1)
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
-- PVEFrame
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