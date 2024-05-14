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
                color = {type="custom_color", alpha=1, color=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, color=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            powerBar = {
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                width = 200,
                height = 20,
                color = {type="class_color", alpha=1, color=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, color=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
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
                color = {type="custom_color", alpha=1, color=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, color=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
            },
            powerBar = {
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                width = 200,
                height = 20,
                color = {type="class_color", alpha=1, color=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, color=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = BFI_DEFAULT,
                smoothing = false,
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