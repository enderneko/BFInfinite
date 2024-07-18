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
        width = 110,
        height = 10,
        insetX = 10,
        insetY = 20,
        healthBar = {
            enabled = true,
            position = {"CENTER", "CENTER", 0, 0},
            width = 110,
            height = 10,
            bgColor = AW.GetColorTable("background"),
            borderColor = AW.GetColorTable("border"),
            colorByClass = true,
            colorByThreat = true,
            texture = "BFI 1",
            mouseoverHighlight = {
                enabled = true,
                color = AW.GetColorTable("white", 0.1)
            },
            shield = {
                enabled = true,
                color = AW.GetColorTable("shield", 0.4),
                reverseFill = true,
            },
            overshieldGlow = {
                enabled = true,
                color = AW.GetColorTable("shield"),
            },
        },
        nameText = {

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