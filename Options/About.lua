---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local aboutPanel

---------------------------------------------------------------------
-- about panel
---------------------------------------------------------------------
local function CreateAboutPanel()
    aboutPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_AboutPanel")
    aboutPanel:SetAllPoints()
end

---------------------------------------------------------------------
-- bfi pane
---------------------------------------------------------------------
local function CreateBFIPane()
    local bfiPane = AF.CreateTitledPane(aboutPanel, "BFI", nil, 300)
    aboutPanel.bfiPane = bfiPane
    AF.SetPoint(bfiPane, "TOPLEFT", aboutPanel, 15, -15)
    AF.SetPoint(bfiPane, "TOPRIGHT", generalPanel, -15, -15)

    -- version
    local ver = strlower(AF.L["Version"])

    local bfiVersion = AF.CreateFontString(bfiPane)
    AF.SetPoint(bfiVersion, "TOPLEFT", 15, -27)
    bfiVersion:SetText(AF.WrapTextInColor("BFI ", "BFI") .. ver .. ": " .. BFI.version)

    local afVersion = AF.CreateFontString(bfiPane)
    AF.SetPoint(afVersion, "TOPLEFT", 270, -27)
    afVersion:SetText(AF.WrapTextInColor("AbstractFramework ", "accent") .. ver .. ": " .. AF.version)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "About" then
        if not aboutPanel then
            CreateAboutPanel()
            CreateBFIPane()
        end
        aboutPanel:Show()
    elseif aboutPanel then
        aboutPanel:Hide()
    end
end)