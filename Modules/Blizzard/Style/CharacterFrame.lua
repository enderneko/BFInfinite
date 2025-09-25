---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local _G = _G
local PANEL_INSET_BOTTOM_OFFSET = _G.PANEL_INSET_BOTTOM_OFFSET
local MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = _G.MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY
local PAPERDOLL_STATINFO = _G.PAPERDOLL_STATINFO
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION

local CharacterFrame = _G.CharacterFrame
local CharacterFrameInset = _G.CharacterFrameInset
local CharacterFrameInsetRight = _G.CharacterFrameInsetRight
local CharacterStatsPane = _G.CharacterStatsPane
local PaperDollFrame = _G.PaperDollFrame
local PaperDollItemsFrame = _G.PaperDollItemsFrame
local EquipmentFlyoutFrame = _G.EquipmentFlyoutFrame
local EquipmentFlyoutFrameHighlight = _G.EquipmentFlyoutFrameHighlight
local EquipmentFlyoutFrameButtons = _G.EquipmentFlyoutFrameButtons
local PaperDollSidebarTabs = _G.PaperDollSidebarTabs
local CharacterModelScene = _G.CharacterModelScene
local ReputationFrame = _G.ReputationFrame
local TokenFrame = _G.TokenFrame
local TokenFramePopup = _G.TokenFramePopup
local CurrencyTransferLog = _G.CurrencyTransferLog

local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo

---------------------------------------------------------------------
-- tabs
---------------------------------------------------------------------
local function StyleTabs()
    local i = 1
    local tab, last = _G["CharacterFrameTab" .. i]
    while tab do
        S.StyleTab(tab)

        AF.ClearPoints(tab)
        if last then
            AF.SetPoint(tab, "TOPLEFT", last, "TOPRIGHT", 1, 0)
        else
            AF.SetPoint(tab, "TOPLEFT", CharacterFrame, "BOTTOMLEFT", 0, -1)
        end
        last = tab

        i = i + 1
        tab = _G["CharacterFrameTab" .. i]
    end
end

---------------------------------------------------------------------
-- flyout
---------------------------------------------------------------------
local function EquipmentFlyout_UpdateItems()
    for _, button in next, EquipmentFlyoutFrame.buttons do
        if not button._BFIStyled then
            button._BFIStyled = true

            button:SetNormalTexture(AF.GetEmptyTexture())
            button:SetPushedTexture(AF.GetEmptyTexture())
            -- texplore(button)

            S.CreateBackdrop(button, true, nil, 1)
            S.StyleIcon(button.icon)
            S.StyleIconBorder(button.IconBorder)
            button.HighlightTexture:SetColorTexture(AF.GetColorRGB("button_highlight"))
        end

        -- button.location == _G.EQUIPMENTFLYOUT_IGNORESLOT_LOCATION or button.location == _G.EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION or button.location == _G.EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION then
        if type(button.location) == "number" and button.location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
            button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
        end

        AF.DefaultUpdatePixels(button.BFIBackdrop)
    end
end

-- local function EquipmentFlyout_DisplayButton(button)
--     if not button._BFIStyled then
--         button._BFIStyled = true

--         button:SetNormalTexture(AF.GetEmptyTexture())
--         button:SetPushedTexture(AF.GetEmptyTexture())
--         -- texplore(button)

--         S.CreateBackdrop(button, true, nil, 1)
--         S.StyleIcon(button.icon)
--         S.StyleIconBorder(button.IconBorder)
--         AF.RemoveFromPixelUpdater(button.BFIBackdrop)
--         button.HighlightTexture:SetColorTexture(AF.GetColorRGB("button_highlight"))
--     end

--     if button.location and button.location >= _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
--         button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
--     end

--     AF.DefaultUpdatePixels(button.BFIBackdrop)
-- end

