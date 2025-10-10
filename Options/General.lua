---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local generalPanel

local function ShowReloadPopup()
    local dialog = AF.GetDialog(generalPanel, L["A UI reload is required\nDo it now?"])
    AF.SetPoint(dialog, "TOP", 0, -200)
    dialog:SetOnConfirm(ReloadUI)
end

---------------------------------------------------------------------
-- general panel
---------------------------------------------------------------------
local function CreateGeneralPanel()
    generalPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_GeneralPanel")
    generalPanel:SetAllPoints()
    AF.ApplyCombatProtectionToFrame(generalPanel)
end

---------------------------------------------------------------------
-- bfi pane
---------------------------------------------------------------------
local bfiPane

local function CreateBFIPane()
    bfiPane = AF.CreateTitledPane(generalPanel, "BFI", 260, 190)
    generalPanel.bfiPane = bfiPane
    AF.SetPoint(bfiPane, "TOPLEFT", generalPanel, 15, -15)
    -- AF.SetPoint(bfiPane, "TOPRIGHT", generalPanel, -15, -15)

    -- language
    -- local languageDropdown = AF.CreateDropdown(bfiPane, 150)
    -- bfiPane.languageDropdown = languageDropdown
    -- AF.SetPoint(languageDropdown, "TOPLEFT", bfiPane, 15, -45)
    -- languageDropdown:SetLabel(L["Language"])

    -- accent color
    local accentColorDropdown = AF.CreateDropdown(bfiPane, 150)
    bfiPane.accentColorDropdown = accentColorDropdown
    AF.SetPoint(accentColorDropdown, "TOPLEFT", bfiPane, 10, -45)
    accentColorDropdown:SetLabel("BFI " .. AF.L["Accent Color"])

    accentColorDropdown:SetItems({
        {text = _G.DEFAULT, value = "default"},
        -- {text = CLASS, value = "class", disabled = true},
        {text = _G.CUSTOM, value = "custom"},
    })

    accentColorDropdown:SetOnSelect(function(value)
        BFIConfig.general.accentColor.type = value
        bfiPane.accentColorPicker:SetShown(value == "custom")
        ShowReloadPopup()
    end)

    local accentColorPicker = AF.CreateColorPicker(accentColorDropdown, nil, nil, nil, function(r, g, b)
        BFIConfig.general.accentColor.color[1] = r
        BFIConfig.general.accentColor.color[2] = g
        BFIConfig.general.accentColor.color[3] = b
        ShowReloadPopup()
    end)
    bfiPane.accentColorPicker = accentColorPicker
    AF.SetPoint(accentColorPicker, "LEFT", accentColorDropdown, "RIGHT", 5, 0)

    -- scale
    local scaleSlider = AF.CreateSlider(bfiPane, _G.UI_SCALE, 150, 0.5, 1.5, 0.01, nil, true)
    bfiPane.scaleSlider = scaleSlider
    AF.SetPoint(scaleSlider, "TOPLEFT", accentColorDropdown, "BOTTOMLEFT", 0, -30)
    scaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.general.scale[BFI.vars.resolution] = value
        AF.SetUIParentScale(value, true)
        ShowReloadPopup()
    end)
    scaleSlider:SetTooltip(_G.UI_SCALE, L["A separate UI scale is saved for each resolution"],
        AF.WrapTextInColor(L["Current resolution: %dx%d"]:format(GetPhysicalScreenSize()), "gray"))

    -- recommended scale
    local recommendedScaleButton = AF.CreateButton(scaleSlider, nil, "BFI_hover", 17, 17)
    recommendedScaleButton:SetTexture(AF.GetIcon("Resize"), {15, 15})
    AF.SetPoint(recommendedScaleButton, "BOTTOMRIGHT", scaleSlider, "TOPRIGHT", 0, 2)
    recommendedScaleButton:SetTooltip(L["Auto Scale"])
    recommendedScaleButton:SetOnClick(function()
        local bestScale = AF.GetBestScale()
        if BFIConfig.general.scale[BFI.vars.resolution] == bestScale then return end
        BFIConfig.general.scale[BFI.vars.resolution] = bestScale
        scaleSlider:SetValue(bestScale)
        AF.SetUIParentScale(bestScale, true)
        ShowReloadPopup()
    end)

    -- game menu scale
    local gameMenuScaleSlider = AF.CreateSlider(bfiPane, L["Game Menu Scale"], 150, 0.5, 1.5, 0.1, nil, true)
    bfiPane.gameMenuScaleSlider = gameMenuScaleSlider
    AF.SetPoint(gameMenuScaleSlider, "TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -45)
    gameMenuScaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.general.gameMenuScale = value
        _G.GameMenuFrame:SetScale(BFIConfig.general.gameMenuScale)
        AF.UpdatePixelsForRegionAndChildren(_G.GameMenuFrame)
    end)

    -- TODO: move to enhancements
    -- local autoRepairDropdown = AF.CreateDropdown(bfiPane, 150)
    -- bfiPane.autoRepairDropdown = autoRepairDropdown
    -- AF.SetPoint(autoRepairDropdown, "TOPLEFT", scaleSlider, 0, -55)
    -- autoRepairDropdown:SetLabel(L["Auto Repair"])
    -- autoRepairDropdown:SetItems({
    --     {text = L["Disabled"], value = "disabled"},
    --     {text = PLAYER, value = "player"},
    --     {text = GUILD, value = "guild"},
    -- })
    -- autoRepairDropdown:SetOnSelect(function(value)
    -- end)
    -- autoRepairDropdown:SetSelectedValue("disabled")
    -- autoRepairDropdown:SetEnabled(false)

    function bfiPane.Load()
        accentColorDropdown:SetSelectedValue(BFIConfig.general.accentColor.type)
        accentColorPicker:SetColor(BFIConfig.general.accentColor.color)
        accentColorPicker:SetShown(BFIConfig.general.accentColor.type == "custom")
        scaleSlider:SetValue(BFIConfig.general.scale[BFI.vars.resolution])
        gameMenuScaleSlider:SetValue(BFIConfig.general.gameMenuScale)
    end
