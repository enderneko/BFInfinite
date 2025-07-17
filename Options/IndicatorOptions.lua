---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local indicators = {
    healthBar = {
        "enabled",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "width,height",
        "smoothing",
        "healPrediction",
        "shield,overshieldGlow",
        "healAbsorb,overabsorbGlow",
        "mouseoverHighlight",
        "dispelHighlight",
        "position,anchorTo",
        "frameLevel",
    }
}

local created = {}
local builder = {}

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function()
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    function pane.Load(t)
        enabled:SetChecked(t.cfg.enabled)
        enabled:SetOnCheck(function(checked)
            t.cfg.enabled = checked
            t:SetTextColor(checked and "white" or "disabled")
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function()
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)

    function pane.Load(t)
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)

        width:SetOnValueChanged(function(value)
            t.cfg.width = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)

        height:SetOnValueChanged(function(value)
            t.cfg.height = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
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

builder["position,anchorTo"] = function()
    if created["position,anchorTo"] then return created["position,anchorTo"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_PositionAnchorTo", nil, 150)
    created["position,anchorTo"] = pane

    local validRelativeTos = GetAnchorToItems()

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems(validRelativeTos)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, 0, -45)
    anchorPoint:SetItems(GetAnchorPointItems())

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(GetAnchorPointItems())

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)

    function pane.Load(t)
        for _, to in next, validRelativeTos do
            if to.value ~= "root" then
                to.disabled = not t.target.indicators[to.value]
            end
        end
        relativeTo.reloadRequired = true

        relativeTo:SetSelectedValue(t.cfg.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])

        relativeTo:SetOnSelect(function(value)
            t.cfg.anchorTo = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        anchorPoint:SetOnSelect(function(value)
            t.cfg.position[1] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        relativePoint:SetOnSelect(function(value)
            t.cfg.position[2] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        x:SetOnValueChanged(function(value)
            t.cfg.position[3] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        y:SetOnValueChanged(function(value)
            t.cfg.position[4] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- frameLevel
---------------------------------------------------------------------
builder["frameLevel"] = function()
    if created["frameLevel"] then return created["frameLevel"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_FrameLevel", nil, 55)
    created["frameLevel"] = pane

    local frameLevel = AF.CreateSlider(pane, L["Frame Level"], 150, 0, 100, 1, nil, true)
    AF.SetPoint(frameLevel, "LEFT", 15, 0)

    function pane.Load(t)
        frameLevel:SetValue(t.cfg.frameLevel)

        frameLevel:SetOnValueChanged(function(value)
            t.cfg.frameLevel = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- smoothing
---------------------------------------------------------------------
builder["smoothing"] = function()
    if created["smoothing"] then return created["smoothing"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Smoothing", nil, 30)
    created["smoothing"] = pane

    local smoothing = AF.CreateCheckButton(pane, L["Smooth Bar Transition"])
    AF.SetPoint(smoothing, "LEFT", 15, 0)

    function pane.Load(t)
        smoothing:SetChecked(t.cfg.smoothing)
        smoothing:SetOnCheck(function(checked)
            t.cfg.smoothing = checked
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
builder["texture"] = function()
    if created["texture"] then return created["texture"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Texture", nil, 55)
    created["texture"] = pane

    local texture = AF.CreateDropdown(pane, 150)
    texture:SetLabel(L["Texture"])
    AF.SetPoint(texture, "TOPLEFT", 15, -25)
    texture:SetItems(AF.LSM_GetBarTextureDropdownItems())

    function pane.Load(t)
        texture:SetSelectedValue(t.cfg.texture)
        texture:SetOnSelect(function(value)
            t.cfg.texture = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- pane for bar colors
---------------------------------------------------------------------
local function CreatePaneForBarColors(colorType, frameName, label, gradientLabel, alphaLabel)
    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, frameName, nil, 105)

    -- color --------------------------------------------------
    local colorDropdown = AF.CreateDropdown(pane, 150)
    colorDropdown:SetLabel(label)
    AF.SetPoint(colorDropdown, "TOPLEFT", 15, -25)
    colorDropdown:SetItems({
        {text = L["Class"], value = "class_color"},
        {text = L["Class (Dark)"], value = "class_color_dark"},
        {text = L["Custom"], value = "custom_color"},
    })

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

        if color.type == "class_color" or color.type == "class_color_dark" then
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

                if #color.rgb ~= 4 then color.rgb = AF.GetColorTable("uf") end
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
        colorDropdown:SetSelectedValue(t.cfg[colorType].type)
        orientationDropdown:SetSelectedValue(t.cfg[colorType].gradient)
        UpdateColorWidgets(t.cfg[colorType])
    end

    return pane
end

---------------------------------------------------------------------
-- barColor
---------------------------------------------------------------------
builder["barColor"] = function()
    if created["barColor"] then return created["barColor"] end

    created["barColor"] = CreatePaneForBarColors("color", "BFI_IndicatorOption_BarColor", L["Bar Color"], L["Bar Gradient"], L["Bar Alpha"])
    return created["barColor"]
end

---------------------------------------------------------------------
-- barLossColor
---------------------------------------------------------------------
builder["barLossColor"] = function()
    if created["barLossColor"] then return created["barLossColor"] end

    created["barLossColor"] = CreatePaneForBarColors("lossColor", "BFI_IndicatorOption_BarLossColor", L["Loss Color"], L["Loss Gradient"], L["Loss Alpha"])
    return created["barLossColor"]
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetIndicatorOptions(info)
    if not indicators[info.id] then return {} end

    local options = {}

    for _, option in pairs(indicators[info.id]) do
        if builder[option] then
            tinsert(options, builder[option]())
            created[option].Load(info)
        end
    end

    return options
end