local addonName, ns = ...
local AW = ns.AW

function AW.CreateEditBox(parent, label, width, height, isMultiLine, isNumeric, font)
    local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    
    AW.StylizeFrame(eb, "widget")
    AW.SetWidth(eb, width or 40)
    AW.SetHeight(eb, height or 20)

    eb.label = AW.CreateFontString(eb, label, nil, "normal", true)
    eb.label:SetPoint("LEFT", 4, 0)
    
    eb:SetMultiLine(isMultiLine)
    eb:SetNumeric(isNumeric)
    eb:SetFontObject(font or AW.GetFont("normal"))
    eb:SetMaxLetters(0)
    eb:SetJustifyH("LEFT")
    eb:SetJustifyV("MIDDLE")
    eb:SetTextInsets(4, 4, 0, 0)
    eb:SetAutoFocus(false)

    eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)
    eb:SetScript("OnEnterPressed", function() eb:ClearFocus() end)
    eb:SetScript("OnEditFocusGained", function() eb:HighlightText() end)
    eb:SetScript("OnEditFocusLost", function() eb:HighlightText(0, 0) end)
    
    eb:SetScript("OnDisable", function()
        eb:SetTextColor(AW.GetColorRGB("disabled"))
        eb:SetBackdropBorderColor(0, 0, 0, 0.5)
    end)
    
    eb:SetScript("OnEnable", function()
        eb:SetTextColor(1, 1, 1, 1)
        eb:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        if strtrim(text) == "" then
            eb.label:Show()
        else
            eb.label:Hide()
        end
    end)

    eb.highlight = AW.CreateTexture(eb, nil, AW.GetColorTable("accent", 0.07))
    AW.SetPoint(eb.highlight, "TOPLEFT", 1, -1)
    AW.SetPoint(eb.highlight, "BOTTOMRIGHT", -1, 1)
    eb.highlight:Hide()

    eb:SetScript("OnEnter", function()
        if not eb:IsEnabled() then return end
        eb.highlight:Show()
    end)

    eb:SetScript("OnLeave", function()
        if not eb:IsEnabled() then return end
        eb.highlight:Hide()
    end)

    function eb:UpdatePixels()
        AW.ReSize(eb)
        AW.RePoint(eb)
        AW.ReBorder(eb)
    end

    AW.AddToPixelUpdater(eb)
    
    return eb
end