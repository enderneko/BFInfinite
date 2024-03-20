local _, BFI = ...
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local AB = BFI.M_AB

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
    local num = GetNumShapeshiftForms()

    for i, b in pairs(stanceBar.buttons) do
        if i <= num then
            local icon, active, castable, spellID = GetShapeshiftFormInfo(i)
            b.icon:SetTexture(GetSpellTexture(spellID))

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
        end
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdateStanceBar(module)
    if module and module ~= "StanceBar" then return end

    if InCombatLockdown() then
        AB.RegisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceBar)
        return
    end

    AB.UnregisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceBar)

    local config = BFI.vars.currentConfigTable.actionBars.barConfig.stancebar

    for i = 1, 10 do
        local b
        if not stanceBar.buttons[i] then
            b = AB.CreateStanceButton(stanceBar, i)
            stanceBar.buttons[i] = b
        else
            b = stanceBar.buttons[i]
        end

        local blz = _G["StanceButton"..i]
        if blz and blz.commandName then
            b.commandName = blz.commandName -- SHAPESHIFTBUTTON1
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
    
    local num = GetNumShapeshiftForms()

    stanceBar.enabled = config.enabled
    if num ~= 0 and config.enabled then
        stanceBar:Show()
        RegisterStateDriver(stanceBar, "visibility", config.visibility)
    else
        stanceBar:Hide()
        UnregisterStateDriver(stanceBar, "visibility")
    end

    -- update button status
    UpdateStanceButtons()

    for i = 1, 10 do
        if i <= num then
            stanceBar.buttons[i]:Show()
        else
            stanceBar.buttons[i]:Hide()
        end
    end
end
BFI.RegisterCallback("UpdateModules", "StanceBar", UpdateStanceBar)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitStanceBar()
    CreateStanceBar()
    UpdateStanceBar()
    AssignBindings()

    -- events
    AB.RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateStanceBar)
    AB.RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateStanceButtons)
	AB.RegisterEvent("UPDATE_SHAPESHIFT_USABLE", UpdateStanceButtons)
    AB.RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", UPDATE_SHAPESHIFT_COOLDOWN)
    AB.RegisterEvent("UPDATE_BINDINGS", AssignBindings)
end
BFI.RegisterCallback("InitModules", "StanceBar", InitStanceBar)