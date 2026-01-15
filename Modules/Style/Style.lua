---@type BFI
local BFI = select(2, ...)
---@class Style
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local _G = _G

---------------------------------------------------------------------
-- remove regions
---------------------------------------------------------------------
local uselessRegions = {
    "Left",
    "FocusLeft",
    "HighlightLeft",
    "Right",
    "FocusRight",
    "HighlightRight",
    "Center",
    "Mid",
    "Middle",
    "FocusMid",
    "HighlightMiddle",
    -- "LeftDisabled",
    -- "MiddleDisabled",
    -- "RightDisabled",
    -- "BorderBottom",
    -- "BorderBottomLeft",
    -- "BorderBottomRight",
    -- "BorderLeft",
    -- "BorderRight",
    -- "TopLeft",
    -- "TopRight",
    -- "BottomLeft",
    -- "BottomRight",
    -- "TopMiddle",
    -- "MiddleLeft",
    -- "MiddleRight",
    -- "BottomMiddle",
    -- "MiddleMiddle",
    -- "TabSpacer",
    -- "TabSpacer1",
    -- "TabSpacer2",
    -- "_RightSeparator",
    -- "_LeftSeparator",
    -- "Cover",
    -- "Border",
    -- "Background",
    -- "TopTex",
    -- "TopLeftTex",
    -- "TopRightTex",
    -- "LeftTex",
    -- "BottomTex",
    -- "BottomLeftTex",
    -- "BottomRightTex",
    -- "RightTex",
    -- "MiddleTex",
    -- "Center"
}

function S.RemoveRegions(region)
    local name = region.GetName and region:GetName()
    for _, subName in next, uselessRegions do
        local r = region[subName] or (name and _G[name .. subName])
        if r then
            r:SetAlpha(0)
            r:Hide()
        end
    end
end

---------------------------------------------------------------------
-- remove blizzard textures
---------------------------------------------------------------------
function S.RemoveTextures(region, hide)
    if not region then return end

    if region:IsObjectType("Texture") then
        region:SetTexture(AF.GetEmptyTexture())
        region:SetAtlas("")
        if hide then
            region:SetAlpha(0)
            region:Hide()
        end
    else
        if region.GetRegions then -- Frame
            for _, r in next, {region:GetRegions()} do
                if r and r:IsObjectType("Texture") then
                    r:SetTexture(AF.GetEmptyTexture())
                    r:SetAtlas("")
                    if hide then
                        r:SetAlpha(0)
                        r:Hide()
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- remove border
---------------------------------------------------------------------
function S.RemoveBorder(region)
    if not region then return end
    if region.Border then
        region.Border:SetAlpha(0)
    end
end

---------------------------------------------------------------------
-- remove Background
---------------------------------------------------------------------
local backgrounds = {
    "Bg",
    "BG",
    "Background",
    "BlackBG",
    "ClassBackground",
    "Dark",
    "Watermark",
}

function S.RemoveBackground(region)
    if not region then return end

    local name = region.GetName and region:GetName()

    for _, bgName in next, backgrounds do
        local bg = name and _G[name .. bgName] or region[bgName]
        if bg then
            bg:SetAlpha(0)
        end
    end
end

---------------------------------------------------------------------
-- remove NineSlice and Background
---------------------------------------------------------------------
function S.RemoveNineSliceAndBackground(frame)
    assert(frame, "RemoveNineSliceAndBackground: frame is nil")

    if frame.NineSlice then
        frame.NineSlice:SetAlpha(0)
    end

    S.RemoveBackground(frame)
end


