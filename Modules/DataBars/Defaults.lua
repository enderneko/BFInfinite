---@class BFI
local BFI = select(2, ...)
---@class DataBars
local DB = BFI.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    experienceBar = {
        enabled = true,
        position = {"BOTTOM", -166, 1},
        width = 330,
        height = 5,
        texture = "BFI Plain",
        hideAtMaxLevel = true,
        texts = {
            enabled = true,
            showOnHover = true,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[level]",
            centerFormat = "[remaining]",
            rightFormat = "[percent]",
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
        normalColor = {useGradient = true, startColor = AF.GetColorTable("exp_normal_start"), endColor = AF.GetColorTable("exp_normal_end")},
        completeQuests = {enabled = true, color = AF.GetColorTable("exp_complete")},
        incompleteQuests = {enabled = false, color = AF.GetColorTable("exp_incomplete")},
        rested = {enabled = true, color = AF.GetColorTable("exp_rested")},
    },
    reputationBar = {
        enabled = true,
        position = {"BOTTOM", 166, 1},
        width = 330,
        height = 5,
        texture = "BFI Plain",
        hideBelowMaxLevel = false,
        texts = {
            enabled = true,
            showOnHover = true,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[name]",
            centerFormat = "[progress]",
            rightFormat = "[standing]",
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
    },
    honorBar = {
        enabled = true,
        position = {"BOTTOM", -166, 1},
        width = 330,
        height = 5,
        texture = "BFI Plain",
        hideBelowMaxLevel = true,
        texts = {
            enabled = true,
            showOnHover = true,
            font = {"BFI", 10, "outline", false},
            leftFormat = "[level]",
            centerFormat = "",
            rightFormat = "[progress]",
        },
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
        color = AF.GetColorTable("honor"),
    },
    threats = {
        enabled = true,
        position = {"BOTTOM", 0, 500},
        width = 150,
        height = 20,
        num = 3,
        spacing = -1,
        texture = "BFI Plain",
        borderColor = AF.GetColorTable("border"),
        bgColor = AF.GetColorTable("background"),
    },
}

AF.RegisterCallback("BFI_UpdateConfigs", function(_, t)
    if not t["dataBars"] then
        t["dataBars"] = AF.Copy(defaults)
    end
    DB.config = t["dataBars"]
end)

function DB.GetDefaults()
    return AF.Copy(defaults)
end