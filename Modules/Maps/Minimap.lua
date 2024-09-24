---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class Maps
local M = BFI.Maps

local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap
local ExpansionButton = _G.ExpansionLandingPageMinimapButton
local GameTimeFrame = _G.GameTimeFrame
local minimapContainer

local GameTime_GetTime = GameTime_GetTime
local GetMinimapZoneText = GetMinimapZoneText
local UIFrameFlash = UIFrameFlash
local UIFrameFlashStop = UIFrameFlashStop

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
    widget:Show()

    AW.ClearPoints(widget)
    AW.LoadWidgetPosition(widget, config.position, minimapContainer)
    AW.SetSize(widget, config.width, config.height)
end

---------------------------------------------------------------------
-- minimap addon buttons
---------------------------------------------------------------------
-- TODO: AddonCompartmentFrame
local addonButtonHolder

local function GetPositionArgs_HolderFrame()
    local p, x, y
    local anchor = addonButtonHolder.config.anchor
    local spacing = addonButtonHolder.config.spacing

    if anchor == "TOPLEFT" then
        p = "BOTTOMLEFT"
        x, y = 0, spacing
    elseif anchor == "TOPRIGHT" then
        p = "BOTTOMRIGHT"
        x, y = 0, spacing
    elseif anchor == "BOTTOMLEFT" then
        p = "TOPLEFT"
        x, y = 0, -spacing
    elseif anchor == "BOTTOMRIGHT" then
        p = "TOPRIGHT"
        x, y = 0, -spacing
    elseif anchor == "TOP" then
        p = "BOTTOM"
        x, y = 0, spacing
    elseif anchor == "BOTTOM" then
        p = "TOP"
        x, y = 0, -spacing
    elseif anchor == "LEFT" then
        p = "RIGHT"
        x, y = -spacing, 0
    elseif anchor == "RIGHT" then
        p = "LEFT"
        x, y = spacing, 0
    end

    return p, anchor, x, y
end

local function UpdateAddonButtons()
    if not addonButtonHolder.init then return end

    -- create
    local name
    for _, child in pairs({Minimap:GetChildren()}) do
        name = child:GetName()
        if name and strfind(name, "^LibDBIcon10_") then
            if not child.isHandled then
                child.isHandled = true
                tinsert(addonButtonHolder.buttons, child)

                for _, obj in pairs({child:GetRegions()}) do
                    if obj ~= child.icon then
                        obj:Hide()
                    end
                end

                child:SetScript("OnDragStart", nil)
                child:SetScript("OnDragStop", nil)
                child:SetParent(addonButtonHolder.frame)
                child:RegisterForDrag()
                AW.SetOnePixelInside(child.icon, child)
                AW.StylizeFrame(child)

                -- re-arrange when show/hide
                child:HookScript("OnShow", UpdateAddonButtons)
                child:HookScript("OnHide", UpdateAddonButtons)
            end
        end
    end

    -- check visibility
    wipe(addonButtonHolder.shownButtons)
    for _, b in pairs(addonButtonHolder.buttons) do
        if b:IsShown() then
            tinsert(addonButtonHolder.shownButtons, b)
        end
    end

    -- re-arrange
    local p, rp, np, x, y, nx, ny = AW.GetAnchorPoints_Simple(addonButtonHolder.buttonAnchor, addonButtonHolder.config.orientation, addonButtonHolder.config.spacing)
    for i, b in pairs(addonButtonHolder.shownButtons) do
        AW.ClearPoints(b)
        AW.SetSize(b, addonButtonHolder.config.width, addonButtonHolder.config.height)

        if i == 1 then
            AW.SetPoint(b, p)
        elseif i % addonButtonHolder.config.numPerLine == 1 then
            AW.SetPoint(b, p, addonButtonHolder.shownButtons[i - addonButtonHolder.config.numPerLine], np, nx, ny)
        else
            AW.SetPoint(b, p, addonButtonHolder.shownButtons[i - 1], rp, x, y)
        end
    end

    local num = #addonButtonHolder.shownButtons
    AW.SetGridSize(addonButtonHolder.frame, addonButtonHolder.config.width, addonButtonHolder.config.height,
        addonButtonHolder.config.spacing, addonButtonHolder.config.spacing,
        min(addonButtonHolder.config.numPerLine, num), ceil(num / addonButtonHolder.config.numPerLine)
    )
