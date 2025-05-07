---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
---@class NamePlates
local NP = BFI.NamePlates

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
    targetIndicator = NP.CreateTargetIndicator,
}

function NP.CreateIndicators(np)
    for name, builder in pairs(builders) do
        np.indicators[name] = builder(np, np:GetName()..AF.UpperFirst(name))
        np.indicators[name].indicatorName = name
    end
end

local efficiencyModeIndicators = {
    healthBar = true,
    nameText = true,
    targetIndicator = true,
    castBar = true,
    healthText = false,
    rareIndicator = false,
    raidIcon = false,
    classIcon = false,
    debuffs = false,
    buffs = false,
    crowdControls = false,
    questIndicator = false,
}

function NP.SetupIndicators(np, config, mode)
    if mode == "efficiency" then
        for name, enabled in pairs(efficiencyModeIndicators) do
            NP.LoadIndicatorConfig(np, name, enabled and config[name])
        end
    else
        for name in pairs(builders) do
            NP.LoadIndicatorConfig(np, name, config[name])
        end
    end
end

function NP.LoadIndicatorConfig(np, indicatorName, indicatorConfig)
    local indicator = np.indicators[indicatorName]

    if indicatorConfig then
        indicator:LoadConfig(indicatorConfig)
        indicator.enabled = indicatorConfig.enabled
    else
        indicator.enabled = false
    end

    if indicator.enabled then
        if np:IsShown() then
            indicator:Enable()
        end
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

local function LoadPosition(self, position, anchorTo)
    if self:GetObjectType() == "FontString" then
        AF.LoadTextPosition(self, position, anchorTo)
    else
        AF.LoadWidgetPosition(self, position, anchorTo)
    end
end

function NP.LoadIndicatorPosition(self, position, anchorTo, parent)
    if anchorTo == "root" then
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

    if parent then
        if parent == "root" then
            parent = self.root
        else
            parent = self.root.indicators[parent]
        end
        self:SetParent(parent)
    end

    local success = pcall(LoadPosition, self, position, anchorTo)
    if not success then
        -- Cannot anchor to itself
        -- Cannot anchor to a region dependent on it
        AF.Fire("BFI_IncorrectAnchor", self)
    end
end