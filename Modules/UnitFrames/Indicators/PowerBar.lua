---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

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
    local inVehicle = UnitHasVehicleUI(unit)
    local isPlayer = AF.UnitIsPlayer(unit)

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2

    if isPlayer and not UnitIsConnected(unit) then
        r1, g1, b1 = AF.GetColorRGB("OFFLINE")
    else
        if colorTable.type:find("^power") then
            r1, g1, b1 = GetPowerTypeColor(colorTable.type, self.powerType, unit)
        elseif colorTable.type:find("^class") then
            if isPlayer then
                r1, g1, b1 = GetClassColor(colorTable.type, class, inVehicle)
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
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    -- color
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetPowerColor(self, unit, self.color)
    if orientation then
        self:SetGradientColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetColor(r1, g1, b1, a1)
    end

    -- lossColor
    orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetPowerColor(self, unit, self.lossColor)
    if orientation then
        self:SetGradientLossColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetLossColor(r1, g1, b1, a1)
    end
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePowerMax(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    self.powerMax = UnitPowerMax(unit)
    self:SetBarMinMaxValues(0, self.powerMax)
end

local function UpdatePower(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    self.power = UnitPower(unit)
    self:SetBarValue(self.power)
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
    if self.frequent then
        self:RegisterEvent("UNIT_POWER_FREQUENT", UpdatePower)
        self:UnregisterEvent("UNIT_POWER_UPDATE")
    else
        self:RegisterEvent("UNIT_POWER_UPDATE", UpdatePower)
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
    end
    self:RegisterEvent("UNIT_MAXPOWER", UpdatePowerMax)
    self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateAll)
    self:RegisterEvent("UNIT_FACTION", UpdatePowerColor)

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

    self:SetTexture(AF.LSM_GetBarTexture(config.texture))
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))
    self:SetSmoothing(config.smoothing)

    self.color = config.color
    self.lossColor = config.lossColor
    self.frequent = config.frequent
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function PowerBar_EnableConfigMode(self)
    self.Enable = PowerBar_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:SetShown(self.enabled)

    UnitPower = UF.CFG_UnitPower
    UnitPowerMax = UF.CFG_UnitPowerMax
    -- UnitHasVehicleUI = UF.CFG_UnitHasVehicleUI

    PowerBar_Update(self)
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
    local bar = AF.CreateSimpleStatusBar(parent, name)
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