---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local DEFAULT_WIDTH, DEFAULT_HEIGHT = 750, 600
local LIST_WIDTH = 170
local HEADER_HEIGHT = 35

local optionsFrame

---------------------------------------------------------------------
-- list
---------------------------------------------------------------------
local list = {
    "General",
    "-Tweaks",
    "SEPARATOR",
    "Colors",
    "Auras",
    "SEPARATOR",
    "Unit Frames",
    "-Nameplates",
    "-Buffs & Debuffs",
    "Action Bars",
    "Chat",
    "-Tooltip",
    "SEPARATOR",
    "About",
}

local frameWidths = {

}

local function CreateButton(name)
    local disabled
    name, disabled = name:gsub("^-", "")

    local button = AF.CreateButton(optionsFrame.listPane, L[name], nil, nil, 25, nil, "", "")
    button.id = name
    button:SetTextJustifyH("LEFT")
    button:SetTextPadding(10)
    button:SetBackdropColor(AF.GetColorRGB("none"))
    button:SetEnabled(disabled == 0)

    -- local highlight = AF.CreateTexture(button, nil, AF.GetColorTable("BFI", 0.6), "BORDER")
    local highlight = AF.CreateGradientTexture(button, "HORIZONTAL", "BFI", "none", nil, "BORDER")
    button.highlight = highlight
    highlight:Hide()
    highlight:SetPoint("TOPLEFT")
    highlight:SetPoint("BOTTOMLEFT")
    AF.SetWidth(highlight, 1)

    return button
end

local function CreateSeparator()
    local separator = AF.CreateTexture(optionsFrame.listPane, nil, "border")
    AF.SetHeight(separator, 1)
    return separator
end

local function ButtonOnDeselect(b)
    AF.AnimatedResize(b.highlight, 1, nil, nil, nil, nil, function()
        b.highlight:Hide()
    end)
end

local function ButtonOnEnter(b)
    if b.isSelected then return end
    AF.AnimatedResize(b.highlight, 7, nil, nil, nil, function()
        b.highlight:Show()
    end)
end

local function ButtonOnLeave(b)
    if b.isSelected then return end
    AF.AnimatedResize(b.highlight, 1, nil, nil, nil, nil, function()
        b.highlight:Hide()
    end)
end

local function ShowOptionsPanel(b, id)
    AF.AnimatedResize(b.highlight, b:GetWidth(), nil, nil, nil, function()
        b.highlight:Show()
    end)
    AF.SetWidth(optionsFrame, frameWidths[id] or DEFAULT_WIDTH)
    AF.Fire("BFI_ShowOptionsPanel", id)
end

local function BuildList()
    local buttons = {}

    local first
    local last

    for _, name in next, list do
        local item
        if name == "SEPARATOR" then
            item = CreateSeparator()
        else
            item = CreateButton(name)
            tinsert(buttons, item)
            if not first then first = item end
        end

        if last then
            AF.SetPoint(item, "TOPLEFT", last, "BOTTOMLEFT", 0, -5)
            AF.SetPoint(item, "TOPRIGHT", last, "BOTTOMRIGHT", 0, -5)
        else
            AF.SetPoint(item, "TOPLEFT", 7, -15)
            AF.SetPoint(item, "TOPRIGHT", -7, -15)
        end
        last = item
    end

    AF.CreateButtonGroup(buttons, ShowOptionsPanel, ButtonOnDeselect, nil, ButtonOnEnter, ButtonOnLeave)
    first:SilentClick()
end

---------------------------------------------------------------------
-- options frame
---------------------------------------------------------------------
local function ReAnchor()
    AF.ReAnchorRegion(optionsFrame, "TOPLEFT")
end

