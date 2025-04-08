---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
---@class ActionBars
local AB = BFI.ActionBars
local U = BFI.utils

local LAB = BFI.libs.LAB

---------------------------------------------------------------------
-- hotkey
---------------------------------------------------------------------
function AB.GetHotkey(key)
    if key and key ~= _G.RANGE_INDICATOR then
        key = key:gsub("ALT%-", "A")
        key = key:gsub("CTRL%-", "C")
        key = key:gsub("SHIFT%-", "S")
        key = key:gsub("META%-", "M")
        key = key:gsub("BUTTON", "B")
        key = key:gsub("MOUSEWHEELUP", "WU")
        key = key:gsub("MOUSEWHEELDOWN", "WD")
        key = key:gsub("NUMPAD", "N")
    end
    return key
end

---------------------------------------------------------------------
-- glow
---------------------------------------------------------------------
local LCG = AF.Libs.LCG
local hiders = {}
local proc = {xOffset = 3, yOffset = 3}

function LCG.ShowButtonGlow(b)
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

function LCG.HideButtonGlow(b)
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
function AB.StylizeButton(b)
    b.MasqueSkinned = true

    local name = b:GetName() or "NoName"

    local icon = b.icon or b.Icon or _G[name .. "Icon"]
    local hotkey = b.HotKey or _G[name .. "HotKey"]
    local autoCast = b.AutoCastOverlay or _G[name .. "Shine"]
    local flash = b.Flash or _G[name .. "Flash"]
    local border = b.Border or _G[name .. "Border"]
    local normal = b.NormalTexture or _G[name .. "NormalTexture"]
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
    U.Hide(border)
    if b.NewActionTexture then b.NewActionTexture:SetAlpha(0) end
    if b.HighlightTexture then b.HighlightTexture:SetAlpha(0) end
    if b.SlotBackground then b.SlotBackground:Hide() end
    if b.IconMask then b.IconMask:Hide() end

    -- hotkey ---------------------------------------------------------------- --
    if hotkey then
        hotkey:SetDrawLayer("OVERLAY")
    end

    -- icon ------------------------------------------------------------------ --
    icon:SetDrawLayer("ARTWORK", -1)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AF.SetOnePixelInside(icon, b)

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
    fs:SetFont(config.font.font, config.font.size, config.font.flags)
    if config.font.shadow then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
    else
        fs:SetShadowOffset(0, 0)
        fs:SetShadowColor(0, 0, 0, 0)
    end
    fs:SetJustifyH(config.justifyH)
    fs:SetPoint(config.position.anchor, fs:GetParent(), config.position.relAnchor, config.position.offsetX, config.position.offsetY)
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
function AB.ReArrange(bar, size, spacing, buttonsPerLine, num, anchor, orientation)
    -- update buttons -------------------------------------------------------- --
    local p, rp, rp_new_line
    local x, y, x_new_line, y_new_line

    p = anchor

    if orientation == "horizontal" then
        if strfind(anchor, "^TOP") then
            rp = "TOP"
            rp_new_line = "BOTTOM"
            y_new_line = -spacing
        elseif strfind(anchor, "^BOTTOM") then
            rp = "BOTTOM"
            rp_new_line = "TOP"
            y_new_line = spacing
        end

        if strfind(anchor, "LEFT$") then
            rp = rp .. "RIGHT"
            rp_new_line = rp_new_line .. "LEFT"
            x = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp .. "LEFT"
            rp_new_line = rp_new_line .. "RIGHT"
            x = -spacing
        end

        y = 0
        x_new_line = 0
    else
        if strfind(anchor, "^TOP") then
            rp = "BOTTOM"
            rp_new_line = "TOP"
            y = -spacing
        elseif strfind(anchor, "^BOTTOM") then
            rp = "TOP"
            rp_new_line = "BOTTOM"
            y = spacing
        end

        if strfind(anchor, "LEFT$") then
            rp = rp .. "LEFT"
            rp_new_line = rp_new_line .. "RIGHT"
            x_new_line = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp .. "RIGHT"
            rp_new_line = rp_new_line .. "LEFT"
            x_new_line = -spacing
        end

        x = 0
        y_new_line = 0
    end

    -- shown
    for i = 1, num do
        local b = bar.buttons[i]

        b:Show()
        b:SetAttribute("statehidden", nil)

        -- size
        AF.SetSize(b, size, size)

        -- point
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
    if orientation == "horizontal" then
        AF.SetGridSize(bar, size, size, spacing, spacing, min(buttonsPerLine, num), ceil(num / buttonsPerLine))
    else
        AF.SetGridSize(bar, size, size, spacing, spacing, ceil(num / buttonsPerLine), min(buttonsPerLine, num))
    end
end

---------------------------------------------------------------------
-- main button
---------------------------------------------------------------------
function AB.CreateButton(parent, id, name)
    local b = LAB:CreateButton(id, name, parent)

    AB.StylizeButton(b)

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

    AF.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- stance button
---------------------------------------------------------------------
function AB.CreateStanceButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_StanceBarButton" .. id, parent, "StanceButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    b.checkedTexture:SetBlendMode("BLEND")

    b.hotkey = AF.CreateFontString(b)
    b.hotkey:SetShadowColor(0, 0, 0, 0)
    b.hotkey:SetShadowOffset(0, 0)

    AF.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- pet button
---------------------------------------------------------------------
function AB.CreatePetButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_PetBarButton" .. id, parent, "PetActionButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    -- b.hotkey = AF.CreateFontString(b)
    -- b.hotkey:SetShadowColor(0, 0, 0, 0)
    -- b.hotkey:SetShadowOffset(0, 0)

    AF.AddToPixelUpdater(b)

    return b
end