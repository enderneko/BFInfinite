local _, BFI = ...
local U = BFI.utils

local defaults = {
    general = {
        frameLevel = 1,
        frameStrata = "LOW",
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
        bar10 = {enabled = false, position = "BOTTOM,0,410"},
        bar13 = {enabled = false, position = "BOTTOM,0,450"},
        bar14 = {enabled = false, position = "BOTTOM,0,450"},
        bar15 = {enabled = false, position = "BOTTOM,0,450"},
    },
    sharedButtonConfig = {
        lock = true,
        targetReticle = true,
        interruptDisplay = true,
        spellCastAnim = true,
        autoAddNewSpells = true, -- TODO:
        pickUpKey = "SHIFT",
        outOfRangeColoring = "button",
        desaturate = true,
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
        orientation = "horizontal",
        size = 32,
        spacing = 2,
        num = 12,
        buttonsPerLine = 12,
        flyoutDirection = "auto",
        buttonConfig = {
            showGrid = true,
            hideElements = {
                macro = false,
                hotkey = false,
                count = false,
            },
            text = {
                hotkey = {
                    font = {font = "visitor", size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "TOPRIGHT", offsetX = 0, offsetY = 0}
                },
                count = {
                    font = {font = "visitor", size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMRIGHT", offsetX = 0, offsetY = 0}
                },
                macro = {
                    font = {font = "visitor", size = 10, flags = "OUTLINE,MONOCHROME"},
                    color = {1, 1, 1},
                    position = {anchor = "BOTTOMLEFT", offsetX = 0, offsetY = 0}
                },
            },
        },
    }

    for _, t in pairs(defaults.barConfig) do
        U.Merge(t, barDefaults)
    end
end

BFI.RegisterCallback("InitConfigs", "ActionBars", function(t)
    if not t["actionBars"] then
        t["actionBars"] = U.Copy(defaults)
    end
end)