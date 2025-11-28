---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local DB = BFI.modules.DisableBlizzard
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- forked from ElvUI
---------------------------------------------------------------------
local blizzard = {
    "MainActionBar",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarLeft",
    "MultiBarRight",
    "OverrideActionBar",
    "PetActionBar",
    "PossessActionBar",
    "StanceBar",
}

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
            sub[func] = AF.noop
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
        local frame = _G[name]
        if frame then
            frame:SetParent(AF.hiddenParent)
            frame:UnregisterAllEvents()

            -- if name == "PetActionBar" then
            --     frame.UpdateVisibility = AF.noop
            -- end
        else
            AF.Debug("DisableBlizzard ActionBars: Frame not found - " .. name)
        end
    end



    -- shut down some events for things we dont use
    _G.ActionBarController:UnregisterAllEvents()
    _G.ActionBarActionEventsFrame:UnregisterAllEvents()
    _G.ActionBarButtonEventsFrame:UnregisterAllEvents()

    -- used for ExtraActionButton and TotemBar (on wrath)
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- needed to let the ExtraActionButton show and Totems to swap
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- needed for cooldowns of them both

    _G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- this is needed for page controller to spawn properly
    _G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- this is needed to let the ExtraActionBar show

    do
        return true
    end


    -- lets only keep ExtraActionButtons in here
    hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", ButtonEventsRegisterFrame)
    ButtonEventsRegisterFrame()

    -- dont reopen game menu and fix settings panel not being able to close during combat
    _G.SettingsPanel.TransitionBackOpeningPanel = function(frame)
        if InCombatLockdown() then
            settingsHider:RegisterEvent("PLAYER_REGEN_ENABLED")
            frame:SetScale(0.00001)
        else
            HideUIPanel(frame)
        end
    end
end
AF.RegisterCallback("BFI_DisableBlizzard", DisableBlizzard)