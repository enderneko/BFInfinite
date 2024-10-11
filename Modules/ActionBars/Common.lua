---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
---@class ActionBars
local AB = BFI.ActionBars
local U = BFI.utils

local LAB = BFI.libs.LAB

---------------------------------------------------------------------
-- hotkey
---------------------------------------------------------------------
function AB.GetHotkey(key)
    key = key:gsub("ALT%-", "A")
    key = key:gsub("CTRL%-", "C")
    key = key:gsub("SHIFT%-", "S")
    key = key:gsub("BUTTON", "B")
    key = key:gsub("MOUSEWHEELUP", "WU")
    key = key:gsub("MOUSEWHEELDOWN", "WD")
    return key
end

---------------------------------------------------------------------
-- glow
---------------------------------------------------------------------
local LCG = BFI.libs.LCG
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

    local icon = b.icon
    local hotkey = b.HotKey
    local autoCast = b.AutoCastOverlay
    local flash = b.Flash
    local border = b.Border
    local normal = b.NormalTexture
    local normal2 = b:GetNormalTexture()

    -- hide and remove ------------------------------------------------------- --
    if normal then normal:SetTexture() normal:Hide() normal:SetAlpha(0) end
    if normal2 then normal2:SetTexture() normal2:Hide() normal2:SetAlpha(0) end
    if border then U.Hide(border) end
    if b.NewActionTexture then b.NewActionTexture:SetAlpha(0) end
    if b.HighlightTexture then b.HighlightTexture:SetAlpha(0) end
    if b.SlotBackground then b.SlotBackground:Hide() end
    if b.IconMask then b.IconMask:Hide() end

    -- hotkey ---------------------------------------------------------------- --
    hotkey:SetDrawLayer("OVERLAY")

    -- icon ------------------------------------------------------------------ --
    icon:SetDrawLayer("ARTWORK", -1)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AW.SetOnePixelInside(icon, b)

    -- cooldown -------------------------------------------------------------- --
    AW.SetOnePixelInside(b.cooldown, b)
    b.cooldown:SetDrawEdge(false)

    -- checked texture ------------------------------------------------------- --
    b.checkedTexture = AW.CreateTexture(b, nil, AW.GetColorTable("white", 0.25))
    AW.SetOnePixelInside(b.checkedTexture, b)
    b.checkedTexture:SetBlendMode("ADD")
    b:SetCheckedTexture(b.checkedTexture)

    -- pushed texture -------------------------------------------------------- --
    b.pushedTexture = AW.CreateTexture(b, nil, AW.GetColorTable("yellow", 0.25))
    AW.SetOnePixelInside(b.pushedTexture, b)
    b.pushedTexture:SetBlendMode("ADD")
    b:SetPushedTexture(b.pushedTexture)

    -- mouseover highlight --------------------------------------------------- --
    b.mouseOverHighlight = AW.CreateTexture(b, nil, AW.GetColorTable("white", 0.25), "HIGHLIGHT")
    AW.SetOnePixelInside(b.mouseOverHighlight, b)
    b.mouseOverHighlight:SetBlendMode("ADD")

    -- SpellHighlightTexture ------------------------------------------------- --
    if b.SpellHighlightTexture then
        b.SpellHighlightTexture:SetColorTexture(AW.GetColorRGB("yellow", 0.4))
        AW.SetOnePixelInside(b.SpellHighlightTexture, b)
    end

    -- AutoCastShine --------------------------------------------------------- --
    if autoCast then
        autoCast:SetAllPoints(b)
        autoCast.Shine:ClearAllPoints()
        AW.SetOutside(autoCast.Shine, b, 5)
        autoCast.Mask:ClearAllPoints()
        AW.SetInside(autoCast.Mask, b, 1)
    end

    -- Flash ----------------------------------------------------------------- --
    if flash then
        flash:SetColorTexture(AW.GetColorRGB("red", 0.25))
        AW.SetOnePixelInside(flash, b)
        flash:SetDrawLayer("ARTWORK", 1)
    end

    -- backdrop -------------------------------------------------------------- --
    Mixin(b, BackdropTemplateMixin)
    AW.StylizeFrame(b)
end

---------------------------------------------------------------------
-- OnEnter/Leave
---------------------------------------------------------------------
function AB.ActionBar_OnEnter(bar)
    bar = bar.header and bar.header or bar
    AW.FrameFadeIn(bar, 0.25)
