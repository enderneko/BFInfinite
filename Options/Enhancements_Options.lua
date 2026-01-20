---@type BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local E = BFI.modules.Enhancements
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    equipmentInfo = {
        "itemLevel",
        "durability",
        "missingEnhance",
    },
    mythicPlus = {
        "teleportButtons",
    },
}

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
builder["reset"] = function(parent)
    if created["reset"] then return created["reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_Reset", nil, 30)
    created["reset"] = pane
    pane:Hide()

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 110, 20)
    AF.SetPoint(reset, "LEFT", 15, 0)
    reset:SetOnClick(function()
        local dialog = AF.GetDialog(BFIOptionsFrame_EnhancementsPanel, AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. pane.t.ownerName, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            E.ResetToDefaults(pane.t.id)
            AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
            AF.Fire("BFI_RefreshOptions", "enhancements")
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

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_Enabled", nil, 30)
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
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
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
-- itemLevel
---------------------------------------------------------------------
builder["itemLevel"] = function(parent)
    if created["itemLevel"] then return created["itemLevel"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_ItemLevel", nil, 221)
    created["itemLevel"] = pane

    local enabled = AF.CreateCheckButton(pane, AF.GetGradientText(L["Show Item Level"], "BFI", "white"))
    AF.SetPoint(enabled, "TOPLEFT", 15, -8)

    local colorDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(colorDropdown, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -25)
    colorDropdown:SetLabel(L["Color"])
    colorDropdown:SetItems({
        {text = L["Quality Color"], value = "quality_color"},
        {text = L["Custom Color"], value = "custom_color"},
    })

    local colorPicker = AF.CreateColorPicker(pane)
    AF.SetPoint(colorPicker, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
    colorPicker:SetOnConfirm(function(r, g, b)
        pane.t.cfg.itemLevel.color.rgb[1] = r
        pane.t.cfg.itemLevel.color.rgb[2] = g
        pane.t.cfg.itemLevel.color.rgb[3] = b
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    colorDropdown:SetOnSelect(function(value)
        colorPicker:SetShown(value == "custom_color")
        pane.t.cfg.itemLevel.color.type = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    AF.SetPoint(anchorPoint, "TOPLEFT", colorDropdown, 185, 0)
    anchorPoint:SetLabel(L["Anchor Point"])
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.itemLevel.position[1] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", colorDropdown, "BOTTOMLEFT", 0, -25)
    xOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.itemLevel.position[2] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.itemLevel.position[3] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local font = AF.CreateDropdown(pane, 150)
    AF.SetPoint(font, "TOPLEFT", xOffset, "BOTTOMLEFT", 0, -40)
    font:SetLabel(L["Font"])
    font:SetItems(AF.LSM_GetFontDropdownItems())
    font:SetOnSelect(function(value)
        pane.t.cfg.itemLevel.font[1] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local outline = AF.CreateDropdown(pane, 150)
    AF.SetPoint(outline, "TOPLEFT", font, 185, 0)
    outline:SetLabel(L["Outline"])
    outline:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    outline:SetOnSelect(function(value)
        pane.t.cfg.itemLevel.font[3] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", font, "BOTTOMLEFT", 0, -25)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.itemLevel.font[2] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local shadow = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadow, "LEFT", size, 185, 0)
    shadow:SetOnCheck(function(checked)
        pane.t.cfg.itemLevel.font[4] = checked
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.itemLevel.enabled, colorDropdown, anchorPoint, xOffset, yOffset, font, outline, size, shadow)
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.itemLevel.enabled = checked
        UpdateWidgets()
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        enabled:SetChecked(t.cfg.itemLevel.enabled)
        colorDropdown:SetSelectedValue(t.cfg.itemLevel.color.type)
        colorPicker:SetColor(t.cfg.itemLevel.color.rgb)
        colorPicker:SetShown(t.cfg.itemLevel.color.type == "custom_color")
        anchorPoint:SetSelectedValue(t.cfg.itemLevel.position[1])
        xOffset:SetValue(t.cfg.itemLevel.position[2])
        yOffset:SetValue(t.cfg.itemLevel.position[3])
        font:SetSelectedValue(t.cfg.itemLevel.font[1])
        outline:SetSelectedValue(t.cfg.itemLevel.font[3])
        size:SetValue(t.cfg.itemLevel.font[2])
        shadow:SetChecked(t.cfg.itemLevel.font[4])
    end

    return pane
end

---------------------------------------------------------------------
-- durability
---------------------------------------------------------------------
builder["durability"] = function(parent)
    if created["durability"] then return created["durability"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_Durability", nil, 176)
    created["durability"] = pane

    local enabled = AF.CreateCheckButton(pane, AF.GetGradientText(L["Show Durability"], "BFI", "white"))
    AF.SetPoint(enabled, "TOPLEFT", 15, -8)

    local colorHigh = AF.CreateColorPicker(pane, L["Color"] .. " (" .. L["High"] .. ")")
    AF.SetPoint(colorHigh, "TOPLEFT", enabled, 185, 0)
    colorHigh:SetOnConfirm(function(r, g, b)
        pane.t.cfg.durability.color.high[1] = r
        pane.t.cfg.durability.color.high[2] = g
        pane.t.cfg.durability.color.high[3] = b
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local colorMedium = AF.CreateColorPicker(pane, L["Color"] .. " (" .. L["Medium"] .. ")")
    AF.SetPoint(colorMedium, "TOPLEFT", colorHigh, "BOTTOMLEFT", 0, -7)
    colorMedium:SetOnConfirm(function(r, g, b)
        pane.t.cfg.durability.color.medium[1] = r
        pane.t.cfg.durability.color.medium[2] = g
        pane.t.cfg.durability.color.medium[3] = b
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local colorLow = AF.CreateColorPicker(pane, L["Color"] .. " (" .. L["Low"] .. ")")
    AF.SetPoint(colorLow, "TOPLEFT", colorMedium, "BOTTOMLEFT", 0, -7)
    colorLow:SetOnConfirm(function(r, g, b)
        pane.t.cfg.durability.color.low[1] = r
        pane.t.cfg.durability.color.low[2] = g
        pane.t.cfg.durability.color.low[3] = b
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local position = AF.CreateDropdown(pane, 150)
    AF.SetPoint(position, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -25)
    position:SetLabel(L["Position"])
    position:SetItems(AF.GetDropdownItems_AnchorPoint())
    position:SetOnSelect(function(value)
        pane.t.cfg.durability.position = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 3, 10, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", position, "BOTTOMLEFT", 0, -25)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.durability.size = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local margin = AF.CreateSlider(pane, L["Margin"], 150, 0, 5, 1, nil, true)
    AF.SetPoint(margin, "TOPLEFT", size, 185, 0)
    margin:SetAfterValueChanged(function(value)
        pane.t.cfg.durability.margin = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local glowBelow = AF.CreateSlider(pane, L["Glow Below"], 150, 0, 1, 0.05, true, true)
    AF.SetPoint(glowBelow, "TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    glowBelow:SetAfterValueChanged(function(value)
        pane.t.cfg.durability.glowBelow = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local hideAtFull = AF.CreateCheckButton(pane, L["Hide At Full Durability"])
    AF.SetPoint(hideAtFull, "TOPLEFT", glowBelow, 185, 0)
    hideAtFull:SetOnCheck(function(checked)
        pane.t.cfg.durability.hideAtFull = checked
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.durability.enabled, colorHigh, colorMedium, colorLow, position, size, margin, glowBelow, hideAtFull)
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.durability.enabled = checked
        UpdateWidgets()
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        enabled:SetChecked(t.cfg.durability.enabled)
        colorHigh:SetColor(t.cfg.durability.color.high)
        colorMedium:SetColor(t.cfg.durability.color.medium)
        colorLow:SetColor(t.cfg.durability.color.low)
        position:SetSelectedValue(t.cfg.durability.position)
        size:SetValue(t.cfg.durability.size)
        margin:SetValue(t.cfg.durability.margin)
        glowBelow:SetValue(t.cfg.durability.glowBelow)
        hideAtFull:SetChecked(t.cfg.durability.hideAtFull)
    end

    return pane
end

---------------------------------------------------------------------
-- missingEnhance
---------------------------------------------------------------------
builder["missingEnhance"] = function(parent)
    if created["missingEnhance"] then return created["missingEnhance"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_MissingEnhance", nil, 131)
    created["missingEnhance"] = pane

    local enabled = AF.CreateCheckButton(pane, AF.GetGradientText(L["Show Missing Enchantment and Gems"], "BFI", "white"))
    AF.SetPoint(enabled, "TOPLEFT", 15, -8)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    AF.SetPoint(anchorPoint, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -25)
    anchorPoint:SetLabel(L["Anchor Point"])
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.missingEnhance.position[1] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 8, 32, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", anchorPoint, 185, 0)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.missingEnhance.size = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    yOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.missingEnhance.position[3] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(xOffset, "LEFT", anchorPoint)
    AF.SetPoint(xOffset, "TOP", yOffset)
    xOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.missingEnhance.position[2] = value
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.missingEnhance.enabled, anchorPoint, size, xOffset, yOffset)
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.missingEnhance.enabled = checked
        UpdateWidgets()
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        enabled:SetChecked(t.cfg.missingEnhance.enabled)
        size:SetValue(t.cfg.missingEnhance.size)
        anchorPoint:SetSelectedValue(t.cfg.missingEnhance.position[1])
        xOffset:SetValue(t.cfg.missingEnhance.position[2])
        yOffset:SetValue(t.cfg.missingEnhance.position[3])
    end

    return pane
end

---------------------------------------------------------------------
-- teleportButtons
---------------------------------------------------------------------
builder["teleportButtons"] = function(parent)
    if created["teleportButtons"] then return created["teleportButtons"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_EnhancementOption_TeleportButtons", nil, 30)
    created["teleportButtons"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Show Teleport Buttons on Mythic+ Tab"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.teleportButtons.enabled = checked
        AF.Fire("BFI_UpdateConfig", "enhancements", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        enabled:SetChecked(t.cfg.teleportButtons.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetEnhancementOptions(parent, info)
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
        if builder[option] then
            local pane = builder[option](parent)
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end