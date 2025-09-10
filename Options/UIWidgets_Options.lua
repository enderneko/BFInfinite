---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local W = BFI.modules.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    readyCheck = {
        "width,height",
        "spacing",
        "arrangement",
        "countdown",
        "font",
        "ready,pull",
    },
}

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
builder["reset"] = function(parent)
    if created["reset"] then return created["reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Reset", nil, 30)
    created["reset"] = pane
    pane:Hide()

    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 110, 20)
    AF.SetPoint(reset, "LEFT", 15, 0)
    reset:SetOnClick(function()
        local dialog = AF.GetDialog(BFIOptionsFrame_EnhancementsPanel, AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. pane.t.ownerName, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            W.ResetToDefaults(pane.t.id)
        end)
    end)

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

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Enabled", nil, 30)
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
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
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
-- restrictPingsTo
---------------------------------------------------------------------
-- TODO: move to data broker
-- local SetRestrictPings = C_PartyInfo.SetRestrictPings
-- local GetRestrictPings = C_PartyInfo.GetRestrictPings
-- local RestrictPingsTo = Enum.RestrictPingsTo

-- builder["restrictPingsTo"] = function(parent)
--     if created["restrictPingsTo"] then return created["restrictPingsTo"] end

--     local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_RestrictPingsTo", nil, 54)
--     created["restrictPingsTo"] = pane

--     local dropdown = AF.CreateDropdown(pane, 150)
--     AF.SetPoint(dropdown, "TOPLEFT", 15, -25)
--     dropdown:SetLabel(string.utf8sub(_G.RAID_MANAGER_RESTRICT_PINGS_TO, 1, -2)) -- remove colon
--     dropdown:SetItems({
--         {text = _G.NONE, value = RestrictPingsTo.None},
--         {text = _G.RAID_MANAGER_RESTRICT_PINGS_TO_LEAD, value = RestrictPingsTo.Lead},
--         {text = _G.RAID_MANAGER_RESTRICT_PINGS_TO_ASSIST, value = RestrictPingsTo.Assist},
--         {text = _G.RAID_MANAGER_RESTRICT_PINGS_TO_TANKS_HEALERS, value = RestrictPingsTo.TankHealer},
--     })

--     dropdown:SetTooltip(L["This group only"])

--     dropdown:SetOnSelect(function(value)
--         SetRestrictPings(value)
--     end)

--     function pane.Load(t)
--         pane.t = t
--         dropdown:SetSelectedValue(GetRestrictPings())
--     end

--     return pane
-- end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 200, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 200, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
builder["font"] = function(parent)
    if created["font"] then return created["font"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Font", nil, 103)
    created["font"] = pane

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[1] = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[3] = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.font[2] = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.font[4] = checked
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
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
function F.GetUIWidgetOptions(parent, info)
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
        if builder[option] then
            local pane = builder[option](parent)
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end