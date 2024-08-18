---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- BFI default cvar values
---------------------------------------------------------------------
-- nameplateShowSelf = 1
-- NameplatePersonalShowAlways = 0
-- NameplatePersonalShowInCombat = 1
-- NameplatePersonalShowWithTarget = 0
local CVAR_DEFAULTS = {
    -- nameOnly
    nameplateShowOnlyNames = 1,
    -- color
    ShowClassColorInNameplate = 1,
    ShowClassColorInFriendlyNameplate = 1,
    nameplateOtherAtBase = 0,
    -- scale
    nameplateGlobalScale = 1.0,
    nameplateLargerScale = 1.0,
    NamePlateHorizontalScale = 1.0,
    NamePlateVerticalScale = 1.0,
    nameplateMaxScale = 1.0,
    nameplateMinScale = 1.0,
    nameplateSelectedScale = 1.0,
    --! overlap: the smaller the number, the more it overlaps
    nameplateOverlapH = 0.5,
    nameplateOverlapV = 0.5,
    -- motion
    nameplateMotion = 1,
    nameplateMotionSpeed = 0.025,
    -- distance
    nameplateMaxDistance = 45,
    nameplateTargetBehindMaxDistance = 15, --? what's this cvar for?
    -- inset
    nameplateTargetRadialPosition = 1, --? 1 & 2 seems the
    nameplateLargeTopInset = 0.2,
    nameplateLargeBottomInset = 0.2,
    nameplateOtherTopInset = 0.08,
    nameplateOtherBottomInset = -1,
}

function NP.GetCVarDefaults()
    return CVAR_DEFAULTS
end

---------------------------------------------------------------------
-- defaults
---------------------------------------------------------------------
local defaults = {
    enabled = true,
    friendlyClickableAreaWidth = 120,
    friendlyClickableAreaHeight = 40,
    hostileClickableAreaWidth = 120,
    hostileClickableAreaHeight = 40,
    cvars = nil,
    alphas = {
        -- base
        occluded = {enabled = true, value = 0.4},
        focus = {enabled = true, value = 1},
        target = {enabled = true, value = 1},
        marked = {enabled = true, value = 1},
        casting = {enabled = true, value = 1},
        mouseover = {enabled = true, value = 1},
        non_target = {enabled = true, value = 0.8},
        no_target = {enabled = false, value = 0.5},
        -- type (multiplier)
        player = 1,
        pet = 1,
        guardian = 1,
        npc = 1, -- classification == normal
        -- classification (multiplier)
        boss = 1,
        rare = 1,
        elite = 1,
        minor = 1,
        totem = 1,
    },
    scales = {
        animatedScaling = true,
        -- base
        -- occluded = {enabled = true, value = 0.4},
        focus = {enabled = false, value = 1},
        target = {enabled = false, value = 1},
        marked = {enabled = false, value = 1},
        casting = {enabled = false, value = 1},
        mouseover = {enabled = false, value = 1},
        non_target = {enabled = false, value = 1},
        no_target = {enabled = false, value = 1},
        -- type (multiplier)
        player = 1,
        pet = 1,
        guardian = 1,
        npc = 1, -- classification == normal
        -- classification (multiplier)
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
    defaults.cvars = U.Copy(NP.GetCVarDefaults())

    local nameplateDefaults = {
        healthBar = {
            enabled = true,
            position = {"CENTER", "CENTER", 0, 0},
            anchorTo = "nameplate",
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
                color = AW.GetColorTable("shield", 0.6),
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
                size = 4,
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
            position = {"RIGHT", "LEFT", -2, 0},
            anchorTo = "healthBar",
            frameLevel = 2,
            width = 13,
            height = 13,
            style = "text",
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