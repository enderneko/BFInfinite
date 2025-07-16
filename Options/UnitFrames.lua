---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local unitFramesPanel
local LoadList

---------------------------------------------------------------------
-- unit frames panel
---------------------------------------------------------------------
local function CreateUnitFramesPanel()
    unitFramesPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_UnitFramesPanel")
    unitFramesPanel:SetAllPoints()
    -- AF.ApplyCombatProtectionToFrame(unitFramesPanel)

    -- switch
    local subs = {
        unit = {"Player", "Target", "Focus", "Pet"},
        target = {"Target Target", "Focus Target", "Pet Target"},
        group = {"Party", "Raid", "Boss", "Arena"},
    }

    local subItems = {}

    local mainSwitch = AF.CreateSwitch(unitFramesPanel, 200, 20)
    unitFramesPanel.mainSwitch = mainSwitch
    AF.SetPoint(mainSwitch, "TOPLEFT", 15, -15)
    -- AF.SetPoint(mainSwitch, "TOPRIGHT")

    local subSwitch = AF.CreateSwitch(unitFramesPanel, 340, 20)
    unitFramesPanel.subSwitch = subSwitch
    AF.SetPoint(subSwitch, "TOPLEFT", mainSwitch, "TOPRIGHT", 10, 0)
    AF.SetPoint(subSwitch, "TOPRIGHT", unitFramesPanel, "TOPRIGHT", -15, -15)

    mainSwitch:SetLabels({
        {text = "Unit", value = "unit"},
        {text = "Target", value = "target"},
        {text = "Group", value = "group"},
    })

    mainSwitch:SetOnSelect(function(value)
        if not subItems[value] then
            for _, name in pairs(subs[value]) do
                subItems[value] = subItems[value] or {}
                tinsert(subItems[value], {text = L[name], value = name})
            end
        end

        subSwitch:SetLabels(subItems[value])
        subSwitch:SetSelectedValue(subs[value][1])
    end)

    subSwitch:SetOnSelect(function(value)
        LoadList(mainSwitch:GetSelectedValue(), value)
    end)
end

---------------------------------------------------------------------
-- content pane
---------------------------------------------------------------------
local contentPane
local function CreateContentPane()
    -- content
    contentPane = AF.CreateFrame(unitFramesPanel)
    unitFramesPanel.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", unitFramesPanel.mainSwitch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    -- indicator list
    local indicatorList = AF.CreateScrollList(contentPane, nil, 0, 0, 26, 20, -1)
    contentPane.indicatorList = indicatorList
    indicatorList:SetPoint("TOPLEFT")
    AF.SetWidth(indicatorList, 150)

    -- scroll config frame
    local scrollConfig = AF.CreateScrollFrame(contentPane, nil, nil, nil, "none", "none")
    contentPane.scrollConfig = scrollConfig
    AF.SetPoint(scrollConfig, "TOPLEFT", indicatorList, "TOPRIGHT", 15, 0)
    AF.SetPoint(scrollConfig, "BOTTOM", indicatorList)
    AF.SetPoint(scrollConfig, "RIGHT")
end

---------------------------------------------------------------------
-- indicators
---------------------------------------------------------------------
local indicators = {
    unit = {
        player = {
            "healthBar", "powerBar", "portrait", "castBar", "extraManaBar", "classPowerBar", "staggerBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "incDmgHealText",
            "buffs", "debuffs", "privateAuras",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon", "restingIndicator",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        target = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "rangeText",
            "buffs", "debuffs", "privateAuras",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "factionIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        focus = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter", "rangeText",
            "buffs", "debuffs", "privateAuras",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        pet = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "combatIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
    },
    target = {
        targettarget = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        focustarget = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        pettarget = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
    },
}

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local listItems = {}

local itemPool = AF.CreateObjectPool(function()
    local button = AF.CreateButton(contentPane.indicatorList, "", "BFI_transparent", nil, nil, nil, "none", "")
    button:EnablePushEffect(false)
    button:SetTextJustifyH("LEFT")

    return button
end)

local function ListItem_OnEnter(self)
    if self.text:IsTruncated() then
        AF.ShowTooltip(self, "LEFT", 0, 0, {self.text:GetText()})
    end
end

local function ListItem_OnLeave(self)
    AF.HideTooltip()
end

local function ListItem_LoadOptions(self)
    -- button carries frame/indicator/config data
    local options = F.GetIndicatorOptions(self)

    local scroll = contentPane.scrollConfig
    scroll:ClearContent()

    local last
    for _, pane in pairs(options) do
        pane:SetParent(scroll.scrollContent)
        AF.ClearPoints(pane)

        if last then
            AF.SetPoint(pane, "TOPLEFT", last, "BOTTOMLEFT", 0, -10)
        else
            AF.SetPoint(pane, "TOPLEFT", scroll.scrollContent)
        end
        AF.SetPoint(pane, "RIGHT", scroll.scrollContent)

        pane:Show()
        last = pane
    end
end

LoadList = function(main, sub)
    local list = contentPane.indicatorList
    list:Reset()
    itemPool:ReleaseAll()
    wipe(listItems)

    sub = sub:gsub(" ", "")

    local cfg = BFI.vars.profile.unitFrames[sub:lower()]

    for i, name in next, indicators[main][sub:lower()] do
        local button = itemPool:Acquire()
        tinsert(listItems, button)
        button:SetText(L[name])

        button.id = name
        button.target = _G["BFI_" .. sub]

        if name == "general" then
            button.cfg = cfg.general
        else
            button.cfg = cfg.indicators[name]
        end

        if cfg.enabled then
            button:SetEnabled(true)
            button:SetTextColor(button.cfg.enabled and "white" or "disabled")
        else
            button:SetEnabled(name == "general")
        end
    end

    list:SetWidgets(listItems)
    AF.CreateButtonGroup(listItems, ListItem_LoadOptions, nil, nil, ListItem_OnEnter, ListItem_OnLeave)

    listItems[1]:SilentClick()
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Unit Frames" then
        if not unitFramesPanel then
            CreateUnitFramesPanel()
            CreateContentPane()
            unitFramesPanel.mainSwitch:SetSelectedValue("unit")
        end
        unitFramesPanel:Show()
    elseif unitFramesPanel then
        unitFramesPanel:Hide()
    end
end)