end

local function CreateAddonButtonHolder()
    local lib = LibStub("LibDBIcon-1.0", true)
    if not lib then return end

    lib:RegisterCallback("LibDBIcon_IconCreated", UpdateAddonButtons)

    -- button
    addonButtonHolder = AW.CreateButton(Minimap, "", "accent-hover", 20, 20)
    -- addonButtonHolder:Hide()
    addonButtonHolder:SetTexture(AW.GetIcon("Menu"), {20, 20}, {"CENTER", 0, 0}, nil, true)
    AW.RemoveFromPixelUpdater(addonButtonHolder)
    AW.CreateFadeInOutAnimation(addonButtonHolder, 0.25, true)

    addonButtonHolder.buttons = {}
    addonButtonHolder.shownButtons = {}

    -- container frame
    local frame = CreateFrame("Frame", nil, addonButtonHolder)
    addonButtonHolder.frame = frame
    AW.SetPoint(frame, "BOTTOMLEFT", addonButtonHolder, "TOPLEFT", 0, 1)
    frame:Hide()

    addonButtonHolder:SetScript("OnClick", function()
        if frame:IsShown() then
            frame:Hide()
        else
            UpdateAddonButtons()
            frame:Show()
        end
    end)

    addonButtonHolder:HookScript("OnEnter", function()
        if not frame:IsShown() and addonButtonHolder.FadeIn and addonButtonHolder.config.fadeOut then
            addonButtonHolder:FadeIn()
        end
    end)

    addonButtonHolder:HookScript("OnLeave", function()
        if not frame:IsShown() and addonButtonHolder.config.fadeOut then
            addonButtonHolder:FadeOut()
        end
    end)

    addonButtonHolder.init = true
end

---------------------------------------------------------------------
-- zone text
---------------------------------------------------------------------
local function UpdateZoneText()
    AW.SetText(Minimap.zoneText, GetMinimapZoneText(), Minimap.zoneText.length)
    Minimap.zoneText:SetTextColor(MinimapZoneText:GetTextColor())
end

local function CreateZoneText()
    -- zoneText
    Minimap.zoneText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.zoneText:Hide()
    AW.CreateFadeInOutAnimation(Minimap.zoneText, 0.25)

    Minimap.onEnter = function()
        if Minimap.zoneText.enabled then
            Minimap.zoneText:FadeIn()
        end
    end

    Minimap.onLeave = function()
        if Minimap.zoneText.enabled then
            Minimap.zoneText:FadeOut()
        end
    end

    Minimap:HookScript("OnEnter", Minimap.onEnter)
    Minimap:HookScript("OnLeave", Minimap.onLeave)
end

---------------------------------------------------------------------
-- clock
---------------------------------------------------------------------
local function UpdateClockSize()
    local width = ceil(Minimap.clockButton.text:GetWidth() + 2)
    local height = ceil(Minimap.clockButton.text:GetHeight() + 2)
    Minimap.clockButton:SetSize(width, height)
end

local function UpdateClockTime()
    Minimap.clockButton.text:SetText(GameTime_GetTime(false))
end

local function UpdateClockFlash()

end

