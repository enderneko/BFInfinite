---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local UF = BFI.UnitFrames

local default_whitelist = {
    -- druid
    8936, -- 愈合 - Regrowth
    774, -- 回春术 - Rejuvenation
    155777, -- 回春术（萌芽） - Rejuvenation (Germination)
    33763, -- 生命绽放 - Lifebloom
    188550, -- 生命绽放 - Lifebloom
    48438, -- 野性成长 - Wild Growth
    102351, -- 塞纳里奥结界 - Cenarion Ward
    102352, -- 塞纳里奥结界 - Cenarion Ward
    391891, -- 激变蜂群 - Adaptive Swarm
    145205, -- 百花齐放 - Efflorescence
    383193, -- 林地护理 - Grove Tending
    439530, -- 共生绽华 - Symbiotic Blooms
    429224, -- 次级塞纳里奥结界 - Minor Cenarion Ward

    -- evoker
    363502, -- 梦境飞行 - Dream Flight
    370889, -- 双生护卫 - Twin Guardian
    364343, -- 回响 - Echo
    355941, -- 梦境吐息 - Dream Breath
    376788, -- 梦境吐息（回响） - Dream Breath (Echo)
    366155, -- 逆转 - Reversion
    367364, -- 逆转（回响） - Reversion (Echo)
    373862, -- 时空畸体 - Temporal Anomaly
    378001, -- 梦境投影（pvp） - Dream Projection (pvp)
    373267, -- 缚誓生命 - Lifebind
    395296, -- 黑檀之力 (self) - Ebon Might
    395152, -- 黑檀之力 - Ebon Might
    360827, -- 炽火龙鳞 - Blistering Scales
    410089, -- 先知先觉 - Prescience
    406732, -- 空间悖论 (self) - Spatial Paradox
    406789, -- 空间悖论 - Spatial Paradox
    445740, -- 纵焰 - Enkindle
    409895, -- 精神之花 - Spiritbloom (Reverberations, Chronowarden Hero Talent)

    -- monk
    119611, -- 复苏之雾 - Renewing Mist
    124682, -- 氤氲之雾 - Enveloping Mist
    325209, -- 氤氲之息 - Enveloping Breath
    406139, -- 真气之茧 - Chi Cocoon
    450805, -- 净化之魂 - Purified Spirit
    423439, -- 真气宁和 - Chi Harmony

    -- paladin
    53563, -- 圣光道标 - Beacon of Light
    223306, -- 赋予信仰 - Bestow Faith
    148039, -- 信仰屏障 - Barrier of Faith
    156910, -- 信仰道标 - Beacon of Faith
    200025, -- 美德道标 - Beacon of Virtue
    287280, -- 圣光闪烁 - Glimmer of Light
    156322, -- 永恒之火 - Eternal Flame
    431381, -- 晨光 - Dawnlight
    388013, -- 阳春祝福 - Blessing of Spring
    388007, -- 仲夏祝福 - Blessing of Summer
    388010, -- 暮秋祝福 - Blessing of Autumn
    388011, -- 凛冬祝福 - Blessing of Winter
    200654, -- 提尔的拯救 - Tyr's Deliverance

    -- priest
    139, -- 恢复 - Renew
    41635, -- 愈合祷言 - Prayer of Mending
    17, -- 真言术：盾 - Power Word: Shield
    194384, -- 救赎 - Atonement
    77489, -- 圣光回响 - Echo of Light
    372847, -- 光明之泉恢复 - Blessed Bolt
    443526, -- 慰藉预兆 - Premonition of Solace

    -- shaman
    974, -- 大地之盾 - Earth Shield
    383648, -- 大地之盾（天赋） - Earth Shield
    61295, -- 激流 - Riptide
    382024, -- 大地生命武器 - Earthliving Weapon
    375986, -- 始源之潮 - Primordial Wave
    444490, -- 源水气泡 - Hydrobubble
}

