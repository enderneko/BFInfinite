local settings = {
    headerText = TRACKER_HEADER_INITIATIVE_TASKS,
    events = { "INITIATIVE_TASKS_TRACKED_UPDATED", "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" },
    blockTemplate = "BFI_ObjectiveTrackerAnimBlockTemplate",
    lineTemplate = "BFI_ObjectiveTrackerAnimLineTemplate",
};

--! TODO:
--! this is a stripped down version of Monthly Activities Objective Tracker
--! still needs: open to initiative frame, fan fare, and initiatve complete turn in animation etc.

BFI_InitiativeTasksObjectiveTrackerMixin = CreateFromMixins(BFI_ObjectiveTrackerModuleMixin, settings);

function BFI_InitiativeTasksObjectiveTrackerMixin:OnEvent(event, ...)
    if event == "INITIATIVE_TASKS_TRACKED_UPDATED" or event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
        self:MarkDirty();
    end
end

function BFI_InitiativeTasksObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
    if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
        local initiativeTaskLink = C_NeighborhoodInitiative.GetInitiativeTaskChatLink(block.id);
        ChatFrameUtil.InsertLink(initiativeTaskLink);
    elseif mouseButton ~= "RightButton" then
        if IsModifiedClick("QUESTWATCHTOGGLE") then
            self:UntrackInitiativeTask(block.id);
        else
            HousingFramesUtil.OpenFrameToTaskID(block.id)
        end

        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    else
        MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
            rootDescription:SetTag("MENU_MONTHLY_ACTVITIES_TRACKER");

            rootDescription:CreateTitle(block.name);
            rootDescription:CreateButton(OBJECTIVES_VIEW_IN_QUESTLOG, function()
                HousingFramesUtil.OpenFrameToTaskID(block.id)
            end);
            rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
                self:UntrackInitiativeTask(block.id);
            end);
        end);
    end
end

function BFI_InitiativeTasksObjectiveTrackerMixin:UntrackInitiativeTask(taskID)
    C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(taskID);
end

function BFI_InitiativeTasksObjectiveTrackerMixin:LayoutContents()
    local trackedTasks = C_NeighborhoodInitiative.GetTrackedInitiativeTasks().trackedIDs;
    for i = 1, #trackedTasks do
        local taskID = trackedTasks[i];
        local taskInfo = C_NeighborhoodInitiative.GetInitiativeTaskInfo(taskID);
        if taskInfo and not taskInfo.completed then
            if not self:AddTask(taskInfo) then
                return;
            end
        end
    end
end

function BFI_InitiativeTasksObjectiveTrackerMixin:AddTask(taskInfo)
    local taskName = taskInfo.taskName;
    local requirements = taskInfo.requirementsList;

    local block = self:GetBlock(taskInfo.ID);
    block.name = taskName;
    block:SetHeader(taskName);
    -- criteria
    for index, requirement in ipairs(requirements) do
        if not requirement.completed then
            local criteriaString = requirement.requirementText;
            criteriaString = string.gsub(criteriaString, " / ", "/");
            block:AddObjective(index, criteriaString, nil, nil, BFI_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, BFI_OBJECTIVE_TRACKER_COLOR["Normal"]);
        end
    end
    
    return self:LayoutBlock(block);
end
