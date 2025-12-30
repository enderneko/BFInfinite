-- shared pool since there are several modules that can display quests, but a given quest can only appear in a specific module
local g_questPOIButtonPool = CreateFramePool("BUTTON", nil, "BFI_ObjectiveTrackerPOIButtonTemplate");

BFI_ObjectiveTrackerQuestPOIBlockMixin = CreateFromMixins(BFI_ObjectiveTrackerAnimBlockMixin);

-- overrides inherited
function BFI_ObjectiveTrackerQuestPOIBlockMixin:OnLayout()
    local module = self.parentModule;
    if self.poiQuestID and (module.showWorldQuests or BFI_ObjectiveTrackerManager:CanShowPOIs(module)) then
        self:AddPOIButton();
    else
        self:CheckAndReleasePOIButton();
    end

    -- this could play anim on POI button so it has to run last
    ObjectiveTrackerAnimBlockMixin.OnLayout(self);
end

function BFI_ObjectiveTrackerQuestPOIBlockMixin:AddPOIButton(questID, isComplete, isSuperTracked, isWorldQuest)
    local style;
    if self.poiIsWorldQuest then
        style = POIButtonUtil.Style.WorldQuest;
    elseif self.poiIsComplete then
        style = POIButtonUtil.Style.QuestComplete;
    else
        style = POIButtonUtil.Style.QuestInProgress;
    end
    local poiButton = self:GetPOIButton(style);
    poiButton:SetPoint("TOPRIGHT", self.HeaderText, "TOPLEFT", -7, 5);
    poiButton:SetPingWorldMap(isWorldQuest);
end

function BFI_ObjectiveTrackerQuestPOIBlockMixin:GetPOIButton(style)
    local button = self.poiButton;
    if not button then
        button = g_questPOIButtonPool:Acquire();
        button:SetParent(self);
        button:SetQuestID(self.poiQuestID);
        self.poiButton = button;
        self:SetExtraAddAnimation(button.AddAnim);
    end

    button:SetStyle(style);
    button:SetSelected(self.poiIsSuperTracked);
    button:UpdateButtonStyle();
    button:Show();
    return button;
end

function BFI_ObjectiveTrackerQuestPOIBlockMixin:SetPOIInfo(questID, isComplete, isSuperTracked, isWorldQuest)
    self.poiQuestID = questID;
    self.poiIsComplete = isComplete;
    self.poiIsSuperTracked = isSuperTracked;
    self.poiIsWorldQuest = isWorldQuest;
end

-- overrides inherited
function BFI_ObjectiveTrackerQuestPOIBlockMixin:Free()
    ObjectiveTrackerAnimBlockMixin.Free(self);
    self:CheckAndReleasePOIButton();
end

function BFI_ObjectiveTrackerQuestPOIBlockMixin:CheckAndReleasePOIButton()
    if self.poiButton then
        g_questPOIButtonPool:Release(self.poiButton);
        self.poiButton = nil;
        self:SetExtraAddAnimation(nil);
        -- clear out the values with nils
        self:SetPOIInfo();
    end
end