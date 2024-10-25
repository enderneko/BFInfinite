---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
-- local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsConnected = UnitIsConnected
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- GetClassColor
---------------------------------------------------------------------
local function GetClassColor(type, class, inVehicle)
    if type == "class_color" then
        -- if inVehicle then
        --     return AW.GetColorRGB("FRIENDLY")
        -- else
            return AW.GetClassColor(class)
        -- end
    elseif type == "class_color_dark" then
        -- if inVehicle then
        --     return AW.GetColorRGB("FRIENDLY", nil, 0.2)
        -- else
            return AW.GetClassColor(class, nil, 0.2)
        -- end
    end
end

---------------------------------------------------------------------
-- GetReactionColor
---------------------------------------------------------------------
local function GetReactionColor(type, unit)
    if type == "class_color" then
        return AW.GetReactionColor(unit)
    elseif type == "class_color_dark" then
        return AW.GetReactionColor(unit, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetPowerTypeColor
---------------------------------------------------------------------
local function GetPowerTypeColor(type, power, unit)
    if type == "power_color" then
        return AW.GetPowerColor(power, unit)
    elseif type == "power_color_dark" then
        return AW.GetPowerColor(power, unit, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetPowerColor
---------------------------------------------------------------------
local function GetPowerColor(self, unit)
    if not (self.color and self.lossColor) then return end

    self.powerType = select(2, UnitPowerType(unit))

    local class = UnitClassBase(unit)
    -- local inVehicle = UnitHasVehicleUI(unit)

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = self.color.alpha
    lossA = self.lossColor.alpha

    if U.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r, g, b = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        else
            -- bar
            if strfind(self.color.type, "^power") then
                r, g, b = GetPowerTypeColor(self.color.type, self.powerType, unit)
            elseif strfind(self.color.type, "^class") then
                r, g, b = GetClassColor(self.color.type, class, inVehicle)
            else
                r, g, b = unpack(self.color.rgb)
            end

            -- loss
            if strfind(self.lossColor.type, "^power") then
                lossR, lossG, lossB = GetPowerTypeColor(self.lossColor.type, self.powerType, unit)
            elseif strfind(self.lossColor.type, "^class") then
                lossR, lossG, lossB = GetClassColor(self.lossColor.type, class, inVehicle)
            else
                lossR, lossG, lossB = unpack(self.lossColor.rgb)
            end
        end
    else
        -- bar
        if strfind(self.color.type, "^power") then
            r, g, b = GetPowerTypeColor(self.color.type, self.powerType, unit)
        elseif strfind(self.color.type, "^class") then
            r, g, b = GetReactionColor(self.color.type, unit)
        else
            r, g, b = unpack(self.color.rgb)
        end

        -- loss
        if strfind(self.lossColor.type, "^power") then
            lossR, lossG, lossB = GetPowerTypeColor(self.lossColor.type, self.powerType, unit)
        elseif strfind(self.lossColor.type, "^class") then
            lossR, lossG, lossB = GetReactionColor(self.lossColor.type, unit)
        else
            lossR, lossG, lossB = unpack(self.lossColor.rgb)
        end
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdatePowerColor(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = GetPowerColor(self, unit)
    self:SetColor(r, g, b, a)
    self:SetLossColor(lossR, lossG, lossB, lossA)
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
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)

    self:SetTexture(U.GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))
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
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:Show()

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
    local bar = AW.CreateSimpleBar(parent, name)
    bar.root = parent
    bar:Hide()

    -- events
    BFI.AddEventHandler(bar)

    -- functions
    bar.Update = PowerBar_Update
    bar.Enable = PowerBar_Enable
    bar.EnableConfigMode = PowerBar_EnableConfigMode
    bar.DisableConfigMode = PowerBar_DisableConfigMode
    bar.LoadConfig = PowerBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar)

    return bar
end