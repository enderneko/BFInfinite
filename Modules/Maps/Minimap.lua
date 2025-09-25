---@type BFI
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

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local UnitName = UnitName
local UnitIsUnit = UnitIsUnit
local UnitClassBase = AF.UnitClassBase

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
    Minimap.addonButtonTray = addonButtonTray
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

local function LoadAddonButtonTrayConfig(config)
    addonButtonTray.enabled = config.enabled
    if config.enabled then
        addonButtonTray:Show()
        if not addonButtonTray.frame:IsShown() then
            if config.alwaysShow then
                addonButtonTray:FadeIn()
            else
                addonButtonTray:FadeOut()
            end
        end

        AF.LoadWidgetPosition(addonButtonTray, config.position, Minimap)
        AF.SetSize(addonButtonTray, config.size, config.size)

        local p, rp, x, y = GetPositionArgs_TrayFrame()
        AF.ClearPoints(addonButtonTray.frame)
        AF.SetPoint(addonButtonTray.frame, p, addonButtonTray, rp, x, y)
        addonButtonTray.frame.texture:SetColorTexture(AF.UnpackColor(config.bgColor))

        UpdateAddonButtons()
    else
        addonButtonTray:Hide()
    end
end

---------------------------------------------------------------------
-- zone text
---------------------------------------------------------------------
local zoneText

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
    -- AF.SetText(zoneText, GetMinimapZoneText(), zoneText.length)
    zoneText:SetText(GetMinimapZoneText())
    -- zoneText:SetTextColor(MinimapZoneText:GetTextColor()) -- not reliable
    zoneText:SetTextColor(GetZoneTextColor())
end

local function CreateZoneText()
    zoneText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.zoneText = zoneText
    zoneText:Hide()
    zoneText:SetWordWrap(true)
    -- zoneText:SetSpacing(5)
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

local function LoadZoneTextConfig(config, generalSize)
    if config.enabled then
        AF.SetFont(zoneText, config.font)
        AF.LoadTextPosition(zoneText, config.position, Minimap)
        AF.SetWidth(zoneText, generalSize * config.length)
        M:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED", UpdateZoneText)
        UpdateZoneText()
        zoneText:Show()
        if config.alwaysShow then
            zoneText:FadeIn()
        else
            zoneText:FadeOut()
        end
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED", UpdateZoneText)
        zoneText:Hide()
    end
end

---------------------------------------------------------------------
-- clock
---------------------------------------------------------------------
local clockButton

