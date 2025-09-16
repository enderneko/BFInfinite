---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local M = BFI.modules.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    general_minimap = {
        "size",
    },
    expansionButton = {
        "size",
        "position",
    },
    trackingButton = {
        "scale",
        "position",
    },
    mailFrame = {
        "scale",
        "position",
    },
    craftingOrderFrame = {
        "scale",
        "position",
    },
    calendar = {
        "size",
        "position",
    },
    zoneText = {
        "length",
        "position",
        "font",
    }
}

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
builder["reset"] = function(parent)
    if created["reset"] then return created["reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Reset", nil, 30)
    created["reset"] = pane
    pane:Hide()

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 110, 20)
    AF.SetPoint(reset, "LEFT", 15, 0)
    reset:SetOnClick(function()
        local which
        if pane.t.id:find("^general") and IsShiftKeyDown() then
            which = L["All Settings"]
        else
            which = pane.t.ownerName
        end

        local dialog = AF.GetDialog(BFIOptionsFrame_MapsPanel, AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. which, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            if which == L["All Settings"] then
                M.ResetToDefaults(pane.t.map)
            elseif pane.t.id:find("^general") then
                M.ResetToDefaults(pane.t.map, "general")
            else
                M.ResetToDefaults(pane.t.map, pane.t.id)
            end

            if pane.t.id == "general_minimap" then
                _G.Minimap:SetZoom(1)
            end

            AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
            AF.Fire("BFI_RefreshOptions", "maps")
        end)
    end)

    local resetTooltips = {_G.RESET, L["Hold %s while clicking to reset all settings for this map"]:format(AF.WrapTextInColor("Shift", "BFI"))}
    reset._tooltipOwner = BFIOptionsFrame_MapsPanel
    reset:HookOnEnter(function()
        if pane.t.id:find("^general") then
            AF.ShowTooltip(reset, "TOPLEFT", 0, 2, resetTooltips)
        end
    end)
    reset:HookOnLeave(AF.HideTooltip)

    function pane.Load(t)
        pane.t = t
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    local function UpdateColor(checked)
        if checked then
            enabled.label:SetTextColor(AF.GetColorRGB("softlime"))
        else
            enabled.label:SetTextColor(AF.GetColorRGB("firebrick"))
        end
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.enabled = checked
        UpdateColor(checked)
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
        pane.t:SetTextColor(checked and "white" or "disabled")
    end)

    function pane.Load(t)
        pane.t = t
        UpdateColor(t.cfg.enabled)
        enabled:SetChecked(t.cfg.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
builder["size"] = function(parent)
    if created["size"] then return created["size"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Size", nil, 55)
    created["size"] = pane

    local size = AF.CreateSlider(pane, L["Size"], 150, 100, 500, 1, nil, true)
    AF.SetPoint(size, "LEFT", 15, 0)
    size:SetAfterValueChanged(function(value)
        pane.t.cfg.size = value
        if pane.t.id == "general_minimap" then
            _G.Minimap:SetZoom(1)
        end
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        if pane.t.id == "general_minimap" then
            size:SetMinMaxValues(100, 500)
        else
            size:SetMinMaxValues(10, 100)
        end
        size:SetValue(t.cfg.size)
    end
    return pane
end

---------------------------------------------------------------------
-- scale
---------------------------------------------------------------------
builder["scale"] = function(parent)
    if created["scale"] then return created["scale"] end
    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Scale", nil, 55)
    created["scale"] = pane

    local scale = AF.CreateSlider(pane, L["Scale"], 150, 0, 2, 0.05, true, true)
    AF.SetPoint(scale, "LEFT", 15, 0)
    scale:SetAfterValueChanged(function(value)
        pane.t.cfg.scale = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        scale:SetValue(t.cfg.scale)
    end
    return pane
end

---------------------------------------------------------------------
-- length
---------------------------------------------------------------------
builder["length"] = function(parent)
    if created["length"] then return created["length"] end
    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Length", nil, 55)
    created["length"] = pane

    local length = AF.CreateSlider(pane, L["Length"], 150, 0, 1, 0.05, true, true)
    AF.SetPoint(length, "LEFT", 15, 0)
    length:SetAfterValueChanged(function(value)
        pane.t.cfg.length = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        length:SetValue(t.cfg.length)
    end
    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 200, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 200, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- position
---------------------------------------------------------------------
builder["position"] = function(parent)
    if created["position"] then return created["position"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Position", nil, 104)
    created["position"] = pane

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", 15, -25)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.position[1] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.position[2] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -500, 500, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)
    x:SetAfterValueChanged(function(value)
        pane.t.cfg.position[3] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -500, 500, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetAfterValueChanged(function(value)
        pane.t.cfg.position[4] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- spacing
---------------------------------------------------------------------
builder["spacing"] = function(parent)
    if created["spacing"] then return created["spacing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Spacing", nil, 55)
    created["spacing"] = pane

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacing, "LEFT", 15, 0)
    spacing:SetOnValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        spacing:SetValue(t.cfg.spacing)
    end

    return pane
end

---------------------------------------------------------------------
-- alpha
---------------------------------------------------------------------
builder["alpha"] = function(parent)
    if created["alpha"] then return created["alpha"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Alpha", nil, 55)
    created["alpha"] = pane

    local alpha = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alpha, "LEFT", 15, 0)
    alpha:SetOnValueChanged(function(value)
        pane.t.cfg.alpha = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        alpha:SetValue(t.cfg.alpha)
    end

    return pane
end

---------------------------------------------------------------------
-- buttonsPerRow
---------------------------------------------------------------------
builder["buttonsPerRow"] = function(parent)
    if created["buttonsPerRow"] then return created["buttonsPerRow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_ButtonsPerRow", nil, 55)
    created["buttonsPerRow"] = pane

    local buttonsPerRow = AF.CreateSlider(pane, L["Buttons Per Row"], 150, 1, 11, 1, nil, true)
    AF.SetPoint(buttonsPerRow, "LEFT", 15, 0)
    buttonsPerRow:SetOnValueChanged(function(value)
        pane.t.cfg.buttonsPerRow = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        buttonsPerRow:SetValue(t.cfg.buttonsPerRow)
    end

    return pane
end

---------------------------------------------------------------------
-- arrangement
---------------------------------------------------------------------
builder["arrangement"] = function(parent)
    if created["arrangement"] then return created["arrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Arrangement", nil, 54)
    created["arrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 200)
    arrangement:SetLabel(L["Arrangement"])
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_ComplexOrientation())

    arrangement:SetOnSelect(function(value)
        pane.t.cfg.arrangement = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.arrangement)
    end

    return pane
end

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
builder["font"] = function(parent)
    if created["font"] then return created["font"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Font", nil, 103)
    created["font"] = pane

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[1] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[3] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.font[2] = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.font[4] = checked
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        fontDropdown:SetSelectedValue(t.cfg.font[1])
        fontSizeSlider:SetValue(t.cfg.font[2])
        fontOutlineDropdown:SetSelectedValue(t.cfg.font[3])
        shadowCheckButton:SetChecked(t.cfg.font[4])
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetMapOptions(parent, info)
    for _, pane in pairs(created) do
        pane:Hide()
        AF.ClearPoints(pane)
    end

    wipe(options)
    tinsert(options, builder["reset"](parent))
    created["reset"]:Show()
    tinsert(options, builder["enabled"](parent))
    created["enabled"]:Show()

    local setting = info.id
    if not settings[setting] then return options end

    for _, option in pairs(settings[setting]) do
        if type(option) == "table" then
            local pane = builder["tips"](parent)
            tinsert(options, pane)
            pane:Show()
            pane.SetTips(AF.TableToString(option, "\n"))
        elseif builder[option] then
            local pane = builder[option](parent)
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end