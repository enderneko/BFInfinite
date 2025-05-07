---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local M = BFI.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap
local ExpansionButton = _G.ExpansionLandingPageMinimapButton
local GameTimeFrame = _G.GameTimeFrame
local minimapContainer

local GameTime_GetTime = GameTime_GetTime
local GetMinimapZoneText = GetMinimapZoneText
local UIFrameFlash = UIFrameFlash
local UIFrameFlashStop = UIFrameFlashStop
local IsInInstance = IsInInstance
local InGuildParty = InGuildParty
local GetInstanceInfo = GetInstanceInfo
local GetGuildInfo = GetGuildInfo
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetDifficultyInfo = GetDifficultyInfo

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

    AF.ClearPoints(ExpansionButton)
    AF.LoadWidgetPosition(ExpansionButton, config.position, minimapContainer)
    AF.SetSize(ExpansionButton, config.width, config.height)
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

    AF.ClearPoints(widget)
    AF.LoadWidgetPosition(widget, config.position, minimapContainer)
    AF.SetSize(widget, config.width, config.height)
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
                AF.SetOnePixelInside(child.icon, child)
                AF.ApplyDefaultBackdropWithColors(child)

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
    local p, rp, np, x, y, nx, ny = AF.GetAnchorPoints_Simple(addonButtonHolder.buttonAnchor, addonButtonHolder.config.orientation, addonButtonHolder.config.spacing)
    for i, b in pairs(addonButtonHolder.shownButtons) do
        AF.ClearPoints(b)
        AF.SetSize(b, addonButtonHolder.config.width, addonButtonHolder.config.height)

        if i == 1 then
            AF.SetPoint(b, p)
        elseif i % addonButtonHolder.config.numPerLine == 1 then
            AF.SetPoint(b, p, addonButtonHolder.shownButtons[i - addonButtonHolder.config.numPerLine], np, nx, ny)
        else
            AF.SetPoint(b, p, addonButtonHolder.shownButtons[i - 1], rp, x, y)
        end
    end

    local num = #addonButtonHolder.shownButtons
    AF.SetGridSize(addonButtonHolder.frame, addonButtonHolder.config.width, addonButtonHolder.config.height,
        addonButtonHolder.config.spacing, addonButtonHolder.config.spacing,
        min(addonButtonHolder.config.numPerLine, num), ceil(num / addonButtonHolder.config.numPerLine)
    )
end

local function CreateAddonButtonHolder()
    local lib = LibStub("LibDBIcon-1.0", true)
    if not lib then return end

    lib:RegisterCallback("LibDBIcon_IconCreated", UpdateAddonButtons)

    -- button
    addonButtonHolder = AF.CreateButton(Minimap, "", "BFI_hover", 20, 20)
    -- addonButtonHolder:Hide()
    addonButtonHolder:SetTexture(AF.GetIcon("Menu", BFI.name), {20, 20})
    AF.RemoveFromPixelUpdater(addonButtonHolder)
    AF.CreateFadeInOutAnimation(addonButtonHolder, 0.25, true)

    addonButtonHolder.buttons = {}
    addonButtonHolder.shownButtons = {}

    -- container frame
    local frame = CreateFrame("Frame", nil, addonButtonHolder)
    addonButtonHolder.frame = frame
    AF.SetPoint(frame, "BOTTOMLEFT", addonButtonHolder, "TOPLEFT", 0, 1)
    frame:Hide()

    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetAllPoints()

    -- scripts
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
    AF.SetText(Minimap.zoneText, GetMinimapZoneText(), Minimap.zoneText.length)
    Minimap.zoneText:SetTextColor(MinimapZoneText:GetTextColor())
end

local function CreateZoneText()
    -- zoneText
    Minimap.zoneText = Minimap:CreateFontString(nil, "OVERLAY")
    Minimap.zoneText:Hide()
    AF.CreateFadeInOutAnimation(Minimap.zoneText, 0.25)

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
local function UpdateClockTime(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.1 then
        self.elapsed = 0
        self.text:SetText(GameTime_GetTime(false))
    end
end

local function UpdateClockSize()
    local w, h = AF.GetStringSize("00:00", unpack(M.config.minimap.clock.font))
    Minimap.clockButton:SetSize(w + 2, h + 2)
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
    [7] = "lookingForRaid", -- Looking For Raid, raid
    [8] = "mythicKeystone", -- Mythic Keystone, party
    [9] = "normal", -- 40 Player, raid
    [14] = "normal", -- Normal, raid
    [15] = "heroic", -- Heroic, raid
    [16] = "mythic", -- Mythic, raid
    [17] = "lookingForRaid", -- Looking For Raid, raid
    [18] = "event", -- Event, raid
    [19] = "event", -- Event, party
    [20] = "event", -- Event Scenario, scenario
    [23] = "mythic", -- Mythic, party
    [24] = "timewalking", -- Timewalking, party
    [30] = "event", -- Event, scenario
    [33] = "timewalking", -- Timewalking, raid
    [151] = "timewalking", -- Looking For Raid, Timewalking, raid
    [205] = "normal", -- ?
    [208] = "delve",
}

