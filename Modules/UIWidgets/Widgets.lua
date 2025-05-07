---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local UI = BFI.UIWidgets
local U = BFI.utils
---@type AbstractFramework
local AF = _G.AbstractFramework

local function SetPoint(self, _, anchorTo)
    if anchorTo ~= self._container then
        self:ClearAllPoints()
        self:SetPoint(self._containerAnchor, self._container)
    end
end

local function InitWidget(frame, name, anchor, width, height, config)
    frame._container = CreateFrame("Frame", nil, AF.UIParent)
    AF.SetSize(frame._container, width * config.scale, height * config.scale)

    AF.CreateMover(frame._container, "BFI: " .. L["UI Widgets"], name, config.position)
    AF.LoadPosition(frame._container, config.position)

    -- frame
    frame:SetScale(config.scale)
    frame:SetParent(frame._container)
    frame._containerAnchor = anchor
    SetPoint(frame)
    hooksecurefunc(frame, "SetPoint", SetPoint)

    -- editmode
    U.DisableEditMode(frame)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateWidgets(_, module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "widgets" then return end

    local config = UI.config

    if not init then
        init = true
        InitWidget(_G.UIWidgetPowerBarContainerFrame, L["Power Bar Widget"], "CENTER", 150, 30, config.powerBarWidget)
        InitWidget(_G.VehicleSeatIndicator, _G.HUD_EDIT_MODE_VEHICLE_SEAT_INDICATOR_LABEL, "CENTER", 128, 128, config.vehicleSeats)
        InitWidget(_G.DurabilityFrame, _G.HUD_EDIT_MODE_DURABILITY_FRAME_LABEL, "CENTER", 90, 75, config.durability)
        InitWidget(_G.BNToastFrame, _G.SHOW_BATTLENET_TOASTS, "CENTER", 250, 50, config.battlenetToast)
    end

    _G.UIWidgetPowerBarContainerFrame._container:SetShown(config.powerBarWidget.enabled)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateWidgets)