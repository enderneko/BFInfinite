---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    general = {
        "enabled",
        "lock,pickUpKey",
        "cast",
        "disableAutoAddSpells",
        "animationOverlays",
        "colors",
        "flyoutSize",
        "frameStrata",
        "tooltip"
    },
    cooldowns = {

    },
    assistant = {
        "assistedHighlight",
        "assistedAnimation",
    },
    bar = {
        "enabled",
        "width,height",
        "arrangement",
        "alpha",
        "showGrid",
        "flyoutDirection",
        "hotkey",
        "count",
        "macro",
        "visibility",
        "paging",
    },
    vehicle = {
        "enabled",
        "size",
    },
    extra = {
        "enabled",
        "zoneAbility",
        "extraAction",
    },
}

---------------------------------------------------------------------
-- copy,paste,reset
---------------------------------------------------------------------
builder["copy,paste,reset"] = function(parent)
    if created["copy,paste,reset"] then return created["copy,paste,reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_CopyPasteReset", nil, 30)
    created["copy,paste,reset"] = pane
    pane:Hide()

    local copiedSetting, copiedOwnerName, copiedTime, copiedCfg

    local copy = AF.CreateButton(pane, L["Copy"], "BFI_hover", 107, 20)
    AF.SetPoint(copy, "LEFT", 15, 0)
    copy.tick = AF.CreateTexture(copy, AF.GetIcon("Fluent_Color_Yes"))
    AF.SetSize(copy.tick, 16, 16)
    AF.SetPoint(copy.tick, "RIGHT", -5, 0)
    copy.tick:Hide()

    local paste = AF.CreateButton(pane, L["Paste"], "BFI_hover", 107, 20)
    AF.SetPoint(paste, "TOPLEFT", copy, "TOPRIGHT", 7, 0)

    copy:SetOnClick(function()
        copiedSetting = pane.t.setting
        copiedCfg = AF.Copy(pane.t.cfg)
        copiedCfg.position = nil
        copiedCfg.paging = nil
        copiedCfg.visibility = nil
        copiedOwnerName = pane.t.ownerName
        copiedTime = time()
        AF.FrameFadeInOut(copy.tick, 0.15)
        paste:SetEnabled(true)
    end)

    paste:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Overwrite with copied config?"], "BFI") .. "\n"
            .. copiedOwnerName .. AF.WrapTextInColor(" -> ", "darkgray") .. pane.t.ownerName .. "\n"
            .. AF.WrapTextInColor(AF.FormatRelativeTime(copiedTime), "darkgray")

        local dialog = AF.GetDialog(BFIOptionsFrame_ActionBarsPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            for k, v in next, copiedCfg do
                if k == "buttonConfig" then
                    for k2, v2 in next, v do
                        if k2 == "text" then
                            AF.MergeExistingKeys(pane.t.cfg.buttonConfig.text, v2)
                        else
                            pane.t.cfg.buttonConfig[k2] = v2
                        end
                    end
                else
                    pane.t.cfg[k] = v
                end
            end
            AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
            AF.Fire("BFI_RefreshOptions", "actionBars")
        end)
    end)


    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 107, 20)
    AF.SetPoint(reset, "TOPLEFT", paste, "TOPRIGHT", 7, 0)
    reset:SetOnClick(function()
        local isResetAll -- = IsShiftKeyDown()
        local text = AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. (isResetAll and L["All Settings"] or pane.t.ownerName)

        local dialog = AF.GetDialog(BFIOptionsFrame_ActionBarsPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            -- if isResetAll then
            --     AB.Reset()
            --     AF.Fire("BFI_UpdateModule", "actionBars")
            -- else
                if pane.t.id == "general" then
                    AB.ResetGeneralAndShared()
                    AF.Fire("BFI_UpdateModule", "actionBars")
                elseif pane.t.id == "vehicle" then
                    AB.ResetVehicle()
                    AF.Fire("BFI_UpdateModule", "actionBars", "vehicle")
                elseif pane.t.id == "extra" then
                    AB.ResetExtra()
                    AF.Fire("BFI_UpdateModule", "actionBars", "extra")
                elseif pane.t.id == "assistant" then
                    AB.ResetAssistant()
                    AF.Fire("BFI_UpdateModule", "actionBars", "main")
                elseif pane.t.id == "cooldowns" then
                    -- TODO: AB.ResetCooldowns()
                else
                    AB.ResetBar(pane.t.id)
                    AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
                end
            -- end
            AF.Fire("BFI_RefreshOptions", "actionBars")
        end)
    end)

    -- local resetTooltips = {_G.RESET, L["Hold %s while clicking to reset all settings"]:format(AF.WrapTextInColor("Shift", "BFI"))}
    -- reset._tooltipOwner = BFIOptionsFrame_ActionBarsPanel
    -- reset:HookOnEnter(function()
    --     if pane.t.id == "general" then
    --         AF.ShowTooltip(reset, "TOPLEFT", 0, 2, resetTooltips)
    --     end
    -- end)
    -- reset:HookOnLeave(AF.HideTooltip)

    function pane.Load(t)
        pane.t = t
        copy:SetEnabled(t.id ~= "general" and t.id ~= "assistant" and t.id ~= "cooldowns")
        paste:SetEnabled(t.id ~= "general" and copiedSetting == t.setting)
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Enabled", nil, 30)
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
        if pane.t.id == "general" then
            AF.Fire("BFI_UpdateModule", "actionBars")
        else
            AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
        end
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
-- lock,pickUpKey
---------------------------------------------------------------------
builder["lock,pickUpKey"] = function(parent)
    if created["lock,pickUpKey"] then return created["lock,pickUpKey"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_LockPickUpKey", nil, 51)
    created["lock,pickUpKey"] = pane

    local lock = AF.CreateCheckButton(pane, L["Lock"])
    AF.SetPoint(lock, "LEFT", 15, 0)

    local pickUpKey = AF.CreateDropdown(pane, 150)
    pickUpKey:SetLabel(L["Pick Up Key"])
    AF.SetPoint(pickUpKey, "TOPLEFT", lock, 185, -5)
    pickUpKey:SetItems(AF.GetDropdownItems_Modifier())
    pickUpKey:SetOnSelect(function(value)
        pane.t.sharedCfg.pickUpKey = value
        AF.Fire("BFI_UpdateModule", "actionBars")
    end)

    lock:SetOnCheck(function(checked)
        pane.t.sharedCfg.lock = checked
        AF.Fire("BFI_UpdateModule", "actionBars")
        Settings.SetValue("lockActionBars", checked)
        pickUpKey:SetEnabled(checked)
    end)

    function pane.Load(t)
        pane.t = t
        lock:SetChecked(t.sharedCfg.lock)
        pickUpKey:SetEnabled(t.sharedCfg.lock)
        pickUpKey:SetSelectedValue(t.sharedCfg.pickUpKey)
    end

    return pane
end

---------------------------------------------------------------------
-- animationOverlays
---------------------------------------------------------------------
builder["animationOverlays"] = function(parent)
    if created["animationOverlays"] then return created["animationOverlays"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_AnimationOverlays", nil, 72)
    created["animationOverlays"] = pane

    local targetReticle = AF.CreateCheckButton(pane, L["Target Reticle"])
    AF.SetPoint(targetReticle, "TOPLEFT", 15, -8)
    targetReticle:SetOnCheck(function(checked)
        pane.t.sharedCfg.targetReticle = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local spellCastAnim = AF.CreateCheckButton(pane, L["Spell Cast Animation"])
    AF.SetPoint(spellCastAnim, "TOPLEFT", targetReticle, "BOTTOMLEFT", 0, -7)
    spellCastAnim:SetOnCheck(function(checked)
        pane.t.sharedCfg.spellCastAnim = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local interruptDisplay = AF.CreateCheckButton(pane, L["Interrupt Animation"])
    AF.SetPoint(interruptDisplay, "TOPLEFT", spellCastAnim, "BOTTOMLEFT", 0, -7)
    interruptDisplay:SetOnCheck(function(checked)
        pane.t.sharedCfg.interruptDisplay = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        targetReticle:SetChecked(t.sharedCfg.targetReticle)
        spellCastAnim:SetChecked(t.sharedCfg.spellCastAnim)
        interruptDisplay:SetChecked(t.sharedCfg.interruptDisplay)
    end

    return pane
end

---------------------------------------------------------------------
-- frameStrata
---------------------------------------------------------------------
builder["frameStrata"] = function(parent)
    if created["frameStrata"] then return created["frameStrata"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_FrameStrata", nil, 58)
    created["frameStrata"] = pane

    local frameStrata = AF.CreateDropdown(pane, 150)
    AF.SetPoint(frameStrata, "TOPLEFT", 15, -25)
    frameStrata:SetLabel(L["Frame Strata"])
    frameStrata:SetItems(AF.GetDropdownItems_FrameStrata())
    frameStrata:SetOnSelect(function(value)
        pane.t.cfg.frameStrata = value
        AF.Fire("BFI_UpdateModule", "actionBars")
    end)

    local frameLevel = AF.CreateSlider(pane, L["Frame Level"], 150, 0, 100, 1, nil, true)
    AF.SetPoint(frameLevel, "TOPLEFT", frameStrata, 185, 0)
    frameLevel:SetAfterValueChanged(function(value)
        pane.t.cfg.frameLevel = value
        AF.Fire("BFI_UpdateModule", "actionBars")
    end)

    function pane.Load(t)
        pane.t = t
        frameStrata:SetSelectedValue(t.cfg.frameStrata)
        frameLevel:SetValue(t.cfg.frameLevel)
    end

    return pane
end

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
builder["colors"] = function(parent)
    if created["colors"] then return created["colors"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Colors", nil, 117)
    created["colors"] = pane

    local outOfRangeColorPicker = AF.CreateColorPicker(pane, L["Out Of Range Color"])
    AF.SetPoint(outOfRangeColorPicker, "TOPLEFT", 15, -8)
    outOfRangeColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.range[1] = r
        pane.t.sharedCfg.colors.range[2] = g
        pane.t.sharedCfg.colors.range[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local outOfRangeColorDropdown = AF.CreateDropdown(pane, 100)
    AF.SetPoint(outOfRangeColorDropdown, "LEFT", outOfRangeColorPicker, 185, 0)
    outOfRangeColorDropdown:SetItems({
        {text = L["Button"], value = "button"},
        {text = L["Hot Key"], value = "hotkey"},
    })
    outOfRangeColorDropdown:SetOnSelect(function(value)
        pane.t.sharedCfg.outOfRangeColoring = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local notUsableColorPicker = AF.CreateColorPicker(pane, L["Not Usable Color"])
    AF.SetPoint(notUsableColorPicker, "TOPLEFT", outOfRangeColorPicker, "BOTTOMLEFT", 0, -10)
    notUsableColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.notUsable[1] = r
        pane.t.sharedCfg.colors.notUsable[2] = g
        pane.t.sharedCfg.colors.notUsable[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local insufficientPowerColorPicker = AF.CreateColorPicker(pane, L["Insufficient Power Color"])
    AF.SetPoint(insufficientPowerColorPicker, "TOPLEFT", notUsableColorPicker, "BOTTOMLEFT", 0, -7)
    insufficientPowerColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.mana[1] = r
        pane.t.sharedCfg.colors.mana[2] = g
        pane.t.sharedCfg.colors.mana[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local equippedCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(equippedCheckButton, "TOPLEFT", insufficientPowerColorPicker, "BOTTOMLEFT", 0, -7)

    local equippedColorPicker = AF.CreateColorPicker(pane, L["Equipped Border Color"])
    AF.SetPoint(equippedColorPicker, "TOPLEFT", equippedCheckButton, "TOPRIGHT", 2, 0)
    equippedColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.equippedBorder[1] = r
        pane.t.sharedCfg.colors.equippedBorder[2] = g
        pane.t.sharedCfg.colors.equippedBorder[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    equippedCheckButton:SetOnCheck(function(checked)
        pane.t.sharedCfg.hideElements.equippedBorder = not checked
        equippedColorPicker:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local macroCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(macroCheckButton, "TOPLEFT", equippedCheckButton, "BOTTOMLEFT", 0, -7)

    local macroColorPicker = AF.CreateColorPicker(pane, L["Macro Border Color"])
    AF.SetPoint(macroColorPicker, "TOPLEFT", macroCheckButton, "TOPRIGHT", 2, 0)
    macroColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.macroBorder[1] = r
        pane.t.sharedCfg.colors.macroBorder[2] = g
        pane.t.sharedCfg.colors.macroBorder[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    macroCheckButton:SetOnCheck(function(checked)
        pane.t.sharedCfg.hideElements.macroBorder = not checked
        macroColorPicker:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        outOfRangeColorDropdown:SetSelectedValue(t.sharedCfg.outOfRangeColoring)
        outOfRangeColorPicker:SetColor(t.sharedCfg.colors.range)
        notUsableColorPicker:SetColor(t.sharedCfg.colors.notUsable)
        insufficientPowerColorPicker:SetColor(t.sharedCfg.colors.mana)
        equippedCheckButton:SetChecked(not t.sharedCfg.hideElements.equippedBorder)
        equippedColorPicker:SetEnabled(not t.sharedCfg.hideElements.equippedBorder)
        equippedColorPicker:SetColor(t.sharedCfg.colors.equippedBorder)
        macroCheckButton:SetChecked(not t.sharedCfg.hideElements.macroBorder)
        macroColorPicker:SetEnabled(not t.sharedCfg.hideElements.macroBorder)
        macroColorPicker:SetColor(t.sharedCfg.colors.macroBorder)
    end

    return pane
end

---------------------------------------------------------------------
-- text
---------------------------------------------------------------------
local function CreateTextPane(parent, which, label)
    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_" .. AF.UpperFirst(which), nil, 198)

    local font = AF.CreateDropdown(pane, 150)
    AF.SetPoint(font, "TOPLEFT", 15, -25)
    font:SetItems(AF.LSM_GetFontDropdownItems())
    font:SetOnSelect(function(value)
        pane.t.cfg.buttonConfig.text[which].font[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    label = AF.GetGradientText(label, "BFI", "white")

    local enable = AF.CreateCheckButton(pane, label)
    AF.SetPoint(enable, "BOTTOMLEFT", font, "TOPLEFT", 0, 2)

    local title = AF.CreateFontString(pane, label)
    AF.SetPoint(title, "BOTTOMLEFT", font, "TOPLEFT", 0, 2)

    local color = AF.CreateColorPicker(pane)
    AF.SetPoint(color, "BOTTOMRIGHT", font, "TOPRIGHT", 0, 2)
    color:SetOnConfirm(function(r, g, b)
        pane.t.cfg.buttonConfig.text[which].color[1] = r
        pane.t.cfg.buttonConfig.text[which].color[2] = g
        pane.t.cfg.buttonConfig.text[which].color[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local outline = AF.CreateDropdown(pane, 150)
    outline:SetLabel(L["Outline"])
    AF.SetPoint(outline, "TOPLEFT", font, 185, 0)
    outline:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    outline:SetOnSelect(function(value)
        pane.t.cfg.buttonConfig.text[which].font[3] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", font, "BOTTOMLEFT", 0, -25)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.buttonConfig.text[which].font[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local shadow = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadow, "LEFT", size, 185, 0)
    shadow:SetOnCheck(function(checked)
        pane.t.cfg.buttonConfig.text[which].font[4] = checked
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.buttonConfig.text[which].position[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.buttonConfig.text[which].position[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.buttonConfig.text[which].position[3] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.buttonConfig.text[which].position[4] = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()
        AF.SetEnabled(not pane.t.cfg.buttonConfig.hideElements[which], font, size, outline, shadow,
            anchorPoint, relativePoint, xOffset, yOffset)
    end

    enable:SetOnCheck(function(checked)
        pane.t.cfg.buttonConfig.hideElements[which] = not checked
        UpdateWidgets()
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t

        if which == "count" then
            enable:Hide()
            title:Show()
        else
            enable:SetChecked(not t.cfg.buttonConfig.hideElements[which])
            enable:Show()
            title:Hide()
        end

        UpdateWidgets()
        color:SetColor(t.cfg.buttonConfig.text[which].color)
        font:SetSelectedValue(t.cfg.buttonConfig.text[which].font[1])
        size:SetValue(t.cfg.buttonConfig.text[which].font[2])
        outline:SetSelectedValue(t.cfg.buttonConfig.text[which].font[3])
        shadow:SetChecked(t.cfg.buttonConfig.text[which].font[4])
        anchorPoint:SetSelectedValue(t.cfg.buttonConfig.text[which].position[1])
        relativePoint:SetSelectedValue(t.cfg.buttonConfig.text[which].position[2])
        xOffset:SetValue(t.cfg.buttonConfig.text[which].position[3])
        yOffset:SetValue(t.cfg.buttonConfig.text[which].position[4])
    end

    return pane
end

builder["hotkey"] = function(parent)
    if created["hotkey"] then return created["hotkey"] end
    created["hotkey"] = CreateTextPane(parent, "hotkey", L["Hot Key"])
    return created["hotkey"]
end

builder["count"] = function(parent)
    if created["count"] then return created["count"] end
    created["count"] = CreateTextPane(parent, "count", L["Count Text"])

    created["count"].IsApplicable = function(t)
        return t.id:find("^bar") or t.id:find("^classbar")
    end

    return created["count"]
end

builder["macro"] = function(parent)
    if created["macro"] then return created["macro"] end
    created["macro"] = CreateTextPane(parent, "macro", L["Macro Name"])

    created["macro"].IsApplicable = function(t)
        return t.id:find("^bar") or t.id:find("^classbar")
    end

    return created["macro"]
end

---------------------------------------------------------------------
-- cast
---------------------------------------------------------------------
builder["cast"] = function(parent)
    if created["cast"] then return created["cast"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Cast", nil, 75)
    created["cast"] = pane

    local selfCast = AF.CreateCheckButton(pane, _G.AUTO_SELF_CAST_TEXT)
    AF.SetPoint(selfCast, "TOPLEFT", 15, -8)
    selfCast:SetOnCheck(function(checked)
        pane.t.sharedCfg.cast.self = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local mouseoverCastDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(mouseoverCastDropdown, "TOPLEFT", selfCast, "BOTTOMLEFT", 0, -25)
    mouseoverCastDropdown:SetItems(AF.GetDropdownItems_Modifier())
    mouseoverCastDropdown:SetOnSelect(function(value)
        pane.t.sharedCfg.cast.mouseover[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local mouseoverCast = AF.CreateCheckButton(pane, L["Mouseover Cast"])
    AF.SetPoint(mouseoverCast, "BOTTOMLEFT", mouseoverCastDropdown, "TOPLEFT", 0, 2)
    mouseoverCast:SetOnCheck(function(checked)
        pane.t.sharedCfg.cast.mouseover[1] = checked
        mouseoverCastDropdown:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local focusCastDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(focusCastDropdown, "TOPLEFT", mouseoverCastDropdown, 185, 0)
    focusCastDropdown:SetItems(AF.GetDropdownItems_Modifier())
    focusCastDropdown:SetOnSelect(function(value)
        pane.t.sharedCfg.cast.focus[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local focusCast = AF.CreateCheckButton(pane, L["Focus Cast"])
    AF.SetPoint(focusCast, "BOTTOMLEFT", focusCastDropdown, "TOPLEFT", 0, 2)
    focusCast:SetOnCheck(function(checked)
        pane.t.sharedCfg.cast.focus[1] = checked
        focusCastDropdown:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        selfCast:SetChecked(t.sharedCfg.cast.self)
        mouseoverCast:SetChecked(t.sharedCfg.cast.mouseover[1])
        mouseoverCastDropdown:SetEnabled(t.sharedCfg.cast.mouseover[1])
        mouseoverCastDropdown:SetSelectedValue(t.sharedCfg.cast.mouseover[2])
        focusCast:SetChecked(t.sharedCfg.cast.focus[1])
        focusCastDropdown:SetEnabled(t.sharedCfg.cast.focus[1])
        focusCastDropdown:SetSelectedValue(t.sharedCfg.cast.focus[2])
    end

    return pane
end

---------------------------------------------------------------------
-- disableAutoAddSpells
---------------------------------------------------------------------
builder["disableAutoAddSpells"] = function(parent)
    if created["disableAutoAddSpells"] then return created["disableAutoAddSpells"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_DisableAutoAddSpells", nil, 30)
    created["disableAutoAddSpells"] = pane

    local disableAutoAddSpells = AF.CreateCheckButton(pane, L["Disable Auto-Adding Spells To Action Bar"])
    AF.SetPoint(disableAutoAddSpells, "LEFT", 15, 0)
    disableAutoAddSpells:SetOnCheck(function(checked)
        pane.t.cfg.disableAutoAddSpells = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        disableAutoAddSpells:SetChecked(t.cfg.disableAutoAddSpells)
    end

    return pane
end

---------------------------------------------------------------------
-- flyoutSize
---------------------------------------------------------------------
builder["flyoutSize"] = function(parent)
    if created["flyoutSize"] then return created["flyoutSize"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_FlyoutSize", nil, 55)
    created["flyoutSize"] = pane

    local flyoutWidth = AF.CreateSlider(pane, L["Flyout Button Width"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(flyoutWidth, "LEFT", 15, 0)
    flyoutWidth:SetAfterValueChanged(function(value)
        pane.t.cfg.flyoutSize[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "flyout")
    end)

    local flyoutHeight = AF.CreateSlider(pane, L["Flyout Button Height"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(flyoutHeight, "TOPLEFT", flyoutWidth, 185, 0)
    flyoutHeight:SetAfterValueChanged(function(value)
        pane.t.cfg.flyoutSize[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "flyout")
    end)

    function pane.Load(t)
        pane.t = t
        flyoutWidth:SetValue(t.cfg.flyoutSize[1])
        flyoutHeight:SetValue(t.cfg.flyoutSize[2])
    end

    return pane
end

---------------------------------------------------------------------
-- tooltip
---------------------------------------------------------------------
builder["tooltip"] = function(parent)
    if created["tooltip"] then return created["tooltip"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Tooltip", nil, 148)
    created["tooltip"] = pane

    local tooltipDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(tooltipDropdown, "TOPLEFT", 15, -25)
    tooltipDropdown:SetLabel(L["Tooltip"])
    tooltipDropdown:SetItems({
        {text = L["Enabled"], value = "enabled"},
        {text = L["Out Of Combat"], value = "out_of_combat"},
        {text = L["Disabled"], value = "disabled"},
    })

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", tooltipDropdown, 185, 0)
    relativeTo:SetItems({
        {text = L["Button"], value = "self"},
        {text = L["Button (Adaptive)"], value = "self_adaptive"},
        {text = _G.DEFAULT, value = "default"},
    })

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", tooltipDropdown, "BOTTOMLEFT", 0, -25)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[1] = value
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[2] = value
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    x:SetAfterValueChanged(function(value)
        pane.t.cfg.tooltip.position[3] = value
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetAfterValueChanged(function(value)
        pane.t.cfg.tooltip.position[4] = value
    end)

    local function UpdateWidgets()
        relativeTo:SetEnabled(pane.t.cfg.tooltip.enabled)
        AF.SetEnabled(pane.t.cfg.tooltip.enabled and pane.t.cfg.tooltip.anchorTo ~= "self_adaptive" and pane.t.cfg.tooltip.anchorTo ~= "default", anchorPoint, relativePoint, x, y)
    end

    tooltipDropdown:SetOnSelect(function(value)
        if value == "enabled" then
            pane.t.cfg.tooltip.enabled = true
            pane.t.cfg.tooltip.hideInCombat = false
        elseif value == "out_of_combat" then
            pane.t.cfg.tooltip.enabled = true
            pane.t.cfg.tooltip.hideInCombat = true
        else
            pane.t.cfg.tooltip.enabled = false
            pane.t.cfg.tooltip.hideInCombat = false
        end
        UpdateWidgets()
        AF.Fire("BFI_UpdateModule", "actionBars")
    end)

     relativeTo:SetOnSelect(function(value)
        pane.t.cfg.tooltip.anchorTo = value
        UpdateWidgets()
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        if t.cfg.tooltip.enabled then
            if t.cfg.tooltip.hideInCombat then
                tooltipDropdown:SetSelectedValue("out_of_combat")
            else
                tooltipDropdown:SetSelectedValue("enabled")
            end
        else
            tooltipDropdown:SetSelectedValue("disabled")
        end
        relativeTo:SetSelectedValue(t.cfg.tooltip.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.tooltip.position[1])
        relativePoint:SetSelectedValue(t.cfg.tooltip.position[2])
        x:SetValue(t.cfg.tooltip.position[3])
        y:SetValue(t.cfg.tooltip.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetAfterValueChanged(function(value)
        pane.t.cfg.width = value
        AF.FrameFadeInOut(pane.t.target.previewRect, nil, nil, true)
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetAfterValueChanged(function(value)
        pane.t.cfg.height = value
        AF.FrameFadeInOut(pane.t.target.previewRect, nil, nil, true)
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
builder["size"] = function(parent)
    if created["size"] then return created["size"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Size", nil, 55)
    created["size"] = pane

    local size = AF.CreateSlider(pane, L["Size"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(size, "LEFT", 15, 0)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.size = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        size:SetValue(t.cfg.size)
    end

    return pane
end

---------------------------------------------------------------------
-- arrangement
---------------------------------------------------------------------
builder["arrangement"] = function(parent)
    if created["arrangement"] then return created["arrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Arrangement", nil, 153)
    created["arrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 200)
    arrangement:SetLabel(AF.GetGradientText(L["Arrangement"], "BFI", "white"))
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_ComplexOrientation())
    arrangement:SetOnSelect(function(value)
        pane.t.cfg.orientation = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local spacingX = AF.CreateSlider(pane, L["X Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacingX, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -25)
    spacingX:SetAfterValueChanged(function(value)
        pane.t.cfg.spacingX = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local spacingY = AF.CreateSlider(pane, L["Y Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacingY, "TOPLEFT", spacingX, 185, 0)
    spacingY:SetAfterValueChanged(function(value)
        pane.t.cfg.spacingY = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local maxButtons = AF.CreateSlider(pane, L["Max Buttons"], 150, 1, 12, 1, nil, true)
    AF.SetPoint(maxButtons, "TOPLEFT", spacingX, "BOTTOMLEFT", 0, -40)

    local buttonsPerLine = AF.CreateSlider(pane, L["Buttons Per Line"], 150, 1, 12, 1, nil, true)
    AF.SetPoint(buttonsPerLine, "TOPLEFT", maxButtons, 185, 0)
    buttonsPerLine:SetAfterValueChanged(function(value)
        pane.t.cfg.buttonsPerLine = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local function UpdateMaxButtonsPerLine()
        buttonsPerLine:SetMinMaxValues(1, pane.t.cfg.num)
        if pane.t.cfg.buttonsPerLine > pane.t.cfg.num then
            pane.t.cfg.buttonsPerLine = pane.t.cfg.num
            buttonsPerLine:SetValue(pane.t.cfg.num)
        end
    end

    maxButtons:SetAfterValueChanged(function(value)
        pane.t.cfg.num = value
        UpdateMaxButtonsPerLine()
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t

        arrangement:SetSelectedValue(t.cfg.orientation)
        spacingX:SetValue(t.cfg.spacingX)
        spacingY:SetValue(t.cfg.spacingY)

        if t.id == "petbar" or t.id == "stancebar" then
            maxButtons:SetMinMaxValues(1, 10)
        else
            maxButtons:SetMinMaxValues(1, 12)
        end
        maxButtons:SetValue(t.cfg.num)

        buttonsPerLine:SetValue(t.cfg.buttonsPerLine)
        UpdateMaxButtonsPerLine()
    end

    return pane
end

---------------------------------------------------------------------
-- alpha
---------------------------------------------------------------------
builder["alpha"] = function(parent)
    if created["alpha"] then return created["alpha"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Alpha", nil, 55)
    created["alpha"] = pane

    local alpha = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alpha, "LEFT", 15, 0)
    alpha:SetAfterValueChanged(function(value)
        pane.t.cfg.alpha = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        alpha:SetValue(t.cfg.alpha)
    end

    return pane
end

---------------------------------------------------------------------
-- showGrid
---------------------------------------------------------------------
builder["showGrid"] = function(parent)
    if created["showGrid"] then return created["showGrid"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_ShowGrid", nil, 30)
    created["showGrid"] = pane

    local showGrid = AF.CreateCheckButton(pane, L["Show Empty Slots"])
    AF.SetPoint(showGrid, "LEFT", 15, 0)
    showGrid:SetOnCheck(function(checked)
        pane.t.cfg.buttonConfig.showGrid = checked
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.IsApplicable(t)
        return t.id:find("^bar") or t.id:find("^classbar") or t.id == "petbar"
    end

    function pane.Load(t)
        pane.t = t
        showGrid:SetChecked(t.cfg.buttonConfig.showGrid)
    end

    return pane
end

---------------------------------------------------------------------
-- flyoutDirection
---------------------------------------------------------------------
builder["flyoutDirection"] = function(parent)
    if created["flyoutDirection"] then return created["flyoutDirection"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_FlyoutDirection", nil, 54)
    created["flyoutDirection"] = pane

    local flyoutDirection = AF.CreateDropdown(pane, 150)
    flyoutDirection:SetLabel(L["Flyout Direction"])
    AF.SetPoint(flyoutDirection, "TOPLEFT", 15, -25)
    flyoutDirection:SetItems({
        {text = L["Up"], value = "UP"},
        {text = L["Down"], value = "DOWN"},
        {text = L["Left"], value = "LEFT"},
        {text = L["Right"], value = "RIGHT"},
    })
    flyoutDirection:SetOnSelect(function(value)
        pane.t.cfg.buttonConfig.flyoutDirection = value
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.IsApplicable(t)
        return t.id:find("^bar") or t.id:find("^classbar")
    end

    function pane.Load(t)
        pane.t = t
        flyoutDirection:SetSelectedValue(t.cfg.buttonConfig.flyoutDirection)
    end

    return pane
end

---------------------------------------------------------------------
-- visibility
---------------------------------------------------------------------
builder["visibility"] = function(parent)
    if created["visibility"] then return created["visibility"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Visibility", nil, 105)
    created["visibility"] = pane

    local visibility = AF.CreateScrollEditBox(pane, nil, nil, 335, 65)
    AF.SetPoint(visibility, "TOPLEFT", 15, -25)
    visibility:SetMaxLetters(256)

    local confirm = visibility:SetConfirmButton(function(value)
        if AF.IsBlank(value) then
            pane.t.cfg.visibility = nil
        else
            pane.t.cfg.visibility = value
        end
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end, nil, "NONE")
    AF.SetPoint(confirm, "BOTTOMLEFT", visibility, "BOTTOMRIGHT", -1, 0)

    local title = AF.CreateFontString(pane, L["Visibility"])
    AF.SetPoint(title, "BOTTOMLEFT", visibility, "TOPLEFT", 2, 2)

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 50, 18)
    AF.SetPoint(reset, "BOTTOMRIGHT", visibility, "TOPRIGHT", 0, 2)
    reset:SetOnClick(function()
        AB.ResetVisibility(pane.t.id)
        visibility:SetText(pane.t.cfg.visibility or "")
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        visibility:SetText(t.cfg.visibility or "")
    end

    return pane
end

---------------------------------------------------------------------
-- paging
---------------------------------------------------------------------
builder["paging"] = function(parent)
    if created["paging"] then return created["paging"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Paging", nil, 105)
    created["paging"] = pane

    local paging = AF.CreateScrollEditBox(pane, nil, nil, 335, 65)
    AF.SetPoint(paging, "TOPLEFT", 15, -25)
    paging:SetMaxLetters(256)

    local selected = AF.player.class

    local confirm = paging:SetConfirmButton(function(value)
        if AF.IsBlank(value) then
            pane.t.cfg.paging[selected] = nil
        else
            pane.t.cfg.paging[selected] = value
        end
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end, nil, "NONE")
    AF.SetPoint(confirm, "BOTTOMLEFT", paging, "BOTTOMRIGHT", -1, 0)

    local title = AF.CreateFontString(pane, L["Paging"])
    AF.SetPoint(title, "BOTTOMLEFT", paging, "TOPLEFT", 2, 2)

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 50, 18)
    AF.SetPoint(reset, "BOTTOMRIGHT", paging, "TOPRIGHT", 0, 2)
    reset:SetOnClick(function()
        AB.ResetPaging(pane.t.id, selected)
        paging:SetText(pane.t.cfg.paging[selected] or "")
        AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
    end)

    local class = AF.CreateDropdown(pane, 120, nil, "vertical")
    AF.SetHeight(class, 18)
    AF.SetPoint(class, "BOTTOMRIGHT", reset, "BOTTOMLEFT", -2, 0)
    class:SetItems(AF.GetDropdownItems_Class())
    class:SetOnSelect(function(value)
        selected = value
        paging:SetText(pane.t.cfg.paging[selected] or "")
    end)

    local tips = AF.CreateTipsButton(pane)
    AF.SetPoint(tips, "TOPLEFT", paging, "TOPRIGHT", 0, 0)
    tips:SetTips(L["Action Bar Index"], L["The index of each action bar is shown in square brackets on the right side of the list"])

    function pane.IsApplicable(t)
        return t.id:find("^bar") or t.id:find("^classbar")
    end

    function pane.Load(t)
        pane.t = t
        paging:SetText(t.cfg.paging[selected] or "")
        class:SetSelectedValue(selected)
    end

    return pane
end

---------------------------------------------------------------------
-- zoneAbility
---------------------------------------------------------------------
builder["zoneAbility"] = function(parent)
    if created["zoneAbility"] then return created["zoneAbility"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_ZoneAbility", nil, 63)
    created["zoneAbility"] = pane

    local title = AF.CreateFontString(pane, AF.GetGradientText(L["Zone Ability"], "BFI", "white"))
    AF.SetPoint(title, "TOPLEFT", 15, -8)

    local hideTexture = AF.CreateCheckButton(pane, L["Hide Texture"])
    AF.SetPoint(hideTexture, "TOPLEFT", 15, -30)
    hideTexture:SetOnCheck(function(checked)
        pane.t.cfg.zoneAbility.hideTexture = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local scale = AF.CreateSlider(pane, L["Scale"], 150, 0.1, 2, 0.01, true, true)
    AF.SetPoint(scale, "TOPLEFT", hideTexture, 185, 0)
    scale:SetAfterValueChanged(function(value)
        pane.t.cfg.zoneAbility.scale = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    function pane.Load(t)
        pane.t = t
        scale:SetValue(t.cfg.zoneAbility.scale)
        hideTexture:SetChecked(t.cfg.zoneAbility.hideTexture)
    end

    return pane
end

---------------------------------------------------------------------
-- extraAction
---------------------------------------------------------------------
builder["extraAction"] = function(parent)
    if created["extraAction"] then return created["extraAction"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_ExtraAction", nil, 257)
    created["extraAction"] = pane

    local title = AF.CreateFontString(pane, AF.GetGradientText(L["Extra Action"], "BFI", "white"))
    AF.SetPoint(title, "TOPLEFT", 15, -8)

    local hideTexture = AF.CreateCheckButton(pane, L["Hide Texture"])
    AF.SetPoint(hideTexture, "TOPLEFT", 15, -30)
    hideTexture:SetOnCheck(function(checked)
        pane.t.cfg.extraAction.hideTexture = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local scale = AF.CreateSlider(pane, L["Scale"], 150, 0.1, 2, 0.01, true, true)
    AF.SetPoint(scale, "TOPLEFT", hideTexture, 185, 0)
    scale:SetAfterValueChanged(function(value)
        pane.t.cfg.extraAction.scale = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local font = AF.CreateDropdown(pane, 150)
    AF.SetPoint(font, "TOPLEFT", hideTexture, "BOTTOMLEFT", 0, -40)
    font:SetLabel(L["Hot Key"])
    font:SetItems(AF.LSM_GetFontDropdownItems())
    font:SetOnSelect(function(value)
        pane.t.cfg.extraAction.hotkey.font[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local color = AF.CreateColorPicker(pane)
    AF.SetPoint(color, "BOTTOMRIGHT", font, "TOPRIGHT", 0, 2)
    color:SetOnConfirm(function(r, g, b)
        pane.t.cfg.extraAction.hotkey.color[1] = r
        pane.t.cfg.extraAction.hotkey.color[2] = g
        pane.t.cfg.extraAction.hotkey.color[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local outline = AF.CreateDropdown(pane, 150)
    outline:SetLabel(L["Outline"])
    AF.SetPoint(outline, "TOPLEFT", font, 185, 0)
    outline:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    outline:SetOnSelect(function(value)
        pane.t.cfg.extraAction.hotkey.font[3] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(size, "TOPLEFT", font, "BOTTOMLEFT", 0, -25)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.extraAction.hotkey.font[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local shadow = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadow, "LEFT", size, 185, 0)
    shadow:SetOnCheck(function(checked)
        pane.t.cfg.extraAction.hotkey.font[4] = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", size, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.extraAction.hotkey.position[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.extraAction.hotkey.position[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.extraAction.hotkey.position[3] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.extraAction.hotkey.position[4] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "extra")
    end)

    function pane.Load(t)
        pane.t = t
        scale:SetValue(t.cfg.extraAction.scale)
        hideTexture:SetChecked(t.cfg.extraAction.hideTexture)
        font:SetSelectedValue(t.cfg.extraAction.hotkey.font[1])
        color:SetColor(t.cfg.extraAction.hotkey.color)
        size:SetValue(t.cfg.extraAction.hotkey.font[2])
        outline:SetSelectedValue(t.cfg.extraAction.hotkey.font[3])
        shadow:SetChecked(t.cfg.extraAction.hotkey.font[4])
        anchorPoint:SetSelectedValue(t.cfg.extraAction.hotkey.position[1])
        relativePoint:SetSelectedValue(t.cfg.extraAction.hotkey.position[2])
        xOffset:SetValue(t.cfg.extraAction.hotkey.position[3])
        yOffset:SetValue(t.cfg.extraAction.hotkey.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- assistedHighlight
---------------------------------------------------------------------
builder["assistedHighlight"] = function(parent)
    if created["assistedHighlight"] then return created["assistedHighlight"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_AssistedHighlight", nil, 30)
    created["assistedHighlight"] = pane

    local assistedHighlight = AF.CreateCheckButton(pane, _G.ASSISTED_COMBAT_HIGHLIGHT_LABEL)
    AF.SetPoint(assistedHighlight, "LEFT", 15, 0)
    assistedHighlight:SetOnCheck(function(checked)
        pane.t.cfg.highlight = checked
        SetCVar("assistedCombatHighlight", checked)
    end)

    function pane.Load(t)
        pane.t = t
        assistedHighlight:SetChecked(t.cfg.highlight)
    end

    return pane
end

---------------------------------------------------------------------
-- assistedAnimation
---------------------------------------------------------------------
builder["assistedAnimation"] = function(parent)
    if created["assistedAnimation"] then return created["assistedAnimation"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_AssistedAnimation", nil, 173)
    created["assistedAnimation"] = pane

    local tip = AF.CreateFontString(pane, L["Animation options for Single-Button Assistant"])
    AF.SetPoint(tip, "TOPLEFT", 15, -8)
    tip:SetColor("tip")

    local styles = {}
    local function CreateStyleButton(style, info)
        local b = AF.CreateButton(pane, nil, {"widget", "widget_highlight"}, 35, 35)
        tinsert(styles, b)
        b.id = style
        b._borderColor = AF.GetColorTable("border")
        b._hoverBorderColor = AF.GetColorTable("BFI")

        local flip = AF.CreateFlipBookFrame(b)
        AF.SetInside(flip, b, 3, 3)
        flip:SetTexture(AF.GetTexture(style, "BFInfinite"))
        flip:SetFlipBookInfo(unpack(info))
        flip:Play()
    end

    CreateStyleButton("Nyan_Cat", {0.42, 4, 2, 6})
    CreateStyleButton("Bug_Cat", {0.98, 4, 4, 14})
    for i, b in pairs(styles) do
        if i == 1 then
            AF.SetPoint(b, "TOPLEFT", 15, -30)
        else
            AF.SetPoint(b, "TOPLEFT", styles[i - 1], "TOPRIGHT", 7, 0)
        end
    end
    local Highlight = AF.CreateButtonGroup(styles, function(_, style)
        pane.t.cfg.style = style
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local size = AF.CreateSlider(pane, L["Size"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(size, "LEFT", styles[1], 185, 0)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.size = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", styles[1], "BOTTOMLEFT", 0, -25)

    local items = AF.GetDropdownItems_AnchorPoint()
    tinsert(items, 1, {text = _G.DEFAULT, value = "default"})
    anchorPoint:SetItems(items)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.position[2] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.position[3] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 1, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetAfterValueChanged(function(value)
        pane.t.cfg.position[4] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    anchorPoint:SetOnSelect(function(value)
        if value == "default" then
            AF.SetEnabled(false, relativePoint, xOffset, yOffset)
            if pane.t.cfg.position ~= "default" then
                pane.t.cfg.size = 0.8
                size:SetStep(0.05)
                size:SetMinMaxValues(0.1, 3)
                size:SetPercentage(true)
                size:SetValue(pane.t.cfg.size)
            end
            pane.t.cfg.position = "default"
        else
            AF.SetEnabled(true, relativePoint, xOffset, yOffset)
            if type(pane.t.cfg.position) ~= "table" then
                pane.t.cfg.position = {
                    value,
                    relativePoint:GetSelected(),
                    xOffset:GetValue(),
                    yOffset:GetValue(),
                }
                pane.t.cfg.size = 32
                size:SetStep(1)
                size:SetMinMaxValues(10, 100)
                size:SetPercentage(false)
                size:SetValue(pane.t.cfg.size)
            else
                pane.t.cfg.position[1] = value
            end
        end
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        Highlight(t.cfg.style)
        if t.cfg.position == "default" then
            size:SetStep(0.05)
            size:SetMinMaxValues(0.1, 3)
            size:SetPercentage(true)
            anchorPoint:SetSelectedValue("default")
            relativePoint:SetSelectedValue("CENTER")
            xOffset:SetValue(0)
            yOffset:SetValue(0)
            AF.SetEnabled(false, relativePoint, xOffset, yOffset)
        else
            size:SetStep(1)
            size:SetMinMaxValues(10, 100)
            size:SetPercentage(false)
            anchorPoint:SetSelectedValue(t.cfg.position[1])
            relativePoint:SetSelectedValue(t.cfg.position[2])
            xOffset:SetValue(t.cfg.position[3])
            yOffset:SetValue(t.cfg.position[4])
            AF.SetEnabled(true, relativePoint, xOffset, yOffset)
        end
        size:SetValue(t.cfg.size)
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetActionBarOptions(parent, info)
    for _, pane in pairs(created) do
        pane:Hide()
        AF.ClearPoints(pane)
    end

    wipe(options)
    tinsert(options, builder["copy,paste,reset"](parent))
    created["copy,paste,reset"]:Show()

    local setting = info.setting
    if not settings[setting] then return options end

    for _, option in pairs(settings[setting]) do
        if builder[option] then
            local pane = builder[option](parent)
            if not pane.IsApplicable or pane.IsApplicable(info) then
                tinsert(options, pane)
                pane:Show()
            end
        end
    end

    return options
end