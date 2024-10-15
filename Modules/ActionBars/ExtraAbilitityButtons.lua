---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AW = BFI.AW
local U = BFI.utils
local AB = BFI.ActionBars

local GetBindingKey = GetBindingKey

---------------------------------------------------------------------
-- zone ability
---------------------------------------------------------------------
local ZoneAbilityFrame = _G.ZoneAbilityFrame
local zoneAbilityHolder
local ZoneAbility_Reparent, ZoneAbility_UpdateScale, ZoneAbility_UpdateAbility

local function CreateZoneAbilityHolder()
    zoneAbilityHolder = CreateFrame("Frame", "BIF_ZoneAbilityHolder", AW.UIParent)
    AW.CreateMover(zoneAbilityHolder, L["Action Bars"], L["Zone Ability"])

    ZoneAbilityFrame:SetParent(zoneAbilityHolder)
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetAllPoints()
    ZoneAbilityFrame.ignoreInLayout = true

    ZoneAbilityFrame.SpellButtonContainer.holder = zoneAbilityHolder
    -- ZoneAbilityFrame.SpellButtonContainer:HookScript("OnEnter", ShowBindTooltip)
    -- ZoneAbilityFrame.SpellButtonContainer:HookScript("OnLeave", HideBindTooltip)

    hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", ZoneAbility_UpdateScale)
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", ZoneAbility_UpdateAbility)

    hooksecurefunc(ZoneAbilityFrame, "SetParent", function(_, parent)
        if parent ~= zoneAbilityHolder then
            if InCombatLockdown() then
                AB:RegisterEvent("PLAYER_REGEN_ENABLED", ZoneAbility_Reparent)
            else
                ZoneAbility_Reparent()
            end
        end
    end)
end

function ZoneAbility_Reparent()
    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", ZoneAbility_Reparent)
    ZoneAbilityFrame:SetParent(zoneAbilityHolder)
end

function ZoneAbility_UpdateScale()
    local scale = zoneAbilityHolder.scale
    local width, height = ZoneAbilityFrame.SpellButtonContainer:GetSize()
    zoneAbilityHolder:SetSize(width * scale, height * scale)
    ZoneAbilityFrame.Style:SetScale(scale)
    ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)
end

function ZoneAbility_UpdateAbility()
    ZoneAbilityFrame.Style:SetAlpha(zoneAbilityHolder.hideTexture and 0 or 1)
    for spellButton in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
        if spellButton and not spellButton.skinnedByBFI then
            spellButton.skinnedByBFI = true

            spellButton.holder = zoneAbilityHolder
            AB.StylizeButton(spellButton)
            AW.AddToPixelUpdater(spellButton)
        end
    end
end

---------------------------------------------------------------------
-- extra action
---------------------------------------------------------------------
local extraActionHolder
local ExtraActionBarFrame = _G.ExtraActionBarFrame
local ExtraAbilityContainer = _G.ExtraAbilityContainer
local ExtraAction_Reparent, ExtraAction_UpdateAbility
local extraButtons = {}

local function CreateExtraActionHolder()
    extraActionHolder = CreateFrame("Frame", "BIF_ExtraActionHolder", AW.UIParent)
    AW.CreateMover(extraActionHolder, L["Action Bars"], ExtraAbilityContainer.systemNameString)

    ExtraActionBarFrame:SetParent(extraActionHolder)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints()
    ExtraActionBarFrame.ignoreInLayout = true

    hooksecurefunc(ExtraAbilityContainer, "AddFrame", ExtraAction_UpdateAbility)

    hooksecurefunc(ExtraActionBarFrame, "SetParent", function(_, parent)
        if parent ~= extraActionHolder then
            if InCombatLockdown() then
                AB:RegisterEvent("PLAYER_REGEN_ENABLED", ExtraAction_Reparent)
            else
                ExtraAction_Reparent()
            end
        end
    end)
end