local function StyleFlyout()
    -- flyout
    EquipmentFlyoutFrameHighlight:SetAlpha(0)
    -- .buttonFrame
    EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
    -- EquipmentFlyoutFrameButtons.bg2:SetAlpha(0)
	EquipmentFlyoutFrameButtons:DisableDrawLayer("ARTWORK")

    AF.ApplyDefaultBackdropWithColors(EquipmentFlyoutFrame, "none", "BFI")
    -- AF.AddToPixelUpdater_CustomGroup("BFIStyled", EquipmentFlyoutFrame)

    hooksecurefunc("EquipmentFlyout_Show", function(b)
        AF.ReBorder(EquipmentFlyoutFrame)
        AF.SetOutside(EquipmentFlyoutFrame, b, 2, 2)
    end)

    hooksecurefunc("EquipmentFlyout_UpdateItems", EquipmentFlyout_UpdateItems)
    -- hooksecurefunc("EquipmentFlyout_DisplayButton", EquipmentFlyout_DisplayButton)
end

---------------------------------------------------------------------
-- CharacterFrameInset
---------------------------------------------------------------------
-- local function UpdateSlotExtraInfo(slot)
--     if not slot.text then return end

--     local link = GetInventoryItemLink("player", slot:GetID())
--     if not link then
--         slot.text:SetText("")
--         return
--     end

--     local name = C_Item.GetItemNameByID(link) or ""
--     slot.text:SetText(name)
-- end

local function StyleSlots()
    local slots = {}
    -- Interface\AddOns\Blizzard_UIPanels_Game\Mainline\PaperDollFrame.xml
    AF.InsertAll(slots, PaperDollItemsFrame.EquipmentSlots, PaperDollItemsFrame.WeaponSlots)

    for _, slot in next,slots do
        S.RemoveTextures(slot)
        S.CreateBackdrop(slot, true, nil, 1)

        local name = slot:GetName()
        local icon = _G[name .. "IconTexture"]
        if icon then
            S.StyleIcon(icon)
        end

        slot.ignoreTexture:SetTexture("Interface/PaperDollInfoFrame/UI-GearManager-LeaveItem-Transparent") -- restore
        S.StyleIconBorder(slot.IconBorder)

        -- local text = AF.CreateFontString(slot)
        -- slot.text = text
        -- if slot.IsLeftSide == true then
        --     text:SetPoint("LEFT", slot, "RIGHT", 5, 0)
        -- elseif slot.IsLeftSide == false then
        --     text:SetPoint("RIGHT", slot, "LEFT", -5, 0)
        -- end
    end
end

local function StyleCharacterModelScene()
    local positions = {
        "Top",
        "TopLeft",
        "TopRight",
        "Left",
        "Right",
        "Bottom",
        "Bottom2",
        "BottomLeft",
        "BottomRight",
        "BotLeft",
        "BotRight",
    }

    for _, position in next, positions do
        -- border
        local tex = _G["PaperDollInnerBorder" .. position]
        if tex then tex:SetAlpha(0) end
        -- bg
        tex = _G["CharacterModelFrameBackground" .. position]
        if tex then tex:SetAlpha(0) end
    end

    CharacterModelScene:ClearAllPoints()
    CharacterModelScene:SetPoint("TOPLEFT", _G.CharacterHeadSlot, "TOPRIGHT", AF.ConvertPixels(5), 0)
    CharacterModelScene:SetPoint("BOTTOMRIGHT", _G.CharacterTrinket1Slot, "BOTTOMLEFT", -AF.ConvertPixels(5), 0)

    local overlay = _G.CharacterModelFrameBackgroundOverlay
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPLEFT", CharacterModelScene)
    overlay:SetPoint("BOTTOMRIGHT", CharacterModelScene)
    overlay:SetColorTexture(AF.GetColorRGB("widget"))
    S.CreateBackdrop(overlay, true, nil, 1)

    PaperDollFrame:HookScript("OnShow", function()
        CharacterModelScene.ControlFrame:Hide()
    end)
end

-- local function UpdateSize(self)
--     if self.activeSubframe == "PaperDollFrame" then
--         self.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 500, PANEL_INSET_BOTTOM_OFFSET)
--     end
-- end

