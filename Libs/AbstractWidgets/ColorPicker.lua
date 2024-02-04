local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- shared function
---------------------------------------------------------------------
function AW.ConvertRGB(r, g, b, desaturation)
    if not desaturation then desaturation = 1 end
    r = r / 255 * desaturation
    g = g / 255 * desaturation
    b = b / 255 * desaturation
    return r, g, b
end

function AW.ConvertRGB_256(r, g, b)
    return floor(r * 255), floor(g * 255), floor(b * 255)
end

function AW.ConvertRGBToHEX(r, g, b)
    local result = ""

    for key, value in pairs({r, g, b}) do
        local hex = ""

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = "00"

        elseif(string.len(hex) == 1)then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

function AW.ConvertHEXToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

--! From ColorPickerAdvanced by Feyawen-Llane
--[[ Convert RGB to HSV ---------------------------------------------
    Inputs:
        r = Red [0, 1]
        g = Green [0, 1]
        b = Blue [0, 1]
    Outputs:
        H = Hue [0, 360]
        S = Saturation [0, 1]
        B = Brightness [0, 1]
]]--
function AW.ConvertRGBToHSB(r, g, b)
    local colorMax = max(r, g, b)
    local colorMin = min(r, g, b)
    local delta = colorMax - colorMin
    local H, S, B
    
    colorMax = tonumber(format("%f", colorMax))
    r = tonumber(format("%f", r))
    g = tonumber(format("%f", g))
    b = tonumber(format("%f", b))
    
    if (delta > 0) then
        if (colorMax == r) then
            H = 60 * (((g - b) / delta) % 6)
        elseif (colorMax == g) then
            H = 60 * (((b - r) / delta) + 2)
        elseif (colorMax == b) then
            H = 60 * (((r - g) / delta) + 4)
        end
        
        if (colorMax > 0) then
            S = delta / colorMax
        else
            S = 0
        end
        
        B = colorMax
    else
        H = 0
        S = 0
        B = colorMax
    end
    
    if (H < 0) then
        H = H + 360
    end
    
    return H, S, B
end

--[[ Convert HSB to RGB ---------------------------------------------
    Inputs:
        h = Hue [0, 360]
        s = Saturation [0, 1]
        b = Brightness [0, 1]
    Outputs:
        R = Red [0,1]
        G = Green [0,1]
        B = Blue [0,1]
]]--
function AW.ConvertHSBToRGB(h, s, b)
    local chroma = b * s
    local prime = (h / 60) % 6
    local X = chroma * (1 - abs((prime % 2) - 1))
    local M = b - chroma
    local R, G, B

    if (0 <= prime) and (prime < 1) then
        R = chroma
        G = X
        B = 0
    elseif (1 <= prime) and (prime < 2) then
        R = X
        G = chroma
        B = 0
    elseif (2 <= prime) and (prime < 3) then
        R = 0
        G = chroma
        B = X
    elseif (3 <= prime) and (prime < 4) then
        R = 0
        G = X
        B = chroma
    elseif (4 <= prime) and (prime < 5) then
        R = X
        G = 0
        B = chroma
    elseif (5 <= prime) and (prime < 6) then
        R = chroma
        G = 0
        B = X
    else
        R = 0
        G = 0
        B = 0
    end
    
    R = tonumber(format("%.3f", R + M))
    G = tonumber(format("%.3f", G + M))
    B = tonumber(format("%.3f", B + M))
    
    return R, G, B
end

