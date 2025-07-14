---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local unitFramesPanel

---------------------------------------------------------------------
-- unit frames panel
---------------------------------------------------------------------
local function CreateUnitFramesPanel()
    unitFramesPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_UnitFramesPanel")
    unitFramesPanel:SetAllPoints()
    AF.ApplyCombatProtectionToFrame(unitFramesPanel)

    -- switch
    local subs = {
        unit = {"Player", "Target", "Focus", "Pet"},
        target = {"TargetTarget", "FocusTarget", "PetTarget"},
        group = {"Party", "Raid", "RaidPets", "Boss", "Arena"},
    }

    local subItems = {}

    local primarySwitch = AF.CreateSwitch(unitFramesPanel, 200, 20)
    unitFramesPanel.primarySwitch = primarySwitch
    AF.SetPoint(primarySwitch, "TOPLEFT", 15, -15)
    -- AF.SetPoint(primarySwitch, "TOPRIGHT")

    local secondarySwitch = AF.CreateSwitch(unitFramesPanel, 390, 20)
    AF.SetPoint(secondarySwitch, "TOPLEFT", primarySwitch, "TOPRIGHT", 10, 0)
    AF.SetPoint(secondarySwitch, "TOPRIGHT", unitFramesPanel, "TOPRIGHT", -15, -15)

    primarySwitch:SetLabels({
        {text = "Unit", value = "unit"},
        {text = "Target", value = "target"},
        {text = "Group", value = "group"},
    })

    primarySwitch:SetOnSelect(function(value)
        if not subItems[value] then
            for _, name in pairs(subs[value]) do
                subItems[value] = subItems[value] or {}
                tinsert(subItems[value], {text = L[name], value = name})
            end
        end

        secondarySwitch:SetLabels(subItems[value])
        secondarySwitch:SetSelectedValue(subs[value][1])
    end)

    -- content
    local contentPane = AF.CreateFrame(unitFramesPanel)
    AF.SetPoint(contentPane, "TOPLEFT", primarySwitch, "BOTTOMLEFT", 0, -10)
    AF.SetPoint(contentPane, "BOTTOMRIGHT", -15, 15)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Unit Frames" then
        if not unitFramesPanel then
            CreateUnitFramesPanel()
            unitFramesPanel.primarySwitch:SetSelectedValue("unit")
        end
        unitFramesPanel:Show()
    elseif unitFramesPanel then
        unitFramesPanel:Hide()
    end
end)