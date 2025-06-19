---@class BFI
local BFI = select(2, ...)
---@class Style
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- remove blizzard textures
---------------------------------------------------------------------
-- local BlizzardFrames = {
--     "ArtOverlayFrame",
--     "Background",
--     "Bg",
--     "BG",
--     "bgLeft",
--     "bgRight",
--     "border",
--     "Border",
--     "BorderFrame",
--     "bottomInset",
--     "BottomInset",
--     "FilligreeOverlay",
--     "inset",
--     "Inset",
--     "InsetFrame",
--     "LeftInset",
--     "NineSlice",
--     "portrait",
--     "Portrait",
--     "PortraitOverlay",
--     "RightInset",
--     "ScrollDownBorder",
--     "ScrollFrameBorder",
--     "ScrollUpBorder",
-- }

function S.RemoveTextures(region)
    if not region then return end

    if region:IsObjectType("Texture") then
        region:SetTexture(AF.GetEmptyTexture())
        region:SetAtlas("")
    else
        -- REVIEW:
        -- local name = region.GetName and region:GetName()
        -- for _, subName in next, BlizzardFrames do
        --     local f = region[subName] or (name and _G[name .. subName])
        --     if f then
        --         print(f)
        --         S.RemoveTextures(f)
        --     end
        -- end

        if region.GetRegions then -- Frame
            for _, r in next, {region:GetRegions()} do
                if r and r:IsObjectType("Texture") then
                    r:SetTexture(AF.GetEmptyTexture())
                    r:SetAtlas("")
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- create backdrop
---------------------------------------------------------------------
function S.CreateBackdrop(region, noBackground, isOutside, relativeFrameLevel)
    if region.BFIBackdrop then return end

    local backdropParent = (region.IsObjectType and region:IsObjectType("Texture") and region:GetParent()) or region
    region.BFIBackdrop = CreateFrame("Frame", nil, backdropParent)

    if noBackground then
        AF.ApplyDefaultBackdrop_NoBackground(region.BFIBackdrop)
    else
        AF.ApplyDefaultBackdropWithColors(region.BFIBackdrop)
    end

    if isOutside then
        AF.SetOnePixelOutside(region.BFIBackdrop, region)
    else
        region.BFIBackdrop:SetAllPoints(region)
    end

    AF.SetFrameLevel(region.BFIBackdrop, relativeFrameLevel or 0)
    AF.AddToPixelUpdater(region.BFIBackdrop)
end

---------------------------------------------------------------------
-- icon
---------------------------------------------------------------------
function S.StyleIcon(icon, createBackdrop)
    icon:SetTexCoord(AF.GetDefaultTexCoord())
    if createBackdrop then
        S.CreateBackdrop(icon, true, nil, 1)
    end
end

---------------------------------------------------------------------
-- icon border
---------------------------------------------------------------------
local function IconBorder_ResetColor(border)
    if border.BFIBackdrop then
        border.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
    end
end

local function IconBorder_SetShown(border, show)
    if show then
        AF.TextureHide(border)
    else
        IconBorder_ResetColor(border)
    end
end

local ItemQuality = Enum.ItemQuality
local iconQuality = {
    ["auctionhouse-itemicon-border-gray"] = ItemQuality.Poor,
    ["auctionhouse-itemicon-border-white"] = ItemQuality.Common,
    ["auctionhouse-itemicon-border-green"] = ItemQuality.Uncommon,
    ["auctionhouse-itemicon-border-blue"] = ItemQuality.Rare,
    ["auctionhouse-itemicon-border-purple"] = ItemQuality.Epic,
    ["auctionhouse-itemicon-border-orange"] = ItemQuality.Legendary,
    ["auctionhouse-itemicon-border-artifact"] = ItemQuality.Artifact,
    ["auctionhouse-itemicon-border-account"] = ItemQuality.Heirloom,

    ["Professions-Slot-Frame"] = ItemQuality.Common,
    ["Professions-Slot-Frame-Green"] = ItemQuality.Uncommon,
    ["Professions-Slot-Frame-Blue"] = ItemQuality.Rare,
    ["Professions-Slot-Frame-Epic"] = ItemQuality.Epic,
    ["Professions-Slot-Frame-Legendary"] = ItemQuality.Legendary
}

local function IconBorder_SetAtlas(border, atlas)
    if border.BFIBackdrop then
        local r, g, b = AF.GetItemQualityColor(iconQuality[atlas])
        border.BFIBackdrop:SetBackdropBorderColor(r, g, b)
    end
end

local function IconBorder_SetVertexColor(border, r, g, b, a)
    if border.BFIBackdrop then
        border.BFIBackdrop:SetBackdropBorderColor(r, g, b, a)
    end
