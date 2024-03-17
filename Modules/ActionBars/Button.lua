local _, BFI = ...
local AW = BFI.AW
local AB = BFI.M_AB
local U = BFI.utils

local LAB = BFI.libs.LAB

function AB.StylizeButton(b)
    b.MasqueSkinned = true

    -- hide and remove ------------------------------------------------------- --
    U.Hide(b.NormalTexture)
    U.Hide(b:GetNormalTexture())
    U.Hide(b.border)
    U.Hide(b.IconMask)
    U.Hide(b.NewActionTexture)
    U.Hide(b.SlotBackground)
    U.Hide(b.SlotBackground)
    U.Hide(b.HighlightTexture)
    
    b.HotKey:SetDrawLayer("OVERLAY")

    -- icon ------------------------------------------------------------------ --
    b.icon:SetDrawLayer("ARTWORK", -1)
    b.icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    AW.SetOnePixelInside(b.icon, b)

    -- cooldown -------------------------------------------------------------- --
    AW.SetOnePixelInside(b.cooldown, b)
    b.cooldown:SetDrawEdge(false)

    -- checked texture ------------------------------------------------------- --
    b.checkedTexture = AW.CreateTexture(b, nil, AW.GetColorTable("white", 0.2))
    AW.SetOnePixelInside(b.checkedTexture, b)
    b.checkedTexture:SetBlendMode("ADD")
    b:SetCheckedTexture(b.checkedTexture)
    
    -- pushed texture -------------------------------------------------------- --
    b.pushedTexture = AW.CreateTexture(b, nil, AW.GetColorTable("yellow", 0.2))
    AW.SetOnePixelInside(b.pushedTexture, b)
    b.pushedTexture:SetBlendMode("ADD")
    b:SetPushedTexture(b.pushedTexture)
    
    -- mouseover highlight --------------------------------------------------- --
    b.mouseOverHighlight = AW.CreateTexture(b, nil, AW.GetColorTable("white", 0.2), "HIGHLIGHT")
    AW.SetOnePixelInside(b.mouseOverHighlight, b)
    b.mouseOverHighlight:SetBlendMode("ADD")

    -- SpellHighlightTexture ------------------------------------------------- --
    b.SpellHighlightTexture:SetColorTexture(AW.GetColorRGB("yellow", 0.4))
    AW.SetOnePixelInside(b.SpellHighlightTexture, b)

    -- AutoCastShine --------------------------------------------------------- --
    AW.SetOnePixelInside(b.AutoCastShine, b)
    
    -- Flash ----------------------------------------------------------------- --
    b.Flash:SetColorTexture(AW.GetColorRGB("red", 0.2))
    AW.SetOnePixelInside(b.Flash, b)
    b.Flash:SetDrawLayer("ARTWORK", 1)
    
    -- backdrop -------------------------------------------------------------- --
    Mixin(b, BackdropTemplateMixin)
    AW.StylizeFrame(b)
end

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

--[=[
-- local wrapFrame = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

-- local Button = CreateFrame("CheckButton")
-- local Button_MT = {__index = Button}

function AB.CreateButton(parent, id, name)
    local b = setmetatable(CreateFrame("CheckButton", name, parent, "BackdropTemplate,SecureActionButtonTemplate"), Button_MT)
    AW.StylizeFrame(b)

    -- icon ------------------------------------------------------------------ --
    b.icon = AW.CreateTexture(b)
    b.icon:SetAllPoints()
    b.icon:Hide()

    -- mouseover highlight --------------------------------------------------- --
    b.mouseOverHighlight = AW.CreateTexture(b, nil, AW.GetColorTable("accent", 0.2), "HIGHLIGHT")
    b.mouseOverHighlight:SetAllPoints()

    b:SetAttribute("type", "action")
    b:SetAttribute("typerelease", "actionrelease")
    b:SetAttribute("checkselfcast", true)
    b:SetAttribute("checkfocuscast", true)
    b:SetAttribute("checkmouseovercast", true)
    b:SetAttribute("useparent-unit", true)
    b:SetAttribute("useparent-actionpage", true)
    b:RegisterForDrag("LeftButton", "RightButton")
    b:RegisterForClicks("AnyUp", "LeftButtonDown", "RightButtonDown")

    -- OnClick --------------------------------------------------------------- --
    wrapFrame:WrapScript(b, "OnClick", [[
        -- print("onclick", IsPressHoldReleaseSpell)
    ]])

    -- wrapFrame:WrapScript(b, "OnReceiveDrag", [[
    --     print(kind, value, ...)

    --     if kind == "spell" then
    --         local spellId = select(2, ...)
            
    --     elseif kind == "item" and value then

    --     end

    --     -- local type, value, subType, extra = ...
    --     -- print(type, value, subType, extra)
    -- ]])

    return b
end
]=]