---------------------------------------------------------------------
-- create backdrop
---------------------------------------------------------------------
function S.CreateBackdrop(region, noBackground, offset, relativeFrameLevel)
    if region.BFIBackdrop then return end

    local backdropParent = (region.IsObjectType and region:IsObjectType("Texture") and region:GetParent()) or region
    region.BFIBackdrop = CreateFrame("Frame", nil, backdropParent)

    if noBackground then
        AF.ApplyDefaultBackdrop_NoBackground(region.BFIBackdrop)
    else
        AF.ApplyDefaultBackdropWithColors(region.BFIBackdrop)
    end

    if not offset or offset == 0 then
        region.BFIBackdrop:SetAllPoints(region)
    elseif offset > 0 then
        AF.SetOutside(region.BFIBackdrop, region, offset, offset)
    else
        AF.SetInside(region.BFIBackdrop, region, -offset, -offset)
    end

    AF.SetFrameLevel(region.BFIBackdrop, relativeFrameLevel or 0)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", region.BFIBackdrop)
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

    -- apply color immediately
    local r, g, b, a = border:GetVertexColor()
    if r then
        if r == 1 and g == 1 and b == 1 then
            r, g, b = AF.GetColorRGB("border")
        end
        backdrop:SetBackdropBorderColor(r, g, b, a)
    end

    if border.BFIBackdrop ~= backdrop then
        border.BFIBackdrop = backdrop
    end

    if not border._BFIIconBorderHooked then
        border._BFIIconBorderHooked = true
        border:Hide()

        -- hook to update color
        hooksecurefunc(border, "Show", AF.TextureHide)
        hooksecurefunc(border, "Hide", IconBorder_ResetColor)
        hooksecurefunc(border, "SetShown", IconBorder_SetShown)
        hooksecurefunc(border, "SetAtlas", IconBorder_SetAtlas)
        hooksecurefunc(border, "SetVertexColor", IconBorder_SetVertexColor)
    end
end

---------------------------------------------------------------------
-- LargeItemButtonTemplate
---------------------------------------------------------------------
function S.StyleLargeItemButton(button, borderColor)
    assert(button, "StyleLargeItemButton: button is nil")

    if button._BFIStyled then return end
    button._BFIStyled = true

    local icon = button.Icon
    S.StyleIcon(icon, true)
    S.StyleIconBorder(button.IconBorder, icon.BFIBackdrop)
    if borderColor then
        icon.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB(borderColor))
    end

    local nameFrame = button.NameFrame
    nameFrame:SetTexture(AF.GetTexture("Gradient_Linear_Left"))
    nameFrame:SetVertexColor(AF.GetColorRGB("widget_highlight"))
    nameFrame:ClearAllPoints()
    nameFrame:SetPoint("TOPLEFT", icon, "TOPRIGHT")
    nameFrame:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT")
end

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------
local function Button_OnEnter(button)
    if not button:IsEnabled() then return end
    button.BFIBackdrop:SetBackdropColor(AF.UnpackColor(button._hoverColor))
end

local function Button_OnLeave(button)
    if not button.isSelected then
        button.BFIBackdrop:SetBackdropColor(AF.UnpackColor(button._color))
    end
end

local function RegisterMouseDownUp(button)
    button:SetScript("OnMouseDown", function()
        if button:IsEnabled() and not button._pushed then
            button._pushed = true
            if button.BFIText then
                button.BFIText:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(button))
            end
            if button.BFIIcon then
                button.BFIIcon:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(button))
            end
        end
    end)
    button:SetScript("OnMouseUp", function()
        if button:IsEnabled() and button._pushed then
            button._pushed = nil
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
        button.BFIText:SetTextColor(AF.UnpackColor(button._iconColor))
    end
    if button.BFIIcon then
        button.BFIIcon:SetDesaturated(false)
        button.BFIIcon:SetVertexColor(AF.UnpackColor(button._iconColor))
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

local function Button_HookHighlight(button)
    hooksecurefunc(button, "LockHighlight", function()
        button.isSelected = true
        Button_OnEnter(button)
    end)
    hooksecurefunc(button, "UnlockHighlight", function()
        button.isSelected = nil
        Button_OnLeave(button)
    end)
end

function S.StyleButton(button, color, hoverColor)
    assert(button, "StyleButton: button is nil")
    if button._BFIStyled then return end
    button._BFIStyled = true

    S.RemoveTextures(button, true)

    button:SetNormalTexture(AF.GetEmptyTexture())
    button:SetPushedTexture(AF.GetEmptyTexture())
    button:SetHighlightTexture(AF.GetEmptyTexture())
    button:SetDisabledTexture(AF.GetEmptyTexture())

    button._color = AF.GetButtonNormalColor(color or "BFI_hover")
    button._hoverColor = AF.GetButtonHoverColor(hoverColor or color or "BFI_hover")

    S.CreateBackdrop(button)
    button.BFIBackdrop:SetBackdropColor(AF.UnpackColor(button._color))
    button.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))

    button.BFIBg = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.BFIBg:SetColorTexture(AF.GetColorRGB("background", 1))
    button.BFIBg:SetAllPoints(button.BFIBackdrop)

    button:HookScript("OnEnter", Button_OnEnter)
    button:HookScript("OnLeave", Button_OnLeave)
    button:HookScript("OnEnable", Button_OnEnable)
    button:HookScript("OnDisable", Button_OnDisable)

    button.BFI_OnEnter = Button_OnEnter
    button.BFI_OnLeave = Button_OnLeave
    button.BFI_OnEnable = Button_OnEnable
    button.BFI_OnDisable = Button_OnDisable
    button.BFI_HookHighlight = Button_HookHighlight

    button:SetPushedTextOffset(0, -AF.GetOnePixelForRegion(button))
    RegisterMouseDownUp(button)

    AF.AddToPixelUpdater_CustomGroup("BFIStyled", button)
