---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}

---------------------------------------------------------------------
-- indicator settings
---------------------------------------------------------------------
local indicators = {
    healthBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "smoothing",
        "healPrediction",
        "shield,overshieldGlow",
        "healAbsorb,overabsorbGlow",
        "mouseoverHighlight",
        "dispelHighlight",
        "frameLevel",
    },
    powerBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "smoothing",
        "frequent",
        "frameLevel",
    }
}

---------------------------------------------------------------------
-- copy,paste,reset
---------------------------------------------------------------------
builder["copy,paste,reset"] = function(parent)
    if created["copy,paste,reset"] then return created["copy,paste,reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_CopyPasteReset", nil, 30)
    created["copy,paste,reset"] = pane
    pane:Hide()

    local copiedId, copiedOwnerName, copiedTime, copiedCfg

    local copy = AF.CreateButton(pane, L["Copy"], "BFI_hover", 100, 20)
    AF.SetPoint(copy, "LEFT", 15, 0)
    copy:SetOnClick(function()
        copiedId = pane.t.id
        copiedOwnerName = pane.t.ownerName
        copiedTime = time()
        copiedCfg = AF.Copy(pane.t.cfg)
    end)

    local paste = AF.CreateButton(pane, L["Paste"], "BFI_hover", 100, 20)
    AF.SetPoint(paste, "TOPLEFT", copy, "TOPRIGHT", 5, 0)
    paste:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Overwrite with copied config?"], "BFI") .. "\n"
            .. "[" .. L[copiedId] .. "]\n"
            .. copiedOwnerName .. AF.WrapTextInColor(" -> ", "darkgray") .. pane.t.ownerName .. "\n"
            .. AF.WrapTextInColor(AF.FormatRelativeTime(copiedTime), "darkgray")

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            AF.Merge(pane.t.cfg, copiedCfg)
            UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
        end)
    end)


    local reset = AF.CreateButton(pane, L["Reset"], "BFI_hover", 100, 20)
    AF.SetPoint(reset, "TOPLEFT", paste, "TOPRIGHT", 5, 0)
    reset:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Reset to default config?"], "BFI") .. "\n"
            .. "[" .. L[pane.t.id] .. "]\n"
            .. pane.t.ownerName

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            AF.Merge(pane.t.cfg, UF.GetFrameDefaults(pane.t.owner, "indicator", pane.t.id))
            UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
        end)
    end)

    function pane.Load(t)
        pane.t = t
        AF.SetEnabled(pane.t.id == copiedId, paste)
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)
    enabled:SetOnCheck(function(checked)
        pane.t.cfg.enabled = checked
        -- pane.t is list button that carries info
        pane.t:SetTextColor(checked and "white" or "disabled")
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        enabled:SetChecked(t.cfg.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- position,anchorTo
---------------------------------------------------------------------
local function GetAnchorToItems()
    local validRelativeTos = {
        "root",
        "healthBar", "powerBar", "portrait", "castBar", "extraManaBar", "classPowerBar", "staggerBar",
        "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "incDmgHealText",
        "buffs", "debuffs",
        "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon",
    }

    for i, to in next, validRelativeTos do
        if to == "root" then
            validRelativeTos[i] = {text = L["Unit Frame"], value = to}
        else
            validRelativeTos[i] = {text = L[to], value = to}
        end
    end
    return validRelativeTos
end

local function GetAnchorPointItems()
    local items = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM"}
    for i, item in next, items do
        items[i] = {text = L[item], value = item}
    end
    return items
end

builder["position,anchorTo"] = function(parent)
    if created["position,anchorTo"] then return created["position,anchorTo"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_PositionAnchorTo", nil, 150)
    created["position,anchorTo"] = pane

    local validRelativeTos = GetAnchorToItems()

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems(validRelativeTos)
    relativeTo:SetOnSelect(function(value)
        pane.t.cfg.anchorTo = value
        UF.LoadIndicatorPosition(pane.t.target.indicators[pane.t.id], pane.t.cfg.position, pane.t.cfg.anchorTo)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, 0, -45)
    anchorPoint:SetItems(GetAnchorPointItems())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.position[1] = value
        UF.LoadIndicatorPosition(pane.t.target.indicators[pane.t.id], pane.t.cfg.position, pane.t.cfg.anchorTo)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(GetAnchorPointItems())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.position[2] = value
        UF.LoadIndicatorPosition(pane.t.target.indicators[pane.t.id], pane.t.cfg.position, pane.t.cfg.anchorTo)
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)
    x:SetOnValueChanged(function(value)
        pane.t.cfg.position[3] = value
        UF.LoadIndicatorPosition(pane.t.target.indicators[pane.t.id], pane.t.cfg.position, pane.t.cfg.anchorTo)
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetOnValueChanged(function(value)
        pane.t.cfg.position[4] = value
        UF.LoadIndicatorPosition(pane.t.target.indicators[pane.t.id], pane.t.cfg.position, pane.t.cfg.anchorTo)
    end)

    function pane.Load(t)
        pane.t = t

        for _, to in next, validRelativeTos do
            if to.value ~= "root" then
                to.disabled = not t.target.indicators[to.value] or to.value == t.id
            end
        end
        relativeTo.reloadRequired = true

        relativeTo:SetSelectedValue(t.cfg.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- frameLevel
---------------------------------------------------------------------
builder["frameLevel"] = function(parent)
    if created["frameLevel"] then return created["frameLevel"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_FrameLevel", nil, 55)
    created["frameLevel"] = pane

    local frameLevel = AF.CreateSlider(pane, L["Frame Level"], 150, 0, 100, 1, nil, true)
    AF.SetPoint(frameLevel, "LEFT", 15, 0)
    frameLevel:SetOnValueChanged(function(value)
        pane.t.cfg.frameLevel = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        frameLevel:SetValue(t.cfg.frameLevel)
    end

    return pane
end

---------------------------------------------------------------------
-- smoothing
---------------------------------------------------------------------
builder["smoothing"] = function(parent)
    if created["smoothing"] then return created["smoothing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_Smoothing", nil, 30)
    created["smoothing"] = pane

    local smoothing = AF.CreateCheckButton(pane, L["Smooth Bar Transition"])
    AF.SetPoint(smoothing, "LEFT", 15, 0)
    smoothing:SetOnCheck(function(checked)
        pane.t.cfg.smoothing = checked
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        smoothing:SetChecked(t.cfg.smoothing)
    end

    return pane
end

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
builder["texture"] = function(parent)
    if created["texture"] then return created["texture"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_Texture", nil, 55)
    created["texture"] = pane

    local texture = AF.CreateDropdown(pane, 150)
    texture:SetLabel(L["Texture"])
    AF.SetPoint(texture, "TOPLEFT", 15, -25)
    texture:SetItems(AF.LSM_GetBarTextureDropdownItems())
    texture:SetOnSelect(function(value)
        pane.t.cfg.texture = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        texture:SetSelectedValue(t.cfg.texture)
    end

    return pane
end

---------------------------------------------------------------------
-- pane for bar colors
---------------------------------------------------------------------
local function CreatePaneForBarColors(parent, colorType, frameName, label, gradientLabel, alphaLabel)
    local pane = AF.CreateBorderedFrame(parent, frameName, nil, 105)

    -- color --------------------------------------------------
    local colorDropdown = AF.CreateDropdown(pane, 150)
    colorDropdown:SetLabel(label)
    AF.SetPoint(colorDropdown, "TOPLEFT", 15, -25)

    local healthBarColorItems = {
        {text = L["Class"], value = "class_color"},
        {text = L["Class (Dark)"], value = "class_color_dark"},
        {text = L["Custom"], value = "custom_color"},
    }

    local powerBarColorItems = {
        {text = L["Class"], value = "class_color"},
        {text = L["Class (Dark)"], value = "class_color_dark"},
        {text = L["Power"], value = "power_color"},
        {text = L["Power (Dark)"], value = "power_color_dark"},
        {text = L["Custom"], value = "custom_color"},
    }

    local orientationDropdown = AF.CreateDropdown(pane, 150)
    orientationDropdown:SetLabel(gradientLabel)
    AF.SetPoint(orientationDropdown, "TOPLEFT", colorDropdown, 185, 0)
    orientationDropdown:SetItems({
        {text = L["Disabled"], value = "disabled"},
        {text = L["Horizontal"], value = "horizontal"},
        {text = L["Horizontal (Flipped)"], value = "horizontal_flipped"},
        {text = L["Vertical"], value = "vertical"},
        {text = L["Vertical (Flipped)"], value = "vertical_flipped"},
    })

    local colorPicker1 = AF.CreateColorPicker(pane)
    colorPicker1:SetOnChange(function(r, g, b, a)
        if #pane.t.cfg[colorType].rgb == 4 then
            pane.t.cfg[colorType].rgb[1] = r
            pane.t.cfg[colorType].rgb[2] = g
            pane.t.cfg[colorType].rgb[3] = b
        else
            pane.t.cfg[colorType].rgb[1][1] = r
            pane.t.cfg[colorType].rgb[1][2] = g
            pane.t.cfg[colorType].rgb[1][3] = b
        end
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local colorPicker2 = AF.CreateColorPicker(pane)
    colorPicker2:SetOnChange(function(r, g, b, a)
        pane.t.cfg[colorType].rgb[2][1] = r
        pane.t.cfg[colorType].rgb[2][2] = g
        pane.t.cfg[colorType].rgb[2][3] = b
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local colorAlphaSlider1 = AF.CreateSlider(pane, alphaLabel .. " 1", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(colorAlphaSlider1, "TOPLEFT", colorDropdown, 0, -45)
    colorAlphaSlider1:SetOnValueChanged(function(value)
        if pane.t.cfg[colorType].gradient == "disabled" then
            pane.t.cfg[colorType].alpha = value
        else
            pane.t.cfg[colorType].alpha[1] = value
        end
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local colorAlphaSlider2 = AF.CreateSlider(pane, alphaLabel .. " 2", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(colorAlphaSlider2, "TOPLEFT", colorAlphaSlider1, 185, 0)
    colorAlphaSlider2:SetOnValueChanged(function(value)
        pane.t.cfg[colorType].alpha[2] = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local function UpdateColorWidgets(color)
        AF.ClearPoints(colorPicker1)
        AF.ClearPoints(colorPicker2)

        if color.type == "class_color" or color.type == "class_color_dark" or color.type == "power_color" or color.type == "power_color_dark" then
            if color.gradient == "disabled" then
                colorPicker1:Hide()
                colorPicker2:Hide()

                if type(color.alpha) ~= "number" then color.alpha = 1 end
                colorAlphaSlider1:SetValue(color.alpha)
                colorAlphaSlider2:SetEnabled(false)
            else
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                colorPicker1:Show()
                colorPicker2:Hide()

                if type(color.alpha) ~= "table" then color.alpha = {1, 1} end
                colorAlphaSlider1:SetValue(color.alpha[1])
                colorAlphaSlider2:SetValue(color.alpha[2])
                colorAlphaSlider2:SetEnabled(true)

                if #color.rgb ~= 4 then color.rgb = {1, 1, 1, 1} end
                colorPicker1:SetColor(color.rgb)
            end

        else -- custom_color
            if color.gradient == "disabled" then
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                colorPicker1:Show()
                colorPicker2:Hide()

                if type(color.alpha) ~= "number" then color.alpha = 1 end
                colorAlphaSlider1:SetValue(color.alpha)
                colorAlphaSlider2:SetEnabled(false)

                if #color.rgb ~= 4 then
                    color.rgb = colorType == "color" and AF.GetColorTable("uf") or AF.GetColorTable("uf_loss")
                end
                colorPicker1:SetColor(color.rgb)
            else
                AF.SetPoint(colorPicker2, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorPicker2, "BOTTOMLEFT", -2, 0)
                colorPicker1:Show()
                colorPicker2:Show()

                if type(color.alpha) ~= "table" then color.alpha = {1, 1} end
                colorAlphaSlider1:SetValue(color.alpha[1])
                colorAlphaSlider2:SetValue(color.alpha[2])
                colorAlphaSlider2:SetEnabled(true)

                if #color.rgb ~= 2 then color.rgb = {AF.GetColorTable("blazing_tangerine"), AF.GetColorTable("vivid_raspberry")} end
                colorPicker1:SetColor(color.rgb[1])
                colorPicker2:SetColor(color.rgb[2])
            end
        end
    end

    colorDropdown:SetOnSelect(function(value)
        AF.HideColorPicker()
        pane.t.cfg[colorType].type = value
        UpdateColorWidgets(pane.t.cfg[colorType])
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    orientationDropdown:SetOnSelect(function(value)
        AF.HideColorPicker()
        pane.t.cfg[colorType].gradient = value
        UpdateColorWidgets(pane.t.cfg[colorType])
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t

        if pane.t.id == "healthBar" then
            colorDropdown:SetItems(healthBarColorItems)
        else
            colorDropdown:SetItems(powerBarColorItems)
        end

        colorDropdown:SetSelectedValue(t.cfg[colorType].type)
        orientationDropdown:SetSelectedValue(t.cfg[colorType].gradient)
        UpdateColorWidgets(t.cfg[colorType])
    end

    return pane
end

---------------------------------------------------------------------
-- barColor
---------------------------------------------------------------------
builder["barColor"] = function(parent)
    if created["barColor"] then return created["barColor"] end

    created["barColor"] = CreatePaneForBarColors(parent, "color", "BFI_IndicatorOption_BarColor", L["Bar Color"], L["Bar Gradient"], L["Bar Alpha"])
    return created["barColor"]
end

---------------------------------------------------------------------
-- barLossColor
---------------------------------------------------------------------
builder["barLossColor"] = function(parent)
    if created["barLossColor"] then return created["barLossColor"] end

    created["barLossColor"] = CreatePaneForBarColors(parent, "lossColor", "BFI_IndicatorOption_BarLossColor", L["Loss Color"], L["Loss Gradient"], L["Loss Alpha"])
    return created["barLossColor"]
end

---------------------------------------------------------------------
-- bgColor,borderColor
---------------------------------------------------------------------
builder["bgColor,borderColor"] = function(parent)
    if created["bgColor,borderColor"] then return created["bgColor,borderColor"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_BgBorderColor", nil, 30)
    created["bgColor,borderColor"] = pane

    local bgColor = AF.CreateColorPicker(pane, L["Background Color"], true)
    AF.SetPoint(bgColor, "LEFT", 15, 0)
    bgColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.bgColor[1] = r
        pane.t.cfg.bgColor[2] = g
        pane.t.cfg.bgColor[3] = b
        pane.t.cfg.bgColor[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local borderColor = AF.CreateColorPicker(pane, L["Border Color"], true)
    AF.SetPoint(borderColor, "TOPLEFT", bgColor, 185, 0)
    borderColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.borderColor[1] = r
        pane.t.cfg.borderColor[2] = g
        pane.t.cfg.borderColor[3] = b
        pane.t.cfg.borderColor[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        bgColor:SetColor(t.cfg.bgColor)
        borderColor:SetColor(t.cfg.borderColor)
    end

    return created["bgColor,borderColor"]
end

---------------------------------------------------------------------
-- healPrediction
---------------------------------------------------------------------
builder["healPrediction"] = function(parent)
    if created["healPrediction"] then return created["healPrediction"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_HealPrediction", nil, 51)
    created["healPrediction"] = pane

    local healPredictionCheckButton = AF.CreateCheckButton(pane, L["Heal Prediction"])
    AF.SetPoint(healPredictionCheckButton, "TOPLEFT", 15, -8)
    healPredictionCheckButton:SetOnCheck(function(checked)
        t.cfg.healPrediction = checked
        UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
    end)

    local customColorCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(customColorCheckButton, "TOPLEFT", healPredictionCheckButton, "BOTTOMLEFT", 0, -7)

    local customColorPicker = AF.CreateColorPicker(pane, L["Custom Color"], true)
    AF.SetPoint(customColorPicker, "TOPLEFT", customColorCheckButton, "TOPRIGHT", 2, 0)
    customColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.healPrediction.color[1] = r
        pane.t.cfg.healPrediction.color[2] = g
        pane.t.cfg.healPrediction.color[3] = b
        pane.t.cfg.healPrediction.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.healPrediction.enabled, customColorCheckButton, customColorPicker)
        customColorPicker:SetEnabled(pane.t.cfg.healPrediction.useCustomColor)
    end

    healPredictionCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healPrediction.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    customColorCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healPrediction.useCustomColor = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        healPredictionCheckButton:SetChecked(t.cfg.healPrediction.enabled)
        customColorCheckButton:SetChecked(t.cfg.healPrediction.useCustomColor)
        customColorPicker:SetColor(t.cfg.healPrediction.color)
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- shield,overshieldGlow
---------------------------------------------------------------------
builder["shield,overshieldGlow"] = function(parent)
    if created["shield,overshieldGlow"] then return created["shield,overshieldGlow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_Shields", nil, 78)
    created["shield,overshieldGlow"] = pane

    local shieldDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(shieldDropdown, "TOPLEFT", 15, -25)
    local items = AF.LSM_GetBarTextureDropdownItems()
    tinsert(items, 1, {text = L["Default"], value = "default"})
    shieldDropdown:SetItems(items)

    local shieldCheckButton = AF.CreateCheckButton(pane, L["Shield"])
    AF.SetPoint(shieldCheckButton, "BOTTOMLEFT", shieldDropdown, "TOPLEFT", 0, 2)

    local shieldColorPicker = AF.CreateColorPicker(pane, nil, true)
    AF.SetPoint(shieldColorPicker, "BOTTOMRIGHT", shieldDropdown, "TOPRIGHT", 0, 2)
    shieldColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.shield.color[1] = r
        pane.t.cfg.shield.color[2] = g
        pane.t.cfg.shield.color[3] = b
        pane.t.cfg.shield.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local shieldReverseFillCheckButton = AF.CreateCheckButton(pane, L["Reverse Fill"])
    AF.SetPoint(shieldReverseFillCheckButton, "TOPLEFT", shieldDropdown, "BOTTOMLEFT", 0, -10)
    shieldReverseFillCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.shield.reverseFill = checked
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local overshieldGlowCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(overshieldGlowCheckButton, "LEFT", shieldDropdown, 185, 0)

    local overshieldGlowColorPicker = AF.CreateColorPicker(pane, L["Overshield Texture"], true)
    AF.SetPoint(overshieldGlowColorPicker, "TOPLEFT", overshieldGlowCheckButton, "TOPRIGHT", 2, 0)
    overshieldGlowColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.overshieldGlow.color[1] = r
        pane.t.cfg.overshieldGlow.color[2] = g
        pane.t.cfg.overshieldGlow.color[3] = b
        pane.t.cfg.overshieldGlow.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()

        AF.SetEnabled(pane.t.cfg.shield.enabled, shieldDropdown, shieldColorPicker, shieldReverseFillCheckButton)
        AF.SetEnabled(pane.t.cfg.overshieldGlow.enabled, overshieldGlowColorPicker)

        shieldCheckButton:SetChecked(pane.t.cfg.shield.enabled)
        shieldDropdown:SetSelectedValue(pane.t.cfg.shield.texture)
        shieldColorPicker:SetColor(pane.t.cfg.shield.color)
        shieldReverseFillCheckButton:SetChecked(pane.t.cfg.shield.reverseFill)

        overshieldGlowCheckButton:SetChecked(pane.t.cfg.overshieldGlow.enabled)
        overshieldGlowColorPicker:SetColor(pane.t.cfg.overshieldGlow.color)
    end

    shieldDropdown:SetOnSelect(function(value)
        pane.t.cfg.shield.texture = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    shieldCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.shield.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    overshieldGlowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.overshieldGlow.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- healAbsorb,overabsorbGlow
---------------------------------------------------------------------
builder["healAbsorb,overabsorbGlow"] = function(parent)
    if created["healAbsorb,overabsorbGlow"] then return created["healAbsorb,overabsorbGlow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_HealAbsorbs", nil, 54)
    created["healAbsorb,overabsorbGlow"] = pane

    local absorbDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(absorbDropdown, "TOPLEFT", 15, -25)
    local items = AF.LSM_GetBarTextureDropdownItems()
    tinsert(items, 1, {text = L["Default"], value = "default"})
    absorbDropdown:SetItems(items)

    local absorbCheckButton = AF.CreateCheckButton(pane, L["Heal Absorb"])
    AF.SetPoint(absorbCheckButton, "BOTTOMLEFT", absorbDropdown, "TOPLEFT", 0, 2)

    local absorbColorPicker = AF.CreateColorPicker(pane, nil, true)
    AF.SetPoint(absorbColorPicker, "BOTTOMRIGHT", absorbDropdown, "TOPRIGHT", 0, 2)
    absorbColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.healAbsorb.color[1] = r
        pane.t.cfg.healAbsorb.color[2] = g
        pane.t.cfg.healAbsorb.color[3] = b
        pane.t.cfg.healAbsorb.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local overabsorbGlowCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(overabsorbGlowCheckButton, "LEFT", absorbDropdown, 185, 0)

    local overabsorbGlowColorPicker = AF.CreateColorPicker(pane, L["Overabsorb Texture"], true)
    AF.SetPoint(overabsorbGlowColorPicker, "TOPLEFT", overabsorbGlowCheckButton, "TOPRIGHT", 2, 0)
    overabsorbGlowColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.overabsorbGlow.color[1] = r
        pane.t.cfg.overabsorbGlow.color[2] = g
        pane.t.cfg.overabsorbGlow.color[3] = b
        pane.t.cfg.overabsorbGlow.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()

        AF.SetEnabled(pane.t.cfg.healAbsorb.enabled, absorbDropdown, absorbColorPicker)
        AF.SetEnabled(pane.t.cfg.overabsorbGlow.enabled, overabsorbGlowColorPicker)

        absorbCheckButton:SetChecked(pane.t.cfg.healAbsorb.enabled)
        absorbDropdown:SetSelectedValue(pane.t.cfg.healAbsorb.texture)
        absorbColorPicker:SetColor(pane.t.cfg.healAbsorb.color)

        overabsorbGlowCheckButton:SetChecked(pane.t.cfg.overabsorbGlow.enabled)
        overabsorbGlowColorPicker:SetColor(pane.t.cfg.overabsorbGlow.color)
    end

    absorbDropdown:SetOnSelect(function(value)
        pane.t.cfg.healAbsorb.texture = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    absorbCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healAbsorb.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    overabsorbGlowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.overabsorbGlow.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- mouseoverHighlight
---------------------------------------------------------------------
builder["mouseoverHighlight"] = function(parent)
    if created["mouseoverHighlight"] then return created["mouseoverHighlight"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_MouseoverHighlight", nil, 30)
    created["mouseoverHighlight"] = pane

    local mouseoverHighlightCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(mouseoverHighlightCheckButton, "LEFT", 15, 0)

    local mouseoverHighlightColorPicker = AF.CreateColorPicker(pane, L["Mouseover Highlight Color"], true)
    AF.SetPoint(mouseoverHighlightColorPicker, "TOPLEFT", mouseoverHighlightCheckButton, "TOPRIGHT", 2, 0)
    mouseoverHighlightColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.mouseoverHighlight.color[1] = r
        pane.t.cfg.mouseoverHighlight.color[2] = g
        pane.t.cfg.mouseoverHighlight.color[3] = b
        pane.t.cfg.mouseoverHighlight.color[4] = a
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    mouseoverHighlightCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.mouseoverHighlight.enabled = checked
        mouseoverHighlightColorPicker:SetEnabled(checked)
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        mouseoverHighlightCheckButton:SetChecked(t.cfg.mouseoverHighlight.enabled)
        mouseoverHighlightColorPicker:SetColor(t.cfg.mouseoverHighlight.color)
        mouseoverHighlightColorPicker:SetEnabled(t.cfg.mouseoverHighlight.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- dispelHighlight
---------------------------------------------------------------------
builder["dispelHighlight"] = function(parent)
    if created["dispelHighlight"] then return created["dispelHighlight"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_DispelHighlight", nil, 80)
    created["dispelHighlight"] = pane

    local dispelHighlightCheckButton = AF.CreateCheckButton(pane, L["Dispel Highlight"])
    AF.SetPoint(dispelHighlightCheckButton, "TOPLEFT", 15, -8)

    local onlyDispellableCheckButton = AF.CreateCheckButton(pane, L["Only Dispellable"])
    AF.SetPoint(onlyDispellableCheckButton, "TOPLEFT", dispelHighlightCheckButton, 185, 0)
    onlyDispellableCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.dispelHighlight.dispellable = checked
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local alphaSlider = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alphaSlider, "TOPLEFT", dispelHighlightCheckButton, "BOTTOMLEFT", 0, -25)
    alphaSlider:SetOnValueChanged(function(value)
        pane.t.cfg.dispelHighlight.alpha = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local blendModeDropdown = AF.CreateDropdown(pane, 150)
    blendModeDropdown:SetLabel(L["Blend Mode"])
    AF.SetPoint(blendModeDropdown, "TOPLEFT", alphaSlider, 185, 0)
    blendModeDropdown:SetItems({
        {text = "DISABLE"},
        {text = "ADD"},
        -- {text = "ALPHAKEY"},
        -- {text = "BLEND"},
        {text = "MOD"},
    })
    blendModeDropdown:SetOnSelect(function(value)
        pane.t.cfg.dispelHighlight.blendMode = value
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.dispelHighlight.enabled, onlyDispellableCheckButton, alphaSlider, blendModeDropdown)

        dispelHighlightCheckButton:SetChecked(pane.t.cfg.dispelHighlight.enabled)
        onlyDispellableCheckButton:SetChecked(pane.t.cfg.dispelHighlight.dispellable)
        alphaSlider:SetValue(pane.t.cfg.dispelHighlight.alpha)
        blendModeDropdown:SetSelectedValue(pane.t.cfg.dispelHighlight.blendMode)
    end

    dispelHighlightCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.dispelHighlight.enabled = checked
        UpdateWidgets()
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- frequent
---------------------------------------------------------------------
builder["frequent"] = function(parent)
    if created["frequent"] then return created["frequent"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_IndicatorOption_Frequent", nil, 30)
    created["frequent"] = pane

    local frequentCheckButton = AF.CreateCheckButton(pane, L["Frequent Updates"])
    AF.SetPoint(frequentCheckButton, "LEFT", 15, 0)
    frequentCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.frequent = checked
        UF.LoadIndicatorConfig(pane.t.target, pane.t.id, pane.t.cfg)
    end)

    function pane.Load(t)
        pane.t = t
        frequentCheckButton:SetChecked(t.cfg.frequent)
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetIndicatorOptions(parent, id)
    for _, option in pairs(created) do
        option:Hide()
        AF.ClearPoints(option)
    end

    local options = {}
    tinsert(options, builder["copy,paste,reset"](parent))
    created["copy,paste,reset"]:Show()

    if not indicators[id] then return options end

    for _, option in pairs(indicators[id]) do
        if builder[option] then
            tinsert(options, builder[option](parent))
            created[option]:Show()
        end
    end

    return options
end