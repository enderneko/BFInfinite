---@class BFI
local BFI = select(2, ...)
local T = BFI.Tooltip
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local tooltipAnchor
local GameTooltip = GameTooltip

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
local InCombatLockdown = InCombatLockdown

local function UpdateAnchor(tooltip, parent)
    if not T.config.enabled or tooltip:IsForbidden() or tooltip:GetAnchorType() ~= "ANCHOR_NONE" then
        return
    end

    tooltip:ClearAllPoints()

    if parent.tooltip then
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
        local point = GetTooltipAnchorPoint(tooltipAnchor)
        tooltip:SetPoint(point, tooltipAnchor)
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

    if not config.enabled then return end

    if not init then
        init = true
        InitTooltip()
    end

    AF.UpdateMoverSave(tooltipAnchor, config.position)
    AF.LoadPosition(tooltipAnchor, config.position)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateTooltip)