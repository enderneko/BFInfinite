---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local unitFramesPanel
local LoadList, curMain, curSub

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
        extra = {"Party Pets", "Party Targets"},
    }

    local subItems = {}
    local lastSelected = {}

    local mainSwitch = AF.CreateSwitch(unitFramesPanel, 300, 20)
    unitFramesPanel.mainSwitch = mainSwitch
    AF.SetPoint(mainSwitch, "TOPLEFT", 15, -15)
    -- AF.SetPoint(mainSwitch, "TOPRIGHT")

    local subSwitch = AF.CreateSwitch(unitFramesPanel, nil, 20)
    unitFramesPanel.subSwitch = subSwitch
    AF.SetPoint(subSwitch, "TOPLEFT", mainSwitch, "BOTTOMLEFT", 0, -10)
    AF.SetPoint(subSwitch, "RIGHT", unitFramesPanel, -15, 0)

    mainSwitch:SetLabels({
        {text = "Unit", value = "unit"},
        {text = "Target", value = "target"},
        {text = "Group", value = "group"},
        {text = "Extra", value = "extra", disabled = true},
    })

    mainSwitch:SetOnSelect(function(value)
        if not subItems[value] then
            for _, name in pairs(subs[value]) do
                subItems[value] = subItems[value] or {}
                tinsert(subItems[value], {text = L[name], value = name, disabled = name == "Arena"})
            end
        end

        subSwitch:SetLabels(subItems[value])
        subSwitch:SetSelectedValue(lastSelected[value] or subs[value][1])
    end)

    subSwitch:SetOnSelect(function(value)
        lastSelected[mainSwitch:GetSelectedValue()] = value
        LoadList(mainSwitch:GetSelectedValue(), value)
    end)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function CreateConfigModeWidgets()
    --------------------------------------------------
    -- config mode frame
    --------------------------------------------------
    local configModeFrame = AF.CreateBorderedFrame(unitFramesPanel, nil, nil, 263)
    unitFramesPanel.configModeFrame = configModeFrame
    AF.SetPoint(configModeFrame, "TOPLEFT", unitFramesPanel, "TOPRIGHT", 5, -15)
    configModeFrame:Hide()

    local groups = {
        "Player", "Target", "Focus", "Pet",
        "Target Target", "Focus Target", "Pet Target",
        "Party", "Raid", "Boss", "Arena"
    }

    local checkButtons = {}

    local all = AF.CreateCheckButton(configModeFrame, _G.ALL)
    AF.SetPoint(all, "TOPLEFT", 7, -7)
    all:SetOnCheck(function(checked)
        for check in next, checkButtons do
            if checked then
                check:SetTextColor("white")
            else
                check:SetTextColor("gray")
            end
            check:SetChecked(checked)
        end
        AF.Fire("BFI_ConfigMode", "unitFrames", nil, checked)
    end)

    local sep = AF.CreateSeparator(configModeFrame, nil, 1, AF.GetColorTable("BFI", 0.8))
    AF.SetPoint(sep, "TOPLEFT", all, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(sep, "RIGHT", -7, 0)

    local function OnCheck(checked, self)
        if checked then
            self:SetTextColor("white")
        else
            self:SetTextColor("gray")
        end

        local allChecked = true
        for check in next, checkButtons do
            if not check:GetChecked() then
                allChecked = false
                break
            end
        end
        all:SetChecked(allChecked)

        AF.Fire("BFI_ConfigMode", "unitFrames", checkButtons[self], checked)
    end

    local width = 0
    local last
    for _, group in next, groups do
        local check = AF.CreateCheckButton(configModeFrame, L[group])

        -- TODO: arena
        if group == "Arena" then
            check:SetEnabled(false)
        else
            checkButtons[check] = group:gsub(" ", ""):lower()
            check:SetTextColor("gray")
            check:SetOnCheck(OnCheck)
        end

        if last then
            AF.SetPoint(check, "TOPLEFT", last, "BOTTOMLEFT", 0, -7)
        else
            AF.SetPoint(check, "TOPLEFT", all, "BOTTOMLEFT", 0, -11)
        end
        last = check
        width = max(width, check.label:GetStringWidth() + 35)
    end

    configModeFrame:SetWidth(width)

    --------------------------------------------------
    -- config mode button
    --------------------------------------------------
    local ON = L["Config Mode"] .. ": " .. AF.UpperFirst(SLASH_TEXTTOSPEECH_ON)
    local OFF = L["Config Mode"] .. ": " .. AF.UpperFirst(SLASH_TEXTTOSPEECH_OFF)

    local configModeButton = AF.CreateButton(unitFramesPanel, OFF, "BFI_hover", nil, 20)
    AF.SetPoint(configModeButton, "TOPLEFT", unitFramesPanel.mainSwitch, "TOPRIGHT", 10, 0)
    AF.SetPoint(configModeButton, "RIGHT", -15, 0)
    AF.ApplyCombatProtectionToWidget(configModeButton)

    local function DisableConfigMode()
        UF.configModeEnabled = false

        AF.FlowText_Stop(configModeButton.text)
        configModeButton:SetText(OFF)
        configModeFrame:Hide()

        UF:UnregisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
        AF.Fire("BFI_ConfigMode", "unitFrames", nil, false)
    end

    local function EnableConfigMode()
        UF.configModeEnabled = true

        configModeButton:SetText(ON)
        AF.FlowText_Start(configModeButton.text, "BFI", "white", 2)
        configModeFrame:Show()

        UF:RegisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)

        if all:GetChecked() then
            AF.Fire("BFI_ConfigMode", "unitFrames", nil, true)
        else
            for check, group in next, checkButtons do
                if check:GetChecked() then
                    AF.Fire("BFI_ConfigMode", "unitFrames", group, true)
                end
            end
        end
    end

    configModeButton:SetOnClick(function()
        UF.configModeEnabled = not UF.configModeEnabled
        if UF.configModeEnabled then
            EnableConfigMode()
        else
            DisableConfigMode()
        end
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
    AF.SetPoint(contentPane, "TOPLEFT", unitFramesPanel.subSwitch, "BOTTOMLEFT", 0, -10)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    -- indicator list
    local indicatorList = AF.CreateScrollList(contentPane, nil, 0, 0, 25, 20, -1)
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
-- settings
---------------------------------------------------------------------
local settings = {
    unit = {
        player = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar", "extraManaBar", "classPowerBar", "staggerBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "incDmgHealText",
            "buffs", "debuffs", -- "privateAuras",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon", "restingIndicator",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        target = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "rangeText",
            "buffs", "debuffs", -- "privateAuras",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "factionIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        focus = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter", "rangeText",
            "buffs", "debuffs", -- "privateAuras",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        pet = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "combatIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
    },
    target = {
        targettarget = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        focustarget = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        pettarget = {
            "general_single",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon", "roleIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
    },
    group = {
        party = {
            "general_party",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer",
            "buffs", "debuffs",
            "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        raid = {
            "general_raid",
            "healthBar", "powerBar",
            "nameText", "healthText", "statusTimer",
            "buffs", "debuffs",
            "raidIcon", "leaderIcon", "roleIcon", "readyCheckIcon", "statusIcon",
            "targetHighlight", "mouseoverHighlight", "threatGlow",
        },
        boss = {
            "general_boss",
            "healthBar", "powerBar", "portrait", "castBar",
            "nameText", "healthText", "powerText", "levelText", "targetCounter",
            "buffs", "debuffs",
            "raidIcon",
            "targetHighlight", "mouseoverHighlight",
        },
        -- arena = {
        -- },
    },
}

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local listItems = {}
local lastIndicator, lastScroll

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

    lastIndicator = self.id

    local scroll = contentPane.scrollSettings
    local options = F.GetUnitFrameOptions(scroll.scrollContent, self)

    local heights = {}
    local last

    for i, pane in next, options do
        pane.index = i -- for re-height

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
    C_Timer.After(0, function()
        for _, pane in next, options do
            pane.Load(self)
        end
    end)
end

LoadList = function(main, sub)
    curMain, curSub = main, sub

    local list = contentPane.indicatorList
    list:Reset()
    itemPool:ReleaseAll()
    wipe(listItems)

    local owner = sub
    sub = sub:gsub(" ", "")

    local lowerSub = sub:lower()

    local cfg = BFI.vars.profile.unitFrames[lowerSub]

    for i, setting in next, settings[main][lowerSub] do
        local button = itemPool:Acquire()
        tinsert(listItems, button)

        if setting:find("^general") then
            button:SetText(L["General"])
            button.cfg = cfg.general
            button:SetTextColor("white")
        else
            button:SetText(L[setting])
            button.cfg = cfg.indicators[setting]
            button:SetTextColor(button.cfg.enabled and "white" or "disabled")
        end

        button.id = setting
        button.ownerName = L[owner]
        button.owner = lowerSub
        button.target = _G["BFI_" .. sub]
    end

    list:SetWidgets(listItems)
    AF.CreateButtonGroup(listItems, ListItem_LoadOptions, nil, nil, ListItem_OnEnter, ListItem_OnLeave)

    if lastIndicator then
        for i, item in next, listItems do
            if item.id == lastIndicator then
                item:SilentClick()
                if lastScroll then
                    contentPane.indicatorList:SetScroll(lastScroll)
                    lastScroll = nil
                else
                    contentPane.indicatorList:ScrollTo(i)
                end
                return
            end
        end
    end

    listItems[1]:SilentClick()
end

AF.RegisterCallback("BFI_RefreshOptions", function(_, which)
    if which ~= "unitFrames" or not contentPane then return end
    lastScroll = contentPane.indicatorList:GetScroll()
    LoadList(curMain, curSub) -- will load lastIndicator
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Unit Frames" then
        if not unitFramesPanel then
            CreateUnitFramesPanel()
            CreateConfigModeWidgets()
            CreateContentPane()
            unitFramesPanel.mainSwitch:SetSelectedValue("unit")
        end
        unitFramesPanel:Show()
    elseif unitFramesPanel then
        unitFramesPanel:Hide()
    end
end)