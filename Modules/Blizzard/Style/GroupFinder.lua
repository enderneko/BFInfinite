---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local pveFrame = _G.PVEFrame
local GroupFinderFrame = _G.GroupFinderFrame

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
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
        self.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget_highlight"))
    end)
    button:HookScript("OnLeave", function(self)
        self.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    end)
end

local function StyleRoleButton(button)
    -- LFDRoleButtonTemplate -> LFGRoleButtonWithBackgroundAndRewardTemplate -> LFGRoleButtonWithBackgroundTemplate -> LFGRoleButtonTemplate

    -- background
    if button.background then
        hooksecurefunc(button.background, "Hide", function(self)
            self:Show()
            self:SetDesaturated(true)
        end)
        hooksecurefunc(button.background, "Show", function(self)
            self:SetDesaturated(false)
        end)
    end

    -- incentiveIcon

    -- checkButton
    button.checkButton:SetScale(1)
    S.StyleCheckButton(button.checkButton, 14)
    button.checkButton.BFIBackdrop:ClearAllPoints()
    button.checkButton.BFIBackdrop:SetPoint("BOTTOMLEFT", 2, 2)
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
            AF.SetPoint(tab, "TOPLEFT", pveFrame, "BOTTOMLEFT", 0, -1)
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
    S.StyleTitledFrame(pveFrame)
    F.Hide(_G.PVEFrameLeftInset)
    F.Hide(pveFrame.shadows)
    S.RemoveTextures(pveFrame)

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
    S.RemoveTextures(_G.LFDParentFrame)
    _G.LFDQueueFrameBackground:Hide()
    _G.LFDParentFrameInset:Hide()

    local LFDQueueFrame = _G.LFDQueueFrame
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

            S.StyleIconButton(frame.expandOrCollapseButton, "red", AF.GetIcon("Plus_Small"), 12)
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
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    StyleTabs()
    StylePVEFrame()
    StyleLFDQueueFrame()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)