local function PaperDollItemSlotButton_Update(slot)
    local highlightTexture = slot:GetHighlightTexture()
    highlightTexture:SetTexture(AF.GetPlainTexture())
    highlightTexture:SetVertexColor(AF.GetColorRGB("button_highlight"))
    AF.SetOnePixelInside(highlightTexture, slot)
end

local function StyleCharacterFrameInset()
    -- hooksecurefunc(CharacterFrame, "UpdateSize", UpdateSize)
    -- CharacterFrameInset:SetPoint("TOPLEFT", CharacterFrame.BFIHeader, "BOTTOMLEFT", PANEL_INSET_BOTTOM_OFFSET, -20)

    StyleSlots()
    StyleCharacterModelScene()
    hooksecurefunc("PaperDollItemSlotButton_Update", PaperDollItemSlotButton_Update)
end


---------------------------------------------------------------------
-- CharacterFrameInsetRight
---------------------------------------------------------------------
local PAPERDOLL_STATINFO = {
    CRITCHANCE = {
        updateFunc = function(statFrame, unit) PaperDollFrame_SetCritChance(statFrame, unit) end
    }
}

local function StyleStatsPaneCategory(frame)
    S.RemoveTextures(frame)
    AF.ApplyDefaultBackdropWithColors(frame)
    AF.SetSize(frame, 177, 19)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", frame)

    frame.Title:ClearAllPoints()
    frame.Title:SetPoint("CENTER")
    AF.UpdateFont(frame.Title, nil, 13)

    hooksecurefunc(frame, "SetPoint", function(_, point, anchorTo, relativePoint, xOffset, yOffset, fix)
        if not fix then
            frame:ClearAllPoints()
            frame:SetPoint(point, anchorTo, relativePoint, xOffset, yOffset - 10, true)
        end
    end)
end

local function PaperDollFrame_UpdateStats()
    for f in CharacterStatsPane.statsFramePool:EnumerateActive() do
        -- f.Background:SetAlpha(0)
        if f.Background:IsShown() then
            f.Background:SetTexture(AF.GetPlainTexture())
            f.Background:SetVertexColor(AF.GetColorRGB("darkgray", 0.1))
            f.Background:ClearAllPoints()
            f.Background:SetPoint("TOP")
            f.Background:SetPoint("BOTTOM")
            f.Background:SetPoint("LEFT", 5, 0)
            f.Background:SetPoint("RIGHT", -5, 0)
        end
    end

    -- cant use AdjustPointsOffset
    -- CharacterStatsPane.ItemLevelCategory:AdjustPointsOffset(0, -10)
    -- -- if UnitLevel("player") >= MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY then
    --     CharacterStatsPane.AttributesCategory:AdjustPointsOffset(0, -10)
    -- -- end
    -- CharacterStatsPane.EnhancementsCategory:AdjustPointsOffset(0, -10)
end

local function PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue)
    if label == _G.STAT_AVERAGE_ITEM_LEVEL then
        local _, ilvl = GetAverageItemLevel()
        ilvl = AF.RoundToDecimal(ilvl, 1)
        statFrame.Value:SetText(ilvl)
    elseif label == _G.STAT_HASTE then
        statFrame.Value:SetFormattedText("%.2f%%", numericValue)
    elseif isPercentage then
        if label == _G.STAT_VERSATILITY then
            -- numericValue = AF.RoundToDecimal(numericValue, 2)
            statFrame.Value:SetFormattedText("%.2f%%/%.2f%%", numericValue, numericValue / 2)
        else
            statFrame.Value:SetFormattedText("%.2f%%", numericValue)
        end
    end

    -- font
    if not statFrame._fontSizeUpdated then
        statFrame._fontSizeUpdated = true
        if label == _G.STAT_AVERAGE_ITEM_LEVEL then
            AF.UpdateFont(statFrame.Value, nil, 20 + BFI.vars.blizzardFontSizeDelta)
        else
            AF.UpdateFont(statFrame.Label, nil, 12 + BFI.vars.blizzardFontSizeDelta, "")
            AF.UpdateFont(statFrame.Value, nil, 12 + BFI.vars.blizzardFontSizeDelta, "")
        end
    end
