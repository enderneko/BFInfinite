local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- fade-in/out animation group
---------------------------------------------------------------------
function AW.CreateFadeInOutAnimationGroup(region, duration)
    duration = duration or 0.25

    local in_ag = region:CreateAnimationGroup()
    region.fadeIn = in_ag

    local out_ag = region:CreateAnimationGroup()
    region.fadeOut = out_ag
    
    function region:FadeIn()
        region.fadeIn:Play()
    end
    
    function region:FadeOut()
        region.fadeOut:Play()
    end

    -- in -----------------------------------------------------------
    local in_a = in_ag:CreateAnimation("Alpha")
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(duration)

    in_ag:SetScript("OnPlay", function()
        out_ag:Stop()
        region:Show()
    end)
    -----------------------------------------------------------------
    
    -- out ----------------------------------------------------------
    local out_a = out_ag:CreateAnimation("Alpha")
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetDuration(duration)

    out_ag:SetScript("OnPlay", function()
        in_ag:Stop()
        region:Show()
    end)

    out_ag:SetScript("OnFinished", function()
        region:Hide()
    end)
    -----------------------------------------------------------------
end

---------------------------------------------------------------------
-- resize with animation
---------------------------------------------------------------------
--- @param steps number total steps to final size
--- @param anchorPoint string TOPLEFT|TOPRIGHT|BOTTOMLEFT|BOTTOMRIGHT
function AW.AnimatedResize(frame, targetWidth, targetHeight, frequency, steps, onStart, onFinish, onChange, anchorPoint)
    frequency = frequency or 0.015
    steps = steps or 7

    if anchorPoint then
        -- anchorPoint is only for those frames of which the direct parent is UIParent
        assert(frame:GetParent() == UIParent)
        local left = Round(frame:GetLeft())
        local right = Round(frame:GetRight())
        local top = Round(frame:GetTop())
        local bottom = Round(frame:GetBottom())
        
        AW.ClearPoints(frame)
        if anchorPoint == "TOPLEFT" then
            frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
        elseif anchorPoint == "TOPRIGHT" then
            frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", right, top)
        elseif anchorPoint == "BOTTOMLEFT" then
            frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
        elseif anchorPoint == "BOTTOMRIGHT" then
            frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", right, bottom)
        end
    end

    if onStart then onStart() end
    
    local currentHeight = frame._height or frame:GetHeight()
    local currentWidth = frame._width or frame:GetWidth()
    targetWidth = targetWidth or currentWidth
    targetHeight = targetHeight or currentHeight

    local diffW = (targetWidth - currentWidth) / steps
    local diffH = (targetHeight - currentHeight) / steps
    
    local animationTimer
    animationTimer = C_Timer.NewTicker(frequency, function()
        if diffW ~= 0 then
            if diffW > 0 then
                currentWidth = math.min(currentWidth + diffW, targetWidth)
            else
                currentWidth = math.max(currentWidth + diffW, targetWidth)
            end
            AW.SetWidth(frame, currentWidth)
        end

        if diffH ~= 0 then
            if diffH > 0 then
                currentHeight = math.min(currentHeight + diffH, targetHeight)
            else
                currentHeight = math.max(currentHeight + diffH, targetHeight)
            end
            AW.SetHeight(frame, currentHeight)
        end

        if onChange then
            onChange(currentWidth, currentHeight)
        end

        if currentWidth == targetWidth and currentHeight == targetHeight then
            animationTimer:Cancel()
            animationTimer = nil
            if onFinish then onFinish() end
        end
    end)
end