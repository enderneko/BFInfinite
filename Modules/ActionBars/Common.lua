---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework
---@class ActionBars
local AB = BFI.modules.ActionBars

local GetBindingKey = GetBindingKey
local LAB = BFI.libs.LAB

---------------------------------------------------------------------
-- hotkey
---------------------------------------------------------------------
function AB.GetHotkey(key)
    if key and key ~= _G.RANGE_INDICATOR then
        key = key:upper()
        key = key:gsub(" ", "")
        key = key:gsub("ALT%-", "A")
        key = key:gsub("CTRL%-", "C")
        key = key:gsub("SHIFT%-", "S")
        key = key:gsub("META%-", "M")

        key = key:gsub("BUTTON", "B")
        key = key:gsub("MOUSEWHEELUP", "WU")
        key = key:gsub("MOUSEWHEELDOWN", "WD")

        key = key:gsub("NUMPAD", "N")
        key = key:gsub("PLUS", "+")
        key = key:gsub("MINUS", "-")
        key = key:gsub("MULTIPLY", "*")
        key = key:gsub("DIVIDE", "/")

        key = key:gsub("BACKSPACE", "Bs")
        key = key:gsub("SPACEBAR", "Sp")
        key = key:gsub("SPACE", "Sp")
        key = key:gsub("CAPSLOCK", "Cp")
        key = key:gsub("CLEAR", "Cl")
        key = key:gsub("DELETE", "Del")
        key = key:gsub("END", "End")
        key = key:gsub("HOME", "Home")
        key = key:gsub("INSERT", "Ins")
        key = key:gsub("SCROLLLOCK", "Sl")
        key = key:gsub("TAB", "Tab")
        key = key:gsub("PAGEDOWN", "PD")
        key = key:gsub("PAGEUP", "PU")

        key = key:gsub("DOWNARROW", "Dn")
        key = key:gsub("LEFTARROW", "Lf")
        key = key:gsub("RIGHTARROW", "Rt")
        key = key:gsub("UPARROW", "Up")
    end
    return key or ""
end

---------------------------------------------------------------------
-- glow
---------------------------------------------------------------------
local LCG = AF.Libs.LCG
local hiders = {}
local proc = {xOffset = 3, yOffset = 3}

function AB.ShowButtonGlow(b)
    local config = AB.config and AB.config.sharedButtonConfig.glow
    if not config or b.glowing then return end

    b.glowing = true

    if config.style == "proc" then -- this uses an options table
        proc.color = config.color
        proc.duration = config.duration
        proc.startAnim = config.startAnim
        LCG.ProcGlow_Start(b, proc)
        hiders[b] = LCG.ProcGlow_Stop
    elseif config.style == "normal" then
        LCG.ButtonGlow_Start(b, config.color)
        hiders[b] = LCG.ButtonGlow_Stop
    elseif config.style == "pixel" then
        LCG.PixelGlow_Start(b, config.color, config.num, config.speed, config.length, config.thickness)
        hiders[b] = LCG.PixelGlow_Stop
    elseif config.style == "shine" then
        LCG.AutoCastGlow_Start(b, config.color, config.num, config.speed, config.scale)
        hiders[b] = LCG.AutoCastGlow_Stop
    end
end

function AB.HideButtonGlow(b)
    if hiders[b] then
        hiders[b](b)
        hiders[b] = nil
    end
    b.glowing = nil
end

function AB.HideAllGlows()
    for b in next, hiders do
        LCG.HideButtonGlow(b)
    end
end

---------------------------------------------------------------------
-- stylize button
---------------------------------------------------------------------
local function OnSizeChanged(self, width, height)
    local _name = self:GetName() or "NoName"

    local icon = self.icon or self.Icon or _G[_name .. "Icon"]
    icon:SetTexCoord(AF.Unpack8(AF.CalcTexCoordPreCrop(0.1, width / height)))

    local name = self.Name or _G[_name .. "Name"]
    if name then
        AF.TruncateFontStringByWidth(self.Name, self:GetWidth() + 5)
    end
end

