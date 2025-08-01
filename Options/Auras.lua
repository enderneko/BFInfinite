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

    local switch = AF.CreateSwitch(aurasPanel, nil, 20)
    aurasPanel.switch = switch
    AF.SetPoint(switch, "TOPLEFT", 15, -15)
    AF.SetPoint(switch, "TOPRIGHT", -15, -15)
    switch:SetLabels({
        {text = L["Global Blacklist"], value = "blacklist"},
        {text = L["Global Priorities"], value = "priorities"},
        {text = L["Global Colors"], value = "colors"},
    })
    switch:SetOnSelect(function(value)
        aurasPanel.contentPane.search:Clear()
        LoadList(value)
    end)

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
local inputBox, dialog

local function HideInputBox()
    if inputBox then
        inputBox:Hide()
        inputBox = nil
    end
end

local function ShowInputBox(owner)
    HideInputBox()

    local t = A.config[currentList]

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
        else -- new
            if currentList == "blacklist" then
                t[spell] = true
            elseif currentList == "priorities" then
                t[spell] = 1
            elseif currentList == "colors" then
                t[spell] = AF.GetColorTable("BFI")
            end
        end
        LoadList(currentList)
        AF.Fire("BFI_UpdateAuras", currentList)
    end)

    inputBox:SetText(owner.spell or "")
end

