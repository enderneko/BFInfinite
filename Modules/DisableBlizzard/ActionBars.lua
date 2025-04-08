---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local DB = BFI.DisableBlizzard
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- forked from ElvUI
---------------------------------------------------------------------
local blizzard = {
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "MultiBarLeft",
    "MultiBarRight",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MicroButtonAndBagsBar",
    "OverrideActionBar",
    "MainMenuBar",
    BFI.vars.isRetail and "StanceBar" or "StanceBarFrame",
    BFI.vars.isRetail and "PetActionBar" or "PetActionBarFrame",
    BFI.vars.isRetail and "PossessActionBar" or "PossessBarFrame",
}

-- if BFI.vars.isCata then -- Wrath TotemBar needs to be handled by us
--     _G.UIPARENT_MANAGED_FRAME_POSITIONS.MultiCastActionBarFrame = nil
-- end

local settingsHider = CreateFrame("Frame")
settingsHider:SetScript("OnEvent", function(frame, event)
    HideUIPanel(_G.SettingsPanel)
    frame:UnregisterEvent(event)
end)

local funcs = {"ClearAllPoints", "SetPoint", "SetScale", "SetShown"}
local function SetNoop(f)
    if not f then return end
    for _, func in pairs(funcs) do
        if f[func] ~= AF.noop then
            frame[func] = AF.noop
        end
    end
end

local function ButtonEventsRegisterFrame(added)
    local frames = _G.ActionBarButtonEventsFrame.frames
    for index = #frames, 1, -1 do
        local frame = frames[index]
        local wasAdded = frame == added
        if not added or wasAdded then
            if not strmatch(frame:GetName(), "ExtraActionButton%d") then
                frames[index] = nil
            end
            if wasAdded then
                break
            end
        end
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

    if not DB.config.actionBars then return end

    for _, name in pairs(blizzard) do
        -- if not BFI.vars.isRetail then
        --     _G.UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
        -- end

        local frame = _G[name]
        if frame then
            frame:SetParent(BFI.hiddenParent)
            frame:UnregisterAllEvents()

            if not BFI.vars.isRetail then
                SetNoop(frame)
            elseif name == "PetActionBar" then
                frame.UpdateVisibility = AF.noop
            end
        end
    end

    -- if not BFI.vars.isRetail then
    --     FixSpellBookTaint()
    -- end

    -- shut down some events for things we dont use
    _G.ActionBarController:UnregisterAllEvents()
    _G.ActionBarActionEventsFrame:UnregisterAllEvents()
    _G.ActionBarButtonEventsFrame:UnregisterAllEvents()

    -- used for ExtraActionButton and TotemBar (on wrath)
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- needed to let the ExtraActionButton show and Totems to swap
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- needed for cooldowns of them both

    if BFI.vars.isRetail then
        U.Hide(_G.StatusTrackingBarManager)
        _G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- this is needed for page controller to spawn properly
        _G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- this is needed to let the ExtraActionBar show

        -- take encounter bar out of edit mode
        U.DisableEditMode(_G.EncounterBar)

        -- lets only keep ExtraActionButtons in here
        hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", ButtonEventsRegisterFrame)
        ButtonEventsRegisterFrame()

        -- crop the new spells being added to the actionbars
        _G.IconIntroTracker:HookScript("OnEvent", function(self)
            local l, r, t, b = 0.1, 0.9, 0.1, 0.9
            for _, iconIntro in ipairs(self.iconList) do
                if not iconIntro.isSkinned then
                    iconIntro.trail1.icon:SetTexCoord(l, r, t, b)
                    iconIntro.trail1.bg:SetTexCoord(l, r, t, b)

                    iconIntro.trail2.icon:SetTexCoord(l, r, t, b)
                    iconIntro.trail2.bg:SetTexCoord(l, r, t, b)

                    iconIntro.trail3.icon:SetTexCoord(l, r, t, b)
                    iconIntro.trail3.bg:SetTexCoord(l, r, t, b)

                    iconIntro.icon.icon:SetTexCoord(l, r, t, b)
                    iconIntro.icon.bg:SetTexCoord(l, r, t, b)

                    iconIntro.isSkinned = true
                end
            end
        end)

        -- dont reopen game menu and fix settings panel not being able to close during combat
        _G.SettingsPanel.TransitionBackOpeningPanel = function(frame)
            if InCombatLockdown() then
                settingsHider:RegisterEvent("PLAYER_REGEN_ENABLED")
                frame:SetScale(0.00001)
            else
                HideUIPanel(frame)
            end
        end

        -- change the text of the remove paging
        -- hooksecurefunc(_G.SettingsPanel.Container.SettingsList.ScrollBox, "Update", function(frame)
        --     for _, child in next, { frame.ScrollTarget:GetChildren() } do
        --         local option = child.data and child.data.setting
        --         local variable = option and option.variable
        --         if variable and strsub(variable, 0, -3) == "PROXY_SHOW_ACTIONBAR" then
        --             local num = tonumber(strsub(variable, 22))
        --             if num and num <= 5 then -- NUM_ACTIONBAR_PAGES - 1
        --                 child.Text:SetFormattedText(L["Remove Bar %d Action Page"], num)
        --             else
        --                 child.CheckBox:SetEnabled(false)
        --                 child:DisplayEnabled(false)
        --             end
        --         end
        --     end
        -- end)
    else
        -- SetNoop(_G.MainMenuBarArtFrame)
        -- SetNoop(_G.MainMenuBarArtFrameBackground)
        -- _G.MainMenuBarArtFrame:UnregisterAllEvents()

        -- -- this would taint along with the same path as the SetNoopers: ValidateActionBarTransition
        -- _G.VerticalMultiBarsContainer:Size(10) -- dummy values so GetTop etc doesnt fail without replacing
        -- SetNoop(_G.VerticalMultiBarsContainer)

        -- -- hide some interface options we dont use
        -- _G.InterfaceOptionsActionBarsPanelStackRightBars:SetScale(0.5)
        -- _G.InterfaceOptionsActionBarsPanelStackRightBars:SetAlpha(0)
        -- _G.InterfaceOptionsActionBarsPanelStackRightBarsText:Hide() -- hides the !
        -- _G.InterfaceOptionsActionBarsPanelRightTwoText:SetTextColor(1,1,1) -- no yellow
        -- _G.InterfaceOptionsActionBarsPanelRightTwoText.SetTextColor = E.noop -- i said no yellow
        -- _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetScale(0.00001)
        -- _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
        -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.00001)
        -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
        -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)
        -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
        -- _G.InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.00001)
        -- _G.InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)

        -- _G.InterfaceOptionsCombatPanelAutoSelfCast:Hide()
        -- _G.InterfaceOptionsCombatPanelSelfCastKeyDropDown:Hide()

        -- if not E.Classic then
        --     _G.InterfaceOptionsCombatPanelFocusCastKeyDropDown:Hide()
        -- end
    end

    -- if BFI.vars.isCata and BFI.vars.playerClass ~= "SHAMAN" then
    --     for i = 1, 12 do
    --         local button = _G["MultiCastActionButton"..i]
    --         button:Hide()
    --         button:UnregisterAllEvents()
    --         button:SetAttribute("statehidden", true)
    --     end
    -- end

    -- if BFI.vars.isCata then
    --     if _G.PlayerTalentFrame then
    --         _G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    --     else
    --         hooksecurefunc("TalentFrame_LoadUI", function()
    --             _G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    --         end)
    --     end
    -- end
end
BFI.RegisterCallback("DisableBlizzard", "ActionBars", DisableBlizzard)