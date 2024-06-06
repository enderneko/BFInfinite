local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHasVehicleUI = UnitHasVehicleUI

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- GetClassColor
---------------------------------------------------------------------
local function GetClassColor(type, class)
    if type == "class_color" then
        return AW.GetClassColor(class)
    elseif type == "class_color_dark" then
        return AW.GetClassColor(class, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetExactManaColor
---------------------------------------------------------------------
local function GetExactManaColor(type)
    if type == "mana_color" then
        return AW.GetColorRGB("MANA")
    elseif type == "mana_color_dark" then
        return AW.GetColorRGB("MANA", nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetManaColor
---------------------------------------------------------------------
local function GetManaColor(self, unit)
    if not (self.color and self.lossColor) then return end

    local class = UnitClassBase(unit)

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = self.color.alpha
    lossA = self.lossColor.alpha

    -- bar
    if strfind(self.color.type, "^mana") then
        r, g, b = GetExactManaColor(self.color.type)
    elseif strfind(self.color.type, "^class") then
        r, g, b = GetClassColor(self.color.type, class)
    else
        r, g, b = unpack(self.color.rgb)
    end

    -- loss
    if strfind(self.lossColor.type, "^mana") then
        lossR, lossG, lossB = GetExactManaColor(self.lossColor.type)
    elseif strfind(self.lossColor.type, "^class") then
        lossR, lossG, lossB = GetClassColor(self.lossColor.type, class)
    else
        lossR, lossG, lossB = unpack(self.lossColor.rgb)
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateManaColor(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = GetManaColor(self, unit)
    self:SetColor(r, g, b, a)
    self:SetLossColor(lossR, lossG, lossB, lossA)
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateManaMax(self, event, unitId, powerType)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end
    if powerType and powerType ~= "MANA" then return end

    self.manaMax = UnitPowerMax(unit, 0)
    self:SetBarMinMaxValues(0, self.manaMax)
end

local function UpdateMana(self, event, unitId, powerType)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end
    if powerType and powerType ~= "MANA" then return end

    self.mana = UnitPower(unit, 0)
    self:SetBarValue(self.mana)
end

---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
local function Check(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    if UnitPowerType(unit) == 0 or UnitPowerMax(unit, 0) == 0 or UnitHasVehicleUI(unit) then
        -- mana is current or no mana
        self:Hide()
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self._enabled = nil
        return
    end

    self._enabled = true

    -- register events
    self:RegisterEvent("UNIT_MAXPOWER", UpdateManaMax)
    if self.frequent then
        self:RegisterEvent("UNIT_POWER_UPDATE", UpdateMana)
    else
        self:RegisterEvent("UNIT_POWER_FREQUENT", UpdateMana)
    end

    -- update now
    self:Show()
    UpdateManaColor(self)
    UpdateManaMax(self)
    UpdateMana(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function ExtraManaBar_Enable(self)
    if self.hideIfHasClassPower and U.GetUnitClassPowerType(self.root.unit) then
        self._disabled = true
        self:UnregisterAllEvents()
        self:Hide()
        return
    else
        self._disabled = nil
    end

    self:RegisterEvent("UNIT_DISPLAYPOWER", Check)
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", Check)
    self:RegisterEvent("UNIT_EXITED_VEHICLE", Check)

    Check(self)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function ExtraManaBar_Update(self)
    if self._enabled then
        UpdateManaColor(self)
        UpdateManaMax(self)
        UpdateMana(self)
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ExtraManaBar_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)

    self:SetTexture(U.GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))
    self:SetSmoothing(config.smoothing)

    self.color = config.color
    self.lossColor = config.lossColor
    self.frequent = config.frequent
    self.hideIfHasClassPower = config.hideIfHasClassPower
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateExtraManaBar(parent, name)
    -- bar
    local bar = AW.CreateSimpleBar(parent, name)
    bar.root = parent

    -- events
    BFI.AddEventHandler(bar)

    -- functions
    bar.Update = ExtraManaBar_Update
    bar.Enable = ExtraManaBar_Enable
    bar.LoadConfig = ExtraManaBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar)

    return bar
end