----------------------------------------------------------------
-- color picker widget
----------------------------------------------------------------
function AW.CreateColorPicker(parent, label, hasOpacity, onChange, onConfirm)
    local cp = CreateFrame("Button", nil, parent, "BackdropTemplate")
    AW.SetSize(cp, 14, 14)
    cp:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(cp)})
    cp:SetBackdropBorderColor(0, 0, 0, 1)

    cp.label = AW.CreateFontString(cp, label)
    AW.SetPoint(cp.label, "LEFT", cp, "RIGHT", 5, 0)
    cp:SetHitRectInsets(0, -cp.label:GetStringWidth()-5, 0, 0)

    cp:SetScript("OnEnter", function()
        cp:SetBackdropBorderColor(AW.GetColorRGB("accent", 0.5))
        cp.label:SetColor("accent")
    end)
    
    cp:SetScript("OnLeave", function()
        cp:SetBackdropBorderColor(AW.GetColorRGB("black"))
        cp.label:SetColor("white")
    end)

    cp.mask = AW.CreateTexture(cp, nil, {0.15, 0.15, 0.15, 0.75})
    AW.SetPoint(cp.mask, "TOPLEFT", 1, -1)
    AW.SetPoint(cp.mask, "BOTTOMRIGHT", -1, 1)
    cp.mask:Hide()
    
    cp.hasOpacity = hasOpacity

    function cp:EnableAlpha(enable)
        AW.HideColorPicker()
        cp.hasOpacity = enable
    end
    
    cp:SetScript("OnClick", function()
        -- reset temp
        cp._r = cp.color[1]
        cp._g = cp.color[2]
        cp._b = cp.color[3]
        cp._a = cp.color[4]

        AW.ShowColorPicker(function(r, g, b, a)
            cp:SetBackdropColor(r, g, b, a)
            if cp._r ~= r or cp._g ~= g or cp._b ~= b or cp._a ~= a then
                cp._r = r
                cp._g = g
                cp._b = b
                cp._a = a
                if onChange then
                    onChange(r, g, b, a)
                end
            end
        end, function(r, g, b, a)
            if cp.color[1] ~= r or cp.color[2] ~= g or cp.color[3] ~= b or cp.color[4] ~= a then
                cp.color[1] = r
                cp.color[2] = g
                cp.color[3] = b
                cp.color[4] = a
                if onConfirm then
                    onConfirm(r, g, b, a)
                end
            end 
        end, cp.hasOpacity, unpack(cp.color))
    end)

    cp.color = {1, 1, 1, 1}
    
    function cp:SetColor(arg1, arg2, arg3, arg4)
        if type(arg1) == "table" then
            cp.color[1] = arg1[1]
            cp.color[2] = arg1[2]
            cp.color[3] = arg1[3]
            cp.color[4] = arg1[4]
            cp:SetBackdropColor(unpack(arg1))
        else
            cp.color[1] = arg1
            cp.color[2] = arg2
            cp.color[3] = arg3
            cp.color[4] = arg4
            cp:SetBackdropColor(arg1, arg2, arg3, arg4)
        end
    end

    function cp:GetColorTable()
        return cp.color
    end

    function cp:GetColorRGB()
        return unpack(cp.color)
    end

    cp:SetScript("OnEnable", function()
        cp.label:SetTextColor(AW.GetColorRGB("white"))
        cp.mask:Hide()
    end)

    cp:SetScript("OnDisable", function()
        cp.label:SetTextColor(AW.GetColorRGB("disabled"))
        cp.mask:Show()
    end)

    return cp
end

----------------------------------------------------------------
-- color picker frame
----------------------------------------------------------------
local COLOR_PICKER_NAME = strupper(ns.prefix).."ColorPicker"
local colorPickerFrame
local currentPane, originalPane, hueSaturationPaneBG, hueSaturationPane, brightnessSlider, alphaSlider, picker
local rEB, gEB, bEB, aEB, h_EB, s_EB, b_EB, hexEB
local confirmBtn, cancelBtn 

local Callback

local oR, oG, oB, oA
local H, S, B, A

-------------------------------------------------
-- update functions
-------------------------------------------------
local function UpdateColor_RGBA(r, g, b, a)
    -- update currentPane & originalPane
    currentPane:SetColor(r, g, b, a)
    
    r, g, b = math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)

    -- update editboxes
    rEB:SetText(r)
    gEB:SetText(g)
    bEB:SetText(b)
    aEB:SetText(math.floor(a * 100))
    hexEB:SetText(AW.ConvertRGBToHEX(r, g, b))
end

local function UpdateColor_HSBA(h, s, b, a, updateBrightness, updatePickers)
    h_EB:SetText(math.floor(h))
    s_EB:SetText(math.floor(s * 100))
    b_EB:SetText(math.floor(b * 100))

    if updateBrightness then
        local _r, _g, _b = AW.ConvertHSBToRGB(h, s, 1)
        brightnessSlider.tex:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(_r, _g, _b, 1))
    end

    if updatePickers then
        picker:SetPoint("CENTER", hueSaturationPane, "BOTTOMLEFT", H/360*hueSaturationPane:GetWidth(), S*hueSaturationPane:GetHeight())
        brightnessSlider:SetValue(1-B)
        alphaSlider:SetValue(1-a)
    end
end

