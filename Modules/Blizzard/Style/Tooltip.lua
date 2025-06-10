---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- style
---------------------------------------------------------------------
local function Style(tooltip, _, embedded)
    if not tooltip or tooltip:IsForbidden() or not tooltip.NineSlice then return end
    if embedded or tooltip.IsEmbedded then return end -- Interface/AddOns/Blizzard_SharedXML/SharedTooltipTemplates.lua#L44

    if tooltip.Delimiter1 then tooltip.Delimiter1:SetTexture() end
    if tooltip.Delimiter2 then tooltip.Delimiter2:SetTexture() end

    AF.ApplyDefaultBackdropWithColors(tooltip.NineSlice)
end

---------------------------------------------------------------------
-- GameTooltip_ShowStatusBar
---------------------------------------------------------------------
-- Interface/AddOns/Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.lua
local function GameTooltip_ShowStatusBar(tooltip)
    if not tooltip or not tooltip.statusBarPool or tooltip:IsForbidden() then return end

    local bar = tooltip.statusBarPool:GetNextActive()
    if not bar or bar.BFIBackdrop then return end

    S.RemoveTextures(bar)
    S.CreateBackdrop(bar, nil, true)
    bar:SetStatusBarTexture(BFI.media.bar)
end

---------------------------------------------------------------------
-- GameTooltip_ShowProgressBar
---------------------------------------------------------------------
-- Interface\AddOns\Blizzard_CovenantCallings\CovenantCallings.lua
-- Interface\AddOns\Blizzard_FrameXMLUtil\Mainline\ReputationUtil.lua
-- Interface\AddOns\Blizzard_PVPUI\Blizzard_PVPUI.lua
local function GameTooltip_ShowProgressBar(tooltip)
    if not tooltip or not tooltip.progressBarPool or tooltip:IsForbidden() then return end

    local bar = tooltip.progressBarPool:GetNextActive()
    if not (bar and bar.Bar) then return end

    bar = bar.Bar
    if bar.BFIBackdrop then return end

    S.RemoveTextures(bar)
    S.CreateBackdrop(bar, nil, true)
    bar:SetStatusBarTexture(BFI.media.bar)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard(_, which)
    if which and which ~= "tooltip" then return end

    -- init
    for _, tooltip in next, {
        _G.EmbeddedItemTooltip,
        _G.FriendsTooltip,
        _G.GameTooltip,
        _G.ItemRefShoppingTooltip1,
        _G.ItemRefShoppingTooltip2,
        _G.ItemRefTooltip,
        _G.QuickKeybindTooltip,
        _G.ReputationParagonTooltip,
        _G.ShoppingTooltip1,
        _G.ShoppingTooltip2,
        _G.WorldMapTooltip,
        _G.LibDBIconTooltip,
        _G.SettingsTooltip,
    } do
        Style(tooltip)
    end

    -- EmbeddedItemTooltip.ItemTooltip
    local embeddedTooltip = _G.EmbeddedItemTooltip.ItemTooltip
    S.StyleIcon(embeddedTooltip.Icon, true) -- create backdrop
    S.StyleIconBorder(embeddedTooltip.IconBorder, embeddedTooltip.Icon.BFIBackdrop)

    -- GameTooltipStatusBar
    local bar = _G.GameTooltipStatusBar
    bar:SetStatusBarTexture(BFI.media.bar)
    bar:ClearAllPoints()
    AF.SetPoint(bar, "TOPLEFT", _G.GameTooltip, "BOTTOMLEFT", 1, 0)
    AF.SetPoint(bar, "TOPRIGHT", _G.GameTooltip, "BOTTOMRIGHT", -1, 0)
    S.CreateBackdrop(bar, nil, true)
    AF.AddToPixelUpdater(bar)

    -- hook
    hooksecurefunc("SharedTooltip_SetBackdropStyle", Style)
    hooksecurefunc("GameTooltip_ShowStatusBar", GameTooltip_ShowStatusBar)
    hooksecurefunc("GameTooltip_ShowProgressBar", GameTooltip_ShowProgressBar)
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)