end

function S.StyleIconBorder(border, backdrop)
    if not backdrop then
        local parent = border:GetParent()
        backdrop = parent.BFIBackdrop or parent
    end

    if border.BFIBackdrop ~= backdrop then
        border.BFIBackdrop = backdrop
    end

    if not border._BFIIconBorderHooked then
        border._BFIIconBorderHooked = true
        border:Hide()

        hooksecurefunc(border, "Show", AF.TextureHide)
        hooksecurefunc(border, "Hide", IconBorder_ResetColor)
        hooksecurefunc(border, "SetShown", IconBorder_SetShown)
        hooksecurefunc(border, "SetAtlas", IconBorder_SetAtlas)
        hooksecurefunc(border, "SetVertexColor", IconBorder_SetVertexColor)
    end
end

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------
local function Button_OnEnter(button)
    button:SetBackdropColor(AF.UnpackColor(button._hoverColor))
end

local function Button_OnLeave(button)
    if not button.isSelected then
        button:SetBackdropColor(AF.UnpackColor(button._color))
    end
end

local function RegisterMouseDownUp(button)
    button:SetScript("OnMouseDown", function()
        if button:IsEnabled() then
            if button.BFIText then
                button.BFIText:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(button))
            end
            if button.BFIIcon then
                button.BFIIcon:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(button))
            end
        end
    end)
    button:SetScript("OnMouseUp", function()
        if button:IsEnabled() then
            if button.BFIText then
                AF.RePoint(button.BFIText)
            end
            if button.BFIIcon then
                AF.RePoint(button.BFIIcon)
            end
        end
    end)
end

local function Button_OnEnable(button)
    if button.BFIText then
        button.BFIText:SetTextColor(AF.GetColorRGB("white"))
    end
    if button.BFIIcon then
        button.BFIIcon:SetDesaturated(false)
        button.BFIIcon:SetVertexColor(AF.GetColorRGB("white"))
    end
end

local function Button_OnDisable(button)
    if button.BFIText then
        button.BFIText:SetTextColor(AF.GetColorRGB("disabled"))
    end
    if button.BFIIcon then
        button.BFIIcon:SetDesaturated(true)
        button.BFIIcon:SetVertexColor(AF.GetColorRGB("disabled"))
    end
end

local function StyleButton(button, color, hoverColor)
    assert(button, "StyleButton: button is nil")
    if button._BFIStyled then return end
    button._BFIStyled = true

    button:SetNormalTexture(AF.GetEmptyTexture())
    button:SetPushedTexture(AF.GetEmptyTexture())
    button:SetHighlightTexture(AF.GetEmptyTexture())
    button:SetDisabledTexture(AF.GetEmptyTexture())

    button._color = AF.GetButtonNormalColor(color or "BFI_hover")
    button._hoverColor = AF.GetButtonHoverColor(hoverColor or color or "BFI_hover")

    button.BFIBg = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.BFIBg:SetColorTexture(AF.GetColorRGB("background", 1))
    button.BFIBg:SetAllPoints(button)

    AF.ApplyDefaultBackdrop(button)
    button:SetBackdropColor(AF.UnpackColor(button._color))
    button:SetBackdropBorderColor(AF.GetColorRGB("border"))

    button:HookScript("OnEnter", Button_OnEnter)
    button:HookScript("OnLeave", Button_OnLeave)
    button:HookScript("OnEnable", Button_OnEnable)
    button:HookScript("OnDisable", Button_OnDisable)

    RegisterMouseDownUp(button)

    AF.AddToPixelUpdater(button)
end

---------------------------------------------------------------------
-- close button
---------------------------------------------------------------------
local function CloseButton_UpdatePixels(button)
    AF.DefaultUpdatePixels(button)
    AF.ReSize(button.BFIIcon)
end

local function StyleCloseButton(button)
    assert(button, "StyleCloseButton: button is nil")

    StyleButton(button, "red")
    AF.SetSize(button, 20, 20)

    if not button.BFIIcon then
        button.BFIIcon = button:CreateTexture(nil, "ARTWORK")
        AF.SetPoint(button.BFIIcon, "CENTER")
        AF.SetSize(button.BFIIcon, 14, 14)
        button.BFIIcon:SetTexture(AF.GetIcon("Close"))
    end
end

---------------------------------------------------------------------
-- remove NineSlice and Background
---------------------------------------------------------------------
local backgrounds = {
    "Bg",
    "Background",
    "ClassBackground",
}