local function UpdateAll(use, v1, v2, v3, a, updateBrightness, updatePickers)
    if use == "rgb" then
        UpdateColor_RGBA(v1, v2, v3, a)
        local h, s, b = AW.ConvertRGBToHSB(v1, v2, v3)
        UpdateColor_HSBA(h, s, b, a, updateBrightness, updatePickers)
        Callback(v1, v2, v3, a)
    elseif use == "hsb" then
        UpdateColor_HSBA(v1, v2, v3, a, updateBrightness, updatePickers)
        local r, g, b = AW.ConvertHSBToRGB(v1, v2, v3)
        UpdateColor_RGBA(r, g, b, a)
        Callback(r, g, b, a)
    end
end

-------------------------------------------------
-- create color pane
-------------------------------------------------
local function CreateColorPane(parent)
    local pane = AW.CreateBorderedFrame(parent, nil, 98, 27)

    pane.solid = AW.CreateTexture(pane)
    AW.SetPoint(pane.solid, "TOPLEFT", 1, -1)
    AW.SetPoint(pane.solid, "BOTTOMRIGHT", pane, "BOTTOMLEFT", 49, 1)

    pane.alpha = AW.CreateTexture(pane)
    AW.SetPoint(pane.alpha, "TOPLEFT", pane.solid, "TOPRIGHT")
    AW.SetPoint(pane.alpha, "BOTTOMRIGHT", -1, 1)
    
    function pane:SetColor(r, g, b, a)
        pane.solid:SetColorTexture(r, g, b)
        pane.alpha:SetColorTexture(r, g, b, a)
    end

    return pane
end

