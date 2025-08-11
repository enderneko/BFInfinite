---@class BFI
local BFI = select(2, ...)
local C = BFI.Chat
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local chatPanel

---------------------------------------------------------------------
-- chat panel
---------------------------------------------------------------------
local function CreateChatPanel()
    chatPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_ChatPanel")
    chatPanel:SetAllPoints()
end

---------------------------------------------------------------------
-- chat frame pane
---------------------------------------------------------------------
local chatFramePane
local function CreateChatFramePane()
    chatFramePane = AF.CreateTitledPane(chatPanel, L["Chat Frame"], 350, 300)
    chatPanel.chatFramePane = chatFramePane
    AF.SetPoint(chatFramePane, "TOPLEFT", chatPanel, 15, -15)

    local enabled = AF.CreateCheckButton(chatFramePane, L["Enabled"])
    AF.SetPoint(enabled, "TOPLEFT", chatFramePane, 10, -30)
    enabled:SetOnCheck(function(checked)
        C.config.enabled = checked
        AF.Fire("BFI_UpdateModule", "chat")

        local dialog = AF.GetDialog(chatPanel, L["A UI reload is required\nDo it now?"])
        AF.SetPoint(dialog, "TOP", 0, -50)
        dialog:SetOnConfirm(ReloadUI)
    end)

    local bgColor = AF.CreateColorPicker(chatFramePane, L["Background Color"], true)
    AF.SetPoint(bgColor, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -15)
    bgColor:SetOnConfirm(function(r, g, b, a)
        C.config.bgColor[1] = r
        C.config.bgColor[2] = g
        C.config.bgColor[3] = b
        C.config.bgColor[4] = a
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local borderColor = AF.CreateColorPicker(chatFramePane, L["Border Color"], true)
    AF.SetPoint(borderColor, "TOPLEFT", bgColor, 180, 0)
    borderColor:SetOnConfirm(function(r, g, b, a)
        C.config.borderColor[1] = r
        C.config.borderColor[2] = g
        C.config.borderColor[3] = b
        C.config.borderColor[4] = a
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local fadeTime = AF.CreateDropdown(chatFramePane, 150)
    AF.SetPoint(fadeTime, "TOPLEFT", bgColor, "BOTTOMLEFT", 0, -35)
    fadeTime:SetLabel(L["Text Fade Time"])
    fadeTime:SetItems({
        {text = _G.NEVER, value = 0},
        {text = AF.L["%d seconds"]:format(30), value = 30},
        {text = AF.L["%d seconds"]:format(60), value = 60},
        {text = AF.L["%d minutes"]:format(2), value = 120},
        {text = AF.L["%d minutes"]:format(5), value = 300},
        {text = AF.L["%d minutes"]:format(10), value = 600},
    })
    fadeTime:SetOnSelect(function(value)
        C.config.fadeTime = value
        C.config.fading = value > 0
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local maxLines = AF.CreateDropdown(chatFramePane, 150)
    AF.SetPoint(maxLines, "TOPLEFT", fadeTime, 180, 0)
    maxLines:SetLabel(L["Max Lines"])
    maxLines:SetItems({
        {text = "100", value = 100},
        {text = "200", value = 200},
        {text = "300", value = 300},
        {text = "500", value = 500},
    })
    maxLines:SetOnSelect(function(value)
        C.config.maxLines = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local width = AF.CreateSlider(chatFramePane, L["Width"], 150, 200, 1000, 1, nil, true)
    AF.SetPoint(width, "TOPLEFT", fadeTime, "BOTTOMLEFT", 0, -30)
    width:SetAfterValueChanged(function(value)
        C.config.width = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local height = AF.CreateSlider(chatFramePane, L["Height"], 150, 100, 1000, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 180, 0)
    height:SetAfterValueChanged(function(value)
        C.config.height = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local fontSwitch = AF.CreateSwitch(chatFramePane, 150)
    AF.SetPoint(fontSwitch, "TOPLEFT", width, "BOTTOMLEFT", 0, -55)
    fontSwitch:SetLabels({
        {text = L["Font"], value = "font"},
        {text = L["Tab Font"], value = "tabFont"},
    })

    local font = AF.CreateDropdown(chatFramePane, 150)
    AF.SetPoint(font, "TOPLEFT", fontSwitch, "BOTTOMLEFT", 0, -25)
    font:SetLabel(L["Font"])
    font:SetItems(AF.LSM_GetFontDropdownItems())
    font:SetOnSelect(function(value)
        C.config[fontSwitch:GetSelectedValue()][1] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local outline = AF.CreateDropdown(chatFramePane, 150)
    outline:SetLabel(L["Outline"])
    AF.SetPoint(outline, "TOPLEFT", font, 180, 0)
    outline:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    outline:SetOnSelect(function(value)
        C.config[fontSwitch:GetSelectedValue()][3] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local size = AF.CreateSlider(chatFramePane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", font, "BOTTOMLEFT", 0, -25)
    size:SetAfterValueChanged(function(value)
        C.config[fontSwitch:GetSelectedValue()][2] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local shadow = AF.CreateCheckButton(chatFramePane, L["Shadow"])
    AF.SetPoint(shadow, "LEFT", size, 180, 0)
    shadow:SetOnCheck(function(checked)
        C.config[fontSwitch:GetSelectedValue()][4] = checked
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    fontSwitch:SetOnSelect(function(value)
        local t = C.config[value]
        font:SetSelectedValue(t[1])
        outline:SetSelectedValue(t[3])
        size:SetValue(t[2])
        shadow:SetChecked(t[4])
    end)

    function chatFramePane.Load()
        local config = C.config
        enabled:SetChecked(config.enabled)
        bgColor:SetColor(config.bgColor)
        borderColor:SetColor(config.borderColor)
        fadeTime:SetSelectedValue(config.fadeTime)
        maxLines:SetSelectedValue(config.maxLines)
        width:SetValue(config.width)
        height:SetValue(config.height)
        fontSwitch:SetSelectedValue(fontSwitch:GetSelectedValue() or "font", true)
    end
end

---------------------------------------------------------------------
-- chat editbox pane
---------------------------------------------------------------------
local chatEditBoxPane
local function CreateChatEditBoxPane()
    chatEditBoxPane = AF.CreateTitledPane(chatPanel, L["Chat Input Box"], 170, 300)
    chatPanel.chatEditBoxPane = chatEditBoxPane
    AF.SetPoint(chatEditBoxPane, "TOPLEFT", chatFramePane, "TOPRIGHT", 30, 0)

    local anchorPoint = AF.CreateDropdown(chatEditBoxPane, 150)
    AF.SetPoint(anchorPoint, "TOPLEFT", 10, -40)
    anchorPoint:SetLabel(L["Anchor Point"])
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        C.config.editBoxPosition[1] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local relativePoint = AF.CreateDropdown(chatEditBoxPane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -30)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        C.config.editBoxPosition[2] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local xOffset = AF.CreateSlider(chatEditBoxPane, L["X Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", relativePoint, "BOTTOMLEFT", 0, -30)
    xOffset:SetAfterValueChanged(function(value)
        C.config.editBoxPosition[3] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)

    local yOffset = AF.CreateSlider(chatEditBoxPane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, "BOTTOMLEFT", 0, -45)
    yOffset:SetAfterValueChanged(function(value)
        C.config.editBoxPosition[4] = value
        AF.Fire("BFI_UpdateModule", "chat")
    end)


    function chatEditBoxPane.Load()
        local config = C.config
        anchorPoint:SetSelectedValue(config.editBoxPosition[1])
        relativePoint:SetSelectedValue(config.editBoxPosition[2])
        xOffset:SetValue(config.editBoxPosition[3])
        yOffset:SetValue(config.editBoxPosition[4])
    end
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Chat" then
        if not chatPanel then
            CreateChatPanel()
            CreateChatFramePane()
            CreateChatEditBoxPane()
        end
        chatFramePane.Load()
        chatEditBoxPane.Load()
        chatPanel:Show()
    elseif chatPanel then
        chatPanel:Hide()
    end
end)