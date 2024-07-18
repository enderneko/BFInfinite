---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.M_NP

local defaults = {
    enabled = true,
    occludedAlpha = 0.4,
    -- nameplateSelectedScale
    hostile = {
        -- castOnMe
        threat = {

        },
    },
    friendly = {

    },
    playersInInstance = {
        -- modify some cvars
    },
    customs = {},
}

do
    local nameplateDefaults = {
        clickableAreaWidth = 120,
        clickableAreaHeight = 40,
        healthBar = {
            enabled = true,
            position = {"CENTER", "CENTER", 0, 0},
            width = 125,
            height = 13,
            bgColor = AW.GetColorTable("background", 0.75),
            borderColor = AW.GetColorTable("border"),
            colorByClass = true,
            colorByThreat = true,
            colorByMarker = true,
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
        },
        nameText = {
            enabled = true,
            position = {"BOTTOM", "TOP", 0, 1},
            anchorTo = "healthBar",
            length = 1,
            font = {"BFI 1", 13, "none", true},
            color = {type = "custom_color", rgb = AW.GetColorTable("white")}, -- class/custom
        },
        healthText = {

        },
        levelText = {

        },
        raidIcon = {

        },
        classIcon = {

        },
        castBar = {
            enabled = true,
            position = {"TOP", "BOTTOM", 0, -2},
            anchorTo = "healthBar",
            width = 125,
            height = 15,
            bgColor = AW.GetColorTable("background", 0.75),
            borderColor = AW.GetColorTable("border"),
            texture = "BFI 1",
            fadeDuration = 1,
            icon = {
                enabled = true,
                position = {"BOTTOMRIGHT", "BOTTOMLEFT", -2, 0},
                width = 25,
                height = 25
            },
            nameText = {
                enabled = true,
                font = {"BFI 1", 11, "none", true},
                position = {"LEFT", "LEFT", 3, 0},
                color = AW.GetColorTable("white"),
                length = 0.75,
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
        buffs = {

        },
        debuffs = {

        },
        crowdControls = {

        },
        quest = {

        },
    }

    U.Merge(defaults.hostile, nameplateDefaults)
    defaults.friendly = U.Copy(nameplateDefaults)
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