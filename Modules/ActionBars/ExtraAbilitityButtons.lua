---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractFramework
local AF = _G.AbstractFramework
local U = BFI.utils
local AB = BFI.ActionBars

local GetBindingKey = GetBindingKey

---------------------------------------------------------------------
-- zone ability
---------------------------------------------------------------------
local ZoneAbilityFrame = _G.ZoneAbilityFrame
local zoneAbilityHolder
local ZoneAbility_UpdateParent, ZoneAbility_UpdateScale, ZoneAbility_UpdateAbility

local function CreateZoneAbilityHolder()
    zoneAbilityHolder = CreateFrame("Frame", "BIF_ZoneAbilityHolder", AF.UIParent)
    AF.CreateMover(zoneAbilityHolder, "BFI: " .. L["Action Bars"], L["Zone Ability"])

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
                AB:RegisterEvent("PLAYER_REGEN_ENABLED", ZoneAbility_UpdateParent)
            else
                ZoneAbility_UpdateParent()
            end
        end
    end)
end

function ZoneAbility_UpdateParent()
    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", ZoneAbility_UpdateParent)
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
    -- ZoneAbilityFrame.Style:ClearAllPoints()
    -- ZoneAbilityFrame.Style:SetPoint("CENTER", -1, 1)

    for spellButton in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
        if spellButton and not spellButton.skinnedByBFI then
            spellButton.skinnedByBFI = true

            spellButton.holder = zoneAbilityHolder
            AB.StylizeButton(spellButton)
            AF.AddToPixelUpdater(spellButton)
        end
    end
end

---------------------------------------------------------------------
-- extra action
---------------------------------------------------------------------
local extraActionHolder
local ExtraActionBarFrame = _G.ExtraActionBarFrame
local ExtraAbilityContainer = _G.ExtraAbilityContainer
local ExtraAction_UpdateParent, ExtraAction_UpdateAbility
local extraButtons = {}

local function CreateExtraActionHolder()
    extraActionHolder = CreateFrame("Frame", "BIF_ExtraActionHolder", AF.UIParent)
    AF.CreateMover(extraActionHolder, "BFI: " .. L["Action Bars"], ExtraAbilityContainer.systemNameString)

    ExtraActionBarFrame:SetParent(extraActionHolder)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints()
    ExtraActionBarFrame.ignoreInLayout = true

    hooksecurefunc(ExtraAbilityContainer, "AddFrame", ExtraAction_UpdateAbility)

    hooksecurefunc(ExtraActionBarFrame, "SetParent", function(_, parent)
        if parent ~= extraActionHolder then
            -- if InCombatLockdown() then
            --     AB:RegisterEvent("PLAYER_REGEN_ENABLED", ExtraAction_UpdateParent)
            -- else
                ExtraAction_UpdateParent()
            -- end
        end
    end)
end

function ExtraAction_UpdateParent()
    AB:UnregisterEvent("PLAYER_REGEN_ENABLED", ExtraAction_UpdateParent)
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
        -- button.style:SetScale(extraActionHolder.scale)
        -- button.style:ClearAllPoints()
        -- button.style:SetPoint("CENTER", -2, 1)

        -- invalid
        -- button:ClearAllPoints()
        -- button:SetAllPoints()

        AB.ApplyTextConfig(button.HotKey, extraActionHolder.font)
        button.HotKey:SetText(AB.GetHotkey(GetBindingKey(button.commandName)))

        AF.AddToPixelUpdater(button)
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

    local size = AF.ConvertPixels(52)

    -- zone ability -----------------------------------------------------
    if not zoneAbilityHolder then
        CreateZoneAbilityHolder()
    end

    AF.UpdateMoverSave(zoneAbilityHolder, zoneAbilityConfig.position)
    AF.LoadPosition(zoneAbilityHolder, zoneAbilityConfig.position)
    zoneAbilityHolder:SetFrameStrata(AB.config.general.frameStrata)
    zoneAbilityHolder:SetFrameLevel(AB.config.general.frameLevel)

    zoneAbilityHolder.scale = zoneAbilityConfig.scale
    AF.SetSize(zoneAbilityHolder, size * zoneAbilityConfig.scale, size * zoneAbilityConfig.scale) -- default size of ZoneAbilityFrame.SpellButtonContainer

    zoneAbilityHolder.hideTexture = zoneAbilityConfig.hideTexture
    ZoneAbilityFrame.Style:SetAlpha(zoneAbilityConfig.hideTexture and 0 or 1)


    -- extra action -----------------------------------------------------
    if not extraActionHolder then
        CreateExtraActionHolder()
    end

    AF.UpdateMoverSave(extraActionHolder, extraActionConfig.position)
    AF.LoadPosition(extraActionHolder, extraActionConfig.position)
    extraActionHolder:SetFrameStrata(AB.config.general.frameStrata)
    extraActionHolder:SetFrameLevel(AB.config.general.frameLevel)

    extraActionHolder.font = extraActionConfig.hotkey

    extraActionHolder.scale = extraActionConfig.scale
    extraActionHolder:SetSize(size * extraActionConfig.scale, size * extraActionConfig.scale)
    ExtraActionBarFrame:SetScale(extraActionConfig.scale)

    extraActionHolder.hideTexture = extraActionConfig.hideTexture
    for button in pairs(extraButtons) do
        button.style:SetAlpha(extraActionConfig.hideTexture and 0 or 1)
        AB.ApplyTextConfig(button.HotKey, extraActionConfig.hotkey)
    end
end
BFI.RegisterCallback("UpdateModules", "AB_Extra", UpdateButton)