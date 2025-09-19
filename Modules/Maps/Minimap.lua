---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local M = BFI.modules.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local GameTooltip = _G.GameTooltip
local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap
local ExpansionButton = _G.ExpansionLandingPageMinimapButton
local GameTimeFrame = _G.GameTimeFrame
local minimapContainer

local GameTime_GetTime = GameTime_GetTime

local GetDifficultyName = DifficultyUtil.GetDifficultyName

local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = C_PvP.GetZonePVPInfo

local IsInInstance = IsInInstance
local InGuildParty = InGuildParty
local GetInstanceInfo = GetInstanceInfo
local GetGuildInfo = GetGuildInfo
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetPersonalOrdersInfo = C_CraftingOrders.GetPersonalOrdersInfo

local ToggleCalendar = ToggleCalendar
local GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local GetNumPendingInvites = C_Calendar.GetNumPendingInvites

---------------------------------------------------------------------
-- expansion button
---------------------------------------------------------------------
local function UpdateExpansionButton(_, forceUpdateButton)
    local config = M.config.minimap.expansionButton
    if not config.enabled then
        ExpansionButton:Hide()
        return
    end

    ExpansionButton:SetParent(Minimap)
    if forceUpdateButton then
        ExpansionButton:RefreshButton(true)
    end

    AF.ClearPoints(ExpansionButton)
    AF.LoadWidgetPosition(ExpansionButton, config.position, minimapContainer)
    AF.SetSize(ExpansionButton, config.size, config.size)
end

---------------------------------------------------------------------
-- other widgets
---------------------------------------------------------------------
local function UpdateMinimapWidgets(widget, config, shouldShow)
    if not config.enabled then
        widget:Hide()
        return
    end

    widget:SetParent(Minimap)
    widget:SetShown(shouldShow)

    AF.ClearPoints(widget)
    AF.LoadWidgetPosition(widget, config.position, minimapContainer)

    if config.size then
        AF.SetSize(widget, config.size, config.size)
    elseif config.scale then
        widget:SetScale(config.scale)
    end
end

---------------------------------------------------------------------
-- minimap addon buttons
---------------------------------------------------------------------
-- TODO: AddonCompartmentFrame
local addonButtonTray

local function GetPositionArgs_TrayFrame()
    local p, x, y
    local anchor = M.config.minimap.addonButtonTray.anchor
    local spacing = M.config.minimap.addonButtonTray.spacing

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
    if not addonButtonTray.init then return end

    -- create
    local name
    for _, child in pairs({Minimap:GetChildren()}) do
        name = child:GetName()
        if name and strfind(name, "^LibDBIcon10_") then
            if not child.isHandled then
                child.isHandled = true
                tinsert(addonButtonTray.buttons, child)

                for _, obj in pairs({child:GetRegions()}) do
                    if obj ~= child.icon then
                        obj:Hide()
                    end
                end

                child:SetScript("OnDragStart", nil)
                child:SetScript("OnDragStop", nil)
                child:SetParent(addonButtonTray.frame)
                child:RegisterForDrag()
                AF.SetOnePixelInside(child.icon, child)
                AF.ApplyDefaultBackdropWithColors(child)

                -- re-arrange when show/hide
                child:HookScript("OnShow", UpdateAddonButtons)
                child:HookScript("OnHide", UpdateAddonButtons)
            end
        end
    end

    -- check visibility
    wipe(addonButtonTray.shownButtons)
    for _, b in pairs(addonButtonTray.buttons) do
        if b:IsShown() then
            tinsert(addonButtonTray.shownButtons, b)
        end
    end

    -- re-arrange
    local config = M.config.minimap.addonButtonTray
    local p, rp, np, x, y, nx, ny = AF.GetAnchorPoints_Complex(config.arrangement, config.spacing)
    for i, b in pairs(addonButtonTray.shownButtons) do
        AF.ClearPoints(b)
        AF.SetSize(b, config.size, config.size)

        if i == 1 then
            AF.SetPoint(b, p)
        elseif config.numPerLine == 1 or i % config.numPerLine == 1 then
            AF.SetPoint(b, p, addonButtonTray.shownButtons[i - config.numPerLine], np, nx, ny)
        else
            AF.SetPoint(b, p, addonButtonTray.shownButtons[i - 1], rp, x, y)
        end
    end

    local num = #addonButtonTray.shownButtons
    AF.SetGridSize(addonButtonTray.frame, config.size, config.size,
        config.spacing, config.spacing,
        min(config.numPerLine, num), ceil(num / config.numPerLine)
    )
