---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local AB = BFI.ActionBars
local U = BFI.utils

local LAB = BFI.libs.LAB

---------------------------------------------------------------------
-- glow
---------------------------------------------------------------------
local LCG = BFI.libs.LCG
local hiders = {}
local proc = {xOffset = 3, yOffset = 3}

function LCG.ShowButtonGlow(b)
    local config = AB.config and AB.config.sharedButtonConfig.glow
    if not config then return end

    if config.style == "Proc" then -- this uses an options table
        proc.color = config.color
        proc.duration = config.duration
        proc.startAnim = config.startAnim
        LCG.ProcGlow_Start(b, proc)
        hiders[b] = LCG.ProcGlow_Stop
    elseif config.style == "Normal" then
        LCG.ButtonGlow_Start(b, config.color)
        hiders[b] = LCG.ButtonGlow_Stop
    elseif config.style == "Pixel" then
        LCG.PixelGlow_Start(b, config.color, config.num, config.speed, config.length, config.thickness)
        hiders[b] = LCG.PixelGlow_Stop
    elseif config.style == "Shine" then
        LCG.AutoCastGlow_Start(b, config.color, config.num, config.speed, config.scale)
        hiders[b] = LCG.AutoCastGlow_Stop
    end
end

function LCG.HideButtonGlow(b)
    if hiders[b] then
        hiders[b](b)
        hiders[b] = nil
    end
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

    local name = b:GetName()
    local icon = b.icon or _G[name.."Icon"]
    local hotkey = b.HotKey or _G[name.."HotKey"]
    local shine = b.AutoCastShine or _G[name.."Shine"]
    local flash = b.Flash or _G[name.."Flash"]
    local border = b.Border or _G[name.."Border"]
    local normal = b.NormalTexture or _G[name.."NormalTexture"]
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
    if shine then
        AW.SetOnePixelInside(shine, b)
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
            b:ClearReticle()
            b.cooldown:SetSwipeColor(0, 0, 0, 1)
            b:UpdateCooldown()
        end)
    end

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

    return b
end