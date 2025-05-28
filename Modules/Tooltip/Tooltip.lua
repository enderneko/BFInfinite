---@class BFI
local BFI = select(2, ...)
local T = BFI.Tooltip
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local tooltipAnchor
local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar
local InCombatLockdown = InCombatLockdown

---------------------------------------------------------------------
-- IsWorldUnitTooltip
---------------------------------------------------------------------
local function IsWorldUnitTooltip()
    local data = C_TooltipInfo.GetWorldCursor()
    return data and data.type == Enum.TooltipDataType.Unit
end

---------------------------------------------------------------------
-- IsModifierKeyDown
---------------------------------------------------------------------
local IsModifierKeyDown = AF.noop_true
local modifiers = {
    ["SHIFT"] = IsShiftKeyDown,
    ["CTRL"] = IsControlKeyDown,
    ["ALT"] = IsAltKeyDown,
}

---------------------------------------------------------------------
-- get anchor
---------------------------------------------------------------------
local function GetTooltipAnchorPoint(owner)
    local scale = owner:GetScale()
    local x, y = owner:GetCenter()
    local point, anchorPoint

    local height = AF.UIParent:GetTop() / scale
    local width = AF.UIParent:GetRight() / scale

    if y >= (height * 2 / 3) then
        point, anchorPoint = "TOP", "BOTTOM"
        y = -1
    else
        point, anchorPoint = "BOTTOM", "TOP"
        y = 1
    end

    if x >= (width * 2 / 3) then
        point = point .. "RIGHT"
        anchorPoint = anchorPoint .. "RIGHT"
        x = -1
    else
        point = point .. "LEFT"
        anchorPoint = anchorPoint .. "LEFT"
        x = 1
    end

    return point, anchorPoint, x, y
end

---------------------------------------------------------------------
-- update anchor
---------------------------------------------------------------------
local function UpdateAnchor(tooltip, parent)
    if not T.config.enabled or tooltip:IsForbidden() or tooltip:GetAnchorType() ~= "ANCHOR_NONE" then
        return
    end

    tooltip:ClearAllPoints()

    if parent.tooltip then
        --! use module settings
        local tt = parent.tooltip
        if tt.enabled and not (tt.hideInCombat and InCombatLockdown()) then

            if tt.anchorTo == "self" then
                tooltip:SetPoint(tt.position[1], parent, tt.position[2], tt.position[3], tt.position[4])
            elseif tt.anchorTo == "self_adaptive" then
                local point, anchorPoint, x, y = GetTooltipAnchorPoint(parent)
                tooltip:SetPoint(point, parent, anchorPoint, x, y)
            else
                local point = GetTooltipAnchorPoint(tooltipAnchor)
                tooltip:SetPoint(point, tooltipAnchor)
            end
        else
            tooltip:Hide()
        end

    else
        --! use tooltip settings
        if InCombatLockdown() and IsWorldUnitTooltip() and not IsModifierKeyDown() then
            return
        end

        if tooltip.StatusBar then
            local statusBar = tooltip.StatusBar
            statusBar:SetAlpha(T.config.healthBar.enabled and 1 or 0)
            -- AF.SetPoint(statusBar, "TOPLEFT", tooltip, "BOTTOMLEFT", 0, 0)
        end

        if T.config.cursorAnchor.type then
            -- NOTE: x, y won't be used if type is "ANCHOR_CURSOR"
            tooltip:SetOwner(parent, T.config.cursorAnchor.type, T.config.cursorAnchor.x, T.config.cursorAnchor.y)
        else
            local point = GetTooltipAnchorPoint(tooltipAnchor)
            tooltip:SetPoint(point, tooltipAnchor)
        end
    end
end

---------------------------------------------------------------------
-- WORLD_CURSOR_TOOLTIP_UPDATE
---------------------------------------------------------------------
local function WORLD_CURSOR_TOOLTIP_UPDATE(_, _, state)
    if GameTooltip:IsForbidden() or T.config.cursorAnchor.type then return end
    if state == 0 then
        -- hide immediately
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- toggle visibility in combat with modifier key
---------------------------------------------------------------------
local function MODIFIER_STATE_CHANGED(_, _, key, down)
    if not GameTooltip:IsForbidden() and InCombatLockdown() and IsWorldUnitTooltip() and key:find(T.config.combatModifierKey) then
        if down == 1 then
            GameTooltip:SetWorldCursor(Enum.WorldCursorAnchorType.Default)
        else
            GameTooltip:Hide()
        end
    end
end

local function PLAYER_REGEN_ENABLED()
    if not GameTooltip:IsForbidden() and IsWorldUnitTooltip() then
        GameTooltip:SetWorldCursor(Enum.WorldCursorAnchorType.Default)
    end
end

local function PLAYER_REGEN_DISABLED()
    if not GameTooltip:IsForbidden() and IsWorldUnitTooltip() then
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- UpdateStatusBarText
---------------------------------------------------------------------
local FormatNumber

local function UpdateStatusBarText(bar, value)
    if bar:IsForbidden() or not (T.config.healthBar.enabled and T.config.healthBar.text.enabled) or not bar.text then
        return
    end

    local _, unit = GameTooltip:GetUnit()

    local maxValue
    if unit then
        value = UnitHealth(unit)
        maxValue = UnitHealthMax(unit)
    else
        _, maxValue = bar:GetMinMaxValues()
    end

    if maxValue == 1 then
        bar.text:SetFormattedText("%.1f%%", value * 100)
    else
        bar.text:SetFormattedText("%s / %s", FormatNumber(value), FormatNumber(maxValue))
    end
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitTooltip()
    tooltipAnchor = CreateFrame("Frame", "BFI_TooltipAnchor", AF.UIParent)
    AF.SetSize(tooltipAnchor, 150, 30)
    AF.CreateMover(tooltipAnchor, "BFI: " .. _G.OTHER, L["Tooltip"])

    hooksecurefunc("GameTooltip_SetDefaultAnchor", UpdateAnchor)

    -- statusBar
    AF.SetHeight(GameTooltipStatusBar, 5)
    AF.AddToPixelUpdater(GameTooltipStatusBar)
    GameTooltipStatusBar:HookScript("OnValueChanged", UpdateStatusBarText)

    local text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
    GameTooltipStatusBar.text = text
    AF.SetFont(text, T.config.healthBar.text.font)
    text:SetPoint("CENTER")
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateTooltip(_, module, which)
    if module and module ~= "Tooltip" then return end

    local config = T.config

    if tooltipAnchor then
        tooltipAnchor.enabled = config.enabled
    end

    if not config.enabled then
        T:UnregisterAllEvents()
        return
    end

    if not init then
        init = true
        InitTooltip()
    end

    AF.UpdateMoverSave(tooltipAnchor, config.position)
    AF.LoadPosition(tooltipAnchor, config.position)

    if config.combatModifierKey then
        IsModifierKeyDown = modifiers[config.combatModifierKey]
        T:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
        T:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
        T:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
    else
        IsModifierKeyDown = AF.noop_true
        T:UnregisterEvent("MODIFIER_STATE_CHANGED")
        T:UnregisterEvent("PLAYER_REGEN_ENABLED")
        T:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end

    T:RegisterEvent("WORLD_CURSOR_TOOLTIP_UPDATE", WORLD_CURSOR_TOOLTIP_UPDATE)

    if config.healthBar.text.useAsianUnits and AF.isAsian then
        FormatNumber = AF.FormatNumber_Asian
    else
        FormatNumber = AF.FormatNumber
    end
end
AF.RegisterCallback("BFI_UpdateModules", UpdateTooltip)