---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local indicators = {
    healthBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "frameLevel",
        "smoothing",
        "texture",
        "color,lossColor,bgColor,borderColor",
        "healPrediction",
        "shield,overshieldGlow",
        "healAbsorb,overabsorbGlow",
        "mouseoverHighlight",
        "dispelHighlight",
    }
}

local created = {}
local builder = {}

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function()
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    function pane.Load(t)
        enabled:SetChecked(t.cfg.enabled)
        enabled:SetOnCheck(function(checked)
            t.cfg.enabled = checked
            t:SetTextColor(checked and "white" or "disabled")
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function()
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, "TOPRIGHT", 35, 0)

    function pane.Load(t)
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)

        width:SetOnValueChanged(function(value)
            t.cfg.width = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)

        height:SetOnValueChanged(function(value)
            t.cfg.height = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- position,anchorTo
---------------------------------------------------------------------
local function GetAnchorToItems()
    local validRelativeTos = {
        "root",
        "healthBar", "powerBar", "portrait", "castBar", "extraManaBar", "classPowerBar", "staggerBar",
        "nameText", "healthText", "powerText", "leaderText", "levelText", "targetCounter", "statusTimer", "incDmgHealText",
        "buffs", "debuffs",
        "raidIcon", "leaderIcon", "roleIcon", "combatIcon", "readyCheckIcon", "factionIcon", "statusIcon",
    }

    for i, to in next, validRelativeTos do
        if to == "root" then
            validRelativeTos[i] = {text = L["Unit Frame"], value = to}
        else
            validRelativeTos[i] = {text = L[to], value = to}
        end
    end
    return validRelativeTos
end

local function GetAnchorPointItems()
    local items = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM"}
    for i, item in next, items do
        items[i] = {text = L[item], value = item}
    end
    return items
end

builder["position,anchorTo"] = function()
    if created["position,anchorTo"] then return created["position,anchorTo"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_PositionAnchorTo", nil, 150)
    created["position,anchorTo"] = pane

    local validRelativeTos = GetAnchorToItems()

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems(validRelativeTos)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, 0, -45)
    anchorPoint:SetItems(GetAnchorPointItems())

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, "TOPRIGHT", 35, 0)
    relativePoint:SetItems(GetAnchorPointItems())

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, "TOPRIGHT", 35, 0)

    function pane.Load(t)
        for _, to in next, validRelativeTos do
            if to.value ~= "root" then
                to.disabled = not t.target.indicators[to.value]
            end
        end
        relativeTo.reloadRequired = true

        relativeTo:SetSelectedValue(t.cfg.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])

        relativeTo:SetOnSelect(function(value)
            t.cfg.anchorTo = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        anchorPoint:SetOnSelect(function(value)
            t.cfg.position[1] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        relativePoint:SetOnSelect(function(value)
            t.cfg.position[2] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        x:SetOnValueChanged(function(value)
            t.cfg.position[3] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)

        y:SetOnValueChanged(function(value)
            t.cfg.position[4] = value
            UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.relativeTo)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- frameLevel
---------------------------------------------------------------------
builder["frameLevel"] = function()
    if created["frameLevel"] then return created["frameLevel"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_FrameLevel", nil, 55)
    created["frameLevel"] = pane

    local frameLevel = AF.CreateSlider(pane, L["Frame Level"], 150, 0, 100, 1, nil, true)
    AF.SetPoint(frameLevel, "LEFT", 15, 0)

    function pane.Load(t)
        frameLevel:SetValue(t.cfg.frameLevel)

        frameLevel:SetOnValueChanged(function(value)
            t.cfg.frameLevel = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- smoothing
---------------------------------------------------------------------
builder["smoothing"] = function()
    if created["smoothing"] then return created["smoothing"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Smoothing", nil, 30)
    created["smoothing"] = pane

    local smoothing = AF.CreateCheckButton(pane, L["Smooth Bar Transition"])
    AF.SetPoint(smoothing, "LEFT", 15, 0)

    function pane.Load(t)
        smoothing:SetChecked(t.cfg.smoothing)
        smoothing:SetOnCheck(function(checked)
            t.cfg.smoothing = checked
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
builder["texture"] = function()
    if created["texture"] then return created["texture"] end

    local pane = AF.CreateBorderedFrame(BFIOptionsFrame, "BFI_IndicatorOption_Texture", nil, 55)
    created["texture"] = pane

    local texture = AF.CreateDropdown(pane, 150)
    texture:SetLabel(L["Texture"])
    AF.SetPoint(texture, "TOPLEFT", 15, -25)
    texture:SetItems(AF.LSM_GetBarTextureDropdownItems())

    function pane.Load(t)
        texture:SetSelectedValue(t.cfg.texture)
        texture:SetOnSelect(function(value)
            t.cfg.texture = value
            UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
        end)
    end

    return pane
end

---------------------------------------------------------------------
-- color,lossColor,bgColor,borderColor
---------------------------------------------------------------------

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetIndicatorOptions(info)
    if not indicators[info.id] then return {} end

    local options = {}

    for _, option in pairs(indicators[info.id]) do
        if builder[option] then
            tinsert(options, builder[option]())
            created[option].Load(info)
        end
    end

    return options
end