local function UpdateClockTime(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.1 then
        self.elapsed = 0
        self.text:SetText(GameTime_GetTime(false))
    end
end

local function UpdateClockSize()
    -- local w, h = AF.GetStringSize("00:00", unpack(M.config.minimap.clock.font))
    -- clockButton:SetSize(w + 4, h + 4)
    AF.ResizeToFitText(clockButton, clockButton.hiddenText, 2, 2)
end

local function CreateClockButton()
    clockButton = CreateFrame("Button", "BFI_MinimapClock", Minimap)
    Minimap.clockButton = clockButton

    -- AF.ApplyDefaultBackdrop(clockButton)
    -- clockButton:SetBackdropBorderColor(AF.GetColorRGB("border"))
    -- clockButton:SetBackdropColor(AF.GetColorRGB("background"))

    -- alarm flash
    local flash = CreateFrame("Frame", nil, clockButton)
    clockButton.flash = flash
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
    clockButton.text = text
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    local hiddenText = clockButton:CreateFontString(nil, "OVERLAY")
    clockButton.hiddenText = hiddenText
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

local function LoadClockButtonConfig(config)
    if config.enabled then
        AF.SetFont(clockButton.text, config.font)
        AF.LoadWidgetPosition(clockButton, config.position)
        clockButton.text:SetTextColor(AF.UnpackColor(config.color))

        -- flash
        local anchor = config.position[1]
        local flashTexture = clockButton.flash.texture
        if anchor:find("^TOP") then
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        elseif anchor:find("LEFT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        elseif anchor:find("RIGHT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        else -- BOTTOM / CENTER
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        end

        clockButton:Show()

        AF.SetFont(clockButton.hiddenText, config.font)
        clockButton.hiddenText:SetText("00:00")
        RunNextFrame(UpdateClockSize)
    else
        clockButton:Hide()
    end
end

---------------------------------------------------------------------
-- instance difficulty
---------------------------------------------------------------------
local instanceDifficultyFrame

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
        instanceDifficultyFrame.isGuildGroup = arg
    end

    if IsInInstance() then
        local _, instanceType, difficulty, _, _, _, _, _, groupSize = GetInstanceInfo()

        local config = M.config.minimap.instanceDifficulty

        if difficulty and DIFFICULTY_INFO[difficulty] then
            groupSize = GetString(instanceDifficultyFrame.isGuildGroup and config.guildColor or config.normalColor, groupSize)
            difficulty = GetString(config.types[DIFFICULTY_INFO[difficulty]])

            instanceDifficultyFrame.text:SetText(groupSize .. difficulty)
            instanceDifficultyFrame:Show()

        elseif instanceType == "pvp" or instanceType == "arena" then
            instanceDifficultyFrame.text:SetText(GetString(config.types.pvp))
            instanceDifficultyFrame:Show()

        elseif instanceType == "scenario" then
            instanceDifficultyFrame.text:SetText(GetString(config.types.scenario))
            instanceDifficultyFrame:Show()

        else
            instanceDifficultyFrame:Hide()
        end
    else
        instanceDifficultyFrame:Hide()
    end

    AF.ResizeToFitText(instanceDifficultyFrame, instanceDifficultyFrame.text, 1, 1)
end

local function UpdateGuild()
    if IsInGuild() then
        RequestGuildPartyState()
    else
        instanceDifficultyFrame.isGuildGroup = false
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
    instanceDifficultyFrame = CreateFrame("Frame", "BFI_InstanceDifficultyFrame", Minimap)
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

local function LoadInstanceDifficultyFrameConfig(config)
    if config.enabled then
        AF.LoadWidgetPosition(instanceDifficultyFrame, config.position)
        AF.SetFont(instanceDifficultyFrame.text, config.font)
        M:RegisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        instanceDifficultyFrame:Show()
        UpdateInstanceDifficulty()
    else
        M:UnregisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        instanceDifficultyFrame:Hide()
    end
end

---------------------------------------------------------------------
-- calendarButton
---------------------------------------------------------------------
local calendarButton

local function CreateCalendarButton()
    calendarButton = AF.CreateIconButton(Minimap, AF.GetEmptyTexture(), nil, nil, nil, "gray", "white")
    Minimap.calendarButton = calendarButton
    AF.RemoveFromPixelUpdater(calendarButton)

    calendarButton:SetOnClick(function()
        ToggleCalendar()
        AF.FrameFlashStop(calendarButton.flash)
    end)

    calendarButton:HookOnEnter(function()
        if GetNumPendingInvites() ~= 0 then
            local _, p, mult = AF.GetAdaptiveAnchor_Vertical(calendarButton)
            AF.ShowTooltip(calendarButton, p, 0, mult * 2, {_G.GAMETIME_TOOLTIP_CALENDAR_INVITES})
        end
    end)
    calendarButton:HookOnLeave(AF.HideTooltip)

    -- shadow
    calendarButton.shadow = calendarButton:CreateTexture(nil, "BORDER")
    AF.SetPoint(calendarButton.shadow, "TOPLEFT", calendarButton.icon, 1, -1)
    AF.SetPoint(calendarButton.shadow, "BOTTOMRIGHT", calendarButton.icon, 1, -1)
    calendarButton.shadow:SetTexture(AF.GetEmptyTexture())
    calendarButton.shadow:SetVertexColor(AF.GetColorRGB("background"))

    -- flash
    calendarButton.flash = calendarButton:CreateTexture(nil, "OVERLAY")
    calendarButton.flash:SetAllPoints(calendarButton.icon)
    calendarButton.flash:SetTexture(AF.GetEmptyTexture())
    calendarButton.flash:SetVertexColor(AF.GetColorRGB("BFI"))
    calendarButton.flash:Hide()

    hooksecurefunc(calendarButton.icon, "SetTexture", function(_, ...)
        calendarButton.shadow:SetTexture(...)
        calendarButton.flash:SetTexture(...)
    end)

    function calendarButton:UpdatePixels()
        AF.ReSize(self)
        AF.RePoint(self)
        AF.RePoint(self.icon)
        AF.RePoint(self.shadow)
        AF.RePoint(self.flash)
    end

    -- CVarCallbackRegistry:RegisterCallback("restrictCalendarInvites", UpdateCalendar, calendarButton)
end

local function UpdateCalendar()
    local d = GetCurrentCalendarTime()
    calendarButton:SetIcon(AF.GetCalendarIcon("day", d.monthDay))
end

local function UpdateCalendarInvites()
    local n = GetNumPendingInvites()
    if n ~= 0 then
        AF.FrameFlashStart(calendarButton.flash, 1)
    else
        AF.FrameFlashStop(calendarButton.flash)
    end
end

local scheduler
local function ScheduleCalendarUpdate()
    M:UnregisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate)
    UpdateCalendar()
    if scheduler then scheduler:Cancel() end
    scheduler = C_Timer.NewTimer(AF.GetNextDaySeconds(true), ScheduleCalendarUpdate)
end

local function LoadCalendarButtonConfig(config)
    UpdateMinimapWidgets(calendarButton, config, true)
    if config.enabled then
        UpdateCalendarInvites()
        ScheduleCalendarUpdate()
        M:RegisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate, UpdateCalendarInvites)
        M:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", UpdateCalendarInvites)
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", ScheduleCalendarUpdate, UpdateCalendarInvites)
        M:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", UpdateCalendarInvites)
        AF.FrameFlashStop(calendarButton.flash)
    end
end

