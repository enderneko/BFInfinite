local addonName, ns = ...
local AW = ns.AW

function AW.CreateEditBox(parent, label, width, height, isTransparent, isMultiLine, isNumeric, font)
    local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    
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
        if not isTransparent then
            eb:SetBackdropBorderColor(0, 0, 0, 0.5)
        end
    end)
    
    eb:SetScript("OnEnable", function()
        eb:SetTextColor(1, 1, 1, 1)
        if not isTransparent then
            eb:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end)

    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        if strtrim(text) == "" then
            eb.label:Show()
        else
            eb.label:Hide()
        end
    end)

    if not isTransparent then
        AW.StylizeFrame(eb, "button")
        
        eb.onEnter = function()
            if not eb:IsEnabled() then return end
            eb:SetBackdropColor(AW.GetColorRGB("accent", 0.1))
        end
        
        eb.onLeave = function()
            eb:SetBackdropColor(AW.GetColorRGB("button"))
        end

        eb:SetScript("OnEnter", eb.onEnter)
        eb:SetScript("OnLeave", eb.onLeave)
    end

    function eb:UpdatePixels()
        AW.ReSize(eb)
        AW.RePoint(eb)
        if not isTransparent then AW.ReBorder(eb) end
    end

    AW.AddToPixelUpdater(eb)
    
    return eb
end