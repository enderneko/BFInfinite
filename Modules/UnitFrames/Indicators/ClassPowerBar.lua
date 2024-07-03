local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

--! NOTE: only available for PLAYER
local class = BFI.vars.playerClass

local GetSpecialization = GetSpecialization
local UnitHasVehicleUI = UnitHasVehicleUI
local PlayerVehicleHasComboPoints = PlayerVehicleHasComboPoints
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower

---------------------------------------------------------------------
-- ShouldShowClassPower
---------------------------------------------------------------------
local should_show_class_power = {
    ROGUE = function()
        return true
    end,
    DRUID = function()
        return UnitPowerType("player") == Enum.PowerType.Energy
    end,
    WARLOCK = function()
        return true
    end,
    PALADIN = function()
        return true
    end,
    MONK = function()
        return GetSpecialization() == 3 -- Windwalker
    end,
    MAGE = function()
        return GetSpecialization() == 1 -- Arcane
    end,
    EVOKER = function()
        return true
    end,
}

local function ShouldShowVehicleComboPoints()
    return UnitHasVehicleUI("player") and PlayerVehicleHasComboPoints()
end

function UF.ShouldShowClassPower()
    if should_show_class_power[class] then
        return should_show_class_power[class]()
    end
    return ShouldShowVehicleComboPoints()
end

---------------------------------------------------------------------
-- GetClassPowerInfo
---------------------------------------------------------------------
local class_power_info = {
    -- class = {powerIndex, powerType, valueOfEachBar}
    ROGUE = function()
        return 4, "COMBO_POINTS", 1
    end,
    DRUID = function()
        return 4, "COMBO_POINTS", 1
    end,
    WARLOCK = function()
        return 7, "SOUL_SHARDS", 10
    end,
    PALADIN = function()
        return 9, "HOLY_POWER", 1
    end,
    MONK = function()
        return 12, "CHI", 1
    end,
    MAGE = function()
        return 16, "ARCANE_CHARGES", 1
    end,
    EVOKER = function()
        return 19, "ESSENCE", 1
    end,
}

