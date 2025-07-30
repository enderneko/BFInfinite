---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local generalPanel

local function ShowReloadPopup()
    local dialog = AF.GetDialog(generalPanel, AF.L["A UI reload is required.\nDo it now?"])
    AF.SetPoint(dialog, "TOP", 0, -50)
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
    bfiPane = AF.CreateTitledPane(generalPanel, "BFI", 260, 300)
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
    AF.SetPoint(accentColorDropdown, "TOPLEFT", bfiPane, 15, -45)
    accentColorDropdown:SetLabel("BFI " .. AF.L["Accent Color"])

    accentColorDropdown:SetItems({
        {text = _G.DEFAULT, value = "default"},
        -- {text = CLASS, value = "class", disabled = true},
        {text = _G.CUSTOM, value = "custom"},
    })

    accentColorDropdown:SetOnSelect(function(value)
        BFIConfig.accentColor.type = value
        bfiPane.accentColorPicker:SetShown(value == "custom")
        ShowReloadPopup()
    end)

    local accentColorPicker = AF.CreateColorPicker(accentColorDropdown, nil, nil, nil, function(r, g, b)
        BFIConfig.accentColor.color[1] = r
        BFIConfig.accentColor.color[2] = g
        BFIConfig.accentColor.color[3] = b
        ShowReloadPopup()
    end)
    bfiPane.accentColorPicker = accentColorPicker
    AF.SetPoint(accentColorPicker, "LEFT", accentColorDropdown, "RIGHT", 5, 0)

    -- scale
    local scaleSlider = AF.CreateSlider(bfiPane, _G.UI_SCALE, 150, 0.5, 1.5, 0.01, nil, true)
    bfiPane.scaleSlider = scaleSlider
    AF.SetPoint(scaleSlider, "TOPLEFT", accentColorDropdown, "BOTTOMLEFT", 0, -35)
    scaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.scale[BFI.vars.resolution] = value
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
        if BFIConfig.scale[BFI.vars.resolution] == bestScale then return end
        BFIConfig.scale[BFI.vars.resolution] = bestScale
        scaleSlider:SetValue(bestScale)
        AF.SetUIParentScale(bestScale, true)
        ShowReloadPopup()
    end)

    -- game menu scale
    local gameMenuScaleSlider = AF.CreateSlider(bfiPane, L["Game Menu Scale"], 150, 0.5, 1.5, 0.1, nil, true)
    bfiPane.gameMenuScaleSlider = gameMenuScaleSlider
    AF.SetPoint(gameMenuScaleSlider, "TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -50)
    gameMenuScaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.gameMenuScale = value
        _G.GameMenuFrame:SetScale(BFIConfig.gameMenuScale)
        AF.UpdatePixelsForRegionAndChildren(_G.GameMenuFrame)
    end)

    -- auto repair
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
end

---------------------------------------------------------------------
-- abstract framework pane
---------------------------------------------------------------------
local afPane

local function CreateAFPane()
    afPane = AF.CreateTitledPane(generalPanel, "AbstractFramework", 260, 300)
    generalPanel.afPane = afPane
    AF.SetPoint(afPane, "TOPLEFT", generalPanel.bfiPane, "TOPRIGHT", 30, 0)
    -- AF.SetPoint(afPane, "TOPRIGHT", generalPanel.bfiPane, "BOTTOMRIGHT", 0, -15)

    afPane:SetTips("AbstractFramework", L["These settings may affect all addons using AbstractFramework"])

    -- accent color
    local accentColorDropdown = AF.CreateDropdown(afPane, 150)
    afPane.accentColorDropdown = accentColorDropdown
    AF.SetPoint(accentColorDropdown, "TOPLEFT", afPane, 15, -45)
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
    AF.SetPoint(scaleSlider, "TOPLEFT", accentColorDropdown, "BOTTOMLEFT", 0, -35)
    scaleSlider:SetAfterValueChanged(function(value)
        AFConfig.scale = value
        AF.SetScale(value, true)
        ShowReloadPopup()
    end)

    -- font size
    local fontSizeSlider = AF.CreateSlider(afPane, "AF " .. L["Font Size"], 150, -5, 5, 1, nil, true)
    afPane.fontSizeSlider = fontSizeSlider
    AF.SetPoint(fontSizeSlider, "TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -50)
    fontSizeSlider:SetAfterValueChanged(function(value)
        AFConfig.fontSizeOffset = value
        AF.UpdateFontSize(value)
    end)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function Load()
    bfiPane.scaleSlider:SetValue(BFIConfig.scale[BFI.vars.resolution])
    bfiPane.gameMenuScaleSlider:SetValue(BFIConfig.gameMenuScale)
    bfiPane.accentColorDropdown:SetSelectedValue(BFIConfig.accentColor.type)
    bfiPane.accentColorPicker:SetColor(BFIConfig.accentColor.color)
    bfiPane.accentColorPicker:SetShown(BFIConfig.accentColor.type == "custom")

    afPane.accentColorDropdown:SetSelectedValue(AFConfig.accentColor.type)
    afPane.accentColorPicker:SetColor(AFConfig.accentColor.color.t)
    afPane.accentColorPicker:SetShown(AFConfig.accentColor.type == "custom")
    afPane.scaleSlider:SetValue(AFConfig.scale)
    afPane.fontSizeSlider:SetValue(AFConfig.fontSizeOffset)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "General" then
        if not generalPanel then
            CreateGeneralPanel()
            CreateBFIPane()
            CreateAFPane()
        end
        Load()
        generalPanel:Show()
    elseif generalPanel then
        generalPanel:Hide()
    end
end)