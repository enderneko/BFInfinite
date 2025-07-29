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
                tinsert(subItems[value], {text = L[name], value = name, disabled = name == "Arena"})
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

    -- scroll settings frame
    local scrollSettings = AF.CreateScrollFrame(contentPane, nil, nil, nil, "none", "none")
    scrollSettings.scrollBar:SetBackdropBorderColor(AF.GetColorRGB("border"))
    contentPane.scrollSettings = scrollSettings
    AF.SetPoint(scrollSettings, "TOPLEFT", indicatorList, "TOPRIGHT", 15, 0)
    AF.SetPoint(scrollSettings, "BOTTOM", indicatorList)
    AF.SetPoint(scrollSettings, "RIGHT")
    scrollSettings:SetScrollStep(50)
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
    group = {
        party = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer",
            "buffs", "debuffs",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        raid = {
            "healthBar", "powerBar",
            "nameText", "healthText", "statusTimer",
            "buffs", "debuffs",
            "raidIcon", "leaderIcon", "roleIcon", "readyCheckIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        boss = {
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon",
            "targetHighlight", "mouseoverHighlight",
        },
        arena = {
        },
    },
}

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local listItems = {}
local lastIndicator

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
    -- AF.Fire("BFI_CheckCopiedInfo", self.module, self.id, self.ownerName, self.cfg)

    lastIndicator = self.id

    local scroll = contentPane.scrollSettings
    local options = F.GetIndicatorOptions(scroll.scrollContent, self)

    local heights = {}
    local last

    for i, pane in next, options do
        pane.index = i

        -- FIXME: seems cause weird issues that option values are not loaded properly (visible)
        -- maybe should set parent when creating the pane?
        -- pane:SetParent(scroll.scrollContent)

        if last then
            AF.SetPoint(pane, "TOPLEFT", last, "BOTTOMLEFT", 0, -10)
        else
            AF.SetPoint(pane, "TOPLEFT", scroll.scrollContent)
        end
        AF.SetPoint(pane, "RIGHT", scroll.scrollContent)

        last = pane
        tinsert(heights, pane._height or 0)
    end

    scroll:SetContentHeights(heights, 10)

    --! NOTE: sometimes option panes won't show, but if scrolled or BFIOptionsFrame is dragged they will appear
    --! maybe it's a WoW UI bug? or intentional?
    --! ScrollFrame SUCKS!!! so repoint to force update, hope it works
    C_Timer.After(0, function()
        AF.RePoint(scroll)
    end)

    --! NOTE: fix weird issues that option values are not loaded properly (slider editbox text invisible)
    --! 王德发！！啥破玩意儿？！
    C_Timer.NewTicker(0, function()
        for _, pane in next, options do
            pane.Load(self)
        end
    end, 2)
end

LoadList = function(main, sub)
    local list = contentPane.indicatorList
    list:Reset()
    itemPool:ReleaseAll()
    wipe(listItems)

    local owner = sub
    sub = sub:gsub(" ", "")

    local cfg = BFI.vars.profile.unitFrames[sub:lower()]

    for i, name in next, indicators[main][sub:lower()] do
        local button = itemPool:Acquire()
        tinsert(listItems, button)
        button:SetText(L[name])

        button.module = "UnitFrames"
        button.id = name
        button.ownerName = L[owner]
        button.owner = sub:lower()
        button.target = _G["BFI_" .. sub]

        if name == "general" then
            button.cfg = cfg.general
        else
            button.cfg = cfg.indicators[name]
            button:SetTextColor(button.cfg.enabled and "white" or "disabled")
        end
    end

    list:SetWidgets(listItems)
    AF.CreateButtonGroup(listItems, ListItem_LoadOptions, nil, nil, ListItem_OnEnter, ListItem_OnLeave)

    if lastIndicator then
        for _, item in next, listItems do
            if item.id == lastIndicator then
                item:SilentClick()
                return
            end
        end
    end

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