local function UpdateInstanceDifficulty(_, event, arg)
    -- NOTE: IsInGuildGroup() seems not correct, InGuildParty() seems fine
    if event == "GUILD_PARTY_STATE_UPDATED" then
        Minimap.instanceDifficultyFrame.isGuildGroup = arg
    end

    if IsInInstance() then
        local _, instanceType, difficulty, _, _, _, _, _, groupSize = GetInstanceInfo()

        local config = Minimap.instanceDifficultyFrame.config

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

        -- if difficulty == 1 or difficulty == 3 or difficulty == 4 or difficulty == 9 or difficulty == 12 or difficulty == 14 or difficulty == 205 then
        --     -- Normal
        --     difficulty = GetString(config.types.normal)
        -- elseif difficulty == 2 or difficulty == 5 or difficulty == 6 or difficulty == 11 or difficulty == 15 then
        --     -- Heroic
        --     difficulty = GetString(config.types.heroic)
        -- elseif difficulty == 16 or difficulty == 23 then
        --     -- Mythic
        --     difficulty = GetString(config.types.mythic)
        -- elseif difficulty == 7 or difficulty == 17 then
        --     -- Looking For Raid
        --     difficulty = GetString(config.types.lookingForRaid)
        -- elseif difficulty == 8 then
        --     -- Mythic Keystone
        --     difficulty = GetString(config.types.mythicKeystone)
        -- elseif difficulty == 24 then
        --     -- Timewalking
        --     difficulty = GetString(config.types.timewalking)
        -- elseif difficulty == 18 or difficulty == 19 or difficulty == 20 then
        --     -- Event
        --     difficulty = GetString(config.types.event)
        -- else
        --     -- TODO: delves
        --     groupSize = nil
        --     difficulty = nil
        -- end

        -- if groupSize and difficulty then
        --     Minimap.instanceDifficultyFrame.text:SetText(groupSize .. difficulty)
        --     Minimap.instanceDifficultyFrame:Show()
        -- else
        --     Minimap.instanceDifficultyFrame:Hide()
        -- end
    else
        Minimap.instanceDifficultyFrame:Hide()
    end

    AF.SetSizeToFitText(Minimap.instanceDifficultyFrame, Minimap.instanceDifficultyFrame.text)
end

local function UpdateGuild()
    if IsInGuild() then
        RequestGuildPartyState()
    else
        Minimap.instanceDifficultyFrame.isGuildGroup = false
        UpdateInstanceDifficulty()
    end
end

local function CreateInstanceDifficulty()
    local instanceDifficultyFrame = CreateFrame("Frame", "BFI_InstanceDifficultyFrame", Minimap)
    Minimap.instanceDifficultyFrame = instanceDifficultyFrame
    -- instanceDifficultyFrame:SetSize(30, 20)
    -- instanceDifficultyFrame:SetPoint("TOPLEFT")
    instanceDifficultyFrame.text = instanceDifficultyFrame:CreateFontString(nil, "OVERLAY")
    instanceDifficultyFrame.text:SetPoint("CENTER")

    local classcolor = "|c" .. RAID_CLASS_COLORS[UnitClassBase("player")].colorStr

    -- NOTE: GuildInstanceDifficultyMixin.OnEnter
    -- instanceDifficultyFrame:SetScript("OnEnter", GuildInstanceDifficultyMixin.OnEnter)
    instanceDifficultyFrame:SetScript("OnEnter", function(self)
        local instanceName, instanceType, difficulty, _, maxPlayers, _, _, _, instanceGroupSize, lfgID = GetInstanceInfo()
        if instanceType ~= "party" and instanceType ~= "raid" then return end

        local difficultyName = DifficultyUtil.GetDifficultyName(difficulty)
        if not difficultyName then return end

        local isLFR = select(8, GetDifficultyInfo(difficulty))

        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 3)

        if isLFR and lfgID then
            local name = GetLFGDungeonInfo(lfgID)
            GameTooltip_SetTitle(GameTooltip, RAID_FINDER)
            GameTooltip_AddNormalLine(GameTooltip, name)
            -- GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers))

        else
            GameTooltip_SetTitle(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP:format(difficultyName))
            GameTooltip_AddNormalLine(GameTooltip, instanceName)
            -- GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers))

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
-- init
---------------------------------------------------------------------
local function UpdatePixels()
    AF.DefaultUpdatePixels(minimapContainer)
    AF.DefaultUpdatePixels(Minimap)
    AF.DefaultUpdatePixels(ExpansionButton)
    AF.DefaultUpdatePixels(MinimapCluster.Tracking)
    AF.DefaultUpdatePixels(addonButtonHolder)
    AF.DefaultUpdatePixels(addonButtonHolder.frame)
    for _, b in pairs(addonButtonHolder.buttons) do
        AF.DefaultUpdatePixels(b)
    end
    AF.DefaultUpdatePixels(Minimap.clockButton)
    AF.DefaultUpdatePixels(Minimap.instanceDifficultyFrame)
    UpdateClockSize()