end

local function PaperDollFrame_UpdateSidebarTabs()
    local i = 1
    local tab, last = _G["PaperDollSidebarTab" .. i]
    while tab do
        AF.ApplyDefaultBackdropWithColors(tab, "widget")
        AF.AddToPixelUpdater_CustomGroup("BFIStyled", tab)

        tab.TabBg:SetAlpha(0)

        tab.Hider:SetColorTexture(0, 0, 0, 0.75)
        tab.Hider:SetAllPoints(tab.Icon)

        tab.Highlight:SetColorTexture(AF.GetColorRGB("button_highlight"))
        tab.Highlight:SetAllPoints(tab.Icon)

        AF.SetOnePixelInside(tab.Icon, tab)
        if i == 1 then
            tab.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        end
        AF.AddToPixelUpdater_CustomGroup("BFIStyled", tab.Icon)

        i = i + 1
        tab = _G["PaperDollSidebarTab" .. i]
    end
end

local function TitleManagerPane_UpdateEach(button)
    if button._BFIStyled then return end
    button._BFIStyled = true

    button:DisableDrawLayer("BACKGROUND")
    button.SelectedBar:SetColorTexture(AF.GetColorRGB("sheet_highlight"))
    button.SelectedBar:SetAlpha(0.75)
    button:GetHighlightTexture():SetColorTexture(AF.GetColorRGB("sheet_highlight", 0.5))
end

local function TitleManagerPane_Update(frame)
    frame:ForEachFrame(TitleManagerPane_UpdateEach)
end

local function GearSetButton_OnEnter(self)
    if self.setID then
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        GameTooltip:SetEquipmentSet(self.setID)
    end
end

-- Modules\Tooltip\Tooltip.lua UpdateAnchor
local tooltip = {
    enabled = true,
    anchorTo = "self",
    position = {"TOPLEFT", "TOPRIGHT", 32, 0},
}

local function EquipmentManagerPane_UpdateEach(button)
    if button.icon.BFIBackdrop then
        button.icon.BFIBackdrop:SetShown(button.setID and true or false)
    end

    if button._BFIStyled then return end
    button._BFIStyled = true

    button:DisableDrawLayer("BACKGROUND")
    button.SelectedBar:SetColorTexture(AF.GetColorRGB("sheet_highlight"))
    button.SelectedBar:SetAlpha(0.75)
    button.HighlightBar:SetColorTexture(AF.GetColorRGB("sheet_highlight"))
    button.HighlightBar:SetAlpha(0.5)
    button.tooltip = tooltip

    S.StyleIcon(button.icon, true)
    AF.SetOnePixelOutside(button.icon.BFIBackdrop, button.icon)
    AF.SetFrameLevel(button.icon.BFIBackdrop, -1)
    button.icon.BFIBackdrop:SetShown(button.setID and true or false)
end

local function EquipmentManagerPane_Update(frame)
    frame:ForEachFrame(EquipmentManagerPane_UpdateEach)
end

local function StyleCharacterFrameInsetRight()
    -- tabs
    -- PaperDollSidebarTabs.DecorLeft:SetAlpha(0)
    -- PaperDollSidebarTabs.DecorRight:SetAlpha(0)
    S.RemoveTextures(PaperDollSidebarTabs)
    hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", PaperDollFrame_UpdateSidebarTabs)

    -- PaperDollSidebarTabs:ClearAllPoints()
    -- PaperDollSidebarTabs:SetPoint("TOPLEFT",CharacterFrameInset, "TOPRIGHT", 1, 0)
    -- PaperDollSidebarTabs:SetPoint("RIGHT",CharacterFrame, -4, 0)
    -- CharacterFrameInsetRight:SetPoint("TOPLEFT", PaperDollSidebarTabs, "BOTTOMLEFT", 0, -5)

    -- CharacterFrameInsetRight:SetPoint("TOPLEFT", CharacterFrameInset, "TOPRIGHT", 1, -25)
    -- PaperDollFrame.TitleManagerPane.ScrollBox:SetHeight(334)

    -- stats pane
    CharacterStatsPane.ItemLevelCategory:SetPoint("TOP", 0, -10)
    StyleStatsPaneCategory(CharacterStatsPane.ItemLevelCategory)
    StyleStatsPaneCategory(CharacterStatsPane.AttributesCategory)
    StyleStatsPaneCategory(CharacterStatsPane.EnhancementsCategory)

    S.RemoveTextures(CharacterStatsPane)
    S.RemoveTextures(CharacterStatsPane.ItemLevelFrame)
    CharacterStatsPane.ItemLevelFrame:SetHeight(30)

    hooksecurefunc("PaperDollFrame_UpdateStats", PaperDollFrame_UpdateStats)
    hooksecurefunc("PaperDollFrame_SetLabelAndText", PaperDollFrame_SetLabelAndText)

    -- movement speed
    tinsert(_G.PAPERDOLL_STATCATEGORIES[1].stats, {stat = "MOVESPEED"})

    -- title
    hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", TitleManagerPane_Update)
    S.StyleScrollBar(PaperDollFrame.TitleManagerPane.ScrollBar)

    -- equipment
    hooksecurefunc(PaperDollFrame.EquipmentManagerPane.ScrollBox, "Update", EquipmentManagerPane_Update)
    S.StyleScrollBar(PaperDollFrame.EquipmentManagerPane.ScrollBar)
    S.StyleButton(_G.PaperDollFrameEquipSet)
    AF.SetOnePixelInside(_G.PaperDollFrameEquipSet.BFIBackdrop, _G.PaperDollFrameEquipSet)
    S.StyleButton(_G.PaperDollFrameSaveSet)
    AF.SetOnePixelInside(_G.PaperDollFrameSaveSet.BFIBackdrop, _G.PaperDollFrameSaveSet)
end

---------------------------------------------------------------------
-- name & level
---------------------------------------------------------------------
local function StyleNameAndLevel()
    local nameText = CharacterFrame.TitleContainer.TitleText
    AF.UpdateFont(nameText, nil, 14 + BFI.vars.blizzardFontSizeDelta)

    -- nameText:ClearAllPoints()
    -- nameText:SetPoint("LEFT", CharacterFrame.BFIHeader, 5, 0)

    local levelText = _G.CharacterLevelText
    AF.UpdateFont(levelText, nil, 13 + BFI.vars.blizzardFontSizeDelta)

    -- levelText:SetParent(CharacterFrame.BFIHeader)
    -- levelText:SetWidth(0)
    -- levelText:SetHeight(0)

    -- hooksecurefunc(levelText, "SetPoint", function(_, _, anchorTo)
    --     if anchorTo ~= nameText then
    --         levelText:ClearAllPoints()
    --         levelText:SetPoint("BOTTOMLEFT", nameText, "BOTTOMRIGHT", 10, 0)
    --     end
    -- end)

    -- local errorText = _G.CharacterTrialLevelErrorText
    -- errorText:SetParent(CharacterFrame.BFIHeader)
    -- errorText:SetWidth(0)
    -- errorText:SetHeight(0)
    -- errorText:ClearAllPoints()
    -- errorText:SetPoint("BOTTOMLEFT", levelText, "BOTTOMRIGHT", 10, 0)
end

---------------------------------------------------------------------
-- header
---------------------------------------------------------------------
local function Header_OnEnter(header)
    header:SetBackdropColor(AF.GetColorRGB("sheet_highlight", 1))
end

local function Header_OnLeave(header)
    header:SetBackdropColor(AF.GetColorRGB("widget"))
end

