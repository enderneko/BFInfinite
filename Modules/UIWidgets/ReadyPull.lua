---@class BFI
local BFI = select(2, ...)
local W = BFI.modules.UIWidgets
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local ceil = math.ceil
local DoReadyCheck = DoReadyCheck
local InitiateRolePoll = InitiateRolePoll
local DoCountdown = C_PartyInfo.DoCountdown
local GetNumGroupMembers = GetNumGroupMembers

local readyCheckTimer, countdownTicker

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local readyPullFrame

local function CreateReadyPullFrame()
    readyPullFrame = CreateFrame("Frame", "BFI_ReadyPullFrame", AF.UIParent)
    AF.AddEventHandler(readyPullFrame)

    -- mover
    AF.CreateMover(readyPullFrame, "BFI: " .. L["UI Widgets"], L["Ready"] .. " & " .. L["Pull"])

    -- ready check & role poll
    local readyButton = AF.CreateButton(readyPullFrame, L["Ready"], "static")
    readyPullFrame.readyButton = readyButton
    readyButton:SetTextHighlightColor("BFI")
    readyButton:SetBorderHighlightColor("BFI")
    readyButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    readyButton.bar = AF.CreateBlizzardStatusBar(readyButton, nil, nil, nil, nil, "BFI", nil, "current_value")
    AF.SetOnePixelInside(readyButton.bar)
    readyButton.bar:SetAlpha(0)
    readyButton.bar:ClearBackdrop()
    readyButton.bar:SetScript("OnValueChanged", nil)

    readyButton:SetOnClick(function(self, button)
        if button == "LeftButton" then
            DoReadyCheck()
        elseif button == "RightButton" then
            InitiateRolePoll()
        end
    end)

    readyButton:HookOnEnter(function(self)
        AF.SetFrameLevel(readyButton, 2)
    end)

    readyButton:HookOnLeave(function(self)
        AF.SetFrameLevel(readyButton, 1)
    end)

    -- countdown
    local pullButton = AF.CreateButton(readyPullFrame, L["Pull"], "static")
    readyPullFrame.pullButton = pullButton
    pullButton:SetTextHighlightColor("BFI")
    pullButton:SetBorderHighlightColor("BFI")
    pullButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    pullButton.bar = AF.CreateBlizzardStatusBar(pullButton, nil, nil, nil, nil, "BFI", nil, "current_value")
    AF.SetOnePixelInside(pullButton.bar)
    pullButton.bar:SetAlpha(0)
    pullButton.bar:ClearBackdrop()
    pullButton.bar:SetScript("OnValueChanged", nil)

    pullButton:SetOnClick(function(self, button)
        if button == "LeftButton" then
            DoCountdown(W.config.readyCheck.countdown)
        elseif countdownTicker then
            DoCountdown(0)
        end
    end)

    pullButton:HookOnEnter(function(self)
        AF.SetFrameLevel(pullButton, 2)
    end)
    pullButton:HookOnLeave(function(self)
        AF.SetFrameLevel(pullButton, 1)
    end)
end

---------------------------------------------------------------------
-- ready check
---------------------------------------------------------------------
local confirmedCount, numGroupMembers = 0, 0

local function ReadyCheckStart(_, _, initiatorName, readyCheckTimeLeft)
    if readyCheckTimer then
        readyCheckTimer:Cancel()
        readyCheckTimer = nil
    end

    local button = readyPullFrame.readyButton
    AF.FrameFadeOut(button.text, nil, nil, nil, true)
    AF.FrameFadeIn(button.bar)
    AF.StartStatusBarCountdown(button.bar, readyCheckTimeLeft)

    confirmedCount = 1
    numGroupMembers = GetNumGroupMembers()

    button.bar.progressText:SetFormattedText("%d / %d", confirmedCount, numGroupMembers)
    button.bar.progressText:SetColor("white")
end

local function ReadyCheckUpdate(_, _, unitTarget, isReady)
    if IsInRaid() then
        if not unitTarget:find("^raid") then return end
    else -- party
        if not unitTarget:find("^party") and unitTarget ~= "player" then return end
    end

    local button = readyPullFrame.readyButton

    if isReady then
        confirmedCount = confirmedCount + 1
        button.bar.progressText:SetFormattedText("%d / %d", confirmedCount, numGroupMembers)
    else
        button.bar.progressText:SetColor("firebrick")
    end
end

local function ReadyCheckFinish()
    local button = readyPullFrame.readyButton

    if confirmedCount == numGroupMembers then
        button.bar.progressText:SetColor("softlime")
    else
        button.bar.progressText:SetColor("firebrick")
    end

    AF.StopStatusBarCountdown(button.bar)
    button.bar:SetValue(0)

    readyCheckTimer = C_Timer.NewTimer(3, function()
        AF.FrameFadeIn(button.text)
        AF.FrameFadeOut(button.bar)
        readyCheckTimer = nil
    end)
end

---------------------------------------------------------------------
-- countdown
---------------------------------------------------------------------
local function StartCountdown(_, _, initiatedBy, timeRemaining, totalTime, informChat, initiatedByName)
    if countdownTicker then
        countdownTicker:Cancel()
        countdownTicker = nil
    end

    local button = readyPullFrame.pullButton
    AF.FrameFadeOut(button.text, nil, nil, nil, true)
    AF.FrameFadeIn(button.bar)
    AF.StartStatusBarCountdown(button.bar, totalTime, timeRemaining)
    button.bar.progressText:SetText(timeRemaining)

    countdownTicker = C_Timer.NewTicker(1, function()
        timeRemaining = timeRemaining - 1
        if timeRemaining > 0 then
            button.bar.progressText:SetText(timeRemaining)
        elseif timeRemaining == 0 then
            button.bar.progressText:SetText(_G.GO)
        elseif timeRemaining == -2 then
            countdownTicker:Cancel()
            countdownTicker = nil
            AF.FrameFadeIn(button.text)
            AF.FrameFadeOut(button.bar)
        end
    end)
end

local function CancelCountdown()
    if countdownTicker then
        countdownTicker:Cancel()
        countdownTicker = nil
    end

    local button = readyPullFrame.pullButton
    AF.FrameFadeIn(button.text)
    AF.FrameFadeOut(button.bar)
    AF.StopStatusBarCountdown(button.bar)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local function SetupReadyPullFrame(config)
    local readyButton = readyPullFrame.readyButton
    local pullButton = readyPullFrame.pullButton

    local p, rp, x, y = AF.GetAnchorPoints_Simple(config.arrangement, config.spacing)
    AF.ClearPoints(readyButton)
    AF.SetPoint(readyButton, p)
    AF.ClearPoints(pullButton)
    AF.SetPoint(pullButton, p, readyButton, rp, x, y)

    AF.SetSize(readyButton, config.width, config.height)
    AF.SetSize(pullButton, config.width, config.height)

    readyButton:SetText(AF.IsBlank(config.ready) and L["Ready"] or config.ready)
    pullButton:SetText(AF.IsBlank(config.pull) and L["Pull"] or config.pull)

    AF.SetFont(readyButton.text, config.font)
    AF.SetFont(pullButton.text, config.font)

    if config.arrangement:find("^[tb]") then
        AF.SetWidth(readyPullFrame, config.width)
        AF.SetListHeight(readyPullFrame, 2, config.height, config.spacing)
    else
        AF.SetHeight(readyPullFrame, config.height)
        AF.SetListWidth(readyPullFrame, 2, config.width, config.spacing)
    end
end

---------------------------------------------------------------------
-- check permission
---------------------------------------------------------------------
local function CheckPermission()
    if not readyPullFrame or not readyPullFrame.enabled then return end
    readyPullFrame:SetShown(AF.HasGroupPermission())
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateReadyPull(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "readyPull" then return end

    local config = W.config.readyPull

    if not config.enabled then
        if readyPullFrame then
            readyPullFrame.enabled = false
            readyPullFrame:Hide()
            readyPullFrame:UnregisterAllEvents()
        end
        return
    end

    if not readyPullFrame then
        CreateReadyPullFrame()
    end
    readyPullFrame.enabled = true

    SetupReadyPullFrame(config)
    readyPullFrame:RegisterEvent("START_PLAYER_COUNTDOWN", StartCountdown)
    readyPullFrame:RegisterEvent("CANCEL_PLAYER_COUNTDOWN", CancelCountdown)
    readyPullFrame:RegisterEvent("READY_CHECK", ReadyCheckStart)
    readyPullFrame:RegisterEvent("READY_CHECK_CONFIRM", ReadyCheckUpdate)
    readyPullFrame:RegisterEvent("READY_CHECK_FINISHED", ReadyCheckFinish)

    AF.UpdateMoverSave(readyPullFrame, config.position)
    AF.LoadPosition(readyPullFrame, config.position)

    CheckPermission()
    AF.RegisterCallback("AF_GROUP_PERMISSION_CHANGED", CheckPermission)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateReadyPull)