---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local W = BFI.modules.UIWidgets
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local function SetPoint(self, _, anchorTo)
    if anchorTo ~= self._container then
        self:ClearAllPoints()
        self:SetPoint(self._containerAnchor, self._container)
    end
end

local function UpdateWidget(frame, name, anchor, width, height, config)
    if not frame._container then
        frame._container = CreateFrame("Frame", nil, AF.UIParent)
        frame._containerAnchor = anchor
        frame:SetParent(frame._container)
        SetPoint(frame)
        hooksecurefunc(frame, "SetPoint", SetPoint)

        AF.CreateMover(frame._container, "BFI: " .. L["UI Widgets"], name)
        F.DisableEditMode(frame)
    end

    AF.SetSize(frame._container, width * config.scale, height * config.scale)
    AF.LoadPosition(frame._container, config.position)
    AF.UpdateMoverSave(frame._container, config.position)
    frame:SetScale(config.scale)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateWidgets(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "widgets" then return end

    local config = W.config

    UpdateWidget(_G.UIWidgetPowerBarContainerFrame, L["Power Bar Widget"], "CENTER", 150, 30, config.powerBarWidget)
    UpdateWidget(_G.VehicleSeatIndicator, _G.HUD_EDIT_MODE_VEHICLE_SEAT_INDICATOR_LABEL, "CENTER", 128, 128, config.vehicleSeats)
    UpdateWidget(_G.DurabilityFrame, _G.HUD_EDIT_MODE_DURABILITY_FRAME_LABEL, "CENTER", 90, 75, config.durability)
    UpdateWidget(_G.BNToastFrame, _G.SHOW_BATTLENET_TOASTS, "CENTER", 250, 50, config.battlenetToast)

    _G.UIWidgetPowerBarContainerFrame._container:SetShown(config.powerBarWidget.enabled)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateWidgets)