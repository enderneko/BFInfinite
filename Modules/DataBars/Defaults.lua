---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class DataBars
local DB = BFI.DataBars
---@class AbstractFramework
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
}

AF.RegisterCallback("UpdateConfigs", "DataBars", function(t)
    if not t["dataBars"] then
        t["dataBars"] = U.Copy(defaults)
    end
    DB.config = t["dataBars"]
end)

function DB.GetDefaults()
    return U.Copy(defaults)
end