end

---------------------------------------------------------------------
-- icon button
---------------------------------------------------------------------
local function IconButton_UpdatePixels(button)
    AF.DefaultUpdatePixels(button)
    AF.ReSize(button.BFIIcon)
end

local function SetupIconButton(button, icon, iconSize, iconColor, color, hoverColor)
    S.StyleButton(button, color, hoverColor)

    button.BFIIcon = button:CreateTexture(nil, "ARTWORK")
    AF.SetPoint(button.BFIIcon, "CENTER")
    AF.SetSize(button.BFIIcon, iconSize, iconSize)
    if AF.IsAtlas(icon) then
        button.BFIIcon:SetAtlas(icon)
    else
        button.BFIIcon:SetTexture(icon)
    end
    button.BFIIcon:SetDesaturated(not button:IsEnabled())
    button.BFIIcon:SetVertexColor(AF.GetColorRGB(button:IsEnabled() and (iconColor or "white") or "disabled"))
    button._iconColor = AF.GetColorTable(iconColor or "white")

    AF.AddToPixelUpdater_CustomGroup("BFIStyled", button, IconButton_UpdatePixels)
end

function S.StyleIconButton(button, icon, iconSize, iconColor, color, hoverColor)
    SetupIconButton(button, icon, iconSize, iconColor, color, hoverColor)
end

function S.StyleCloseButton(button)
    assert(button, "StyleCloseButton: button is nil")

    if button._BFIStyled then return end
    SetupIconButton(button, AF.GetIcon("Close"), 16, nil, "red")
    AF.SetSize(button, 27, 20)
end

function S.StyleMinimizeButton(button)
    assert(button, "StyleMinimizeButton: button is nil")

    if button._BFIStyled then return end
    SetupIconButton(button, AF.GetIcon("ArrowDown1"), 20, nil, "red")
    AF.SetSize(button, 27, 20)
end

function S.StyleMaximizeButton(button)
    assert(button, "StyleMaximizeButton: button is nil")

    if button._BFIStyled then return end
    SetupIconButton(button, AF.GetIcon("ArrowUp1"), 20, nil, "red")
    AF.SetSize(button, 27, 20)
end

---------------------------------------------------------------------
-- spell/icon button
---------------------------------------------------------------------
function S.StyleSpellItemButton(button)
    local name = button:GetName()

    S.CreateBackdrop(button, true, nil, 1)

    local iconTexture = name and _G[name .. "IconTexture"] or button.IconTexture or button.Icon
    if iconTexture then
        S.StyleIcon(iconTexture)
        -- AF.SetOnePixelInside(iconTexture, button.BFIBackdrop)
    end

    local iconBorder = name and _G[name .. "IconBorder"] or button.IconBorder or button.Border
    if iconBorder then
        S.StyleIconBorder(iconBorder)
    end

    local normalTexture = name and _G[name .. "NormalTexture"] or button.NormalTexture
    if normalTexture then
        normalTexture:SetAlpha(0)
    end

    local highlightTexture = name and (_G[name .. "Highlight"] or button.Highlight) or (button.GetHighlightTexture and button:GetHighlightTexture())
    if highlightTexture then
        AF.SetOnePixelInside(highlightTexture, button.BFIBackdrop)
        highlightTexture:SetColorTexture(AF.GetColorRGB("white", 0.25))
    end

    local pushedTexture = button.GetPushedTexture and button:GetPushedTexture()
    if pushedTexture then
        AF.SetOnePixelInside(pushedTexture, button.BFIBackdrop)
        pushedTexture:SetColorTexture(AF.GetColorRGB("yellow", 0.25))
    end
    -- button:SetPushedTexture(AF.GetEmptyTexture())

    local checkedTexture = button.GetCheckedTexture and button:GetCheckedTexture()
    if checkedTexture then
        AF.SetOnePixelInside(checkedTexture, button.BFIBackdrop)
        checkedTexture:SetColorTexture(AF.GetColorRGB("BFI", 0.25))
    end