---------------------------------------------------------------------
-- coordsFrame
---------------------------------------------------------------------
local coordsFrame

local function CreateCoordsFrame()
    coordsFrame = CreateFrame("Frame", nil, Minimap)
    Minimap.coordsFrame = coordsFrame

    coordsFrame:SetSize(1, 1)
    coordsFrame:Hide()
    AF.CreateFadeInOutAnimation(coordsFrame, 0.25)

    local text = coordsFrame:CreateFontString(nil, "OVERLAY")
    coordsFrame.text = text
    text:SetWordWrap(true)
    -- text:SetSpacing(5)

    coordsFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            self.elapsed = 0

            local success
            local map = GetBestMapForUnit("player")
            if map then
                local pos = GetPlayerMapPosition(map, "player")
                if pos then
                    local x, y = pos:GetXY()
                    if x and y then
                        self.text:SetFormattedText(self.format, x * 100, y * 100)
                        success = true
                    end
                end
            end

            if not success then
                self.text:SetText("")
            end
        end
    end)

    Minimap:HookScript("OnEnter", function()
        if M.config.minimap.coordinates.enabled and not M.config.minimap.coordinates.alwaysShow then
            coordsFrame.elapsed = 1
            coordsFrame:FadeIn()
        end
    end)
    Minimap:HookScript("OnLeave", function()
        if M.config.minimap.coordinates.enabled and not M.config.minimap.coordinates.alwaysShow then
            coordsFrame:FadeOut()
        end
    end)
end

local function LoadCoordsFrameConfig(config)
    if config.enabled then
        AF.SetFont(coordsFrame.text, config.font)
        coordsFrame.text:SetTextColor(AF.UnpackColor(config.color))

        if config.relativeTo == "zoneText" then
            AF.LoadTextPosition(coordsFrame.text, config.position, zoneText)
        else
            AF.LoadTextPosition(coordsFrame.text, config.position, Minimap)
        end

        if config.format == "integer" then
            coordsFrame.format = "%d, %d"
        elseif config.format == "1decimal" then
            coordsFrame.format = "%.1f, %.1f"
        else
            coordsFrame.format = "%.2f, %.2f"
        end

        -- if config.twoLines then
        --     coordsFrame.sep = "\n"
        -- else
        --     coordsFrame.sep = ", "
        -- end

        coordsFrame:Show()
        if config.alwaysShow then
            coordsFrame:FadeIn()
        else
            coordsFrame:FadeOut()
        end
    else
        coordsFrame:Hide()
    end
end

---------------------------------------------------------------------
-- pingText
---------------------------------------------------------------------
local pingText

local function CreatePingText()
    pingText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.pingText = pingText
    pingText:Hide()
    AF.CreateContinualFadeInOutAnimation(pingText, nil, 3)
end

local lastUnit, lastTime

local function UpdatePingText(_, _, unit)
    if unit:find("target$") or unit:find("^soft") then return end

    local name, server = UnitName(unit)
    if not name then return end

    if lastUnit and UnitIsUnit(unit, lastUnit) and GetTime() - lastTime < 0.4 then return end
    lastUnit = unit
    lastTime = GetTime()

    local class = UnitClassBase(unit)
    if server and server ~= "" then
        name = name .. "*"
    end
    pingText:SetText(name)
    pingText:SetTextColor(AF.GetClassColor(class))
    pingText:FadeInOut()
end

local function LoadPingTextConfig(config)
    if config.enabled then
        AF.SetFont(pingText, config.font)
        AF.LoadTextPosition(pingText, config.position, Minimap)
        M:RegisterEvent("MINIMAP_PING", UpdatePingText)
    else
        M:UnregisterEvent("MINIMAP_PING", UpdatePingText)
        pingText:Hide()
    end
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
    AF.DefaultUpdatePixels(clockButton)
    AF.DefaultUpdatePixels(instanceDifficultyFrame)
    UpdateClockSize()
    calendarButton:UpdatePixels()
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
        CreateCoordsFrame()
        CreatePingText()
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

    -- mail frame
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.MailFrame, config.mailFrame, true)
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:ClearAllPoints()
    MinimapCluster.IndicatorFrame.MailFrame.MailIcon:SetPoint("CENTER")

    -- crafting order frame
    local orders = GetPersonalOrdersInfo()
    UpdateMinimapWidgets(MinimapCluster.IndicatorFrame.CraftingOrderFrame, config.craftingOrderFrame, #orders > 0)
    MiniMapCraftingOrderIcon:ClearAllPoints()
    MiniMapCraftingOrderIcon:SetPoint("CENTER")

    -- load other widgets
    LoadCalendarButtonConfig(config.calendar)
    LoadClockButtonConfig(config.clock)
    LoadZoneTextConfig(config.zoneText, config.general.size)
    LoadInstanceDifficultyFrameConfig(config.instanceDifficulty)
    LoadAddonButtonTrayConfig(config.addonButtonTray)
    LoadCoordsFrameConfig(config.coordinates)
    LoadPingTextConfig(config.ping)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateMinimap)