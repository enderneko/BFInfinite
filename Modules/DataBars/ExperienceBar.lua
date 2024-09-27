---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AW = BFI.AW
local U = BFI.utils
---@class DataBars
local DB = BFI.DataBars

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

---------------------------------------------------------------------
-- quest xp
---------------------------------------------------------------------
local function GetQuestXP()
    local completeXP, incompleteXP = 0, 0
    local questID, rewardXP
    for i = 1, GetNumQuestLogEntries() do
        questID = GetQuestIDForLogIndex(i)
        if questID then
            rewardXP = GetQuestLogRewardXP(questID)

            if rewardXP then
                if IsQuestComplete(questID) or ReadyForTurnIn(questID) then
                    completeXP = completeXP + rewardXP
                else
                    incompleteXP = incompleteXP + rewardXP
                end
            end
        end
    end
    return completeXP, incompleteXP
end

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
        return U.Round(experienceBar.currentXP / experienceBar.maxXP * 100, 1) .. "%"
    end,
    remaining = function()
        return BreakUpLargeNumbers(experienceBar.maxXP - experienceBar.currentXP)
    end,
    complete = function()
        return BreakUpLargeNumbers(experienceBar.completeXP)
    end,
    incomplete = function()
        return BreakUpLargeNumbers(experienceBar.incompleteXP)
    end,
    level = function()
        return experienceBar.playerLevel
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

local function UpdateTextVisibility(showOnHover)
    if showOnHover == true then
        experienceBar.textFrame:Hide()
        experienceBar:SetScript("OnEnter", ShowText)
        experienceBar:SetScript("OnLeave", HideText)
    elseif showOnHover == false then
        experienceBar.textFrame:Show()
        experienceBar:SetScript("OnEnter", nil)
        experienceBar:SetScript("OnLeave", nil)
    else
        experienceBar.textFrame:Hide()
        experienceBar:SetScript("OnEnter", nil)
        experienceBar:SetScript("OnLeave", nil)
    end
end

