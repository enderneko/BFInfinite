local _, BFI = ...

local EM = {}
BFI.AddEventHandler(EM)

local CheckTargetFrame = function() return true end
local CheckCastFrame = function() return true end
local CheckArenaFrame = function() return true end
local CheckPartyFrame = function() return true end
local CheckFocusFrame = function() return true end
local CheckRaidFrame = function() return true end
local CheckBossFrame = function() return true end
local CheckAuraFrame = function() return true end
local CheckActionBar = function() return true end

local ignoreFrames = {
    "MainStatusTrackingBarContainer", -- Experience Bar
    "MicroMenuContainer", -- MicroBar / Menu
}

local hideFrames = {}
local needsUpdate = false

function EM.LAYOUTS_UPDATED(_, event, arg1)
    local allow = event ~= "PLAYER_SPECIALIZATION_CHANGED" or arg1 == "player"
    if allow and not _G.EditModeManagerFrame:IsEventRegistered(event) then
        needsUpdate = true
    end
end

-- hooksecurefunc(GameMenuFrame, "AddButton", function(...)
--     print(...)
-- end)

function EM.PLAYER_REGEN(event)
    local editMode = _G.EditModeManagerFrame
    local combatLeave = event == "PLAYER_REGEN_ENABLED"
    -- _G.GameMenuButtonEditMode:SetEnabled(combatLeave)

    -- if combatLeave then
    --     EditModeManagerFrame:BlockEnteringEditMode(EM)
    -- else
    --     EditModeManagerFrame:UnblockEnteringEditMode(EM)
    -- end

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

function EM.HandleHide(frame)
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

function EM.OnProceed()
    local editMode = _G.EditModeManagerFrame
    local dialog = _G.EditModeUnsavedChangesDialog
    if dialog.selectedLayoutIndex then
        editMode:SelectLayout(dialog.selectedLayoutIndex)
    else
        EM.HandleHide(editMode, dialog)
    end

    StaticPopupSpecial_Hide(dialog)
end

function EM.OnSaveProceed()
    _G.EditModeManagerFrame:SaveLayoutChanges()
    EM.OnProceed()
end

function EM.OnClose()
    local editMode = _G.EditModeManagerFrame
    if editMode:HasActiveChanges() then
        editMode:ShowRevertWarningDialog()
    else
        EM.HandleHide(editMode)
    end
end

function EM.SetEnabled(self, enabled)
    if InCombatLockdown() and enabled then
        self:Disable()
    end
end

function EM.Initialize()
    -- unsaved changes cant open or close the window in combat
    local dialog = _G.EditModeUnsavedChangesDialog
    dialog.ProceedButton:SetScript("OnClick", EM.OnProceed)
    dialog.SaveAndProceedButton:SetScript("OnClick", EM.OnSaveProceed)

    -- the panel itself cant either
    _G.EditModeManagerFrame.onCloseCallback = EM.OnClose

    -- keep the button off during combat
    -- hooksecurefunc(_G.GameMenuButtonEditMode, "SetEnabled", EM.SetEnabled)

    -- wait for combat leave to do stuff
    EM:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", EM.LAYOUTS_UPDATED)
    EM:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EM.LAYOUTS_UPDATED)
    EM:RegisterEvent("PLAYER_REGEN_ENABLED", EM.PLAYER_REGEN)
    EM:RegisterEvent("PLAYER_REGEN_DISABLED", EM.PLAYER_REGEN)

    -- account settings will be tainted
    local mixin = _G.EditModeManagerFrame.AccountSettings
    if CheckCastFrame() then mixin.RefreshCastBar = BFI.dummy end
    if CheckAuraFrame() then mixin.RefreshBuffsAndDebuffs = BFI.dummy end
    if CheckBossFrame() then mixin.RefreshBossFrames = BFI.dummy end
    if CheckArenaFrame() then mixin.RefreshArenaFrames = BFI.dummy end
    if CheckRaidFrame() then mixin.RefreshRaidFrames = BFI.dummy end
    if CheckPartyFrame() then mixin.RefreshPartyFrames = BFI.dummy end
    if CheckTargetFrame() and CheckFocusFrame() then
        mixin.RefreshTargetAndFocus = BFI.dummy
    end
    if CheckActionBar() then
        mixin.RefreshVehicleLeaveButton = BFI.dummy
        mixin.RefreshActionBarShown = BFI.dummy
        mixin.RefreshEncounterBar = BFI.dummy
        mixin.RefreshStatusTrackingBar2 = BFI.dummy

        for _, name in next, ignoreFrames do
            local frame = _G[name]
            if frame then
                frame.OnEditModeEnter = BFI.dummy
            end
        end
    end
end

EM:RegisterEvent("PLAYER_LOGIN", EM.Initialize)