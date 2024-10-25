---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils
---@class AbstractWidgets
local AW = _G.AbstractWidgets

---------------------------------------------------------------------
-- hide frame
---------------------------------------------------------------------
function U.Hide(region)
    if not region then return end
    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
        region:SetParent(BFI.hiddenParent)
    else
        region.Show = region.Hide
    end
    region:Hide()
end

---------------------------------------------------------------------
-- remove texture
---------------------------------------------------------------------
function U.RemoveTexture(texture)
    texture:SetTexture(AW.GetEmptyTexture())
    texture:SetAtlas("")
end

---------------------------------------------------------------------
-- disable edit mode
---------------------------------------------------------------------
function U.DisableEditMode(region)
    region.HighlightSystem = BFI.dummy
    region.ClearHighlight = BFI.dummy
end