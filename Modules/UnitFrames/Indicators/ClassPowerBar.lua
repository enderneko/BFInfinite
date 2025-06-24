---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

--! NOTE: only available for PLAYER
local class = AF.player.class

local GetSpecialization = GetSpecialization
local UnitHasVehicleUI = UnitHasVehicleUI
local PlayerVehicleHasComboPoints = PlayerVehicleHasComboPoints
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitPowerDisplayMod = UnitPowerDisplayMod
local GetPowerRegenForPowerType = GetPowerRegenForPowerType
local GetRuneCooldown = GetRuneCooldown

local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE -- 1
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER -- 3
local SPEC_WARLOCK_DESTRUCTION = _G.SPEC_WARLOCK_DESTRUCTION -- 3
local SPEC_DK_BLOOD = 1
local SPEC_DK_FORST = 2
local SPEC_DK_UNHOLY = 3

local POWER_TYPE_ENERGY = Enum.PowerType.Energy -- 3
local POWER_TYPE_COMBO_POINTS = Enum.PowerType.ComboPoints -- 4
local POWER_TYPE_SOUL_SHARDS = Enum.PowerType.SoulShards -- 7
local POWER_TYPE_HOLY_POWER = Enum.PowerType.HolyPower -- 9
local POWER_TYPE_CHI = Enum.PowerType.Chi -- 12
local POWER_TYPE_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges -- 16
local POWER_TYPE_ESSENCE = Enum.PowerType.Essence -- 19
-- local POWER_TYPE_RUNE_BLOOD = Enum.PowerType.RuneBlood -- 20
-- local POWER_TYPE_RUNE_FROST = Enum.PowerType.RuneFrost -- 21
-- local POWER_TYPE_RUNE_UNHOLY = Enum.PowerType.RuneUnholy -- 22

---------------------------------------------------------------------
-- ShouldShowClassPower
---------------------------------------------------------------------
local should_show_class_power = {
    DEATHKNIGHT = function()
        return true
    end,
    DRUID = function()
        return UnitPowerType("player") == POWER_TYPE_ENERGY
    end,
    EVOKER = function()
        return true
    end,
    MAGE = function()
        return GetSpecialization() == SPEC_MAGE_ARCANE -- Arcane
    end,
    MONK = function()
        return GetSpecialization() == SPEC_MONK_WINDWALKER -- Windwalker
    end,
    PALADIN = function()
        return true
    end,
    ROGUE = function()
        return true
    end,
    WARLOCK = function()
        return true
    end,
}

local function ShouldShowVehicleComboPoints()
    return UnitHasVehicleUI("player") and PlayerVehicleHasComboPoints()
end

function UF.ShouldShowClassPower()
    if UnitHasVehicleUI("player") then
        return PlayerVehicleHasComboPoints()
    else
        if should_show_class_power[class] then
            return should_show_class_power[class]()
        end
    end
end

---------------------------------------------------------------------
-- GetClassPowerInfo
---------------------------------------------------------------------
local class_power_info = {
    -- class = {powerIndex, powerType, valueOfEachBar, powerRegen}
    DEATHKNIGHT = function()
        if GetSpecialization() == SPEC_DK_BLOOD then
            return nil, "RUNE_BLOOD"
        elseif GetSpecialization() == SPEC_DK_FORST then
            return nil, "RUNE_FORST"
        elseif GetSpecialization() == SPEC_DK_UNHOLY then
            return nil, "RUNE_UNHOLY"
        end
    end,
    DRUID = function()
        return POWER_TYPE_COMBO_POINTS, "COMBO_POINTS"
    end,
    EVOKER = function()
        return POWER_TYPE_ESSENCE, "ESSENCE", nil, GetPowerRegenForPowerType(POWER_TYPE_ESSENCE)
    end,
    MAGE = function()
        return POWER_TYPE_ARCANE_CHARGES, "ARCANE_CHARGES"
    end,
    MONK = function()
        return POWER_TYPE_CHI, "CHI"
    end,
    PALADIN = function()
        return POWER_TYPE_HOLY_POWER, "HOLY_POWER"
    end,
    ROGUE = function()
        return POWER_TYPE_COMBO_POINTS, "COMBO_POINTS"
    end,
    WARLOCK = function()
        if GetSpecialization() == SPEC_WARLOCK_DESTRUCTION then
            return POWER_TYPE_SOUL_SHARDS, "SOUL_SHARDS", UnitPowerDisplayMod(POWER_TYPE_SOUL_SHARDS)
        else
            return POWER_TYPE_SOUL_SHARDS, "SOUL_SHARDS"
        end
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
        return AF.GetClassColor(class)
    elseif type == "class_color_dark" then
        return AF.GetClassColor(class, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetPowerColor
---------------------------------------------------------------------
local function GetPowerColor(self, type)
    if type == "power_color" then
        return AF.GetPowerColor(self.powerType, "player")
    elseif type == "power_color_dark" then
        return AF.GetPowerColor(self.powerType, "player", nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetClassPowerColor
---------------------------------------------------------------------
local function GetClassPowerColor(self)
    if not (self.config.color and self.config.lossColor) then return end

    local r, g, b, a, lossR, lossG, lossB, lossA
    local r2, g2, b2, lossR2, lossG2, lossB2

    a = self.config.color.alpha
    lossA = self.config.lossColor.alpha

    -- bar
    if strfind(self.config.color.type, "^power") then
        r, g, b, _, r2, g2, b2 = GetPowerColor(self, self.config.color.type)
    elseif strfind(self.config.color.type, "^class") then
        r, g, b = GetClassColor(self.config.color.type, class)
    else
        r, g, b = unpack(self.config.color.rgb)
    end

    -- loss
    if strfind(self.config.lossColor.type, "^power") then
        lossR, lossG, lossB, _, lossR2, lossG2, lossB2 = GetPowerColor(self, self.config.lossColor.type)
    elseif strfind(self.config.lossColor.type, "^class") then
        lossR, lossG, lossB = GetClassColor(self.config.lossColor.type, class)
    else
        lossR, lossG, lossB = unpack(self.config.lossColor.rgb)
    end

    return r, g, b, a, lossR, lossG, lossB, lossA, r2, g2, b2, lossR2, lossG2, lossB2
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdatePowerColor(self, event, unitId)
    if unitId and unitId ~= self.unit then return end

    local r, g, b, a, lossR, lossG, lossB, lossA, r2, g2, b2, lossR2, lossG2, lossB2 = GetClassPowerColor(self)
    if r2 then
        -- gradient
        for i = 1, self.numPowerBars do
            self.bars[i]:SetGradientColor(r, g, b, a, r2, g2, b2, a)
            self.bars[i]:SetGradientLossColor(lossR, lossG, lossB, lossA, lossR2, lossG2, lossB2, lossA)
        end
    else
        -- solid
        for i = 1, self.numPowerBars do
            self.bars[i]:SetColor(r, g, b, a)
            self.bars[i]:SetLossColor(lossR, lossG, lossB, lossA)
        end
    end
end

---------------------------------------------------------------------
-- setup bars
---------------------------------------------------------------------
local function SetupBars(self)
    self.numPowerBars = self.powerMax

    local width = (AF.ConvertPixelsForRegion(self._width, self) - AF.ConvertPixelsForRegion(self.config.spacing, self) * (self.numPowerBars - 1)) / self.numPowerBars

    -- create
    for i = 1, self.numPowerBars do
        local bar = self.bars[i] or AF.CreateSimpleStatusBar(self)
        AF.RemoveFromPixelUpdater(bar)

        self.bars[i] = bar
        bar.parent = self
        bar.index = i

        bar:SetWidth(width)
        AF.SetHeight(bar, self.config.height)

        bar:SetTexture(AF.LSM_GetBarTexture(self.config.texture))
        bar:SetBackgroundColor(unpack(self.config.bgColor))
        bar:SetBorderColor(unpack(self.config.borderColor))

        bar:SetBarMinMaxValues(0, 1)

        if i == 1 then
            AF.SetPoint(bar, "TOPLEFT")
        else
            AF.SetPoint(bar, "TOPLEFT", self.bars[i-1], "TOPRIGHT", self.config.spacing, 0)
        end

        -- cooldown text
        bar.text = bar.text or bar:CreateFontString(nil, "OVERLAY")
        bar.text:SetShown(self.config.cooldownText.enabled)
        AF.LoadTextPosition(bar.text, self.config.cooldownText.position, bar)
        AF.SetFont(bar.text, unpack(self.config.cooldownText.font))
        bar.text:SetText("")

        bar:Desaturate(false)
        bar:Show()
    end

    -- hide unused
    for i = self.numPowerBars + 1, #self.bars do
        self.bars[i]:Hide()
    end

    -- color
    UpdatePowerColor(self)
end

---------------------------------------------------------------------
-- SetBarValues_Static
---------------------------------------------------------------------
local function SetBarValues_Static(self)
    local value = self.power
    for i = 1, self.numPowerBars do
        if value >= 1 then
            self.bars[i]:SetBarValue(1)
            self.bars[i]:Desaturate(false)
        elseif value >= 0 then
            self.bars[i]:SetBarValue(value)
            self.bars[i]:Desaturate(true)
        else
            self.bars[i]:SetBarValue(0)
            self.bars[i]:Desaturate(false)
        end
        value = value - 1
    end
end

---------------------------------------------------------------------
-- SetBarValues_Essence
---------------------------------------------------------------------
local function EssenceRegenOnUpdate(bar, elapsed)
    -- bar
    bar.regenValue = bar.regenValue + elapsed * bar.parent.powerRegen
    bar:SetBarValue(bar.regenValue)
    -- countdown
    bar.remaining = (1 - bar.regenValue) / bar.parent.powerRegen
    if bar.remaining > 1 then
        bar.text:SetFormattedText("%d", bar.remaining)
    elseif bar.remaining > 0 then
        bar.text:SetFormattedText("%.1f", bar.remaining)
    else
        bar.text:SetText("")
    end
end

local function SetBarValues_Essence(self)
    for i = 1, self.numPowerBars do
        if i == self.power + 1 then
            if self.lastRegenBar and self.lastRegenBar.regenValue then
                self.bars[i].regenValue = self.lastRegenBar.regenValue
            else
                self.bars[i].regenValue = 0
            end
            self.bars[i].text:SetText("")
            self.bars[i]:SetScript("OnUpdate", EssenceRegenOnUpdate)
            self.bars[i]:Desaturate(true)
        elseif i <= self.power then
            self.bars[i]:SetScript("OnUpdate", nil)
            self.bars[i]:SetBarValue(1)
            self.bars[i].regenValue = nil
            self.bars[i].text:SetText("")
            self.bars[i]:Desaturate(false)
        else
            self.bars[i]:SetScript("OnUpdate", nil)
            self.bars[i]:SetBarValue(0)
            self.bars[i].regenValue = nil
            self.bars[i].text:SetText("")
            self.bars[i]:Desaturate(false)
        end
    end
    self.lastRegenBar = self.bars[self.power + 1]
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePowerMax(self, event, unitId, powerType)
    -- if unitId and unitId ~= self.unit then return end
    if powerType and powerType ~= self.powerType then return end

    self.powerMax = UnitPowerMax(self.unit, self.powerIndex)
    SetupBars(self)
end

local function UpdatePower(self, event, unitId, powerType)
    -- if unitId and unitId ~= self.unit then return end
    if powerType and powerType ~= self.powerType then return end

    if self.powerMod then
        self.power = UnitPower(self.unit, self.powerIndex, true) / self.powerMod
    else
        self.power = UnitPower(self.unit, self.powerIndex)
    end

    self:UpdateBars()
end

---------------------------------------------------------------------
-- runes
---------------------------------------------------------------------
local function RuneSorter(a, b)
    return a.start < b.start
end

local function RuneOnUpdate(bar, elapsed)
    bar:SetBarValue(bar:GetValue() + elapsed)
    -- countdown
    if bar:GetRemainingValue() > 1 then
        bar.text:SetFormattedText("%d", bar:GetRemainingValue())
    elseif bar:GetRemainingValue() > 0 then
        bar.text:SetFormattedText("%.1f", bar:GetRemainingValue())
    else
        bar.text:SetText("")
    end
end

local function UpdateRune(self)
    -- update
    for i = 1, 6 do
        self.runes[i].start, self.runes[i].duration = GetRuneCooldown(i)
    end
    -- sort
    sort(self.runes, RuneSorter)
    -- set
    local bar
    for i = 1, 6 do
        if self.runes[i].start == 0 then
            self.bars[i]:SetScript("OnUpdate", nil)
            self.bars[i]:SetMinMaxValues(0, 1)
            self.bars[i]:SetBarValue(1)
            self.bars[i].text:SetText("")
            self.bars[i]:Desaturate(false)
        else
            self.bars[i]:SetMinMaxValues(0, self.runes[i].duration)
            self.bars[i]:SetBarValue(GetTime() - self.runes[i].start)
            self.bars[i].text:SetText("")
            self.bars[i]:SetScript("OnUpdate", RuneOnUpdate)
            self.bars[i]:Desaturate(true)
        end
    end
end

---------------------------------------------------------------------
-- check & setup
---------------------------------------------------------------------
local function Check(self, event, unitId)
    if unitId and (unitId ~= "player" and unitId ~= "vehicle") then return end

    if ShouldShowVehicleComboPoints() then
        self.unit = "vehicle"
        self.powerIndex = 4
        self.powerType = "COMBO_POINTS"
        self.powerMod = nil
    else
        self.unit = "player"
        self.powerIndex, self.powerType, self.powerMod = UF.GetClassPowerInfo()
    end

    if self.powerType and strfind(self.powerType, "^RUNE") then
        self.powerMax = 6
        if not self.runes then
            self.runes = {}
            for i = 1, 6 do
                self.runes[i] = {
                    start = 0,
                    duration = 0,
                }
            end
        end
    else
        self.powerMax = UnitPowerMax(self.unit, self.powerIndex)
    end

    if not UF.ShouldShowClassPower() or self.powerMax == 0 then
        self:Hide()
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:UnregisterEvent("RUNE_POWER_UPDATE")
        self._enabled = nil
        return
    end

    SetupBars(self)

    self._enabled = true
    self:Show()

    -- register events
    if strfind(self.powerType, "^RUNE") then
        self:UnregisterEvent("UNIT_MAXPOWER")
        self:UnregisterEvent("UNIT_POWER_FREQUENT")
        self:RegisterEvent("RUNE_POWER_UPDATE", UpdateRune)
        UpdateRune(self)
    else
        self:UnregisterEvent("RUNE_POWER_UPDATE")
        self:RegisterUnitEvent("UNIT_MAXPOWER", "player", UpdatePowerMax)
        self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", UpdatePower)
        UpdatePower(self)
    end
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
    self.powerIndex, self.powerType, self.powerMod, self.powerRegen = UF.GetClassPowerInfo()
    if self.powerIndex == POWER_TYPE_ESSENCE then
        self.UpdateBars = SetBarValues_Essence
    else
        self.UpdateBars = SetBarValues_Static
    end

    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", Check)
    self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player", Check)
    self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player", Check)
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
        if strfind(self.powerType, "^RUNE") then
            UpdateRune(self)
        else
            UpdatePowerMax(self)
            UpdatePower(self)
        end
        UpdatePowerColor(self)
    end
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function ClassPowerBar_UpdatePixels(self)
    if not self._enabled then return end

    C_Timer.After(1, function()
        local width = (AF.ConvertPixelsForRegion(self._width, self) - AF.ConvertPixelsForRegion(self.config.spacing, self) * (self.numPowerBars - 1)) / self.numPowerBars
        for _, bar in next, self.bars do
            bar:DefaultUpdatePixels()
            bar:SetWidth(width)
        end
    end)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ClassPowerBar_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    self.config = config

    if self._enabled then
        SetupBars(self)
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ClassPowerBar_EnableConfigMode(self)
    self.Enable = ClassPowerBar_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:Show()

    class = "PALADIN"
    self.power = 3
    self.powerType = "HOLY_POWER"
    self.powerMax = 5
    self.powerMod = 1

    SetupBars(self)
    self:UpdateBars()
end

local function ClassPowerBar_DisableConfigMode(self)
    self.Enable = ClassPowerBar_Enable
    self.Update = ClassPowerBar_Update

    class = AF.player.class
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
    AF.AddEventHandler(frame)

    -- functions
    frame.Update = ClassPowerBar_Update
    frame.Enable = ClassPowerBar_Enable
    frame.EnableConfigMode = ClassPowerBar_EnableConfigMode
    frame.DisableConfigMode = ClassPowerBar_DisableConfigMode
    frame.LoadConfig = ClassPowerBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(frame, ClassPowerBar_UpdatePixels)

    return frame
end