end

---------------------------------------------------------------------
-- check button
---------------------------------------------------------------------
function S.StyleCheckButton(button, size)
    assert(button, "StyleCheckButton: button is nil")

    if button._BFIStyled then return end
    button._BFIStyled = true

    S.RemoveTextures(button)

    S.CreateBackdrop(button)
    button.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    AF.ClearPoints(button.BFIBackdrop)
    button.BFIBackdrop:SetPoint("CENTER")
    AF.SetSize(button.BFIBackdrop, size or 15, size or 15)

    local checkedTexture = button:CreateTexture(nil, "ARTWORK")
    checkedTexture:SetTexture(AF.GetPlainTexture())
    checkedTexture:SetVertexColor(AF.GetColorRGB("BFI", 0.7))
    AF.SetOnePixelInside(checkedTexture, button.BFIBackdrop)
    button:SetCheckedTexture(checkedTexture)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", checkedTexture)

    local highlightTexture = button:CreateTexture(nil, "ARTWORK")
    highlightTexture:SetTexture(AF.GetPlainTexture())
    highlightTexture:SetVertexColor(AF.GetColorRGB("BFI", 0.1))
    highlightTexture:SetAllPoints(checkedTexture)
    button:SetHighlightTexture(highlightTexture)

    local disabledTexture = button:CreateTexture(nil, "ARTWORK")
    disabledTexture:SetTexture(AF.GetPlainTexture())
    disabledTexture:SetVertexColor(AF.GetColorRGB("disabled", 0.7))
    disabledTexture:SetAllPoints(checkedTexture)
    button:SetDisabledCheckedTexture(disabledTexture)

    button:HookScript("OnEnable", function(self)
        self.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
    end)

    button:HookScript("OnDisable", function(self)
        self.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("disabled", nil, 0.7))
    end)
end

function S.ReStyleCheckButtonTexture(button, isIndeterminate)
    -- some check buttons update their textures dynamically, so we need to "fix" them
    assert(button, "ReStyleCheckButtonTexture: button is nil")

    button:SetNormalTexture(AF.GetEmptyTexture())
    button:SetPushedTexture(AF.GetEmptyTexture())

    local checkedTexture = button:GetCheckedTexture()
    local disabledTexture = button:GetDisabledCheckedTexture()
    local highlightTexture = button:GetHighlightTexture()

    if isIndeterminate then
        checkedTexture:SetTexture(AF.GetTexture("Triangle_BottomRight"))
        disabledTexture:SetTexture(AF.GetTexture("Triangle_BottomRight"))
    else
        checkedTexture:SetTexture(AF.GetPlainTexture())
        disabledTexture:SetTexture(AF.GetPlainTexture())
    end
    checkedTexture:SetVertexColor(AF.GetColorRGB("BFI", 0.7))
    disabledTexture:SetVertexColor(AF.GetColorRGB("disabled", 0.7))
    highlightTexture:SetTexture(AF.GetPlainTexture())
    highlightTexture:SetVertexColor(AF.GetColorRGB("BFI", 0.1))
end

---------------------------------------------------------------------
-- progress bar
---------------------------------------------------------------------
function S.StyleStatusBar(bar, backdropOffset, barTexture)
    assert(bar, "StyleStatusBar: bar is nil")

    if bar._BFIStyled then return end
    bar._BFIStyled = true

    S.RemoveTextures(bar)
    S.CreateBackdrop(bar, nil, backdropOffset)
    bar.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget_dark"))
    bar:SetStatusBarTexture(barTexture or BFI.media.bar)
    bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
end

---------------------------------------------------------------------
-- edit box
---------------------------------------------------------------------
function S.StyleEditBox(box, tlx, tly, brx, bry)
    assert(box, "StyleEditBox: box is nil")

    if box._BFIStyled then return end
    box._BFIStyled = true

    S.RemoveRegions(box)
    S.RemoveNineSliceAndBackground(box)
    S.CreateBackdrop(box)
    box.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    AF.ClearPoints(box.BFIBackdrop)
    AF.SetPoint(box.BFIBackdrop, "TOPLEFT", tlx or 0, tly or 0)
    AF.SetPoint(box.BFIBackdrop, "BOTTOMRIGHT", brx or 0, bry or 0)
