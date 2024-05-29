local _, BFI = ...
local U = BFI.utils

---------------------------------------------------------------------
-- hide
---------------------------------------------------------------------
function U.Hide(region)
    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
        region:SetParent(BFI.hiddenParent)
    else
        region.Show = region.Hide
    end

    region:Hide()
end

---------------------------------------------------------------------
-- disable edit mode
---------------------------------------------------------------------
function U.DisableEditMode(region)
    region.HighlightSystem = BFI.dummy
    region.ClearHighlight = BFI.dummy
end

---------------------------------------------------------------------
-- debuff type color
---------------------------------------------------------------------
function U.GetDebuffTypeColor(debuffType)
    if debuffType == "Curse" then
        return AW.GetColorRGB("debuff_curse")
    elseif debuffType == "Disease" then
        return AW.GetColorRGB("debuff_disease")
    elseif debuffType == "Magic" then
        return AW.GetColorRGB("debuff_magic")
    elseif debuffType == "Poison" then
        return AW.GetColorRGB("debuff_disease")
    elseif debuffType == "Bleed" then
        return AW.GetColorRGB("debuff_bleed")
    elseif debuffType == "None" then
        return AW.GetColorRGB("debuff_none")
    else
        return AW.GetColorRGB("black")
    end
end