local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW

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