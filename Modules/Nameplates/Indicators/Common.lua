---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class NamePlate
local NP = BFI.M_NamePlates

local builders = {
    healthBar = NP.CreateHealthBar,
    castBar = NP.CreateCastBar,
    nameText = NP.CreateNameText,
    healthText = NP.CreateHealthText,
    levelText = NP.CreateLevelText,
    rareIndicator = NP.CreateRareIndicator,
    raidIcon = NP.CreateRaidIcon,
    classIcon = NP.CreateClassIcon,
    debuffs = NP.CreateDebuffs,
    buffs = NP.CreateBuffs,
    crowdControls = NP.CreateCrowdControls,
    questIndicator = NP.CreateQuestIndicator,
}

function NP.CreateIndicators(np)
    for name, builder in pairs(builders) do
        np.indicators[name] = builder(np, np:GetName()..U.UpperFirst(name))
        np.indicators[name].indicatorName = name
    end
end

function NP.SetupIndicators(np, config)
    for name in pairs(builders) do
        NP.LoadIndicatorConfig(np, name, config[name])
    end
end

function NP.LoadIndicatorConfig(np, indicatorName, indicatorConfig)
    local indicator = np.indicators[indicatorName]

    if indicatorConfig then
        indicator:LoadConfig(indicatorConfig)
    end

    indicator.enabled = indicatorConfig and indicatorConfig.enabled

    if indicator.enabled then
        indicator:Enable()
    else
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
        end
    end
end

function NP.DisableIndicators(np)
    for _, indicator in pairs(np.indicators) do
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
        end
    end
end

function NP.UpdateIndicators(np)
    for _, indicator in pairs(np.indicators) do
        if indicator.enabled then
            indicator:Update()
        end
    end
end

function NP.OnNameplateShow(np)
    for _, indicator in pairs(np.indicators) do
        if indicator.enabled then
            indicator:Enable()
        elseif indicator.siblings then
            indicator:UpdateSiblings()
        end
    end
end

function NP.OnNameplateHide(np)
    for _, indicator in pairs(np.indicators) do
        if indicator.enabled then
            indicator:UnregisterAllEvents()
        end
    end
end

function NP.LoadIndicatorPosition(self, position, anchorTo)
    if anchorTo == "nameplate" then
        anchorTo = self.root
        if self.sibling then
            self.sibling:RemoveSibling(self)
            self.sibling = nil
        end
    elseif anchorTo then
        anchorTo = self.root.indicators[anchorTo]
        if anchorTo.canHaveSibling then
            anchorTo:AddSibling(self)
            self.sibling = anchorTo
        end
    end

    if self:GetObjectType() == "FontString" then
        AW.LoadTextPosition(self, position, anchorTo)
    else
        AW.LoadWidgetPosition(self, position, anchorTo)
    end
end