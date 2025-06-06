---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

local function Style(tooltip, _, embedded)
    if not tooltip or tooltip:IsForbidden() or not tooltip.NineSlice then return end
    if embedded or tooltip.IsEmbedded then return end -- Interface/AddOns/Blizzard_SharedXML/SharedTooltipTemplates.lua#L44

    if tooltip.Delimiter1 then tooltip.Delimiter1:SetTexture() end
    if tooltip.Delimiter2 then tooltip.Delimiter2:SetTexture() end

    AF.ApplyDefaultBackdropWithColors(tooltip.NineSlice)
end

local function StyleBlizzard(_, which)
    if which and which ~= "tooltip" then return end
    Style(GameTooltip)
    hooksecurefunc("SharedTooltip_SetBackdropStyle", Style)
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)