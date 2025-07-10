---@class BFI
local BFI = select(2, ...)
local G = BFI.General
---@type AbstractFramework
local AF = _G.AbstractFramework

local optionsFrame

---------------------------------------------------------------------
-- options frame
---------------------------------------------------------------------
local function CreateOptionsFrame()
    optionsFrame = AF.CreateFrame(AFParent, "BFIOptionsFrame", 1000, 600)
    optionsFrame:Hide()

    tinsert(_G.UISpecialFrames, optionsFrame:GetName())

    optionsFrame:EnableMouse(true)
    optionsFrame:SetOnMouseWheel(AF.noop)
    optionsFrame:SetClampedToScreen(true)
    optionsFrame:SetFrameStrata("HIGH")
    optionsFrame:SetFrameLevel(777)
    optionsFrame:SetToplevel(true)
    optionsFrame:SetPoint("CENTER")

    AF.CreateGlow(optionsFrame, "shadow")

    --------------------------------------------------
    -- header pane
    --------------------------------------------------
    local headerPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrameHeaderPane", nil, 35)
    headerPane:SetPoint("TOPLEFT")
    headerPane:SetPoint("TOPRIGHT")
    headerPane:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    AF.SetDraggable(headerPane, optionsFrame, true)

    -- logo
    local color2 = G.config.customAccentColor.enabled and {AF.InvertColor(AF.GetColorRGB("BFI"))} or "vivid_raspberry"
    local logo = AF.CreateGradientTexture(headerPane, "HORIZONTAL", "BFI", color2, AF.GetIcon("BFI_64_W", BFI.name))
    AF.SetSize(logo, 40, 40)
    AF.SetPoint(logo, "LEFT", headerPane, 7, 0)

    -- title
    local text = AF.WrapTextInColor("BFI", "BFI") .. AF.WrapTextInColorRGB("NFINITE", AF.GetColorRGB("BFI", nil, 0.7))
    local title = AF.CreateFontString(headerPane, text, nil, "BFI_FONT")
    AF.SetPoint(title, "LEFT", logo, "RIGHT", 7, 0)

    -- close button
    local closeButton = AF.CreateCloseButton(headerPane, optionsFrame, 35, 21, 15)
    AF.SetPoint(closeButton, "RIGHT", headerPane, -7, 0)

    -- reload button
    local reloadButton = AF.CreateButton(headerPane, _G.RELOADUI, "BFI", 115, 21)
    AF.SetPoint(reloadButton, "BOTTOMRIGHT", closeButton, "BOTTOMLEFT", -7, 0)
    reloadButton:SetTexture(AF.GetIcon("Reload"), nil, {"LEFT", 5, 0}, nil, nil, nil, "TRILINEAR")

    -- edit mode button
    local editModeButton = AF.CreateButton(headerPane, _G.HUD_EDIT_MODE_MENU, "BFI", 115, 21)
    AF.SetPoint(editModeButton, "BOTTOMRIGHT", reloadButton, "BOTTOMLEFT", -7, 0)
    editModeButton:SetTexture(AF.GetIcon("Layout"), nil, {"LEFT", 5, 0})

    -- AbstractFramework button
    local afButton = AF.CreateButton(headerPane, "AbstractFramework", "BFI", 175, 21)
    AF.SetPoint(afButton, "BOTTOMRIGHT", editModeButton, "BOTTOMLEFT", -7, 0)
    afButton:SetTexture(AF.GetIcon("AF"), nil, {"LEFT", 5, 0})

    --------------------------------------------------
    -- list pane
    --------------------------------------------------
    local listPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrameListPane", 200)
    AF.SetPoint(listPane, "TOPLEFT", headerPane, "BOTTOMLEFT", 0, 1)
    AF.SetPoint(listPane, "BOTTOMLEFT", optionsFrame)
    listPane:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
    AF.SetDraggable(listPane, optionsFrame, true)

    --------------------------------------------------
    -- content pane
    --------------------------------------------------
    local contentPane = AF.CreateBorderedFrame(optionsFrame, "BFIOptionsFrameContentPane")
    AF.SetPoint(contentPane, "TOPLEFT", listPane, "TOPRIGHT", -1, 0)
    AF.SetPoint(contentPane, "BOTTOMRIGHT")
    AF.SetDraggable(contentPane, optionsFrame, true)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFI.ToggleOptionsFrame()
    if not optionsFrame then
        CreateOptionsFrame()
    end
    optionsFrame:Toggle()
end