function ExtraAction_Reparent()
    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", ExtraAction_Reparent)
    ExtraActionBarFrame:SetParent(extraActionHolder)
end

function ExtraAction_UpdateAbility(_, frame)
    local button = frame.button
    if button and not button.skinnedByBFI then
        button.skinnedByBFI = true
        extraButtons[button] = true

        AB.StylizeButton(button)
        button.style:SetDrawLayer("BACKGROUND", -7)
        button.style:SetAlpha(extraActionHolder.hideTexture and 0 or 1)
        button.style:ClearAllPoints()
        button.style:SetScale(extraActionHolder.scale)
        button.style:SetPoint("CENTER", -2, 1)

        button:ClearAllPoints()
        button:SetAllPoints()
        AB.ApplyTextConfig(button.HotKey, extraActionHolder.font)
        button.HotKey:SetText(AB.GetHotkey(GetBindingKey(button.commandName)))

        AW.AddToPixelUpdater(button)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateButton(module, which)
    if module and module ~= "ActionBars" then return end
    if which and which ~= "extra" then return end

    local enabled = AB.config.general.enabled
    local extraAbilityEnabled = AB.config.extraAbilityButtons.enabled
    local zoneAbilityConfig = AB.config.extraAbilityButtons.zoneAbility
    local extraActionConfig = AB.config.extraAbilityButtons.extraAction

    if not (enabled and extraAbilityEnabled) then
        return
    end

    U.DisableEditMode(ExtraAbilityContainer)
    ExtraAbilityContainer:SetScript("OnShow", nil)
    ExtraAbilityContainer:SetScript("OnUpdate", nil)
    ExtraAbilityContainer.OnUpdate = nil
    ExtraAbilityContainer.IsLayoutFrame = nil

    -- zone ability -----------------------------------------------------
    if not zoneAbilityHolder then
        CreateZoneAbilityHolder()
    end

    AW.UpdateMoverSave(zoneAbilityHolder, zoneAbilityConfig.position)
    AW.LoadPosition(zoneAbilityHolder, zoneAbilityConfig.position)
    zoneAbilityHolder:SetFrameStrata(AB.config.general.frameStrata)
    zoneAbilityHolder:SetFrameLevel(AB.config.general.frameLevel)

    zoneAbilityHolder.scale = zoneAbilityConfig.scale
    AW.SetSize(zoneAbilityHolder, 52 * zoneAbilityConfig.scale, 52 * zoneAbilityConfig.scale) -- default size of ZoneAbilityFrame.SpellButtonContainer

    zoneAbilityHolder.hideTexture = zoneAbilityConfig.hideTexture
    ZoneAbilityFrame.Style:SetAlpha(zoneAbilityConfig.hideTexture and 0 or 1)


    -- extra action -----------------------------------------------------
    if not extraActionHolder then
        CreateExtraActionHolder()
    end

    AW.UpdateMoverSave(extraActionHolder, extraActionConfig.position)
    AW.LoadPosition(extraActionHolder, extraActionConfig.position)
    extraActionHolder:SetFrameStrata(AB.config.general.frameStrata)
    extraActionHolder:SetFrameLevel(AB.config.general.frameLevel)

    extraActionHolder.font = extraActionConfig.hotkey

    extraActionHolder.scale = extraActionConfig.scale
    -- ExtraActionBarFrame:SetScale(extraActionConfig.scale)
    local w, h = ExtraActionBarFrame.button:GetSize()
    extraActionHolder:SetSize(w * extraActionConfig.scale, h * extraActionConfig.scale)

    extraActionHolder.hideTexture = extraActionConfig.hideTexture
    for button in pairs(extraButtons) do
        button.style:SetAlpha(extraActionConfig.hideTexture and 0 or 1)
        AB.ApplyTextConfig(button.HotKey, extraActionConfig.hotkey)
    end
end
BFI.RegisterCallback("UpdateModules", "AB_Extra", UpdateButton)