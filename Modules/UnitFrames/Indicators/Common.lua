local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local builders = {
    healthBar = UF.CreateHealthBar,
    powerBar = UF.CreatePowerBar,
    nameText = UF.CreateNameText,
    healthText = UF.CreateHealthText,
    portrait = UF.CreatePortrait,
    castBar = UF.CreateCastBar,
}

function UF.CreateIndicators(button, indicators)
    for name in pairs(indicators) do
        button.indicators[name] = builders[name](button, button:GetName().."_"..U.UpperFirst(name))
    end
end

function UF.LoadConfigForIndicators(button, indicators, config)
    -- TODO: whether "skip" is needed
    for name, skip in pairs(indicators) do
        local indicator = button.indicators[name]
        indicator:LoadConfig(config.indicators[name], skip)
        if config.indicators[name].enabled then
            indicator:Enable()
            indicator.enabled = true
        else
            if indicator.Disable then
                indicator:Disable()
            else
                UF.DisableIndicator(indicator)
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

function UF.DisableIndicator(self)
    self:UnregisterAllEvents()
    self:Hide()
end