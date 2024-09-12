---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class Maps
local M = BFI.Maps

local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap
local ExpansionButton = _G.ExpansionLandingPageMinimapButton
local minimapContainer

local GetMinimapZoneText = GetMinimapZoneText

---------------------------------------------------------------------
-- expansion button
---------------------------------------------------------------------
local function UpdateExpansionButton()
    local config = M.config.minimap.expansionButton
    if not config.enabled then
        ExpansionButton:Hide()
        return
    end

    ExpansionButton:SetParent(Minimap)

    AW.ClearPoints(ExpansionButton)
    AW.LoadWidgetPosition(ExpansionButton, config.position, minimapContainer)
    AW.SetSize(ExpansionButton, config.width, config.height)
end

---------------------------------------------------------------------
-- other widgets
---------------------------------------------------------------------
local function UpdateMinimapWidgets(widget, config)
    if not config.enabled then
        widget:Hide()
        return
    end

    widget:SetParent(Minimap)

    AW.ClearPoints(widget)
    AW.LoadWidgetPosition(widget, config.position, minimapContainer)
    AW.SetSize(widget, config.width, config.height)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function UpdatePixels()
    AW.DefaultUpdatePixels(minimapContainer)
    AW.DefaultUpdatePixels(Minimap)
    AW.DefaultUpdatePixels(ExpansionButton)
    AW.DefaultUpdatePixels(MinimapCluster.Tracking)
end

local function UpdateZoneText()
    AW.SetText(Minimap.zoneText, GetMinimapZoneText(), Minimap.zoneText.length)
    Minimap.zoneText:SetTextColor(MinimapZoneText:GetTextColor())
end

local function InitMinimap()
    -- MinimapCluster
    U.DisableEditMode(MinimapCluster)
    MinimapCluster:EnableMouse(false)

    -- minimapContainer
    minimapContainer = CreateFrame("Frame", "BFI_MinimapContainer", AW.UIParent, "BackdropTemplate")
    AW.StylizeFrame(minimapContainer)
    AW.CreateMover(minimapContainer, _G.OTHER, _G.HUD_EDIT_MODE_MINIMAP_LABEL)
    AW.AddToPixelUpdater(minimapContainer, UpdatePixels)

    -- Minimap
    Minimap.Layout = BFI.dummy -- MinimapCluster.IndicatorFrame
    Minimap:SetMaskTexture(AW.GetPlainTexture())
    Minimap:SetParent(minimapContainer)
    AW.SetPoint(Minimap, "TOPLEFT", 1, -1)
    AW.SetPoint(Minimap, "BOTTOMRIGHT", -1, 1)

    -- zoneText
    Minimap.zoneText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.zoneText:Hide()
    AW.CreateFadeInOutAnimation(Minimap.zoneText, 0.25)
    Minimap:HookScript("OnEnter", function()
        if Minimap.zoneText.enabled then
            Minimap.zoneText:FadeIn()
        end
    end)
    Minimap:HookScript("OnLeave", function()
        if Minimap.zoneText.enabled then
            Minimap.zoneText:FadeOut()
        end
    end)

    -- Minimap frames
    local frames = {
        _G.MinimapCompassTexture,
        Minimap.ZoomIn,
        Minimap.ZoomOut,
        MinimapCluster,
        -- MinimapCluster.BorderTop,
        -- MinimapCluster.Tracking.Background,
        -- MinimapCluster.IndicatorFrame,
        -- MinimapCluster.ZoneTextButton,
        _G.MinimapBackdrop,
        _G.GameTimeFrame,
    }

    for _, f in pairs(frames) do
        U.Hide(f)
    end

    -- expansion minimap button
    hooksecurefunc(ExpansionButton, "UpdateIcon", UpdateExpansionButton)

    -- Minimap:SetArchBlobRingAlpha(0)
    -- Minimap:SetArchBlobRingScalar(0)
    -- Minimap:SetQuestBlobRingAlpha(0)
    -- Minimap:SetQuestBlobRingScalar(0)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateMinimap(module, which)
    if module and module ~= "Maps" then return end
    if which and which ~= "minimap" then return end

    local config = M.config.minimap

    if minimapContainer then
        minimapContainer.enabled = config.enabled -- for mover
    end

    if not config.enabled then return end

    if not init then
        init = true
        InitMinimap()
        AW.UpdateMoverSave(minimapContainer, config.position)
    end

    -- minimap
    AW.ClearPoints(minimapContainer)
    AW.LoadPosition(minimapContainer, config.position)
    AW.SetSize(minimapContainer, config.width, config.height)
    Minimap:SetSize(Minimap:GetSize()) --! for ping

    -- expansion button
    UpdateExpansionButton()

    -- tracking button
    UpdateMinimapWidgets(MinimapCluster.Tracking, config.trackingButton)

    -- mail frame
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.MailFrame, config.mailFrame)
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:ClearAllPoints()
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:SetPoint("CENTER")

    -- crafting order frame
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.CraftingOrderFrame, config.craftingOrderFrame)
    MiniMapCraftingOrderIcon:ClearAllPoints()
    MiniMapCraftingOrderIcon:SetPoint("CENTER")

    -- zone text
    Minimap.zoneText.enabled = config.zoneText.enabled
    if config.zoneText.enabled then
        Minimap.zoneText.length = config.zoneText.length
        U.SetFont(Minimap.zoneText, unpack(config.zoneText.font))
        AW.LoadTextPosition(Minimap.zoneText, config.zoneText.position)
        M:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED", UpdateZoneText)
        UpdateZoneText()
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED", UpdateZoneText)
        Minimap.zoneText:Hide()
    end
end
BFI.RegisterCallback("UpdateModules", "M_Minimap", UpdateMinimap)