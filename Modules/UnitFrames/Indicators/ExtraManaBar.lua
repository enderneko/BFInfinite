---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

--! NOTE: only available for PLAYER
local class = AF.player.class

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
        local powerType = UnitPowerType("player")
        return powerType == Enum.PowerType.Rage or powerType == Enum.PowerType.Energy or powerType == Enum.PowerType.LunarPower
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
local function GetManaColor(self, colorTable)
    if not colorTable then return end

    local orientation, r1, g1, b1, a1, r2, g2, b2, a2

    if colorTable.type:find("^mana") then
        r1, g1, b1 = GetExactManaColor(colorTable.type)
    elseif colorTable.type:find("^class") then
        r1, g1, b1 = GetClassColor(colorTable.type, class)
    else
        if colorTable.gradient == "disabled" then
            r1, g1, b1 = AF.UnpackColor(colorTable.rgb)
        else
            r1, g1, b1 = AF.UnpackColor(colorTable.rgb[1])
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

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateManaColor(self, event, unitId)
    if unitId and unitId ~= "player" then return end

    -- fill
    local orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetManaColor(self, self.fillColor)
    if orientation then
        self:SetGradientFillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetFillColor(r1, g1, b1, a1)
    end

    -- unfill
    orientation, r1, g1, b1, a1, r2, g2, b2, a2 = GetManaColor(self, self.unfillColor)
    if orientation then
        self:SetGradientUnfillColor(orientation, r1, g1, b1, a1, r2, g2, b2, a2)
    else
        self:SetUnfillColor(r1, g1, b1, a1)
    end
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdateManaMax(self, event, unitId, powerType)
    if unitId and unitId ~= "player" then return end
    if powerType and powerType ~= "MANA" then return end

    self.manaMax = UnitPowerMax("player", 0)
    self:SetMinMaxValues(0, self.manaMax)
end

local function UpdateMana(self, event, unitId, powerType)
    if unitId and unitId ~= "player" then return end
    if powerType and powerType ~= "MANA" then return end

    self.mana = UnitPower("player", 0)
    self:SetValue(self.mana)

    -- if self.hideIfFull and self.mana / self.manaMax >= 0.99 then
    --     self:Hide()
    -- else
    --     self:Show()
    -- end
end

---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
local function Check(self, event, unitId)
    if unitId and unitId ~= "player" then return end

    print(self.hideIfHasClassPower, UF.ShouldShowClassPower(), UF.ShouldShowExtraMana())

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
    self:RegisterUnitEvent("UNIT_MAXPOWER", "player", UpdateManaMax)
    if self.frequent then
        self:UnregisterEvent("UNIT_POWER_UPDATE")
        self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", UpdateMana)
    else
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", UpdateMana)
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
    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", Check)
    self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player", Check)
    self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player", Check)

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

    self:LSM_SetTexture(config.texture)
    self:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    self:SetBorderColor(AF.UnpackColor(config.borderColor))
    self:SetSmoothing(config.smoothing)

    self.fillColor = config.fillColor
    self.unfillColor = config.unfillColor
    self.frequent = config.frequent
    self.hideIfHasClassPower = config.hideIfHasClassPower
    -- self.hideIfFull = config.hideIfFull
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ExtraManaBar_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = ExtraManaBar_EnableConfigMode
    self.Update = AF.noop

    UnitPower = UF.CFG_UnitPower
    UnitPowerMax = UF.CFG_UnitPowerMax
    UnitHasVehicleUI = UF.CFG_UnitHasVehicleUI

    UpdateManaColor(self)
    UpdateManaMax(self)
    UpdateMana(self)

    self:SetShown(self.enabled)
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
    local bar = AF.CreateSecretPowerBar(parent, name)
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