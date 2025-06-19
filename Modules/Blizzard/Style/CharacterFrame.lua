---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local _G = _G
local PANEL_INSET_BOTTOM_OFFSET = _G.PANEL_INSET_BOTTOM_OFFSET
local MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = _G.MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY
local PAPERDOLL_STATINFO = _G.PAPERDOLL_STATINFO

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
local function StyleFlyout()
    -- flyout
    EquipmentFlyoutFrameHighlight:SetAlpha(0)
    -- .buttonFrame
    EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
    -- EquipmentFlyoutFrameButtons.bg2:SetAlpha(0)
	EquipmentFlyoutFrameButtons:DisableDrawLayer("ARTWORK")

    AF.ApplyDefaultBackdropWithColors(EquipmentFlyoutFrame, "none", "BFI")

    hooksecurefunc("EquipmentFlyout_Show", function(b)
        AF.SetOutside(EquipmentFlyoutFrame, b, 2, 2)
    end)
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
            icon:SetAlpha(1)
            S.StyleIcon(icon)
        end

        slot.ignoreTexture:SetAlpha(1)
        slot.IconBorder:SetAlpha(1)
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
    highlightTexture:SetVertexColor(1, 1, 1, 0.25)
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
    AF.SetSize(frame, 177, 17)
    AF.AddToPixelUpdater(frame)

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
end

local function PaperDollFrame_UpdateSidebarTabs()


    local i = 1
    local tab, last = _G["PaperDollSidebarTab" .. i]
    while tab do
        AF.ApplyDefaultBackdropWithColors(tab, "widget")

        tab.TabBg:SetAlpha(0)

        tab.Hider:SetColorTexture(0, 0, 0, 0.75)
        AF.SetOnePixelInside(tab.Hider, tab)

        tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
        AF.SetOnePixelInside(tab.Highlight, tab)

        AF.SetOnePixelInside(tab.Icon, tab)
        if i == 1 then
            tab.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        end

        i = i + 1
        tab = _G["PaperDollSidebarTab" .. i]
    end
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
    CharacterStatsPane.ItemLevelFrame:SetHeight(22)

    hooksecurefunc("PaperDollFrame_UpdateStats", PaperDollFrame_UpdateStats)
    hooksecurefunc("PaperDollFrame_SetLabelAndText", PaperDollFrame_SetLabelAndText)
end

---------------------------------------------------------------------
-- name & level
---------------------------------------------------------------------
-- local function StyleNameAndLevel()
--     local nameText = CharacterFrame.TitleContainer.TitleText
--     nameText:ClearAllPoints()
--     nameText:SetPoint("LEFT", CharacterFrame.BFIHeader, 5, 0)

--     local levelText = _G.CharacterLevelText
--     levelText:SetParent(CharacterFrame.BFIHeader)
--     levelText:SetWidth(0)
--     levelText:SetHeight(0)

--     hooksecurefunc(levelText, "SetPoint", function(_, _, anchorTo)
--         if anchorTo ~= nameText then
--             levelText:ClearAllPoints()
--             levelText:SetPoint("BOTTOMLEFT", nameText, "BOTTOMRIGHT", 10, 0)
--         end
--     end)

--     local errorText = _G.CharacterTrialLevelErrorText
--     errorText:SetParent(CharacterFrame.BFIHeader)
--     errorText:SetWidth(0)
--     errorText:SetHeight(0)
--     errorText:ClearAllPoints()
--     errorText:SetPoint("BOTTOMLEFT", levelText, "BOTTOMRIGHT", 10, 0)
-- end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    S.StylePortraitFrame(CharacterFrame)
    S.RemoveNineSliceAndBackground(CharacterFrameInset)
    S.RemoveNineSliceAndBackground(CharacterFrameInsetRight)
    S.RemoveNineSliceAndBackground(CharacterStatsPane)

    -- _G.CHARACTERFRAME_EXPANDED_WIDTH = 700
    -- CharacterFrame:SetHeight(450)

    StyleTabs()
    StyleFlyout()
    StyleCharacterFrameInset()
    StyleCharacterFrameInsetRight()
    -- StyleNameAndLevel()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)