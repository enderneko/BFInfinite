---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.M_NamePlates

local defaults = {
    enabled = true,
    friendlyClickableAreaWidth = 120,
    friendlyClickableAreaHeight = 40,
    hostileClickableAreaWidth = 120,
    hostileClickableAreaHeight = 40,
    cvars = {

    },
    alphas = {
        -- overwrite others
        occluded = {enabled = true, value = 0.4},
        mouseover = {enabled = true, value = 1},
        marked = {enabled = true, value = 1},
        casting = {enabled = true, value = 1},
        -- target
        target = {enabled = true, value = 1},
        non_target = {enabled = true, value = 0.8},
        no_target = {enabled = false, value = 0.5},
        -- type
        player = 1,
        pet = 1,
        guardian = 1,
        npc = 1,
        -- classification
        boss = 1,
        rare = 1,
        elite = 1,
        minor = 1,
        totem = 1,
    },
    scales = {
        animatedScaling = true,
        -- overwrite others
        -- occluded = {enabled = true, value = 0.4},
        mouseover = {enabled = false, value = 1},
        marked = {enabled = false, value = 1},
        casting = {enabled = false, value = 1},
        -- target
        target = {enabled = false, value = 1},
        non_target = {enabled = false, value = 1},
        no_target = {enabled = false, value = 1},
        -- type
        player = 1,
        pet = 1,
        guardian = 1,
        npc = 1,
        -- classification
        boss = 1,
        rare = 1,
        elite = 1,
        minor = 1,
        totem = 1,
    },
    playersInInstance = {
        -- modify some cvars
    },
    customs = {},
    performanceModeUnits = {
        tapDenied = true,
        customs = {},
    }
}

