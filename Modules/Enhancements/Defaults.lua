---@class BFI
local BFI = select(2, ...)
---@class Enhancements
local E = BFI.modules.Enhancements
---@type AbstractFramework
local AF = _G.AbstractFramework

local defaults = {
    equipmentInfo = {
        enabled = true,
        itemLevel = {
            enabled = true,
            position = {"TOPLEFT", 1, -1},
            color = {type = "quality_color", rgb = AF.GetColorTable("BFI")},
            font = {"Expressway", 12, "outline", false},
        },
        durability = {
            enabled = true,
            position = "BOTTOM",
            margin = 1,
            size = 5,
            color = {
                high = AF.GetColorTable("green"),
                medium = AF.GetColorTable("yellow"),
                low = AF.GetColorTable("red"),
            },
            hideAtFull = true,
            glowBelow = 0.25,
        },
        missingEnhance = { -- missing enchantments and gems
            enabled = true,
            position = {"BOTTOMLEFT", 2, 2},
            size = 15,
        }
    },
}

AF.RegisterCallback("BFI_UpdateConfig", function(_, module)
    if module then return end -- init

    if not BFIConfig.enhancements then
        BFIConfig.enhancements = AF.Copy(defaults)
    end
    E.config = BFIConfig.enhancements
end)

function E.GetDefaults()
    return AF.Copy(defaults)
end

function E.ResetToDefaults(which)
    if not which then
        AF.MergeExistingKeys(BFIConfig["enhancements"], defaults)
    else
        AF.MergeExistingKeys(BFIConfig["enhancements"][which], defaults[which])
    end
end