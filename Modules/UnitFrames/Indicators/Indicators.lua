local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local builders = {
    healthBar = UF.CreateStatusBar,
    powerBar = UF.CreateStatusBar,
    nameText = UF.CreateNameText,
    healthText = UF.CreateHealthText,
    portrait = UF.CreatePortrait,
}

function UF.CreateIndicators(button, indicators)
    for name in pairs(indicators) do
        button.indicators[name] = builders[name](button)
    end
end

function UF.LoadConfigForIndicators(button, indicators, config)
    for name, skip in pairs(indicators) do
        button.indicators[name]:LoadConfig(config.indicators[name], skip)
    end
end