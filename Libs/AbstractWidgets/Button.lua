local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------
function AW.CreateButton(parent, text, color, width, height, template, noBorder, noBackground, fontNormal, fontDisable)
    local b = CreateFrame("Button", nil, parent, template and template..",BackdropTemplate" or "BackdropTemplate")
    if parent then b:SetFrameLevel(parent:GetFrameLevel()+1) end
    b:SetText(text)
    AW.SetSize(b, width, height)

    -- keep color & hoverColor
    b._color = AW.GetButtonNormalColor(color)
    b._hoverColor = AW.GetButtonHoverColor(color)

    local fs = b:GetFontString()
    b.fs = fs
    if fs then
        fs:SetWordWrap(false)
        fs:SetPoint("LEFT")
        fs:SetPoint("RIGHT")

        function b:SetTextColor(...)
            fs:SetTextColor(...)
        end
    end
    
    if noBorder then
        b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8"})
    else
        b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(b)})
    end
    
    if color and string.find(color, "transparent") then -- drop down item
        b._isTransparent = true
        if fs then
            fs:SetJustifyH("LEFT")
            fs:SetPoint("LEFT", 5, 0)
            fs:SetPoint("RIGHT", -5, 0)
        end
        b:SetBackdropBorderColor(1, 1, 1, 0) -- hide boder
        b:SetPushedTextOffset(0, 0)
    else
        if not noBackground then
            local bg = b:CreateTexture()
            bg:SetDrawLayer("BACKGROUND", -8)
            b.bg = bg
            bg:SetAllPoints(b)
            bg:SetColorTexture(AW.GetColorRGB("button"))
        end

        b:SetBackdropBorderColor(0, 0, 0, 1)
        b:SetPushedTextOffset(0, -AW.GetOnePixelForRegion(b))
    end

    b:SetBackdropColor(unpack(b._color)) 
    b:SetDisabledFontObject(fontDisable or AW.GetFont("normal", true))
    b:SetNormalFontObject(fontNormal or AW.GetFont("normal"))
    b:SetHighlightFontObject(fontNormal or AW.GetFont("normal"))
    
    if color ~= "none" then
        b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self._hoverColor)) end)
        b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self._color)) end)
    end

    if template and strfind(template, "Secure") then
        b._isSecure = true
        -- NOTE: ActionButtonUseKeyDown will affect OnClick
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown", "RightButtonDown")
    end

    -- click sound
    if not AW.isVanilla then
        b:SetScript("PostClick", function(self, button, down)
            if b._isSecure then
                if down == GetCVarBool("ActionButtonUseKeyDown") then
                    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
                end
            else
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            end
        end)
    else
        b:SetScript("PostClick", function() PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON) end)
    end

    -- texture
    function b:SetTexture(tex, size, point, isAtlas, noPushDownEffect)
        b.tex = b:CreateTexture(nil, "ARTWORK")
        assert(#point==3, "point format error! should be something like {\"CENTER\", 0, 0}")
        AW.SetPoint(b.tex, unpack(point))
        AW.SetSize(b.tex, unpack(size))
        if isAtlas then
            b.tex:SetAtlas(tex)
        else
            b.tex:SetTexture(tex)
        end
        -- update fontstring point
        if fs then
            fs:ClearAllPoints()
            fs:SetPoint("LEFT", size[2]+point[2]+point[2], 0)
            fs:SetPoint("RIGHT", -point[2], 0)
        end
        -- push effect
        if not noPushDownEffect then
            b.onMouseDown = function()
                b.tex:ClearAllPoints()
                b.tex:SetPoint(point[1], point[2], point[3]-AW.GetOnePixelForRegion(b))
            end
            b.onMouseUp = function()
                b.tex:ClearAllPoints()
                b.tex:SetPoint(unpack(point))
            end
            b:SetScript("OnMouseDown", b.onMouseDown)
            b:SetScript("OnMouseUp", b.onMouseUp)
        end
        -- enable / disable
        b:HookScript("OnEnable", function()
            b.tex:SetDesaturated(false)
            b.tex:SetVertexColor(1, 1, 1)
            b:SetScript("OnMouseDown", b.onMouseDown)
            b:SetScript("OnMouseUp", b.onMouseUp)
        end)
        b:HookScript("OnDisable", function()
            b.tex:SetDesaturated(true)
            b.tex:SetVertexColor(0.5, 0.5, 0.5)
            b:SetScript("OnMouseDown", nil)
            b:SetScript("OnMouseUp", nil)
        end)
    end

    function b:UpdatePixels()
        AW.ReSize(b)
        AW.RePoint(b)
        
        if not noBorder then
            AW.ReBorder(b)
        end

        if b.tex then
            AW.ReSize(b.tex)
            AW.RePoint(b.tex)
        end

        if not b._isTransparent then
            b:SetPushedTextOffset(0, -AW.GetOnePixelForRegion(b))
        end
    end
    
    AW.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- close button
---------------------------------------------------------------------
function AW.CreateCloseButton(parent, frameToHide, width, height, offset)
    local b = AW.CreateButton(parent, nil, "red", width, height)
    offset = offset or 6
    b:SetTexture(AW.GetIcon("Close"), {width-offset, height-offset}, {"CENTER", 0, 0})
    b:SetScript("OnClick", function()
        if frameToHide then
            frameToHide:Hide()
        else
            parent:Hide()
        end
    end)
    return b
end

---------------------------------------------------------------------
-- check button
---------------------------------------------------------------------
function AW.CreateCheckButton(parent, label, onClick)
    -- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
    -- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10
    
    local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    AW.SetSize(cb, 14, 14)

    cb.onClick = onClick
    cb:SetScript("OnClick", function(self)
        PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        if self.onClick then self.onClick(self:GetChecked() and true or false, self) end
    end)
    
    cb.label = cb:CreateFontString(nil, "OVERLAY", AW.GetFont("normal"))
    cb.label:SetPoint("LEFT", cb, "RIGHT", 5, 0)

    function cb:SetText(text)
        cb.label:SetText(text)
        if text and strtrim(text) ~= "" then
            cb:SetHitRectInsets(0, -cb.label:GetStringWidth()-5, 0, 0)
        else
            cb:SetHitRectInsets(0, 0, 0, 0)
        end
    end

    cb:SetText(label)

    cb:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(cb)})
    cb:SetBackdropColor(AW.GetColorRGB("button"))
    cb:SetBackdropBorderColor(0, 0, 0, 1)

    local checkedTexture = cb:CreateTexture(nil, "ARTWORK")
    checkedTexture:SetColorTexture(AW.GetColorRGB("accent", 0.7))
    AW.SetPoint(checkedTexture, "TOPLEFT", 1, -1)
    AW.SetPoint(checkedTexture, "BOTTOMRIGHT", -1, 1)

    local highlightTexture = cb:CreateTexture(nil, "ARTWORK")
    highlightTexture:SetColorTexture(AW.GetColorRGB("accent", 0.1))
    AW.SetPoint(highlightTexture, "TOPLEFT", 1, -1)
    AW.SetPoint(highlightTexture, "BOTTOMRIGHT", -1, 1)
    
    cb:SetCheckedTexture(checkedTexture)
    cb:SetHighlightTexture(highlightTexture, "ADD")
    -- cb:SetDisabledCheckedTexture([[Interface\AddOns\Cell\Media\CheckBox\CheckBox-DisabledChecked-16x16]])

    cb:SetScript("OnEnable", function()
        cb.label:SetTextColor(1, 1, 1)
        checkedTexture:SetColorTexture(AW.GetColorRGB("accent", 0.7))
        cb:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    cb:SetScript("OnDisable", function()
        cb.label:SetTextColor(AW.GetColorRGB("disabled"))
        checkedTexture:SetColorTexture(AW.GetColorRGB("disabled", 0.7))
        cb:SetBackdropBorderColor(0, 0, 0, 0.7)
    end)

    function cb:UpdatePixels()
        AW.ReSize(cb)
        AW.RePoint(cb)
        AW.ReBorder(cb)
        AW.RePoint(checkedTexture)
        AW.RePoint(highlightTexture)
    end

    AW.AddToPixelUpdater(cb)

    return cb
end