end

---------------------------------------------------------------------
-- abstract framework pane
---------------------------------------------------------------------
local afPane

local function CreateAFPane()
    afPane = AF.CreateTitledPane(generalPanel, "AbstractFramework", 260, 190)
    generalPanel.afPane = afPane
    AF.SetPoint(afPane, "TOPRIGHT", -15, -15)
    -- AF.SetPoint(afPane, "TOPRIGHT", generalPanel.bfiPane, "BOTTOMRIGHT", 0, -15)

    afPane:SetTips("AbstractFramework", L["Changing these settings affects all addons that use AbstractFramework"])

    -- accent color
    local accentColorDropdown = AF.CreateDropdown(afPane, 150)
    afPane.accentColorDropdown = accentColorDropdown
    AF.SetPoint(accentColorDropdown, "TOPLEFT", afPane, 10, -45)
    accentColorDropdown:SetLabel("AF " .. AF.L["Accent Color"])

    accentColorDropdown:SetItems({
        {text = _G.DEFAULT, value = "default"},
        {text = _G.CUSTOM, value = "custom"},
    })

    accentColorDropdown:SetOnSelect(function(value)
        AFConfig.accentColor.type = value
        afPane.accentColorPicker:SetShown(value == "custom")
        ShowReloadPopup()
    end)

    local accentColorPicker = AF.CreateColorPicker(accentColorDropdown, nil, nil, nil, function(r, g, b)
        AFConfig.accentColor.color = AF.BuildAccentColorTable({r, g, b})
        ShowReloadPopup()
    end)
    afPane.accentColorPicker = accentColorPicker
    AF.SetPoint(accentColorPicker, "LEFT", accentColorDropdown, "RIGHT", 5, 0)

    -- scale
    local scaleSlider = AF.CreateSlider(afPane, "AF " .. L["Scale"], 150, 0.5, 1.5, 0.1, nil, true)
    afPane.scaleSlider = scaleSlider
    AF.SetPoint(scaleSlider, "TOPLEFT", accentColorDropdown, "BOTTOMLEFT", 0, -30)
    scaleSlider:SetAfterValueChanged(function(value)
        AFConfig.scale = value
        AF.SetScale(value, true)
        ShowReloadPopup()
    end)

    -- font size
    local fontSizeSlider = AF.CreateSlider(afPane, "AF " .. L["Font Size"], 150, -5, 5, 1, nil, true)
    afPane.fontSizeSlider = fontSizeSlider
    AF.SetPoint(fontSizeSlider, "TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -45)
    fontSizeSlider:SetAfterValueChanged(function(value)
        AFConfig.fontSizeDelta = value
        AF.UpdateFontSize(value)
    end)

    function afPane.Load()
        accentColorDropdown:SetSelectedValue(AFConfig.accentColor.type)
        accentColorPicker:SetColor(AFConfig.accentColor.color.t)
        accentColorPicker:SetShown(AFConfig.accentColor.type == "custom")
        scaleSlider:SetValue(AFConfig.scale)
        fontSizeSlider:SetValue(AFConfig.fontSizeDelta)
    end
end

---------------------------------------------------------------------
-- font pane
---------------------------------------------------------------------
local fontPane

local function CreateFontPane()
    local _BFI = AF.WrapTextInColor("BFI", "BFI")
    local _BFI_DEFAULT = AF.WrapTextInColor("BFI Default", "BFI")
    local _BFI_COMBAT = AF.WrapTextInColor("BFI Combat", "BFI")

    fontPane = AF.CreateTitledPane(generalPanel, L["Fonts"], 180, 200)
    generalPanel.fontPane = fontPane
    AF.SetPoint(fontPane, "TOPLEFT", generalPanel.bfiPane, "BOTTOMLEFT", 0, -30)

    local font = AF.CreateDropdown(fontPane, 150)
    AF.SetPoint(font, "TOPLEFT", fontPane, 10, -45)

    font:SetLabel(_BFI .. " " .. L["Font"])
    font._tooltipWordWrapMinWidth = 400
    font:SetTooltip(_BFI .. " " .. L["Font"],
        L["Change the actual style of the %s font"]:format(_BFI),
        L["Select the %s font in other components' font settings to apply it universally"]:format(_BFI),
        " ",
        L["The %s and %s fonts mainly support English and Simplified Chinese"]:format(_BFI_DEFAULT, _BFI_COMBAT),
        " ",
        AF.WrapTextInColor("BFI Default: NotoSansCJKsc + Accidental Presidency", "gray"),
        AF.WrapTextInColor("BFI Combat: NotoSansCJKsc + Dolphin", "gray")
)

    local items = AF.LSM_GetFontDropdownItems()
    for k, v in ipairs(items) do
        if v.text == "BFI" then
            table.remove(items, k)
            break
        end
    end

    font:SetItems(items)
    font:SetOnSelect(function(value)
        BFIConfig.general.font.common.font = value
        ShowReloadPopup()
    end)

    local overrideAF = AF.CreateCheckButton(fontPane, L["Override AF Font"])
    AF.SetPoint(overrideAF, "TOPLEFT", font, "BOTTOMLEFT", 0, -15)
    overrideAF:SetOnCheck(function(checked)
        BFIConfig.general.font.common.overrideAF = checked
        ShowReloadPopup()
    end)

    local overrideBlizzard = AF.CreateCheckButton(fontPane, L["Override Blizzard Font"])
    AF.SetPoint(overrideBlizzard, "TOPLEFT", overrideAF, "BOTTOMLEFT", 0, -15)

    local blizzardFontSizeDelta = AF.CreateSlider(fontPane, L["Blizzard Font Size"], 150, -5, 5, 1, nil, true)
    AF.SetPoint(blizzardFontSizeDelta, "TOPLEFT", overrideBlizzard, "BOTTOMLEFT", 0, -30)
    blizzardFontSizeDelta:SetAfterValueChanged(function(value)
        BFIConfig.general.font.common.blizzardFontSizeDelta = value
        ShowReloadPopup()
    end)

    overrideBlizzard:SetOnCheck(function(checked)
        BFIConfig.general.font.common.overrideBlizzard = checked
        blizzardFontSizeDelta:SetEnabled(checked)
        ShowReloadPopup()
    end)

    local overrideCombatTextFont = AF.CreateDropdown(fontPane, 150)
    AF.SetPoint(overrideCombatTextFont, "TOPLEFT", blizzardFontSizeDelta, "BOTTOMLEFT", 0, -50)
    overrideCombatTextFont:SetItems(AF.LSM_GetFontDropdownItems())
    overrideCombatTextFont:SetOnSelect(function(value)
        BFIConfig.general.font.combatText.font = value
    end)

    local overrideCombatText = AF.CreateCheckButton(fontPane, L["Override Combat Text"])
    AF.SetPoint(overrideCombatText, "BOTTOMLEFT", overrideCombatTextFont, "TOPLEFT", 0, 2)
    overrideCombatText:SetTooltip(L["Requires relog or restart to take effect"])
    overrideCombatText:SetOnCheck(function(checked)
        BFIConfig.general.font.combatText.override = checked
        overrideCombatTextFont:SetEnabled(checked)
    end)

    local overrideNameTextFont = AF.CreateDropdown(fontPane, 150)
    AF.SetPoint(overrideNameTextFont, "TOPLEFT", overrideCombatTextFont, "BOTTOMLEFT", 0, -40)
    overrideNameTextFont:SetItems(AF.LSM_GetFontDropdownItems())
    overrideNameTextFont:SetOnSelect(function(value)
        BFIConfig.general.font.nameText.font = value
    end)

    local overrideNameText = AF.CreateCheckButton(fontPane, L["Override Name Text"])
    AF.SetPoint(overrideNameText, "BOTTOMLEFT", overrideNameTextFont, "TOPLEFT", 0, 2)
    overrideNameText:SetTooltip(L["Requires relog or restart to take effect"])
    overrideNameText:SetOnCheck(function(checked)
        BFIConfig.general.font.nameText.override = checked
        overrideNameTextFont:SetEnabled(checked)
    end)

    function fontPane.Load()
        font:SetSelectedValue(BFIConfig.general.font.common.font)
        overrideAF:SetChecked(BFIConfig.general.font.common.overrideAF)
        overrideBlizzard:SetChecked(BFIConfig.general.font.common.overrideBlizzard)
        blizzardFontSizeDelta:SetEnabled(BFIConfig.general.font.common.overrideBlizzard)
        blizzardFontSizeDelta:SetValue(BFIConfig.general.font.common.blizzardFontSizeDelta)

        overrideCombatText:SetChecked(BFIConfig.general.font.combatText.override)
        overrideCombatTextFont:SetSelectedValue(BFIConfig.general.font.combatText.font)
        overrideCombatTextFont:SetEnabled(BFIConfig.general.font.combatText.override)

        overrideNameText:SetChecked(BFIConfig.general.font.nameText.override)
        overrideNameTextFont:SetSelectedValue(BFIConfig.general.font.nameText.font)
        overrideNameTextFont:SetEnabled(BFIConfig.general.font.nameText.override)
    end
end

---------------------------------------------------------------------
-- cvar pane
---------------------------------------------------------------------
local cvarPane
local cvarWidgets = {}

local GetCVar = GetCVar
local SetCVar = SetCVar
local _GetCVarDefault = GetCVarDefault
local _GetCVarBool = GetCVarBool

local function GetCVarBool(cvar)
    if type(cvar) == "table" then
        for _, c in next, cvar do
            if not _GetCVarBool(c) then
                return false
            end
        end
        return true
    else
        return _GetCVarBool(cvar)
    end
end

local function GetCVarDefault(cvar)
    local default = _GetCVarDefault(cvar)
    if tonumber(default) then
        default = AF.RoundToDecimal(tonumber(default), 2)
    end
    return default
end

local cvarLineFormatLeft, cvarLineFormatRight = AF.WrapTextInColor("\"%s\"", "yellow_text"), AF.WrapTextInColor(L["Default Value: %s"], "softlime")
local function GetCVarTooltipLine(cvar)
    return {format(cvarLineFormatLeft, cvar), format(cvarLineFormatRight, AF.WrapTextInColor(GetCVarDefault(cvar), "white"))}
end

local function Option_OnEnter(self)
    if not self.tooltipLines then
        local lines = {self.info.label, self.info.tooltip}
        if type(self.info.name) == "table" then
            for i, c in next, self.info.name do
                local doubleLine = GetCVarTooltipLine(c)
                tinsert(lines, i + 1, doubleLine)
            end
        else
            tinsert(lines, 2, GetCVarTooltipLine(self.info.name))
        end
        self.tooltipLines = lines
    end
    AF.ShowTooltip(self, "LEFT", -5, 0, self.tooltipLines)
end

local function Option_OnLeave(self)
    AF.HideTooltip()
end

local function RegisterParent(holder, parent)
    if not parent then return end
    for _, widget in next, cvarWidgets do
        if widget.info.name == parent then
            widget.children = widget.children or {}
            tinsert(widget.children, holder)
        end
    end
end

local cvarOptions = {
    slider = function(info)
        local holder = CreateFrame("Frame", nil, cvarPane)
        holder.info = info

        local slider = AF.CreateSlider(holder, info.label, 35, info.min, info.max, info.step)
        slider:SetPoint("LEFT")
        slider:EnableMouseWheel(true)
        slider.eb:Hide()

        AF.ClearPoints(slider.label)
        AF.SetPoint(slider.label, "LEFT", slider, "RIGHT", 33, 0)

        slider.info = info
        slider:HookOnEnter(Option_OnEnter)
        slider:HookOnLeave(Option_OnLeave)

        local current = AF.CreateFontString(slider, nil, "tip")
        AF.SetPoint(current, "LEFT", slider, "RIGHT", 3, 0)
        slider:SetOnValueChanged(function(value)
            current:SetText(value)
            SetCVar(info.name, value)

            if holder.children then
                for _, child in next, holder.children do
                    child:Load()
                end
            end
        end)

        RegisterParent(holder, info.parent)

        function holder.Load()
            local value = F.GetCVarNumber(info.name)
            current:SetText(AF.RoundToNearestMultiple(value, info.step))
            slider:SetValue(value)

            if info.parent then
                slider:SetEnabled(GetCVar(info.parent) ~= "0")
            end
        end

        return holder
    end,

    toggle = function(info)
        local holder = CreateFrame("Frame", nil, cvarPane)
        holder.info = info

        local toggle = AF.CreateCheckButton(holder, info.label)
        toggle:SetPoint("LEFT")
        toggle:SetChecked(GetCVarBool(info.name))
        toggle:SetOnCheck(function(checked)
            if type(info.name) == "table" then
                for _, c in next, info.name do
                    SetCVar(c, checked)
                end
            else
                SetCVar(info.name, checked)
            end

            if holder.children then
                for _, child in next, holder.children do
                    child:Load()
                end
            end
        end)

        toggle.info = info
        toggle:HookOnEnter(Option_OnEnter)
        toggle:HookOnLeave(Option_OnLeave)

        RegisterParent(holder, info.parent)

        function holder.Load()
            toggle:SetChecked(GetCVarBool(info.name))

            if info.parent then
                toggle:SetEnabled(GetCVar(info.parent) ~= "0")
            end
        end

        return holder
    end,
}

local cvars = {
    {name = "scriptErrors", type = "toggle", label = SHOW_LUA_ERRORS, tooltip = OPTION_TOOLTIP_SHOW_LUA_ERRORS},
    {name = "cameraDistanceMaxZoomFactor", type = "slider", min = 1, max = 2.6, step = 0.1, label = MAX_FOLLOW_DIST, tooltip = OPTION_TOOLTIP_MAX_FOLLOW_DIST},
    {name = "SpellQueueWindow", type = "slider", min = 0, max = 400, step = 1, label = LAG_TOLERANCE .. " (" .. MILLISECONDS_ABBR .. ")", tooltip = OPTION_TOOLTIP_REDUCED_LAG_TOLERANCE},
    {name = "ResampleAlwaysSharpen", type = "toggle", label = L["Always Enable Sharpening"]},
    {name = "ResampleSharpness", type = "slider", min = 0, max = 2, step = 0.1, label = RESAMPLE_SHARPNESS, tooltip = OPTION_TOOLTIP_SHARPNESS},
    {name = "mapFade", type = "toggle", label = MAP_FADE_TEXT, tooltip = OPTION_TOOLTIP_MAP_FADE},
    {name = "UnitNamePlayerGuild", type = "toggle", label = SHOW_PLAYER_NAMES .. " - " .. UNIT_NAME_GUILD, tooltip = OPTION_TOOLTIP_UNIT_NAME_GUILD},
    {name = "UnitNamePlayerPVPTitle", type = "toggle", label = SHOW_PLAYER_NAMES .. " - " .. UNIT_NAME_PLAYER_TITLE, tooltip = OPTION_TOOLTIP_UNIT_NAME_PLAYER_TITLE},
    {name = "WorldTextScale", type = "slider", min = 0.5, max = 2.5, step = 0.1, label = L["Combat Text Scale"], tooltip = L["Adjust the size of floating combat text"]},
    {
        name = {"floatingCombatTextCombatDamage", "floatingCombatTextCombatLogPeriodicSpells"},
        type = "toggle", label = L["Combat Text - Player Damage"], tooltip = OPTION_TOOLTIP_SHOW_DAMAGE
    },
    {
        name = {"floatingCombatTextPetMeleeDamage", "floatingCombatTextPetSpellDamage"},
        type = "toggle", label = L["Combat Text - Pet Damage"], tooltip = OPTION_TOOLTIP_SHOW_PET_MELEE_DAMAGE
    },
    {
        name = {"floatingCombatTextCombatHealing", "floatingCombatTextCombatHealingAbsorbTarget"},
        type = "toggle", label = L["Combat Text - Healing"], tooltip = OPTION_TOOLTIP_SHOW_COMBAT_HEALING
    },
    {name = "floatingCombatTextCombatDamageDirectionalScale", type = "slider", min = 0, max = 5, step = 1, label = L["Combat Text - Damage Directional Scale"], tooltip = L["Directional damage number motion scale (0 = disabled)"]},
    {name = "floatingCombatTextCombatDamageDirectionalOffset", parent = "floatingCombatTextCombatDamageDirectionalScale", type = "slider", min = 0, max = 15, step = 1, label = L["Combat Text - Damage Directional Offset"], tooltip = L["Initial offset for directional damage numbers"]},
    {name = "cameraIndirectVisibility", type = "toggle", label = L["Camera Occlusion Tolerance"], tooltip = L["Allow minor occlusion before the camera moves closer"]},
    {name = "cameraIndirectOffset", parent = "cameraIndirectVisibility", type = "slider", min = 1, max = 10, step = 0.5, label = L["Camera Occlusion Offset"], tooltip = L["Offset used when avoiding occlusion (1 = most sensitive, 10 = least)"]},
    {name = "stopAutoAttackOnTargetChange", type = "toggle", label = STOP_AUTO_ATTACK, tooltip = OPTION_TOOLTIP_STOP_AUTO_ATTACK},
}

function F.GetCVarData()
    local data = {}
    for _, info in next, cvars do
        data[info.name] = GetCVar(info.name)
    end
    return data
end

local function CreateCVarPane()
    cvarPane = AF.CreateTitledPane(generalPanel, "CVars", 340, 200)
    generalPanel.cvarPane = cvarPane
    AF.SetPoint(cvarPane, "TOPRIGHT", generalPanel.afPane, "BOTTOMRIGHT", 0, -30)

    cvarPane:SetTips("CVars", L["You can use the mouse wheel on sliders to adjust values"])

    local list = AF.CreateScrollList(cvarPane, nil, 0, 5, 11, 20, 6, "none", "none")
    cvarPane.list = list
    AF.SetPoint(list, "TOPLEFT", cvarPane, 5, -30)
    AF.SetPoint(list, "TOPRIGHT", cvarPane, -5, -30)
    list.scrollBar:SetBorderColor("border")

    for _, info in next, cvars do
        local widget = cvarOptions[info.type](info)
        tinsert(cvarWidgets, widget)
    end
    list:SetWidgets(cvarWidgets)

    -- REVIEW: floatingCombatTextSpellMechanics, SHOW_TARGET_EFFECTS, OPTION_TOOLTIP_SHOW_TARGET_EFFECTS
    -- REVIEW: floatingCombatTextSpellMechanicsOther, SHOW_OTHER_TARGET_EFFECTS, OPTION_TOOLTIP_SHOW_OTHER_TARGET_EFFECTS

    function cvarPane.Load()
        for _, widget in next, cvarWidgets do
            widget.Load()
        end
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function Load()
    bfiPane.Load()
    afPane.Load()
    fontPane.Load()
    cvarPane.Load()
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "general" then
        if not generalPanel then
            CreateGeneralPanel()
            CreateBFIPane()
            CreateAFPane()
            CreateFontPane()
            CreateCVarPane()
        end
        Load()
        generalPanel:Show()
    elseif generalPanel then
        generalPanel:Hide()
    end
end)