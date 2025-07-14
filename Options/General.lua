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
local function CreateBFIPane()
    local bfiPane = AF.CreateTitledPane(generalPanel, "BFI", nil, 200)
    generalPanel.bfiPane = bfiPane
    AF.SetPoint(bfiPane, "TOPLEFT", generalPanel, 15, -15)
    AF.SetPoint(bfiPane, "TOPRIGHT", generalPanel, -15, -15)

    -- language
    -- local languageDropdown = AF.CreateDropdown(bfiPane, 140)
    -- bfiPane.languageDropdown = languageDropdown
    -- AF.SetPoint(languageDropdown, "TOPLEFT", bfiPane, 15, -45)
    -- languageDropdown:SetLabel(L["Language"])

    -- scale
    local scaleSlider = AF.CreateSlider(bfiPane, "UI " .. L["Scale"], 140, 0.5, 1.5, 0.01, nil, true)
    bfiPane.scaleSlider = scaleSlider
    AF.SetPoint(scaleSlider, "TOPLEFT", bfiPane, 15, -45)
    scaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.scale = value
        AF.SetUIParentScale(value, true)
        ShowReloadPopup()
    end)

    -- recommended scale
    local recommendedScaleButton = AF.CreateButton(scaleSlider, nil, "BFI_hover", 17, 17)
    recommendedScaleButton:SetTexture(AF.GetIcon("Resize"), {15, 15})
    AF.SetPoint(recommendedScaleButton, "BOTTOMRIGHT", scaleSlider, "TOPRIGHT", 0, 2)
    recommendedScaleButton:SetTooltip(L["Apply Recommended Scale"])
    recommendedScaleButton:SetOnClick(function()
        local bestScale = AF.GetBestScale()
        if BFIConfig.scale == bestScale then return end
        BFIConfig.scale = bestScale
        scaleSlider:SetValue(bestScale)
        AF.SetUIParentScale(bestScale, true)
        ShowReloadPopup()
    end)

    -- game menu scale
    local gameMenuScaleSlider = AF.CreateSlider(bfiPane, L["Game Menu Scale"], 140, 0.5, 1.5, 0.1, nil, true)
    bfiPane.gameMenuScaleSlider = gameMenuScaleSlider
    AF.SetPoint(gameMenuScaleSlider, "TOPLEFT", scaleSlider, "TOPRIGHT", 35, 0)
    gameMenuScaleSlider:SetAfterValueChanged(function(value)
        BFIConfig.gameMenuScale = value
        GameMenuFrame:SetScale(BFIConfig.gameMenuScale)
    end)

    -- custom accent color
    local customAccentColorCheckbox = AF.CreateCheckButton(bfiPane, nil, function(checked)
        BFIConfig.customAccentColor.enabled = checked
        generalPanel.bfiPane.customAccentColorColorPicker:SetEnabled(checked)
    end)
    customAccentColorCheckbox:SetTooltip("BFI " .. AF.L["Accent Color"], AF.L["A UI reload is required"])
    bfiPane.customAccentColorCheckbox = customAccentColorCheckbox
    AF.SetPoint(customAccentColorCheckbox, "TOPLEFT", scaleSlider, 0, -45)

    local customAccentColorColorPicker = AF.CreateColorPicker(customAccentColorCheckbox, "BFI " .. AF.L["Accent Color"], nil, nil, function(r, g, b)
        BFIConfig.customAccentColor.color[1] = r
        BFIConfig.customAccentColor.color[2] = g
        BFIConfig.customAccentColor.color[3] = b
        ShowReloadPopup()
    end)
    bfiPane.customAccentColorColorPicker = customAccentColorColorPicker
    AF.SetPoint(customAccentColorColorPicker, "TOPLEFT", customAccentColorCheckbox, "TOPRIGHT", 5, 0)
end

---------------------------------------------------------------------
-- abstract framework pane
---------------------------------------------------------------------
local function CreateAFPane()
    local afPane = AF.CreateTitledPane(generalPanel, AF.GetIconString("AF") .. "AbstractFramework", nil, 100)
    generalPanel.afPane = afPane
    AF.SetPoint(afPane, "TOPLEFT", generalPanel.bfiPane, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(afPane, "TOPRIGHT", generalPanel.bfiPane, "BOTTOMRIGHT", 0, -15)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function Load()
    generalPanel.bfiPane.scaleSlider:SetValue(BFIConfig.scale)
    generalPanel.bfiPane.gameMenuScaleSlider:SetValue(BFIConfig.gameMenuScale)
    generalPanel.bfiPane.customAccentColorCheckbox:SetChecked(BFIConfig.customAccentColor.enabled)
    generalPanel.bfiPane.customAccentColorColorPicker:SetColor(BFIConfig.customAccentColor.color)
    generalPanel.bfiPane.customAccentColorColorPicker:SetEnabled(BFIConfig.customAccentColor.enabled)
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