-------------------------------------------------
-- create color slider
-------------------------------------------------
local function CreateColorSlider(parent, onValueChanged)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    AW.StylizeFrame(slider)
    AW.SetSize(slider, 17, 130)
    slider:SetValueStep(0.001)
    slider:SetMinMaxValues(0, 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("VERTICAL")

    slider:SetScript("OnValueChanged", onValueChanged)

    slider.tex = slider:CreateTexture(nil, "ARTWORK")
    slider.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    AW.SetPointOnePixelInner(slider.tex, slider)

    slider.thumb1 = slider:CreateTexture(nil, "ARTWORK")
    AW.SetSize(slider.thumb1, 17, 1)
    slider:SetThumbTexture(slider.thumb1)

    slider.thumb2 = slider:CreateTexture(nil, "ARTWORK")
    slider.thumb2:SetTexture(AW.GetIcon("Thumb"))
    AW.SetSize(slider.thumb2, 16, 16)
    AW.SetPoint(slider.thumb2, "LEFT", slider.thumb1, "RIGHT", -5, 0)

    function slider:UpdatePixels()
        AW.ReSize(slider)
        AW.RePoint(slider)
        AW.ReBorder(slider)
        AW.RePoint(slider.tex)
        AW.ReSize(slider.thumb1)
        AW.ReSize(slider.thumb2)
        AW.RePoint(slider.thumb2)
    end

    return slider
end

-------------------------------------------------
-- create color editbox
-------------------------------------------------
local function CreateEB(label, width, height, isNumeric, group)
    local eb = AW.CreateEditBox(colorPickerFrame, nil, width, height, false, isNumeric)
    eb.label2 = AW.CreateFontString(eb, label)
    AW.SetPoint(eb.label2, "BOTTOMLEFT", eb, "TOPLEFT", 0, 2)

    eb:SetScript("OnEditFocusGained", function()
        eb:HighlightText()
        eb.oldText = eb:GetText()
    end)
    
    eb:SetScript("OnEditFocusLost", function()
        eb:HighlightText(0, 0)
        if strtrim(eb:GetText()) == "" then
            eb:SetText(eb.oldText)
        end
    end)

    eb:SetScript("OnEnterPressed", function()
        if isNumeric then
            if group == "rgb" then
                if rEB:GetNumber() > 255 then
                    rEB:SetText(255)
                end
                if gEB:GetNumber() > 255 then
                    gEB:SetText(255)
                end
                if bEB:GetNumber() > 255 then
                    bEB:SetText(255)
                end

                local r, g, b = AW.ConvertRGB(rEB:GetNumber(), gEB:GetNumber(), bEB:GetNumber())
                H, S, B = AW.ConvertRGBToHSB(r, g, b)
                UpdateAll("rgb", r, g, b, A, true, true)

            elseif group == "hsb" then
                if h_EB:GetNumber() > 360 then
                    h_EB:SetText(360)
                end
                if s_EB:GetNumber() > 100 then
                    s_EB:SetText(100)
                end
                if b_EB:GetNumber() > 100 then
                    b_EB:SetText(100)
                end

                H, S, B = h_EB:GetNumber(), s_EB:GetNumber()/100, b_EB:GetNumber()/100
                UpdateAll("hsb", H, S, B, A, true, true)

            else -- alphaSlider
                if aEB:GetNumber() > 100 then
                    aEB:SetText(100)
                end
                A = aEB:GetNumber()/100

                alphaSlider:SetValue(1-A)
                UpdateAll("hsb", H, S, B, A)
            end
            
        else -- hex
            local text = strtrim(hexEB:GetText())
            -- print(text, hexEB.oldText)
            if strlen(text) ~= 6 or not strmatch(text, "^[0-9a-fA-F]+$") then
                hexEB:SetText(hexEB.oldText)
            end

            local r, g, b = AW.ConvertRGB(AW.ConvertHEXToRGB(hexEB:GetText()))
            H, S, B = AW.ConvertRGBToHSB(r, g, b)
            UpdateAll("rgb", r, g, b, A, true, true)
        end

        eb:ClearFocus()
    end)

    return eb
end

-------------------------------------------------
-- CreateColorPickerFrame
-------------------------------------------------
local function CreateColorPickerFrame()
    colorPickerFrame = AW.CreateHeaderedFrame(UIParent, COLOR_PICKER_NAME, _G.COLOR_PICKER, 216, 295, "DIALOG")
    colorPickerFrame.header.closeBtn:Hide()
    colorPickerFrame:SetToplevel(true)
    -- AW.StylizeFrame(colorPickerFrame, nil, "accent")
    -- AW.StylizeFrame(colorPickerFrame.header, "header", "accent")
    AW.SetPoint(colorPickerFrame, "CENTER")
    AW.PixelPerfectPoint(colorPickerFrame)

    colorPickerFrame:SetScript("OnHide", function()
        Callback = nil
    end)

    ---------------------------------------------
    -- color pane
    ---------------------------------------------
    currentPane = CreateColorPane(colorPickerFrame)
    AW.SetPoint(currentPane, "TOPLEFT", 7, -7)
    
    originalPane = CreateColorPane(colorPickerFrame)
    AW.SetPoint(originalPane, "TOPRIGHT", -7, -7)

    ---------------------------------------------
    -- hue, saturation
    ---------------------------------------------
    hueSaturationPaneBG = AW.CreateBorderedFrame(colorPickerFrame, nil, 130, 130)
    AW.SetPoint(hueSaturationPaneBG, "TOPLEFT", currentPane, "BOTTOMLEFT", 0, -7)
    
    hueSaturationPane = CreateFrame("Frame", nil, hueSaturationPaneBG)
    AW.SetPointOnePixelInner(hueSaturationPane, hueSaturationPaneBG)

    -- fill color
    local colors = {"red", "yellow", "green", "cyan", "blue", "purple", "red"}
    local sectionSize = hueSaturationPane:GetWidth() / 6
    for i = 1, 6 do
        hueSaturationPane[i] = AW.CreateGradientTexture(hueSaturationPane, "HORIZONTAL", colors[i], colors[i+1], nil, nil, 0)

        -- width
        hueSaturationPane[i]:SetWidth(sectionSize)

        -- point
        if i == 1 then
            hueSaturationPane[i]:SetPoint("TOPLEFT")
        else
            hueSaturationPane[i]:SetPoint("TOPLEFT", hueSaturationPane[i-1], "TOPRIGHT")
        end
        hueSaturationPane[i]:SetPoint("BOTTOM")
    end

    -- add saturation
    local saturation = AW.CreateGradientTexture(hueSaturationPane, "VERTICAL", AW.GetColorTable("white", 1), AW.GetColorTable("white", 0), nil, nil, 1)
    saturation:SetBlendMode("BLEND")
    saturation:SetAllPoints(hueSaturationPane)

    ---------------------------------------------
    -- brightness slider
    ---------------------------------------------
    brightnessSlider = CreateColorSlider(colorPickerFrame, function(self, value, userChanged)
        if not userChanged then return end
        B = 1 - value

        if self.prev == B then return end
        self.prev = B

        -- update
        UpdateAll("hsb", H, S, B, A)
    end)
    AW.SetPoint(brightnessSlider, "TOPLEFT", hueSaturationPane, "TOPRIGHT", 15, 0)

    ---------------------------------------------
    -- alpha slider
    ---------------------------------------------
    alphaSlider = CreateColorSlider(colorPickerFrame, function(self, value, userChanged)
        if not userChanged then return end
        A = tonumber(format("%.3f", 1 - value))
        
        if self.prev == A then return end
        self.prev = A
        
        -- update
        UpdateAll("hsb", H, S, B, A)
    end)
    AW.SetPoint(alphaSlider, "TOPLEFT", brightnessSlider, "TOPRIGHT", 15, 0)

    alphaSlider.tex:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(1, 1, 1, 1))

    alphaSlider:SetScript("OnEnable", function()
        alphaSlider:SetAlpha(1)
        alphaSlider.thumb2:SetVertexColor(AW.GetColorRGB("white"))
    end)
    alphaSlider:SetScript("OnDisable", function()
        alphaSlider:SetAlpha(0.25)
        alphaSlider.thumb2:SetVertexColor(AW.GetColorRGB("disabled"))
    end)

    ---------------------------------------------
    -- picker
    ---------------------------------------------
    picker = CreateFrame("Frame", nil, hueSaturationPane)
    AW.SetSize(picker, 10, 10)
    picker:SetPoint("CENTER", hueSaturationPane, "BOTTOMLEFT")
    
    picker.tex1 = picker:CreateTexture(nil, "ARTWORK")
    picker.tex1:SetPoint("CENTER")
    AW.SetSize(picker.tex1, 10, 10)
    picker.tex1:SetTexture(AW.GetIcon("Circle"))
    -- picker.tex1:SetTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
    -- picker.tex1:SetTexCoord(0, 0.15625, 0, 0.625)

    picker.tex2 = picker:CreateTexture(nil, "ARTWORK")
    picker.tex2:SetPoint("CENTER")
    AW.SetSize(picker.tex2, 12, 12)
    picker.tex2:SetTexture(AW.GetIcon("Circle"))
    picker.tex2:SetVertexColor(0, 0, 0, 1)

    picker:EnableMouse(true)
    picker:SetMovable(true)

    function picker:UpdatePixels()
        AW.ReSize(picker)
        AW.ReSize(picker.tex1)
        AW.ReSize(picker.tex2)
    end

    function picker:StartMoving(x, y, mouseX, mouseY)
        local scale = picker:GetEffectiveScale()

        local lastX, lastY
        self:SetScript("OnUpdate", function(self)
            local newMouseX, newMouseY = GetCursorPosition()
            if newMouseX == lastX and newMouseY == lastY then return end
            lastX, lastY = newMouseX, newMouseY

            local newX = x + (newMouseX - mouseX) / scale
            local newY = y + (newMouseY - mouseY) / scale
            
            if newX < 0 then -- left
                newX = 0
            elseif newX > hueSaturationPane:GetWidth() then -- right
                newX = hueSaturationPane:GetWidth()
            end
    
            if newY < 0 then -- top
                newY = 0
            elseif newY > hueSaturationPane:GetHeight() then
                newY = hueSaturationPane:GetHeight()
            end
    
            picker:SetPoint("CENTER", hueSaturationPane, "BOTTOMLEFT", newX, newY)

            -- update HSV
            H = (newX / hueSaturationPane:GetWidth()) * 360
            S = newY / hueSaturationPane:GetHeight()

            -- update
            UpdateAll("hsb", H, S, B, A, true)
        end)
    end

    picker:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end

        local x, y = select(4, picker:GetPoint(1))
        local mouseX, mouseY = GetCursorPosition()

        picker:StartMoving(x, y, mouseX, mouseY)
    end)

    picker:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- click & drag
    hueSaturationPane:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        
        local hueSaturationX, hueSaturationY = hueSaturationPane:GetLeft(), hueSaturationPane:GetBottom()
        local mouseX, mouseY = GetCursorPosition()
        
        local scale = picker:GetEffectiveScale()
        mouseX, mouseY = mouseX/scale, mouseY/scale
        
        -- start dragging
        local x, y = select(4, picker:GetPoint(1))
        picker:StartMoving(mouseX/scale-hueSaturationX, mouseY/scale-hueSaturationY, mouseX, mouseY)
    end)

    hueSaturationPane:SetScript("OnMouseUp", function(self, button)
        picker:SetScript("OnUpdate", nil)
    end)

    ---------------------------------------------
    -- editboxes
    ---------------------------------------------
    -- red
    rEB = CreateEB("R", 40, 20, true, "rgb")
    AW.SetPoint(rEB, "TOPLEFT", hueSaturationPaneBG, "BOTTOMLEFT", 0, -25)

    -- green
    gEB = CreateEB("G", 40, 20, true, "rgb")
    AW.SetPoint(gEB, "TOPLEFT", rEB, "TOPRIGHT", 7, 0)
    
    -- blue
    bEB = CreateEB("B", 40, 20, true, "rgb")
    AW.SetPoint(bEB, "TOPLEFT", gEB, "TOPRIGHT", 7, 0)

    -- alphaSlider
    aEB = CreateEB("A", 61, 20, true)
    AW.SetPoint(aEB, "TOPLEFT", bEB, "TOPRIGHT", 7, 0)

    -- hue
    h_EB = CreateEB("H", 40, 20, true, "hsb")
    AW.SetPoint(h_EB, "TOPLEFT", rEB, "BOTTOMLEFT", 0, -25)

    -- saturation
    s_EB = CreateEB("S", 40, 20, true, "hsb")
    AW.SetPoint(s_EB, "TOPLEFT", h_EB, "TOPRIGHT", 7, 0)

    -- brightness
    b_EB = CreateEB("B", 40, 20, true, "hsb")
    AW.SetPoint(b_EB, "TOPLEFT", s_EB, "TOPRIGHT", 7, 0)

    -- hex
    hexEB = CreateEB("Hex", 61, 20, false, "rgb")
    AW.SetPoint(hexEB, "TOPLEFT", b_EB, "TOPRIGHT", 7, 0)

    ---------------------------------------------
    -- buttons
    ---------------------------------------------
    confirmBtn = AW.CreateButton(colorPickerFrame, _G.OKAY, "green", 97, 20)
    AW.SetPoint(confirmBtn, "BOTTOMLEFT", 7, 7)
    
    cancelBtn = AW.CreateButton(colorPickerFrame, _G.CANCEL, "red", 97, 20)
    AW.SetPoint(cancelBtn, "BOTTOMRIGHT", -7, 7)

    ---------------------------------------------
    -- update pixels
    ---------------------------------------------
    colorPickerFrame._UpdatePixels = colorPickerFrame.UpdatePixels
    function colorPickerFrame:UpdatePixels()
        colorPickerFrame:_UpdatePixels()
        
        -- AW.ReSize(hueSaturationPaneBG)
        -- AW.RePoint(hueSaturationPaneBG)
        
        AW.RePoint(hueSaturationPane)
        -- update each color section
        for i = 1, 6 do
            hueSaturationPane[i]:SetWidth(hueSaturationPane:GetWidth() / 6)
        end

        -- brightness slider
        brightnessSlider:UpdatePixels()
        alphaSlider:UpdatePixels()

        -- picker
        picker:UpdatePixels()
    end
    
    AW.AddToPixelUpdater(colorPickerFrame)
