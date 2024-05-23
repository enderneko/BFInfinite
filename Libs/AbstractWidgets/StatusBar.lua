local addonName, ns = ...
local AW = ns.AW

--- @param color string color name defined in Color.lua
--- @param borderColor string color name defined in Color.lua
function AW.CreateStatusBar(parent, minValue, maxValue, width, height, color, borderColor, progressTextType)
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    AW.StylizeFrame(bar, AW.GetColorTable(color, 0.9, 0.1), borderColor)
    AW.SetSize(bar, width, height)

    minValue = minValue or 1
    maxValue = maxValue or 1

    bar._SetMinMaxValues = bar.SetMinMaxValues
    function bar:SetMinMaxValues(l, h)
        bar:_SetMinMaxValues(l, h)
        bar.minValue = l
        bar.maxValue = h
    end
    bar:SetMinMaxValues(minValue, maxValue)

    bar:SetStatusBarTexture(AW.GetPlainTexture())
    bar:SetStatusBarColor(AW.GetColorRGB(color, 0.7))
    bar:GetStatusBarTexture():SetDrawLayer("BORDER", -7)

    bar.tex = AW.CreateGradientTexture(bar, "HORIZONTAL", "none", AW.GetColorTable(color, 0.2), nil, "BORDER", -6)
    bar.tex:SetBlendMode("ADD")
    bar.tex:SetPoint("TOPLEFT", bar:GetStatusBarTexture())
    bar.tex:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture())

    if progressTextType then
        bar.progressText = AW.CreateFontString(bar)
        AW.SetPoint(bar.progressText, "CENTER")
        if progressTextType == "percentage" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d%%", (bar:GetValue()-bar.minValue)/bar.maxValue*100)
            end)
        elseif progressTextType == "value" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d", bar:GetValue())
            end)
        elseif progressTextType == "value-max" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d/%d", bar:GetValue(), bar.maxValue)
            end)
        end
    end

    bar:SetValue(minValue)

    function bar:SetBarValue(v)
        AW.SetStatusBarValue(bar, v)
    end

    Mixin(bar, SmoothStatusBarMixin) -- SetSmoothedValue

    function bar:UpdatePixels()
        AW.ReSize(bar)
        AW.RePoint(bar)
        AW.ReBorder(bar)
        if bar.progressText then
            AW.RePoint(bar.progressText)
        end
    end

    AW.AddToPixelUpdater(bar)

    return bar
end