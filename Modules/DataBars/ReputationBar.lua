---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AW = BFI.AW
local U = BFI.utils
---@class DataBars
local DB = BFI.DataBars

local GetWatchedFactionData = C_Reputation.GetWatchedFactionData
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local IsMajorFaction = C_Reputation.IsMajorFaction
local GetMajorFactionData = C_MajorFactions.GetMajorFactionData
local HasMaximumRenown = C_MajorFactions.HasMaximumRenown

local reputationBar

local FACTION_COLORS = U.Copy(_G.FACTION_BAR_COLORS)
-- paragon
FACTION_COLORS[9] = {r = 0, g = 1, b = 0.53}
-- renown
FACTION_COLORS[10] = {r = 0, g = 1, b = 1}

---------------------------------------------------------------------
-- text
---------------------------------------------------------------------
local formatter = {
    name = function()
        return reputationBar.name
    end,
    current = function()
        return BreakUpLargeNumbers(reputationBar.current)
    end,
    total = function()
        return BreakUpLargeNumbers(reputationBar.max)
    end,
    progress = function()
        if reputationBar.max == 0 then
            return ""
        else
            return format("%s / %s", BreakUpLargeNumbers(reputationBar.current), BreakUpLargeNumbers(reputationBar.max))
        end
    end,
    standing = function()
        return reputationBar.standing
    end,
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
    reputationBar.textFrame:Show()
end

local function HideText()
    reputationBar.textFrame:Hide()
end

local function UpdateTextVisibility(showOnHover)
    if showOnHover == true then
        reputationBar.textFrame:Hide()
        reputationBar:SetScript("OnEnter", ShowText)
        reputationBar:SetScript("OnLeave", HideText)
    elseif showOnHover == false then
        reputationBar.textFrame:Show()
        reputationBar:SetScript("OnEnter", nil)
        reputationBar:SetScript("OnLeave", nil)
    else
        reputationBar.textFrame:Hide()
        reputationBar:SetScript("OnEnter", nil)
        reputationBar:SetScript("OnLeave", nil)
    end
end

---------------------------------------------------------------------
-- update rep
---------------------------------------------------------------------
local function UpdateRep(self)
    local data = GetWatchedFactionData()
    if not data then
        self:Hide()
        return
    end
    self:Show()

    local name = data.name
    local reaction = data.reaction
    local currentReactionThreshold = data.currentReactionThreshold
    local nextReactionThreshold = data.nextReactionThreshold
    local currentStanding = data.currentStanding
    local factionID = data.factionID
    -- BFI.Debug(name, reaction, factionID, "currentStanding:", currentStanding, "current:", currentReactionThreshold, "next:", nextReactionThreshold)

    local standingLabel, hasRewardPending
    -- TODO: hasRewardPending

    --! friendship
    local info = factionID and GetFriendshipReputation(factionID)
    if info and info.friendshipFactionID and info.friendshipFactionID ~= 0 then
        standingLabel = info.reaction
        currentReactionThreshold = info.reactionThreshold or 0
        nextReactionThreshold = info.nextThreshold
        currentStanding = info.standing or 1
        -- BFI.Debug("[friendship]", "currentStanding:", currentStanding, "standingLabel:", standingLabel, "current:", currentReactionThreshold, "next:", nextReactionThreshold)
    end

    --! paragon (Legion)
    if factionID and IsFactionParagon(factionID) then
        local current, threshold
        current, threshold, _, hasRewardPending = GetFactionParagonInfo(factionID)

        if current and threshold then
            standingLabel = L["Paragon"]
            currentReactionThreshold = 0
            nextReactionThreshold = threshold
            currentStanding = current % threshold
            reaction = 9
        end
        -- BFI.Debug("[paragon]", "currentStanding:", currentStanding, "standingLabel:", standingLabel, "current:", currentReactionThreshold, "next:", nextReactionThreshold)
    end

    --! renown
    if factionID and IsMajorFaction(factionID) then
        reaction = 10
        local data = GetMajorFactionData(factionID)
        standingLabel = _G.RENOWN_LEVEL_LABEL .. " " .. data.renownLevel
        currentReactionThreshold = 0
        nextReactionThreshold = data.renownLevelThreshold
        currentStanding = HasMaximumRenown(factionID) and data.renownLevelThreshold or data.renownReputationEarned or 0
        -- BFI.Debug("[renown]", "currentStanding:", currentStanding, "standingLabel:", standingLabel, "current:", currentReactionThreshold, "next:", nextReactionThreshold)
    end

    -- bar
    local isMax = not nextReactionThreshold or currentReactionThreshold == nextReactionThreshold
    if isMax then
        self:SetMinMaxValues(0, 1)
        self:SetBarValue(1)
    else
        self:SetMinMaxValues(currentReactionThreshold, nextReactionThreshold)
        self:SetBarValue(currentStanding)
    end

    -- color
    local color = FACTION_COLORS[reaction]
    self:SetColor(color.r, color.g, color.b)

    -- text
    if not standingLabel then
        standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or _G.UNKNOWN
    end

    reputationBar.name = name
    reputationBar.current = currentStanding - currentReactionThreshold
    reputationBar.max = nextReactionThreshold - currentReactionThreshold
    reputationBar.standing = standingLabel

    if reputationBar.textEnabled then
        self.leftText:SetText(FormatText(self.leftFormat))
        self.centerText:SetText(FormatText(self.centerFormat))
        self.rightText:SetText(FormatText(self.rightFormat))
    end
end

local function UpdateRepVisibility(self)
    -- level check
    if self.hideBelowMaxLevel and not U.IsMaxLevel() then
        self:RegisterEvent("PLAYER_LEVEL_UP", UpdateRepVisibility)
        self:UnregisterEvent("UPDATE_FACTION")
        self:Hide()
    else
        self:RegisterEvent("UPDATE_FACTION", UpdateRep)
        self:UnregisterEvent("PLAYER_LEVEL_UP")
        UpdateRep(self)
        self:Show()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateReputationBar()
    reputationBar = AW.CreateSimpleBar(AW.UIParent, "BFI_ReputationBar")
    reputationBar.loss:Hide()
    reputationBar:Hide()

    AW.CreateMover(reputationBar, L["Data Bars"], L["Reputation Bar"])
    AW.AddToPixelUpdater(reputationBar)

    -- text frame
    local textFrame = CreateFrame("Frame", nil, reputationBar)
    reputationBar.textFrame = textFrame
    textFrame:SetAllPoints()

    -- left text
    local leftText = textFrame:CreateFontString(nil, "OVERLAY")
    reputationBar.leftText = leftText
    AW.LoadTextPosition(leftText, {"LEFT", "LEFT", 5, 0})

    -- right text
    local centerText = textFrame:CreateFontString(nil, "OVERLAY")
    reputationBar.centerText = centerText
    AW.LoadTextPosition(centerText, {"CENTER", "CENTER", 0, 0})

    -- right text
    local rightText = textFrame:CreateFontString(nil, "OVERLAY")
    reputationBar.rightText = rightText
    AW.LoadTextPosition(rightText, {"RIGHT", "RIGHT", -5, 0})

    -- events
    BFI.AddEventHandler(reputationBar)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateReputationBar(module, which)
    if module and module ~= "DataBars" then return end
    if which and which ~= "reputation" then return end

    local config = DB.config.reputationBar
    if not config.enabled then
        if reputationBar then
            reputationBar.enabled = false
            reputationBar:UnregisterAllEvents()
            reputationBar:Hide()
        end
        return
    end

    if not reputationBar then
        CreateReputationBar()
    end
    reputationBar.enabled = true

    reputationBar:RegisterEvent("UPDATE_FACTION", UpdateRep)

    AW.UpdateMoverSave(reputationBar, config.position)
    AW.LoadPosition(reputationBar, config.position)
    AW.SetSize(reputationBar, config.width, config.height)

    reputationBar:SetBorderColor(AW.UnpackColor(config.borderColor))
    reputationBar:SetBackgroundColor(AW.UnpackColor(config.bgColor))
    reputationBar:SetTexture(U.GetBarTexture(config.texture))

    -- text
    reputationBar.textEnabled = config.texts.enabled
    if config.texts.enabled then
        U.SetFont(reputationBar.leftText, unpack(config.texts.font))
        reputationBar.leftFormat = config.texts.leftFormat
        U.SetFont(reputationBar.centerText, unpack(config.texts.font))
        reputationBar.centerFormat = config.texts.centerFormat
        U.SetFont(reputationBar.rightText, unpack(config.texts.font))
        reputationBar.rightFormat = config.texts.rightFormat
        UpdateTextVisibility(config.texts.showOnHover)
    else
        UpdateTextVisibility()
    end

    reputationBar.hideBelowMaxLevel = config.hideBelowMaxLevel
    UpdateRepVisibility(reputationBar)
end
BFI.RegisterCallback("UpdateModules", "DB_ReputationBar", UpdateReputationBar)