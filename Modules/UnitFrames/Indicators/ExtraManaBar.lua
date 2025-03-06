---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

--! NOTE: only available for PLAYER
local class = BFI.vars.playerClass

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHasVehicleUI = UnitHasVehicleUI

---------------------------------------------------------------------
-- ShouldShowExtraMana
---------------------------------------------------------------------
local should_show_extra_mana = {
    DRUID = function()
        return UnitPowerType("player") == Enum.PowerType.Rage or UnitPowerType("player") == Enum.PowerType.LunarPower
    end,
    PRIEST = function()
        return UnitPowerType("player") == Enum.PowerType.Insanity
    end,
    SHAMAN = function()
        return UnitPowerType("player") == Enum.PowerType.Maelstrom
    end,
}

function UF.ShouldShowExtraMana()
    if should_show_extra_mana[class] then
        return not UnitHasVehicleUI("player") and should_show_extra_mana[class]()
    end
end

---------------------------------------------------------------------
-- GetClassColor
---------------------------------------------------------------------
local function GetClassColor(type)
    if type == "class_color" then
        return AF.GetClassColor(class)
    elseif type == "class_color_dark" then
        return AF.GetClassColor(class, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetExactManaColor
---------------------------------------------------------------------
local function GetExactManaColor(type)
    if type == "mana_color" then
        return AF.GetColorRGB("MANA")
    elseif type == "mana_color_dark" then
        return AF.GetColorRGB("MANA", nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetManaColor
---------------------------------------------------------------------
local function GetManaColor(self)
    if not (self.color and self.lossColor) then return end

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
    if unitId and unitId ~= "player" then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = GetManaColor(self, "player")
    self:SetColor(r, g, b, a)
    self:SetLossColor(lossR, lossG, lossB, lossA)
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateManaMax(self, event, unitId, powerType)
    if unitId and unitId ~= "player" then return end
    if powerType and powerType ~= "MANA" then return end

    self.manaMax = UnitPowerMax("player", 0)
    self:SetBarMinMaxValues(0, self.manaMax)
end

local function UpdateMana(self, event, unitId, powerType)
    if unitId and unitId ~= "player" then return end
    if powerType and powerType ~= "MANA" then return end

    self.mana = UnitPower("player", 0)
    self:SetBarValue(self.mana)

    if self.hideIfFull and self.mana / self.manaMax >= 0.99 then
        self:Hide()
    else
        self:Show()
    end
end

---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
local function Check(self, event, unitId)
    if unitId and unitId ~= "player" then return end

    if (self.hideIfHasClassPower and UF.ShouldShowClassPower())
        or not UF.ShouldShowExtraMana() then

        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:Hide()
        self._enabled = nil
        return
    end

    self._enabled = true

    -- register events
    self:RegisterEvent("UNIT_MAXPOWER", UpdateManaMax)
    if self.frequent then
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self:RegisterEvent("UNIT_POWER_FREQUENT", UpdateMana)
    else
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:RegisterEvent("UNIT_POWER_UPDATE", UpdateMana)
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
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    self:SetTexture(AF.LSM_GetBarTexture(config.texture))
    self:SetBackgroundColor(unpack(config.bgColor))
    self:SetBorderColor(unpack(config.borderColor))
    self:SetSmoothing(config.smoothing)

    self.color = config.color
    self.lossColor = config.lossColor
    self.frequent = config.frequent
    self.hideIfHasClassPower = config.hideIfHasClassPower
    self.hideIfFull = config.hideIfFull
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ExtraManaBar_EnableConfigMode(self)
    self.Enable = ExtraManaBar_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:Show()

    UnitPower = UF.CFG_UnitPower
    UnitPowerMax = UF.CFG_UnitPowerMax
    UnitHasVehicleUI = UF.CFG_UnitHasVehicleUI

    UpdateManaColor(self)
    UpdateManaMax(self)
    UpdateMana(self)
end

local function ExtraManaBar_DisableConfigMode(self)
    self.Enable = ExtraManaBar_Enable
    self.Update = ExtraManaBar_Update

    UnitPower = UF.UnitPower
    UnitPowerMax = UF.UnitPowerMax
    UnitHasVehicleUI = UF.UnitHasVehicleUI
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateExtraManaBar(parent, name)
    -- bar
    local bar = AF.CreateSimpleStatusBar(parent, name)
    bar.root = parent

    -- events
    AF.AddEventHandler(bar)

    -- functions
    bar.Update = ExtraManaBar_Update
    bar.Enable = ExtraManaBar_Enable
    bar.EnableConfigMode = ExtraManaBar_EnableConfigMode
    bar.DisableConfigMode = ExtraManaBar_DisableConfigMode
    bar.LoadConfig = ExtraManaBar_LoadConfig

    return bar
end