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
        eb:SetBackdropBorderColor(0, 0, 0, 0.7)
    end)
    
    eb:SetScript("OnEnable", function()
        eb:SetTextColor(1, 1, 1, 1)
        eb:SetBackdropBorderColor(0, 0, 0, 1)
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

    function eb:SetOnTextChanged(func)
        eb.onTextChanged = func
    end

    eb.value = "" -- init value

    eb:SetScript("OnTextChanged", function(self, userChanged)
        local text = strtrim(eb:GetText())
        if text == "" then
            eb.label:Show()
        else
            eb.label:Hide()
        end

        if userChanged then
            -- NOTE: if confirmBtn is set, onTextChanged will not invoke
            if eb.confirmBtn then
                if eb.value ~= text then
                    eb.confirmBtn:Show()
                else
                    eb.confirmBtn:Hide()
                end
            elseif eb.onTextChanged then
                eb.onTextChanged(text)
                eb.value = text -- update value
            end
        else
            eb.value = text -- update value
        end
    end)

    eb:SetScript("OnHide", function()
        eb:SetText(eb.value) -- restore
    end)

    -- confirm button -----------------------------------------------
    function eb:SetConfirmButton(func, isOutside, text, width)
        eb.confirmBtn = AW.CreateButton(eb, text, "accent", width or 30, 20)
        eb.confirmBtn:Hide()

        if not text then
            eb.confirmBtn:SetTexture(AW.GetIcon("Tick"), {16, 16}, {"CENTER", 0, 0})
        end

        if isOutside then
            AW.SetPoint(eb.confirmBtn, "TOPLEFT", eb, "TOPRIGHT", -1, 0)
        else
            AW.SetPoint(eb.confirmBtn, "TOPRIGHT")
        end

        eb.confirmBtn:SetScript("OnHide", function()
            eb.confirmBtn:Hide()
        end)
        
        eb.confirmBtn:SetScript("OnClick", function()
            local text = strtrim(eb:GetText())
            if func then func(text) end
            eb.value = text -- update value
            eb.confirmBtn:Hide()
            eb:ClearFocus()
        end)
    end
    -----------------------------------------------------------------

    function eb:UpdatePixels()
        AW.ReSize(eb)
        AW.RePoint(eb)
        AW.ReBorder(eb)
        -- eb.confirmBtn:UpdatePixels() already called in pixel updater
    end

    AW.AddToPixelUpdater(eb)
    
    return eb
end