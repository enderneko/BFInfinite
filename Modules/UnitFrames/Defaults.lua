local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.M_UF

local default_player_target_indicators = {
    healthBar = {
        position = {"TOPLEFT", "TOPLEFT", 0, 0},
        orientation = "HORIZONTAL",
        width = 225,
        height = 30,
        color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
        lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
        bgColor = AW.GetColorTable("background"),
        borderColor = AW.GetColorTable("border"),
        texture = BFI_DEFAULT,
        smoothing = false,
        frameLevel = 1,
    },
    powerBar = {
        position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
        orientation = "HORIZONTAL",
        width = 225,
        height = 17,
        color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
        lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
        bgColor = AW.GetColorTable("background"),
        borderColor = AW.GetColorTable("border"),
        texture = BFI_DEFAULT,
        smoothing = false,
        frameLevel = 1,
    },
    nameText = {
        position = {"TOPLEFT", "TOPLEFT", 3, -3},
        length = 0.5,
        anchorTo = "healthBar",
        font = {BFI_DEFAULT, 12, "shadow"},
        color = {type="class_color", rgb=AW.GetColorTable("white")},
    },
    healthText = {
        position = {"TOPRIGHT", "TOPRIGHT", -3, -3},
        anchorTo = "healthBar",
        font = {BFI_DEFAULT, 12, "shadow"},
        color = {type="custom_color", rgb=AW.GetColorTable("white")},
        format = {
            numeric = "current_absorbs_short",
            percent = "current_absorbs_sum_decimal",
            delimiter = " | ",
        },
    },
    portrait = {
        type = "3d", -- 3d, 2d, class_icon
        position = {"CENTER", "CENTER", 0, -5},
        anchorTo = "button",
        width = 197,
        height = 20,
        color = AW.GetColorTable("background", 1),
        borderColor = AW.GetColorTable("border"),
        model = {
            xOffset = 0,
            yOffset = 0,
            rotation = 0,
            camDistanceScale = 1.7,
        },
        frameLevel = 5,
    },
}

local defaults = {
    player = {
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOMLEFT", 300, 300},
            width = 225,
            height = 49,
        },
        indicators = default_player_target_indicators,
    },
    target = {
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOMLEFT", 550, 300},
            width = 225,
            height = 49,
        },
        indicators = default_player_target_indicators,
    }
}

BFI.RegisterCallback("InitConfigs", "UnitFrames", function(t)
    if not t["unitFrames"] then
        t["unitFrames"] = U.Copy(defaults)
    end
    UF.config = t["unitFrames"]
end)

function UF.GetDefaults()
    return U.Copy(defaults)
end