local function CreateContentPane()
    -- content
    contentPane = AF.CreateFrame(aurasPanel)
    aurasPanel.contentPane = contentPane
    AF.SetPoint(contentPane, "TOPLEFT", aurasPanel.switch, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)

    local search = AF.CreateEditBox(contentPane, _G.SEARCH, nil, 20, "trim")
    contentPane.search = search
    search:SetOnTextChanged(function(text, userChanged)
        if not userChanged then return end
        LoadList(currentList)
    end)

    local reset = AF.CreateButton(contentPane, _G.RESET, "red_hover", 107, 20)
    contentPane.reset = reset
    reset:SetPoint("TOPRIGHT")

    AF.SetPoint(search, "TOPLEFT")
    AF.SetPoint(search, "TOPRIGHT", reset, "TOPLEFT", -7, 0)

    local scroll = AF.CreateScrollGrid(contentPane, nil, 5, 5, 2, 18, nil, 20, 5)
    contentPane.scroll = scroll
    AF.SetPoint(scroll, "TOPLEFT", search, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(scroll, "TOPRIGHT", reset, "BOTTOMRIGHT", 0, -15)

    reset:SetOnClick(function()
        local listName = "Global " .. currentList:gsub("^%l", string.upper)
        dialog = AF.GetDialog(scroll, L["Reset %s?"]:format(L[listName]))
        AF.SetPoint(dialog, "TOP", 0, -30)
        dialog:SetOnConfirm(function()
            search:SetText("")
            wipe(A.config[currentList])
            AF.Merge(A.config[currentList], A.GetDefaults(currentList))
            LoadList(currentList)
            AF.Fire("BFI_UpdateAuras", currentList)
        end)
    end)

    local addButton = AF.CreateButton(contentPane, nil, "BFI_hover", 150, 20)
    contentPane.addButton = addButton
    addButton:SetTexture(AF.GetIcon("Plus"))
    addButton:EnablePushEffect(false)
    addButton:SetOnClick(ShowInputBox)

    local tip = AF.CreateFontString(contentPane, AF.GetIconString("MouseLeftClick") .. L["Edit"] .. "  " .. AF.GetIconString("MouseRightClick") .. L["Delete"])
    AF.SetPoint(tip, "TOPLEFT", scroll, "BOTTOMLEFT", 0, -5)
    tip:SetColor("tip")
end

---------------------------------------------------------------------
-- pools
---------------------------------------------------------------------
local function DeleteItem(owner)
    local t = A.config[currentList]
    t[owner.spell] = nil
    LoadList(currentList)
end

local pools = {}

pools.blacklist = AF.CreateObjectPool(function()
    local b = AF.CreateButton(contentPane.scroll, nil, "BFI_hover")
    b:SetTexture(AF.GetIcon("QuestionMark"), nil, {"LEFT", 2, 0}, nil, "black")
    b:EnablePushEffect(false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b.idText = AF.CreateFontString(b)
    AF.SetPoint(b.idText, "LEFT", b.texture, "RIGHT", 5, 0)
    b.idText:SetWidth(70)
    b.idText:SetJustifyH("LEFT")
    b.idText:SetWordWrap(false)

    b.nameText = AF.CreateFontString(b)
    AF.SetPoint(b.nameText, "LEFT", b.idText, "RIGHT", 5, 0)
    AF.SetPoint(b.nameText, "RIGHT", -5, 0)
    b.nameText:SetJustifyH("LEFT")
    b.nameText:SetWordWrap(false)

    b:SetOnClick(function(_, button)
        if button == "LeftButton" then
            ShowInputBox(b)
        elseif button == "RightButton" then
            DeleteItem(b)
            AF.Fire("BFI_UpdateAuras", currentList)
        end
    end)

    b:HookOnEnter(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:SetOwner(contentPane, "ANCHOR_NONE")
        AF.Tooltip2:SetSpellByID(b.spell, true)
        AF.Tooltip2:SetPoint("TOPRIGHT", b, "TOPLEFT", -1, 0)
        AF.Tooltip2:Show()
    end)

    b:HookOnLeave(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:Hide()
    end)

    return b
end, function(_, b)
    b:Hide()
    b.spell = nil
end)

pools.priorities = AF.CreateObjectPool(function()
    local b = AF.CreateButton(contentPane.scroll, nil, "BFI_hover")
    b:SetTexture(AF.GetIcon("QuestionMark"), nil, {"LEFT", 2, 0}, nil, "black")
    b:EnablePushEffect(false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b.editBox = AF.CreateEditBox(b, nil, 40, 20, "number")
    b.editBox:SetPoint("TOPRIGHT")
    b.editBox:HookOnEnter(b:GetOnEnter())
    b.editBox:HookOnLeave(b:GetOnLeave())
    b.editBox:SetTextColor(AF.GetColorRGB("BFI"))
    b.editBox:SetMaxLetters(3)
    b.editBox:SetOnEnterPressed(function(value, userChanged)
        if not userChanged then return end
        local t = A.config[currentList]
        if not value then
            b.editBox:SetText(t[b.spell])
            return
        end
        t[b.spell] = value
        LoadList(currentList)
        AF.Fire("BFI_UpdateAuras", currentList)
    end)

    b.idText = AF.CreateFontString(b)
    AF.SetPoint(b.idText, "LEFT", b.texture, "RIGHT", 5, 0)
    b.idText:SetWidth(70)
    b.idText:SetJustifyH("LEFT")
    b.idText:SetWordWrap(false)

    b.nameText = AF.CreateFontString(b)
    AF.SetPoint(b.nameText, "LEFT", b.idText, "RIGHT", 5, 0)
    AF.SetPoint(b.nameText, "RIGHT", b.editBox, "LEFT", -3, 0)
    b.nameText:SetJustifyH("LEFT")
    b.nameText:SetWordWrap(false)

    b:SetOnClick(function(_, button)
        if button == "LeftButton" then
            ShowInputBox(b)
        elseif button == "RightButton" then
            DeleteItem(b)
            AF.Fire("BFI_UpdateAuras", currentList)
        end
    end)

    b:HookOnEnter(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:SetOwner(contentPane, "ANCHOR_NONE")
        AF.Tooltip2:SetSpellByID(b.spell, true)
        AF.Tooltip2:SetPoint("TOPRIGHT", b, "TOPLEFT", -1, 0)
        AF.Tooltip2:Show()
    end)

    b:HookOnLeave(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:Hide()
    end)

    return b
end, function(_, b)
    b:Hide()
    b.spell = nil
    b.priority = nil
end)

pools.colors = AF.CreateObjectPool(function()
    local b = AF.CreateButton(contentPane.scroll, nil, "BFI_hover")
    b:SetTexture(AF.GetIcon("QuestionMark"), nil, {"LEFT", 2, 0}, nil, "black")
    b:EnablePushEffect(false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b.colorPicker = AF.CreateColorPicker(b, nil, true)
    b.colorPicker:SetPoint("RIGHT", -3, 0)
    b.colorPicker:HookOnEnter(b:GetOnEnter())
    b.colorPicker:HookOnLeave(b:GetOnLeave())
    b.colorPicker:SetOnConfirm(function(_r, _g, _b, _a)
        local t = A.config[currentList]
        t[b.spell][1] = _r
        t[b.spell][2] = _g
        t[b.spell][3] = _b
        t[b.spell][4] = _a
        AF.Fire("BFI_UpdateAuras", currentList)
    end)

    b.idText = AF.CreateFontString(b)
    AF.SetPoint(b.idText, "LEFT", b.texture, "RIGHT", 5, 0)
    b.idText:SetWidth(70)
    b.idText:SetJustifyH("LEFT")
    b.idText:SetWordWrap(false)

    b.nameText = AF.CreateFontString(b)
    AF.SetPoint(b.nameText, "LEFT", b.idText, "RIGHT", 5, 0)
    AF.SetPoint(b.nameText, "RIGHT", b.colorPicker, "LEFT", -3, 0)
    b.nameText:SetJustifyH("LEFT")
    b.nameText:SetWordWrap(false)

    b:SetOnClick(function(_, button)
        if button == "LeftButton" then
            ShowInputBox(b)
        elseif button == "RightButton" then
            DeleteItem(b)
            AF.Fire("BFI_UpdateAuras", currentList)
        end
    end)

    b:HookOnEnter(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:SetOwner(contentPane, "ANCHOR_NONE")
        AF.Tooltip2:SetSpellByID(b.spell, true)
        AF.Tooltip2:SetPoint("TOPRIGHT", b, "TOPLEFT", -1, 0)
        AF.Tooltip2:Show()
    end)

    b:HookOnLeave(function()
        if inputBox and inputBox:IsShown() then return end
        AF.Tooltip2:Hide()
    end)

    return b
end, function(_, b)
    b:Hide()
    b.spell = nil
end)

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
LoadList = function(which)
    if dialog and AF.IsDialogActive(dialog) and dialog:GetParent() == contentPane.scroll then
        dialog:Hide()
        dialog = nil
    end

    currentList = which

    local items = {}
    local t = A.config[which]
    local search = contentPane.search:GetValue():lower()

    for spell, v in next, t do
        local name, icon = AF.GetSpellInfo(spell, true)
        if AF.IsBlank(search) or name:lower():find(search, 1, true) or tostring(spell):find(search, 1, true) then
            local b = pools[which]:Acquire()
            tinsert(items, b)

            b.spell = spell
            if which == "priorities" then
                b.priority = v
                b.editBox:SetText(v)
            elseif which == "colors" then
                b.colorPicker:SetColor(v)
            end

            b.idText:SetText(spell)
            b.nameText:SetText(name)
            b:SetTexture(icon, nil, nil, nil, "black")
        end
    end

    if which == "priorities" then
        AF.Sort(items, "priority", "ascending", "spell", "ascending")
    else
        AF.Sort(items, "spell", "ascending")
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