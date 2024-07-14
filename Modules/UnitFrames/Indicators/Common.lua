---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class UnitFrame
local UF = BFI.M_UF

local builders = {
    healthBar = UF.CreateHealthBar,
    powerBar = UF.CreatePowerBar,
    extraManaBar = UF.CreateExtraManaBar,
    classPowerBar = UF.CreateClassPowerBar,
    staggerBar = UF.CreateStaggerBar,
    nameText = UF.CreateNameText,
    healthText = UF.CreateHealthText,
    powerText = UF.CreatePowerText,
    levelText = UF.CreateLevelText,
    targetCounter = UF.CreateTargetCounter,
    portrait = UF.CreatePortrait,
    castBar = UF.CreateCastBar,
    combatIcon = UF.CreateCombatIcon,
    leaderIcon = UF.CreateLeaderIcon,
    leaderText = UF.CreateLeaderText,
    rangeText = UF.CreateRangeText,
    statusTimer = UF.CreateStatusTimer,
    statusIcon = UF.CreateStatusIcon,
    raidIcon = UF.CreateRaidIcon,
    roleIcon = UF.CreateRoleIcon,
    factionIcon = UF.CreateFactionIcon,
    restingIndicator = UF.CreateRestingIndicator,
    targetHighlight = UF.CreateTargetHighlight,
    mouseoverHighlight = UF.CreateMouseoverHighlight,
    threatGlow = UF.CreateThreatGlow,
    auras = UF.CreateAuras,
}

function UF.CreateIndicators(button, indicators)
    for _, v in pairs(indicators) do
        if type(v) == "table" then
            local builder, name = v[1], v[2]
            button.indicators[name] = builders[builder](button, button:GetName().."_"..U.UpperFirst(name), select(3, unpack(v)))
            button.indicators[name].indicatorName = name
        else -- string:name
            button.indicators[v] = builders[v](button, button:GetName().."_"..U.UpperFirst(v))
            button.indicators[v].indicatorName = v
        end
    end
end

function UF.SetupIndicators(button, indicators, config)
    for _, v in pairs(indicators) do
        local name
        if type(v) == "table" then
            name = v[2]
        else
            name = v
        end
        UF.LoadIndicatorConfig(button, name, config.indicators[name])
    end
end

function UF.LoadIndicatorConfig(button, indicatorName, indicatorConfig)
    local indicator = button.indicators[indicatorName]
    indicator:LoadConfig(indicatorConfig)

    indicator.enabled = indicatorConfig.enabled

    if indicator.enabled then
        indicator:Enable()
        -- NOTE: let each indicator handle this
        -- if button:IsVisible() then
        --     indicator:Update()
        -- end
    else
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
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

function UF.UpdateIndicators(button, force)
    for _, indicator in pairs(button.indicators) do
        if indicator.enabled then
            indicator:Update(force)
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

function UF.LoadTextPosition(self, config)
    if config.anchorTo == "button" then
        anchorTo = self.root
    else
        anchorTo = self.root.indicators[config.anchorTo]
    end
    AW.LoadTextPosition(self, config.position, anchorTo)
end