local addonName, ns = ...
---@class AbstractWidgets
local AW = ns.AW

-----------------------------------------
-- forked from ElvUI
-----------------------------------------
local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
FADEMANAGER.interval = 0.025

-----------------------------------------
-- fade manager onupdate
-----------------------------------------
local function Fading(_, elapsed)
    FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

    if FADEMANAGER.timer > FADEMANAGER.interval then
        FADEMANAGER.timer = 0

        for frame, info in next, FADEFRAMES do
            if frame:IsVisible() then
                info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.interval)
            else -- faster for hidden frames
                info.fadeTimer = info.timeToFade + 1
            end

            if info.fadeTimer < info.timeToFade then
                if info.mode == "IN" then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
                else
                    frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
                end
            else
                frame:SetAlpha(info.endAlpha)
                -- NOTE: remove from FADEFRAMES
                if frame and FADEFRAMES[frame] then
                    if frame.fade then
                        frame.fade.fadeTimer = nil
                    end
                    FADEFRAMES[frame] = nil
                end
            end
        end

        if not next(FADEFRAMES) then
            FADEMANAGER:SetScript("OnUpdate", nil)
        end
    end
end

-----------------------------------------
-- fade
-----------------------------------------
local function FrameFade(frame, info)
    frame:SetAlpha(info.startAlpha)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not FADEFRAMES[frame] then
        FADEFRAMES[frame] = info
        FADEMANAGER:SetScript("OnUpdate", Fading)
    else
        FADEFRAMES[frame] = info
    end
end

function AW.FrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = "IN"
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha or frame:GetAlpha()
    frame.fade.endAlpha = endAlpha or 1
    frame.fade.diffAlpha = frame.fade.endAlpha - frame.fade.startAlpha

    FrameFade(frame, frame.fade)
end

function AW.FrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = "OUT"
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha or frame:GetAlpha()
    frame.fade.endAlpha = endAlpha or 0
    frame.fade.diffAlpha = frame.fade.startAlpha - frame.fade.endAlpha

    FrameFade(frame, frame.fade)
end

---------------------------------------------------------------------
-- fade-in/out animation group
---------------------------------------------------------------------
local fade_in_out = {
    FadeIn = function(region)
        if not region.fadeIn:IsPlaying() then
            region.fadeIn:Play()
        end
    end,

    FadeOut = function(region)
        if not region.fadeOut:IsPlaying() then
            region.fadeOut:Play()
        end
    end,

    ShowNow = function(region)
        region.fadeIn:Stop()
        region.fadeOut:Stop()
        region:Show()
    end,

    HideNow = function(region)
        region.fadeIn:Stop()
        region.fadeOut:Stop()
        region:Hide()
    end,
}

function AW.CreateFadeInOutAnimation(region, duration)
    duration = duration or 0.25

    local in_ag = region:CreateAnimationGroup()
    region.fadeIn = in_ag

    local out_ag = region:CreateAnimationGroup()
    region.fadeOut = out_ag

    for k, v in pairs(fade_in_out) do
        region[k] = v
    end

    -- in -----------------------------------------------------------
    local in_a = in_ag:CreateAnimation("Alpha")
    in_ag.alpha = in_a
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
    out_ag.alpha = out_a
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

function AW.SetFadeInOutAnimationDuration(region, duration)
    if not (duration and region.fadeIn and region.fadeOut) then return end

    region.fadeIn.alpha:SetDuration(duration)
    region.fadeOut.alpha:SetDuration(duration)
end

---------------------------------------------------------------------
-- blink
---------------------------------------------------------------------
function AW.CreateBlinkAnimation(region, duration)
    local blink = region:CreateAnimationGroup()
    region.blink = blink

    local alpha = blink:CreateAnimation("Alpha")
    blink.alpha = alpha
    alpha:SetFromAlpha(0.25)
    alpha:SetToAlpha(1)
    alpha:SetDuration(duration)

    blink:SetLooping("BOUNCE")
    blink:Play()
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
        assert(frame:GetParent() == AW.UIParent)
        local left = Round(frame:GetLeft())
        local right = Round(frame:GetRight())
        local top = Round(frame:GetTop())
        local bottom = Round(frame:GetBottom())

        AW.ClearPoints(frame)
        if anchorPoint == "TOPLEFT" then
            frame:SetPoint("TOPLEFT", AW.UIParent, "BOTTOMLEFT", left, top)
        elseif anchorPoint == "TOPRIGHT" then
            frame:SetPoint("TOPRIGHT", AW.UIParent, "BOTTOMLEFT", right, top)
        elseif anchorPoint == "BOTTOMLEFT" then
            frame:SetPoint("BOTTOMLEFT", AW.UIParent, "BOTTOMLEFT", left, bottom)
        elseif anchorPoint == "BOTTOMRIGHT" then
            frame:SetPoint("BOTTOMRIGHT", AW.UIParent, "BOTTOMLEFT", right, bottom)
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