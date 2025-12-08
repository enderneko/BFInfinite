---@type BFI
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
    general_worldMap = {
        mapFade = false,
        mapFadeAlpha = 0.5,
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
        "alwaysShow",
        "length",
        "position",
        "font",
    },
    coordinates = {
        "alwaysShow",
        "format",
        "position",
        "font",
    },
    ping = {
        "position",
        "font",
    },
    clock = {
        "position",
        "font",
    },
    addonButtonTray = {
        "alwaysShow",
        "bgColor",
        "size",
        "position",
        "arrangement",
    },
    instanceDifficulty = {
        "position",
        "font",
        "difficultyColors",
    },
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

        if pane.t.id:find("^general") and not checked then
            local dialog = AF.GetDialog(BFIOptionsFrame_MapsPanel, L["A UI reload is required\nDo it now?"])
            dialog:SetPoint("TOP", pane, "BOTTOM")
            dialog:SetOnConfirm(ReloadUI)
        end
    end)

    function pane.Load(t)
        pane.t = t
        UpdateColor(t.cfg.enabled)
        enabled:SetChecked(t.cfg.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- alwaysShow
---------------------------------------------------------------------
builder["alwaysShow"] = function(parent)
    if created["alwaysShow"] then return created["alwaysShow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_AlwaysShow", nil, 30)
    created["alwaysShow"] = pane

    local alwaysShow = AF.CreateCheckButton(pane, L["Always Show"])
    AF.SetPoint(alwaysShow, "LEFT", 15, 0)

    alwaysShow:SetOnCheck(function(checked)
        pane.t.cfg.alwaysShow = checked
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        alwaysShow:SetChecked(t.cfg.alwaysShow)
    end

    return pane
end

---------------------------------------------------------------------
-- bgColor
---------------------------------------------------------------------
builder["bgColor"] = function(parent)
    if created["bgColor"] then return created["bgColor"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_bgColor", nil, 30)
    created["bgColor"] = pane

    local bgColor = AF.CreateColorPicker(pane, L["Background Color"], true)
    AF.SetPoint(bgColor, "LEFT", 15, 0)

    bgColor:SetOnConfirm(function(r, g, b, a)
        pane.t.cfg.bgColor[1] = r
        pane.t.cfg.bgColor[2] = g
        pane.t.cfg.bgColor[3] = b
        pane.t.cfg.bgColor[4] = a
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        bgColor:SetColor(t.cfg.bgColor)
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
-- position
---------------------------------------------------------------------
builder["position"] = function(parent)
    if created["position"] then return created["position"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Position", nil, 104)
    created["position"] = pane

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems({
        {text = _G.MINIMAP_LABEL, value = "minimap"},
        {text = L["Zone Text"], value = "zoneText"},
    })
    relativeTo:SetOnSelect(function(value)
        pane.t.cfg.relativeTo = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
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

        if t.cfg.relativeTo then
            relativeTo:SetSelectedValue(t.cfg.relativeTo)
            relativeTo:Show()
            AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, "BOTTOMLEFT", 0, -25)
            parent._contentHeights[pane.index] = 149
            AF.SetHeight(pane, 149)
        else
            relativeTo:SetSelectedValue("zoneText")
            relativeTo:Hide()
            AF.SetPoint(anchorPoint, "TOPLEFT", 15, -25)
            parent._contentHeights[pane.index] = 104
            AF.SetHeight(pane, 104)
        end

        AF.ReSize(parent) -- call AF.SetScrollContentHeight
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
-- arrangement
---------------------------------------------------------------------
builder["arrangement"] = function(parent)
    if created["arrangement"] then return created["arrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Arrangement", nil, 103)
    created["arrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 200)
    arrangement:SetLabel(L["Arrangement"])
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_Arrangement_Complex())
    arrangement:SetOnSelect(function(value)
        pane.t.cfg.arrangement = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local anchor = AF.CreateDropdown(pane, 120)
    anchor:SetLabel(L["Anchor Point"])
    anchor:SetItems(AF.GetDropdownItems_AnchorPoint(true))
    anchor:SetOnSelect(function(value)
        pane.t.cfg.anchor = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacing, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -25)
    spacing:SetAfterValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local numPerLine = AF.CreateSlider(pane, L["Displayed Per Line"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(numPerLine, "TOPLEFT", spacing, 185, 0)
    numPerLine:SetAfterValueChanged(function(value)
        pane.t.cfg.numPerLine = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    AF.SetPoint(anchor, "TOP", arrangement)
    AF.SetPoint(anchor, "RIGHT", numPerLine)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.arrangement)
        anchor:SetSelectedValue(t.cfg.anchor)
        spacing:SetValue(t.cfg.spacing)
        numPerLine:SetValue(t.cfg.numPerLine)
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

    local fontColorPicker = AF.CreateColorPicker(pane)
    AF.SetPoint(fontColorPicker, "BOTTOMRIGHT", fontDropdown, "TOPRIGHT", 0, 2)
    fontColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.cfg.color[1] = r
        pane.t.cfg.color[2] = g
        pane.t.cfg.color[3] = b
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
        if t.cfg.color then
            fontColorPicker:Show()
            fontColorPicker:SetColor(t.cfg.color)
        else
            fontColorPicker:Hide()
        end
    end

    return pane
end

---------------------------------------------------------------------
-- difficultyColors
---------------------------------------------------------------------
builder["difficultyColors"] = function(parent)
    if created["difficultyColors"] then return created["difficultyColors"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_DifficultyColors", nil, 333)
    created["difficultyColors"] = pane

    local guildGroup = AF.CreateColorPicker(pane, L["Guild Group"])
    AF.SetPoint(guildGroup, "TOPLEFT", 15, -8)
    guildGroup:SetOnConfirm(function(r, g, b)
        pane.t.cfg.guildColor[1] = r
        pane.t.cfg.guildColor[2] = g
        pane.t.cfg.guildColor[3] = b
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local nonGuildGroup = AF.CreateColorPicker(pane, L["Non-Guild Group"])
    AF.SetPoint(nonGuildGroup, "TOPLEFT", guildGroup, 185, 0)
    nonGuildGroup:SetOnConfirm(function(r, g, b)
        pane.t.cfg.normalColor[1] = r
        pane.t.cfg.normalColor[2] = g
        pane.t.cfg.normalColor[3] = b
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    local types = {
        {label = _G.PLAYER_DIFFICULTY1, key = "normal"},
        {label = _G.PLAYER_DIFFICULTY2, key = "heroic"},
        {label = _G.PLAYER_DIFFICULTY6, key = "mythic"},
        {label = _G.PLAYER_DIFFICULTY_MYTHIC_PLUS, key = "mythicPlus"},
        {label = _G.PLAYER_DIFFICULTY3, key = "raidFinder"},
        {label = _G.PLAYER_DIFFICULTY_STORY_RAID, key = "raidStory"},
        {label = _G.PLAYER_DIFFICULTY_TIMEWALKER, key = "timewalking"},
        {label = _G.LFG_TYPE_FOLLOWER_DUNGEON, key = "followerDungeon"},
        {label = _G.DELVE_LABEL, key = "delve"},
        {label = _G.GUILD_CHALLENGE_TYPE4, key = "scenario"},
        {label = _G.MAP_LEGEND_EVENT, key = "event"},
        {label = _G.PVP, key = "pvp"},
    }

    local colorPickers = {}

    for i, info in next, types do
        local cp = AF.CreateColorPicker(pane, info.label)
        cp.key = info.key
        tinsert(colorPickers, cp)

        local eb = AF.CreateEditBox(cp, nil, 100, 20, "trim")
        cp.eb = eb
        AF.SetPoint(eb, "TOPLEFT", cp, "BOTTOMRIGHT", 5, -3)
        eb:SetConfirmButton(function(text)
            pane.t.cfg.types[info.key].text = text
            AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
        end, nil, "RIGHT_OUTSIDE")

        if i == 1 then
            AF.SetPoint(cp, "TOPLEFT", guildGroup, "BOTTOMLEFT", 0, -20)
        elseif i % 2 == 1 then
            AF.SetPoint(cp, "TOPLEFT", colorPickers[i - 2], "BOTTOMLEFT", 0, -35)
        else
            AF.SetPoint(cp, "TOPLEFT", colorPickers[i - 1], 185, 0)
        end

        cp:SetOnConfirm(function(r, g, b)
            pane.t.cfg.types[info.key].color[1] = r
            pane.t.cfg.types[info.key].color[2] = g
            pane.t.cfg.types[info.key].color[3] = b
            AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
        end)
    end

    function pane.Load(t)
        pane.t = t
        guildGroup:SetColor(t.cfg.guildColor)
        nonGuildGroup:SetColor(t.cfg.normalColor)
        for _, cp in next, colorPickers do
            cp:SetColor(t.cfg.types[cp.key].color)
            cp.eb:SetText(t.cfg.types[cp.key].text)
        end
    end

    return pane
end

---------------------------------------------------------------------
-- format
---------------------------------------------------------------------
builder["format"] = function(parent)
    if created["format"] then return created["format"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_MapOption_Format", nil, 54)
    created["format"] = pane

    local format = AF.CreateDropdown(pane, 150)
    format:SetLabel(L["Format"])
    AF.SetPoint(format, "TOPLEFT", 15, -25)
    format:SetItems({
        {text = "27, 27", value = "integer"},
        {text = "27.7, 27.7", value = "1decimal"},
        {text = "27.79, 27.79", value = "2decimals"},
    })
    format:SetOnSelect(function(value)
        pane.t.cfg.format = value
        AF.Fire("BFI_UpdateModule", "maps", pane.t.map)
    end)

    function pane.Load(t)
        pane.t = t
        format:SetSelectedValue(t.cfg.format)
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