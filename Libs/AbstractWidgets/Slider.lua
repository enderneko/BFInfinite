local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- slider
---------------------------------------------------------------------
function AW.CreateSlider(parent, text, width, low, high, step, showPercentSign, hideLowHighText)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    AW.StylizeFrame(slider, "widget")
    
    slider:SetValueStep(step or 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")
    AW.SetSize(slider, width, 10)

    local label = AW.CreateFontString(slider, text)
    AW.SetPoint(label, "BOTTOM", slider, "TOP", 0, 2)

    function slider:SetLabel(n)
        label:SetText(n)
    end

    -- OnEnterPressed / dragging
    function slider:SetOnValueChanged(func)
        slider.onValueChanged = func
    end

    -- OnEnterPressed / OnMouseUp
    function slider:SetAfterValueChanged(func)
        slider.afterValueChanged = func
    end

    -- low ----------------------------------------------------------
    local lowText = AW.CreateFontString(slider, nil, "gray")
    AW.SetPoint(lowText, "TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    -----------------------------------------------------------------
    
    -- high ---------------------------------------------------------
    local highText = AW.CreateFontString(slider, nil, "gray")
    AW.SetPoint(highText, "TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
    -----------------------------------------------------------------

    -- thumb --------------------------------------------------------
    local thumbBG = AW.CreateTexture(slider, nil, AW.GetColorTable("black"), "BACKGROUND")
    AW.SetSize(thumbBG, 10, 8)

    local thumb = AW.CreateTexture(slider, nil, AW.GetColorTable("accent", 0.7), "OVERLAY")
    -- AW.SetSize(thumb, 8, 8)
    -- AW.SetPoint(thumb, "BOTTOM", thumbBG, "TOP", 0, -5)
    AW.SetPoint(thumb, "TOPLEFT", thumbBG, 1, 0)
    AW.SetPoint(thumb, "BOTTOMRIGHT", thumbBG, -1, 0)

    slider:SetThumbTexture(thumbBG)
    -----------------------------------------------------------------
    
    local oldValue, valueBeforeClick

    -- editbox ------------------------------------------------------
    local eb = AW.CreateEditBox(slider, nil, 48, 14)
    AW.SetPoint(eb, "TOPLEFT", slider, "BOTTOMLEFT", math.ceil(width / 2 - 24), -1)
    eb:SetJustifyH("CENTER")

    eb:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local value = tonumber(self:GetText())

        if value == oldValue then return end
        if value then
            if value < slider.low then value = slider.low end
            if value > slider.high then value = slider.high end
            self:SetText(value)
            slider:SetValue(value)
            if slider.onValueChanged then slider.onValueChanged(value) end
            if slider.afterValueChanged then slider.afterValueChanged(value) end
        else
            self:SetText(self.oldValue)
        end
    end)
    
    eb:SetScript("OnShow", function(self)
        if oldValue then self:SetText(oldValue) end
    end)
    -----------------------------------------------------------------

    local unit = showPercentSign and "%" or ""
    local percentSign = AW.CreateFontString(slider, "%", "gray")
    AW.SetPoint(percentSign, "LEFT", eb, "RIGHT", 2, 0)
    percentSign:Hide()

    if hideLowHighText then
        lowText:Hide()
        highText:Hide()
        if showPercentSign then
            percentSign:Show()
        end
    end
    
    -- highlight ----------------------------------------------------
    local highlight = AW.CreateTexture(slider, nil, AW.GetColorTable("accent", 0.05))
    AW.SetPoint(highlight, "TOPLEFT", 1, -1)
    AW.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
    highlight:Hide()
    -----------------------------------------------------------------

    -- NOTE: OnEnter / OnLeave will still trigger even if disabled
    -- OnEnter ------------------------------------------------------
    local function OnEnter()
        thumb:SetColor("accent")
        valueBeforeClick = slider:GetValue()
        highlight:Show()
    end
    slider:SetScript("OnEnter", OnEnter)
    -----------------------------------------------------------------
    
    -- OnLeave ------------------------------------------------------
    local function OnLeave()
        thumb:SetColor(AW.GetColorTable("accent", 0.7))
        highlight:Hide()
    end
    slider:SetScript("OnLeave", OnLeave)
    -----------------------------------------------------------------
    
    -- OnValueChanged -----------------------------------------------
    slider:SetScript("OnValueChanged", function(self, value, userChanged)
        if oldValue == value then return end
        
        if math.floor(value) < value then -- decimal
            value = tonumber(string.format("%.2f", value))
        end
        oldValue = value
        
        eb:SetText(value)
        if userChanged and slider.onValueChanged then
            slider.onValueChanged(value)
        end
    end)
    -----------------------------------------------------------------
    
    -- OnMouseUp ----------------------------------------------------
    slider:SetScript("OnMouseUp", function(self, button, isMouseOver)
        if not slider:IsEnabled() then return end
        
        -- oldValue here == newValue, OnMouseUp called after OnValueChanged
        if valueBeforeClick ~= oldValue and slider.afterValueChanged then
            valueBeforeClick = oldValue
            local value = slider:GetValue()
            if math.floor(value) < value then -- decimal
                value = tonumber(string.format("%.2f", value))
            end
            slider.afterValueChanged(value)
        end
    end)
    -----------------------------------------------------------------

    -- REVIEW: OnMouseWheel
    --[[
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        if not IsShiftKeyDown() then return end

        -- NOTE: OnValueChanged may not be called: value == low
        oldValue = oldValue and oldValue or low

        local value
        if delta == 1 then -- scroll up
            value = oldValue + step
            value = value > high and high or value
        elseif delta == -1 then -- scroll down
            value = oldValue - step
            value = value < low and low or value
        end
        
        if value ~= oldValue then
            slider:SetValue(value)
            if slider.onValueChanged then slider.onValueChanged(value) end
            if slider.afterValueChanged then slider.afterValueChanged(value) end
        end
    end)
    ]]
    
    slider:SetScript("OnDisable", function()
        label:SetColor("disabled")
        eb:SetEnabled(false)
        thumb:SetColor(AW.GetColorTable("disabled", 0.7))
        thumbBG:SetColor(AW.GetColorTable("black", 0.7))
        lowText:SetColor("disabled")
        highText:SetColor("disabled")
        percentSign:SetColor("disabled")
        slider:SetScript("OnEnter", nil)
        slider:SetScript("OnLeave", nil)
        slider:SetBackdropBorderColor(AW.GetColorRGB("black", 0.7))
    end)
    
    slider:SetScript("OnEnable", function()
        label:SetColor("white")
        eb:SetEnabled(true)
        thumb:SetColor(AW.GetColorTable("accent", 0.7))
        thumbBG:SetColor(AW.GetColorTable("black", 1))
        lowText:SetColor("gray")
        highText:SetColor("gray")
        percentSign:SetColor("gray")
        slider:SetScript("OnEnter", OnEnter)
        slider:SetScript("OnLeave", OnLeave)
        slider:SetBackdropBorderColor(AW.GetColorRGB("black", 1))
    end)

    function slider:UpdateMinMaxValues(minV, maxV)
        slider:SetMinMaxValues(minV, maxV)
        slider.low = minV
        slider.high = maxV
        lowText:SetText(minV..unit)
        highText:SetText(maxV..unit)
    end
    slider:UpdateMinMaxValues(low, high)

    function slider:UpdatePixels()
        AW.ReSize(slider)
        AW.RePoint(slider)
    end

    AW.AddToPixelUpdater(slider)
    
    return slider
end