end

local function CreateAddonButtonTray()
    local lib = LibStub("LibDBIcon-1.0", true)
    if not lib then return end

    lib:RegisterCallback("LibDBIcon_IconCreated", UpdateAddonButtons)

    -- button
    addonButtonTray = AF.CreateButton(Minimap, "", "BFI_hover", 20, 20)
    AF.RemoveFromPixelUpdater(addonButtonTray)
    AF.CreateFadeInOutAnimation(addonButtonTray, 0.25, true)

    addonButtonTray:SetTexture(AF.GetIcon("Menu3"))
    addonButtonTray:EnablePushEffect(false)
    AF.SetOnePixelInside(addonButtonTray.texture, addonButtonTray)
    -- addonButtonTray:SetOnMouseDown(function()
    --     AF.SetSize(addonButtonTray.texture, M.config.minimap.addonButtonTray.size - 2, M.config.minimap.addonButtonTray.size - 2)
    -- end)
    -- addonButtonTray:SetOnMouseUp(function()
    --     AF.SetSize(addonButtonTray.texture, M.config.minimap.addonButtonTray.size, M.config.minimap.addonButtonTray.size)
    -- end)

    addonButtonTray.buttons = {}
    addonButtonTray.shownButtons = {}

    -- container frame
    local frame = CreateFrame("Frame", nil, addonButtonTray)
    addonButtonTray.frame = frame
    AF.SetPoint(frame, "BOTTOMLEFT", addonButtonTray, "TOPLEFT", 0, 1)
    frame:Hide()

    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetAllPoints()

    -- scripts
    addonButtonTray:SetScript("OnClick", function()
        if frame:IsShown() then
            frame:Hide()
        else
            UpdateAddonButtons()
            frame:Show()
        end
    end)

    addonButtonTray:HookScript("OnEnter", function()
        if M.config.minimap.addonButtonTray.enabled and not frame:IsShown() and not M.config.minimap.addonButtonTray.alwaysShow then
            addonButtonTray:FadeIn()
        end
    end)

    addonButtonTray:HookScript("OnLeave", function()
        if M.config.minimap.addonButtonTray.enabled and not frame:IsShown() and not M.config.minimap.addonButtonTray.alwaysShow then
            addonButtonTray:FadeOut()
        end
    end)

    addonButtonTray.init = true
end

---------------------------------------------------------------------
-- zone text
---------------------------------------------------------------------
-- Minimap_Update: Interface\AddOns\Blizzard_Minimap\Mainline\Minimap.lua
local function GetZoneTextColor()
    local pvpType = GetZonePVPInfo()
    if pvpType == "sanctuary" then
        return 0.41, 0.8, 0.94
    elseif pvpType == "arena" then
        return 1.0, 0.1, 0.1
    elseif pvpType == "friendly" then
        return 0.1, 1.0, 0.1
    elseif pvpType == "hostile" then
        return 1.0, 0.1, 0.1
    elseif pvpType == "contested" then
        return 1.0, 0.7, 0.0
    else
        return NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
    end
end

local function UpdateZoneText()
    local zoneText = Minimap.zoneText
    -- AF.SetText(Minimap.zoneText, GetMinimapZoneText(), Minimap.zoneText.length)
    zoneText:SetText(GetMinimapZoneText())
    -- zoneText:SetTextColor(MinimapZoneText:GetTextColor()) -- not reliable
    zoneText:SetTextColor(GetZoneTextColor())
end