---------------------------------------------------------------------
-- update xp
---------------------------------------------------------------------
local function UpdateXP(self)
    local maxLevel = GetMaxLevelForLatestExpansion() --? GetMaxPlayerLevel()
    self.playerLevel = UnitLevel("player")

    if self.hideAtMaxLevel and self.playerLevel >= maxLevel then
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
    self.remainingXP = self.maxXP - self.currentXP

    self:SetMinMaxValues(0, self.maxXP)
    self:SetBarValue(self.currentXP)

    local width = self:GetBarWidth()
    self.completeXP, self.incompleteXP = GetQuestXP()
    self.restedXP = GetXPExhaustion() or 0

    -- complete
    if self.completeEnabled then
        -- print("completeTexture:", U.Clamp(self.completeXP, 0.001, self.remainingXP))
        self.completeTexture:SetWidth(U.Clamp(self.completeXP, 0.001, self.remainingXP) / self.maxXP * width)
        self.remainingXP = self.remainingXP - self.completeXP
    end

    -- incomplete
    if self.incompleteEnabled then
        -- print("incompleteTexture:", U.Clamp(self.incompleteXP, 0.001, self.remainingXP))
        self.incompleteTexture:SetWidth(U.Clamp(self.incompleteXP, 0.001, self.remainingXP) / self.maxXP * width)
        self.remainingXP = self.remainingXP - self.incompleteXP
    end

    -- rested
    if self.restedEnabled then
        -- print("restedTex:", U.Clamp(self.restedXP, 0.001, self.remainingXP))
        self.restedTex:SetWidth(U.Clamp(self.restedXP, 0.001, self.remainingXP) / self.maxXP * width)
    end

    -- text
    if self.textEnabled then
        self.leftText:SetText(FormatText(self.leftFormat))
        self.centerText:SetText(FormatText(self.centerFormat))
        self.rightText:SetText(FormatText(self.rightFormat))
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateExperienceBar()
    experienceBar = AW.CreateSimpleBar(AW.UIParent, "BFI_ExperienceBar")
    experienceBar.loss:Hide()
    experienceBar:Hide()
    AW.CreateMover(experienceBar, L["Data Bars"], L["Experience Bar"])
    AW.AddToPixelUpdater(experienceBar)

    -- disabled
    local disabledTexture = experienceBar:CreateTexture(nil, "OVERLAY")
    experienceBar.disabledTexture = disabledTexture
    disabledTexture:SetAllPoints(experienceBar.bg)
    disabledTexture:SetTexture(AW.GetTexture("Stripe"), "REPEAT", "REPEAT")
    disabledTexture:SetHorizTile(true)
    disabledTexture:SetVertTile(true)
    disabledTexture:SetVertexColor(AW.GetColorRGB("disabled", 0.75))

    -- complete
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
    AW.LoadTextPosition(leftText, {"LEFT", "LEFT", 5, 0})

    -- center text
    local centerText = textFrame:CreateFontString(nil, "OVERLAY")
    experienceBar.centerText = centerText
    AW.LoadTextPosition(centerText, {"CENTER", "CENTER", 0, 0})

    -- right text
    local rightText = textFrame:CreateFontString(nil, "OVERLAY")
    experienceBar.rightText = rightText
    AW.LoadTextPosition(rightText, {"RIGHT", "RIGHT", -5, 0})

    -- events
    BFI.AddEventHandler(experienceBar)

    -- script
    experienceBar:SetScript("OnShow", function()
        -- QUEST_LOG_UPDATE
        -- UNIT_QUEST_LOG_CHANGED
        -- PLAYER_XP_UPDATE
        -- PLAYER_LEVEL_UP
        -- UPDATE_EXHAUSTION
        -- UPDATE_EXPANSION_LEVEL
        -- MAX_EXPANSION_LEVEL_UPDATED
        -- TIME_PLAYED_MSG
        -- ENABLE_XP_GAIN
        -- DISABLE_XP_GAIN

        experienceBar:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateXP)
        experienceBar:RegisterEvent("UPDATE_EXPANSION_LEVEL", UpdateXP)
        experienceBar:RegisterEvent("MAX_EXPANSION_LEVEL_UPDATED", UpdateXP)
    end)

    experienceBar:SetScript("OnHide", function()
        experienceBar:UnregisterAllEvents()
    end)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateXPerienceBar(module, which)
    if module and module ~= "DataBars" then return end
    if which and which ~= "experience" then return end

    local config = DB.config.experienceBar
    if not config.enabled then
        if experienceBar then
            experienceBar:Hide()
        end
        return
    end

    if not experienceBar then
        CreateExperienceBar()
    end

    AW.LoadPosition(experienceBar, config.position)
    AW.SetSize(experienceBar, config.width, config.height)

    experienceBar:SetBorderColor(AW.UnpackColor(config.borderColor))
    experienceBar:SetBackgroundColor(AW.UnpackColor(config.bgColor))

    local texture = U.GetBarTexture(config.texture)

    -- main
    experienceBar:SetTexture(texture)
    if config.normalColor.useGradient then
        experienceBar:SetGradientColor(config.normalColor.startColor, config.normalColor.endColor)
    else
        experienceBar:SetColor(AW.UnpackColor(config.normalColor.startColor))
    end

    local anchorTo = experienceBar.fg

    -- complete
    experienceBar.completeEnabled = config.completeQuests.enabled
    if config.completeQuests.enabled then
        experienceBar.completeTexture:SetTexture(texture)
        experienceBar.completeTexture:SetVertexColor(AW.UnpackColor(config.completeQuests.color))
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
        experienceBar.incompleteTexture:SetVertexColor(AW.UnpackColor(config.incompleteQuests.color))
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
        experienceBar.restedTex:SetVertexColor(AW.UnpackColor(config.rested.color))
        experienceBar.restedTex:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT")
        experienceBar.restedTex:SetPoint("BOTTOMLEFT", anchorTo, "BOTTOMRIGHT")
        experienceBar.restedTex:Show()
    else
        experienceBar.restedTex:Hide()
    end

    -- text
    experienceBar.textEnabled = config.texts.enabled
    if config.texts.enabled then
        U.SetFont(experienceBar.leftText, unpack(config.texts.font))
        experienceBar.leftFormat = config.texts.leftFormat
        U.SetFont(experienceBar.centerText, unpack(config.texts.font))
        experienceBar.centerFormat = config.texts.centerFormat
        U.SetFont(experienceBar.rightText, unpack(config.texts.font))
        experienceBar.rightFormat = config.texts.rightFormat
        UpdateTextVisibility(config.texts.showOnHover)
    else
        UpdateTextVisibility()
    end

    experienceBar.hideAtMaxLevel = config.hideAtMaxLevel

    UpdateXP(experienceBar)
    experienceBar:Show()
end
BFI.RegisterCallback("UpdateModules", "DB_ExperienceBar", UpdateXPerienceBar)