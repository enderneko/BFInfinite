local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.M_UF

local defaults = {
    player = {
        general = {
            bgColor = AW.GetColorTable("background"),
            borderColor = AW.GetColorTable("border"),
            position = {"LEFT", 300, 0},
            width = 200,
            height = 70,
        },
        indicators = {
            healthBar = {
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                width = 200,
                height = 30,
                color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            powerBar = {
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                width = 200,
                height = 20,
                color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            nameText = {
                position = {"LEFT", "LEFT", 5, 0},
                length = 0.75,
                anchorTo = "healthBar",
                font = {BFI_DEFAULT, 12, "shadow"},
                color = {type="class_color", rgb=AW.GetColorTable("white")},
            },
        },
    },
    target = {
        general = {
            bgColor = AW.GetColorTable("background"),
            borderColor = AW.GetColorTable("border"),
            position = {"LEFT", 550, 0},
            width = 200,
            height = 70,
        },
        indicators = {
            healthBar = {
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                width = 200,
                height = 30,
                color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            powerBar = {
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                width = 200,
                height = 20,
                color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            nameText = {
                position = {"LEFT", "LEFT", 5, 0},
                length = 0.75,
                anchorTo = "healthBar",
                font = {BFI_DEFAULT, 12, "shadow"},
                color = {type="class_color", rgb=AW.GetColorTable("white")},
            },
        },
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