function AB.StylizeButton(b)
    b.MasqueSkinned = true

    local _name = b:GetName() or "NoName"

    local icon = b.icon or b.Icon or _G[_name .. "Icon"]
    local hotkey = b.HotKey or _G[_name .. "HotKey"]
    local count = b.Count or _G[_name .. "Count"]
    local name = b.Name or _G[_name .. "Name"]
    local autoCast = b.AutoCastOverlay or _G[_name .. "Shine"]
    local flash = b.Flash or _G[_name .. "Flash"]
    local border = b.Border or _G[_name .. "Border"]
    local normal = b.NormalTexture or _G[_name .. "NormalTexture"]
    local normal2 = b:GetNormalTexture()
    local cooldown = b.cooldown or b.Cooldown

    -- hide and remove ------------------------------------------------------- --
    if normal then
        normal:SetTexture()
        normal:Hide()
        normal:SetAlpha(0)
    end
    if normal2 then
        normal2:SetTexture()
        normal2:Hide()
        normal2:SetAlpha(0)
    end
    F.Hide(border)
    if b.NewActionTexture then b.NewActionTexture:SetAlpha(0) end
    if b.HighlightTexture then b.HighlightTexture:SetAlpha(0) end
    if b.SlotBackground then b.SlotBackground:Hide() end
    if b.IconMask then b.IconMask:Hide() end

    -- texts ----------------------------------------------------------------- --
    if hotkey then
        hotkey:SetDrawLayer("OVERLAY")
        hotkey:SetWidth(0)
    end

    if count then
        count:SetDrawLayer("OVERLAY")
        count:SetWidth(0)
    end

    if name then
        name:SetDrawLayer("OVERLAY")
        name:SetWidth(0)
    end

    -- icon ------------------------------------------------------------------ --
    icon:SetDrawLayer("ARTWORK", -1)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AF.SetOnePixelInside(icon, b)
    b:SetScript("OnSizeChanged", OnSizeChanged)

    -- cooldown -------------------------------------------------------------- --
    if cooldown then
        AF.SetOnePixelInside(cooldown, b)
        cooldown:SetDrawEdge(false)
    end

    -- checked texture ------------------------------------------------------- --
    if b.SetCheckedTexture then
        b.checkedTexture = AF.CreateTexture(b, nil, AF.GetColorTable("white", 0.25))
        AF.SetOnePixelInside(b.checkedTexture, b)
        b.checkedTexture:SetBlendMode("ADD")
        b:SetCheckedTexture(b.checkedTexture)
    end

    -- pushed texture -------------------------------------------------------- --
    if b.SetPushedTexture then
        b.pushedTexture = AF.CreateTexture(b, nil, AF.GetColorTable("yellow", 0.25))
        AF.SetOnePixelInside(b.pushedTexture, b)
        b.pushedTexture:SetBlendMode("ADD")
        b:SetPushedTexture(b.pushedTexture)
    end

    -- mouseover highlight --------------------------------------------------- --
    if b.SetHighlightTexture then
        b.mouseoverHighlight = AF.CreateTexture(b, nil, AF.GetColorTable("white", 0.25), "HIGHLIGHT")
        AF.SetOnePixelInside(b.mouseoverHighlight, b)
        b.mouseoverHighlight:SetBlendMode("ADD")
        b:SetHighlightTexture(b.mouseoverHighlight)
    end

    -- SpellHighlightTexture ------------------------------------------------- --
    if b.SpellHighlightTexture then
        b.SpellHighlightTexture:SetColorTexture(AF.GetColorRGB("yellow", 0.4))
        AF.SetOnePixelInside(b.SpellHighlightTexture, b)
    end

    -- AutoCastShine --------------------------------------------------------- --
    if autoCast then
        autoCast:SetAllPoints(b)
        autoCast.Shine:ClearAllPoints()
        AF.SetOutside(autoCast.Shine, b, 5)
        autoCast.Mask:ClearAllPoints()
        AF.SetInside(autoCast.Mask, b, 1)
    end

    -- Flash ----------------------------------------------------------------- --
    if flash then
        flash:SetColorTexture(AF.GetColorRGB("red", 0.25))
        AF.SetOnePixelInside(flash, b)
        flash:SetDrawLayer("ARTWORK", 1)
    end

    -- backdrop -------------------------------------------------------------- --
    Mixin(b, BackdropTemplateMixin)
    AF.ApplyDefaultBackdrop(b)
    AF.ApplyDefaultBackdropColors(b)
