---@class BFI
local BFI = select(2, ...)
local W = BFI.modules.UIWidgets
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local ceil = math.ceil
local DoReadyCheck = DoReadyCheck
local DoCountdown = C_PartyInfo.DoCountdown
local GetNumGroupMembers = GetNumGroupMembers

local readyCheckTimer, countdownTicker

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local readyCheckFrame

local function CreateReadyCheckFrame()
    readyCheckFrame = CreateFrame("Frame", "BFI_ReadyCheckFrame", AF.UIParent)
    AF.AddEventHandler(readyCheckFrame)

    -- mover
    AF.CreateMover(readyCheckFrame, "BFI: " .. L["UI Widgets"], _G.READY_CHECK)

    -- ready check & role poll
    local readyCheckButton = AF.CreateButton(readyCheckFrame, L["Ready"], "static")
    readyCheckFrame.readyCheckButton = readyCheckButton
    readyCheckButton:SetTextHighlightColor("BFI")
    readyCheckButton:SetBorderHighlightColor("BFI")

    readyCheckButton.bar = AF.CreateBlizzardStatusBar(readyCheckButton, nil, nil, nil, nil, "BFI", nil, "current_value")
    AF.SetOnePixelInside(readyCheckButton.bar)
    readyCheckButton.bar:SetAlpha(0)
    readyCheckButton.bar:ClearBackdrop()
    readyCheckButton.bar:SetScript("OnValueChanged", nil)

    readyCheckButton:SetOnClick(DoReadyCheck)

    -- countdown
    local countdownButton = AF.CreateButton(readyCheckFrame, L["Pull"], "static")
    readyCheckFrame.countdownButton = countdownButton
    countdownButton:SetTextHighlightColor("BFI")
    countdownButton:SetBorderHighlightColor("BFI")
    countdownButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    countdownButton.bar = AF.CreateBlizzardStatusBar(countdownButton, nil, nil, nil, nil, "BFI", nil, "current_value")
    AF.SetOnePixelInside(countdownButton.bar)
    countdownButton.bar:SetAlpha(0)
    countdownButton.bar:ClearBackdrop()
    countdownButton.bar:SetScript("OnValueChanged", nil)

    countdownButton:SetOnClick(function(self, button)
        if button == "LeftButton" then
            DoCountdown(W.config.readyCheck.countdown)
        elseif countdownTicker then
            DoCountdown(0)
        end
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

    local button = readyCheckFrame.readyCheckButton
    AF.FrameFadeOut(button.text, nil, nil, nil, true)
    AF.FrameFadeIn(button.bar)
    AF.StartStatusBarCountdown(button.bar, readyCheckTimeLeft)

    confirmedCount = 1
    numGroupMembers = GetNumGroupMembers()

    button.bar.progressText:SetFormattedText("%d / %d", confirmedCount, numGroupMembers)
    button.bar.progressText:SetColor("white")
end

local function ReadyCheckUpdate(_, _, unitTarget, isReady)
    local button = readyCheckFrame.readyCheckButton

    if isReady then
        confirmedCount = confirmedCount + 1
        button.bar.progressText:SetFormattedText("%d / %d", confirmedCount, numGroupMembers)
    else
        button.bar.progressText:SetColor("firebrick")
    end
end

local function ReadyCheckFinish()
    local button = readyCheckFrame.readyCheckButton

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

    local button = readyCheckFrame.countdownButton
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

    local button = readyCheckFrame.countdownButton
    AF.FrameFadeIn(button.text)
    AF.FrameFadeOut(button.bar)
    AF.StopStatusBarCountdown(button.bar)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local function SetupReadyCheckFrame(config)
    local readyCheckButton = readyCheckFrame.readyCheckButton
    local countdownButton = readyCheckFrame.countdownButton

    local p, rp, x, y = AF.GetAnchorPoints_Simple(config.arrangement, config.spacing)
    AF.SetPoint(readyCheckButton, p)
    AF.SetPoint(countdownButton, p, readyCheckButton, rp, x, y)

    AF.SetSize(readyCheckButton, config.width, config.height)
    AF.SetSize(countdownButton, config.width, config.height)

    readyCheckButton:SetText(AF.IsBlank(config.ready) and L["Ready"] or config.ready)
    countdownButton:SetText(AF.IsBlank(config.pull) and L["Pull"] or config.pull)

    if config.arrangement:find("^[tb]") then
        AF.SetWidth(readyCheckFrame, config.width)
        AF.SetListHeight(readyCheckFrame, 2, config.height, config.spacing)
    else
        AF.SetHeight(readyCheckFrame, config.height)
        AF.SetListWidth(readyCheckFrame, 2, config.width, config.spacing)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateReadyCheck(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "readycheck" then return end

    local config = W.config.readyCheck

    if not config.enabled then
        if readyCheckFrame then
            readyCheckFrame.enabled = false
            readyCheckFrame:Hide()
            readyCheckFrame:UnregisterAllEvents()
        end
        return
    end

    if not readyCheckFrame then
        CreateReadyCheckFrame()
    end
    readyCheckFrame:Show()
    readyCheckFrame.enabled = true

    SetupReadyCheckFrame(config)
    readyCheckFrame:RegisterEvent("START_PLAYER_COUNTDOWN", StartCountdown)
    readyCheckFrame:RegisterEvent("CANCEL_PLAYER_COUNTDOWN", CancelCountdown)
    readyCheckFrame:RegisterEvent("READY_CHECK", ReadyCheckStart)
    readyCheckFrame:RegisterEvent("READY_CHECK_CONFIRM", ReadyCheckUpdate)
    readyCheckFrame:RegisterEvent("READY_CHECK_FINISHED", ReadyCheckFinish)

    AF.UpdateMoverSave(readyCheckFrame, config.position)
    AF.LoadPosition(readyCheckFrame, config.position)

end
AF.RegisterCallback("BFI_UpdateModule", UpdateReadyCheck)