end

---------------------------------------------------------------------
-- InputScrollFrameTemplate
---------------------------------------------------------------------
function S.StyleInputScrollFrame(frame)
    assert(frame, "StyleInputScrollFrame: frame is nil")

    if frame._BFIStyled then return end
    frame._BFIStyled = true

    frame:DisableDrawLayer("BACKGROUND")
    S.CreateBackdrop(frame)
    frame.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))
    AF.ClearPoints(frame.BFIBackdrop)
    AF.SetOutside(frame.BFIBackdrop, frame, 4)
end

---------------------------------------------------------------------
-- dropdown button
---------------------------------------------------------------------
function S.StyleDropdownButton(button)
    assert(button, "StyleDropdownButton: button is nil")

    if button._BFIStyled then return end
    button._BFIStyled = true

    S.RemoveTextures(button)
    AF.ApplyDefaultBackdropWithColors(button, "widget")
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", button)

    button:SetNormalTexture(AF.GetEmptyTexture())
    button:SetPushedTexture(AF.GetEmptyTexture())
    button:SetHighlightTexture(AF.GetEmptyTexture())
    button:SetDisabledTexture(AF.GetEmptyTexture())

    if button.Arrow then button.Arrow:SetAlpha(0) end
    if button.Button then button.Button:SetAlpha(0) end
    if button.Background then button.Background:SetAlpha(0) end
    -- if button.Text then
    --     button.Text:ClearAllPoints()
    --     button.Text:SetPoint("CENTER")
    -- end
    button:SetPushedTextOffset(0, 0)
    if button.displacedRegions then
        wipe(button.displacedRegions) -- REVIEW: TAINT?
    end

    local arrow = AF.CreateTexture(button, AF.GetIcon("ArrowDown_Small"), "darkgray")
    button.BFIArrow = arrow
    AF.SetSize(arrow, 16, 16)
    AF.SetPoint(arrow, "RIGHT", -5, 0)
    AF.RemoveFromPixelUpdater(arrow)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", arrow)

    button:HookScript("OnEnter", function(self)
        self.BFIArrow:SetVertexColor(AF.GetColorRGB("white", nil, 0.9))
    end)
    button:HookScript("OnLeave", function(self)
        self.BFIArrow:SetVertexColor(AF.GetColorRGB("darkgray"))
    end)

    -- if button:IsMenuOpen() then
    --     print("StyleDropdown: CloseMenu")
    --     arrow:SetTexture(AF.GetIcon("ArrowUp_Small"))
    -- else
    --     print("StyleDropdown: OpenMenu")
    --     arrow:SetTexture(AF.GetIcon("ArrowDown_Small"))
    -- end
    button:HookScript("OnMouseDown", function()
        arrow:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(button))
        -- if button.Text then
        --     button.Text:ClearPointsOffset()
        -- end
    end)

    local function ClearPointsOffset()
        AF.RePoint(arrow)
        -- if button.Text then
        --     button.Text:ClearPointsOffset()
        -- end
    end

    button:HookScript("OnMouseUp", ClearPointsOffset)
    button:HookScript("OnHide",ClearPointsOffset)
    button:HookScript("OnDisable", ClearPointsOffset)
end

---------------------------------------------------------------------
-- dropdown
---------------------------------------------------------------------
-- local function Dropdown_Create(prefix, level, index)
--     print("DropDownMenu_CreateFrames:", prefix, level, index)
-- end

-- local function Dropdown_Toggle(prefix, level)
--     print("ToggleDropDownMenu:", prefix, level)
-- end

-- function S.StyleDropdown(prefix)
--     -- Interface\AddOns\Blizzard_SharedXML\Mainline\UIDropDownMenu.lua
--     hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
--         Dropdown_Create(prefix, level, index)
--     end)
--     hooksecurefunc("ToggleDropDownMenu", function(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay, overrideDisplayMode)
--         Dropdown_Toggle(prefix, level)
--     end)
-- end

---------------------------------------------------------------------
-- scroll bar
---------------------------------------------------------------------
local function StyleScrollBarArrow(arrow, texture)
    arrow.Texture:SetAlpha(0)

    texture = AF.GetIcon(texture)
    arrow:SetNormalTexture(texture)
    -- arrow:SetPushedTexture(texture)
    arrow:SetDisabledTexture(texture)
    arrow:SetHighlightTexture(texture)

    local normalTex = arrow:GetNormalTexture()
    -- local pushedTex = arrow:GetPushedTexture()
    local disabledTex = arrow:GetDisabledTexture()
    local highlightTex = arrow:GetHighlightTexture()

    normalTex:SetVertexColor(AF.GetColorRGB("darkgray"))
    disabledTex:SetVertexColor(AF.GetColorRGB("disabled"))
    highlightTex:SetVertexColor(AF.GetColorRGB("white", 0.5))

    AF.SetSize(arrow, 16, 16)
end

local function ScorllThumb_OnEnter(self)
    self:SetBackdropColor(self.r, self.g, self.b, 0.9)
end

local function ScorllThumb_OnLeave(self)
    self:SetBackdropColor(self.r, self.g, self.b, 0.7)
end

function S.StyleScrollBar(scrollBar)
    assert(scrollBar, "StyleScrollBar: scrollBar is nil")

    if scrollBar._BFIStyled then return end
    scrollBar._BFIStyled = true

    S.RemoveTextures(scrollBar)
    StyleScrollBarArrow(scrollBar.Back, "ArrowUp_Small")
    StyleScrollBarArrow(scrollBar.Forward, "ArrowDown_Small")

    if scrollBar.Track then
        S.RemoveTextures(scrollBar.Track)
        AF.ApplyDefaultBackdropWithColors(scrollBar.Track, "widget")
        AF.AddToPixelUpdater_CustomGroup("BFIStyled", scrollBar.Track)
    end

    local thumb = scrollBar:GetThumb()
    if thumb then
        thumb:DisableDrawLayer("ARTWORK")
        thumb:DisableDrawLayer("BACKGROUND")

        local newThumb = AF.CreateBorderedFrame(thumb)
        scrollBar.BFIThumb = newThumb
        newThumb:SetAllPoints(thumb)

        newThumb.r, newThumb.g, newThumb.b = AF.GetColorRGB("BFI")
        newThumb:SetBackdropColor(newThumb.r, newThumb.g, newThumb.b, 0.7)

        newThumb:SetScript("OnEnter", ScorllThumb_OnEnter)
        newThumb:SetScript("OnLeave", ScorllThumb_OnLeave)
        newThumb:EnableMouse(false)
        newThumb:EnableMouseMotion(true)

        AF.RemoveFromPixelUpdater(newThumb)
        AF.AddToPixelUpdater_CustomGroup("BFIStyled", newThumb)
    end
end

