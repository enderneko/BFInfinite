---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local AB = BFI.ActionBars
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
        "tooltip"
    },
    bar = {
        "enabled",
    },
}

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function GetModifierItems()
    return {
        {text = "Alt", value = "ALT"},
        {text = "Ctrl", value = "CTRL"},
        {text = "Shift", value = "SHIFT"},
        {text = _G.NONE, value = "NONE"},
    }
end

local function GetAnchorPointItems(noCenter)
    local items = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "BOTTOM"}
    if not noCenter then
        tinsert(items, "CENTER")
    end
    for i, item in next, items do
        items[i] = {text = L[item], value = item}
    end
    return items
end

---------------------------------------------------------------------
-- copy,paste,reset
---------------------------------------------------------------------
builder["copy,paste,reset"] = function(parent)
    if created["copy,paste,reset"] then return created["copy,paste,reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_CopyPasteReset", nil, 30)
    created["copy,paste,reset"] = pane
    pane:Hide()

    local copiedId, copiedOwnerName, copiedTime, copiedCfg

    local copy = AF.CreateButton(pane, L["Copy"], "BFI_hover", 107, 20)
    AF.SetPoint(copy, "LEFT", 15, 0)
    copy.tick = AF.CreateTexture(copy, AF.GetIcon("Fluent_Color_Yes"))
    AF.SetSize(copy.tick, 16, 16)
    AF.SetPoint(copy.tick, "RIGHT", -5, 0)
    copy.tick:Hide()

    local paste = AF.CreateButton(pane, L["Paste"], "BFI_hover", 107, 20)
    AF.SetPoint(paste, "TOPLEFT", copy, "TOPRIGHT", 7, 0)

    copy:SetOnClick(function()
        copiedId = pane.t.id
        copiedCfg = AF.Copy(pane.t.cfg)
        copiedOwnerName = pane.t.ownerName
        copiedTime = time()
        AF.FrameFadeInOut(copy.tick, 0.15)
        paste:SetEnabled(true)
    end)

    paste:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Overwrite with copied config?"], "BFI") .. "\n"
            .. copiedOwnerName .. AF.WrapTextInColor(" -> ", "darkgray") .. pane.t.ownerName .. "\n"
            .. AF.WrapTextInColor(AF.FormatRelativeTime(copiedTime), "darkgray")

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            AF.MergeExistingKeys(pane.t.cfg, copiedCfg)
            AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
        end)
    end)


    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 107, 20)
    AF.SetPoint(reset, "TOPLEFT", paste, "TOPRIGHT", 7, 0)
    reset:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Reset to default config?"], "BFI") .. "\n" .. pane.t.ownerName

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            -- TODO:
            -- wipe(pane.t.cfg)
        end)
    end)

    function pane.Load(t)
        pane.t = t
        copy:SetEnabled(t.id ~= "general")
        paste:SetEnabled(t.id ~= "general" and copiedId == t.id)
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
    pickUpKey:SetItems(GetModifierItems())
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
        pane.t.sharedCfg.colors.equipped[1] = r
        pane.t.sharedCfg.colors.equipped[2] = g
        pane.t.sharedCfg.colors.equipped[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    equippedCheckButton:SetOnCheck(function(checked)
        pane.t.sharedCfg.hideElements.equipped = not checked
        equippedColorPicker:SetEnabled(checked)
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local macroColorPicker = AF.CreateColorPicker(pane, L["Macro Border Color"])
    AF.SetPoint(macroColorPicker, "TOPLEFT", equippedCheckButton, "BOTTOMLEFT", 0, -7)
    macroColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.sharedCfg.colors.macro[1] = r
        pane.t.sharedCfg.colors.macro[2] = g
        pane.t.sharedCfg.colors.macro[3] = b
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    function pane.Load(t)
        pane.t = t
        outOfRangeColorDropdown:SetSelectedValue(t.sharedCfg.outOfRangeColoring)
        outOfRangeColorPicker:SetColor(t.sharedCfg.colors.range)
        notUsableColorPicker:SetColor(t.sharedCfg.colors.notUsable)
        insufficientPowerColorPicker:SetColor(t.sharedCfg.colors.mana)
        equippedCheckButton:SetChecked(not t.sharedCfg.hideElements.equipped)
        equippedColorPicker:SetEnabled(not t.sharedCfg.hideElements.equipped)
        equippedColorPicker:SetColor(t.sharedCfg.colors.equipped)
        macroColorPicker:SetColor(t.sharedCfg.colors.macro)
    end

    return pane
end

---------------------------------------------------------------------
-- texts
---------------------------------------------------------------------
builder["texts"] = function(parent)
    if created["texts"] then return created["texts"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Texts", nil, 130)
    created["texts"] = pane



    return pane
end

---------------------------------------------------------------------
-- cast
---------------------------------------------------------------------
builder["cast"] = function(parent)
    if created["cast"] then return created["cast"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Cast", nil, 75)
    created["cast"] = pane

    local selfCast = AF.CreateCheckButton(pane, L["Auto Self Cast"])
    AF.SetPoint(selfCast, "TOPLEFT", 15, -8)
    selfCast:SetOnCheck(function(checked)
        pane.t.sharedCfg.cast.self = checked
        AF.Fire("BFI_UpdateModule", "actionBars", "main")
    end)

    local mouseoverCastDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(mouseoverCastDropdown, "TOPLEFT", selfCast, "BOTTOMLEFT", 0, -25)
    mouseoverCastDropdown:SetItems(GetModifierItems())
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
    focusCastDropdown:SetItems(GetModifierItems())
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

    local flyoutWidth = AF.CreateSlider(pane, L["Flyout Button Width"], 150, 20, 100, 1, nil, true)
    AF.SetPoint(flyoutWidth, "LEFT", 15, 0)
    flyoutWidth:SetAfterValueChanged(function(value)
        pane.t.cfg.flyoutSize[1] = value
        AF.Fire("BFI_UpdateModule", "actionBars", "flyout")
    end)

    local flyoutHeight = AF.CreateSlider(pane, L["Flyout Button Height"], 150, 20, 100, 1, nil, true)
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
    anchorPoint:SetItems(GetAnchorPointItems())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[1] = value
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(GetAnchorPointItems())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[2] = value
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    x:SetOnValueChanged(function(value)
        pane.t.cfg.tooltip.position[3] = value
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetOnValueChanged(function(value)
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
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end