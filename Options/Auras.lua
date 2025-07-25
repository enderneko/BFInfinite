---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local A = BFI.Auras
---@type AbstractFramework
local AF = _G.AbstractFramework

local aurasPanel

local currentList
local LoadList

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateAurasPanel()
    aurasPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_AurasPanel")
    aurasPanel:SetAllPoints()

    local switch = AF.CreateSwitch(aurasPanel, 550, 20)
    aurasPanel.switch = switch
    AF.SetPoint(switch, "TOPLEFT", 15, -15)
    AF.SetPoint(switch, "TOPRIGHT", -15, -15)
    switch:SetLabels({
        {text = L["Global Blacklist"], value = "blacklist"},
        {text = L["Global Priorities"], value = "priorities"},
        {text = L["Global Colors"], value = "colors"},
    })
    switch:SetOnSelect(LoadList)

    local tip = AF.CreateTipsButton(switch)
    AF.SetPoint(tip, "TOPRIGHT", -2, -2)
    tip:SetTips(L["Global Colors"], L["Currently, these colors are only used for block-type buff indicators on Unit Frames"])
    tip:SetTipsPosition("TOPRIGHT", 2, 3)
    AF.SetFrameLevel(tip, 10)
end

---------------------------------------------------------------------
-- content pane
---------------------------------------------------------------------
local contentPane
local inputBox

local function HideInputBox()
    if inputBox then
        inputBox:Hide()
        inputBox = nil
    end
end

local function ShowInputBox(owner, t)
    HideInputBox()

    inputBox = AF.GetEditBox(contentPane, L["Input Spell ID"], nil, nil, "number")
    inputBox:SetAllPoints(owner)
    inputBox:SetBorderColor("BFI")

    inputBox:SetOnTextChanged(function(spell)
        if not spell then
            AF.Tooltip2:Hide()
            return
        end
        AF.Tooltip2:SetOwner(inputBox, "ANCHOR_NONE")
        AF.Tooltip2:SetSpellByID(spell, true)
        AF.Tooltip2:SetPoint("TOPRIGHT", inputBox, "TOPLEFT", -1, 0)
        AF.Tooltip2:Show()
    end)

    inputBox:SetOnEnterPressed(function(spell)
        if not (spell and AF.SpellExists(spell)) then return end
        if owner.spell then -- edit
            local old = t[owner.spell]
            t[owner.spell] = nil
            t[spell] = old
            LoadList(currentList)
        else -- new
            if currentList == "blacklist" then
                t[spell] = true
            elseif currentList == "priorities" then
                t[spell] = 1
            elseif currentList == "colors" then
                t[spell] = AF.GetColorTable("BFI")
            end
        end
    end)

    inputBox:SetText(owner.spell or "")
end

local function CreateContentPane()
    -- content
    contentPane = AF.CreateFrame(aurasPanel)
    aurasPanel.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", aurasPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    local search = AF.CreateEditBox(contentPane, _G.SEARCH, nil, 20)
    contentPane.search = search

    local reset = AF.CreateButton(contentPane, _G.RESET, "red_hover", 107, 20)
    contentPane.reset = reset
    reset:SetPoint("TOPRIGHT")

    AF.SetPoint(search, "TOPLEFT")
    AF.SetPoint(search, "TOPRIGHT", reset, "TOPLEFT", -7, 0)

    local scroll = AF.CreateScrollGrid(contentPane, nil, 7, 7, 2, 17, nil, 20, 7)
    contentPane.scroll = scroll
    AF.SetPoint(scroll, "TOPLEFT", search, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(scroll, "TOPRIGHT", reset, "BOTTOMRIGHT", 0, -15)

    local addButton = AF.CreateButton(contentPane, nil, "BFI_hover", 150, 20)
    contentPane.addButton = addButton
    addButton:SetTexture(AF.GetIcon("Plus"))
    addButton:EnablePushEffect(false)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local itemPool = AF.CreateObjectPool(function()
    local b = AF.CreateButton(contentPane.scroll, nil, "BFI_hover")
    b:SetTexture(AF.GetIcon("QuestionMark"), nil, {"LEFT", 2, 0}, nil, "black")
    b:EnablePushEffect(false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b:SetOnClick(function(_, button)
        if button == "LeftButton" then
            ShowInputBox(b, A.config[currentList])
        elseif button == "RightButton" then
        end
    end)

    return b
end, function(_, b)
    b:Hide()
    b.spell = nil
    b.priority = nil
end)

LoadList = function(which)
    currentList = which

    local items = {}
    local t = A.config[which]

    for spell, v in next, t do
        local b = itemPool:Acquire()
        tinsert(items, b)

        b.spell = spell
        if which == "priorities" then
            b.priority = v
        end

        local name, icon = AF.GetSpellInfo(spell, true)
        b:SetText(name)
        b:SetTexture(icon, nil, nil, nil, "black")
    end

    if which == "priorities" then
        AF.Sort(items, "priority", "ascending", "spell", "ascending")
    else
        AF.Sort(items, spell, "ascending")
    end

    tinsert(items, 1, contentPane.addButton)

    contentPane.scroll:SetWidgets(items)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Auras" then
        if not aurasPanel then
            CreateAurasPanel()
            CreateContentPane()
            aurasPanel.switch:SetSelectedValue("blacklist")
        end
        aurasPanel:Show()
    elseif aurasPanel then
        aurasPanel:Hide()
    end
end)