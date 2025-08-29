---@class BFI
local BFI = select(2, ...)
---@class ActionBars
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    general = {
        enabled = true,
        frameLevel = 1,
        frameStrata = "LOW",
        flyoutSize = {32, 16},
        disableAutoAddSpells = true,
        tooltip = {
            enabled = true,
            hideInCombat = false,
            anchorTo = "self_adaptive", -- self / self_adaptive / default
            position = {"BOTTOMLEFT", "TOPLEFT", 0, 1},
            supportsItemComparison = false, -- not configurable for now
        },
    },
    assistant = {
        highlight = GetCVarBool("assistedCombatHighlight"),
        style = "Nyan_Cat",
        position = "default",
        size = 0.8,
    },
    barConfig = {
        bar1 = {enabled = true, position = {"BOTTOM", 0, 8}},
        bar2 = {enabled = true, position =  {"BOTTOM", 0, 43}},
        bar3 = {enabled = true, position =  {"BOTTOM", 0, 78}},
        bar4 = {enabled = true, position =  {"BOTTOM", -272, 8}},
        bar5 = {enabled = true, position =  {"BOTTOM", 272, 8}},
        bar6 = {enabled = true, position =  {"BOTTOM", 394, 8}},
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
        pickUpKey = "SHIFT",
        targetReticle = true,
        interruptDisplay = true,
        spellCastAnim = true,
        -- desaturateOnCooldown = true,
        outOfRangeColoring = "button",
        colors = {
            range = {0.8, 0.3, 0.3},
            notUsable = {0.4, 0.4, 0.4},
            mana = {0.5, 0.5, 1.0},
            equippedBorder = {0.3, 0.8, 0.3},
            macroBorder = {0.8, 0.3, 0.8},
        },
        hideElements = {
            equippedBorder = false,
            macroBorder = false,
        },
        glow = { -- not configurable for now
            style = "proc",
            color = nil,
            duration = 1,
            startAnim = true,
        },
        cast = {
            self = true, -- checkselfcast, SetCVar("autoSelfCast"), no change for ModifiedClick "SELFCAST"
            mouseover = {false, "NONE"}, -- checkmouseovercast, SetCVar("enableMouseoverCast"), ModifiedClick "MOUSEOVERCAST"
            focus = {false, "CTRL"}, -- checkfocuscast, ModifiedClick "FOCUSCAST"
        },
    },
    vehicleExitButton = {
        enabled = true,
        position =  {"BOTTOM", 88, 117},
        size = 33,
    },
    extraAbilityButtons = {
        enabled = true,
        zoneAbility = {
            position =  {"BOTTOM", -351, 155},
            scale = 0.63,
            hideTexture = true,
        },
        extraAction = {
            position =  {"BOTTOM", 0, 160},
            scale = 0.8,
            hideTexture = false,
            hotkey = {
                font = {"BFI", 12, "outline", false},
                color = {1, 1, 1},
                position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
            },
        },
    },
}

do
    -- fill bar options
    local barDefaults = {
        alpha = 1,
        orientation = "left_to_right_then_bottom",
        width = 33,
        height = 33,
        spacingX = 2,
        spacingY = 2,
        num = 12,
        buttonsPerLine = 12,
        buttonConfig = {
            showGrid = true,
            flyoutDirection = "UP",
            hideElements = {
                hotkey = false,
                macro = false,
            },
            text = {
                hotkey = {
                    font = {"BFI", 10, "outline", false},
                    color = {1, 1, 1},
                    position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
                },
                count = {
                    font = {"BFI", 10, "outline", false},
                    color = {1, 1, 1},
                    position = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 1},
                },
                macro = {
                    font = {"BFI", 10, "outline", false},
                    color = {1, 1, 1},
                    position = {"BOTTOMLEFT", "BOTTOMLEFT", 0, 1},
                },
            },
        },
    }

    for bar, t in pairs(defaults.barConfig) do
        AF.Merge(t, barDefaults)

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
                PRIEST = "[bonusbar:1] 7;"..(AF.isVanilla and " [possessbar] 16;" or "").." 1",
                ROGUE = "[bonusbar:1] 7;"..(AF.isCata and " [bonusbar:2] 8;" or "").." 1",
                WARLOCK = AF.isCata and "[form:1] 7; 1" or "1",
                WARRIOR = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9; 1",
            }
        else
            t.paging = {}
        end

        -- others
        if bar == "bar4" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.width, t.height = 28, 28
        elseif bar == "bar5" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.width, t.height = 28, 28
        elseif bar == "bar6" then
            t.alpha = 0.75
            t.buttonsPerLine = 4
            t.width, t.height = 28, 28
        elseif bar == "bar7" then
            t.num = 3
        elseif bar == "stancebar" then
            t.num = 7
            t.buttonsPerLine = 10
            t.width, t.height = 26, 26
            t.buttonConfig = {
                hideElements = {
                    hotkey = false,
                },
                text = {
                    hotkey = {
                        font = {"BFI", 10, "outline", false},
                        color = {1, 1, 1},
                        position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
                    },
                },
            }
        elseif bar == "petbar" then
            t.num = 10
            t.buttonsPerLine = 5
            t.width, t.height = 22, 22
            t.buttonConfig = {
                showGrid = true,
                hideElements = {
                    hotkey = false,
                },
                text = {
                    hotkey = {
                        font = {"BFI", 10, "outline", false},
                        color = {1, 1, 1},
                        position = {"TOPRIGHT", "TOPRIGHT", 0, 0},
                    },
                },
            }
        end
    end
end

AF.RegisterCallback("BFI_UpdateProfile", function(_, t)
    if not t["actionBars"] then
        t["actionBars"] = AF.Copy(defaults)
    end
    AB.config = t["actionBars"]
end)

function AB.GetDefaults()
    return AF.Copy(defaults)
end

function AB.Reset()
    BFI.vars.profile.actionBars = AF.Copy(defaults)
    AB.config = BFI.vars.profile.actionBars
end

function AB.ResetGeneralAndShared()
    wipe(AB.config.general)
    wipe(AB.config.sharedButtonConfig)
    AF.Merge(AB.config.general, AF.Copy(defaults.general))
    AF.Merge(AB.config.sharedButtonConfig, AF.Copy(defaults.sharedButtonConfig))
end

function AB.ResetBar(bar)
    wipe(AB.config.barConfig[bar])
    AF.Merge(AB.config.barConfig[bar], AF.Copy(defaults.barConfig[bar]))
end

function AB.ResetVehicle()
    wipe(AB.config.vehicleExitButton)
    AF.Merge(AB.config.vehicleExitButton, AF.Copy(defaults.vehicleExitButton))
end

function AB.ResetExtra()
    wipe(AB.config.extraAbilityButtons)
    AF.Merge(AB.config.extraAbilityButtons, AF.Copy(defaults.extraAbilityButtons))
end

function AB.ResetVisibility(bar)
    AB.config.barConfig[bar].visibility = defaults.barConfig[bar].visibility
end

function AB.ResetPaging(bar, class)
    AB.config.barConfig[bar].paging[class] = defaults.barConfig[bar].paging[class]
end