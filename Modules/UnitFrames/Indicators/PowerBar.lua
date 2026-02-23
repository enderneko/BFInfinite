---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function PowerBar_Update(self)
    self:UpdateAll()
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function PowerBar_Enable(self)
    self:SetUnit(self.root.effectiveUnit)
    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function HealthBar_Disable(self)
    self:ClearUnit()
    self:Hide()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function PowerBar_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    self:SetupFillColor(config.fillColor)
    self:SetupUnfillColor(config.unfillColor)

    self:LSM_SetTexture(config.texture)
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))
    self:SetSmoothing(config.smoothing)
    self:EnableFrequentUpdates(config.frequent)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function PowerBar_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = PowerBar_EnableConfigMode
    self.Update = AF.noop

    UnitPower = UF.CFG_UnitPower
    UnitPowerMax = UF.CFG_UnitPowerMax
    -- UnitHasVehicleUI = UF.CFG_UnitHasVehicleUI

    PowerBar_Update(self)

    self:SetShown(self.enabled)
end

local function PowerBar_DisableConfigMode(self)
    self.Enable = PowerBar_Enable
    self.Update = PowerBar_Update

    UnitPower = UF.UnitPower
    UnitPowerMax = UF.UnitPowerMax
    -- UnitHasVehicleUI = UF.UnitHasVehicleUI
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePowerBar(parent, name)
    -- bar
    local bar = AF.CreateSecretPowerBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    AF.AddEventHandler(bar)

    -- functions
    bar.Update = PowerBar_Update
    bar.Enable = PowerBar_Enable
    bar.EnableConfigMode = PowerBar_EnableConfigMode
    bar.DisableConfigMode = PowerBar_DisableConfigMode
    bar.LoadConfig = PowerBar_LoadConfig

    return bar
end