local function CreateZoneText()
    local zoneText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.zoneText = zoneText
    zoneText:Hide()
    zoneText:SetWordWrap(true)
    zoneText:SetSpacing(5)
    AF.CreateFadeInOutAnimation(zoneText, 0.25)


    Minimap:HookScript("OnEnter", function()
        if M.config.minimap.zoneText.enabled and not M.config.minimap.zoneText.alwaysShow then
            zoneText:FadeIn()
        end
    end)
    Minimap:HookScript("OnLeave", function()
        if M.config.minimap.zoneText.enabled and not M.config.minimap.zoneText.alwaysShow then
            zoneText:FadeOut()
        end
    end)
end

---------------------------------------------------------------------
-- clock
---------------------------------------------------------------------
local function UpdateClockTime(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.1 then
        self.elapsed = 0
        self.text:SetText(GameTime_GetTime(false))
    end
end

local function UpdateClockSize()
    -- local w, h = AF.GetStringSize("00:00", unpack(M.config.minimap.clock.font))
    -- Minimap.clockButton:SetSize(w + 4, h + 4)
    AF.ResizeToFitText(Minimap.clockButton, Minimap.clockButton.hiddenText, 2, 2)
end

local function CreateClockButton()
    local clockButton = CreateFrame("Button", "BFI_MinimapClock", Minimap)
    Minimap.clockButton = clockButton

    -- AF.ApplyDefaultBackdrop(clockButton)
    -- clockButton:SetBackdropBorderColor(AF.GetColorRGB("border"))
    -- clockButton:SetBackdropColor(AF.GetColorRGB("background"))

    -- alarm flash
    local flash = CreateFrame("Frame", nil, clockButton)
    Minimap.clockButton.flash = flash
    flash:Hide()
    flash:SetAllPoints()
    flash:SetFrameLevel(clockButton:GetFrameLevel())

    flash.texture = flash:CreateTexture(nil, "BORDER")
    flash.texture:SetTexture(AF.GetPlainTexture())
    flash.texture:SetAllPoints()

    -- hook alarm
    hooksecurefunc("TimeManager_FireAlarm", function()
        AF.FrameFlashStart(flash)
    end)
    hooksecurefunc("TimeManager_TurnOffAlarm", function()
        AF.FrameFlashStop(flash)
    end)

    -- text
    local text = clockButton:CreateFontString(nil, "OVERLAY")
    Minimap.clockButton.text = text
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    local hiddenText = clockButton:CreateFontString(nil, "OVERLAY")
    Minimap.clockButton.hiddenText = hiddenText
    hiddenText:SetPoint("CENTER")
    hiddenText:SetJustifyH("CENTER")
    hiddenText:SetJustifyV("MIDDLE")
    hiddenText:SetAlpha(0)

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
    clockButton.elapsed = 0
    clockButton:SetScript("OnUpdate", UpdateClockTime)
end

---------------------------------------------------------------------
-- instance difficulty
---------------------------------------------------------------------
local function GetString(arg1, arg2)
    if not arg2 then
        arg2 = arg1.text
        arg1 = arg1.color
    end
    return AF.WrapTextInColorRGB(arg2, AF.UnpackColor(arg1))
end

-- https://warcraft.wiki.gg/wiki/DifficultyID
local DIFFICULTY_INFO = {
    [1] = "normal", -- Normal, party
    [2] = "heroic", -- Heroic, party
    [3] = "normal", -- 10 Player, raid
    [4] = "normal", -- 25 Player, raid
    [5] = "heroic", -- 10 Player (Heroic), raid
    [6] = "heroic", -- 25 Player (Heroic), raid
    [7] = "raidFinder", -- Looking For Raid, raid
    [8] = "mythicPlus", -- Mythic Keystone, party
    [9] = "normal", -- 40 Player, raid
    [14] = "normal", -- Normal, raid
    [15] = "heroic", -- Heroic, raid
    [16] = "mythic", -- Mythic, raid
    [17] = "raidFinder", -- Looking For Raid, raid
    [18] = "event", -- Event, raid
    [19] = "event", -- Event, party
    [20] = "event", -- Event Scenario, scenario
    [23] = "mythic", -- Mythic, party
    [24] = "timewalking", -- Timewalking, party
    [30] = "event", -- Event, scenario
    [33] = "timewalking", -- Timewalking, raid
    [151] = "timewalking", -- Looking For Raid, Timewalking, raid
    [205] = "followerDungeon",
    [208] = "delve",
    [220] = "raidStory",
}

local function UpdateInstanceDifficulty(_, event, arg)
    -- NOTE: IsInGuildGroup() seems not correct, InGuildParty() seems fine
    if event == "GUILD_PARTY_STATE_UPDATED" then
        Minimap.instanceDifficultyFrame.isGuildGroup = arg
    end

    if IsInInstance() then
        local _, instanceType, difficulty, _, _, _, _, _, groupSize = GetInstanceInfo()

        local config = M.config.minimap.instanceDifficulty

        if difficulty and DIFFICULTY_INFO[difficulty] then
            groupSize = GetString(Minimap.instanceDifficultyFrame.isGuildGroup and config.guildColor or config.normalColor, groupSize)
            difficulty = GetString(config.types[DIFFICULTY_INFO[difficulty]])

            Minimap.instanceDifficultyFrame.text:SetText(groupSize .. difficulty)
            Minimap.instanceDifficultyFrame:Show()

        elseif instanceType == "pvp" or instanceType == "arena" then
            Minimap.instanceDifficultyFrame.text:SetText(GetString(config.types.pvp))
            Minimap.instanceDifficultyFrame:Show()

        elseif instanceType == "scenario" then
            Minimap.instanceDifficultyFrame.text:SetText(GetString(config.types.scenario))
            Minimap.instanceDifficultyFrame:Show()

        else
            Minimap.instanceDifficultyFrame:Hide()
        end
    else
        Minimap.instanceDifficultyFrame:Hide()
    end

    AF.ResizeToFitText(Minimap.instanceDifficultyFrame, Minimap.instanceDifficultyFrame.text, 1, 1)
end

local function UpdateGuild()
    if IsInGuild() then
        RequestGuildPartyState()
    else
        Minimap.instanceDifficultyFrame.isGuildGroup = false
        UpdateInstanceDifficulty()
    end
end

local DUNGEON_DIFFICULTY_BANNER_TOOLTIP = _G.DUNGEON_DIFFICULTY_BANNER_TOOLTIP
local GUILD_GROUP = _G.GUILD_GROUP
local GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP = _G.GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP
local GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP = _G.GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP
local GUILD_ACHIEVEMENTS_ELIGIBLE = _G.GUILD_ACHIEVEMENTS_ELIGIBLE
local PLAYER_DIFFICULTY3 = _G.PLAYER_DIFFICULTY3

local function CreateInstanceDifficulty()
    local instanceDifficultyFrame = CreateFrame("Frame", "BFI_InstanceDifficultyFrame", Minimap)
    Minimap.instanceDifficultyFrame = instanceDifficultyFrame
    -- instanceDifficultyFrame:SetSize(30, 20)
    -- instanceDifficultyFrame:SetPoint("TOPLEFT")
    instanceDifficultyFrame.text = instanceDifficultyFrame:CreateFontString(nil, "OVERLAY")
    instanceDifficultyFrame.text:SetPoint("CENTER")

    instanceDifficultyFrame.tooltip = {
        enabled = true,
        anchorTo = "self_adaptive",
    }

    -- NOTE: GuildInstanceDifficultyMixin.OnEnter
    -- instanceDifficultyFrame:SetScript("OnEnter", GuildInstanceDifficultyMixin.OnEnter)
    instanceDifficultyFrame:SetScript("OnEnter", function(self)
        local instanceName, instanceType, difficulty, difficultyName, maxPlayers, _, _, _, instanceGroupSize, lfgID = GetInstanceInfo()
        if instanceType ~= "party" and instanceType ~= "raid" then return end

        difficultyName = GetDifficultyName(difficulty) or difficultyName
        local isLFR = select(8, GetDifficultyInfo(difficulty))

        GameTooltip_SetDefaultAnchor(GameTooltip, self)

        if isLFR and lfgID then
            local name = GetLFGDungeonInfo(lfgID)
            GameTooltip_SetTitle(GameTooltip, PLAYER_DIFFICULTY3)
            GameTooltip_AddNormalLine(GameTooltip, name)
            -- GameTooltip_AddNormalLine(GameTooltip, _G.DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers))

        elseif difficultyName then
            GameTooltip_SetTitle(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP:format(difficultyName))
            GameTooltip_AddNormalLine(GameTooltip, instanceName)
            -- GameTooltip_AddNormalLine(GameTooltip, _G.DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers))

            if self.isGuildGroup then
                local guildName = GetGuildInfo("player")
                local _, numGuildPresent, numGuildRequired, xpMultiplier = InGuildParty()

                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddColoredLine(GameTooltip, GUILD_GROUP, GREEN_FONT_COLOR)

                if xpMultiplier < 1 then
                    GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP:format(numGuildRequired, instanceGroupSize, guildName, xpMultiplier * 100), true)
                elseif xpMultiplier > 1 then
                    GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP:format(guildName, xpMultiplier * 100), true)
                else
                    if instanceType == "party" and maxPlayers == 5 then
                        numGuildRequired = 4
                    end
                    GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, instanceGroupSize, guildName), true)
                end
            end
        end

        GameTooltip:Show()
    end)

    instanceDifficultyFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

---------------------------------------------------------------------
-- calendar
---------------------------------------------------------------------
local function CreateCalendarButton()
    local calendar = AF.CreateIconButton(Minimap, AF.GetEmptyTexture(), nil, nil, nil, "gray", "white")
    Minimap.calendarButton = calendar
    AF.RemoveFromPixelUpdater(calendar)

    calendar:SetOnClick(function()
        ToggleCalendar()
        AF.FrameFlashStop(calendar.flash)
    end)

    calendar:HookOnEnter(function()
        if GetNumPendingInvites() ~= 0 then
            local _, p, mult = AF.GetAdaptiveAnchor_Vertical(calendar)
            AF.ShowTooltip(calendar, p, 0, mult * 2, {_G.GAMETIME_TOOLTIP_CALENDAR_INVITES})
        end
    end)
    calendar:HookOnLeave(AF.HideTooltip)

    -- shadow
    calendar.shadow = calendar:CreateTexture(nil, "BORDER")
    AF.SetPoint(calendar.shadow, "TOPLEFT", calendar.icon, 1, -1)
    AF.SetPoint(calendar.shadow, "BOTTOMRIGHT", calendar.icon, 1, -1)
    calendar.shadow:SetTexture(AF.GetEmptyTexture())
    calendar.shadow:SetVertexColor(AF.GetColorRGB("background"))

    -- flash
    calendar.flash = calendar:CreateTexture(nil, "OVERLAY")
    calendar.flash:SetAllPoints(calendar.icon)
    calendar.flash:SetTexture(AF.GetEmptyTexture())
    calendar.flash:SetVertexColor(AF.GetColorRGB("BFI"))
    calendar.flash:Hide()

    hooksecurefunc(calendar.icon, "SetTexture", function(_, ...)
        calendar.shadow:SetTexture(...)
        calendar.flash:SetTexture(...)
    end)

    function calendar:UpdatePixels()
        AF.ReSize(self)
        AF.RePoint(self)
        AF.RePoint(self.icon)
        AF.RePoint(self.shadow)
        AF.RePoint(self.flash)
    end

    -- CVarCallbackRegistry:RegisterCallback("restrictCalendarInvites", UpdateCalendar, calendar)
end

local function UpdateCalendar()
    local d = GetCurrentCalendarTime()
    Minimap.calendarButton:SetIcon(AF.GetCalendarIcon("day", d.monthDay))
end

local function UpdateCalendarInvites()
    local n = GetNumPendingInvites()
    if n ~= 0 then
        AF.FrameFlashStart(Minimap.calendarButton.flash, 1)
    else
        AF.FrameFlashStop(Minimap.calendarButton.flash)
    end
end

local scheduler
local function ScheduleCalendarUpdate()
    M:UnregisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate)
    UpdateCalendar()
    if scheduler then scheduler:Cancel() end
    scheduler = C_Timer.NewTimer(AF.GetNextDaySeconds(true), ScheduleCalendarUpdate)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function UpdatePixels()
    AF.DefaultUpdatePixels(minimapContainer)
    AF.DefaultUpdatePixels(Minimap)
    AF.DefaultUpdatePixels(ExpansionButton)
    AF.DefaultUpdatePixels(MinimapCluster.Tracking)
    AF.DefaultUpdatePixels(addonButtonTray)
    AF.DefaultUpdatePixels(addonButtonTray.frame)
    for _, b in pairs(addonButtonTray.buttons) do
        AF.DefaultUpdatePixels(b)
    end
    AF.DefaultUpdatePixels(Minimap.clockButton)
    AF.DefaultUpdatePixels(Minimap.instanceDifficultyFrame)
    UpdateClockSize()
    Minimap.calendarButton:UpdatePixels()