end

local function InitMinimap()
    -- MinimapCluster
    U.DisableEditMode(MinimapCluster)
    MinimapCluster:EnableMouse(false)

    -- minimapContainer
    minimapContainer = CreateFrame("Frame", "BFI_MinimapContainer", AF.UIParent, "BackdropTemplate")
    AF.ApplyDefaultBackdropWithColors(minimapContainer)
    AF.CreateMover(minimapContainer, "BFI: " .. _G.OTHER, _G.HUD_EDIT_MODE_MINIMAP_LABEL)
    AF.AddToPixelUpdater(minimapContainer, UpdatePixels)

    -- Minimap
    Minimap.Layout = AF.noop -- MinimapCluster.IndicatorFrame
    Minimap:SetMaskTexture(AF.GetPlainTexture())
    Minimap:SetParent(minimapContainer)
    AF.SetPoint(Minimap, "TOPLEFT", 1, -1)
    AF.SetPoint(Minimap, "BOTTOMRIGHT", -1, 1)

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
local function UpdateMinimap(_, module, which)
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
        CreateInstanceDifficulty()
        AF.UpdateMoverSave(minimapContainer, config.position)
    end

    -- minimap
    AF.ClearPoints(minimapContainer)
    AF.LoadPosition(minimapContainer, config.position)
    AF.SetSize(minimapContainer, config.width, config.height)
    Minimap:SetSize(Minimap:GetSize()) --! for ping

    -- expansion button
    UpdateExpansionButton()

    -- tracking button
    UpdateMinimapWidgets(MinimapCluster.Tracking, config.trackingButton)

    -- calendar
    UpdateMinimapWidgets(GameTimeFrame, config.calendar)

    -- clock
    if config.clock.enabled then
        AF.SetFont(Minimap.clockButton.text, unpack(config.clock.font))
        AF.LoadWidgetPosition(Minimap.clockButton, config.clock.position)

        -- flash
        local anchor = config.clock.position[1]
        local flashTexture = Minimap.clockButton.flash.texture
        if strfind(anchor, "^TOP") then
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        elseif strfind(anchor, "LEFT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        elseif strfind(anchor, "RIGHT$") then
            flashTexture:SetGradient("HORIZONTAL", CreateColor(AF.GetColorRGB("none")), CreateColor(AF.GetColorRGB("BFI")))
        else -- BOTTOM / CENTER
            flashTexture:SetGradient("VERTICAL", CreateColor(AF.GetColorRGB("BFI")), CreateColor(AF.GetColorRGB("none")))
        end

        Minimap.clockButton:Show()
        M:RegisterEvent("FIRST_FRAME_RENDERED", UpdateClockSize)
        UpdateClockSize()
    else
        Minimap.clockButton:Hide()
        M:UnregisterEvent("FIRST_FRAME_RENDERED", UpdateClockSize)
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
        AF.SetFont(Minimap.zoneText, unpack(config.zoneText.font))
        AF.LoadTextPosition(Minimap.zoneText, config.zoneText.position)
        M:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:RegisterEvent("ZONE_CHANGED", UpdateZoneText)
        UpdateZoneText()
        Minimap.zoneText:Show()
        Minimap.zoneText:FadeOut()
    else
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_NEW_AREA", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED_INDOORS", UpdateZoneText)
        M:UnregisterEvent("ZONE_CHANGED", UpdateZoneText)
        Minimap.zoneText:Hide()
    end

    -- dungeon difficulty
    if config.instanceDifficulty.enabled then
        Minimap.instanceDifficultyFrame.config = config.instanceDifficulty
        AF.LoadWidgetPosition(Minimap.instanceDifficultyFrame, config.instanceDifficulty.position)
        AF.SetFont(Minimap.instanceDifficultyFrame.text, unpack(config.instanceDifficulty.font))
        M:RegisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:RegisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        Minimap.instanceDifficultyFrame:Show()
    else
        M:UnregisterEvent("GUILD_PARTY_STATE_UPDATED", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateInstanceDifficulty)
        M:UnregisterEvent("UPDATE_INSTANCE_INFO", UpdateInstanceDifficulty)
        M:UnregisterEvent("PLAYER_GUILD_UPDATE", UpdateGuild)
        Minimap.instanceDifficultyFrame:Hide()
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

        AF.LoadWidgetPosition(addonButtonHolder, config.addonButtonHolder.position, Minimap)
        AF.SetSize(addonButtonHolder, config.addonButtonHolder.width, config.addonButtonHolder.height)

        local p, rp, x, y = GetPositionArgs_HolderFrame()
        addonButtonHolder.buttonAnchor = p
        AF.ClearPoints(addonButtonHolder.frame)
        AF.SetPoint(addonButtonHolder.frame, p, addonButtonHolder, rp, x, y)
        addonButtonHolder.frame.texture:SetColorTexture(AF.UnpackColor(config.addonButtonHolder.bgColor))

        UpdateAddonButtons()
    else
        addonButtonHolder:Hide()
    end
end
AF.RegisterCallback("BFI_UpdateModules", UpdateMinimap)