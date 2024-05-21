local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local strfind = strfind
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsConnected = UnitIsConnected

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- GetClassColor
---------------------------------------------------------------------
local function GetClassColor(type, class, inVehicle)
    if type == "class_color" then
        if inVehicle then
            return AW.GetColorRGB("FRIENDLY")
        else
            return AW.GetClassColor(class)
        end
    elseif type == "class_color_dark" then
        if inVehicle then
            return AW.GetColorRGB("FRIENDLY", nil, 0.2)
        else
            return AW.GetClassColor(class, nil, 0.2)
        end
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
    local inVehicle = UnitHasVehicleUI(unit)

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
local function UpdatePowerColor(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    local r, g, b, a, lossR, lossG, lossB, lossA = GetPowerColor(self, unit)
    self:SetStatusBarColor(r, g, b, a)
    self.loss:SetVertexColor(lossR, lossG, lossB, lossA)
end

---------------------------------------------------------------------
-- value
---------------------------------------------------------------------
local function UpdatePowerMax(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    self.powerMax = UnitPowerMax(unit)
    self:SetBarMinMaxValues(0, self.powerMax)
end

local function UpdatePower(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    self.power = UnitPower(unit)
    self:SetBarValue(self.power)
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
    self:RegisterEvent("UNIT_DISPLAYPOWER", UpdatePowerColor)

    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function PowerBar_Update(self)
    UpdatePowerColor(self)
    UpdatePowerMax(self)
    UpdatePower(self)
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function PowerBar_SetColor(self, color)
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end

local function PowerBar_SetLossColor(self, color)
    self.loss:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function PowerBar_SetBackgroudColor(self, color)
    self.container:SetBackdropColor(unpack(color))
end

local function PowerBar_SetBorderColor(self, color)
    self.container:SetBackdropBorderColor(unpack(color))
end

-- local function PowerBar_SetOrientation(self, orientation)
--     self:SetOrientation(orientation)
--     self.loss:ClearAllPoints()
--     if orientation == "HORIZONTAL" then
--         self.loss:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT")
--         self.loss:SetPoint("BOTTOMRIGHT")
--     else
--         self.loss:SetPoint("TOPLEFT")
--         self.loss:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "TOPRIGHT")
--     end
-- end

local function PowerBar_SetTexture(self, texture)
    texture = U.GetBarTexture(texture)
    self:SetStatusBarTexture(texture)
    self:GetStatusBarTexture():SetDrawLayer("OVERLAY", 0)
    self.loss:SetTexture(texture)
    self.loss:SetDrawLayer("OVERLAY", 0)
end

local function PowerBar_SetSmoothing(self, smoothing)
    self:ResetSmoothedValue()
    if smoothing then
        self.SetBarValue = self.SetSmoothedValue
        self.SetBarMinMaxValues = self.SetMinMaxSmoothedValue
    else
        self.SetBarValue = self.SetValue
        self.SetBarMinMaxValues = self.SetMinMaxValues
    end
end

local function PowerBar_UpdatePixels(self)
    AW.RePoint(self)
    AW.ReSize(self.container)
    AW.RePoint(self.container)
    AW.ReBorder(self.container)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function PowerBar_LoadConfig(self, config, skipColorUpdate)
    self.container:SetFrameLevel(self.root:GetFrameLevel() + config.frameLevel)
    AW.LoadWidgetPosition(self.container, config.position)
    AW.SetSize(self.container, config.width, config.height)

    self:SetTexture(config.texture)
    self:SetBackgroundColor(config.bgColor)
    self:SetBorderColor(config.borderColor)
    self:SetSmoothing(config.smoothing)

    self.color = config.color
    self.lossColor = config.lossColor
    self.frequent = config.frequent
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePowerBar(parent, name)
    -- container
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    AW.SetDefaultBackdrop(container)

    -- bar
    local bar = CreateFrame("StatusBar", name, container)
    AW.SetOnePixelInside(bar, container)

    bar.root = parent
    bar.container = container

    Mixin(bar, SmoothStatusBarMixin) -- SetSmoothedValue
    bar:SetScript("OnHide", function()
        bar:ResetSmoothedValue()
    end)

    -- events
    BFI.SetEventHandler(bar)

    -- loss texture
    bar.loss = bar:CreateTexture(nil, "OVERLAY", nil, 0)

    -- functions
    bar.Update = PowerBar_Update
    bar.Enable = PowerBar_Enable
    bar.SetColor = PowerBar_SetColor
    bar.SetTexture = PowerBar_SetTexture
    bar.SetLossColor = PowerBar_SetLossColor
    bar.SetBorderColor = PowerBar_SetBorderColor
    bar.SetBackgroundColor = PowerBar_SetBackgroudColor
    bar.SetSmoothing = PowerBar_SetSmoothing
    bar.LoadConfig = PowerBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(bar, PowerBar_UpdatePixels)

    return bar
end