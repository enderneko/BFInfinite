---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
local E = BFI.modules.Enhancements
---@type AbstractFramework
local AF = _G.AbstractFramework

local LoadOptions

---------------------------------------------------------------------
-- enhancements panel
---------------------------------------------------------------------
local enhancementsPanel
local function CreateEnhancementsPanel()
    enhancementsPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_EnhancementsPanel")
    enhancementsPanel:SetAllPoints()
end

---------------------------------------------------------------------
-- content pane
---------------------------------------------------------------------
local contentPane
local function CreateContentPane()
    -- content
    contentPane = AF.CreateFrame(enhancementsPanel)
    enhancementsPanel.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", 15, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    -- list
    local list = AF.CreateScrollList(contentPane, nil, 0, 0, 28, 20, -1)
    -- local list = AF.CreateScrollList(contentPane, nil, 0, 0, 14, 39, -1)
    contentPane.list = list
    list:SetPoint("TOPLEFT")
    AF.SetWidth(list, 150)
    list:SetupButtonGroup("BFI_transparent", LoadOptions, nil, nil, nil, function(b, data)
        b.ownerName = data.text
        b.cfg = E.config[data.id]
        b:SetTextColor(b.cfg.enabled and "white" or "disabled")
    end)
    list:SetData({
        {text = L["Equipment Info"], id = "equipmentInfo"},
    })

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
local lastSelf

LoadOptions = function(self)
    lastSelf = self

    local scroll = contentPane.scrollSettings
    local options = F.GetEnhancementOptions(scroll.scrollContent, self)

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
    if which ~= "enhancements" or not contentPane then return end
    lastSelf:SetTextColor(lastSelf.cfg.enabled and "white" or "disabled")
    LoadOptions(lastSelf)
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "enhancements" then
        if not enhancementsPanel then
            CreateEnhancementsPanel()
            CreateContentPane()
            contentPane.list:Select("equipmentInfo")
        end
        enhancementsPanel:Show()
    elseif enhancementsPanel then
        enhancementsPanel:Hide()
    end
end)