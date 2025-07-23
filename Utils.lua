---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- hide frame
---------------------------------------------------------------------
function U.Hide(region)
    if not region then return end
    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
        region:SetParent(AF.hiddenParent)
    else
        region.Show = region.Hide
    end
    region:Hide()
end

---------------------------------------------------------------------
-- disable edit mode
---------------------------------------------------------------------
function U.DisableEditMode(region)
    region.HighlightSystem = AF.noop
    region.ClearHighlight = AF.noop
end

---------------------------------------------------------------------
-- loot spec
---------------------------------------------------------------------
function U.GetLootSpecInfo()
    local id = GetLootSpecialization()
    if id == 0 then
        -- current spec
        id = AF.player.specID
    end
    local _, name, _, icon = GetSpecializationInfoByID(id)
    return id, name, icon
end