local function HeaderRight_UpdateCollapse(texture, atlas)
    if not atlas or atlas == "Options_ListExpand_Right" or atlas == "Options_ListExpand_Right_Expanded" then
        if texture:GetParent():IsCollapsed() then
            texture:SetTexture(AF.GetIcon("Plus_Small"))
            -- texture:SetAtlas("glues-characterSelect-icon-plus")
            -- texture:SetAtlas("QuestLog-icon-Expand", true)
        else
            texture:SetTexture(AF.GetIcon("Minus_Small"))
            -- texture:SetAtlas("glues-characterSelect-icon-minus")
            -- texture:SetAtlas("QuestLog-icon-shrink", true)
        end
        texture:SetSize(16, 16)
    end
end

local function HeaderRight_Style(right)
    right:ClearAllPoints()
    right:SetPoint("RIGHT", -5, 0)
    right:SetAlpha(0.5)
    -- right:SetDesaturated(true)
    HeaderRight_UpdateCollapse(right)
    hooksecurefunc(right, "SetAtlas", HeaderRight_UpdateCollapse)
end

local function StyleHeader(header)
    if header._BFIStyled then return end
    header._BFIStyled = true

    S.RemoveTextures(header)

    header.Right:SetDrawLayer("ARTWORK")
    HeaderRight_Style(header.Right)
    HeaderRight_Style(header.HighlightRight)

    AF.ApplyDefaultBackdropWithColors(header, "widget")
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", header)

    header:HookScript("OnEnter", Header_OnEnter)
    header:HookScript("OnLeave", Header_OnLeave)
end

---------------------------------------------------------------------
-- entry
---------------------------------------------------------------------
local function StyleEntry(entry)
    if entry._BFIStyled then return end
    entry._BFIStyled = true

    local content = entry.Content
    if content then
        content.BackgroundHighlight.Middle:SetAllPoints()
        content.BackgroundHighlight.Left:SetAlpha(0)
        content.BackgroundHighlight.Right:SetAlpha(0)

        if content.ReputationBar then
            S.StyleProgressBar(content.ReputationBar)
        end

        if content.CurrencyIcon then
            S.StyleIcon(content.CurrencyIcon, true)
        end
    end
end

---------------------------------------------------------------------
-- reputation frame
---------------------------------------------------------------------
local function UpdateParagon(frame)
    -- reputation (paragon)
    local factionID = frame.factionID
    if factionID then
        if factionID and IsFactionParagon(factionID) then
            local current, threshold, _, hasRewardPending = GetFactionParagonInfo(factionID)
            -- print(C_Reputation.GetFactionDataByID(factionID).name, hasRewardPending)

            local icon = frame.Content.ParagonIcon
            icon.Icon:SetDesaturated(not hasRewardPending)
            icon.Highlight:SetDesaturated(not hasRewardPending)

            -- if current and threshold then
            --     local bar = frame.Content.ReputationBar
            --     bar:SetMinMaxValues(0, threshold)
            --     bar:SetValue(current % threshold)
            -- end
        end
    end
end

local function ReputationFrame_ScrollBox_Update(scroll)
    scroll:ForEachFrame(function(frame)
        -- if frame.elementData.isHeader and not frame.elementData.isHeaderWithRep then
        if frame.Right then
            StyleHeader(frame)
        else
            StyleEntry(frame)
            UpdateParagon(frame)
        end
    end)
end

