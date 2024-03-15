local _, BFI = ...
local W = BFI.widgets
local U = BFI.utils

function U.Hide(region)
    if not region then return end
    
    region:SetParent(W.hiddenParent)

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