---------------------------------------------------------------------
-- titled frame
---------------------------------------------------------------------
function S.StyleTitledFrame(frame)
    assert(frame, "StyleTitledFrame: frame is nil")

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

    AF.RemoveFromPixelUpdater(frame.BFIBg)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", frame.BFIBg)

    -- title
    frame.BFIHeader = AF.CreateBorderedFrame(frame, nil, nil, nil, "header", "border")
    frame.BFIHeader:SetPoint("TOPLEFT")
    frame.BFIHeader:SetPoint("TOPRIGHT")
    AF.SetHeight(frame.BFIHeader, 20)
    AF.RemoveFromPixelUpdater(frame.BFIHeader)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", frame.BFIHeader)

    -- frame.BFIHeader.tex = frame.BFIHeader:CreateTexture(nil, "ARTWORK")
    -- frame.BFIHeader.tex:SetColorTexture(AF.GetColorRGB("BFI", 0.025))
    frame.BFIHeader.tex = AF.CreateGradientTexture(frame.BFIHeader, "HORIZONTAL", AF.GetColorTable("BFI", 0.4), AF.GetColorTable("BFI", 0), nil, "ARTWORK")
    AF.SetOnePixelInside(frame.BFIHeader.tex, frame.BFIHeader)
    AF.RemoveFromPixelUpdater(frame.BFIHeader.tex)
    AF.AddToPixelUpdater_CustomGroup("BFIStyled", frame.BFIHeader.tex)

    if frame.TitleContainer then
        -- new style
        AF.SetFrameLevel(frame.BFIHeader, 0, frame.TitleContainer)
        frame.TitleContainer.TitleText:ClearAllPoints()
        frame.TitleContainer.TitleText:SetPoint("CENTER", frame.BFIHeader)
    else
        -- old style
        AF.SetFrameLevel(frame.BFIHeader, 1, frame)
        frame.TitleText:ClearAllPoints()
        frame.TitleText:SetPoint("CENTER", frame.BFIHeader)
        frame:DisableDrawLayer("BACKGROUND")
        frame:DisableDrawLayer("BORDER")
    end

    -- close button
    local closeButton = frame.CloseButton or (name and _G[name .. "CloseButton"])
    S.StyleCloseButton(closeButton)
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT")
    AF.SetFrameLevel(closeButton, 1, frame.BFIHeader)

    -- minimize/maximize button
    local maximizeMinimizeFrame = frame.MaximizeMinimizeButton or frame.MaximizeMinimizeFrame
    if maximizeMinimizeFrame then
        local maximizeButton = maximizeMinimizeFrame.MaximizeButton
        S.StyleMaximizeButton(maximizeButton)
        AF.SetFrameLevel(maximizeButton, 1, frame.BFIHeader)
        maximizeButton:ClearAllPoints()
        AF.SetPoint(maximizeButton, "TOPRIGHT", closeButton, "TOPLEFT", 1, 0)

        local minimizeButton = maximizeMinimizeFrame.MinimizeButton
        S.StyleMinimizeButton(minimizeButton)
        AF.SetFrameLevel(minimizeButton, 1, frame.BFIHeader)
        minimizeButton:ClearAllPoints()
        AF.SetPoint(minimizeButton, "TOPRIGHT", closeButton, "TOPLEFT", 1, 0)
    end
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
                    tab.BFIBackdrop:SetBackdropColor(AF.UnpackColor(tab._color))
                elseif i == frame.selectedTab then
                    -- PanelTemplates_SelectTab(tab)
                    -- print("PanelTemplates_UpdateTabs: tab is selected", tab:GetName())
                    tab.isSelected = true
                    tab.BFIBackdrop:SetBackdropColor(AF.UnpackColor(tab._hoverColor))
                else
                    -- PanelTemplates_DeselectTab(tab)
                    -- print("PanelTemplates_UpdateTabs: tab is deselected", tab:GetName())
                    tab.isSelected = false
                    tab.BFIBackdrop:SetBackdropColor(AF.UnpackColor(tab._color))
                end
            end
        end
    end
end)

hooksecurefunc("PanelTemplates_SelectTab", function(tab)
    if not tab._BFIStyled then return end
    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
end)

hooksecurefunc("PanelTemplates_DeselectTab", function(tab)
    if not tab._BFIStyled then return end
    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
end)

function S.StyleTab(tab)
    assert(tab, "StyleTab: tab is nil")
    if tab._BFIStyled then return end

    S.RemoveTextures(tab)
    S.StyleButton(tab, "BFI_hover")

    --! NOTE: taint
    -- Interface\AddOns\Blizzard_SharedXML\Mainline\SharedUIPanelTemplates.lua
    -- if tab.isTopTab then
    --     tab.selectedTextY = -7
    --     tab.deselectedTextY = -6
    -- else
    --     tab.selectedTextY = 0
    --     tab.deselectedTextY = 0
    -- end
    -- tab.selectedTextX = 0
    -- tab.deselectedTextX = 0

    AF.SetHeight(tab, 27)
end

---------------------------------------------------------------------
-- tab system
---------------------------------------------------------------------
local function SetTabSelected(tab, isSelected)
    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
    if not isSelected then
        tab.BFIBackdrop:SetBackdropColor(AF.UnpackColor(tab._color))
    else
        tab.BFIBackdrop:SetBackdropColor(AF.UnpackColor(tab._hoverColor))
    end
end

function S.StyleTabSystem(frame, skipRepositioning)
    assert(frame, "StyleTabSystem: frame is nil")

    if not skipRepositioning then
        AF.ClearPoints(frame)
        AF.SetPoint(frame, "TOPLEFT", frame:GetParent(), "BOTTOMLEFT", 0, -1)
    end

    for _, tab in next, frame.tabs do
        S.StyleTab(tab)
        hooksecurefunc(tab, "SetTabSelected", SetTabSelected)
    end
end

---------------------------------------------------------------------
-- side tab - SidePanelTabButtonMixin
---------------------------------------------------------------------
local function SideTab_OnMouseDown(tab, button)
    if button == "LeftButton" then
        tab.Icon:SetPoint("CENTER", 0, -1)
    end
end

