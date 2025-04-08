---@class BFI
local BFI = select(2, ...)
local UI = BFI.UIWidgets
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local quickJoinToastHolder
local QuickJoinToastButton = _G.QuickJoinToastButton
local ToggleQuickJoinPanel = _G.ToggleQuickJoinPanel

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateQuickJoinToastHolder()
    quickJoinToastHolder = CreateFrame("Frame", "BFI_QuickJoinToastHolder", AF.UIParent)
    quickJoinToastHolder:SetFrameStrata("LOW")
    quickJoinToastHolder:SetFrameLevel(3)
    AF.SetSize(quickJoinToastHolder, 300, 22)
    AF.CreateMover(quickJoinToastHolder, "BFI: " .. L["UI Widgets"], _G.COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_QUICK_JOIN_LABEL)

    -- click
    local function ShowToast()
        ToggleQuickJoinPanel()
        QuickJoinFrame:SelectGroup(QuickJoinToastButton.displayedToast.guid)
        QuickJoinFrame:ScrollToGroup(QuickJoinToastButton.displayedToast.guid)
    end

    hooksecurefunc(QuickJoinToastButton, "ShowToast", function()
        quickJoinToastHolder:SetScript("OnMouseDown", ShowToast)
    end)

    hooksecurefunc(QuickJoinToastButton, "HideToast", function()
        quickJoinToastHolder:SetScript("OnMouseDown", nil)
        quickJoinToastHolder:EnableMouse(false)
    end)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local function SetupToast(toast)
    -- toast:Show()
    -- toast:SetAlpha(1)
    -- toast.Text:SetAlpha(1)
    -- toast.Text:SetText("Adventure queued for Random Dungeon")

    -- position
    toast:SetParent(quickJoinToastHolder)
    toast:ClearAllPoints()
    toast:SetPoint("LEFT")

    -- size
    AF.SetWidth(toast, 300)
    AF.SetHeight(toast, 22)

    -- font
    AF.SetFont(toast.Text, unpack(UI.config.quickJoinToast.font))

    -- style
    toast.Line:Hide()
    toast.Background = AF.CreateBorderedFrame(toast, nil, nil, nil, "background", "BFI")
    toast.Background:SetAllPoints()
    toast.Background:SetFrameLevel(toast:GetFrameLevel())
    toast.Background:SetAlpha(0)

    -- animations
    -- Interface/AddOns/Blizzard_QuickJoin/QuickJoinToast.xml#L82
    local animations = {QuickJoinToastButton.FriendToToastAnim:GetAnimations()}
    for i, a in pairs(animations) do
        if a:GetTarget() == toast.Background and a.SetScale then -- should be 1
            a:SetDuration(0)
            a:SetScaleTo(1, 1)
        end
    end

    -- Interface/AddOns/Blizzard_QuickJoin/QuickJoinToast.xml#L108
    animations = {QuickJoinToastButton.ToastToToastAnim:GetAnimations()}
    for i, a in pairs(animations) do
        if a:GetTarget() == toast.Background and a.SetScale then -- should be 6 & 7
            a:SetDuration(0)
            a:SetScaleTo(1, 1)
        end
    end

    -- Interface/AddOns/Blizzard_QuickJoin/QuickJoinToast.xml#L125
    animations = {QuickJoinToastButton.ToastToFriendAnim:GetAnimations()}
    for i, a in pairs(animations) do
        if a:GetTarget() == toast.Background and a.SetScale then -- should be 5
            a:SetDuration(0)
            a:SetScaleTo(1, 1)
        end
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateQuickJoinToast(module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "quickjoin" then return end

    local config = UI.config.quickJoinToast

    if not config.enabled then
        if quickJoinToastHolder then
            quickJoinToastHolder.enabled = false
            -- quickJoinToastHolder:UnregisterAllEvents()
            quickJoinToastHolder:Hide()
        end
        return
    end

    if not quickJoinToastHolder then
        CreateQuickJoinToastHolder()
        SetupToast(QuickJoinToastButton.Toast)
    end
    quickJoinToastHolder:Show()
    quickJoinToastHolder.enabled = true

    AF.UpdateMoverSave(quickJoinToastHolder, config.position)
    AF.LoadPosition(quickJoinToastHolder, config.position)

end
BFI.RegisterCallback("UpdateModules", "UI_QuickJoinToast", UpdateQuickJoinToast)