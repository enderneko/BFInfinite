---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local DB = BFI.modules.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    experienceBar = {
        "hideAtMaxLevel",
        "width,height",
        "texture",
        "colors",
        "xpColors",
        "texts",
    },
    reputationBar = {
        "hideBelowMaxLevel",
        "width,height",
        "texture",
        "colors",
        "texts",
    },
    honorBar = {
        "hideBelowMaxLevel",
        "width,height",
        "texture",
        "colors",
        "texts",
    },
}

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
builder["reset"] = function(parent)
    if created["reset"] then return created["reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Reset", nil, 30)
    created["reset"] = pane
    pane:Hide()

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 110, 20)
    AF.SetPoint(reset, "LEFT", 15, 0)
    reset:SetOnClick(function()
        local dialog = AF.GetDialog(BFIOptionsFrame_DataBarsPanel, AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. pane.t.ownerName, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            DB.ResetToDefaults(pane.t.id)
            AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
            AF.Fire("BFI_RefreshOptions", "dataBars")
        end)
    end)

    function pane.Load(t)
        pane.t = t
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    local function UpdateColor(checked)
        if checked then
            enabled.label:SetTextColor(AF.GetColorRGB("softlime"))
        else
            enabled.label:SetTextColor(AF.GetColorRGB("firebrick"))
        end
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.enabled = checked
        UpdateColor(checked)
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
        pane.t:SetTextColor(checked and "white" or "disabled")
    end)

    function pane.Load(t)
        pane.t = t
        UpdateColor(t.cfg.enabled)
        enabled:SetChecked(t.cfg.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- hideAtMaxLevel
---------------------------------------------------------------------
builder["hideAtMaxLevel"] = function(parent)
    if created["hideAtMaxLevel"] then return created["hideAtMaxLevel"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_HideAtMaxLevel", nil, 30)
    created["hideAtMaxLevel"] = pane

    local hideAtMaxLevel = AF.CreateCheckButton(pane, L["Hide At Max Level"])
    AF.SetPoint(hideAtMaxLevel, "LEFT", 15, 0)
    hideAtMaxLevel:SetOnCheck(function(checked)
        pane.t.cfg.hideAtMaxLevel = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        hideAtMaxLevel:SetChecked(t.cfg.hideAtMaxLevel)
    end

    return pane
end

---------------------------------------------------------------------
-- hideBelowMaxLevel
---------------------------------------------------------------------
builder["hideBelowMaxLevel"] = function(parent)
    if created["hideBelowMaxLevel"] then return created["hideBelowMaxLevel"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_HideBelowMaxLevel", nil, 30)
    created["hideBelowMaxLevel"] = pane

    local hideBelowMaxLevel = AF.CreateCheckButton(pane, L["Hide Below Max Level"])
    AF.SetPoint(hideBelowMaxLevel, "LEFT", 15, 0)
    hideBelowMaxLevel:SetOnCheck(function(checked)
        pane.t.cfg.hideBelowMaxLevel = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        hideBelowMaxLevel:SetChecked(t.cfg.hideBelowMaxLevel)
    end

    return pane
end

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
builder["texture"] = function(parent)
    if created["texture"] then return created["texture"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Texture", nil, 54)
    created["texture"] = pane

    local texture = AF.CreateDropdown(pane, 150)
    texture:SetLabel(L["Texture"])
    AF.SetPoint(texture, "TOPLEFT", 15, -25)
    texture:SetItems(AF.LSM_GetBarTextureDropdownItems())
    texture:SetOnSelect(function(value)
        pane.t.cfg.texture = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        texture:SetSelectedValue(t.cfg.texture)
    end

    return pane
end

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
builder["colors"] = function(parent)
    if created["colors"] then return created["colors"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Colors", nil, 103)
    created["colors"] = pane

    local color = AF.CreateDropdown(pane, 150)
    color:SetLabel(L["Color"])
    AF.SetPoint(color, "TOPLEFT", 15, -25)
    color:SetItems({
        {text = L["Gradient"], value = "gradient"},
        {text = L["Solid"], value = "solid"},
    })

    local endColor = AF.CreateColorPicker(pane)
    AF.SetPoint(endColor, "BOTTOMRIGHT", color, "TOPRIGHT", 0, 2)
    endColor:SetOnChange(function(r, g, b)
        pane.t.cfg.color.endColor[1] = r
        pane.t.cfg.color.endColor[2] = g
        pane.t.cfg.color.endColor[3] = b
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local startColor = AF.CreateColorPicker(pane)
    AF.SetPoint(startColor, "BOTTOMRIGHT", endColor, "BOTTOMLEFT", -2, 0)
    startColor:SetOnChange(function(r, g, b)
        pane.t.cfg.color.startColor[1] = r
        pane.t.cfg.color.startColor[2] = g
        pane.t.cfg.color.startColor[3] = b
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local backgroundColor = AF.CreateColorPicker(pane, L["Background Color"], true)
    AF.SetPoint(backgroundColor, "TOPLEFT", color, 185, 16)
    backgroundColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.bgColor[1] = r
        pane.t.cfg.bgColor[2] = g
        pane.t.cfg.bgColor[3] = b
        pane.t.cfg.bgColor[4] = a
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local borderColor = AF.CreateColorPicker(pane, L["Border Color"], true)
    AF.SetPoint(borderColor, "TOPLEFT", backgroundColor, "BOTTOMLEFT", 0, -7)
    borderColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.borderColor[1] = r
        pane.t.cfg.borderColor[2] = g
        pane.t.cfg.borderColor[3] = b
        pane.t.cfg.borderColor[4] = a
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local startAlpha = AF.CreateSlider(pane, L["Alpha"] .. " 1", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(startAlpha, "TOPLEFT", color, "BOTTOMLEFT", 0, -25)
    startAlpha:SetOnValueChanged(function(value)
        pane.t.cfg.color.startAlpha = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local endAlpha = AF.CreateSlider(pane, L["Alpha"] .. " 2", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(endAlpha, "TOPLEFT", startAlpha, 185, 0)
    endAlpha:SetOnValueChanged(function(value)
        pane.t.cfg.color.endAlpha = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local function UpdateWidgets()
        if pane.t.cfg.color.type == "gradient" then
            if pane.t.cfg.color.startColor then
                startColor:Show()
            else
                startColor:Hide()
            end
            endColor:Show()
            startAlpha:SetEnabled(true)
        else -- solid
            startColor:Hide()
            endColor:SetShown(pane.t.id ~= "reputationBar")
            startAlpha:SetEnabled(false)
        end
    end

    color:SetOnSelect(function(value)
        pane.t.cfg.color.type = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
        UpdateWidgets()
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
        color:SetSelectedValue(t.cfg.color.type)
        startAlpha:SetValue(t.cfg.color.startAlpha)
        endAlpha:SetValue(t.cfg.color.endAlpha)
        if t.cfg.color.startColor then
            startColor:SetColor(t.cfg.color.startColor)
        end
        endColor:SetColor(t.cfg.color.endColor)
        backgroundColor:SetColor(t.cfg.bgColor)
        borderColor:SetColor(t.cfg.borderColor)
    end

    return pane
end

---------------------------------------------------------------------
-- xpColors
---------------------------------------------------------------------
builder["xpColors"] = function(parent)
    if created["xpColors"] then return created["xpColors"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_XPColors", nil, 72)
    created["xpColors"] = pane

    -- rested
    local rested = AF.CreateCheckButton(pane)
    AF.SetPoint(rested, "TOPLEFT", 15, -8)

    local restedColor = AF.CreateColorPicker(pane, L["Rested"], true)
    AF.SetPoint(restedColor, "TOPLEFT", rested, "TOPRIGHT", 2, 0)
    restedColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.rested.color[1] = r
        pane.t.cfg.rested.color[2] = g
        pane.t.cfg.rested.color[3] = b
        pane.t.cfg.rested.color[4] = a
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    rested:SetOnCheck(function(checked)
        pane.t.cfg.rested.enabled = checked
        restedColor:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    -- completed
    local completed = AF.CreateCheckButton(pane)
    AF.SetPoint(completed, "TOPLEFT", rested, "BOTTOMLEFT", 0, -7)

    local completedColor = AF.CreateColorPicker(pane, L["Completed Quests"], true)
    AF.SetPoint(completedColor, "TOPLEFT", completed, "TOPRIGHT", 2, 0)
    completedColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.completedQuests.color[1] = r
        pane.t.cfg.completedQuests.color[2] = g
        pane.t.cfg.completedQuests.color[3] = b
        pane.t.cfg.completedQuests.color[4] = a
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    completed:SetOnCheck(function(checked)
        pane.t.cfg.completedQuests.enabled = checked
        completedColor:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    -- incomplete
    local incomplete = AF.CreateCheckButton(pane)
    AF.SetPoint(incomplete, "TOPLEFT", completed, "BOTTOMLEFT", 0, -7)

    local incompleteColor = AF.CreateColorPicker(pane, L["Incomplete Quests"], true)
    AF.SetPoint(incompleteColor, "TOPLEFT", incomplete, "TOPRIGHT", 2, 0)
    incompleteColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.incompleteQuests.color[1] = r
        pane.t.cfg.incompleteQuests.color[2] = g
        pane.t.cfg.incompleteQuests.color[3] = b
        pane.t.cfg.incompleteQuests.color[4] = a
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    incomplete:SetOnCheck(function(checked)
        pane.t.cfg.incompleteQuests.enabled = checked
        incompleteColor:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t

        rested:SetChecked(t.cfg.rested.enabled)
        restedColor:SetColor(t.cfg.rested.color)
        restedColor:SetEnabled(t.cfg.rested.enabled)

        completed:SetChecked(t.cfg.completedQuests.enabled)
        completedColor:SetColor(t.cfg.completedQuests.color)
        completedColor:SetEnabled(t.cfg.completedQuests.enabled)

        incomplete:SetChecked(t.cfg.incompleteQuests.enabled)
        incompleteColor:SetColor(t.cfg.incompleteQuests.color)
        incompleteColor:SetEnabled(t.cfg.incompleteQuests.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 3, 1000, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 3, 100, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- spacing
---------------------------------------------------------------------
builder["spacing"] = function(parent)
    if created["spacing"] then return created["spacing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Spacing", nil, 55)
    created["spacing"] = pane

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacing, "LEFT", 15, 0)
    spacing:SetOnValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        spacing:SetValue(t.cfg.spacing)
    end

    return pane
end

---------------------------------------------------------------------
-- texts
---------------------------------------------------------------------
builder["texts"] = function(parent)
    if created["texts"] then return created["texts"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Texts", nil, 407)
    created["texts"] = pane

    local enabled = AF.CreateCheckButton(pane, AF.GetGradientText(L["Enable Texts"], "BFI", "white"))
    AF.SetPoint(enabled, "TOPLEFT", 15, -8)

    local alwaysShow = AF.CreateCheckButton(pane, L["Always Show Texts"])
    AF.SetPoint(alwaysShow, "TOPLEFT", enabled, 185, 0)
    alwaysShow:SetOnCheck(function(checked)
        pane.t.cfg.texts.alwaysShow = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    -- font
    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -30)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.texts.font[1] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.texts.font[3] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.texts.font[2] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.texts.font[4] = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -40)
    yOffset:SetOnValueChanged(function(value)
        pane.t.cfg.texts.yOffset = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    -- format
    local leftFormat = AF.CreateEditBox(pane, nil, 150, 20, "trim")
    AF.SetPoint(leftFormat, "TOPLEFT", yOffset, "BOTTOMLEFT", 0, -60)
    leftFormat:SetConfirmButton(function(value)
        pane.t.cfg.texts.leftFormat = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end, nil, "RIGHT_OUTSIDE")
    leftFormat.enabledLabel = AF.GetGradientText(L["Left Text Format"], "BFI", "white")
    leftFormat.disabledLabel = AF.WrapTextInColor(L["Left Text Format"], "disabled")

    local rightFormat = AF.CreateEditBox(pane, nil, 150, 20, "trim")
    AF.SetPoint(rightFormat, "TOPLEFT", leftFormat, 185, 0)
    rightFormat:SetConfirmButton(function(value)
        pane.t.cfg.texts.rightFormat = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end, nil, "RIGHT_OUTSIDE")
    rightFormat.enabledLabel = AF.GetGradientText(L["Right Text Format"], "BFI", "white")
    rightFormat.disabledLabel = AF.WrapTextInColor(L["Right Text Format"], "disabled")

    local centerFormat = AF.CreateEditBox(pane, nil, 150, 20, "trim")
    AF.SetPoint(centerFormat, "TOPLEFT", leftFormat, "BOTTOMLEFT", 0, -25)
    centerFormat:SetConfirmButton(function(value)
        pane.t.cfg.texts.centerFormat = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end, nil, "RIGHT_OUTSIDE")
    centerFormat.enabledLabel = AF.GetGradientText(L["Center Text Format"], "BFI", "white")
    centerFormat.disabledLabel = AF.WrapTextInColor(L["Center Text Format"], "disabled")

    -- available tags
    local tags = AF.CreateScrollList(pane, nil, 0, 0, 3, 20, 5, "none", "none")
    AF.SetPoint(tags, "TOPLEFT", centerFormat, "BOTTOMLEFT", 0, -45)
    AF.SetPoint(tags, "RIGHT", rightFormat)
    tags:SetLabel(L["Available Tags"], "white")

    local widgetPool = AF.CreateObjectPool(function()
        local f = AF.CreateFrame(tags)

        local eb = AF.CreateEditBox(f, nil, 150, 20)
        eb:SetNotUserChangable(true)
        eb:SetPoint("TOPLEFT")

        local text = AF.CreateFontString(f)
        AF.SetPoint(text, "LEFT", eb, "RIGHT", 5, 0)

        function f:Load(data)
            eb:SetText(data.tag)
            text:SetText(data.desc)
        end

        return f
    end)
    tags:SetWidgetPool(widgetPool)

    local availableTags = {
        experienceBar = {
            {tag = "[level]", desc = L["Level"]},
            {tag = "[current]", desc = L["Current"]},
            {tag = "[total]", desc = L["Total"]},
            {tag = "[percent]", desc = L["Percentage"]},
            {tag = "[remaining]", desc = L["Remaining"]},
            {tag = "[rested]", desc = L["Rested"]},
            {tag = "[completed]", desc = L["Completed Quests"]},
            {tag = "[incomplete]", desc = L["Incomplete Quests"]},
        },
        reputationBar = {
            {tag = "[name]", desc = L["Name"]},
            {tag = "[standing]", desc = L["Reputation"]},
            {tag = "[current]", desc = L["Current"]},
            {tag = "[total]", desc = L["Total"]},
            {tag = "[progress]", desc = L["Progress"]},
        },
        honorBar = {
            {tag = "[level]", desc = L["Honor Level"]},
            {tag = "[current]", desc = L["Current"]},
            {tag = "[total]", desc = L["Total"]},
            {tag = "[progress]", desc = L["Progress"]},
        },
    }

    -- update widgets
    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.texts.enabled, alwaysShow,
            fontDropdown, fontOutlineDropdown, fontSizeSlider, shadowCheckButton, yOffset,
            leftFormat, centerFormat, rightFormat,
            tags.label
        )

        if pane.t.cfg.texts.enabled then
            leftFormat:SetLabelAlt(leftFormat.enabledLabel)
            rightFormat:SetLabelAlt(rightFormat.enabledLabel)
            centerFormat:SetLabelAlt(centerFormat.enabledLabel)
            AF.HideMask(tags)
        else
            leftFormat:SetLabelAlt(leftFormat.disabledLabel)
            rightFormat:SetLabelAlt(rightFormat.disabledLabel)
            centerFormat:SetLabelAlt(centerFormat.disabledLabel)
            AF.ShowMask(tags, nil, 0, 0, 0, 0)
        end
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.texts.enabled = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
        UpdateWidgets()
    end)

    function pane.Load(t)
        pane.t = t

        UpdateWidgets()
        tags:SetData(availableTags[t.id])

        enabled:SetChecked(t.cfg.texts.enabled)
        alwaysShow:SetChecked(t.cfg.texts.alwaysShow)
        fontDropdown:SetSelectedValue(t.cfg.texts.font[1])
        fontSizeSlider:SetValue(t.cfg.texts.font[2])
        fontOutlineDropdown:SetSelectedValue(t.cfg.texts.font[3])
        shadowCheckButton:SetChecked(t.cfg.texts.font[4])
        yOffset:SetValue(t.cfg.texts.yOffset)
        leftFormat:SetText(t.cfg.texts.leftFormat)
        centerFormat:SetText(t.cfg.texts.centerFormat)
        rightFormat:SetText(t.cfg.texts.rightFormat)
    end

    return pane
end

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
builder["font"] = function(parent)
    if created["font"] then return created["font"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_DataBarOption_Font", nil, 103)
    created["font"] = pane

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[1] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local fontColorPicker = AF.CreateColorPicker(pane)
    AF.SetPoint(fontColorPicker, "BOTTOMRIGHT", fontDropdown, "TOPRIGHT", 0, 2)
    fontColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.cfg.color[1] = r
        pane.t.cfg.color[2] = g
        pane.t.cfg.color[3] = b
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[3] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.font[2] = value
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.font[4] = checked
        AF.Fire("BFI_UpdateModule", "dataBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        fontDropdown:SetSelectedValue(t.cfg.font[1])
        fontSizeSlider:SetValue(t.cfg.font[2])
        fontOutlineDropdown:SetSelectedValue(t.cfg.font[3])
        shadowCheckButton:SetChecked(t.cfg.font[4])
        if t.cfg.color then
            fontColorPicker:Show()
            fontColorPicker:SetColor(t.cfg.color)
        else
            fontColorPicker:Hide()
        end
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetDataBarOptions(parent, info)
    for _, pane in pairs(created) do
        pane:Hide()
        AF.ClearPoints(pane)
    end

    wipe(options)
    tinsert(options, builder["reset"](parent))
    created["reset"]:Show()
    tinsert(options, builder["enabled"](parent))
    created["enabled"]:Show()

    local setting = info.id
    if not settings[setting] then return options end

    for _, option in pairs(settings[setting]) do
        if type(option) == "table" then
            local pane = builder["tips"](parent)
            tinsert(options, pane)
            pane:Show()
            pane.SetTips(AF.TableToString(option, "\n"))
        elseif builder[option] then
            local pane = builder[option](parent)
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end