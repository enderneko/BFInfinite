---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local actionBarsPanel
local LoadOptions

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateActionBarsPanel()
    actionBarsPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_ActionBarsPanel")
    actionBarsPanel:SetAllPoints()
end

---------------------------------------------------------------------
-- content pane
---------------------------------------------------------------------
local contentPane
local function CreateContentPane()
    -- content
    contentPane = AF.CreateFrame(actionBarsPanel)
    actionBarsPanel.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", 15, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    -- list
    local list = AF.CreateScrollList(contentPane, nil, 0, 0, 28, 20, -1)
    contentPane.list = list
    list:SetPoint("TOPLEFT")
    AF.SetWidth(list, 150)

    -- scroll
    local scrollSettings = AF.CreateScrollFrame(contentPane, nil, nil, nil, "none", "none")
    scrollSettings.scrollBar:SetBackdropBorderColor(AF.GetColorRGB("border"))
    contentPane.scrollSettings = scrollSettings
    AF.SetPoint(scrollSettings, "TOPLEFT", list, "TOPRIGHT", 15, 0)
    AF.SetPoint(scrollSettings, "BOTTOM", list)
    AF.SetPoint(scrollSettings, "RIGHT")
    scrollSettings:SetScrollStep(50)

    AF.ApplyCombatProtectionToFrame(scrollSettings.scrollContent, 0, 0, 0, 0)

    -- fill list
    local items = {
        {text = L["General"], value = "general"},
        {text = _G.ASSISTED_COMBAT_LABEL, value = "assistant", enabled = true},
        {text = L["Cooldowns"], value = "cooldowns"},
        {text = L["Action Bar %d"]:format(1), value = "bar1", page = 1},
        {text = L["Action Bar %d"]:format(2), value = "bar2", page = 6},
        {text = L["Action Bar %d"]:format(3), value = "bar3", page = 5},
        {text = L["Action Bar %d"]:format(4), value = "bar4", page = 3},
        {text = L["Action Bar %d"]:format(5), value = "bar5", page = 4},
        {text = L["Action Bar %d"]:format(6), value = "bar6", page = 13},
        {text = L["Action Bar %d"]:format(7), value = "bar7", page = 14},
        {text = L["Action Bar %d"]:format(8), value = "bar8", page = 15},
        {text = L["Action Bar %d"]:format(9), value = "bar9", page = 2},
        {text = L["Class Bar %d"]:format(1), value = "classbar1", page = 7},
        {text = L["Class Bar %d"]:format(2), value = "classbar2", page = 8},
        {text = L["Class Bar %d"]:format(3), value = "classbar3", page = 9},
        {text = L["Class Bar %d"]:format(4), value = "classbar4", page = 10},
        {text = L["Pet Bar"], value = "petbar"},
        {text = L["Stance Bar"], value = "stancebar"},
        {text = _G.HUD_EDIT_MODE_VEHICLE_LEAVE_BUTTON_LABEL, value = "vehicle"},
        {text = L["Extra Ability Buttons"], value = "extra"},
    }

    local widgets = {}
    for _, item in next, items do
        local button = AF.CreateButton(list, item.text, "BFI_transparent", nil, nil, nil, "none", "")
        tinsert(widgets, button)
        button:EnablePushEffect(false)
        button:SetTextJustifyH("LEFT")

        button.id = item.value -- for button group & BFI_UpdateModule
        button.ownerName = item.text

        if item.value == "general" then
            button.setting = "general"
            button.cfg = AB.config.general
            button.sharedCfg = AB.config.sharedButtonConfig
        elseif item.value == "cooldowns" then
            -- TODO:
            button.setting = "cooldowns"
            button.cfg = {}
            button:SetEnabled(false)
        elseif item.value == "assistant" then
            button.setting = "assistant"
            button.cfg = AB.config.assistant
        elseif item.value == "vehicle" then
            button.setting = "vehicle"
            button.cfg = AB.config.vehicleExitButton
        elseif item.value == "extra" then
            button.setting = "extra"
            button.cfg = AB.config.extraAbilityButtons
        else
            button.setting = "bar"
            button.target = AB.bars[item.value]
            button.cfg = AB.config.barConfig[item.value]
        end

        button:SetTextColor((button.cfg.enabled or item.enabled) and "white" or "disabled")

        if item.page then
            button.page = AF.CreateFontString(button, "[" .. item.page .. "]", "disabled")
            AF.SetPoint(button.page, "RIGHT", -5, 0)
        end
    end
    list:SetWidgets(widgets)
    AF.CreateButtonGroup(widgets, LoadOptions)

    -- load general
    widgets[1]:SilentClick()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local lastSelf

LoadOptions = function(self)
    lastSelf = self

    local scroll = contentPane.scrollSettings
    local options = F.GetActionBarOptions(scroll.scrollContent, self)

    local heights = {}
    local last

    for i, pane in next, options do
        pane.index = i

        -- FIXME: seems cause weird issues that option values are not loaded properly (invisible)
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

AF.RegisterCallback("BFI_RefreshOptions", function(_, which)
    if which ~= "actionBars" or not contentPane then return end
    for _, button in next, contentPane.list:GetWidgets() do
        -- refresh cfg
        -- if button.id == "general" then
        --     button.cfg = AB.config.general
        --     button.sharedCfg = AB.config.sharedButtonConfig
        -- elseif button.id == "vehicle" then
        --     button.cfg = AB.config.vehicleExitButton
        -- elseif button.id == "extra" then
        --     button.cfg = AB.config.extraAbilityButtons
        -- else
        --     button.cfg = AB.config.barConfig[button.id]
        -- end
        button:SetTextColor(button.cfg.enabled and "white" or "disabled")
    end
    LoadOptions(lastSelf)
end)


---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "actionBars" then
        if not actionBarsPanel then
            CreateActionBarsPanel()
            CreateContentPane()
        end
        actionBarsPanel:Show()
    elseif actionBarsPanel then
        actionBarsPanel:Hide()
    end
end)