function UF.GetClassPowerInfo()
    if class_power_info[class] then
        return class_power_info[class]()
    end
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
-- GetPowerColor
---------------------------------------------------------------------
local function GetPowerColor(self, type)
    if type == "power_color" then
        return AW.GetColorRGB(self.powerType)
    elseif type == "power_color_dark" then
        return AW.GetColorRGB(self.powerType, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetClassPowerColor
---------------------------------------------------------------------
local function GetClassPowerColor(self)
    if not (self.config.color and self.config.lossColor) then return end

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = self.config.color.alpha
    lossA = self.config.lossColor.alpha

    -- bar
    if strfind(self.config.color.type, "^power") then
        r, g, b = GetPowerColor(self, self.config.color.type)
    elseif strfind(self.config.color.type, "^class") then
        r, g, b = GetClassColor(self.config.color.type, class)
    else
        r, g, b = unpack(self.config.color.rgb)
    end

    -- loss
    if strfind(self.config.lossColor.type, "^power") then
        lossR, lossG, lossB = GetPowerColor(self, self.config.lossColor.type)
    elseif strfind(self.config.lossColor.type, "^class") then
        lossR, lossG, lossB = GetClassColor(self.config.lossColor.type, class)
    else
        lossR, lossG, lossB = unpack(self.config.lossColor.rgb)
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdatePowerColor(self, event, unitId)
    if unitId and unitId ~= self.unit then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = GetClassPowerColor(self)
    for i = 1, self.numPowerBars do
        self.bars[i]:SetColor(r, g, b, a)
        self.bars[i]:SetLossColor(lossR, lossG, lossB, lossA)
    end
end

---------------------------------------------------------------------
-- setup bars
---------------------------------------------------------------------
local function SetupBars(self)
    self.numPowerBars = self.powerMax

    local width = (AW.ConvertPixelsForRegion(self._width, self) - AW.ConvertPixelsForRegion(self.config.spacing, self) * (self.numPowerBars - 1)) / self.numPowerBars

    -- create
    for i = 1, self.numPowerBars do
        local bar = self.bars[i] or AW.CreateSimpleBar(self)
        self.bars[i] = bar

        bar:SetWidth(width)
        AW.SetHeight(bar, self.config.height)

        bar:SetTexture(U.GetBarTexture(self.config.texture))
        bar:SetBackgroundColor(unpack(self.config.bgColor))
        bar:SetBorderColor(unpack(self.config.borderColor))

        bar:SetBarMinMaxValues(0, 1)

        if i == 1 then
            AW.SetPoint(bar, "TOPLEFT")
        else
            AW.SetPoint(bar, "TOPLEFT", self.bars[i-1], "TOPRIGHT", self.config.spacing, 0)
        end

        self.bars[i]:Show()
    end

    -- hide unused
    for i = self.numPowerBars + 1, #self.bars do
        self.bars[i]:Hide()
    end

    -- color
    UpdatePowerColor(self)
end

local function SetBarValues(self)
    local value = self.power / self.powerMod

    for i = 1, self.numPowerBars do
        if value >= 1 then
            self.bars[i]:SetBarValue(1)
        elseif value >= 0 then
            self.bars[i]:SetBarValue(value)
        else
            self.bars[i]:SetBarValue(0)
        end
        value = value - 1
    end
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePowerMax(self, event, unitId, powerType)
    if unitId and unitId ~= self.unit then return end
    if powerType and powerType ~= self.powerType then return end

    self.powerMax = UnitPowerMax(self.unit, self.powerIndex)
    SetupBars(self)
end

local function UpdatePower(self, event, unitId, powerType)
    if unitId and unitId ~= self.unit then return end
    if powerType and powerType ~= self.powerType then return end

    self.power = UnitPower(self.unit, self.powerIndex, true)
    SetBarValues(self)
end

---------------------------------------------------------------------
-- check & setup
---------------------------------------------------------------------
local function Check(self, event, unitId)
    if unitId and (unitId ~= "player" and unitId ~= "vehicle") then return end

    if not UF.ShouldShowClassPower() then
        self:Hide()
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self._enabled = nil
        return
    end

    if ShouldShowVehicleComboPoints() then
        self.unit = "vehicle"
        self.powerIndex = 4
        self.powerType = "COMBO_POINTS"
    else
        self.unit = "player"
        self.powerIndex, self.powerType = UF.GetClassPowerInfo()
    end

    self.powerMax = UnitPowerMax(self.unit, self.powerIndex)
    SetupBars(self)

    self._enabled = true

    -- register events
    self:RegisterEvent("UNIT_MAXPOWER", UpdatePowerMax)
    self:RegisterEvent("UNIT_POWER_UPDATE", UpdatePower)

    -- update now
    self:Show()
    UpdatePower(self)
end

local function DelayedCheck(self)
    if self.timer then self.timer:Cancel() end
    self.timer = C_Timer.NewTimer(0.5, function()
        Check(self)
    end)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function ClassPowerBar_Enable(self)
    self.unit = "player"
    self.powerIndex, self.powerType, self.powerMod = UF.GetClassPowerInfo()

    self:RegisterEvent("UNIT_DISPLAYPOWER", Check)
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", Check)
    self:RegisterEvent("UNIT_EXITED_VEHICLE", Check)
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", DelayedCheck)
    if class == "ROGUE" then
        -- 深邃诡计
        self:RegisterEvent("TRAIT_CONFIG_UPDATED", DelayedCheck)
    end

    Check(self)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function ClassPowerBar_Update(self)
    if self._enabled then
        UpdatePowerMax(self)
        UpdatePowerColor(self)
        UpdatePower(self)
    end
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function ClassPowerBar_UpdatePixels(self)
    if not self._enabled then return end

    C_Timer.After(1, function()
        local width = (AW.ConvertPixelsForRegion(self._width, self) - AW.ConvertPixelsForRegion(self.config.spacing, self) * (self.numPowerBars - 1)) / self.numPowerBars
        for _, bar in pairs(self.bars) do
            bar:UpdatePixels()
            bar:SetWidth(width)
        end
    end)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ClassPowerBar_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)

    self.config = config

    if self._enabled then
        SetupBars(self)
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateClassPowerBar(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- bars
    frame.bars = {}

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Update = ClassPowerBar_Update
    frame.Enable = ClassPowerBar_Enable
    frame.LoadConfig = ClassPowerBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, ClassPowerBar_UpdatePixels)

    return frame
end