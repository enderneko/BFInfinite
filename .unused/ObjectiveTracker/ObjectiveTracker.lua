BFI_ObjectiveTrackerFrameMixin = { };

function BFI_ObjectiveTrackerFrameMixin:OnLoad()
    BFI_ObjectiveTrackerContainerMixin.OnLoad(self);

    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("QUEST_ACCEPTED");
end

function BFI_ObjectiveTrackerFrameMixin:OnEvent(event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        C_QuestLog.SortQuestWatches();
    elseif event == "ZONE_CHANGED" then
        local mapID = C_Map.GetBestMapForUnit("player");
        if mapID ~= self.lastSortMapID then
            C_QuestLog.SortQuestWatches();
            self.lastSortMapID = mapID;
        end
    elseif ( event == "QUEST_ACCEPTED" ) then
        local questID = ...;
        if not C_QuestLog.IsQuestBounty(questID) and not C_QuestLog.IsQuestTask(questID) then
            if GetCVarBool("autoQuestWatch") and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
                C_QuestLog.AddQuestWatch(questID);
            end
        end
    end
end

function BFI_ObjectiveTrackerFrameMixin:ShouldShowHeader()
    if C_GameRules.IsGameRuleActive(Enum.GameRule.ObjectiveTrackerDisabled) then
        return false;
    end

    if not self:HasAnyModules() then
        return false;
    end

    return true;
end

function BFI_ObjectiveTrackerFrameMixin:Update(dirtyUpdate)
    if not self:ShouldShowHeader() then
        self.Header:Hide();
        return false;
    end

    self.Header:Show();

    return BFI_ObjectiveTrackerContainerMixin.Update(self, dirtyUpdate);
end