local function CreateClockButton()
    local clockButton = CreateFrame("Button", "BFI_MinimapClock", Minimap)
    Minimap.clockButton = clockButton

    -- AW.SetDefaultBackdrop(clockButton)
    -- clockButton:SetBackdropBorderColor(AW.GetColorRGB("border"))
    -- clockButton:SetBackdropColor(AW.GetColorRGB("background"))

    -- alarm flash
    local flash = CreateFrame("Frame", nil, clockButton)
    Minimap.clockButton.flash = flash
    flash:Hide()
    flash:SetAllPoints()
    flash:SetFrameLevel(clockButton:GetFrameLevel())

    flash.texture = flash:CreateTexture(nil, "BORDER")
    flash.texture:SetTexture(AW.GetPlainTexture())
    flash.texture:SetAllPoints()

    -- hook alarm
    hooksecurefunc("TimeManager_FireAlarm", function()
        UIFrameFlash(flash, 0.5, 0.5, -1)
    end)
    hooksecurefunc("TimeManager_TurnOffAlarm", function()
        UIFrameFlashStop(flash)
    end)

    -- text
    local text = clockButton:CreateFontString(nil, "OVERLAY")
    Minimap.clockButton.text = text
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    -- OnClick
    clockButton:SetScript("OnClick", function()
        _G.TimeManagerFrame:ClearAllPoints()
        if Minimap:GetBottom() > 240 then
            _G.TimeManagerFrame:SetPoint("TOP", Minimap, "BOTTOM")
        else
            _G.TimeManagerFrame:SetPoint("BOTTOM", Minimap, "TOP")
        end

        if _G.TimeManagerClockButton.alarmFiring then
            PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
            TimeManager_TurnOffAlarm()
        else
            TimeManager_Toggle()
        end
    end)

    -- OnUpdate
    clockButton:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            UpdateClockTime()
        end
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function UpdatePixels()
    AW.DefaultUpdatePixels(minimapContainer)
    AW.DefaultUpdatePixels(Minimap)
    AW.DefaultUpdatePixels(ExpansionButton)
    AW.DefaultUpdatePixels(MinimapCluster.Tracking)
    -- TODO: addonButtonHolder
    -- TODO: Minimap.clockButton
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

    -- Minimap frames
    local frames = {
        _G.MinimapCompassTexture,
        Minimap.ZoomIn,
        Minimap.ZoomOut,
        Minimap.ZoomHitArea,
        -- MinimapCluster,
        MinimapCluster.Tracking.Background,
        -- MinimapCluster.BorderTop,
        -- MinimapCluster.IndicatorFrame,
        -- MinimapCluster.ZoneTextButton,
        _G.MinimapBackdrop,
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
        CreateAddonButtonHolder()
        CreateZoneText()
        CreateClockButton()
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

    -- calendar
    UpdateMinimapWidgets(GameTimeFrame, config.calendar)

    -- clock
    if config.clock.enabled then
        Minimap.clockButton:Show()
        AW.LoadWidgetPosition(Minimap.clockButton, config.clock.position)
        U.SetFont(Minimap.clockButton.text, unpack(config.clock.font))
        Minimap.clockButton.text:SetText("00:00")
        UpdateClockSize()

        -- flash
        local anchor = config.clock.position[1]
        local flashTexture = Minimap.clockButton.flash.texture
        if anchor == "TOP" then
            flashTexture:SetGradient("VERTICAL", CreateColor(AW.GetColorRGB("none")), CreateColor(AW.GetColorRGB("accent")))
        elseif strfind(anchor, "LEFT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AW.GetColorRGB("accent")), CreateColor(AW.GetColorRGB("none")))
        elseif strfind(anchor, "RIGHT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AW.GetColorRGB("none")), CreateColor(AW.GetColorRGB("accent")))
        else -- BOTTOM / CENTER
            flashTexture:SetGradient("VERTICAL", CreateColor(AW.GetColorRGB("accent")), CreateColor(AW.GetColorRGB("none")))
        end
    else
        Minimap.clockButton:Hide()
    end

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
        Minimap.zoneText:Show()
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED", UpdateZoneText)
        Minimap.zoneText:Hide()
    end

    -- minimap button holder
    addonButtonHolder.enabled = config.addonButtonHolder.enabled
    if config.addonButtonHolder.enabled then
        addonButtonHolder.config = config.addonButtonHolder

        addonButtonHolder:Show()
        if addonButtonHolder.config.fadeOut then
            addonButtonHolder:FadeOut()
        else
            addonButtonHolder:FadeIn()
        end

        AW.LoadWidgetPosition(addonButtonHolder, config.addonButtonHolder.position, Minimap)
        AW.SetSize(addonButtonHolder, config.addonButtonHolder.width, config.addonButtonHolder.height)

        local p, rp, x, y = GetPositionArgs_HolderFrame()
        addonButtonHolder.buttonAnchor = p
        AW.ClearPoints(addonButtonHolder.frame)
        AW.SetPoint(addonButtonHolder.frame, p, addonButtonHolder, rp, x, y)

        UpdateAddonButtons()
    else
        addonButtonHolder:Hide()
    end
end
BFI.RegisterCallback("UpdateModules", "M_Minimap", UpdateMinimap)