end

local function InitMinimap()
    -- MinimapCluster
    F.DisableEditMode(MinimapCluster)
    MinimapCluster:EnableMouse(false)

    -- minimapContainer
    minimapContainer = CreateFrame("Frame", "BFI_MinimapContainer", AF.UIParent, "BackdropTemplate")
    AF.ApplyDefaultBackdropWithColors(minimapContainer)
    AF.CreateMover(minimapContainer, "BFI: " .. _G.OTHER, _G.HUD_EDIT_MODE_MINIMAP_LABEL)
    AF.AddToPixelUpdater_Auto(minimapContainer, UpdatePixels)

    -- Minimap
    Minimap.Layout = AF.noop -- MinimapCluster.IndicatorFrame
    Minimap:SetMaskTexture(AF.GetPlainTexture())
    Minimap:SetParent(minimapContainer)
    AF.SetOnePixelInside(Minimap)

    -- Minimap frames
    local frames = {
        _G.MinimapCompassTexture,
        Minimap.ZoomIn,
        Minimap.ZoomOut,
        Minimap.ZoomHitArea,
        MinimapCluster,
        MinimapCluster.Tracking.Background,
        -- MinimapCluster.BorderTop,
        -- MinimapCluster.IndicatorFrame,
        -- MinimapCluster.ZoneTextButton,
        _G.MinimapBackdrop,
    }

    for _, f in pairs(frames) do
        F.Hide(f)
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
local function UpdateMinimap(_, module, which)
    if module and module ~= "maps" then return end
    if which and which ~= "minimap" then return end

    local config = M.config.minimap

    if minimapContainer then
        minimapContainer.enabled = config.general.enabled -- for mover
    end

    if not config.general.enabled then return end

    if not init then
        init = true
        InitMinimap()
        CreateAddonButtonTray()
        CreateZoneText()
        CreateClockButton()
        CreateInstanceDifficulty()
        CreateCalendarButton()
    end

    AF.UpdateMoverSave(minimapContainer, config.general.position)

    -- minimap
    AF.ClearPoints(minimapContainer)
    AF.LoadPosition(minimapContainer, config.general.position)
    AF.SetSize(minimapContainer, config.general.size, config.general.size)
    Minimap:SetSize(Minimap:GetSize()) --! for ping
    Minimap:SetZoom(0)

    -- expansion button
    UpdateExpansionButton(nil, true)

    -- tracking button
    UpdateMinimapWidgets(MinimapCluster.Tracking, config.trackingButton, true)

    -- calendar
    -- UpdateMinimapWidgets(GameTimeFrame, config.calendar2, true)
    UpdateMinimapWidgets(Minimap.calendarButton, config.calendar, true)
    if config.calendar.enabled then
        UpdateCalendarInvites()
        ScheduleCalendarUpdate()
        M:RegisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate, UpdateCalendarInvites)
        M:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", UpdateCalendarInvites)
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate, UpdateCalendarInvites)
        M:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", UpdateCalendarInvites)
        AF.FrameFlashStop(Minimap.calendarButton.flash)
    end

    -- clock
    if config.clock.enabled then
        AF.SetFont(Minimap.clockButton.text, config.clock.font)
        AF.LoadWidgetPosition(Minimap.clockButton, config.clock.position)
        Minimap.clockButton.text:SetTextColor(AF.UnpackColor(config.clock.color))

        -- flash
        local anchor = config.clock.position[1]
        local flashTexture = Minimap.clockButton.flash.texture
        if anchor:find("^TOP") then
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        elseif anchor:find("LEFT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        elseif anchor:find("RIGHT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        else -- BOTTOM / CENTER
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        end

        Minimap.clockButton:Show()
        -- M:RegisterEvent("FIRST_FRAME_RENDERED", UpdateClockSize)
        -- UpdateClockSize()

        AF.SetFont(Minimap.clockButton.hiddenText, config.clock.font)
        Minimap.clockButton.hiddenText:SetText("00:00")
        RunNextFrame(UpdateClockSize)
    else
        Minimap.clockButton:Hide()
        -- M:UnregisterEvent("FIRST_FRAME_RENDERED", UpdateClockSize)
    end

    -- mail frame
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.MailFrame, config.mailFrame, true)
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:ClearAllPoints()
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:SetPoint("CENTER")

    -- crafting order frame
    local orders = GetPersonalOrdersInfo()
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.CraftingOrderFrame, config.craftingOrderFrame, #orders > 0)
    MiniMapCraftingOrderIcon:ClearAllPoints()
    MiniMapCraftingOrderIcon:SetPoint("CENTER")

    -- zone text
    if config.zoneText.enabled then
        AF.SetFont(Minimap.zoneText, config.zoneText.font)
        AF.LoadTextPosition(Minimap.zoneText, config.zoneText.position, Minimap)
        AF.SetWidth(Minimap.zoneText, config.general.size * config.zoneText.length)
        M:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED", UpdateZoneText)
        UpdateZoneText()
        Minimap.zoneText:Show()
        if config.zoneText.alwaysShow then
            Minimap.zoneText:FadeIn()
        else
            Minimap.zoneText:FadeOut()
        end
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED", UpdateZoneText)
        Minimap.zoneText:Hide()
    end

    -- dungeon difficulty
    if config.instanceDifficulty.enabled then
        AF.LoadWidgetPosition(Minimap.instanceDifficultyFrame, config.instanceDifficulty.position)
        AF.SetFont(Minimap.instanceDifficultyFrame.text, config.instanceDifficulty.font)
        M:RegisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        Minimap.instanceDifficultyFrame:Show()
        UpdateInstanceDifficulty()
    else
        M:UnregisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        Minimap.instanceDifficultyFrame:Hide()
    end

    -- minimap button tray
    addonButtonTray.enabled = config.addonButtonTray.enabled
    if config.addonButtonTray.enabled then
        addonButtonTray:Show()
        if not addonButtonTray.frame:IsShown() then
            if config.addonButtonTray.alwaysShow then
                addonButtonTray:FadeIn()
            else
                addonButtonTray:FadeOut()
            end
        end

        AF.LoadWidgetPosition(addonButtonTray, config.addonButtonTray.position, Minimap)
        AF.SetSize(addonButtonTray, config.addonButtonTray.size, config.addonButtonTray.size)
        -- AF.SetSize(addonButtonTray.texture, config.addonButtonTray.size, config.addonButtonTray.size)

        local p, rp, x, y = GetPositionArgs_TrayFrame()
        AF.ClearPoints(addonButtonTray.frame)
        AF.SetPoint(addonButtonTray.frame, p, addonButtonTray, rp, x, y)
        addonButtonTray.frame.texture:SetColorTexture(AF.UnpackColor(config.addonButtonTray.bgColor))

        UpdateAddonButtons()
    else
        addonButtonTray:Hide()
    end
end
AF.RegisterCallback("BFI_UpdateModule", UpdateMinimap)