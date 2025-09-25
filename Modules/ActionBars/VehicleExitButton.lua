---@type BFI
local BFI = select(2, ...)
local L = BFI.L
local F = BFI.funcs
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local CanExitVehicle = CanExitVehicle

local vehicleExitHolder

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateButton()
    vehicleExitHolder = AF.CreateBorderedFrame(AF.UIParent, "BFI_VehicleExitHolder", 20, 20)
    vehicleExitHolder:Hide()
    AF.AddToPixelUpdater_Auto(vehicleExitHolder, function()
        AF.DefaultUpdatePixels(vehicleExitHolder)
        AF.SetOnePixelInside(vehicleExitHolder.button, vehicleExitHolder)
    end, true)

    vehicleExitHolder.button = _G.MainMenuBarVehicleLeaveButton
    vehicleExitHolder.button:SetParent(vehicleExitHolder)
    AF.SetOnePixelInside(vehicleExitHolder.button, vehicleExitHolder)

    vehicleExitHolder.button:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
    vehicleExitHolder.button:GetPushedTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)


    -- FIXME: Blizzard LockHighlight seems bugged in 11.0.5
    vehicleExitHolder.button:GetHighlightTexture():SetAlpha(0)
    local highlight = vehicleExitHolder.button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetColorTexture(AF.GetColorRGB("white", 0.25))

    F.DisableEditMode(vehicleExitHolder.button)
    vehicleExitHolder.button:SetScript("OnShow", nil)
    vehicleExitHolder.button:SetScript("OnHide", nil)

    hooksecurefunc(vehicleExitHolder.button, "Update", function()
        if CanExitVehicle() then
            vehicleExitHolder:Show()
        else
            vehicleExitHolder:Hide()
        end
    end)

    hooksecurefunc(vehicleExitHolder.button, "SetPoint", function(_, _, anchorTo)
        if anchorTo ~= vehicleExitHolder then
            vehicleExitHolder.button:SetParent(vehicleExitHolder)
            AF.SetOnePixelInside(vehicleExitHolder.button, vehicleExitHolder)
        end
    end)

    -- hooksecurefunc(vehicleExitHolder.button, "SetHighlightTexture", function(self, texture)
    --     if texture ~= highlight then
    --         vehicleExitHolder.button:SetHighlightTexture(highlight, "ADD")
    --     end
    -- end)

    hooksecurefunc(vehicleExitHolder.button, "LockHighlight", function()
        -- vehicleExitHolder.button:SetHighlightTexture(highlight, "ADD")
        highlight:SetDrawLayer("OVERLAY")
        highlight:SetColorTexture(AF.GetColorRGB("yellow", 0.25))
    end)

    hooksecurefunc(vehicleExitHolder.button, "UnlockHighlight", function()
        -- vehicleExitHolder.button:SetHighlightTexture(highlight, "ADD")
        highlight:SetDrawLayer("HIGHLIGHT")
        highlight:SetColorTexture(AF.GetColorRGB("white", 0.25))
    end)

    AF.CreateMover(vehicleExitHolder, "BFI: " .. L["Action Bars"], _G.HUD_EDIT_MODE_VEHICLE_LEAVE_BUTTON_LABEL)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateButton(_, module, which)
    if module and module ~= "actionBars" then return end
    if which and which ~= "vehicle" then return end

    local enabled = AB.config.general.enabled
    local config = AB.config.vehicleExitButton

    if not (enabled and config.enabled) then
        if vehicleExitHolder then
            vehicleExitHolder:Hide()
            vehicleExitHolder.enabled = false
        end
        return
    end

    if not vehicleExitHolder then
        CreateButton()
    end

    vehicleExitHolder.enabled = true

    -- mover
    AF.UpdateMoverSave(vehicleExitHolder, config.position)

    -- load config
    AF.LoadPosition(vehicleExitHolder, config.position)
    AF.SetSize(vehicleExitHolder, config.size, config.size)
    vehicleExitHolder:SetFrameStrata(AB.config.general.frameStrata)
    vehicleExitHolder:SetFrameLevel(AB.config.general.frameLevel)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateButton)