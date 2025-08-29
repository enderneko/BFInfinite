---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class ActionBars
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local RANGE_INDICATOR = _G.RANGE_INDICATOR
local DEFAULT_BINDINGS = Enum.BindingSet.Default
local ACCOUNT_BINDINGS = Enum.BindingSet.Account
local CHARACTER_BINDINGS = Enum.BindingSet.Character
local GetBindingKey = GetBindingKey
local GetCurrentBindingSet = GetCurrentBindingSet
local LoadBindings = LoadBindings
local SaveBindings = SaveBindings
local SetBinding = SetBinding

local keybindFrame
local keybindModeActive = false

local keybindOverlayParent = CreateFrame("Frame", "BFIKeybindOverlayParent", AF.UIParent)
keybindOverlayParent:SetAllPoints(AF.UIParent)
keybindOverlayParent:Hide()

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function Init()
    keybindFrame = AF.CreateHeaderedFrame(AF.UIParent, "BFIKeybindModeFrame", "BFI " .. L["Keybind Mode"], 375, 140, "DIALOG")
    keybindFrame:Hide()
    keybindFrame:SetOnHide(AB.DeactivateKeybindMode)

    keybindFrame.header.closeBtn:Hide()

    -- _G.QUICK_KEYBIND_DESCRIPTION
    local str = L["Mouse over a button and press the desired key to set the binding for that button or press ESC to unbind"]
        .. "\n" .. AF.WrapTextInColor(L["Bindings will only be saved after clicking %s"]:format(_G.OKAY), "firebrick")

    local text = AF.CreateFontString(keybindFrame, str)
    AF.SetPoint(text, "TOPLEFT", 10, -10)
    AF.SetPoint(text, "TOPRIGHT", -10, -10)
    text:SetJustifyH("LEFT")
    text:SetSpacing(5)

    local ok = AF.CreateButton(keybindFrame, _G.OKAY, "red", 90, 18)
    AF.SetPoint(ok, "BOTTOMLEFT", 7, 7)
    ok:SetOnClick(function()
        AB.DeactivateKeybindMode()
        SaveBindings(GetCurrentBindingSet())
    end)

    local cancel = AF.CreateButton(keybindFrame, _G.CANCEL, "red", 90, 18)
    AF.SetPoint(cancel, "BOTTOMRIGHT", -7, 7)
    cancel:SetOnClick(function()
        AB.DeactivateKeybindMode()
        LoadBindings(GetCurrentBindingSet())
    end)

    local resetToDefault = AF.CreateButton(keybindFrame, _G.RESET_TO_DEFAULT, "red")
    AF.SetPoint(resetToDefault, "TOPLEFT", ok, "TOPRIGHT", 7, 0)
    AF.SetPoint(resetToDefault, "BOTTOMRIGHT", cancel, "BOTTOMLEFT", -7, 0)
    resetToDefault:SetOnClick(function()
        AF.ShowGlobalDialog(_G.CONFIRM_RESET_KEYBINDINGS .. "\n" .. AF.WrapTextInColor(L["This option takes effect immediately"], "firebrick"), function()
            LoadBindings(DEFAULT_BINDINGS)
            SaveBindings(GetCurrentBindingSet())
        end, nil, true)
    end)

    local character = AF.CreateCheckButton(keybindFrame, _G.CHARACTER_SPECIFIC_KEYBINDINGS)
    keybindFrame.character = character
    AF.SetPoint(character, "BOTTOMLEFT", ok, "TOPLEFT", 0, 10)
    character:SetTooltip(L["This option takes effect immediately"])
    character:SetOnCheck(function(checked)
        if checked then -- character
            -- Settings.SelectCharacterBindings()
            SaveBindings(ACCOUNT_BINDINGS)
            LoadBindings(CHARACTER_BINDINGS)
            SaveBindings(CHARACTER_BINDINGS)
        else -- account
            AF.ShowGlobalDialog(_G.CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS .. "\n" .. AF.WrapTextInColor(L["This option takes effect immediately"], "firebrick"), function()
                -- Settings.SelectAccountBindings()
                LoadBindings(ACCOUNT_BINDINGS)
                SaveBindings(ACCOUNT_BINDINGS)
            end, function()
                character:SetChecked(true)
            end, true)
        end
    end)
end

---------------------------------------------------------------------
-- keybind overlay
---------------------------------------------------------------------
local overlays = {}

local function GetModifier()
    local modifier = ""
    local alt = IsAltKeyDown()
    local ctrl = IsControlKeyDown()
    local shift = IsShiftKeyDown()
    local meta = IsMetaKeyDown()

    if alt then modifier = "ALT-" end
    if ctrl then  modifier = modifier .. "CTRL-" end
    if shift then modifier = modifier .. "SHIFT-" end
    if meta then modifier = modifier .. "META-" end

    return modifier
end

local function PrepareBinding(self)
    local keyBoundTarget = self.keyBoundTarget or self.button.keyBoundTarget
    local keys = {GetBindingKey(keyBoundTarget)}

    for _, k in next, keys do
        SetBinding(k) -- clear
    end

    return keyBoundTarget, keys[1], keys[2]
end

local function UpdateBinding(keyBoundTarget, newKey, key1, key2)
    if key1 and key2 then
        -- key1 and key2 both exist, replace key1
        SetBinding(newKey, keyBoundTarget)
        SetBinding(key2, keyBoundTarget)
    elseif key1 then
        -- key1 exists, restore key1, add newKey as key2
        SetBinding(key1, keyBoundTarget)
        SetBinding(newKey, keyBoundTarget)
    else
        SetBinding(newKey, keyBoundTarget)
    end
end

local function Overlay_OnKeyDown(self, key)
    if key == "ENTER"
        or key == "LALT" or key == "RALT"
        or key == "LCTRL" or key == "RCTRL"
        or key == "LSHIFT" or key == "RSHIFT"
        or key == "LMETA" or key == "RMETA" then
        return
    end

    local keyBoundTarget, key1, key2 = PrepareBinding(self)

    if key == "ESCAPE" then
        return
    end

    local newKey = GetModifier() .. key

    UpdateBinding(keyBoundTarget, newKey, key1, key2)
    -- print(self.button:GetName(), GetBindingKey(keyBoundTarget))
end

local function Overlay_OnMouseDown(self, button)
    if button == "MiddleButton" then button = "BUTTON3" end
    button = button:upper()

    if not button:find("^BUTTON") then return end

    local keyBoundTarget, key1, key2 = PrepareBinding(self)

    local newKey = GetModifier() .. button

    UpdateBinding(keyBoundTarget, newKey, key1, key2)
end

local function Overlay_OnMouseWheel(self, delta)
    local keyBoundTarget, key1, key2 = PrepareBinding(self)

    local newKey = delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"
    newKey = GetModifier() .. newKey

    UpdateBinding(keyBoundTarget, newKey, key1, key2)
end

local function Overlay_OnEnter(self)
    self:SetBackdropColor(AF.GetColorRGB("darkgray", 0.6))
    self:SetScript("OnKeyDown", Overlay_OnKeyDown)
    self:SetScript("OnMouseDown", Overlay_OnMouseDown)
    self:SetScript("OnMouseWheel", Overlay_OnMouseWheel)
    -- print(GetBindingKey(self.keyBoundTarget or self.button.keyBoundTarget))
end

local function Overlay_OnLeave(self)
    self:SetBackdropColor(AF.GetColorRGB("background", 0.6))
    self:SetScript("OnKeyDown", nil)
    self:SetScript("OnMouseDown", nil)
    self:SetScript("OnMouseWheel", nil)
end

local function UpdateBindingText(self)
    self.text:SetFormattedText("%s\n%s", self.button:GetHotKeys())
end

local function Overlay_OnShow(self)
    local button = self.button

    if button.HotKey then button.HotKey:SetAlpha(0) end
    if button.Count then button.Count:SetAlpha(0) end
    if button.Name then button.Name:SetAlpha(0) end

    UpdateBindingText(self)

    if (button.enabled or button:GetParent().enabled) and not button:GetAttribute("statehidden") then
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self:EnableKeyboard(true)
        self:SetAlpha(1)
    else
        self:EnableMouse(false)
        self:EnableMouseWheel(false)
        self:EnableKeyboard(false)
        self:SetAlpha(0)
    end
end

local function Overlay_OnHide(self)
    local button = self.button
    if button.HotKey then button.HotKey:SetAlpha(1) end
    if button.Count then button.Count:SetAlpha(1) end
    if button.Name then button.Name:SetAlpha(1) end
    self:SetScript("OnKeyDown", nil)
    self:SetScript("OnMouseWheel", nil)
end

function AB.CreateKeybindOverlay(button, keyBoundTarget)
    local overlay = AF.CreateFrame(keybindOverlayParent)
    tinsert(overlays, overlay)
    overlay.button = button
    overlay.keyBoundTarget = keyBoundTarget
    AF.ApplyDefaultBackdropWithColors(overlay, AF.GetColorTable("background", 0.6), "border")
    overlay:SetAllPoints(button)

    overlay:SetOnShow(Overlay_OnShow)
    overlay:SetOnHide(Overlay_OnHide)
    overlay:SetOnEnter(Overlay_OnEnter)
    overlay:SetOnLeave(Overlay_OnLeave)

    overlay.text = overlay:CreateFontString(nil, "OVERLAY")
    overlay.text:SetFont(AF_FONT_NORMAL:GetFont(), 11, "OUTLINE")
    AF.AddToFontSizeUpdater(overlay.text, 11)
    overlay.text:SetPoint("CENTER")
end

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local function UPDATE_BINDINGS()
    for _, overlay in next, overlays do
        UpdateBindingText(overlay)
    end
end

function AB.ActivateKeybindMode()
    if InCombatLockdown() then return end

    keybindModeActive = true

    if not keybindFrame then
        Init()
    end

    keybindFrame:ClearAllPoints()
    keybindFrame:SetPoint("BOTTOM", AF.UIParent, "CENTER", 0, 100)
    keybindFrame:Show()
    keybindFrame.character:SetChecked(GetCurrentBindingSet() == CHARACTER_BINDINGS)
    keybindOverlayParent:Show()

    AB:RegisterEvent("PLAYER_REGEN_DISABLED", AB.DeactivateKeybindMode)
    AB:RegisterEvent("UPDATE_BINDINGS", UPDATE_BINDINGS)
end

function AB.DeactivateKeybindMode()
    keybindModeActive = false

    if not keybindFrame then return end
    keybindFrame:Hide()
    keybindOverlayParent:Hide()

    AB:UnregisterEvent("PLAYER_REGEN_DISABLED", AB.DeactivateKeybindMode)
    AB:UnregisterEvent("UPDATE_BINDINGS", UPDATE_BINDINGS)
end

function AB.IsKeybindModeActive()
    return keybindModeActive
end

---------------------------------------------------------------------
-- modify settings panel "Quick Keybind Mode" button
---------------------------------------------------------------------
local function OnClick()
    if not InCombatLockdown() then
        HideUIPanel(_G.SettingsPanel)
        if not keybindModeActive then
            AB.ActivateKeybindMode()
        end
    end
end

local function Modify(self, category)
    if category.name ~= _G.SETTINGS_KEYBINDINGS_LABEL then return end
    -- texplore(self:GetSettingsList())
    local layout = _G.SettingsPanel:GetLayout(category)

    -- texplore(layout.initializers[3])
    local initializer = layout.initializers[3]
    if initializer then
        -- REVIEW: will this cause taints?
        initializer.data.buttonText = "BFI " .. L["Keybind Mode"]
        initializer.data.buttonClick = OnClick
        _G.SettingsPanel:DisplayLayout(layout)
    end

    AF.Unhook(_G.SettingsPanel, "DisplayCategory", Modify)
end

AF.RegisterCallback("AF_PLAYER_LOGIN_DELAYED", function()
    AF.Hook(_G.SettingsPanel, "DisplayCategory", Modify)
end)

---------------------------------------------------------------------
-- deactivate keybind mode on module update
---------------------------------------------------------------------
AF.RegisterCallback("BFI_UpdateModule", function(_, module, which)
    if module ~= "actionBars" then return end
    if not keybindModeActive then return end
    AB.DeactivateKeybindMode()
end)