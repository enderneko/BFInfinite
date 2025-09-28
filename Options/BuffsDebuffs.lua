---@type BFI
local BFI = select(2, ...)
local L = BFI.L
local BD = BFI.modules.BuffsDebuffs
---@type AbstractFramework
local AF = _G.AbstractFramework

local LoadOptions

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
end

---------------------------------------------------------------------
-- normal
---------------------------------------------------------------------
local normalPane

local function CreateNormalPane()
    normalPane = AF.CreateFrame(buffsDebuffsPanel)
    AF.SetPoint(normalPane, "TOPLEFT", buffsDebuffsPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(normalPane, "BOTTOMRIGHT", -15, 15)

    -- icons
    local iconsPane = AF.CreateTitledPane(normalPane, L["Icons"], nil, 230)
    AF.SetPoint(iconsPane, "TOPLEFT", 0, -15)
    AF.SetPoint(iconsPane, "TOPRIGHT", 0, -15)

    local arrangement = AF.CreateDropdown(iconsPane, 200)
    AF.SetPoint(arrangement, "TOPLEFT", iconsPane, "TOPLEFT", 10, -45)
    arrangement:SetLabel(L["Arrangement"])
    arrangement:SetItems(AF.GetDropdownItems_Arrangement_Complex())

    local sortMethod = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(sortMethod, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -30)
    sortMethod:SetLabel(L["Sort Method"])

    local sortDirection = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(sortDirection, "TOPLEFT", sortMethod, "TOPRIGHT", 35, 0)
    sortDirection:SetLabel(L["Sort Direction"])

    local separateOwn = AF.CreateDropdown(iconsPane, 150)
    AF.SetPoint(separateOwn, "TOPLEFT", sortDirection, "TOPRIGHT", 35, 0)
    separateOwn:SetLabel(L["Separate Own"])

    local width = AF.CreateSlider(iconsPane, L["Width"], 150, 10, 100, nil, nil, true)
    AF.SetPoint(width, "TOPLEFT", sortMethod, "BOTTOMLEFT", 0, -25)

    local height = AF.CreateSlider(iconsPane, L["Height"], 150, 10, 100, nil, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, "BOTTOMLEFT", 0, -40)

    local spacingX = AF.CreateSlider(iconsPane, L["X Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingX, "TOPLEFT", width, "TOPRIGHT", 35, 0)

    local spacingY = AF.CreateSlider(iconsPane, L["Y Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingY, "TOPLEFT", height, "TOPRIGHT", 35, 0)

    local maxWraps = AF.CreateSlider(iconsPane, L["Max Lines"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(maxWraps, "TOPLEFT", spacingX, "TOPRIGHT", 35, 0)

    local wrapAfter = AF.CreateSlider(iconsPane, L["Displayed Per Line"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(wrapAfter, "TOPLEFT", spacingY, "TOPRIGHT", 35, 0)

    -- texts
    local textsPane = AF.CreateTitledPane(normalPane, L["Texts"], nil, 100)
    AF.SetPoint(textsPane, "TOPLEFT", iconsPane, "BOTTOMLEFT", 0, -30)
    AF.SetPoint(textsPane, "TOPRIGHT", iconsPane, "BOTTOMRIGHT", 0, -30)
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
    if buffsDebuffsPanel.switch:GetSelectedValue() == "privateAuras" then
        normalPane:Hide()
        privatePane:Show()
    else
        normalPane:Show()
        privatePane:Hide()
    end
end

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