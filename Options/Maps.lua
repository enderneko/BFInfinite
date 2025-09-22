---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local F = BFI.funcs
local M = BFI.modules.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local LoadList, LoadOptions
local currentMap
local minimapLast, worldmapLast

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local mapsPanel

local function CreateMapsPanel()
    mapsPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_MapsPanel")
    mapsPanel:SetAllPoints()

    local switch = AF.CreateSwitch(mapsPanel, nil, 20)
    mapsPanel.switch = switch
    AF.SetPoint(switch, "TOPLEFT", 15, -15)
    AF.SetPoint(switch, "TOPRIGHT", -15, -15)
    switch:SetLabels({
        {text = _G.MINIMAP_LABEL, value = "minimap"},
        {text = _G.WORLDMAP_BUTTON, value = "worldmap", disabled = true},
    })
    switch:SetOnSelect(LoadList)
end

---------------------------------------------------------------------
-- content pane
---------------------------------------------------------------------
local contentPane

local function CreateContentPane()
    contentPane = AF.CreateFrame(mapsPanel)
    AF.SetPoint(contentPane, "TOPLEFT", mapsPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    -- list
    local list = AF.CreateScrollList(contentPane, nil, 0, 0, 26, 20, -1)
    contentPane.list = list
    list:SetPoint("TOPLEFT")
    AF.SetWidth(list, 150)
    list:SetupButtonGroup("BFI_transparent", LoadOptions, nil, nil, nil, function(b, data)
        b.ownerName = data.text
        if data.id:find("^general") then
            b.cfg = M.config[currentMap].general
        else
            b.cfg = M.config[currentMap][data.id]
        end
        b.map = currentMap
        b:SetTextColor(b.cfg.enabled and "white" or "disabled")
        b.combatProtect = data.combatProtect
    end)

    -- scroll
    local scrollSettings = AF.CreateScrollFrame(contentPane, nil, nil, nil, "none", "none")
    scrollSettings.scrollBar:SetBackdropBorderColor(AF.GetColorRGB("border"))
    contentPane.scrollSettings = scrollSettings
    AF.SetPoint(scrollSettings, "TOPLEFT", list, "TOPRIGHT", 15, 0)
    AF.SetPoint(scrollSettings, "BOTTOM", list)
    AF.SetPoint(scrollSettings, "RIGHT")
    scrollSettings:SetScrollStep(50)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local lastScroll

LoadList = function(which)
    currentMap = which
    local list = contentPane.list

    if which == "minimap" then
        list:SetData({
            {text = L["General"], id = "general_minimap"},
            {text = _G.MAIL_LABEL, id = "mailFrame"},
            {text = L["Crafting Order"], id = "craftingOrderFrame"},
            {text = L["Calendar"], id = "calendar"},
            {text = _G.TIMEMANAGER_TITLE, id = "clock"},
            {text = L["Zone Text"], id = "zoneText"},
            {text = L["Coordinates"], id = "coordinates"},
            {text = L["Instance Difficulty"], id = "instanceDifficulty"},
            {text = L["Expansion Button"], id = "expansionButton"},
            {text = L["Tracking Button"], id = "trackingButton"},
            {text = L["Addon Button Tray"], id = "addonButtonTray"},
        })
        list:Select(minimapLast or "general_minimap")
    else
        list:SetData({
        })
        list:Select(worldmapLast or "general")
    end

    if lastScroll then
        list:ScrollTo(lastScroll)
        lastScroll = nil
    end
end

LoadOptions = function(self)
    if currentMap == "minimap" then
        minimapLast = self.id
    elseif currentMap == "worldmap" then
        worldmapLast = self.id
    end

    local scroll = contentPane.scrollSettings
    local options = F.GetMapOptions(scroll.scrollContent, self)

    if self.combatProtect then
        AF.ApplyCombatProtectionToFrame(scroll.scrollContent, 0, 0, 0, 0)
    else
        AF.RemoveCombatProtectionFromFrame(scroll.scrollContent)
    end

    local heights = {}
    local last

    for i, pane in next, options do
        pane.index = i

        if last then
            AF.SetPoint(pane, "TOPLEFT", last, "BOTTOMLEFT", 0, -10)
        else
            AF.SetPoint(pane, "TOPLEFT", scroll.scrollContent)
        end
        AF.SetPoint(pane, "RIGHT", scroll.scrollContent)

        last = pane
        tinsert(heights, pane._height or tostring(pane:GetHeight()))
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
    if which ~= "maps" or not contentPane then return end
    lastScroll = contentPane.list:GetScroll()
    LoadList(currentMap)
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Maps" then
        if not mapsPanel then
            CreateMapsPanel()
            CreateContentPane()
            mapsPanel.switch:SetSelectedValue("minimap")
        end
        mapsPanel:Show()
    elseif mapsPanel then
        mapsPanel:Hide()
    end
end)