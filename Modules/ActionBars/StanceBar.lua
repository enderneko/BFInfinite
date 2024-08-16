---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local AB = BFI.ActionBars

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
local stanceBar
local function CreateStanceBar()
    stanceBar = CreateFrame("Frame", "BFI_StanceBar", AW.UIParent, "SecureHandlerStateTemplate")

    stanceBar.name = "stancebar"
    stanceBar.buttons = {}

    AB.bars[stanceBar.name] = stanceBar

    AW.CreateMover(stanceBar, "ActionBars", L["Stance Bar"], function(p,x,y) print("StanceBar:", p, x, y) end)

    -- stanceBar:SetScript("OnEnter", AB.ActionBar_OnEnter)
    -- stanceBar:SetScript("OnLeave", AB.ActionBar_OnLeave)
end

---------------------------------------------------------------------
-- assign bindings
---------------------------------------------------------------------
local function GetHotKey(key)
    key = key:gsub("ALT%-", "A")
    key = key:gsub("CTRL%-", "C")
    key = key:gsub("SHIFT%-", "S")
    key = key:gsub("BUTTON", "B")
    key = key:gsub("MOUSEWHEELUP", "WU")
    key = key:gsub("MOUSEWHEELDOWN", "WD")
    return key
end

local function AssignBindings()
    if InCombatLockdown() then return end

    ClearOverrideBindings(stanceBar)

    for i, b in ipairs(stanceBar.buttons) do
        local command = b.commandName:format(i)
        for _, key in next, {GetBindingKey(command)} do
            b.hotkey:SetText(GetHotKey(key))
            if key ~= "" then
                SetOverrideBindingClick(stanceBar, false, key, b:GetName())
            end
        end
    end
end

---------------------------------------------------------------------
-- update cooldown
---------------------------------------------------------------------
local function UPDATE_SHAPESHIFT_COOLDOWN()
    for i = 1, GetNumShapeshiftForms() do
        local cooldown = stanceBar.buttons[i].cooldown
        local start, duration, active = GetShapeshiftFormCooldown(i)
        if (active and active ~= 0) and start > 0 and duration > 0 then
            cooldown:SetCooldown(start, duration)
            cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0)
        else
            cooldown:Clear()
        end
    end
end

---------------------------------------------------------------------
-- update buttons
---------------------------------------------------------------------
local function UpdateStanceButtons()
    if InCombatLockdown() then
        AB:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceButtons)
        return
    end

    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceButtons)

    local num = GetNumShapeshiftForms()

    for i, b in pairs(stanceBar.buttons) do
        if i <= num then
            local blz = _G["StanceButton"..i]
            if blz and blz.commandName then
                b.commandName = blz.commandName -- SHAPESHIFTBUTTON1
            end

            local icon, active, castable, spellID = GetShapeshiftFormInfo(i)
            b.icon:SetTexture(C_Spell.GetSpellTexture(spellID))

            b:SetChecked(GetShapeshiftForm() ~= 0) -- not checked if no stance

            if active then
                if num == 1 then
                    b.checkedTexture:SetColorTexture(AW.GetColorRGB("white", 0.25))
                else
                    b.checkedTexture:SetColorTexture(AW.GetColorRGB("black", 0))
                end
            else
                b.checkedTexture:SetColorTexture(AW.GetColorRGB("black", 0.6))
            end

            stanceBar.buttons[i]:Show()
        else
            stanceBar.buttons[i]:Hide()
        end
    end

    if num ~= 0 and stanceBar.enabled then
        stanceBar:Show()
        RegisterStateDriver(stanceBar, "visibility", stanceBar.visibility)
    else
        stanceBar:Hide()
        UnregisterStateDriver(stanceBar, "visibility")
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdateStanceBar(module, which)
    if module and module ~= "ActionBars" then return end
    if which and which ~= "stance" then return end

    local enabled = AB.config.general.enabled
    local config = AB.config.barConfig.stancebar

    if not (enabled and config.enabled) then
        AB:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS")
        AB:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
        AB:UnregisterEvent("UPDATE_SHAPESHIFT_USABLE")
        AB:UnregisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
        AB:UnregisterEvent("UPDATE_BINDINGS", AssignBindings)
        return
    end

    if not stanceBar then
        CreateStanceBar()
        AssignBindings()
    end

    -- events
    AB:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateStanceButtons)
    AB:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateStanceButtons)
	AB:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", UpdateStanceButtons)
    AB:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", UPDATE_SHAPESHIFT_COOLDOWN)
    AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)

    for i = 1, 10 do
        local b
        if not stanceBar.buttons[i] then
            b = AB.CreateStanceButton(stanceBar, i)
            stanceBar.buttons[i] = b
        else
            b = stanceBar.buttons[i]
        end

        if config.buttonConfig.hideElements.hotkey then
            b.hotkey:Hide()
        else
            local t = config.buttonConfig.text.hotkey
            b.hotkey:SetFont(t.font.font, t.font.size, t.font.flags)
            b.hotkey:SetTextColor(unpack(t.color))
            AW.ClearPoints(b.hotkey)
            AW.SetPoint(b.hotkey, t.position.anchor, t.position.offsetX, t.position.offsetY)
            b.hotkey:Show()
        end
    end

    -- load config
    AB.ReArrange(stanceBar, config.size, config.spacing, config.buttonsPerLine, config.num, config.anchor, config.orientation)
    AW.LoadPosition(stanceBar, config.position)

    stanceBar:SetFrameStrata(BFI.vars.currentConfigTable.actionBars.general.frameStrata)
    stanceBar:SetFrameLevel(BFI.vars.currentConfigTable.actionBars.general.frameLevel)

    stanceBar.alpha = config.alpha
    stanceBar:SetAlpha(config.alpha)

    stanceBar.enabled = config.enabled
    stanceBar.visibility = config.visibility
    UpdateStanceButtons()
end
BFI.RegisterCallback("UpdateModules", "AB_StanceBar", UpdateStanceBar)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitStanceBar()
--     CreateStanceBar()
--     UpdateStanceBar()
--     AssignBindings()

--     -- events
--     AB:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateStanceButtons)
--     AB:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateStanceButtons)
-- 	AB:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", UpdateStanceButtons)
--     AB:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", UPDATE_SHAPESHIFT_COOLDOWN)
--     AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)
-- end
-- BFI.RegisterCallback("InitModules", "AB_StanceBar", InitStanceBar)