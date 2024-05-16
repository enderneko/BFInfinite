local _, BFI = ...
local U = BFI.utils

function U.Hide(region)
    if not region then return end
    
    region:SetParent(BFI.hiddenParent)

    region.Show = region.Hide

    if region.SetTexture then
        region:SetTexture()
    end

    if region.SetAlpha then
        region:SetAlpha(0)
    end

    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
    end

    region:Hide()
end

function U.DisableEditMode(region)
    region.HighlightSystem = BFI.dummy
    region.ClearHighlight = BFI.dummy
end