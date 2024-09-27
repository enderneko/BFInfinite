---@class BFI
local BFI = select(2, ...)
---@class DataBars
local DB = BFI.DataBars
local AW = BFI.AW
local U = BFI.utils

local defaults = {
    experienceBar = {
        enabled = true,
        position = {"BOTTOM", -166, 1},
        width = 330,
        height = 5,
        texture = "BFI Plain",
        texts = {
            enabled = true,
            showOnHover = true,
            font = {"Visitor", 9, "monochrome_outline", false},
            leftFormat = "[level]",
            centerFormat = "[remaining]",
            rightFormat = "[percent]",
        },
        borderColor = AW.GetColorTable("border"),
        bgColor = AW.GetColorTable("background"),
        normalColor = {useGradient = true, startColor = AW.GetColorTable("exp_normal_start"), endColor = AW.GetColorTable("exp_normal_end")},
        completeQuests = {enabled = true, color = AW.GetColorTable("exp_complete")},
        incompleteQuests = {enabled = false, color = AW.GetColorTable("exp_incomplete")},
        rested = {enabled = true, color = AW.GetColorTable("exp_rested")},
    },
    reputationBar = {
        enabled = true,
        position = {"BOTTOM", 166, 1},
        width = 330,
        height = 5,
        colors = {
            border = AW.GetColorTable("border"),
            background = AW.GetColorTable("background"),
            normal = AW.GetColorTable("exp_normal_start"),
        },
    },
}

BFI.RegisterCallback("UpdateConfigs", "DataBars", function(t)
    if not t["dataBars"] then
        t["dataBars"] = U.Copy(defaults)
    end
    DB.config = t["dataBars"]
end)

function DB.GetDefaults()
    return U.Copy(defaults)
end