end

---------------------------------------------------------------------
-- update text
---------------------------------------------------------------------
function AB.ApplyTextConfig(fs, config)
    AF.SetFont(fs, unpack(config.font))
    AF.LoadTextPosition(fs, config.position)
    fs:SetTextColor(AF.UnpackColor(config.color))
end

---------------------------------------------------------------------
-- OnEnter/Leave
---------------------------------------------------------------------
function AB.ActionBar_OnEnter(bar)
    bar = bar.header and bar.header or bar
    AF.FrameFadeIn(bar, 0.25)
end

function AB.ActionBar_OnLeave(bar)
    bar = bar.header and bar.header or bar
    AF.FrameFadeOut(bar, 0.25, nil, bar.alpha)
end

---------------------------------------------------------------------
-- arrangement
---------------------------------------------------------------------
function AB.ReArrange(bar, width, height, spacingX, spacingY, buttonsPerLine, num, orientation)
    -- update buttons -------------------------------------------------------- --
    local p, rp, rp_new_line, x, y, x_new_line, y_new_line = AF.GetAnchorPoints_Complex(orientation, spacingX, spacingY)

    -- shown
    for i = 1, num do
        local b = bar.buttons[i]

        b:Show()
        b:SetAttribute("statehidden", nil)

        -- size
        AF.SetSize(b, width, height)

        -- point
        AF.ClearPoints(b)
        if i == 1 then
            AF.SetPoint(b, p)
        else
            if (i - 1) % buttonsPerLine == 0 then
                AF.SetPoint(b, p, bar.buttons[i - buttonsPerLine], rp_new_line, x_new_line, y_new_line)
            else
                AF.SetPoint(b, p, bar.buttons[i - 1], rp, x, y)
            end
        end
    end

    -- hidden
    for i = num + 1, #bar.buttons do
        bar.buttons[i]:Hide()
        bar.buttons[i]:SetAttribute("statehidden", true)
    end

    -- update bar ------------------------------------------------------------ --
    if orientation:find("^left") or orientation:find("^right") then -- horizontal
        AF.SetGridSize(bar, width, height, spacingX, spacingY, min(buttonsPerLine, num), ceil(num / buttonsPerLine))
    else -- vertical
        AF.SetGridSize(bar, width, height, spacingX, spacingY, ceil(num / buttonsPerLine), min(buttonsPerLine, num))
    end
end

---------------------------------------------------------------------
-- main button
---------------------------------------------------------------------
local function Button_GetHotKeys(self)
    if not self.keyBoundTarget then
        return "", ""
    end

    local key1, key2 = GetBindingKey(self.keyBoundTarget)
    return AB.GetHotkey(key1), AB.GetHotkey(key2)
end

