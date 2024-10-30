---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractFramework
local AF = _G.AbstractFramework
---@class UIWidgets
local UI = BFI.UIWidgets

local function SetPoint(self, _, anchorTo)
    if anchorTo ~= self._container then
        self:ClearAllPoints()
        self:SetPoint(self._containerAnchor, self._container)
    end
end

local function InitWidget(frame, name, anchor, width, height, config)
    frame._container = CreateFrame("Frame", nil, AF.UIParent)
    AF.SetSize(frame._container, width, height)

    AF.CreateMover(frame._container, L["UI Widgets"], name, config.position)
    AF.LoadPosition(frame._container, config.position)

    -- frame
    frame:SetScale(config.scale)
    frame:SetParent(frame._container)
    frame._containerAnchor = anchor
    SetPoint(frame)
    hooksecurefunc(frame, "SetPoint", SetPoint)

    -- pixel perfect
    -- AF.AddToPixelUpdater(frame._container)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateWidgets(module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "widgets" then return end

    local config = UI.config

    if not init then
        init = true
        InitWidget(_G.UIWidgetPowerBarContainerFrame, L["Power Bar Widget"], "CENTER", 150, 30, config.powerBarWidget)
    end

    _G.UIWidgetPowerBarContainerFrame._container:SetShown(config.powerBarWidget.enabled)
end
BFI.RegisterCallback("UpdateModules", "UI_Widgets", UpdateWidgets)