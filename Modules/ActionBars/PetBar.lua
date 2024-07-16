local _, BFI = ...
local L = BFI.L
local U = BFI.utils
local AW = BFI.AW
local AB = BFI.M_AB

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
local petBar
local function CreatePetBar()
    petBar = CreateFrame("Frame", "BFI_PetBar", AW.UIParent, "SecureHandlerStateTemplate")

    petBar.name = "petbar"
    petBar.buttons = {}

    AB.bars[petBar.name] = petBar

    AW.CreateMover(petBar, "ActionBars", L["Pet Bar"], function(p,x,y) print("PetBar:", p, x, y) end)

    petBar:SetScript("OnEnter", AB.ActionBar_OnEnter)
    petBar:SetScript("OnLeave", AB.ActionBar_OnLeave)
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

    ClearOverrideBindings(petBar)

    for i, b in ipairs(petBar.buttons) do
        for _, key in next, {GetBindingKey("BONUSACTIONBUTTON"..i)} do
            b.hotkey:SetText(GetHotKey(key))
            if key ~= "" then
                SetOverrideBindingClick(petBar, false, key, b:GetName())
            end
        end
    end
end

---------------------------------------------------------------------
-- update cooldown
---------------------------------------------------------------------
local function UpdatePetCooldowns()
    for i, b in pairs(petBar.buttons) do
        local start, duration = GetPetActionCooldown(i)
        b.cooldown:SetCooldown(start, duration)

        if not GameTooltip:IsForbidden() and GameTooltip:GetOwner() == b then
            b:OnEnter()
        end
    end
end

---------------------------------------------------------------------
-- update buttons
---------------------------------------------------------------------
local function UpdatePetButtons(event, unit)
    if (event == "UNIT_FLAGS" and unit ~= "pet") or (event == "UNIT_PET" and unit ~= "player") then return end

    for i, b in pairs(petBar.buttons) do
        local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

        if isToken then
            b.icon:SetTexture(_G[texture])
            b.tooltipName = _G[name]
        else
            b.icon:SetTexture(texture)
            b.tooltipName = name
        end

        if spellID then
            local spell = Spell:CreateFromSpellID(spellID)
            b.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
                b.tooltipSubtext = spell:GetSpellSubtext()
            end)
        end

        if autoCastAllowed then
            -- b.AutoCastable:Show()
            b.AutoCastOverlay:Show()
        else
            -- b.AutoCastable:Hide()
            b.AutoCastOverlay:Hide()
        end

        if autoCastEnabled then
            -- AutoCastShine_AutoCastStart(b.AutoCastShine)
            b.AutoCastOverlay.Shine.Anim:Play()
        else
            -- AutoCastShine_AutoCastStop(b.AutoCastShine)
            b.AutoCastOverlay.Shine.Anim:Stop()
        end

        if name == "PET_ACTION_FOLLOW" or name == "PET_ACTION_WAIT" or name == "PET_ACTION_MOVE_TO"
            or name == "PET_MODE_AGGRESSIVE" or name == "PET_MODE_DEFENSIVE" or name == "PET_MODE_DEFENSIVEASSIST"
            or name == "PET_MODE_PASSIVE" or name == "PET_MODE_ASSIST" then
            b:SetChecked(true)
            b.checkedTexture:SetBlendMode("BLEND")

            if isActive then
                b.checkedTexture:SetColorTexture(AW.GetColorRGB("black", 0))
            else
                b.checkedTexture:SetColorTexture(AW.GetColorRGB("black", 0.6))
            end
        else
            b.checkedTexture:SetBlendMode("ADD")
            b.checkedTexture:SetColorTexture(AW.GetColorRGB("white", 0.25))

            if isActive then
                b:SetChecked(true)

                if IsPetAttackAction(i) then
                    if b.StartFlash then b:StartFlash() end
                end
            else
                b:SetChecked(false)

                if IsPetAttackAction(i) then
                    if b.StopFlash then b:StopFlash() end
                end
            end
        end

        if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
            if b.StartFlash then b:StopFlash() end
            b.icon:SetVertexColor(0.4, 0.4, 0.4)
            b.icon:SetDesaturation(1)
            b:SetChecked(false)
        elseif GetPetActionSlotUsable(i) then
            b.icon:SetVertexColor(1, 1, 1)
            b.icon:SetDesaturation(0)
        else
            b.icon:SetVertexColor(0.4, 0.4, 0.4)
            b.icon:SetDesaturation(1)
        end
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdatePetBar(module, which)
    if module and module ~= "ActionBars" then return end
    if which and which ~= "pet" then return end

    local enabled = AB.config.general.enabled
    local config = AB.config.barConfig.petbar

    if not (enabled and config.enabled) then
        AB:UnregisterEvent("PET_BAR_UPDATE")
        AB:UnregisterEvent("UNIT_PET")
        AB:UnregisterEvent("UNIT_FLAGS")
        AB:UnregisterEvent("PLAYER_CONTROL_GAINED")
        AB:UnregisterEvent("PLAYER_CONTROL_LOST")
        AB:UnregisterEvent("PLAYER_ENTERING_WORLD")
        AB:UnregisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
        AB:UnregisterEvent("SPELLS_CHANGED")
        AB:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
        AB:UnregisterEvent("UPDATE_BINDINGS", AssignBindings)
        return
    end

    if not petBar then
        CreatePetBar()
        AssignBindings()
    end

    -- events
    AB:RegisterEvent("PET_BAR_UPDATE", UpdatePetButtons)
    AB:RegisterEvent("UNIT_PET", UpdatePetButtons)
    AB:RegisterEvent("UNIT_FLAGS", UpdatePetButtons)
    AB:RegisterEvent("PLAYER_CONTROL_GAINED", UpdatePetButtons)
    AB:RegisterEvent("PLAYER_CONTROL_LOST", UpdatePetButtons)
    AB:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePetButtons)
    AB:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", UpdatePetButtons)
    AB:RegisterEvent("SPELLS_CHANGED", UpdatePetButtons)
    AB:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", UpdatePetCooldowns)
    AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)

    for i = 1, 10 do
        local b
        if not petBar.buttons[i] then
            b = AB.CreatePetButton(petBar, i)
            petBar.buttons[i] = b
        else
            b = petBar.buttons[i]
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
    AB.ReArrange(petBar, config.size, config.spacing, config.buttonsPerLine, config.num, config.anchor, config.orientation)
    AW.LoadPosition(petBar, config.position)

    petBar:SetFrameStrata(BFI.vars.currentConfigTable.actionBars.general.frameStrata)
    petBar:SetFrameLevel(BFI.vars.currentConfigTable.actionBars.general.frameLevel)

    petBar.alpha = config.alpha
    petBar:SetAlpha(config.alpha)

    petBar.enabled = config.enabled
    if config.enabled then
        RegisterStateDriver(petBar, "visibility", config.visibility)
        petBar:Show()
    else
        UnregisterStateDriver(petBar, "visibility")
        petBar:Hide()
    end

    -- update buttons
    UpdatePetButtons()
end
BFI.RegisterCallback("UpdateModules", "AB_PetBar", UpdatePetBar)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitPetBar()
--     CreatePetBar()
--     UpdatePetBar()
--     AssignBindings()

--     -- events
--     AB:RegisterEvent("PET_BAR_UPDATE", UpdatePetButtons)
--     AB:RegisterEvent("UNIT_PET", UpdatePetButtons)
--     AB:RegisterEvent("UNIT_FLAGS", UpdatePetButtons)
--     AB:RegisterEvent("PLAYER_CONTROL_GAINED", UpdatePetButtons)
--     AB:RegisterEvent("PLAYER_CONTROL_LOST", UpdatePetButtons)
--     AB:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePetButtons)
--     AB:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", UpdatePetButtons)
--     AB:RegisterEvent("SPELLS_CHANGED", UpdatePetButtons)
--     AB:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", UpdatePetCooldowns)
--     AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)
-- end
-- BFI.RegisterCallback("InitModules", "AB_PetBar", InitPetBar)