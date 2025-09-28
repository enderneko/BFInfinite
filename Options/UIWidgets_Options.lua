---@type BFI
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
    microMenu = {
        "width,height",
        "alpha",
        "buttonsPerRow",
        "spacing",
    },
    readyPull = {
        {
            AF.WrapTextInColor(L["Ready"], "BFI"),
            AF.WrapTextInColor(L["Left-click: "], "tip") .. _G.READY_CHECK,
            AF.WrapTextInColor(L["Right-click: "], "tip") .. _G.ROLE_POLL,
            "",
            AF.WrapTextInColor(L["Pull"], "BFI"),
            AF.WrapTextInColor(L["Left-click: "], "tip") .. L["Start countdown"],
            AF.WrapTextInColor(L["Right-click: "], "tip") .. L["Cancel countdown"],
        },
        "countdown",
        "width,height",
        "arrangement_simple",
        "spacing",
        "ready,pull",
        "font",
    },
    markers = {
        {
            AF.WrapTextInColor(L["Target Markers"], "BFI"),
            AF.WrapTextInColor(L["Left-click: "], "tip") .. L["Toggle marker"],
            AF.WrapTextInColor(L["Right-click: "], "tip") .. L["Lock/unlock marker (only for players in your group)"],
            "",
            AF.WrapTextInColor(L["World Markers"], "BFI"),
            AF.WrapTextInColor(L["Left-click: "], "tip") .. L["Place marker"],
            AF.WrapTextInColor(L["Right-click: "], "tip") .. L["Clear marker"],
        },
        "markerOptions",
        "width,height",
        "arrangement_complex",
        "markerSpacing",
    }
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
        local dialog = AF.GetDialog(BFIOptionsFrame_UIWidgetsPanel, AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n" .. pane.t.ownerName, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            W.ResetToDefaults(pane.t.id)
            AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
            AF.Fire("BFI_RefreshOptions", "uiWidgets")
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
-- tips
---------------------------------------------------------------------
builder["tips"] = function(parent)
    if created["tips"] then return created["tips"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Tips")
    created["tips"] = pane
    pane:SetBorderColor("BFI")

    local tips = AF.CreateFontString(pane)
    AF.SetPoint(tips, "TOPLEFT", 15, -9)
    AF.SetPoint(tips, "RIGHT", -15, 0)
    tips:SetSpacing(5)
    tips:SetJustifyH("LEFT")
    tips:SetJustifyV("TOP")

    local function UpdateHeight()
        pane:SetHeight(tips:GetStringHeight() + 20)

        if parent._contentHeights then
            parent._contentHeights[pane.index] = tostring(pane:GetHeight()) -- update height
            AF.ReSize(parent) -- call AF.SetScrollContentHeight
        end
    end

    function pane.SetTips(text)
        tips:SetText(text)
        C_Timer.After(0, UpdateHeight)
    end

    pane.Load = AF.noop

    return pane
end

---------------------------------------------------------------------
-- showTooltips
---------------------------------------------------------------------
-- builder["showTooltips"] = function(parent)
--     if created["showTooltips"] then return created["showTooltips"] end

--     local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_ShowTooltips", nil, 30)
--     created["showTooltips"] = pane

--     local showTooltips = AF.CreateCheckButton(pane, L["Show Tooltips"])
--     AF.SetPoint(showTooltips, "LEFT", 15, 0)

--     showTooltips:SetOnCheck(function(checked)
--         pane.t.cfg.showTooltips = checked
--         -- AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
--     end)

--     function pane.Load(t)
--         pane.t = t
--         showTooltips:SetChecked(t.cfg.showTooltips)
--     end

--     return pane
-- end

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
-- spacing
---------------------------------------------------------------------
builder["spacing"] = function(parent)
    if created["spacing"] then return created["spacing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Spacing", nil, 55)
    created["spacing"] = pane

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacing, "LEFT", 15, 0)
    spacing:SetOnValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
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

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Alpha", nil, 55)
    created["alpha"] = pane

    local alpha = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alpha, "LEFT", 15, 0)
    alpha:SetOnValueChanged(function(value)
        pane.t.cfg.alpha = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
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

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_ButtonsPerRow", nil, 55)
    created["buttonsPerRow"] = pane

    local buttonsPerRow = AF.CreateSlider(pane, L["Buttons Per Row"], 150, 1, 11, 1, nil, true)
    AF.SetPoint(buttonsPerRow, "LEFT", 15, 0)
    buttonsPerRow:SetOnValueChanged(function(value)
        pane.t.cfg.buttonsPerRow = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        buttonsPerRow:SetValue(t.cfg.buttonsPerRow)
    end

    return pane
end

---------------------------------------------------------------------
-- markerSpacing
---------------------------------------------------------------------
builder["markerSpacing"] = function(parent)
    if created["markerSpacing"] then return created["markerSpacing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_MarkerSpacing", nil, 55)
    created["markerSpacing"] = pane

    local groupSpacing = AF.CreateSlider(pane, L["Group Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(groupSpacing, "LEFT", 15, 0)
    groupSpacing:SetOnValueChanged(function(value)
        pane.t.cfg.groupSpacing = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local markerSpacing = AF.CreateSlider(pane, L["Marker Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(markerSpacing, "TOPLEFT", groupSpacing, 185, 0)
    markerSpacing:SetOnValueChanged(function(value)
        pane.t.cfg.markerSpacing = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        groupSpacing:SetValue(t.cfg.groupSpacing)
        markerSpacing:SetValue(t.cfg.markerSpacing)
    end

    return pane
end

---------------------------------------------------------------------
-- countdown
---------------------------------------------------------------------
builder["countdown"] = function(parent)
    if created["countdown"] then return created["countdown"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_Countdown", nil, 55)
    created["countdown"] = pane

    local countdown = AF.CreateSlider(pane, _G.COUNTDOWN, 150, 1, 30, 1, nil, true)
    AF.SetPoint(countdown, "LEFT", 15, 0)
    countdown:SetAfterValueChanged(function(value)
        pane.t.cfg.countdown = value
        -- AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        countdown:SetValue(t.cfg.countdown)
    end

    return pane
end

---------------------------------------------------------------------
-- arrangement_complex
---------------------------------------------------------------------
builder["arrangement_complex"] = function(parent)
    if created["arrangement_complex"] then return created["arrangement_complex"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_ArrangementComplex", nil, 54)
    created["arrangement_complex"] = pane

    local arrangement = AF.CreateDropdown(pane, 200)
    arrangement:SetLabel(L["Arrangement"])
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_Arrangement_Complex())

    arrangement:SetOnSelect(function(value)
        pane.t.cfg.arrangement = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.arrangement)
    end

    return pane
end

---------------------------------------------------------------------
-- arrangement_simple
---------------------------------------------------------------------
builder["arrangement_simple"] = function(parent)
    if created["arrangement_simple"] then return created["arrangement_simple"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_ArrangementSimple", nil, 54)
    created["arrangement_simple"] = pane

    local arrangement = AF.CreateDropdown(pane, 150)
    arrangement:SetLabel(L["Arrangement"])
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_Arrangement_Simple())

    arrangement:SetOnSelect(function(value)
        pane.t.cfg.arrangement = value
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
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
-- ready,pull
---------------------------------------------------------------------
builder["ready,pull"] = function(parent)
    if created["ready,pull"] then return created["ready,pull"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_ReadyPull", nil, 54)
    created["ready,pull"] = pane

    local ready = AF.CreateEditBox(pane, L["Use default if empty"], 150, 20)
    ready:SetLabelAlt(L["Ready"])
    AF.SetPoint(ready, "TOPLEFT", 15, -25)
    ready:SetOnTextChanged(function(text, userChanged)
        if not userChanged then return end
        pane.t.cfg.ready = text
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local pull = AF.CreateEditBox(pane, L["Use default if empty"], 150, 20)
    pull:SetLabelAlt(L["Pull"])
    AF.SetPoint(pull, "TOPLEFT", ready, 185, 0)
    pull:SetOnTextChanged(function(text, userChanged)
        if not userChanged then return end
        pane.t.cfg.pull = text
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    function pane.Load(t)
        pane.t = t
        ready:SetText(t.cfg.ready)
        pull:SetText(t.cfg.pull)
    end

    return pane
end

---------------------------------------------------------------------
-- markerOptions
---------------------------------------------------------------------
builder["markerOptions"] = function(parent)
    if created["markerOptions"] then return created["markerOptions"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UIWidgetOption_MarkerOptions", nil, 51)
    created["markerOptions"] = pane

    local targetMarkers = AF.CreateCheckButton(pane, L["Target Markers"])
    AF.SetPoint(targetMarkers, "TOPLEFT", 15, -8)

    local worldMarkers = AF.CreateCheckButton(pane, L["World Markers"])
    AF.SetPoint(worldMarkers, "TOPLEFT", targetMarkers, 185, 0)
    worldMarkers:SetOnCheck(function(checked)
        pane.t.cfg.worldMarkers = checked
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    local showIfSolo = AF.CreateCheckButton(pane, L["Show If Solo"])
    AF.SetPoint(showIfSolo, "TOPLEFT", targetMarkers, "BOTTOMLEFT", 0, -7)
    showIfSolo:SetOnCheck(function(checked)
        pane.t.cfg.showIfSolo = checked
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
    end)

    targetMarkers:SetOnCheck(function(checked)
        pane.t.cfg.targetMarkers = checked
        AF.Fire("BFI_UpdateModule", "uiWidgets", pane.t.id)
        showIfSolo:SetEnabled(checked)
    end)

    function pane.Load(t)
        pane.t = t
        targetMarkers:SetChecked(t.cfg.targetMarkers)
        worldMarkers:SetChecked(t.cfg.worldMarkers)
        showIfSolo:SetChecked(t.cfg.showIfSolo)
        showIfSolo:SetEnabled(t.cfg.targetMarkers)
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