local function SideTab_OnMouseUp(tab, button)
    if button == "LeftButton" then
        tab.Icon:SetPoint("CENTER")
    end
end

local function SideTab_OnEnter(tab)
    tab.SelectedTexture:Show()
    if tab.tooltipText then
        GameTooltip:SetOwner(tab, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", tab, "TOPRIGHT", 1, 0)
        GameTooltip:SetText(tab.tooltipText)
        GameTooltip:Show()
    end
end

local function SideTab_OnLeave(tab)
    if not tab._checked then
        tab.SelectedTexture:Hide()
    end
    GameTooltip:Hide()
end

local function SideTab_SetChecked(tab, checked)
    tab._checked = checked
end

function S.StyleSideTab(tab)
    assert(tab, "StyleSideTab: tab is nil")

    if tab._BFIStyled then return end
    tab._BFIStyled = true

    S.RemoveTextures(tab)
    S.CreateBackdrop(tab)
    tab.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget"))

    AF.SetSize(tab, 35, 50)
    tab.Icon:SetPoint("CENTER")

    tab.SelectedTexture = AF.CreateTexture(tab, nil, AF.GetColorTable("BFI", 0.6), "BORDER", -1)
    tab.SelectedTexture:SetAllPoints()
    tab.SelectedTexture:Hide()

    tab:HookScript("OnMouseDown", SideTab_OnMouseDown)
    tab:HookScript("OnMouseUp", SideTab_OnMouseUp)
    tab:SetScript("OnEnter", SideTab_OnEnter)
    tab:SetScript("OnLeave", SideTab_OnLeave)
    hooksecurefunc(tab, "SetChecked", SideTab_SetChecked)
end

---------------------------------------------------------------------
-- SpellSearchPreviewContainer
---------------------------------------------------------------------
local function SpellSearchPreview_UpdateEach(button)
    if not button._BFIStyled then
        S.StyleButton(button)
        -- button._hoverColor = AF.GetColorTable("widget_highlight2")

        local icon = button.Icon
        S.StyleIcon(icon, true)
        AF.SetSize(icon, 15, 15)
        AF.ClearPoints(icon)
        AF.SetPoint(icon, "LEFT", 7, 0)
        AF.SetOnePixelOutside(icon.BFIBackdrop, icon)
        icon:SetTexture(button.resultInfo.icon)
        icon:SetAlpha(1)
        icon:Show()
    end
end

local function SpellSearchPreview_Update(scrollBox)
    scrollBox:ForEachFrame(SpellSearchPreview_UpdateEach)
end

function S.StyleSpellSearchPreviewContainer(container)
    assert(container, "StyleSpellSearchPreviewContainer: container is nil")

    if container._BFIStyled then return end
    container._BFIStyled = true

    S.RemoveTextures(container)

    hooksecurefunc(container, "UpdateResultsDisplay", function(self)
        if self.ScrollBox:HasDataProvider() then
            if not self._BFIHooked then
                self._BFIHooked = true
                hooksecurefunc(self.ScrollBox, "Update", SpellSearchPreview_Update)
            end
        else
            for button in self.suggestedResultButtonsPool:EnumerateActive() do
                S.StyleButton(button)
                -- button._hoverColor = AF.GetColorTable("widget_highlight2")
            end
        end
    end)
end

---------------------------------------------------------------------
-- update pixels using OnUpdateExecutor
---------------------------------------------------------------------
local start

local function UpdatePixels(_, region, remaining, total)
    region:UpdatePixels()
    -- print("BFIStyled: ", AF.RoundToDecimal((total - remaining) / total, 2))
end

local pixelUpdateExecutor = AF.BuildOnUpdateExecutor(UpdatePixels, function(_, num)
    AF.Debug("Updated pixels for BFIStyled group", num, AF.RoundToDecimal(GetTimePreciseSec() - start, 3))
end, 10)

local function StartPixelUpdateProcess()
    pixelUpdateExecutor:Clear()
    start = GetTimePreciseSec()
    pixelUpdateExecutor:Submit(AF.GetPixelUpdater_CustomGroupComponents("BFIStyled"), true)
end

AF.RegisterCallback("AF_PIXEL_UPDATE", StartPixelUpdateProcess)
AF.RegisterCallback("AF_FIRST_FRAME_RENDERED", function()
    if not InCombatLockdown() then
        StartPixelUpdateProcess()
    end
end)