end

function AB.ActionBar_OnLeave(bar)
    bar = bar.header and bar.header or bar
    AW.FrameFadeOut(bar, 0.25, nil, bar.alpha)
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
            rp = rp.."RIGHT"
            rp_new_line = rp_new_line.."LEFT"
            x = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp.."LEFT"
            rp_new_line = rp_new_line.."RIGHT"
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
            rp = rp.."LEFT"
            rp_new_line = rp_new_line.."RIGHT"
            x_new_line = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp.."RIGHT"
            rp_new_line = rp_new_line.."LEFT"
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
        AW.SetSize(b, size, size)

        -- point
        if i == 1 then
            AW.SetPoint(b, p)
        else
            if (i - 1) % buttonsPerLine == 0 then
                AW.SetPoint(b, p, bar.buttons[i-buttonsPerLine], rp_new_line, x_new_line, y_new_line)
            else
                AW.SetPoint(b, p, bar.buttons[i-1], rp, x, y)
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
        AW.SetGridSize(bar, size, size, spacing, spacing, min(buttonsPerLine, num), ceil(num / buttonsPerLine))
    else
        AW.SetGridSize(bar, size, size, spacing, spacing, ceil(num / buttonsPerLine), min(buttonsPerLine, num))
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
        AW.SetOnePixelInside(b.TargetReticleAnimFrame, b)
        b.TargetReticleAnimFrame.Base:SetAllPoints()
        b.TargetReticleAnimFrame.Base:SetTexture(AW.GetTexture("TargetReticleBase"))
        b.TargetReticleAnimFrame.Highlight:SetAllPoints()
        b.TargetReticleAnimFrame.Mask:SetAllPoints()
        b.TargetReticleAnimFrame.Mask:SetTexture(AW.GetTexture("TargetReticleMask"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end

    -- InterruptDisplay ------------------------------------------------------ --
    if b.InterruptDisplay then
        AW.SetOnePixelInside(b.InterruptDisplay, b)
        b.InterruptDisplay.Base:SetAllPoints()
        b.InterruptDisplay.Base.Base:SetAllPoints()
        b.InterruptDisplay.Base.Base:SetTexture(AW.GetTexture("InterruptDisplayBase"))
        b.InterruptDisplay.Highlight:SetAllPoints()
        b.InterruptDisplay.Highlight.Mask:SetAllPoints()
        b.InterruptDisplay.Highlight.Mask:SetTexture(AW.GetTexture("InterruptDisplayMask"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        -- b.InterruptDisplay.Highlight.HighlightTexture:SetAllPoints()
        -- b.InterruptDisplay.Highlight.Mask:SetAllPoints()
    end

    -- SpellCastAnimFrame ---------------------------------------------------- --
    if b.SpellCastAnimFrame then
        AW.SetOnePixelInside(b.SpellCastAnimFrame, b)

        b.SpellCastAnimFrame.Fill:SetAllPoints()
        b.SpellCastAnimFrame.Fill.FillMask:SetAllPoints()
        b.SpellCastAnimFrame.Fill.FillMask:SetTexture(AW.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
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

    AW.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- stance button
---------------------------------------------------------------------
function AB.CreateStanceButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_StanceBarButton"..id, parent, "StanceButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    b.checkedTexture:SetBlendMode("BLEND")

    b.hotkey = AW.CreateFontString(b)
    b.hotkey:SetShadowColor(0, 0, 0, 0)
    b.hotkey:SetShadowOffset(0, 0)

    AW.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- pet button
---------------------------------------------------------------------
function AB.CreatePetButton(parent, id)
    local b = CreateFrame("CheckButton", "BFI_PetBarButton"..id, parent, "PetActionButtonTemplate")

    b:SetID(id)
    AB.StylizeButton(b)

    b.header = parent
    b:HookScript("OnEnter", AB.ActionBar_OnEnter)
    b:HookScript("OnLeave", AB.ActionBar_OnLeave)

    b.hotkey = AW.CreateFontString(b)
    b.hotkey:SetShadowColor(0, 0, 0, 0)
    b.hotkey:SetShadowOffset(0, 0)

    AW.AddToPixelUpdater(b)

    return b
end