function S.RemoveNineSliceAndBackground(frame)
    assert(frame, "RemoveNineSliceAndBackground: frame is nil")

    if frame.NineSlice then
        frame.NineSlice:SetAlpha(0)
    end

    local name = frame.GetName and frame:GetName()

    for _, bgName in next, backgrounds do
        local bg = name and _G[name .. bgName]
        if bg then bg:SetAlpha(0) end
        bg = frame[bgName]
        if bg then bg:SetAlpha(0) end
    end
end

---------------------------------------------------------------------
-- portrait frame
---------------------------------------------------------------------
-- PortraitFrameBaseTemplate
function S.StylePortraitFrame(frame)
    assert(frame, "StylePortraitFrame: frame is nil")

    if frame._BFIStyled then return end
    frame._BFIStyled = true

    local name = frame.GetName and frame:GetName()

    -- remove blizzard ----------------------------------------------
    S.RemoveNineSliceAndBackground(frame)

    -- portrait
    if frame.PortraitContainer then
        frame.PortraitContainer:SetAlpha(0)
    end

    if frame.TopTileStreaks then
        frame.TopTileStreaks:SetAlpha(0)
    end

    -- style into bfi -----------------------------------------------
    -- bg
    frame.BFIBg = AF.CreateBorderedFrame(frame)
    frame.BFIBg:SetAllPoints(frame)
    AF.SetFrameLevel(frame.BFIBg)

    -- title
    frame.BFIHeader = AF.CreateBorderedFrame(frame, nil, nil, nil, "header", "border")
    frame.BFIHeader:SetPoint("TOPLEFT")
    frame.BFIHeader:SetPoint("TOPRIGHT")
    AF.SetHeight(frame.BFIHeader, 20)
    AF.SetFrameLevel(frame.BFIHeader, 0, frame.TitleContainer)

    frame.BFIHeader.tex = frame.BFIHeader:CreateTexture(nil, "ARTWORK")
    frame.BFIHeader.tex:SetColorTexture(AF.GetColorRGB("BFI", 0.025))
    AF.SetOnePixelInside(frame.BFIHeader.tex, frame.BFIHeader)

    frame.TitleContainer.TitleText:ClearAllPoints()
    frame.TitleContainer.TitleText:SetPoint("CENTER", frame.BFIHeader)

    -- close button
    local closeButton = frame.CloseButton or (name and _G[name .. "CloseButton"])
    StyleCloseButton(closeButton)
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT")
    AF.SetFrameLevel(closeButton, 1, frame.BFIHeader)
end

---------------------------------------------------------------------
-- tab
---------------------------------------------------------------------
local function GetTabByIndex(frame, index)
	return frame.Tabs and frame.Tabs[index] or _G[frame:GetName().."Tab"..index]
end

hooksecurefunc("PanelTemplates_UpdateTabs", function(frame)
    if frame.selectedTab then
        local tab
        for i = 1, frame.numTabs do
            tab = GetTabByIndex(frame, i)
            if tab and tab._BFIStyled then
                if tab.isDisabled then
                    -- PanelTemplates_SetDisabledTabState(tab)
                    -- print("PanelTemplates_UpdateTabs: tab is disabled", tab:GetName())
                    tab.isSelected = false
                    tab:SetBackdropColor(AF.UnpackColor(tab._color))
                elseif i == frame.selectedTab then
                    -- PanelTemplates_SelectTab(tab)
                    -- print("PanelTemplates_UpdateTabs: tab is selected", tab:GetName())
                    tab.isSelected = true
                    tab:SetBackdropColor(AF.UnpackColor(tab._hoverColor))
                else
                    -- PanelTemplates_DeselectTab(tab)
                    -- print("PanelTemplates_UpdateTabs: tab is deselected", tab:GetName())
                    tab.isSelected = false
                    tab:SetBackdropColor(AF.UnpackColor(tab._color))
                end
            end
        end
    end
end)

function S.StyleTab(tab)
    assert(tab, "StyleTab: tab is nil")
    if tab._BFIStyled then return end

    S.RemoveTextures(tab)
    AF.ApplyDefaultBackdrop(tab)
    StyleButton(tab, "BFI_hover")

    -- Interface\AddOns\Blizzard_SharedXML\Mainline\SharedUIPanelTemplates.lua
    if tab.isTopTab then
        tab.selectedTextY = -7
        tab.deselectedTextY = -6
    else
        tab.selectedTextY = 0
        tab.deselectedTextY = 0
    end
    tab.selectedTextX = 0
    tab.deselectedTextX = 0

    AF.SetHeight(tab, 26)
    tab:SetPushedTextOffset(0, -AF.GetOnePixelForRegion(tab))

    tab._BFIStyled = true
end