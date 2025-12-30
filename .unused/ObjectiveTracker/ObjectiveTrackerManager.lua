BFI_ObjectiveTrackerManager = {
    containers = { },
    moduleToContainerMap = { },
    backgroundAlpha = 0,
    canAddModules = true,
};

function BFI_ObjectiveTrackerManager:AssignModulesOrder(modules)
    for i, module in ipairs(modules) do
        module.uiOrder = i;
    end
end

function BFI_ObjectiveTrackerManager:AddContainer(container)
    self.containers[container] = true;
    -- pass current alpha to new container
    container:OnAdded(self.backgroundAlpha);
end

function BFI_ObjectiveTrackerManager:HasAnyModules()
    for container in pairs(self.containers) do
        if container:HasAnyModules() then
            return true;
        end
    end

    return false;
end

function BFI_ObjectiveTrackerManager:UpdateAll()
    for container in pairs(self.containers) do
        container:Update();
    end
end

function BFI_ObjectiveTrackerManager:UpdateModule(module)
    -- check that module is assigned
    local container = self:GetContainerForModule(module);
    if container then
        module:MarkDirty();
    end
end

function BFI_ObjectiveTrackerManager:GetContainerForModule(module)
    return self.moduleToContainerMap[module];
end

function BFI_ObjectiveTrackerManager:SetModuleContainer(module, container)
    if not self.containers[container] then
        return;
    end

    local oldContainer = self:GetContainerForModule(module);
    if oldContainer then
        oldContainer:RemoveModule(module);
    end
    self.moduleToContainerMap[module] = container;
    container:AddModule(module);
end

function BFI_ObjectiveTrackerManager:AcquireFrame(parent, template)
    if not self.poolCollection then
        self.poolCollection = CreateFramePoolCollection();
        self.templateTypes = { };
    end

    local templateType = self.templateTypes[template];
    if not templateType then
        local templateInfo = C_XMLUtil.GetTemplateInfo(template);
        templateType = templateInfo and templateInfo.type or "Frame";
        self.templateTypes[template] = templateType;
    end

    local pool = self.poolCollection:GetOrCreatePool(templateType, parent, template);
    local frame, isNew = pool:Acquire(template);
    if isNew then
        frame.template = template; -- stored so we can use it to free from the lookup later
    end
    return frame, isNew;
end

function BFI_ObjectiveTrackerManager:ReleaseFrame(frame)
    self.poolCollection:Release(frame);
end

function BFI_ObjectiveTrackerManager:SetOpacity(opacity)
    self.backgroundAlpha = (opacity or 0) / 100;
    for container in pairs(self.containers) do
        container:SetBackgroundAlpha(self.backgroundAlpha);
    end
end

local minLineFontSize = 12;
local maxLineFontSize = 20;
local headerExtraSize = 2;

function BFI_ObjectiveTrackerManager:SetTextSize(textSize)
    if textSize < minLineFontSize or textSize > maxLineFontSize then
        return;
    end

    local lineFont = "ObjectiveTrackerFont"..textSize;
    local headerFont = "ObjectiveTrackerFont"..(textSize + headerExtraSize);
    ObjectiveTrackerLineFont:SetFontObject(lineFont);
    ObjectiveTrackerHeaderFont:SetFontObject(headerFont);
    self:UpdateAll();
end

-- Rewards Toast
function BFI_ObjectiveTrackerManager:ShowRewardsToast(rewards, module, block, headerText, callback)
    if not rewards or #rewards == 0 then
        return;
    end

    if not self.rewardsToastPool then
        self.rewardsToastPool = CreateFramePool("FRAME", UIParent, "ObjectiveTrackerRewardsToastTemplate");
    end

    local rewardsToast = self.rewardsToastPool:Acquire();
    rewardsToast.block = block;
    rewardsToast:SetFrameLevel(1000 + self.rewardsToastPool:GetNumActive() * 10);
    rewardsToast:ShowRewards(rewards, module, block, headerText, callback);
end

function BFI_ObjectiveTrackerManager:HideRewardsToast(rewardsToast)
    self.rewardsToastPool:Release(rewardsToast);
end

function BFI_ObjectiveTrackerManager:HasRewardsToastForBlock(block)
    if not self.rewardsToastPool then
        return false;
    end

    for rewardsToast in self.rewardsToastPool:EnumerateActive() do
        if rewardsToast.block == block then
            return true;
        end
    end
    return false;
end

-- questPOI cvar

function BFI_ObjectiveTrackerManager:UpdatePOIEnabled(enabled)
    self.questPOIEnabled = enabled;
    for module in pairs(self.questPOIEnabledModules) do
        module:MarkDirty();
    end
end

function BFI_ObjectiveTrackerManager:OnVariablesLoaded()
    local enabled = GetCVarBool("questPOI");
    self:UpdatePOIEnabled(enabled);
end

function BFI_ObjectiveTrackerManager:OnCVarChanged(cvar, value)
    if cvar == "questPOI" then
        local enabled = value == "1";
        self:UpdatePOIEnabled(enabled);
    end
end

function BFI_ObjectiveTrackerManager:CanShowPOIs(module)
    if self.questPOIEnabled == nil then
        self.questPOIEnabled = GetCVarBool("questPOI");
        self.questPOIEnabledModules = { };
        EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
        CVarCallbackRegistry:RegisterCallback("questPOI", function(_, value) self:OnCVarChanged("questPOI", value); end, self);
    end

    if not self.questPOIEnabledModules[module] then
        self.questPOIEnabledModules[module] = true;
    end

    return self.questPOIEnabled;
end

function BFI_ObjectiveTrackerManager:EnumerateActiveBlocksByTag(tag, callback)
    local ContainerEnumerateActiveModuleBlocksByTag = function(module)
        if module:MatchesTag(tag) then
            module:EnumerateActiveBlocks(callback);
        end
    end

    for container in pairs(self.containers) do
        container:ForEachModule(ContainerEnumerateActiveModuleBlocksByTag);
    end
end

function BFI_ObjectiveTrackerManager:OnPlayerEnteringWorld(isInitialLogin, isReloadingUI)
    if not isInitialLogin and not isReloadingUI then
        return;
    end

    local mainTrackerFrame = BFI_ObjectiveTrackerFrame;
    self:AddContainer(mainTrackerFrame);

    if self.canAddModules then
        local orderedModules = {
            BFI_ScenarioObjectiveTracker,
            BFI_UIWidgetObjectiveTracker,
            BFI_CampaignQuestObjectiveTracker,
            BFI_QuestObjectiveTracker,
            BFI_AdventureObjectiveTracker,
            BFI_AchievementObjectiveTracker,
            BFI_MonthlyActivitiesObjectiveTracker,
            BFI_InitiativeTasksObjectiveTracker,
            BFI_ProfessionsRecipeTracker,
            BFI_BonusObjectiveTracker,
            BFI_WorldQuestObjectiveTracker,
        };

        self:AssignModulesOrder(orderedModules);
        for i, module in ipairs(orderedModules) do
            self:SetModuleContainer(module, mainTrackerFrame);
        end
    end

    self:UpdateAll();
end

function BFI_ObjectiveTrackerManager:RemoveAllModules()
    for container in pairs(self.containers) do
        container:RemoveAllModules();
    end

    self:UpdateAll();
end

function BFI_ObjectiveTrackerManager:SetCanAddModules(canAdd)
    self.canAddModules = canAdd;
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", BFI_ObjectiveTrackerManager.OnPlayerEnteringWorld, BFI_ObjectiveTrackerManager);
