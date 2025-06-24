---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AB = BFI.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
local stanceBar
local function CreateStanceBar()
    stanceBar = CreateFrame("Frame", "BFI_StanceBar", AF.UIParent, "SecureHandlerStateTemplate")

    stanceBar.name = "stancebar"
    stanceBar.buttons = {}

    AB.bars[stanceBar.name] = stanceBar

    AF.CreateMover(stanceBar, "BFI: " .. L["Action Bars"], L["Stance Bar"])

    stanceBar:SetScript("OnEnter", AB.ActionBar_OnEnter)
    stanceBar:SetScript("OnLeave", AB.ActionBar_OnLeave)

    AF.AddToPixelUpdater_Auto(stanceBar, nil, true)
end

---------------------------------------------------------------------
-- assign bindings
---------------------------------------------------------------------
local function AssignBindings()
    if InCombatLockdown() then return end

    ClearOverrideBindings(stanceBar)

    for i, b in ipairs(stanceBar.buttons) do
        local command = ("SHAPESHIFTBUTTON%d"):format(i)
        for _, key in next, {GetBindingKey(command)} do
            b.hotkey:SetText(AB.GetHotkey(key) or "")
            if key and key ~= "" then
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
            -- cooldown:SetDrawBling(false)
        else
            cooldown:Clear()
        end
    end
end

---------------------------------------------------------------------
-- update buttons
---------------------------------------------------------------------
local function UpdateStanceButtonStatus()
    local num = GetNumShapeshiftForms()
    for i, b in next, stanceBar.buttons do
        if i <= num then
            local icon, active, castable, spellID = GetShapeshiftFormInfo(i)
            b.icon:SetTexture(icon)
            b.icon:SetVertexColor(AF.GetColorRGB(castable and "white" or "disabled"))

            -- ElvUI
            -- b.icon:SetTexture(C_Spell.GetSpellTexture(spellID))
            -- b:SetChecked(GetShapeshiftForm() ~= 0) -- not checked if no stance
            -- if active then
            --     if num == 1 then
            --         b.checkedTexture:SetColorTexture(AF.GetColorRGB("white", 0.25))
            --     else
            --         b.checkedTexture:SetColorTexture(AF.GetColorRGB("black", 0))
            --     end
            -- else
            --     b.checkedTexture:SetColorTexture(AF.GetColorRGB("black", 0.6))
            -- end
        end
    end
end

local function UpdateStanceButtons()
    if InCombatLockdown() then
        AB:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceButtons)
        return
    end
    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", UpdateStanceButtons)

    local num = GetNumShapeshiftForms()

    for i, b in next, stanceBar.buttons do
        if i <= num then
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

    UpdateStanceButtonStatus()
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdateStanceBar(_, module, which)
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
    end

    -- mover
    AF.UpdateMoverSave(stanceBar, config.position)

    -- events
    AB:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateStanceButtons)
    AB:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateStanceButtonStatus)
    AB:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", UpdateStanceButtonStatus)
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
            AF.ClearPoints(b.hotkey)
            AF.SetPoint(b.hotkey, t.position.anchor, t.position.offsetX, t.position.offsetY)
            b.hotkey:Show()
        end

        -- tooltip
        b.tooltip = AB.config.general.tooltip
    end

    -- load config
    AB.ReArrange(stanceBar, config.size, config.spacing, config.buttonsPerLine, config.num, config.anchor, config.orientation)
    AF.LoadPosition(stanceBar, config.position)

    stanceBar:SetFrameStrata(AB.config.general.frameStrata)
    stanceBar:SetFrameLevel(AB.config.general.frameLevel)

    stanceBar.alpha = config.alpha
    stanceBar:SetAlpha(config.alpha)

    stanceBar.enabled = config.enabled
    stanceBar.visibility = config.visibility

    UpdateStanceButtons()
    AssignBindings()
end
AF.RegisterCallback("BFI_UpdateModules", UpdateStanceBar)