function AB.CreateButton(parent, id, name)
    local b = LAB:CreateButton(id, name, parent)

    AB.StylizeButton(b)
    AB.CreateKeybindOverlay(b)

    b.GetHotKeys = Button_GetHotKeys

    -- TargetReticleAnimFrame ------------------------------------------------ --
    if b.TargetReticleAnimFrame then
        AF.SetOnePixelInside(b.TargetReticleAnimFrame, b)
        b.TargetReticleAnimFrame.Base:SetAllPoints()
        b.TargetReticleAnimFrame.Base:SetTexture(AF.GetTexture("TargetReticleBase", BFI.name))
        b.TargetReticleAnimFrame.Highlight:SetAllPoints()
        b.TargetReticleAnimFrame.Mask:SetAllPoints()
        b.TargetReticleAnimFrame.Mask:SetTexture(AF.GetTexture("TargetReticleMask", BFI.name), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end

    -- InterruptDisplay ------------------------------------------------------ --
    if b.InterruptDisplay then
        AF.SetOnePixelInside(b.InterruptDisplay, b)
        b.InterruptDisplay.Base:SetAllPoints()
        b.InterruptDisplay.Base.Base:SetAllPoints()
        b.InterruptDisplay.Base.Base:SetTexture(AF.GetTexture("InterruptDisplayBase", BFI.name))
        b.InterruptDisplay.Highlight:SetAllPoints()
        b.InterruptDisplay.Highlight.Mask:SetAllPoints()
        b.InterruptDisplay.Highlight.Mask:SetTexture(AF.GetTexture("InterruptDisplayMask", BFI.name), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        -- b.InterruptDisplay.Highlight.HighlightTexture:SetAllPoints()
        -- b.InterruptDisplay.Highlight.Mask:SetAllPoints()
    end

    -- SpellCastAnimFrame ---------------------------------------------------- --
    if b.SpellCastAnimFrame then
        AF.SetOnePixelInside(b.SpellCastAnimFrame, b)

        b.SpellCastAnimFrame.Fill:SetAllPoints()
        b.SpellCastAnimFrame.Fill.FillMask:SetAllPoints()
        b.SpellCastAnimFrame.Fill.FillMask:SetTexture(AF.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        b.SpellCastAnimFrame.Fill.InnerGlowTexture:ClearAllPoints()
        b.SpellCastAnimFrame.Fill.InnerGlowTexture:Hide()

        b.SpellCastAnimFrame.Fill.CastingAnim.CastFillTranslation:SetEndDelay(0)
        b.SpellCastAnimFrame.Fill.CastingAnim:SetScript("OnFinished", function()
            b.SpellCastAnimFrame:Hide()
        end)

        b.SpellCastAnimFrame:SetScript("OnHide", function()
            b:StopTargettingReticleAnim()
            b.cooldown:SetSwipeColor(0, 0, 0, 1)
            b:UpdateCooldown()
        end)
    end

    AF.AddToPixelUpdater_Auto(b, nil, true)

    return b
end

---------------------------------------------------------------------
-- stance button
---------------------------------------------------------------------
local function StanceButton_GetHotKeys(self)
    local command = ("SHAPESHIFTBUTTON%d"):format(self:GetID())
    local key1, key2 = GetBindingKey(command)
    return AB.GetHotkey(key1), AB.GetHotkey(key2)
end

function AB.CreateStanceButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_StanceBarButton" .. id, parent, "StanceButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)
    AB.CreateKeybindOverlay(b, "SHAPESHIFTBUTTON" .. id)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    b.checkedTexture:SetBlendMode("BLEND")
    b.HotKey = AF.CreateFontString(b)
    b.GetHotKeys = StanceButton_GetHotKeys

    AF.AddToPixelUpdater_Auto(b, nil, true)

    return b
end

---------------------------------------------------------------------
-- pet button
---------------------------------------------------------------------
local function PetButton_GetHotKeys(self)
    local command = ("BONUSACTIONBUTTON%d"):format(self:GetID())
    local key1, key2 = GetBindingKey(command)
    return AB.GetHotkey(key1), AB.GetHotkey(key2)
end

function AB.CreatePetButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_PetBarButton" .. id, parent, "PetActionButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)
    AB.CreateKeybindOverlay(b, "BONUSACTIONBUTTON" .. id)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    -- b.HotKey = AF.CreateFontString(b)
    b.GetHotKeys = PetButton_GetHotKeys

    AF.AddToPixelUpdater_Auto(b, nil, true)

    return b
end

---------------------------------------------------------------------
-- preview rect
---------------------------------------------------------------------
function AB.CreatePreviewRect(parent)
    local previewRect = parent:CreateTexture(nil, "BACKGROUND")
    previewRect:SetIgnoreParentAlpha(true)
    previewRect:SetColorTexture(AF.GetColorRGB("BFI", 0.277))
    previewRect:SetAlpha(0)
    previewRect:SetAllPoints(parent)
    previewRect:Hide()
    parent.previewRect = previewRect
end