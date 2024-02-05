local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- dialog
---------------------------------------------------------------------
local dialog

local function CreateDialog()
    dialog = AW.CreateBorderedFrame(UIParent, nil, 200, 100, nil, "accent")
    dialog:Hide() -- for first OnShow

    dialog:EnableMouse(true)
    dialog:SetClampedToScreen(true)

    -- text holder
    local textHolder = AW.CreateFrame(dialog)
    dialog.textHolder = textHolder
    AW.SetPoint(textHolder, "TOPLEFT", 7, -7)
    AW.SetPoint(textHolder, "TOPRIGHT", -7, -7)

    local text = AW.CreateFontString(textHolder)
    dialog.text = text
    AW.SetPoint(text, "TOPLEFT")
    AW.SetPoint(text, "TOPRIGHT")
    text:SetWordWrap(true)
    text:SetSpacing(3)

    -- frame holder
    local contentHolder = AW.CreateFrame(dialog)
    dialog.contentHolder = contentHolder
    AW.SetPoint(contentHolder, "TOPLEFT", textHolder, "BOTTOMLEFT", 7, -7)
    AW.SetPoint(contentHolder, "TOPRIGHT", textHolder, "BOTTOMRIGHT", -7, -7)

    -- no
    local no = AW.CreateButton(dialog, _G.NO, "red", 50, 17)
    dialog.no = no
    AW.SetPoint(no, "BOTTOMRIGHT")
    no:SetBackdropBorderColor(AW.GetColorRGB("accent"))
    AW.ClearPoints(no.text)
    AW.SetPoint(no.text, "CENTER")
    no:SetScript("OnClick", function()
        if dialog.onCancel then dialog.onCancel() end
        dialog:Hide()
    end)

    -- yes
    local yes = AW.CreateButton(dialog, _G.YES, "green", 50, 17)
    dialog.yes = yes
    AW.SetPoint(yes, "BOTTOMRIGHT", no, "BOTTOMLEFT", 1, 0)
    yes:SetBackdropBorderColor(AW.GetColorRGB("accent"))
    AW.ClearPoints(yes.text)
    AW.SetPoint(yes.text, "CENTER")
    yes:SetScript("OnClick", function()
        if dialog.onConfirm then dialog.onConfirm() end
        dialog:Hide()
    end)

    -- OnHide
    dialog:SetScript("OnHide", function()
        dialog:Hide()
        
        -- reset
        dialog.minButtonWidth = nil
        dialog.onConfirm = nil
        dialog.onCancel = nil
        
        -- reset text
        text:SetText()
        textHolder:SetHeight(0)
        
        -- reset content
        if dialog.content then
            dialog.content:ClearAllPoints()
            dialog.content:Hide()
            dialog.content = nil
        end
        contentHolder:SetHeight(0)
        
        -- reset button
        yes:SetEnabled(true)
        yes:SetText(_G.YES)
        AW.SetWidth(yes, 50)
        no:SetText(_G.NO)
        AW.SetWidth(no, 50)
        
        -- hide mask
        if dialog.shownMask then
            dialog.shownMask:Hide()
            dialog.shownMask = nil
        end
    end)

    -- OnShow
    dialog:SetScript("OnShow", function()
        dialog:SetScript("OnUpdate", function()
            if text:GetText() then
                --! NOTE: text width must be set, and its x/y offset should be 0 (not sure), or WEIRD ISSUES would a appear.
                text:SetWidth(Round(dialog:GetWidth()-14))
                textHolder:SetHeight(Round(text:GetHeight()))
            end
            if dialog.content then
                contentHolder:SetHeight(Round(dialog.content:GetHeight()))
            end
            dialog:SetHeight(Round(textHolder:GetHeight()+contentHolder:GetHeight())+40)
            dialog:SetScript("OnUpdate", nil)
        end)
    end)

    -- update pixels
    function dialog:UpdatePixels()
        print("dialog:UpdatePixels")
        AW.ReSize(dialog)
        AW.RePoint(dialog)
        AW.ReBorder(dialog)

        if dialog:IsShown() then
            dialog:GetScript("OnShow")()
        end
        
        if dialog.minButtonWidth then
            AW.ResizeDialogButtonToFitText(dialog.minButtonWidth)
        end
    end
end

-- show
function AW.ShowDialog(parent, text, width, yesText, noText, showMask, content, yesDisabled)
    if not dialog then CreateDialog() end

    dialog:SetParent(parent)
    dialog:SetFrameLevel(parent:GetFrameLevel()+50) -- mask:30 < level < combatMask:100
    AW.SetWidth(dialog, width)

    dialog.text:SetText(text)

    if yesText then dialog.yes:SetText(yesText) end
    if noText then dialog.no:SetText(noText) end

    if showMask then
        dialog.shownMask = AW.ShowMask(parent)
    end

    if content then
        dialog.content = content
        content:SetPoint("TOPLEFT")
        content:SetPoint("TOPRIGHT")
        content:Show()
    end

    if yesDisabled then
        dialog.yes:SetEnabled(false)
    end

    dialog:Show()

    return dialog
end

-- point
function AW.SetDialogPoint(...)
    AW.ClearPoints(dialog)
    AW.SetPoint(dialog, ...)
end

-- resize yes/no
function AW.ResizeDialogButtonToFitText(minWidth)
    dialog.minButtonWidth = minWidth or 0
    local yesWidth = Round(dialog.yes.text:GetWidth())+10
    local noWidth = Round(dialog.no.text:GetWidth())+10
    if minWidth then
        yesWidth = max(minWidth, yesWidth)
        noWidth = max(minWidth, noWidth)
    end
    dialog.yes:SetWidth(yesWidth)
    dialog.no:SetWidth(noWidth)
end

-- content in contentHolder
function AW.CreateDialogContent()
    if not dialog then CreateDialog() end
    local f = AW.CreateFrame(dialog.contentHolder)
    f.dialog = dialog
    return f
end

-- onConfirm
function AW.SetDialogOnConfirm(fn)
    dialog.onConfirm = fn
end

-- onCancel
function AW.SetDialogOnCancel(fn)
    dialog.onCancel = fn
end