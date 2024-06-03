local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.M_UF

AW.AddColors({
    aura_percent = {1, 1, 0},
    aura_seconds = {1, 0.3, 0.3},
})

-- TODO: presets

local default_player_target_indicators = {
    healthBar = {
        enabled = true,
        position = {"TOPLEFT", "TOPLEFT", 0, 0},
        frameLevel = 1,
        -- orientation = "HORIZONTAL",
        width = 225,
        height = 31,
        color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
        lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
        bgColor = AW.GetColorTable("background"),
        borderColor = AW.GetColorTable("border"),
        texture = "BFI 1",
        smoothing = false,
        healPrediction = {enabled=true, useCustomColor=true, color=AW.GetColorTable("heal_prediction")},
        shield = {
            enabled = true,
            -- texture = AW.GetTexture("Shield"), -- no customization now
            color = AW.GetColorTable("shield", 0.4),
            reverseFill = true,
        },
        overshieldGlow = {enabled=true, color=AW.GetColorTable("shield")},
        healAbsorb = {
            enabled = true,
            -- texture = AW.GetTexture("Shield"), -- no customization now
            color = AW.GetColorTable("absorb"),
        },
        overabsorbGlow = {enabled=true, color=AW.GetColorTable("absorb")},
    },
    powerBar = {
        enabled = true,
        position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
        frameLevel = 1,
        -- orientation = "HORIZONTAL",
        width = 225,
        height = 17,
        color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
        lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
        bgColor = AW.GetColorTable("background"),
        borderColor = AW.GetColorTable("border"),
        texture = "BFI 1",
        smoothing = false,
        frequent = true,
    },
    nameText = {
        enabled = true,
        position = {"TOPLEFT", "TOPLEFT", 3, -4},
        length = 0.5,
        anchorTo = "healthBar",
        font = {"BFI 1", 12, "none", true},
        color = {type="class_color", rgb=AW.GetColorTable("white")}, -- class/custom
    },
    healthText = {
        enabled = true,
        position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
        anchorTo = "healthBar",
        font = {"BFI 1", 12, "none", true},
        color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/custom
        format = {
            numeric = "current_absorbs_short",
            percent = "current_absorbs_sum_decimal",
            delimiter = " | ",
            noPercentSign = false,
        },
    },
    powerText = {
        enabled = true,
        position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
        anchorTo = "powerBar",
        font = {"BFI 2", 9, "monochrome", false},
        color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/power/custom
        frequent = true,
        format = {
            numeric = "current",
            percent = "none",
            delimiter = " | ",
            noPercentSign = false,
        },
    },
    portrait = {
        enabled = true,
        type = "3d", -- 3d, 2d, class_icon
        position = {"CENTER", "CENTER", 0, -5},
        frameLevel = 5,
        -- anchorTo = "button",
        width = 197,
        height = 20,
        bgColor = AW.GetColorTable("background", 1),
        borderColor = AW.GetColorTable("border"),
        model = {
            xOffset = 0, -- [-100, 100]
            yOffset = 0, -- [-100, 100]
            rotation = 0, -- [0, 360]
            camDistanceScale = 1.5,
        },
    },
    castBar = {
        enabled = true,
        position = {"CENTER", "CENTER", 0, -5},
        frameLevel = 10,
        width = 197,
        height = 20,
        bgColor = AW.GetColorTable("background", 0.5),
        borderColor = AW.GetColorTable("border"),
        texture = "BFI 1",
        fadeDuration = 1,
        showIcon = true,
        nameText = {
            font = {"BFI 1", 12, "none", true},
            position = {"LEFT", "LEFT", 25, 0},
            color = AW.GetColorTable("white"),
            length = 0.5,
        },
        durationText = {
            font = {"BFI 1", 12, "none", true},
            position = {"RIGHT", "RIGHT", -5, 0},
            format = "%.1f",
            color = AW.GetColorTable("white"),
            showDelay = false,
        },
        spark = {
            texture = AW.GetPlainTexture(),
            color = AW.GetColorTable("cast_spark"),
            width = 2,
            height = 0,
        },
        colors = {
            normal = AW.GetColorTable("cast_normal"),
            failed = AW.GetColorTable("cast_failed"),
            succeeded = AW.GetColorTable("cast_succeeded"),
            uninterruptible = AW.GetColorTable("cast_uninterruptible"),
        },
    },
    buffs = {
        enabled = true,
        -- position = {},
        -- orientation = "",
        -- color = "",
        width = 19,
        height = 19,
        spacing = 1,
        numPerLine = 11,
        numTotal = 22,
        frameLevel = 1,
    },
    debuffs = {
        enabled = true,
        -- position = {},
        -- orientation = "",
        width = 19,
        height = 19,
        spacing = 1,
        numPerLine = 11,
        numTotal = 22,
        frameLevel = 1,
    },
    privateAuras = {
        enabled = true,
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
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 31,
                color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                smoothing = false,
                healPrediction = {enabled=true, useCustomColor=true, color=AW.GetColorTable("heal_prediction")},
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Shield"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {enabled=true, color=AW.GetColorTable("shield")},
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Shield"), -- no customization now
                    color = AW.GetColorTable("absorb"),
                },
                overabsorbGlow = {enabled=true, color=AW.GetColorTable("absorb")},
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 17,
                color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -4},
                length = 0.5,
                anchorTo = "healthBar",
                font = {"BFI 1", 12, "none", true},
                color = {type="class_color", rgb=AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                font = {"BFI 1", 12, "none", true},
                color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    noPercentSign = false,
                },
            },
            powerText = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                font = {"BFI 2", 9, "monochrome", false},
                color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    noPercentSign = false,
                },
            },
            portrait = {
                enabled = true,
                type = "3d", -- 3d, 2d, class_icon
                position = {"CENTER", "CENTER", 0, -5},
                frameLevel = 5,
                -- anchorTo = "button",
                width = 197,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.5,
                },
            },
            castBar = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, -5},
                frameLevel = 10,
                width = 197,
                height = 20,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                fadeDuration = 1,
                showIcon = true,
                nameText = {
                    font = {"BFI 1", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.5,
                },
                durationText = {
                    font = {"BFI 1", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    texture = AW.GetPlainTexture(),
                    color = AW.GetColorTable("cast_spark"),
                    width = 2,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                },
                ticks = {
                    enabled = true,
                    color = AW.GetColorTable("cast_tick"),
                    width = 3,
                },
                latency = {
                    enabled = true,
                    color = AW.GetColorTable("cast_latency")
                },
            },
            buffs = {
                enabled = true,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                orientation = "right_to_left",
                borderColor = "none",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacing = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                durationText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true, 5, AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
            },
            debuffs = {
                enabled = true,
                position = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1},
                orientation = "right_to_left",
                borderColor = "debuff_type",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacing = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                durationText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true, 5, AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    target = {
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOMLEFT", 550, 300},
            width = 225,
            height = 49,
            oorAlpha = 1,
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 31,
                color = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf")},
                lossColor = {type="custom_color", alpha=1, rgb=AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                smoothing = false,
                healPrediction = {enabled=true, useCustomColor=true, color=AW.GetColorTable("heal_prediction")},
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Shield"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {enabled=true, color=AW.GetColorTable("shield")},
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Shield"), -- no customization now
                    color = AW.GetColorTable("absorb"),
                },
                overabsorbGlow = {enabled=true, color=AW.GetColorTable("absorb")},
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 17,
                color = {type="class_color", alpha=1, rgb=AW.GetColorTable("uf_power")},
                lossColor = {type="class_color_dark", alpha=1, rgb=AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -4},
                length = 0.5,
                anchorTo = "healthBar",
                font = {"BFI 1", 12, "none", true},
                color = {type="class_color", rgb=AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                font = {"BFI 1", 12, "none", true},
                color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    noPercentSign = false,
                },
            },
            powerText = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                font = {"BFI 2", 9, "monochrome", false},
                color = {type="custom_color", rgb=AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    noPercentSign = false,
                },
            },
            portrait = {
                enabled = true,
                type = "3d", -- 3d, 2d, class_icon
                position = {"CENTER", "CENTER", 0, -5},
                frameLevel = 5,
                -- anchorTo = "button",
                width = 197,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.5,
                },
            },
            castBar = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, -5},
                frameLevel = 10,
                width = 197,
                height = 20,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI 1",
                fadeDuration = 1,
                showIcon = true,
                nameText = {
                    font = {"BFI 1", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.5,
                },
                durationText = {
                    font = {"BFI 1", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    texture = AW.GetPlainTexture(),
                    color = AW.GetColorTable("cast_spark"),
                    width = 2,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                },
            },
            buffs = {
                enabled = true,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                orientation = "left_to_right",
                borderColor = "cast_by_me",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacing = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                durationText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true, 5, AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
            },
            debuffsByMe = {
                enabled = true,
                position = {"BOTTOMLEFT", "TOPLEFT", 0, 1},
                orientation = "left_to_right",
                borderColor = "debuff_type",
                cooldownStyle = "none",
                separateMyDebuffs = true,
                width = 19,
                height = 19,
                spacing = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                durationText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true, 5, AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
            },
            debuffsByOthers = {
                enabled = true,
                position = {"BOTTOMLEFT", "TOPLEFT", 0, 2},
                anchorTo = "debuffsByMe",
                orientation = "left_to_right",
                borderColor = "debuff_type",
                cooldownStyle = "none",
                width = 17,
                height = 17,
                spacing = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                durationText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true, 5, AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI 1", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
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