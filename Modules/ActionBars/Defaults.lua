---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local AB = BFI.ActionBars

local defaults = {
    general = {
        enabled = true,
        frameLevel = 1,
        frameStrata = "LOW",
        flyoutSize = 32,
    },
    barConfig = {
        bar1 = {enabled = true, position = {"BOTTOM", 0, 10}},
        bar2 = {enabled = true, position =  {"BOTTOM", 0, 45}},
        bar3 = {enabled = true, position =  {"BOTTOM", 0, 80}},
        bar4 = {enabled = true, position =  {"BOTTOM", -272, 10}},
        bar5 = {enabled = true, position =  {"BOTTOM", 272, 10}},
        bar6 = {enabled = true, position =  {"BOTTOM", 394, 10}},
        bar7 = {enabled = true, position =  {"BOTTOM", 158, 117}},
        bar8 = {enabled = false, position =  {"BOTTOM", 0, 290}},
        bar9 = {enabled = false, position =  {"BOTTOM", 0, 330}},
        classbar1 = {enabled = false, position =  {"BOTTOM", 0, 370}},
        classbar2 = {enabled = false, position =  {"BOTTOM", 0, 410}},
        classbar3 = {enabled = false, position =  {"BOTTOM", 0, 450}},
        classbar4 = {enabled = false, position =  {"BOTTOM", 0, 490}},
        stancebar = {enabled = true, position =  {"BOTTOM", -112, 117}},
        petbar = {enabled = true, position =  {"BOTTOM", -272, 102}},
    },
    sharedButtonConfig = {
        lock = true,
        targetReticle = true,
        interruptDisplay = true,
        spellCastAnim = true,
        -- autoAddNewSpells = true, -- TODO:
        pickUpKey = "SHIFT",
        outOfRangeColoring = "button",
        desaturateOnCooldown = true,
        colors = {
            range = {0.8, 0.3, 0.3},
            mana = {0.5, 0.5, 1.0},
            equipped = {0.3, 0.8, 0.3},
            macro = {0.8, 0.3, 0.8},
            notUsable = {0.4, 0.4, 0.4},
        },
        hideElements = {
            equipped = false,
        },
        glow = {
            -- style = "pixel",
            style = "proc",
            color = nil,
            duration = 1,
            startAnim = true,
        },
        casting = {
            self = {true, GetCVarBool("autoSelfCast")}, -- checkselfcast, GetCVarBool("autoSelfCast")
            mouseover = {GetCVarBool("enableMouseoverCast"), Settings.GetValue("MOUSEOVERCAST")}, -- checkmouseovercast, Settings.GetValue("MOUSEOVERCAST")
            -- focus = {false, "ALT"}, -- FIXME: invalid
        },
    },
}

do
    -- fill bar options
    local barDefaults = {
        alpha = 1,
        anchor = "TOPLEFT",
        orientation = "horizontal",
        size = 33,
        spacing = 2,
        num = 12,
        buttonsPerLine = 12,
        buttonConfig = {
            showGrid = true,
            flyoutDirection = "UP",
            hideElements = {
                macro = false,
                hotkey = false,
                count = false,
            },
            text = {
                hotkey = {
                    font = {font = AW.GetFont("Noto_AP_SC"), size = 10, flags = "OUTLINE"},
                    color = {1, 1, 1},
                    position = {anchor = "TOPRIGHT", relAnchor = "TOPRIGHT", offsetX = 0, offsetY = 0},
                    justifyH = "RIGHT",
                    shadow = false,
                },
                count = {
                    font = {font = AW.GetFont("Noto_AP_SC"), size = 10, flags = "OUTLINE"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMRIGHT", relAnchor = "BOTTOMRIGHT", offsetX = 0, offsetY = 1},
                    justifyH = "RIGHT",
                    shadow = false,
                },
                macro = {
                    font = {font = AW.GetFont("Noto_AP_SC"), size = 10, flags = "OUTLINE"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMLEFT", relAnchor = "BOTTOMLEFT", offsetX = -2, offsetY = 0},
                    justifyH = "CENTER",
                    shadow = false,
                },
            },
        },
    }

    for bar, t in pairs(defaults.barConfig) do
        U.Merge(t, barDefaults)

        -- visibility
        if bar == "bar1" then
            t.visibility = "[petbattle] hide; show"
        elseif bar == "petbar" then
            t.visibility = "[petbattle] hide; [novehicleui,pet,nooverridebar,nopossessbar] show; hide"
        else
            t.visibility = "[vehicleui][petbattle][overridebar] hide; show"
        end

        -- paging (class-specific)
        if bar == "bar1" then
            t.paging = {
                DRUID = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10; 1",
                EVOKER = "[bonusbar:1] 7; 1",
                PRIEST = "[bonusbar:1] 7;"..(BFI.vars.isVanilla and " [possessbar] 16;" or "").." 1",
                ROGUE = "[bonusbar:1] 7;"..(BFI.vars.isCata and " [bonusbar:2] 8;" or "").." 1",
                WARLOCK = BFI.vars.isCata and "[form:1] 7; 1" or "1",
                WARRIOR = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9; 1",
            }
        else
            t.paging = {}
        end

        -- others
        if bar == "bar4" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.size = 28
        elseif bar == "bar5" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.size = 28
        elseif bar == "bar6" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.size = 28
        elseif bar == "bar7" then
            t.num = 3
            -- t.size = 28
        elseif bar == "stancebar" then
            t.num = 7
            t.buttonsPerLine = 10
            t.size = 26
            t.buttonConfig = {
                hideElements = {
                    hotkey = false,
                },
                text = {
                    hotkey = {
                        font = {font = AW.GetFont("Noto_AP_SC"), size = 10, flags = "OUTLINE"},
                        color = {1, 1, 1},
                        position = {anchor = "TOPRIGHT", relAnchor = "TOPRIGHT", offsetX = 0, offsetY = 0}
                    },
                },
            }
        elseif bar == "petbar" then
            t.num = 10
            t.buttonsPerLine = 5
            t.size = 22
        end
    end
end

BFI.RegisterCallback("UpdateConfigs", "ActionBars", function(t)
    if not t["actionBars"] then
        t["actionBars"] = U.Copy(defaults)
    end
    AB.config = t["actionBars"]
end)

function AB.GetDefaults()
    return U.Copy(defaults)
end