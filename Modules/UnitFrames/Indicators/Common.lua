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
}

function UF.CreateIndicators(button, indicators)
    for _, name in pairs(indicators) do
        button.indicators[name] = builders[name](button, button:GetName().."_"..U.UpperFirst(name))
    end
end

function UF.LoadConfigForIndicators(button, indicators, config)
    -- TODO: whether "skip" is needed
    for _, name in pairs(indicators) do
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
                if indicator.container then
                    indicator.container:Hide()
                else
                    indicator:Hide()
                end
            end
            indicator.enabled = false
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