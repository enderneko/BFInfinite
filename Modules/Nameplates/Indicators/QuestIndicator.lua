---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local GetUnitTooltipInfo = C_TooltipInfo.GetUnit
local GetTasksTable = GetTasksTable
local GetTaskInfo = GetTaskInfo
local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local GetQuestInfo = C_QuestLog.GetInfo
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local IsQuestComplete = C_QuestLog.IsComplete
local GetQuestObjectives = C_QuestLog.GetQuestObjectives
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local IsInInstance = IsInInstance

---------------------------------------------------------------------
-- quest
---------------------------------------------------------------------
local QUEST_OBJECTIVE_BAR = "^(.*) %(?(%d+)%%%)?$"
local QUEST_OBJECTIVE_1 = "^(%d+)/(%d+) (.*)$"
local QUEST_OBJECTIVE_2 = "^(.*)[:：]%s?(%d+)/(%d+)$"

local quests = {}
local hideInInstance

local function UpdateQuestIndicator(np)
    np.indicators.questIndicator:Update()
end

-- TODO:
-- C_Scenario.GetInfo
-- C_Scenario.GetStepInfo
-- local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE);
-- local inProvingGrounds = (scenarioType == LE_SCENARIO_TYPE_PROVING_GROUNDS);
-- local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY);
-- local inWarfront = (scenarioType == LE_SCENARIO_TYPE_WARFRONT);

local function UpdateQuests(_, event, unit)
    if unit and unit ~= "player" then return end

    wipe(quests)

    if IsInInstance() and hideInInstance then return end

    for i = 1, GetNumQuestLogEntries() do
        -- https://warcraft.wiki.gg/wiki/API_C_QuestLog.GetInfo
        local info = GetQuestInfo(i)

        if info and info.questID and not info.isHeader then
            -- print(i, info.questID, info.title)
            quests[info.title] = wipe(quests[info.title] or {})

            -- objectives https://warcraft.wiki.gg/wiki/API_C_QuestLog.GetQuestObjectives
            local objective
            for _, o in pairs(GetQuestObjectives(info.questID)) do
                -- print(o.text, o.type, o.finished, o.numFulfilled, o.numRequired)
                if o.type == "item" or o.type == "monster" then
                    objective = select(3, strmatch(o.text, QUEST_OBJECTIVE_1))
                    if not objective then
                        objective = strmatch(o.text, QUEST_OBJECTIVE_2)
                    end
                elseif o.type == "progressbar" then
                    objective = strmatch(o.text, QUEST_OBJECTIVE_BAR)
                end
                if objective then
                    quests[info.title][objective] = true
                end
            end

            if U.IsEmpty(quests[info.title]) then
                quests[info.title] = nil
            end
        end
    end

    -- texplore(quests)
    NP.IterateAllVisibleNamePlates(UpdateQuestIndicator, "hostile_npc")
end

local timer
local function DelayedUpdate()
    if timer then timer:Cancel() end
    timer = C_Timer.After(1, UpdateQuests)
end

function NP.EnableQuestIndicator(enabled, _hideInInstance)
    if enabled then
        hideInInstance = _hideInInstance
        NP:RegisterEvent("UNIT_QUEST_LOG_CHANGED", DelayedUpdate)
        NP:RegisterEvent("QUEST_LOG_UPDATE", DelayedUpdate)
        if not hideInInstance and IsInInstance() then
            DelayedUpdate()
        end
    else
        NP:UnregisterEvent("UNIT_QUEST_LOG_CHANGED", DelayedUpdate)
    end
end

---------------------------------------------------------------------
-- UnitIsQuestTarget
---------------------------------------------------------------------
local function UnitIsQuestTarget(unit)
    local data = GetUnitTooltipInfo(unit)
    -- texplore(data)

    -- https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnit
    -- Enum.TooltipDataLineType
    -- 0 None
    -- 1 Blank
    -- 2 UnitName
    -- 3 GemSocket
    -- 4 AzeriteEssenceSlot
    -- 5 AzeriteEssencePower
    -- 6 LearnableSpell
    -- 7 UnitThreat
    -- 8 QuestObjective
    -- 9 AzeriteItemPowerDescription
    -- 10 RuneforgeLegendaryPowerDescription
    -- 11 SellPrice
    -- 12 ProfessionCraftingQuality
    -- 13 SpellName
    -- 14 CurrencyTotal
    -- 15 ItemEnchantmentPermanent
    -- 16 UnitOwner
    -- 17 QuestTitle
    -- 18 QuestPlayer
    -- 19 NestedBlock
    -- 20 ItemBinding
    -- 21 RestrictedRaceClass Added in 10.0.5
    -- 22 RestrictedFaction Added in 10.0.5
    -- 23 RestrictedSkill Added in 10.0.5
    -- 24 RestrictedPvPMedal Added in 10.0.5
    -- 25 RestrictedReputation Added in 10.0.5
    -- 26 RestrictedSpellKnown Added in 10.0.5
    -- 27 RestrictedLevel Added in 10.0.5
    -- 28 EquipSlot Added in 10.0.5
    -- 29 ItemName Added in 10.0.5
    -- 30 Separator Added in 10.1.0

    local title

    for i = 3, #data.lines do
        local line = data.lines[i]
        if line.type == 17 then -- title
            if quests[line.leftText] then
                title = line.leftText
            end
        elseif line.type == 8 and title and quests[title] then -- objective and active quest
            local name, current, required
            if strfind(line.leftText, "%%%)?$") then -- progress
                name, current = strmatch(line.leftText, QUEST_OBJECTIVE_BAR)
                required = 100
            else
                current, required, name = strmatch(line.leftText, QUEST_OBJECTIVE_1)
                if not name then
                    name, current, required = strmatch(line.leftText, QUEST_OBJECTIVE_2)
                end

            end

            -- print("result: ", name, current, required)
            if name and quests[title][name] then
                current = tonumber(current)
                required = tonumber(required)
                if current ~= required then
                    return true
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- icon
---------------------------------------------------------------------
local function UpdateIcon(self)
    local unit = self.root.unit

    if UnitIsQuestTarget(unit) then
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function QuestIndicator_Update(self)
    UpdateIcon(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function QuestIndicator_Enable(self)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function QuestIndicator_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.SetSize(self, config.width, config.height)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateQuestIndicator(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetTexture(AW.GetTexture("Quest"))
    icon:SetAllPoints()

    -- functions
    frame.Enable = QuestIndicator_Enable
    frame.Update = QuestIndicator_Update
    frame.LoadConfig = QuestIndicator_LoadConfig

    return frame
end