do
    local nameplateDefaults = {
        healthBar = {
            enabled = true,
            position = {"CENTER", "CENTER", 0, 0},
            frameLevel = 1,
            width = 120,
            height = 13,
            colorByClass = true,
            colorByThreat = true,
            colorByMarker = true,
            colorAlpha = 1,
            lossColor = {
                useDarkerForground = false,
                alpha = 0.5,
                rgb = AW.GetColorTable("black")
            },
            bgColor = AW.GetColorTable("background", 0),
            borderColor = AW.GetColorTable("border"),
            texture = "BFI 1",
            mouseoverHighlight = {
                enabled = true,
                color = AW.GetColorTable("white", 0.1)
            },
            shield = {
                enabled = true,
                color = AW.GetColorTable("shield", 0.5),
                reverseFill = true,
            },
            overshieldGlow = {
                enabled = true,
                color = AW.GetColorTable("shield"),
            },
            thresholds = {
                enabled = false,
                width = 7,
                height = 25,
                values = { --! must be descending sorted
                    {value = 0.3, color = AW.GetColorTable("gold")},
                },
            },
            threatGlow = {
                enabled = true,
                size = 5,
                alpha = 1,
            },
        },
        nameText = {
            enabled = true,
            position = {"BOTTOM", "TOP", 0, 1},
            anchorTo = "healthBar",
            length = 1,
            font = {"BFI 1", 12, "none", true},
            color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
        },
        healthText = {
            enabled = true,
            position = {"CENTER", "CENTER", -5, 0},
            anchorTo = "healthBar",
            font = {"BFI 1", 11, "none", true},
            color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
            format = {
                numeric = "current_short",
                percent = "current",
                delimiter = " - ",
                noPercentSign = false,
                useAsianUnits = false,
            },
            hideIfFull = true,
        },
        levelText = {
            enabled = true,
            position = {"RIGHT", "RIGHT", -5, 0},
            anchorTo = "healthBar",
            font = {"BFI 1", 11, "none", true},
            color = {type = "level_color", rgb = AW.GetColorTable("white")}, -- level/class/custom
            highLevelTexture = {
                enabled = true,
                size = 16,
            },
        },
        castBar = {
            enabled = true,
            position = {"TOP", "BOTTOM", 0, -2},
            anchorTo = "healthBar",
            frameLevel = 3,
            width = 120,
            height = 13,
            bgColor = AW.GetColorTable("background", 0.75),
            borderColor = AW.GetColorTable("border"),
            texture = "BFI 1",
            fadeDuration = 1,
            icon = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMLEFT", -2, 0},
                width = 18,
                height = 18
            },
            nameText = {
                enabled = true,
                font = {"BFI 1", 11, "none", true},
                position = {"LEFT", "LEFT", 3, 0},
                color = AW.GetColorTable("white"),
                length = 0.75,
                showInterruptSource = true,
            },
            durationText = {
                enabled = true,
                font = {"BFI 1", 11 , "none", true},
                position = {"RIGHT", "RIGHT", -3, 0},
                format = "%.1f",
                color = AW.GetColorTable("white"),
            },
            spark = {
                enabled = true,
                texture = AW.GetPlainTexture(),
                color = AW.GetColorTable("cast_spark"),
                width = 1,
                height = 0,
            },
            colors = {
                normal = AW.GetColorTable("cast_normal"),
                failed = AW.GetColorTable("cast_failed"),
                succeeded = AW.GetColorTable("cast_succeeded"),
                uninterruptible = AW.GetColorTable("cast_uninterruptible"),
            },
        },
        raidIcon = {
            enabled = true,
            position = {"RIGHT", "LEFT", -2, 0},
            anchorTo = "healthBar",
            frameLevel = 2,
            width = 16,
            height = 16,
        },
        classIcon = {
            enabled = false,
            position = {"RIGHT", "TOPRIGHT", 0, 0},
            anchorTo = "healthBar",
            frameLevel = 2,
            width = 16,
            height = 16,
        },
    }

    local hostile = {
        -- castOnMe
        buffs = {
            enabled = true,
            position = {"BOTTOM", "TOP", 0, 10},
            anchorTo = "debuffs",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 23,
            height = 23,
            spacingH = 3,
            spacingV = 6,
            numPerLine = 5,
            numTotal = 5,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 12, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 12, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
                color = AW.GetColorTable("white"),
            },
            filters = {
                castByMe = false,
                castByOthers = false,
                castByUnit = false,
                castByNPC = false,
                isBossAura = false,
                dispellable = true,
                canBeDispelled = true,
            },
            blockers = {},
            priorities = {},
            blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = true,
                debuffType = false,
            },
            glowDispellableByMe = true,
        },
        debuffs = {
            enabled = true,
            position = {"BOTTOM", "TOP", 0, 18},
            anchorTo = "healthBar",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 25,
            height = 15,
            spacingH = 3,
            spacingV = 6,
            numPerLine = 4,
            numTotal = 8,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
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
            blockers = {
                crowdControlType = true,
            },
            priorities = {},
            blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = false,
                debuffType = false,
            },
        },
        crowdControls = {
            enabled = true,
            position = {"BOTTOM", "TOP", 0, 15},
            anchorTo = "buffs",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 40,
            height = 24,
            spacingH = 5,
            spacingV = 10,
            numPerLine = 3,
            numTotal = 3,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 13, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 13, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
                color = AW.GetColorTable("white"),
            },
            crowdControlTypes = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true,
                [7] = true,
                [8] = true,
                [9] = true,
                [10] = true,
                [11] = true,
                [12] = true,
                [13] = true,
                [14] = false,
                [15] = false,
                [99] = true,
            },
            -- filters = {},
            -- blockers = {},
            -- priorities = {},
            -- blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = false,
                debuffType = false,
            },
        },
    }

    local hostile_npc = {
        rareIndicator = {
            enabled = true,
            position = {"RIGHT", "TOPRIGHT", 0, 0},
            anchorTo = "healthBar",
            frameLevel = 2,
            color = AW.GetColorTable("white"),
            width = 16,
            height = 16,
        },
        questIndicator = {
            enabled = true,
            position = {"LEFT", "RIGHT", 0, 0},
            anchorTo = "healthBar",
            frameLevel = 2,
            width = 18,
            height = 18,
            hideInInstance = true,
        }
    }

    local friendly = {
        nameText = {
            enabled = true,
            position = {"CENTER", "CENTER", 0, -10},
            anchorTo = "nameplate",
            length = 0,
            font = {"BFI 1", 13, "outline", false},
            color = {type = "class_color", rgb = AW.GetColorTable("white")}, -- class/custom
            showOtherServerSign = true,
        },
        buffs = {
            enabled = false,
            position = {"BOTTOM", "TOP", 0, 10},
            anchorTo = "debuffs",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 23,
            height = 23,
            spacingH = 3,
            spacingV = 6,
            numPerLine = 5,
            numTotal = 5,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
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
            blockers = {},
            priorities = {},
            blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = false,
                debuffType = false,
            },
        },
        debuffs = {
            enabled = false,
            position = {"BOTTOM", "TOP", 0, 18},
            anchorTo = "healthBar",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 25,
            height = 15,
            spacingH = 3,
            spacingV = 6,
            numPerLine = 4,
            numTotal = 8,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
                color = AW.GetColorTable("white"),
            },
            filters = {
                castByMe = false,
                castByOthers = false,
                castByUnit = false,
                castByNPC = false,
                isBossAura = false,
                dispellable = true,
            },
            blockers = {
                crowdControlType = true,
            },
            priorities = {},
            blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = true,
                debuffType = false,
            },
        },
        crowdControls = {
            enabled = false,
            position = {"BOTTOM", "TOP", 0, 15},
            anchorTo = "buffs",
            orientation = "left_to_right",
            cooldownStyle = "none",
            width = 45,
            height = 25,
            spacingH = 3,
            spacingV = 6,
            numPerLine = 3,
            numTotal = 3,
            frameLevel = 2,
            durationText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "TOPRIGHT", 0, -2},
                color = {
                    AW.GetColorTable("white"), -- normal
                    {false, 0.5, AW.GetColorTable("aura_percent")}, -- less than 50%
                    {true,  5,   AW.GetColorTable("aura_seconds")}, -- less than 5sec
                },
            },
            stackText = {
                enabled = true,
                font = {"BFI 1", 10, "outline", false},
                position = {"RIGHT", "BOTTOMRIGHT", 0, 2},
                color = AW.GetColorTable("white"),
            },
            crowdControlTypes = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true,
                [7] = true,
                [8] = true,
                [9] = true,
                [10] = true,
                [11] = true,
                [12] = true,
                [13] = true,
                [14] = false,
                [15] = false,
                [99] = true,
            },
            -- filters = {},
            -- blockers = {},
            -- priorities = {},
            -- blacklist = {},
            auraTypeColor = {
                castByMe = false,
                dispellable = false,
                debuffType = false,
            },
        },
    }

    -- hostile
    defaults.hostile_npc = U.Copy(nameplateDefaults, hostile, hostile_npc)
    defaults.hostile_player = U.Copy(nameplateDefaults, hostile)

    -- friendly
    defaults.friendly_npc = U.Copy(nameplateDefaults, friendly)
    defaults.friendly_player = U.Copy(nameplateDefaults, friendly)

    -- update friendly_npc
    for n, t in pairs(defaults.friendly_npc) do
        t.enabled = n == "nameText"
    end

    -- update friendly_player
    for n, t in pairs(defaults.friendly_player) do
        t.enabled = n == "nameText"
    end
end

local customDefaults = {
    trigger = "npcName",
    hide = false,
    scale = {
        enabled = false,
        value = 1,
    },
    color = {
        enabled = false,
        value = AW.GetColorTable("white"),
    },
    glow = {
        enabled = false,
        color = AW.GetColorTable("yellow"),
    },
    texture = {
        enabled = false,
        width = 32,
        height = 32,
        useCustom = false,
        path = "star",
    },
}

BFI.RegisterCallback("UpdateConfigs", "Nameplates", function(t)
    if not t["nameplates"] then
        t["nameplates"] = U.Copy(defaults)
    end
    NP.config = t["nameplates"]
end)

function NP.GetDefaults()
    return U.Copy(defaults)
end

function NP.GetNameplateDefaults()
    return U.Copy(nameplateDefaults)
end