local function CreateOptionsFrame()
    optionsFrame = AF.CreateFrame(AFParent, "BFIOptionsFrame", DEFAULT_WIDTH, DEFAULT_HEIGHT)
    optionsFrame:Hide()

    tinsert(_G.UISpecialFrames, optionsFrame:GetName())

    optionsFrame:EnableMouse(true)
    optionsFrame:SetOnMouseWheel(AF.noop)
    optionsFrame:SetClampedToScreen(true)
    optionsFrame:SetFrameStrata("HIGH")
    optionsFrame:SetFrameLevel(777)
    optionsFrame:SetToplevel(true)
    optionsFrame:SetPoint("CENTER")

    AF.CreateGlow(optionsFrame, "shadow")

    optionsFrame:SetOnShow(ReAnchor)

    --------------------------------------------------
    -- header pane
    --------------------------------------------------
    local headerPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrame_HeaderPane", nil, HEADER_HEIGHT)
    optionsFrame.headerPane = headerPane
    headerPane:SetPoint("TOPLEFT")
    headerPane:SetPoint("TOPRIGHT")
    headerPane:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    AF.SetDraggable(headerPane, optionsFrame, true, nil, ReAnchor)

    -- logo
    local color2 = BFIConfig.accentColor.type == "custom" and {AF.InvertColor(AF.GetColorRGB("BFI"))} or "vivid_raspberry"
    local logo = AF.CreateGradientTexture(headerPane, "HORIZONTAL", "BFI", color2, AF.GetIcon("BFI_64_W", BFI.name))
    AF.SetSize(logo, 40, 40)
    AF.SetPoint(logo, "LEFT", headerPane, 7, 0)

    -- title
    local text = AF.WrapTextInColor("BFI", "BFI") .. AF.WrapTextInColorRGB("NFINITE", AF.GetColorRGB("BFI", nil, 0.7))
    local title = AF.CreateFontString(headerPane, text, nil, "BFI_FONT")
    AF.SetPoint(title, "LEFT", logo, "RIGHT", 7, 0)

    -- close button
    local closeButton = AF.CreateCloseButton(headerPane, optionsFrame, 35, 21, 15)
    AF.SetPoint(closeButton, "RIGHT", headerPane, -7, 0)

    -- reload button
    local reloadButton = AF.CreateButton(headerPane, nil, "BFI", 35, 21)
    AF.SetPoint(reloadButton, "BOTTOMRIGHT", closeButton, "BOTTOMLEFT", -7, 0)
    reloadButton:SetTexture(AF.GetIcon("Refresh"))
    reloadButton:SetTooltip(_G.RELOADUI)
    reloadButton:SetOnClick(_G.ReloadUI)

    -- edit mode button
    local editModeButton = AF.CreateButton(headerPane, nil, "BFI", 35, 21)
    AF.SetPoint(editModeButton, "BOTTOMRIGHT", reloadButton, "BOTTOMLEFT", -7, 0)
    editModeButton:SetTexture(AF.GetIcon("Layers"))
    editModeButton:SetTooltip(_G.HUD_EDIT_MODE_MENU)
    editModeButton:SetOnClick(function()
        optionsFrame:Hide()
        AF.ShowMovers()
    end)

    --------------------------------------------------
    -- list pane
    --------------------------------------------------
    local listPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrame_ListPane", LIST_WIDTH)
    optionsFrame.listPane = listPane
    AF.SetPoint(listPane, "TOPLEFT", headerPane, "BOTTOMLEFT", 0, 1)
    AF.SetPoint(listPane, "BOTTOMLEFT", optionsFrame)
    listPane:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
    AF.SetDraggable(listPane, optionsFrame, true, nil, ReAnchor)

    --------------------------------------------------
    -- content pane
    --------------------------------------------------
    local contentPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrame_ContentPane")
    optionsFrame.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", listPane, "TOPRIGHT", -1, 0)
    AF.SetPoint(contentPane, "BOTTOMRIGHT")
    AF.SetDraggable(contentPane, optionsFrame, true, nil, ReAnchor)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFI.ToggleOptionsFrame()
    if not optionsFrame then
        CreateOptionsFrame()
        BuildList()
    end
    optionsFrame:Toggle()
end