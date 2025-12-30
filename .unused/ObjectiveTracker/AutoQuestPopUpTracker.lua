local questItems = { };

BFI_AutoQuestPopupTrackerMixin = { };

function BFI_AutoQuestPopupTrackerMixin:ShouldDisplayAutoQuest(questID)
    return not C_QuestLog.IsQuestBounty(questID) and self:ShouldDisplayQuest(QuestCache:Get(questID));
end

local function MakeBlockKey(questID, popUpType)
    return questID .. popUpType;
end

function BFI_AutoQuestPopupTrackerMixin:AddAutoQuestObjectives()
    if SplashFrame:IsShown() then
        return;
    end

    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i);
        if self:ShouldDisplayAutoQuest(questID) then
            local questTitle = C_QuestLog.GetTitleForQuestID(questID);
            if questTitle and questTitle ~= "" then
                local block = self:GetBlock(MakeBlockKey(questID, popUpType), "AutoQuestPopUpBlockTemplate");
                if self:LayoutBlock(block) then
                    block:Update(questTitle, questID, popUpType);
                else
                    return;
                end
            end
        end
    end
end

function BFI_AutoQuestPopupTrackerMixin:AddAutoQuestPopUp(questID, popUpType, itemID)
    if AddAutoQuestPopUp(questID, popUpType) then
        questItems[questID] = itemID;
        PlaySound(SOUNDKIT.UI_AUTO_QUEST_COMPLETE);
        self:ForceExpand();
    end
end

function BFI_AutoQuestPopupTrackerMixin:RemoveAutoQuestPopUp(questID)
    RemoveAutoQuestPopUp(questID);
    if GetNumAutoQuestPopUps() == 0 then
        wipe(questItems);
    end
    self:MarkDirty();
end

BFI_AutoQuestPopupBlockMixin = CreateFromMixins(BFI_ObjectiveTrackerBlockMixin);

-- ObjectiveTrackerBlockMixin override
function BFI_AutoQuestPopupBlockMixin:Init()
    self.usedLines = { };   -- unused, needed throughout ObjectiveTrackerBlockMixin
    self.fixedWidth = true;
    self.fixedHeight = true;
    self.height = 68;
    self.offsetX = -20;

    self.Contents.IconShine.Flash:SetScript("OnFinished", GenerateClosure(self.OnAnimFinished, self));
end

function BFI_AutoQuestPopupBlockMixin:OnMouseUp(button, upInside)
    if button == "LeftButton" and upInside then
        local questID = self.questID;
        if self.popUpType == "OFFER" then
            ShowQuestOffer(questID);
        else
            ShowQuestComplete(questID);
        end
        self.parentModule:RemoveAutoQuestPopUp(questID);
    end
end

function BFI_AutoQuestPopupBlockMixin:Update(questTitle, questID, popUpType)
    if self.questID ~= questID then
        self.questID = questID;
        self.popUpType = popUpType;
        self:UpdateIcon(questID, popUpType);
        local contents = self.Contents;

        if popUpType == "COMPLETE" then
            if C_QuestLog.IsQuestTask(questID) then
                contents.TopText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE_TASK);
            else
                contents.TopText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE);
            end

            contents.BottomText:Hide();
            contents.TopText:SetPoint("TOP", 0, -15);
            if contents.QuestName:GetStringWidth() > contents.QuestName:GetWidth() then
                contents.QuestName:SetPoint("TOP", 0, -25);
            else
                contents.QuestName:SetPoint("TOP", 0, -29);
            end
        elseif popUpType == "OFFER" then
            contents.TopText:SetText(QUEST_WATCH_POPUP_QUEST_DISCOVERED);
            contents.BottomText:Show();
            contents.BottomText:SetText(QUEST_WATCH_POPUP_CLICK_TO_VIEW);
            contents.TopText:SetPoint("TOP", 0, -9);
            contents.QuestName:SetPoint("TOP", 0, -20);
            contents.FlashFrame:Hide();
        end
        contents.QuestName:SetText(questTitle);
        self:SlideIn();
    end
end

function BFI_AutoQuestPopupBlockMixin:UpdateIcon(questID, popUpType)
    local contents = self.Contents;
    local isCampaign = C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Campaign;
    contents.QuestIconBadgeBorder:SetShown(not isCampaign);

    local isComplete = popUpType == "COMPLETE";
    contents.QuestionMark:SetShown(not isCampaign and isComplete);
    contents.Exclamation:SetShown(not isCampaign and not isComplete);

    if not isComplete then
        self:UpdateExclamationIcon(questItems[questID], popUpType, self);
    end

    if isCampaign then
        contents.QuestIconBg:SetTexCoord(0, 1, 0, 1);
        contents.QuestIconBg:SetAtlas("AutoQuest-Badge-Campaign", TextureKitConstants.UseAtlasSize);
    else
        contents.QuestIconBg:SetSize(60, 60);
        contents.QuestIconBg:SetTexture("Interface/QuestFrame/AutoQuest-Parts");
        contents.QuestIconBg:SetTexCoord(0.30273438, 0.41992188, 0.01562500, 0.95312500);
    end
end

function BFI_AutoQuestPopupBlockMixin:UpdateExclamationIcon(itemID, popUpType)
    local icon = self.Contents.Exclamation;
    local texture = itemID and select(10, C_Item.GetItemInfo(itemID));
    if texture then
        icon:SetTexCoord(0.078125, 0.921875, 0.078125, 0.921875);
        icon:SetSize(35, 35);
        icon:SetTexture(texture);
    else
        icon:SetTexture("Interface\\QuestFrame\\AutoQuest-Parts");
        icon:SetTexCoord(0.13476563, 0.17187500, 0.01562500, 0.53125000);
        icon:SetSize(19, 33);
    end
end

function BFI_AutoQuestPopupBlockMixin:SlideIn()
    local slideInfo = {
        travel = 68,
        adjustModule = true,
        duration = 0.4,
    };
    self:Slide(slideInfo);
end

function BFI_AutoQuestPopupBlockMixin:OnEndSlide(slideOut, finished)
    local contents = self.Contents;
    contents.Shine.Flash:Play();
    contents.IconShine.Flash:Play();
    -- this may have scrolled something partially offscreen
    self.parentModule:MarkDirty();
end

-- ObjectiveTrackerBlockMixin override
function BFI_AutoQuestPopupBlockMixin:AdjustSlideAnchor(offsetY)
    self.Contents:SetPoint("TOPLEFT", 0, offsetY);
end

function BFI_AutoQuestPopupBlockMixin:OnAnimFinished()
    if self.popUpType == "COMPLETE" then
        self.Contents.FlashFrame:Show();
    end
end

BFI_AutoQuestPopupFlashFrameMixin = { };

function BFI_AutoQuestPopupFlashFrameMixin:OnLoad()
    self.IconFlash:SetVertexColor(1, 0, 0);
end

function BFI_AutoQuestPopupFlashFrameMixin:OnShow()
    UIFrameFlash(self, 0.75, 0.75, -1, nil);
end

function BFI_AutoQuestPopupFlashFrameMixin:OnHide()
    UIFrameFlashStop(self);
end