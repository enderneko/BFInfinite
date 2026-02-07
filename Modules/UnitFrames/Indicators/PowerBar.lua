---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
-- local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsConnected = UnitIsConnected
local UnitClassBase = AF.UnitClassBase

---------------------------------------------------------------------
-- GetClassColor
---------------------------------------------------------------------
local function GetClassColor(type, class, inVehicle)
    if type == "class_color" then
        -- if inVehicle then
        --     return AF.GetColorRGB("FRIENDLY")
        -- else
            return AF.GetClassColor(class)
        -- end
    elseif type == "class_color_dark" then
        -- if inVehicle then
        --     return AF.GetColorRGB("FRIENDLY", nil, 0.2)
        -- else
            return AF.GetClassColor(class, nil, 0.2)
        -- end
    end
end

---------------------------------------------------------------------
-- GetReactionColor
---------------------------------------------------------------------
local function GetReactionColor(type, unit)
    if type == "class_color" then
        return AF.GetReactionColor(unit)
    elseif type == "class_color_dark" then
        return AF.GetReactionColor(unit, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetPowerTypeColor
---------------------------------------------------------------------
local function GetPowerTypeColor(type, power, unit)
    if type == "power_color" then
        return AF.GetPowerColor(power, unit)
    elseif type == "power_color_dark" then
        return AF.GetPowerColor(power, unit, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function GetPowerColor(self, unit, colorTable)
    if not colorTable then return end

    self.powerType = select(2, UnitPowerType(unit))

    local class = UnitClassBase(unit)
    -- local inVehicle = UnitHasVehicleUI(unit)
    local isPlayer = AF.UnitIsPlayer(unit)

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2

    if isPlayer and not UnitIsConnected(unit) then
        r1, g1, b1 = AF.GetColorRGB("OFFLINE")
    else
        if colorTable.type:find("^power") then
            r1, g1, b1 = GetPowerTypeColor(colorTable.type, self.powerType, unit)
        elseif colorTable.type:find("^class") then
            if isPlayer then
                r1, g1, b1 = GetClassColor(colorTable.type, class)
            else
                r1, g1, b1 = GetReactionColor(colorTable.type, unit)
            end
        else
            if colorTable.gradient == "disabled" then
                r1, g1, b1 = AF.UnpackColor(colorTable.rgb)
            else
                r1, g1, b1 = AF.UnpackColor(colorTable.rgb[1])
            end
        end
    end

    if colorTable.gradient == "disabled" then
        a1 = colorTable.alpha
        return nil, r1, g1, b1, a1
    else
        a1, a2 = colorTable.alpha[1], colorTable.alpha[2]
        if #colorTable.rgb == 4 then
            r2, g2, b2 = AF.UnpackColor(colorTable.rgb)
        else
            r2, g2, b2 = AF.UnpackColor(colorTable.rgb[2])
        end

        orientation = colorTable.gradient:find("^vertical") and "VERTICAL" or "HORIZONTAL"
        if colorTable.gradient:find("flipped$") then
            return orientation, r2, g2, b2, a2, r1, g1, b1, a1
        else
            return orientation, r1, g1, b1, a1, r2, g2, b2, a2
        end
    end
end

local function UpdatePowerColor(self, event, unitId)
    local unit = self.root.effectiveUnit
    if unitId and unit ~= unitId then return end

    -- fill
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetPowerColor(self, unit, self.fillColor)
    if orientation then
        self:SetGradientFillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetFillColor(r1, g1, b1, a1)
    end

    -- unfill
    orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetPowerColor(self, unit, self.unfillColor)
    if orientation then
        self:SetGradientUnfillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetUnfillColor(r1, g1, b1, a1)
    end
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePowerMax(self, event, unitId)
    local unit = self.root.effectiveUnit
    if unitId and unit ~= unitId then return end

    self.powerMax = UnitPowerMax(unit)
    self:SetMinMaxValues(0, self.powerMax)
end

local function UpdatePower(self, event, unitId)
    local unit = self.root.effectiveUnit
    if unitId and unit ~= unitId then return end

    self.power = UnitPower(unit)
    self:SetValue(self.power)
end

local function UpdateAll(self, event, unitId)
    UpdatePowerColor(self, event, unitId)
    UpdatePowerMax(self, event, unitId)
    UpdatePower(self, event, unitId)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function PowerBar_Enable(self)
    local effectiveUnit = self.root.effectiveUnit

    if self.frequent then
        self:RegisterUnitEvent("UNIT_POWER_FREQUENT", effectiveUnit, UpdatePower)
        self:UnregisterEvent("UNIT_POWER_UPDATE")
    else
        self:RegisterUnitEvent("UNIT_POWER_UPDATE", effectiveUnit, UpdatePower)
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
    end
    self:RegisterUnitEvent("UNIT_MAXPOWER", effectiveUnit, UpdatePowerMax)
    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", effectiveUnit, UpdateAll)
    self:RegisterUnitEvent("UNIT_FACTION", effectiveUnit, UpdatePowerColor)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function PowerBar_Update(self)
    UpdateAll(self)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function PowerBar_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    self:LSM_SetTexture(config.texture)
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))
    self:SetSmoothing(config.smoothing)

    self.fillColor = config.fillColor
    self.unfillColor = config.unfillColor
    self.frequent = config.frequent
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