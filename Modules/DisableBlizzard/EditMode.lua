---@class BFI
local BFI = select(2, ...)
local DB = BFI.DisableBlizzard
---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- forked from ElvUI
---------------------------------------------------------------------
local ignoreFrames = {
    "MainStatusTrackingBarContainer", -- Experience Bar
    "MicroMenuContainer", -- MicroBar / Menu
}

local hideFrames = {}
local needsUpdate = false

---------------------------------------------------------------------
-- edit mode button
---------------------------------------------------------------------
local function GetGameMenuEditModeButton()
    local menu = _G.GameMenuFrame
    return menu and menu.MenuButtons and menu.MenuButtons[_G.HUD_EDIT_MODE_MENU]
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
local function LAYOUTS_UPDATED(_, event, arg1)
    local allow = event ~= "PLAYER_SPECIALIZATION_CHANGED" or arg1 == "player"
    if allow and not _G.EditModeManagerFrame:IsEventRegistered(event) then
        needsUpdate = true
    end
end

local function PLAYER_REGEN(event)
    local editMode = _G.EditModeManagerFrame
    local combatLeave = event == "PLAYER_REGEN_ENABLED"

    local btn = GetGameMenuEditModeButton()
    if btn then
        btn:SetEnabled(combatLeave)
    end

    if combatLeave then
        if next(hideFrames) then
            for frame in next, hideFrames do
                HideUIPanel(frame)
                frame:SetScale(1)

                hideFrames[frame] = nil
            end
        end

        if needsUpdate then
            editMode:UpdateLayoutInfo(C_EditMode.GetLayouts())

            needsUpdate = false
        end

        editMode:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
        editMode:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
    else
        editMode:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
        editMode:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    end
end

---------------------------------------------------------------------
-- handle
---------------------------------------------------------------------
local function HandleHide(frame)
    local combat = InCombatLockdown()
    if combat then -- fake hide the editmode system
        hideFrames[frame] = true

        for _, child in next, frame.registeredSystemFrames do
            child:ClearHighlight()
        end
    end

    HideUIPanel(frame, not combat)
    frame:SetScale(combat and 0.00001 or 1)
end

local function OnProceed()
    local editMode = _G.EditModeManagerFrame
    local dialog = _G.EditModeUnsavedChangesDialog
    if dialog.selectedLayoutIndex then
        editMode:SelectLayout(dialog.selectedLayoutIndex)
    else
        HandleHide(editMode, dialog)
    end

    StaticPopupSpecial_Hide(dialog)
end

local function OnSaveProceed()
    _G.EditModeManagerFrame:SaveLayoutChanges()
    OnProceed()
end

local function OnClose()
    local editMode = _G.EditModeManagerFrame
    if editMode:HasActiveChanges() then
        editMode:ShowRevertWarningDialog()
    else
        HandleHide(editMode)
    end
end

---------------------------------------------------------------------
-- SetEnabled
---------------------------------------------------------------------
local function SetEnabled(self, enabled)
    if InCombatLockdown() and enabled then
        self:Disable()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function DisableBlizzard()
    --! require ReloadUI to take effect
    if init then return end
    init = true

    local config = DB.config

    -- unsaved changes cant open or close the window in combat
    local dialog = _G.EditModeUnsavedChangesDialog
    dialog.ProceedButton:SetScript("OnClick", OnProceed)
    dialog.SaveAndProceedButton:SetScript("OnClick", OnSaveProceed)

    -- the panel itself cant either
    _G.EditModeManagerFrame.onCloseCallback = OnClose

    -- disable EM button during combat
    local btn = GetGameMenuEditModeButton()
    if btn then
        hooksecurefunc(btn, "SetEnabled", SetEnabled)
    end

    -- wait for combat leave to do stuff
    DB:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", LAYOUTS_UPDATED)
    DB:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", LAYOUTS_UPDATED)
    DB:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN)
    DB:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN)

    local mixin = _G.EditModeManagerFrame.AccountSettings
    if config.castBar then mixin.RefreshCastBar = AF.noop end
    if config.auras then mixin.RefreshBuffsAndDebuffs = AF.noop end
    if config.boss then mixin.RefreshBossFrames = AF.noop end
    if config.arena then mixin.RefreshArenaFrames = AF.noop end
    if config.raid then mixin.RefreshRaidFrames = AF.noop end
    if config.party then mixin.RefreshPartyFrames = AF.noop end
    if config.target and config.focus then
        mixin.RefreshTargetAndFocus = AF.noop
    end
    if config.actionBars then
        mixin.RefreshVehicleLeaveButton = AF.noop
        mixin.RefreshActionBarShown = AF.noop
        mixin.RefreshEncounterBar = AF.noop
        mixin.RefreshStatusTrackingBar2 = AF.noop

        for _, name in next, ignoreFrames do
            local frame = _G[name]
            if frame then
                frame.OnEditModeEnter = AF.noop
            end
        end
    end
end
BFI.RegisterCallback("DisableBlizzard", "EditMode", DisableBlizzard)