local default_blacklist = {
    8326, -- 鬼魂 - Ghost
    160029, -- 正在复活 - Resurrecting
    255234, -- 图腾复生 - Totemic Revival
    225080, -- 复生 - Reincarnation
    57723, -- 筋疲力尽 - Exhaustion
    57724, -- 心满意足 - Sated
    80354, -- 时空错位 - Temporal Displacement
    264689, -- 疲倦 - Fatigued
    390435, -- 筋疲力尽 - Exhaustion
    206151, -- 挑战者的负担 - Challenger's Burden
    195776, -- 月羽疫病 - Moonfeather Fever
    352562, -- 起伏机动 - Undulating Maneuvers
    356419, -- 审判灵魂 - Judge Soul
    387847, -- 邪甲术 - Fel Armor
    213213, -- 伪装 - Masquerade
}

local defaults = {
    general = {
        frameStrata = "LOW",
    },
    player = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", -218, 250},
            width = 225,
            height = 49,
            oorAlpha = nil,
            tooltip = {
                enabled = true,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 31,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = true,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 17,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            extraManaBar = {
                enabled = true,
                position = {"TOP", "BOTTOM", 0, 1},
                anchorTo = "root",
                frameLevel = 1,
                width = 177,
                height = 5,
                color = {type = "mana_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "mana_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = false,
                hideIfHasClassPower = true,
                hideIfFull = true,
            },
            classPowerBar = {
                enabled = true,
                position = {"TOP", "BOTTOM", 0, 1},
                anchorTo = "root",
                frameLevel = 5,
                width = 177,
                height = 5,
                spacing = 1,
                color = {type = "power_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "power_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
            },
            nameText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.5,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
            },
            powerText = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current_short",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
                hideIfEmpty = false,
            },
            portrait = {
                enabled = true,
                style = "3d", -- 3d, 2d, class_icon
                position = {"CENTER", "CENTER", 0, -5},
                anchorTo = "root",
                frameLevel = 5,
                width = 207,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, -5},
                anchorTo = "root",
                frameLevel = 15,
                width = 207,
                height = 20,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = false,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
                ticks = {
                    enabled = true,
                    color = AW.GetColorTable("cast_tick"),
                    width = 2,
                },
                latency = {
                    enabled = true,
                    color = AW.GetColorTable("cast_latency"),
                },
            },
            staggerBar = {
                enabled = true,
                position = {"TOP", "BOTTOM", 0, 1},
                anchorTo = "root",
                frameLevel = 5,
                width = 177,
                height = 5,
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                text = {
                    enabled = false,
                    font = {"BFI", 10, "none", true},
                    position = {"RIGHT", "RIGHT", -1, 0},
                    color = AW.GetColorTable("white"),
                    format = {
                        numeric = "current",
                        percent = "none",
                        delimiter = " | ",
                        showPercentSign = true,
                        useAsianUnits = false,
                    },
                },
            },
            combatIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMLEFT", 1, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 10,
                height = 10,
                texture = "Combat1",
            },
            leaderIcon = {
                enabled = false,
                position = {"CENTER", "LEFT", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
            },
            leaderText = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 3, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("red")}, -- class/custom
            },
            levelText = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 0, 0},
                anchorTo = "leaderText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            statusTimer = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "targetCounter",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                useEn = true,
                showLabel = true,
            },
            statusIcon = {
                enabled = true,
                position = {"TOP", "TOP", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 20,
                height = 20,
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            readyCheckIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMRIGHT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 16,
                height = 16,
            },
            roleIcon = {
                enabled = false,
                position = {"CENTER", "TOPRIGHT", 0, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            factionIcon = {
                enabled = true,
                position = {"CENTER", "TOPLEFT", 0, -1},
                anchorTo = "root",
                frameLevel = 10,
                width = 16,
                height = 16,
                style = "text",
            },
            restingIndicator = {
                enabled = true,
                position = {"BOTTOMLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 5,
                width = 32,
                height = 16,
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            incDmgHealText = {
                enabled = true,
                position = {"BOTTOM", "BOTTOM", 0, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                types = {
                    swing = {enabled = true, color = AW.GetColorTable("swing")},
                    damage = {enabled = true, color = AW.GetColorTable("damage")},
                    heal = {enabled = true, color = AW.GetColorTable("heal")},
                },
                format = {
                    numeric = "current_short",
                    useAsianUnits = false,
                },
            },
            buffs = {
                enabled = false,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = nil,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = nil,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    target = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", 218, 250},
            width = 225,
            height = 49,
            oorAlpha = 1,
            tooltip = {
                enabled = true,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 31,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 225,
                height = 17,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.5,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
            },
            powerText = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current_short",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
                hideIfEmpty = false,
            },
            portrait = {
                enabled = true,
                style = "3d", -- 3d, 2d, class_icon
                position = {"CENTER", "CENTER", 0, -5},
                anchorTo = "root",
                frameLevel = 5,
                width = 207,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, -5},
                anchorTo = "root",
                frameLevel = 15,
                width = 207,
                height = 20,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            combatIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMRIGHT", 1, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 10,
                height = 10,
                texture = "Combat1",
            },
            leaderIcon = {
                enabled = false,
                position = {"CENTER", "RIGHT", -1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
            },
            leaderText = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 3, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("red")}, -- class/custom
            },
            levelText = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 0, 0},
                anchorTo = "leaderText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            rangeText = {
                enabled = true,
                position = {"BOTTOM", "BOTTOM", 0, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
            },
            statusTimer = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "targetCounter",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                useEn = true,
                showLabel = true,
            },
            statusIcon = {
                enabled = true,
                position = {"TOP", "TOP", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 20,
                height = 20,
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            roleIcon = {
                enabled = false,
                position = {"CENTER", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            factionIcon = {
                enabled = true,
                position = {"CENTER", "TOPRIGHT", -1, -1},
                anchorTo = "root",
                frameLevel = 10,
                width = 16,
                height = 16,
                style = "text",
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = true,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"BOTTOMLEFT", "TOPLEFT", 0, 1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
                subFrame = {
                    enabled = true,
                    desaturated = true,
                    filter = "notCastByMe",
                    width = 17,
                    height = 17,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    targettarget = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", 52, 250},
            width = 97,
            height = 22,
            oorAlpha = 1,
            tooltip = {
                enabled = false,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 97,
                height = 19,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = false,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = false,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 97,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.9,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            levelText = {
                enabled = false,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 10, "none", true},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"LEFT", "RIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            portrait = {
                enabled = false,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                width = 97,
                height = 19,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = false,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 97,
                height = 22,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            roleIcon = {
                enabled = false,
                position = {"LEFT", "LEFT", 0, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = false,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = false,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    focus = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", 0, 276},
            width = 200,
            height = 23,
            oorAlpha = 1,
            tooltip = {
                enabled = true,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 200,
                height = 20,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 200,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.9,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"RIGHT", "RIGHT", -3, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "none",
                    percent = "current_absorbs_sum",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            levelText = {
                enabled = false,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 10, "none", true},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"LEFT", "RIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            rangeText = {
                enabled = true,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
            },
            portrait = {
                enabled = false,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                -- anchorTo = "root",
                frameLevel = 1,
                width = 200,
                height = 19,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 200,
                height = 23,
                bgColor = AW.GetColorTable("background", 0.9),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            roleIcon = {
                enabled = false,
                position = {"LEFT", "LEFT", 0, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = true,
                position = {"BOTTOMLEFT", "TOPLEFT", 0, 1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    focustarget = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", -52, 250},
            width = 97,
            height = 22,
            oorAlpha = 1,
            tooltip = {
                enabled = false,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 97,
                height = 19,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = false,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = false,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 97,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.9,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            levelText = {
                enabled = false,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 10, "none", true},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"LEFT", "RIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            portrait = {
                enabled = false,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                width = 97,
                height = 19,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = false,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 97,
                height = 22,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            roleIcon = {
                enabled = false,
                position = {"LEFT", "LEFT", 0, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = false,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = false,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    pet = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", -375, 268},
            width = 77,
            height = 31,
            oorAlpha = 0.45,
            tooltip = {
                enabled = false,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 3,
                -- orientation = "HORIZONTAL",
                width = 77,
                height = 27,
                color = {type = "custom_color", alpha = 0.6, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background", 0),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = false,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = false,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 77,
                height = 5,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.9,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"RIGHT", "RIGHT", -5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "none",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            levelText = {
                enabled = false,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 10, "none", true},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"LEFT", "RIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            portrait = {
                enabled = true,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                width = 77,
                height = 27,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 77,
                height = 27,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = false,
                enableInterruptibleCheck = false,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 3, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.7,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -3, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            combatIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMLEFT", 1, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 10,
                height = 10,
                texture = "Combat1",
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = false,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = false,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = true,
            },
        },
    },
    pettarget = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", -375, 250},
            width = 77,
            height = 17,
            oorAlpha = 0.45,
            tooltip = {
                enabled = false,
                anchorTo = "self",
                position = {"BOTTOM", "TOP", 0, 1},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 77,
                height = 17,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = false,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = false,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = false,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = false,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = false,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 1,
                -- orientation = "HORIZONTAL",
                width = 77,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = true,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.9,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"TOPRIGHT", "TOPRIGHT", -3, -4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "current_absorbs_short",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            levelText = {
                enabled = false,
                position = {"LEFT", "LEFT", 5, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 10, "none", true},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"LEFT", "RIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            portrait = {
                enabled = false,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                -- anchorTo = "root",
                frameLevel = 1,
                width = 77,
                height = 19,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
            },
            castBar = {
                enabled = false,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 15,
                width = 77,
                height = 22,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 25, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.75,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -5, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            roleIcon = {
                enabled = false,
                position = {"LEFT", "LEFT", 0, 1},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                hideDamager = false,
            },
            targetHighlight = {
                enabled = false,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = false,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = false,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = false,
                position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 11,
                numTotal = 22,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = true,
                    dispellable = true,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = false,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 5,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
            privateAuras = {
                enabled = false,
            },
        },
    },
    party = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", -550, 300},
            orientation = "bottom_to_top",
            showPlayer = false,
            spacing = 17,
            width = 140,
            height = 25,
            oorAlpha = 0.45,
            tooltip = {
                enabled = true,
                anchorTo = "self",
                position = {"LEFT", "RIGHT", 1, 0},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 3,
                -- orientation = "HORIZONTAL",
                width = 140,
                height = 20,
                color = {type = "custom_color", alpha = 0.6, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background", 0),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = true,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0},
                anchorTo = "root",
                frameLevel = 5,
                -- orientation = "HORIZONTAL",
                width = 140,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = false,
            },
            nameText = {
                enabled = true,
                position = {"LEFT", "LEFT", 3, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.5,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"RIGHT", "RIGHT", -3, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "none",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            powerText = {
                enabled = false,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = true,
                format = {
                    numeric = "current_short",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
                hideIfEmpty = false,
            },
            leaderText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -0.5},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("red")}, -- class/custom
            },
            levelText = {
                enabled = true,
                position = {"TOPLEFT", "TOPRIGHT", 0, 0},
                anchorTo = "leaderText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = false,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            statusTimer = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", 0, -1},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                useEn = true,
                showLabel = true,
            },
            portrait = {
                enabled = true,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 1,
                width = 140,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
                -- cutaway = true, --! anchorTo == "healthBar" & style == "3d"
            },
            castBar = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 5,
                width = 140,
                height = 4,
                bgColor = AW.GetColorTable("background", 0.5),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = false,
                enableInterruptibleCheck = false,
                nameText = {
                    enabled = false,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 23, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.5,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = false,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -3, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            combatIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMRIGHT", 0, 1},
                anchorTo = "healthBar",
                frameLevel = 10,
                width = 8,
                height = 8,
                texture = "Combat1",
            },
            leaderIcon = {
                enabled = false,
                position = {"CENTER", "TOPLEFT", 2, -1},
                anchorTo = "root",
                frameLevel = 10,
                width = 10,
                height = 10,
            },
            statusIcon = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 15,
                width = 16,
                height = 16,
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            readyCheckIcon = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 20,
                width = 15,
                height = 15,
            },
            roleIcon = {
                enabled = true,
                position = {"CENTER", "BOTTOMLEFT", 1, 1},
                anchorTo = "healthBar",
                frameLevel = 10,
                width = 10,
                height = 10,
                hideDamager = true,
            },
            factionIcon = {
                enabled = true,
                position = {"CENTER", "TOPLEFT", 1, -1},
                anchorTo = "root",
                frameLevel = 10,
                width = 13,
                height = 13,
                style = "text",
            },
            targetHighlight = {
                enabled = true,
                frameLevel = 1,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = true,
                frameLevel = 2,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = true,
                position = {"TOPRIGHT", "BOTTOMRIGHT", 0, -1},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "vertical",
                width = 12,
                height = 12,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 10,
                numTotal = 10,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = false,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = false,
                    castByUnit = false,
                    castByNPC = false,
                    isBossAura = false,
                    dispellable = nil,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = nil,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"TOPLEFT", "TOPRIGHT", 1, 0},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 3,
                numTotal = 6,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
        },
    },
    raid = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOMRIGHT", -5, 250},
            orientation = "top_to_bottom_then_right",
            spacingV = 3,
            spacingH = 3,
            maxColumns = 6,
            unitsPerColumn = 5,
            width = 65,
            height = 40,
            oorAlpha = 0.45,
            tooltip = {
                enabled = true,
                anchorTo = "self",
                position = {"LEFT", "RIGHT", 1, 0},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 3,
                -- orientation = "HORIZONTAL",
                width = 65,
                height = 40,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background", 0),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = false,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = true,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"CENTER", "BOTTOM", 0, 0},
                anchorTo = "root",
                frameLevel = 6,
                -- orientation = "HORIZONTAL",
                width = 49,
                height = 5,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = false,
            },
            nameText = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.75,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = false,
                position = {"TOP", "BOTTOM", 0, -1},
                anchorTo = "nameText",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "none",
                    percent = "current",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = true,
            },
            leaderIcon = {
                enabled = true,
                position = {"CENTER", "LEFT", 4, 1},
                anchorTo = "healthBar",
                frameLevel = 5,
                width = 10,
                height = 10,
            },
            statusTimer = {
                enabled = true,
                position = {"BOTTOM", "BOTTOM", 0, 4},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"Visitor", 9, "monochrome", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                useEn = true,
                showLabel = false,
            },
            statusIcon = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 5,
                width = 16,
                height = 16,
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, -3},
                anchorTo = "root",
                frameLevel = 5,
                width = 10,
                height = 10,
                style = "text",
            },
            readyCheckIcon = {
                enabled = true,
                position = {"CENTER", "CENTER", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 20,
                width = 15,
                height = 15,
            },
            roleIcon = {
                enabled = true,
                position = {"CENTER", "TOPLEFT", 4, -4},
                anchorTo = "healthBar",
                frameLevel = 5,
                width = 10,
                height = 10,
                hideDamager = true,
            },
            targetHighlight = {
                enabled = true,
                frameLevel = 4,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = true,
                frameLevel = 5,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            threatGlow = {
                enabled = true,
                size = 3,
                alpha = 1,
            },
            buffs = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "vertical",
                width = 12,
                height = 12,
                spacingH = 0,
                spacingV = 0,
                numPerLine = 4,
                numTotal = 4,
                frameLevel = 10,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = false,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = false,
                    castByUnit = false,
                    castByNPC = false,
                    isBossAura = false,
                    dispellable = nil,
                },
                mode = "whitelist",
                priorities = {},
                blacklist = {},
                whitelist = U.Copy(default_whitelist),
                auraTypeColor = {
                    castByMe = false,
                    dispellable = nil,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "vertical",
                width = 12,
                height = 12,
                spacingH = 0,
                spacingV = 0,
                numPerLine = 4,
                numTotal = 4,
                frameLevel = 10,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = false,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"Visitor", 9, "monochrome_outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = true,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = U.Copy(default_blacklist),
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
        },
    },
    boss = {
        enabled = true,
        general = {
            bgColor = AW.GetColorTable("none"),
            borderColor = AW.GetColorTable("none"),
            position = {"BOTTOM", 406, 345},
            orientation = "bottom_to_top",
            spacing = 12,
            width = 140,
            height = 25,
            oorAlpha = 0.45,
            tooltip = {
                enabled = false,
                anchorTo = "self",
                position = {"LEFT", "RIGHT", 1, 0},
            },
        },
        indicators = {
            healthBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 3,
                -- orientation = "HORIZONTAL",
                width = 140,
                height = 20,
                color = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf")},
                lossColor = {type = "custom_color", alpha = 1, rgb = AW.GetColorTable("uf_loss")},
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                mouseoverHighlight = {
                    enabled = false,
                    color = AW.GetColorTable("white", 0.05)
                },
                healPrediction = {
                    enabled = true,
                    useCustomColor = true,
                    color = AW.GetColorTable("heal_prediction"),
                },
                shield = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("shield", 0.4),
                    reverseFill = true,
                },
                overshieldGlow = {
                    enabled = true,
                    color = AW.GetColorTable("shield", 0.9),
                },
                healAbsorb = {
                    enabled = true,
                    -- texture = AW.GetTexture("Stripe"), -- no customization now
                    color = AW.GetColorTable("absorb", 0.7),
                },
                overabsorbGlow = {
                    enabled = true,
                    color = AW.GetColorTable("absorb"),
                },
                dispelHighlight = {
                    enabled = true,
                    alpha = 0.75,
                    blendMode = "ADD",
                    dispellable = true,
                },
            },
            powerBar = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0},
                anchorTo = "root",
                frameLevel = 5,
                -- orientation = "HORIZONTAL",
                width = 140,
                height = 4,
                color = {type = "class_color", alpha = 1, rgb = AW.GetColorTable("uf_power")},
                lossColor = {type = "class_color_dark", alpha = 1, rgb = AW.GetColorTable("uf")},
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                smoothing = false,
                frequent = false,
            },
            nameText = {
                enabled = true,
                position = {"LEFT", "LEFT", 3, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                length = 0.5,
                font = {"BFI", 12, "none", true},
                color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            healthText = {
                enabled = true,
                position = {"RIGHT", "RIGHT", -3, 0},
                anchorTo = "healthBar",
                parent = "healthBar",
                font = {"BFI", 12, "none", true},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
                format = {
                    numeric = "none",
                    percent = "current_absorbs_sum_decimal",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
            },
            powerText = {
                enabled = true,
                position = {"TOPRIGHT", "TOPRIGHT", -1, -0.5},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/power/custom
                frequent = false,
                format = {
                    numeric = "current_short",
                    percent = "none",
                    delimiter = " | ",
                    showPercentSign = true,
                    useAsianUnits = false,
                },
                hideIfFull = false,
                hideIfEmpty = true,
            },
            levelText = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 3, -0.5},
                anchorTo = "powerBar",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            },
            targetCounter = {
                enabled = true,
                position = {"BOTTOMLEFT", "BOTTOMRIGHT", 3, 0},
                anchorTo = "levelText",
                parent = "powerBar",
                font = {"Visitor", 9, "monochrome_outline", false},
                color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            },
            portrait = {
                enabled = false,
                style = "3d", -- 3d, 2d, class_icon
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "healthBar",
                frameLevel = 1,
                width = 140,
                height = 20,
                bgColor = AW.GetColorTable("background", 1),
                borderColor = AW.GetColorTable("border"),
                model = {
                    xOffset = 0, -- [-100, 100]
                    yOffset = 0, -- [-100, 100]
                    rotation = 0, -- [0, 360]
                    camDistanceScale = 1.75,
                },
                -- cutaway = true, --! anchorTo == "healthBar" & style == "3d"
            },
            castBar = {
                enabled = true,
                position = {"TOPLEFT", "TOPLEFT", 0, 0},
                anchorTo = "root",
                frameLevel = 5,
                width = 140,
                height = 20,
                bgColor = AW.GetColorTable("background"),
                borderColor = AW.GetColorTable("border"),
                texture = "BFI",
                fadeDuration = 1,
                showIcon = true,
                enableInterruptibleCheck = true,
                nameText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"LEFT", "LEFT", 23, 0},
                    color = AW.GetColorTable("white"),
                    length = 0.5,
                    showInterruptSource = true,
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 12, "none", true},
                    position = {"RIGHT", "RIGHT", -3, 0},
                    format = "%.1f",
                    color = AW.GetColorTable("white"),
                    showDelay = false,
                },
                spark = {
                    enabled = true,
                    texture = "plain",
                    color = AW.GetColorTable("cast_spark"),
                    width = 1,
                    height = 0,
                },
                colors = {
                    normal = AW.GetColorTable("cast_normal"),
                    failed = AW.GetColorTable("cast_failed"),
                    succeeded = AW.GetColorTable("cast_succeeded"),
                    interruptible = {
                        requireInterruptUsable = true,
                        value = AW.GetColorTable("cast_interruptible"),
                    },
                    uninterruptible = AW.GetColorTable("cast_uninterruptible"),
                    uninterruptibleTexture = AW.GetColorTable("cast_uninterruptible_texture"),
                },
            },
            raidIcon = {
                enabled = true,
                position = {"CENTER", "TOP", 1, 0},
                anchorTo = "root",
                frameLevel = 10,
                width = 12,
                height = 12,
                style = "text",
            },
            targetHighlight = {
                enabled = true,
                frameLevel = 1,
                size = 1,
                color = AW.GetColorTable("target_highlight"),
            },
            mouseoverHighlight = {
                enabled = true,
                frameLevel = 2,
                size = 1,
                color = AW.GetColorTable("mouseover_highlight"),
            },
            buffs = {
                enabled = true,
                position = {"TOPLEFT", "TOPRIGHT", 1, 0},
                anchorTo = "root",
                orientation = "left_to_right",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 3,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = true,
                    castByUnit = true,
                    castByNPC = true,
                    isBossAura = true,
                    dispellable = nil,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = nil,
                    debuffType = nil,
                },
            },
            debuffs = {
                enabled = true,
                position = {"TOPRIGHT", "TOPLEFT", -1, 0},
                anchorTo = "root",
                orientation = "right_to_left",
                cooldownStyle = "none",
                width = 19,
                height = 19,
                spacingH = 1,
                spacingV = 1,
                numPerLine = 3,
                numTotal = 3,
                frameLevel = 1,
                tooltip = {
                    enabled = true,
                    anchorTo = "self",
                    position = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                },
                durationText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"TOP", "TOP", 1, 0},
                    color = {
                        AW.GetColorTable("white"), -- normal
                        {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                        {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                    },
                },
                stackText = {
                    enabled = true,
                    font = {"BFI", 10, "outline", false},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 3, -1},
                    color = AW.GetColorTable("white"),
                },
                filters = {
                    castByMe = true,
                    castByOthers = false,
                    castByUnit = false,
                    castByNPC = false,
                    isBossAura = false,
                    dispellable = false,
                },
                mode = "blacklist",
                priorities = {},
                blacklist = {},
                whitelist = {},
                auraTypeColor = {
                    castByMe = false,
                    dispellable = true,
                    debuffType = true,
                },
            },
        },
    },
}

BFI.RegisterCallback("UpdateConfigs", "UnitFrames", function(t)
    if not t["unitFrames"] then
        t["unitFrames"] = U.Copy(defaults)
    end
    UF.config = t["unitFrames"]
end)

function UF.GetDefaults()
    return U.Copy(defaults)
end