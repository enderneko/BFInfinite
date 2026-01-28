---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@class DataBars
local DB = BFI.modules.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local IsXPUserDisabled = IsXPUserDisabled
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitLevel = UnitLevel
local GetMaxLevelForLatestExpansion = GetMaxLevelForLatestExpansion
local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local GetQuestLogRewardXP = GetQuestLogRewardXP
local IsQuestComplete = C_QuestLog.IsComplete
local ReadyForTurnIn = C_QuestLog.ReadyForTurnIn
local GetXPExhaustion = GetXPExhaustion
local BreakUpLargeNumbers = BreakUpLargeNumbers

local experienceBar
local UpdateXP, UpdateQuestXP

---------------------------------------------------------------------
-- text
---------------------------------------------------------------------
local formatter = {
    current = function()
        return BreakUpLargeNumbers(experienceBar.currentXP)
    end,
    total = function()
        return BreakUpLargeNumbers(experienceBar.maxXP)
    end,
    percent = function()
        return AF.RoundToDecimal(experienceBar.currentXP / experienceBar.maxXP * 100, 1) .. "%"
    end,
    remaining = function()
        return BreakUpLargeNumbers(experienceBar.maxXP - experienceBar.currentXP)
    end,
    completed = function()
        return BreakUpLargeNumbers(experienceBar.completedXP)
    end,
    incomplete = function()
        return BreakUpLargeNumbers(experienceBar.incompleteXP)
    end,
    level = function()
        return UnitLevel("player")
    end
}

local function FormatText(text)
    return string.gsub(text, "%[(%w+)%]", function(s)
        if formatter[s] then
            return formatter[s]()
        else
            return ""
        end
    end)
end

local function ShowText()
    experienceBar.textFrame:Show()
end

local function HideText()
    experienceBar.textFrame:Hide()
end

local function UpdateTextVisibility(alwaysShow)
    if alwaysShow == true then
        experienceBar.textFrame:Show()
        experienceBar:SetScript("OnEnter", nil)
        experienceBar:SetScript("OnLeave", nil)
    elseif alwaysShow == false then
        experienceBar.textFrame:Hide()
        experienceBar:SetScript("OnEnter", ShowText)
        experienceBar:SetScript("OnLeave", HideText)
    else
        experienceBar.textFrame:Hide()
        experienceBar:SetScript("OnEnter", nil)
        experienceBar:SetScript("OnLeave", nil)
    end
end

---------------------------------------------------------------------
-- UpdateBarAndText
---------------------------------------------------------------------
local function UpdateBarAndText(self)
    local width = self:GetBarWidth()

    local remainingXP = self.maxXP - self.currentXP

    -- completed
    if self.completeEnabled then
        -- print("completeTexture:", AF.Clamp(self.completedXP, 0.001, remainingXP))
        self.completeTexture:SetWidth(AF.Clamp(self.completedXP, 0.001, remainingXP) / self.maxXP * width)
        remainingXP = remainingXP - self.completedXP
    end

    -- incomplete
    if self.incompleteEnabled then
        -- print("incompleteTexture:", AF.Clamp(self.incompleteXP, 0.001, remainingXP))
        self.incompleteTexture:SetWidth(AF.Clamp(self.incompleteXP, 0.001, remainingXP) / self.maxXP * width)
        remainingXP = remainingXP - self.incompleteXP
    end

    -- rested
    if self.restedEnabled then
        -- print("restedTex:", AF.Clamp(self.restedXP, 0.001, remainingXP))
        self.restedTex:SetWidth(AF.Clamp(self.restedXP, 0.001, remainingXP) / self.maxXP * width)
    end

    -- text
    if self.textEnabled then
        self.leftText:SetText(FormatText(self.leftFormat))
        self.centerText:SetText(FormatText(self.centerFormat))
        self.rightText:SetText(FormatText(self.rightFormat))
    end
end

---------------------------------------------------------------------
-- quest xp
---------------------------------------------------------------------
function UpdateQuestXP(self)
    self.completedXP, self.incompleteXP = 0, 0

    if AF.IsMaxLevel() then return end

    local questID, rewardXP
    for i = 1, GetNumQuestLogEntries() do
        questID = GetQuestIDForLogIndex(i)
        if questID then
            rewardXP = GetQuestLogRewardXP(questID)

            if rewardXP then
                if IsQuestComplete(questID) or ReadyForTurnIn(questID) then
                    self.completedXP = self.completedXP + rewardXP
                else
                    self.incompleteXP = self.incompleteXP + rewardXP
                end
            end
        end
    end

    UpdateBarAndText(self)
end

---------------------------------------------------------------------
-- update xp
---------------------------------------------------------------------
function UpdateXP(self)
    -- print(self.hideAtMaxLevel, AF.IsMaxLevel(), GetMaxLevelForLatestExpansion(), UnitLevel("player"), IsLevelAtEffectiveMaxLevel(UnitLevel("player")))
    -- level check
    if self.hideAtMaxLevel and AF.IsMaxLevel() then
        self:Hide()
        return
    end

    if IsXPUserDisabled() then
        self.disabledTexture:Show()
    else
        self.disabledTexture:Hide()
    end

    self.currentXP = UnitXP("player")
    self.maxXP = UnitXPMax("player")

    self:SetMinMaxValues(0, self.maxXP)
    self:SetBarValue(self.currentXP)

    local width = self:GetBarWidth()
    self.restedXP = GetXPExhaustion() or 0

    UpdateBarAndText(self)
end

local function UpdateAll(self)
    UpdateXP(self)
    UpdateQuestXP(self)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateExperienceBar()
    experienceBar = AF.CreateSimpleStatusBar(AF.UIParent, "BFI_ExperienceBar")
    experienceBar.loss:Hide()
    experienceBar:Hide()

    AF.CreateMover(experienceBar, "BFI: " .. L["Data Bars"], L["Experience Bar"])

    -- disabled
    local disabledTexture = experienceBar:CreateTexture(nil, "OVERLAY")
    experienceBar.disabledTexture = disabledTexture
    disabledTexture:SetAllPoints(experienceBar.bg)
    disabledTexture:SetTexture(AF.GetTexture("Stripe"), "REPEAT", "REPEAT")
    disabledTexture:SetHorizTile(true)
    disabledTexture:SetVertTile(true)
    disabledTexture:SetVertexColor(AF.GetColorRGB("disabled", 0.75))

    -- completed
    local completeTexture = experienceBar:CreateTexture(nil, "ARTWORK")
    experienceBar.completeTexture = completeTexture

    -- incomplete
    local incompleteTexture = experienceBar:CreateTexture(nil, "ARTWORK")
    experienceBar.incompleteTexture = incompleteTexture

    -- rested
    local restedTex = experienceBar:CreateTexture(nil, "ARTWORK")
    experienceBar.restedTex = restedTex

    -- text frame
    local textFrame = CreateFrame("Frame", nil, experienceBar)
    experienceBar.textFrame = textFrame
    textFrame:SetAllPoints()

    -- left text
    local leftText = textFrame:CreateFontString(nil, "OVERLAY")
    experienceBar.leftText = leftText

    -- center text
    local centerText = textFrame:CreateFontString(nil, "OVERLAY")
    experienceBar.centerText = centerText

    -- right text
    local rightText = textFrame:CreateFontString(nil, "OVERLAY")
    experienceBar.rightText = rightText

    -- events
    AF.AddEventHandler(experienceBar)

    -- script
    experienceBar:SetScript("OnShow", function()
        -- experienceBar:RegisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL", UpdateAll)
        experienceBar:RegisterEvent("UPDATE_EXPANSION_LEVEL", UpdateAll)
        experienceBar:RegisterEvent("MAX_EXPANSION_LEVEL_UPDATED", UpdateAll)
        experienceBar:RegisterEvent("PLAYER_XP_UPDATE", UpdateXP)
        experienceBar:RegisterEvent("PLAYER_LEVEL_UP", UpdateXP)
        experienceBar:RegisterEvent("UPDATE_EXHAUSTION", UpdateXP)
        experienceBar:RegisterEvent("ENABLE_XP_GAIN", UpdateXP)
        experienceBar:RegisterEvent("DISABLE_XP_GAIN", UpdateXP)
        experienceBar:RegisterEvent("QUEST_LOG_UPDATE", UpdateQuestXP)
        experienceBar:RegisterEvent("UNIT_QUEST_LOG_CHANGED", UpdateQuestXP)
    end)

    experienceBar:SetScript("OnHide", function()
        experienceBar:UnregisterAllEvents()
    end)

    -- init
    experienceBar.currentXP = 0
    experienceBar.maxXP = 1
    experienceBar.completedXP = 0
    experienceBar.incompleteXP = 0
    experienceBar.restedXP = 0
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateExperienceBar(_, module, which)
    if module and module ~= "dataBars" then return end
    if which and which ~= "experienceBar" then return end

    local config = DB.config.experienceBar
    if not config.enabled then
        if experienceBar then
            experienceBar.enabled = false
            experienceBar:Hide()
        end
        return
    end

    if not experienceBar then
        CreateExperienceBar()
    end
    experienceBar.enabled = true

    -- mover
    AF.UpdateMoverSave(experienceBar, config.position)

    AF.LoadPosition(experienceBar, config.position)
    AF.SetSize(experienceBar, config.width, config.height)

    experienceBar:SetBorderColor(AF.UnpackColor(config.borderColor))
    experienceBar:SetBackgroundColor(AF.UnpackColor(config.bgColor))

    local texture = AF.LSM_GetBarTexture(config.texture)

    -- main
    experienceBar:SetTexture(texture)
    if config.color.type == "gradient" then
        experienceBar:SetGradientColor(nil,
            config.color.startColor[1], config.color.startColor[2], config.color.startColor[3], config.color.startAlpha,
            config.color.endColor[1], config.color.endColor[2], config.color.endColor[3], config.color.endAlpha
        )
    else -- solid
        experienceBar:SetColor(config.color.endColor[1], config.color.endColor[2], config.color.endColor[3], config.color.endAlpha)
    end

    local anchorTo = experienceBar.fill.mask

    -- completed
    experienceBar.completeEnabled = config.completedQuests.enabled
    if config.completedQuests.enabled then
        experienceBar.completeTexture:SetTexture(texture)
        experienceBar.completeTexture:SetVertexColor(AF.UnpackColor(config.completedQuests.color))
        experienceBar.completeTexture:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT")
        experienceBar.completeTexture:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMRIGHT")
        experienceBar.completeTexture:Show()
        anchorTo = experienceBar.completeTexture
    else
        experienceBar.completeTexture:Hide()
    end

    -- incomplete
    experienceBar.incompleteEnabled = config.incompleteQuests.enabled
    if config.incompleteQuests.enabled then
        experienceBar.incompleteTexture:SetTexture(texture)
        experienceBar.incompleteTexture:SetVertexColor(AF.UnpackColor(config.incompleteQuests.color))
        experienceBar.incompleteTexture:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT")
        experienceBar.incompleteTexture:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMRIGHT")
        experienceBar.incompleteTexture:Show()
        anchorTo = experienceBar.incompleteTexture
    else
        experienceBar.incompleteTexture:Hide()
    end

    -- rested
    experienceBar.restedEnabled = config.rested.enabled
    if config.rested.enabled then
        experienceBar.restedTex:SetTexture(texture)
        experienceBar.restedTex:SetVertexColor(AF.UnpackColor(config.rested.color))
        experienceBar.restedTex:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT")
        experienceBar.restedTex:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMRIGHT")
        experienceBar.restedTex:Show()
    else
        experienceBar.restedTex:Hide()
    end

    -- text
    experienceBar.textEnabled = config.texts.enabled
    if config.texts.enabled then
        AF.SetFont(experienceBar.leftText, config.texts.font)
        AF.LoadTextPosition(experienceBar.leftText, {"LEFT", "LEFT", 5, config.texts.yOffset})
        experienceBar.leftFormat = config.texts.leftFormat

        AF.SetFont(experienceBar.centerText, config.texts.font)
        AF.LoadTextPosition(experienceBar.centerText, {"CENTER", "CENTER", 0, config.texts.yOffset})
        experienceBar.centerFormat = config.texts.centerFormat

        AF.SetFont(experienceBar.rightText, config.texts.font)
        AF.LoadTextPosition(experienceBar.rightText, {"RIGHT", "RIGHT", -5, config.texts.yOffset})
        experienceBar.rightFormat = config.texts.rightFormat

        UpdateTextVisibility(config.texts.alwaysShow)
    else
        UpdateTextVisibility()
    end

    experienceBar.hideAtMaxLevel = config.hideAtMaxLevel

    experienceBar:Show()
    UpdateAll(experienceBar)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateExperienceBar)