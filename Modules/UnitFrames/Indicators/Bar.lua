local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- status bar
---------------------------------------------------------------------
local function Bar_SetBarColor(bar, color)
    bar:SetStatusBarColor(color[1], color[2], color[3], color[4])
end

local function Bar_SetLossColor(bar, color)
    bar.loss:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function Bar_SetBackgroudColor(bar, color)
    bar:SetBackdropColor(color[1], color[2], color[3], color[4])
end

local function Bar_SetBorderColor(bar, color)
    bar:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

local function Bar_SetOrientation(bar, orientation)
    bar:SetOrientation(orientation)
    bar.loss:ClearAllPoints()
    if orientation == "HORIZONTAL" then
        bar.loss:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT")
        bar.loss:SetPoint("BOTTOMRIGHT")
    else
        bar.loss:SetPoint("TOPLEFT")
        bar.loss:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "TOPRIGHT")
    end
end

local function Bar_SetTexture(bar, texture)
    texture = U.GetBarTexture(texture)
    bar:SetStatusBarTexture(texture)
    bar.loss:SetTexture(texture)
end

local function Bar_SetSmoothing(bar, smoothing)
    if smoothing then
        bar.SetBarValue = bar.SetSmoothedValue
        bar.SetBarMinMaxValues = bar.SetMinMaxSmoothedValue
    else
        bar:ResetSmoothedValue()
        bar.SetBarValue = bar.SetValue
        bar.SetBarMinMaxValues = bar.SetMinMaxValues
    end
end

local function Bar_LoadConfig(bar, config, skipColorUpdate)
    AW.LoadWidgetPosition(bar, config.position)
    AW.SetSize(bar, config.width, config.height)
    bar:SetBackgroundColor(config.bgColor)
    bar:SetBorderColor(config.borderColor)
    bar:SetSmoothing(config.smoothing)

    if skipColorUpdate then
        bar.color = config.color
        bar.lossColor = config.lossColor
    else
        bar:SetBarColor(config.color)
        bar:SetLossColor(config.lossColor)
    end
end

local function Bar_UpdatePixels(bar)
    AW.ReSize(bar)
    AW.RePoint(bar)
    AW.ReBorder(bar)
end

-- TODO: make bar clickable

function UF.CreateStatusBar(parent)
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    Mixin(bar, SmoothStatusBarMixin) -- SetSmoothedValue
    bar:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(bar)})

    -- bar texture
    bar:SetStatusBarTexture(AW.GetTexture("StatusBar"))
    bar:GetStatusBarTexture():SetDrawLayer("BORDER", -7)
    
    -- loss texture
    bar.loss = bar:CreateTexture(nil, "BORDER", nil, -7)
    bar.loss:SetTexture(AW.GetTexture("StatusBar"))
    Bar_SetOrientation(bar, "HORIZONTAL")
    
    -- color preset
    bar:SetBackdropBorderColor(AW.GetColorRGB("border"))
    bar:SetBackdropColor(AW.GetColorRGB("background"))

    -- functions
    bar.SetBarColor = Bar_SetBarColor
    bar.SetBarTexture = Bar_SetTexture
    bar.SetLossColor = Bar_SetLossColor
    bar.SetBorderColor = Bar_SetBorderColor
    bar.SetBackgroundColor = Bar_SetBackgroudColor
    bar.SetBarOrientation = Bar_SetOrientation
    bar.SetSmoothing = Bar_SetSmoothing
    bar.LoadConfig = Bar_LoadConfig
    
    -- pixel perfect
    bar.UpdatePixels = Bar_UpdatePixels
    AW.AddToPixelUpdater(bar)

    return bar
end

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local strfind = strfind
local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local UnitIsCharmed = UnitIsCharmed
local UnitPowerType = UnitPowerType

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
-- GetPowerColor
---------------------------------------------------------------------
local function GetPowerColor(type, power, unit)
    if type == "power_color" then
        return AW.GetPowerColor(power, unit)
    elseif type == "power_color_dark" then
        return AW.GetPowerColor(power, unit, nil, 0.2)
    end
end

---------------------------------------------------------------------
-- GetHealthColor
---------------------------------------------------------------------
function UF.GetHealthColor(button, unit)
    local bar = button.indicators.healthBar
    if not (bar.color and bar.lossColor) then return end

    button.states.class = UnitClassBase(unit)

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = bar.color.alpha
    lossA = bar.lossColor.alpha

    if U.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r, g, b = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        elseif UnitIsCharmed(unit) then
            r, g, b = 0.5, 0, 1
            lossR, lossG, lossB = barR*0.2, barG*0.2, barB*0.2
        else
            -- bar
            if bar.color.type == "custom_color" then
                r, g, b = unpack(bar.color.color)
            else
                r, g, b = GetClassColor(bar.color.type, button.states.class, button.states.inVehicle)
            end
            
            -- loss
            if bar.lossColor.type == "custom_color" then
                lossR, lossG, lossB = unpack(bar.color.color)
            else
                lossR, lossG, lossB = GetClassColor(bar.lossColor.type, button.states.class, button.states.inVehicle)
            end
        end
    else
        -- bar
        if bar.color.type == "custom_color" then
            r, g, b = unpack(bar.color.color)
        else
            r, g, b = GetReactionColor(bar.color.type, unit)
        end
        
        -- loss
        if bar.lossColor.type == "custom_color" then
            lossR, lossG, lossB = unpack(bar.lossColor.color)
        else
            lossR, lossG, lossB = GetReactionColor(bar.lossColor.type, unit)
        end
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end

---------------------------------------------------------------------
-- SetPowerColor
---------------------------------------------------------------------
function UF.GetPowerColor(button, unit)
    local bar = button.indicators.powerBar
    if not (bar.color and bar.lossColor) then return end

    button.states.powerType = select(2, UnitPowerType(unit))

    local r, g, b, a, lossR, lossG, lossB, lossA

    a = bar.color.alpha
    lossA = bar.lossColor.alpha

    if U.UnitIsPlayer(unit) then
        if not UnitIsConnected(unit) then
            r, g, b = 0.4, 0.4, 0.4
            lossR, lossG, lossB = 0.4, 0.4, 0.4
        else
            -- bar
            if strfind(bar.color.type, "^power") then
                r, g, b = GetPowerColor(bar.color.type, button.states.powerType, unit)
            elseif strfind(bar.color.type, "^class") then
                r, g, b = GetClassColor(bar.color.type, button.states.class, button.states.inVehicle)
            else
                r, g, b = unpack(bar.color.color)
            end

            -- loss
            if strfind(bar.lossColor.type, "^power") then
                lossR, lossG, lossB = GetPowerColor(bar.lossColor.type, button.states.powerType, unit)
            elseif strfind(bar.lossColor.type, "^class") then
                lossR, lossG, lossB = GetClassColor(bar.lossColor.type, button.states.class, button.states.inVehicle)
            else
                lossR, lossG, lossB = unpack(bar.lossColor.color)
            end
        end
    else
        -- bar
        if strfind(bar.color.type, "^power") then
            r, g, b = GetPowerColor(bar.color.type, button.states.powerType, unit)
        elseif strfind(bar.color.type, "^class") then
            r, g, b = GetReactionColor(bar.color.type, unit)
        else
            r, g, b = unpack(bar.color.color)
        end

        -- loss
        if strfind(bar.lossColor.type, "^power") then
            lossR, lossG, lossB = GetPowerColor(bar.lossColor.type, button.states.powerType, unit)
        elseif strfind(bar.lossColor.type, "^class") then
            lossR, lossG, lossB = GetReactionColor(bar.lossColor.type, unit)
        else
            lossR, lossG, lossB = unpack(bar.lossColor.color)
        end
    end

    return r, g, b, a, lossR, lossG, lossB, lossA
end