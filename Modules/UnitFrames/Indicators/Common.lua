local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local builders = {
    healthBar = UF.CreateHealthBar,
    powerBar = UF.CreatePowerBar,
    nameText = UF.CreateNameText,
    healthText = UF.CreateHealthText,
    powerText = UF.CreatePowerText,
    portrait = UF.CreatePortrait,
    castBar = UF.CreateCastBar,
    auras = UF.CreateAuras,
}

function UF.CreateIndicators(button, indicators)
    for _, v in pairs(indicators) do
        if type(v) == "table" then
            local builder, name = v[1], v[2]
            button.indicators[name] = builders[builder](button, button:GetName().."_"..U.UpperFirst(name), select(3, unpack(v)))
        else -- string:name
            button.indicators[v] = builders[v](button, button:GetName().."_"..U.UpperFirst(v))
        end
    end
end

function UF.LoadConfigForIndicators(button, indicators, config)
    for _, v in pairs(indicators) do
        local name
        if type(v) == "table" then
            name = v[2]
        else
            name = v
        end

        local indicator = button.indicators[name]
        indicator:LoadConfig(config.indicators[name])
        if config.indicators[name].enabled then
            indicator:Enable()
            indicator.enabled = true
        else
            if indicator.Disable then
                indicator:Disable()
            else
                indicator:UnregisterAllEvents()
                indicator:Hide()
            end
            indicator.enabled = false
        end
    end
end

function UF.DisableIndicators(button)
    for _, indicator in pairs(button.indicators) do
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
        end
    end
end

function UF.UpdateIndicators(button)
    for _, indicator in pairs(button.indicators) do
        if indicator.enabled then
            indicator:Update()
        end
    end
end

function UF.OnButtonShow(button)
    for _, indicator in pairs(button.indicators) do
        if indicator.enabled then
            indicator:Enable()
        end
    end
end

function UF.OnButtonHide(button)
    for _, indicator in pairs(button.indicators) do
        if indicator.enabled then
            indicator:UnregisterAllEvents()
        end
    end
end