local _, BFI = ...
local AW = BFI.AW
local U = BFI.utils
local AB = BFI.M_AB

local defaults = {
    general = {
        frameLevel = 1,
        frameStrata = "LOW",
        flyoutSize = 32,
    },
    barConfig = {
        bar1 = {enabled = true, position = "BOTTOM,0,50"},
        bar2 = {enabled = true, position = "BOTTOM,0,90"},
        bar3 = {enabled = true, position = "BOTTOM,0,130"},
        bar4 = {enabled = false, position = "BOTTOM,0,170"},
        bar5 = {enabled = false, position = "BOTTOM,0,210"},
        bar6 = {enabled = false, position = "BOTTOM,0,250"},
        bar7 = {enabled = false, position = "BOTTOM,0,290"},
        bar8 = {enabled = false, position = "BOTTOM,0,330"},
        bar9 = {enabled = false, position = "BOTTOM,0,370"},
        classbar1 = {enabled = false, position = "BOTTOM,0,410"},
        classbar2 = {enabled = false, position = "BOTTOM,0,450"},
        classbar3 = {enabled = false, position = "BOTTOM,0,450"},
        classbar4 = {enabled = false, position = "BOTTOM,0,450"},
        stancebar = {enabled = true, position = "BOTTOM,0,170"},
        petbar = {enabled = true, position = "BOTTOM,0,210"},
    },
    sharedButtonConfig = {
        lock = true,
        targetReticle = true,
        interruptDisplay = true,
        spellCastAnim = true,
        autoAddNewSpells = true, -- TODO:
        pickUpKey = "SHIFT",
        outOfRangeColoring = "button",
        colors = {
            range = {0.8, 0.1, 0.1},
            mana = {0.5, 0.5, 1.0},
            equipped = {0.4, 1, 0.4},
        },
        hideElements = {
            equipped = false,
        },
        glow = {
            style = "Proc Glow",
            color = nil,
            frameLevel = 7,
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
        size = 32,
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
                    font = {font = AW.GetFont("visitor"), size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "TOPRIGHT", offsetX = 0, offsetY = 0}
                },
                count = {
                    font = {font = AW.GetFont("visitor"), size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMRIGHT", offsetX = 0, offsetY = 0}
                },
                macro = {
                    font = {font = AW.GetFont("visitor"), size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMLEFT", offsetX = 0, offsetY = 0}
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

        -- others
        if bar == "stancebar" then
            t.num = 10
            t.buttonsPerLine = 10
            t.buttonConfig = {
                hideElements = {
                    hotkey = false,
                },
                text = {
                    hotkey = {
                        font = {font = AW.GetFont("visitor"), size = 10, flags = "OUTLINE,MONOCHROME"},
                        color = {1, 1, 1},
                        position = {anchor = "TOPRIGHT", offsetX = 0, offsetY = 0}
                    },
                },
            }
        elseif bar == "petbar" then
            t.num = 10
            t.buttonsPerLine = 10
        end
    end
end

BFI.RegisterCallback("InitConfigs", "ActionBars", function(t)
    if not t["actionBars"] then
        t["actionBars"] = U.Copy(defaults)
    end
end)

function AB.GetDefaults()
    return U.Copy(defaults)
end