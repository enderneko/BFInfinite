---@type BFI
local BFI = select(2, ...)
---@class UIWidgets
local W = BFI.modules.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    microMenu = {
        enabled = true,
        position = {"BOTTOMLEFT", 1, 183},
        alpha = 0,
        width = 20,
        height = 25,
        spacing = 2,
        buttonsPerRow = 12,
    },
    powerBarWidget = {
        enabled = true,
        position = {"TOP", 0, -70},
        scale = 0.8,
    },
    altPowerBar = {
        position = {"BOTTOM", 0, 211},
        useBlizzardStyle = false,
        scale = 0.75,
        width = 170,
        height = 19,
        texture = "AF",
        color = AF.GetColorTable(BFI.name),
        bgColor = AF.GetColorTable("background"),
        borderColor = AF.GetColorTable("border"),
        texts = {
            font = {"BFI", 12, "none", true},
            color = AF.GetColorTable("white"),
            leftFormat = "[name]",
            centerFormat = "",
            rightFormat = "[current] / [total]",
        },
    },
    buffTimer = {
        position = {"BOTTOM", 0, 209},
        scale = 0.75,
    },
    vehicleSeats = {
        position = {"BOTTOMLEFT", 381, 183},
        scale = 0.7,
    },
    queueStatus = {
        position = {"BOTTOM", -469, 152},
        scale = 0.7,
    },
    durability = {
        position = {"BOTTOM", -244, 153},
        scale = 0.7,
    },
    battlenetToast = {
        position = {"BOTTOMLEFT", 1, 238},
        scale = 1,
    },
    quickJoinToast = {
        enabled = true,
        position = {"BOTTOMLEFT", 1, 212},
        font = {"BFI", 12, "none", true},
    },
    readyPull = {
        enabled = true,
        position = {"BOTTOM", 392, 145},
        font = {"BFI", 12, "none", true},
        arrangement = "left_to_right",
        ready = "",
        pull = "",
        countdown = 7,
        width = 60,
        height = 17,
        spacing = 2,
    },
    markers = {
        enabled = true,
        position = {"BOTTOM", 355, 99},
        targetMarkers = true,
        worldMarkers = true,
        width = 20,
        height = 20,
        groupSpacing = 2,
        markerSpacing = 2,
        arrangement = "left_to_right_then_up",
        showIfSolo = false,
    },
    objectiveTracker = {
        enabled = true,
        position = {"TOPRIGHT", -1, -200},
        height = 400,
        font = {"BFI", 12, "none", true},
        order = {
            "ScenarioObjectiveTracker", -- 地下城/挑战/试炼场/托加斯特，罪魂之塔/... - TRACKER_HEADER_DUNGEON
            "UIWidgetObjectiveTracker", -- 场景战役(?) - TRACKER_HEADER_SCENARIO
            "CampaignQuestObjectiveTracker", -- 战役(任务) - TRACKER_HEADER_CAMPAIGN_QUESTS
            "WorldQuestObjectiveTracker", -- 世界任务 - TRACKER_HEADER_WORLD_QUESTS
            "BonusObjectiveTracker", -- 奖励目标 - TRACKER_HEADER_BONUS_OBJECTIVES
            "QuestObjectiveTracker", -- 任务 - TRACKER_HEADER_QUESTS
            "AchievementObjectiveTracker", -- 成就 - TRACKER_HEADER_ACHIEVEMENTS
            "AdventureObjectiveTracker", -- 藏品 - ADVENTURE_TRACKING_MODULE_HEADER_TEXT
            "MonthlyActivitiesObjectiveTracker", -- 旅行者日志 - TRACKER_HEADER_MONTHLY_ACTIVITIES
            "InitiativeTasksObjectiveTracker", -- 文化节 - TRACKER_HEADER_INITIATIVE_TASKS
            "ProfessionsRecipeTracker", -- 专业技能 - PROFESSIONS_TRACKER_HEADER_PROFESSION
        },
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["uiWidgets"] then
        t["uiWidgets"] = AF.Copy(defaults)
    end
    W.config = t["uiWidgets"]
end)

function W.GetDefaults()
    return AF.Copy(defaults)
end

function W.ResetToDefaults(which)
    if not which then
        for k, v in next, defaults do
            wipe(W.config[k])
            AF.Merge(W.config[k], v)
        end
    else
        wipe(W.config[which])
        AF.Merge(W.config[which], defaults[which])
    end
end