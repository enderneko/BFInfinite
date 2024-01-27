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
    
    -- in -----------------------------------------------------------
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