local function StyleReputationFrame()
    -- local backdrop = AF.CreateBorderedFrame(ReputationFrame)
    -- backdrop:SetAllPoints(CharacterFrameInset)
    S.StyleDropdownButton(ReputationFrame.filterDropdown)
    S.StyleScrollBar(ReputationFrame.ScrollBar)
    hooksecurefunc(ReputationFrame.ScrollBox, "Update", ReputationFrame_ScrollBox_Update)

    local detailFrame = ReputationFrame.ReputationDetailFrame
    S.RemoveTextures(detailFrame)
    S.RemoveBorder(detailFrame)
    S.CreateBackdrop(detailFrame, nil, -1)

    S.StyleCloseButton(detailFrame.CloseButton)
    detailFrame.CloseButton:SetPoint("TOPRIGHT", detailFrame.BFIBackdrop)

    S.StyleCheckButton(detailFrame.AtWarCheckbox)
    S.StyleCheckButton(detailFrame.MakeInactiveCheckbox)
    S.StyleCheckButton(detailFrame.WatchFactionCheckbox)
    S.StyleScrollBar(detailFrame.ScrollingDescriptionScrollBar)
    S.StyleButton(detailFrame.ViewRenownButton)
end

---------------------------------------------------------------------
-- token frame
---------------------------------------------------------------------
local function TokenFrame_ScrollBox_UpdateEach(frame)
    if frame.Right then
        StyleHeader(frame)
    else
        StyleEntry(frame)
    end
end

local function TokenFrame_ScrollBox_Update(scroll)
    scroll:ForEachFrame(TokenFrame_ScrollBox_UpdateEach)
end

local function StyleTokenFrame()
    S.StyleDropdownButton(TokenFrame.filterDropdown)
    S.StyleScrollBar(TokenFrame.ScrollBar)

    local tex = AF.GetIcon("History", BFI.name)
    local b = TokenFrame.CurrencyTransferLogToggleButton
    b.NormalTexture:SetTexture(tex)
    b.NormalTexture:SetVertexColor(AF.GetColorRGB("gray"))
    b.HighlightTexture:SetTexture(tex)
    b.PushedTexture:SetTexture(tex)

    hooksecurefunc(TokenFrame.ScrollBox, "Update", TokenFrame_ScrollBox_Update)

    S.RemoveBorder(TokenFramePopup)
    S.CreateBackdrop(TokenFramePopup, nil, -1)

    S.StyleCheckButton(TokenFramePopup.InactiveCheckbox)
    S.StyleCheckButton(TokenFramePopup.BackpackCheckbox)
    S.StyleButton(TokenFramePopup.CurrencyTransferToggleButton)

    local closeButton = TokenFramePopup["$parent.CloseButton"]
    S.StyleCloseButton(closeButton)
    closeButton:SetPoint("TOPRIGHT", TokenFramePopup.BFIBackdrop)
end

---------------------------------------------------------------------
-- transfer log
---------------------------------------------------------------------
local function CurrencyTransferLog_ScrollBox_UpdateEach(frame)
    frame.BackgroundHighlight.Middle:SetAllPoints()
    frame.BackgroundHighlight.Left:SetAlpha(0)
    frame.BackgroundHighlight.Right:SetAlpha(0)
    S.StyleIcon(frame.CurrencyIcon, true)
end

local function CurrencyTransferLog_ScrollBox_Update(scroll)
    scroll:ForEachFrame(CurrencyTransferLog_ScrollBox_UpdateEach)
end

local function StyleTransferLog()
    S.StyleTitledFrame(CurrencyTransferLog)
    S.StyleScrollBar(CurrencyTransferLog.ScrollBar)
    _G.CurrencyTransferLogInset:SetAlpha(0)
    hooksecurefunc(CurrencyTransferLog.ScrollBox, "Update", CurrencyTransferLog_ScrollBox_Update)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    S.StyleTitledFrame(CharacterFrame)
    S.RemoveNineSliceAndBackground(CharacterFrameInset)
    S.RemoveNineSliceAndBackground(CharacterFrameInsetRight)
    S.RemoveNineSliceAndBackground(CharacterStatsPane)

    -- _G.CHARACTERFRAME_EXPANDED_WIDTH = 700
    -- CharacterFrame:SetHeight(450)

    StyleTabs()
    StyleFlyout()
    StyleCharacterFrameInset()
    StyleCharacterFrameInsetRight()
    StyleNameAndLevel()
    StyleReputationFrame()
    StyleTokenFrame()
    StyleTransferLog()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)