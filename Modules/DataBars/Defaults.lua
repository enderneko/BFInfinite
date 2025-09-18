---@class BFI
local BFI = select(2, ...)
---@class DataBars
local DB = BFI.modules.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    experienceBar = {
        enabled = true,
        position = {"BOTTOM", -166, 1},
        width = 330,
        height = 5,
        texture = "AF Plain",
        hideAtMaxLevel = true,
        texts = {
            enabled = true,
            alwaysShow = false,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[level]",
            centerFormat = "[remaining]",
            rightFormat = "[percent]",
            yOffset = 2,
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
        color = {type = "gradient", startAlpha = 1, endAlpha = 1, startColor = AF.GetColorTable("exp_normal_start"), endColor = AF.GetColorTable("exp_normal_end")},
        completedQuests = {enabled = true, color = AF.GetColorTable("exp_complete")},
        incompleteQuests = {enabled = false, color = AF.GetColorTable("exp_incomplete")},
        rested = {enabled = true, color = AF.GetColorTable("exp_rested")},
    },
    reputationBar = {
        enabled = true,
        position = {"BOTTOM", 166, 1},
        width = 330,
        height = 5,
        texture = "AF Plain",
        hideBelowMaxLevel = false,
        texts = {
            enabled = true,
            alwaysShow = false,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[name]",
            centerFormat = "[progress]",
            rightFormat = "[standing]",
            yOffset = 2,
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
        color = {type = "gradient", startAlpha = 1, endAlpha = 1, startColor = nil, endColor = AF.GetColorTable("white")},
    },
    honorBar = {
        enabled = true,
        position = {"BOTTOM", -166, 1},
        width = 330,
        height = 5,
        texture = "AF Plain",
        hideBelowMaxLevel = true,
        texts = {
            enabled = true,
            alwaysShow = false,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[level]",
            centerFormat = "",
            rightFormat = "[progress]",
            yOffset = 2,
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
        color = {type = "gradient", startAlpha = 1, endAlpha = 1, startColor = AF.GetColorTable("honor_start"), endColor = AF.GetColorTable("honor_end")},
    },
    threats = {
        enabled = true,
        position = {"BOTTOM", 0, 500},
        width = 150,
        height = 20,
        num = 3,
        spacing = -1,
        texture = "AF Plain",
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
    },
}

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["dataBars"] then
        t["dataBars"] = AF.Copy(defaults)
    end
    DB.config = t["dataBars"]
end)

function DB.GetDefaults()
    return AF.Copy(defaults)
end

function DB.ResetToDefaults(which)
    if not which then
        wipe(DB.config)
        AF.Merge(DB.config, defaults)
    else
        wipe(DB.config[which])
        AF.Merge(DB.config[which], defaults[which])
    end
end