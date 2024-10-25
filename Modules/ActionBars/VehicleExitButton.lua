---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local U = BFI.utils
local AB = BFI.ActionBars

local CanExitVehicle = CanExitVehicle

local vehicleExitButton

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateButton()
    vehicleExitButton = AW.CreateBorderedFrame(AW.UIParent, 20, 20)
    vehicleExitButton:Hide()
    AW.AddToPixelUpdater(vehicleExitButton, function()
        AW.DefaultUpdatePixels(vehicleExitButton)
        AW.SetOnePixelInside(vehicleExitButton.content, vehicleExitButton)
    end)

    vehicleExitButton.content = _G.MainMenuBarVehicleLeaveButton
    vehicleExitButton.content:SetParent(vehicleExitButton)

    vehicleExitButton.content:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
    vehicleExitButton.content:GetPushedTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)

    local highlight = vehicleExitButton.content:GetHighlightTexture()
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetColorTexture(AW.GetColorRGB("white", 0.25))

    U.DisableEditMode(vehicleExitButton.content)
    vehicleExitButton.content:SetScript("OnShow", nil)
    vehicleExitButton.content:SetScript("OnHide", nil)

    hooksecurefunc(vehicleExitButton.content, "Update", function()
        if CanExitVehicle() then
            vehicleExitButton:Show()
        else
            vehicleExitButton:Hide()
        end
    end)

    hooksecurefunc(vehicleExitButton.content, "SetPoint", function(_, _, anchorTo)
        if anchorTo ~= vehicleExitButton then
            vehicleExitButton.content:SetParent(vehicleExitButton)
            AW.SetOnePixelInside(vehicleExitButton.content, vehicleExitButton)
        end
    end)

    hooksecurefunc(vehicleExitButton.content, "SetHighlightTexture", function(self, texture)
        if texture ~= highlight then
            vehicleExitButton.content:SetHighlightTexture(highlight, "ADD")
        end
    end)

    hooksecurefunc(vehicleExitButton.content, "LockHighlight", function(self, texture)
        highlight:SetColorTexture(AW.GetColorRGB("yellow", 0.25))
        vehicleExitButton.content:SetHighlightTexture(highlight, "ADD")
    end)

    hooksecurefunc(vehicleExitButton.content, "UnlockHighlight", function(self, texture)
        highlight:SetColorTexture(AW.GetColorRGB("white", 0.25))
        vehicleExitButton.content:SetHighlightTexture(highlight, "ADD")
    end)

    AW.CreateMover(vehicleExitButton, L["Action Bars"], vehicleExitButton.content.systemNameString)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateButton(module, which)
    if module and module ~= "ActionBars" then return end
    if which and which ~= "vehicle" then return end

    local enabled = AB.config.general.enabled
    local config = AB.config.vehicleExitButton

    if not (enabled and config.enabled) then
        return
    end

    if not vehicleExitButton then
        CreateButton()
    end

    -- mover
    AW.UpdateMoverSave(vehicleExitButton, config.position)

    -- load config
    AW.LoadPosition(vehicleExitButton, config.position)
    AW.SetSize(vehicleExitButton, config.size, config.size)
    vehicleExitButton:SetFrameStrata(AB.config.general.frameStrata)
    vehicleExitButton:SetFrameLevel(AB.config.general.frameLevel)
end
BFI.RegisterCallback("UpdateModules", "AB_VehicleExit", UpdateButton)