end

-------------------------------------------------
-- show
-------------------------------------------------
function AW.ShowColorPicker(callback, onConfirm, hasAlpha, r, g, b, a)
    if not colorPickerFrame then
        CreateColorPickerFrame()
    end

    -- clear previous
    brightnessSlider.prev = nil
    alphaSlider.prev = nil

    -- already shown, restore previous
    if colorPickerFrame:IsShown() then
        if Callback then
            Callback(oR, oG, oB, oA)
        end
    end

    -- backup for restore
    oR, oG, oB, oA = r or 1, g or 1, b or 1, a or 1

    -- data & callback
    H, S, B = AW.ConvertRGBToHSB(oR, oG, oB)
    A = oA
    Callback = callback

    confirmBtn:SetScript("OnClick", function()
        colorPickerFrame:Hide()
        local r, g, b = AW.ConvertHSBToRGB(H, S, B)
        onConfirm(r, g, b, A)
    end)

    cancelBtn:SetScript("OnClick", function()
        colorPickerFrame:Hide()
        callback(oR, oG, oB, oA)
    end)

    -- update originalPane
    originalPane:SetColor(oR, oG, oB, oA)

    -- update all
    UpdateAll("rgb", oR, oG, oB, oA, true, true)
    AW.SetEnabled(hasAlpha, alphaSlider, aEB, aEB.label2)

    colorPickerFrame:Show()
end

function AW.HideColorPicker()
    if colorPickerFrame then
        colorPickerFrame:Hide()
    end
end