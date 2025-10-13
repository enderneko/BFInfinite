---@type BFI
local BFI = select(2, ...)
local L = BFI.L
local BD = BFI.modules.BuffsDebuffs
---@type AbstractFramework
local AF = _G.AbstractFramework

local LoadOptions
local selected, currentConfig, currentTextConfig

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local buffsDebuffsPanel

local function CreateBuffsDebuffsPanel()
    buffsDebuffsPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_BuffsDebuffsPanel")
    buffsDebuffsPanel:SetAllPoints()
    AF.ApplyCombatProtectionToFrame(buffsDebuffsPanel)

    local switch = AF.CreateSwitch(buffsDebuffsPanel, nil, 20)
    buffsDebuffsPanel.switch = switch
    AF.SetPoint(switch, "TOPLEFT", 15, -15)
    AF.SetPoint(switch, "TOPRIGHT", -15, -15)
    switch:SetLabels({
        {text = L["Buffs"], value = "buffs"},
        {text = L["Debuffs"], value = "debuffs"},
        {text = L["Private Auras"], value = "privateAuras", disabled = true},
    })
    switch:SetOnSelect(LoadOptions)

    local enabled = AF.CreateCheckButton(switch)
    buffsDebuffsPanel.enabled = enabled
    AF.SetFrameLevel(enabled, 5)
    enabled.accentColor = "softlime"
    enabled.checkedTexture:SetColorTexture(AF.GetColorRGB(enabled.accentColor, 0.7))
    enabled.highlightTexture:SetColorTexture(AF.GetColorRGB(enabled.accentColor, 0.1))
    enabled:SetOnCheck(function(checked)
        BD.config[selected].enabled = checked
        LoadOptions()
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local reset = AF.CreateIconButton(switch, AF.GetIcon("Erase"), 15, 15, nil, "gray", "white")
    buffsDebuffsPanel.reset = reset
    AF.SetFrameLevel(reset, 5)
    reset:SetOnClick(function()
        local dialog = AF.GetDialog(buffsDebuffsPanel,
            AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n"
            .. switch:GetSelectedButton():GetText()
        )
        AF.SetPoint(dialog, "TOP", 0, -55)
        dialog:SetOnConfirm(function()
            BD.ResetToDefaults(selected)
            LoadOptions()
            AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
        end)
    end)
end

---------------------------------------------------------------------
-- normal
---------------------------------------------------------------------
local normalPane

local function CreateNormalPane()
    normalPane = AF.CreateFrame(buffsDebuffsPanel)
    AF.SetPoint(normalPane, "TOPLEFT", buffsDebuffsPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(normalPane, "BOTTOMRIGHT", -15, 15)

    --------------------------------------------------
    -- iconsPane
    --------------------------------------------------
    local iconsPane = AF.CreateTitledPane(normalPane, L["Icons"], nil, 235)
    AF.SetPoint(iconsPane, "TOPLEFT", 0, -5)
    AF.SetPoint(iconsPane, "TOPRIGHT", 0, -5)

    local arrangement = AF.CreateDropdown(iconsPane, 210)
    AF.SetPoint(arrangement, "TOPLEFT", iconsPane, "TOPLEFT", 10, -45)
    arrangement:SetLabel(L["Arrangement"])
    arrangement:SetItems(AF.GetDropdownItems_Arrangement_Complex())
    arrangement:SetOnSelect(function(value)
        currentConfig.orientation = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local sortMethod = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(sortMethod, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -30)
    sortMethod:SetLabel(L["Sort Method"])
    sortMethod:SetItems({
        {text = L["Index"], value = "INDEX"},
        {text = L["Name"], value = "NAME"},
        {text = L["Time"], value = "TIME"},
    })
    sortMethod:SetOnSelect(function(value)
        currentConfig.sortMethod = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local sortDirection = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(sortDirection, "TOPLEFT", sortMethod, "TOPRIGHT", 35, 0)
    sortDirection:SetLabel(L["Sort Direction"])
    sortDirection:SetItems({
        {text = L["Ascending"], value = "+"},
        {text = L["Descending"], value = "-"},
    })
    sortDirection:SetOnSelect(function(value)
        currentConfig.sortDirection = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local separateOwn = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(separateOwn, "TOPLEFT", sortDirection, "TOPRIGHT", 35, 0)
    separateOwn:SetLabel(L["Separate Own"])
    separateOwn:SetItems({
        {text = L["Disabled"], value = 0},
        {text = L["Before"], value = 1},
        {text = L["After"], value = -1},
    })
    separateOwn:SetOnSelect(function(value)
        currentConfig.separateOwn = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local width = AF.CreateSlider(iconsPane, L["Width"], 150, 10, 100, nil, nil, true)
    AF.SetPoint(width, "TOPLEFT", sortMethod, "BOTTOMLEFT", 0, -30)
    width:SetOnValueChanged(function(value)
        currentConfig.width = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local height = AF.CreateSlider(iconsPane, L["Height"], 150, 10, 100, nil, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, "BOTTOMLEFT", 0, -45)
    height:SetOnValueChanged(function(value)
        currentConfig.height = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local spacingX = AF.CreateSlider(iconsPane, L["X Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingX, "TOPLEFT", width, "TOPRIGHT", 35, 0)
    spacingX:SetOnValueChanged(function(value)
        currentConfig.spacingX = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local spacingY = AF.CreateSlider(iconsPane, L["Y Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingY, "TOPLEFT", height, "TOPRIGHT", 35, 0)
    spacingY:SetOnValueChanged(function(value)
        currentConfig.spacingY = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local maxWraps = AF.CreateSlider(iconsPane, L["Max Lines"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(maxWraps, "TOPLEFT", spacingX, "TOPRIGHT", 35, 0)
    maxWraps:SetOnValueChanged(function(value)
        currentConfig.maxWraps = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local wrapAfter = AF.CreateSlider(iconsPane, L["Displayed Per Line"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(wrapAfter, "TOPLEFT", spacingY, "TOPRIGHT", 35, 0)
    wrapAfter:SetOnValueChanged(function(value)
        currentConfig.wrapAfter = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    --------------------------------------------------
    -- textsPane
    --------------------------------------------------
    local textsPane = AF.CreateTitledPane(normalPane, L["Texts"], nil, 235)
    AF.SetPoint(textsPane, "TOPLEFT", iconsPane, "BOTTOMLEFT", 0, -30)
    AF.SetPoint(textsPane, "TOPRIGHT", iconsPane, "BOTTOMRIGHT", 0, -30)

    local textSwitch = AF.CreateSwitch(textsPane, 210, 20)
    AF.SetPoint(textSwitch, "BOTTOMRIGHT", textsPane.line, "BOTTOMRIGHT", 0, -1)
    textSwitch:SetLabels({
        {text = L["Stack Text"], value = "stack"},
        {text = L["Duration Text"], value = "duration"},
    })
    textSwitch:SetOnSelect(function()
        textsPane.Load(textSwitch:GetSelectedValue())
    end)

    local font = AF.CreateDropdown(textsPane, 150)
    AF.SetPoint(font, "TOPLEFT", 10, -45)
    font:SetItems(AF.LSM_GetFontDropdownItems())
    font:SetLabel(L["Font"])
    font:SetOnSelect(function(value)
        currentTextConfig.font[1] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local outline = AF.CreateDropdown(textsPane, 150)
    AF.SetPoint(outline, "TOPLEFT", font, "TOPRIGHT", 35, 0)
    outline:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    outline:SetLabel(L["Outline"])
    outline:SetOnSelect(function(value)
        currentTextConfig.font[3] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local size = AF.CreateSlider(textsPane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", font, "BOTTOMLEFT", 0, -30)
    size:SetOnValueChanged(function(value)
        currentTextConfig.font[2] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local shadow = AF.CreateCheckButton(textsPane, L["Shadow"])
    AF.SetPoint(shadow, "TOPLEFT", size, "TOPRIGHT", 35, 0)
    shadow:SetOnCheck(function(checked)
        currentTextConfig.font[4] = checked
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local anchorPoint = AF.CreateDropdown(textsPane, 150)
    AF.SetPoint(anchorPoint, "TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetLabel(L["Anchor Point"])
    anchorPoint:SetOnSelect(function(value)
        currentTextConfig.position[1] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local relativePoint = AF.CreateDropdown(textsPane, 150)
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, "TOPRIGHT", 35, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetLabel(L["Relative Point"])
    relativePoint:SetOnSelect(function(value)
        currentTextConfig.position[2] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local xOffset = AF.CreateSlider(textsPane, L["X Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -30)
    xOffset:SetOnValueChanged(function(value)
        currentTextConfig.position[3] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local yOffset = AF.CreateSlider(textsPane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, "TOPRIGHT", 35, 0)
    yOffset:SetOnValueChanged(function(value)
        currentTextConfig.position[4] = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local enabled = AF.CreateCheckButton(textsPane, L["Enabled"])
    AF.SetPoint(enabled, "TOPLEFT", outline, "TOPRIGHT", 35, 0)
    enabled:SetOnCheck(function(checked)
        currentTextConfig.enabled = checked
        textsPane.UpdateWidgets()
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local showSecondsUnit = AF.CreateCheckButton(textsPane, L["Show Seconds Unit"])
    AF.SetPoint(showSecondsUnit, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -15)
    showSecondsUnit:SetOnCheck(function(checked)
        currentTextConfig.showSecondsUnit = checked
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local normalColor = AF.CreateColorPicker(textsPane, L["Normal"])
    AF.SetPoint(normalColor, "TOPLEFT", showSecondsUnit, "BOTTOMLEFT", 0, -15)
    normalColor:SetOnChange(function(r, g, b)
        if textSwitch:GetSelectedValue() == "stack" then
            currentTextConfig.color[1] = r
            currentTextConfig.color[2] = g
            currentTextConfig.color[3] = b
        else
            currentTextConfig.color.normal[1] = r
            currentTextConfig.color.normal[2] = g
            currentTextConfig.color.normal[3] = b
        end
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local percentCheckButton = AF.CreateCheckButton(textsPane)
    AF.SetPoint(percentCheckButton, "TOPLEFT", normalColor, "BOTTOMLEFT", 0, -7)
    percentCheckButton:SetOnCheck(function(checked)
        currentTextConfig.color.percent.enabled = checked
        textsPane.UpdateWidgets()
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local percentColor = AF.CreateColorPicker(textsPane, L["Remaining Time"])
    AF.SetPoint(percentColor, "TOPLEFT", percentCheckButton, "TOPRIGHT", 2, 0)
    percentColor:SetOnChange(function(r, g, b)
        currentTextConfig.color.percent.rgb[1] = r
        currentTextConfig.color.percent.rgb[2] = g
        currentTextConfig.color.percent.rgb[3] = b
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    percentColor.label2 = AF.CreateFontString(percentColor, "<")
    AF.SetPoint(percentColor.label2, "TOPLEFT", percentColor.label, "BOTTOMLEFT", 0, -7)

    local percentDropdown = AF.CreateDropdown(textsPane, 45, nil, "vertical")
    AF.SetPoint(percentDropdown, "LEFT", percentColor.label2, "RIGHT", 5, 0)
    percentDropdown:SetItems({
        {text = "90%", value = 0.9},
        {text = "80%", value = 0.8},
        {text = "70%", value = 0.7},
        {text = "60%", value = 0.6},
        {text = "50%", value = 0.5},
        {text = "40%", value = 0.4},
        {text = "30%", value = 0.3},
        {text = "20%", value = 0.2},
        {text = "10%", value = 0.1},
    })
    percentDropdown:SetOnSelect(function(value)
        currentTextConfig.color.percent.value = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local secondsCheckButton = AF.CreateCheckButton(textsPane)
    AF.SetPoint(secondsCheckButton, "LEFT", percentCheckButton)
    AF.SetPoint(secondsCheckButton, "TOP", percentDropdown, "BOTTOM", 0, -7)
    secondsCheckButton:SetOnCheck(function(checked)
        currentTextConfig.color.seconds.enabled = checked
        textsPane.UpdateWidgets()
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    local secondsColor = AF.CreateColorPicker(textsPane, L["Remaining Time"])
    AF.SetPoint(secondsColor, "TOPLEFT", secondsCheckButton, "TOPRIGHT", 2, 0)
    secondsColor:SetOnChange(function(r, g, b)
        currentTextConfig.color.seconds.rgb[1] = r
        currentTextConfig.color.seconds.rgb[2] = g
        currentTextConfig.color.seconds.rgb[3] = b
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end)

    secondsColor.label2 = AF.CreateFontString(secondsColor, "<")
    AF.SetPoint(secondsColor.label2, "TOPLEFT", secondsColor.label, "BOTTOMLEFT", 0, -7)

    local secondsEditBox = AF.CreateEditBox(textsPane, nil, 45, 20, "number")
    AF.SetPoint(secondsEditBox, "LEFT", secondsColor.label2, "RIGHT", 5, 0)
    secondsEditBox:SetMaxLetters(3)
    secondsEditBox:SetConfirmButton(function(value)
        currentTextConfig.color.seconds.value = value
        AF.Fire("BFI_UpdateModule", "buffsDebuffs", selected)
    end, nil, "RIGHT_OUTSIDE")

    local sec = AF.CreateFontString(textsPane, L["sec"])
    AF.SetPoint(sec, "LEFT", secondsEditBox, "RIGHT", 5, 0)

    --------------------------------------------------
    -- load
    --------------------------------------------------
    function textsPane.UpdateWidgets()
        AF.SetEnabled(currentConfig.enabled, enabled)
        AF.SetEnabled(currentConfig.enabled and currentTextConfig.enabled, font, size, outline, shadow, anchorPoint, relativePoint, xOffset, yOffset, normalColor)

        local durationEnabled = currentConfig.enabled and currentTextConfig.enabled and textSwitch:GetSelectedValue() == "duration"
        AF.SetEnabled(durationEnabled, showSecondsUnit, percentCheckButton, secondsCheckButton)
        AF.SetEnabled(durationEnabled and currentTextConfig.color.percent.enabled, percentColor, percentColor.label2, percentDropdown)
        AF.SetEnabled(durationEnabled and currentTextConfig.color.seconds.enabled, secondsColor, secondsColor.label2, secondsEditBox, sec)
    end

    function textsPane.Load(which)
        currentTextConfig = BD.config[selected][which]

        textsPane.UpdateWidgets()
        enabled:SetChecked(currentTextConfig.enabled)

        font:SetSelectedValue(currentTextConfig.font[1])
        size:SetValue(currentTextConfig.font[2])
        outline:SetSelectedValue(currentTextConfig.font[3])
        shadow:SetChecked(currentTextConfig.font[4])
        anchorPoint:SetSelectedValue(currentTextConfig.position[1])
        relativePoint:SetSelectedValue(currentTextConfig.position[2])
        xOffset:SetValue(currentTextConfig.position[3])
        yOffset:SetValue(currentTextConfig.position[4])

        showSecondsUnit:SetChecked(currentTextConfig.showSecondsUnit)

        if which == "stack" then
            normalColor:SetColor(currentTextConfig.color)

            percentCheckButton:SetChecked(false)
            percentColor:SetColor(1, 1, 1)
            percentDropdown:ClearSelected()

            secondsCheckButton:SetChecked(false)
            secondsColor:SetColor(1, 1, 1)
            secondsEditBox:SetText("")
        else
            normalColor:SetColor(currentTextConfig.color.normal)

            percentCheckButton:SetChecked(currentTextConfig.color.percent.enabled)
            percentColor:SetColor(currentTextConfig.color.percent.rgb)
            percentDropdown:SetSelectedValue(currentTextConfig.color.percent.value)

            secondsCheckButton:SetChecked(currentTextConfig.color.seconds.enabled)
            secondsColor:SetColor(currentTextConfig.color.seconds.rgb)
            secondsEditBox:SetText(currentTextConfig.color.seconds.value)
        end
    end

    function normalPane.Load()
        currentConfig = BD.config[selected]

        -- icons
        AF.SetEnabled(currentConfig.enabled, arrangement, sortMethod, sortDirection, separateOwn, width, height, spacingX, spacingY, maxWraps, wrapAfter)
        arrangement:SetSelectedValue(currentConfig.orientation)
        sortMethod:SetSelectedValue(currentConfig.sortMethod)
        sortDirection:SetSelectedValue(currentConfig.sortDirection)
        separateOwn:SetSelectedValue(currentConfig.separateOwn)
        width:SetValue(currentConfig.width)
        height:SetValue(currentConfig.height)
        spacingX:SetValue(currentConfig.spacingX)
        spacingY:SetValue(currentConfig.spacingY)
        maxWraps:SetValue(currentConfig.maxWraps)
        wrapAfter:SetValue(currentConfig.wrapAfter)

        -- texts
        if not textSwitch:GetSelectedValue() then
            textSwitch:SetSelectedValue("stack")
        end
        textsPane.Load(textSwitch:GetSelectedValue())
    end
end

---------------------------------------------------------------------
-- private
---------------------------------------------------------------------
local privatePane

local function CreatePrivatePane()
    privatePane = AF.CreateFrame(buffsDebuffsPanel)
    AF.SetPoint(privatePane, "TOPLEFT", buffsDebuffsPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(privatePane, "BOTTOMRIGHT", -15, 15)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
LoadOptions = function()
    selected = buffsDebuffsPanel.switch:GetSelectedValue()

    if selected == "privateAuras" then
        normalPane:Hide()
        privatePane:Show()
    else
        normalPane:Show()
        privatePane:Hide()
        normalPane.Load()
    end

    AF.ClearPoints(buffsDebuffsPanel.enabled)
    AF.SetPoint(buffsDebuffsPanel.enabled, "LEFT", buffsDebuffsPanel.switch:GetSelectedButton(), "LEFT", 3, 0)
    buffsDebuffsPanel.enabled:SetChecked(BD.config[selected].enabled)

    AF.ClearPoints(buffsDebuffsPanel.reset)
    AF.SetPoint(buffsDebuffsPanel.reset, "RIGHT", buffsDebuffsPanel.switch:GetSelectedButton(), "RIGHT", -3, 0)

    for _, b in next, buffsDebuffsPanel.switch.buttons do
        if b:IsEnabled() then
            if BD.config[b.value].enabled then
                b.text:SetTextColor(1, 1, 1)
            else
                b.text:SetTextColor(AF.GetColorRGB("firebrick"))
            end
        end
    end
end

AF.RegisterCallback("BFI_RefreshOptions", function(_, which)
    if which ~= "buffsDebuffs" or not buffsDebuffsPanel then return end
    LoadOptions()
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "buffsDebuffs" then
        if not buffsDebuffsPanel then
            CreateBuffsDebuffsPanel()
            CreateNormalPane()
            CreatePrivatePane()
            buffsDebuffsPanel.switch:SetSelectedValue("buffs")
        end
        buffsDebuffsPanel:Show()
    elseif buffsDebuffsPanel then
        buffsDebuffsPanel:Hide()
    end
end)