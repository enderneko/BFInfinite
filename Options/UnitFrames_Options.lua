---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local UF = BFI.modules.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    -- general
    general_single = {
        "enabled",
        "width,height",
        "oorAlpha",
        "bgColor,borderColor",
        "tooltip",
    },
    general_party = {
        "enabled",
        "width,height",
        "partyArrangement",
        "oorAlpha",
        "bgColor,borderColor",
        "tooltip",
    },
    general_raid = {
        "enabled",
        "width,height",
        "raidArrangement",
        "oorAlpha",
        "bgColor,borderColor",
        "tooltip",
    },
    general_boss = {
        "enabled",
        "width,height",
        "groupArrangement",
        "oorAlpha",
        "bgColor,borderColor",
        "tooltip",
     },

    -- indicators
    healthBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "smoothing",
        "healPrediction",
        "shield,overshieldGlow",
        "healAbsorb,overabsorbGlow",
        "mouseoverHighlight",
        "dispelHighlight",
        "frameLevel",
    },
    powerBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "smoothing",
        "frequent",
        "frameLevel",
    },
    portrait = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "style,model",
        "bgColor,borderColor",
        "frameLevel",
    },
    castBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "interruptibleCheck",
        "bgColor,borderColor",
        "showIcon",
        "showLatency",
        "fadeDuration",
        "spark",
        "ticks",
        "castBarNameText",
        "castBarDurationText",
        "frameLevel",
    },
    extraManaBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "smoothing",
        "frequent",
        "hideIfHasClassPower,hideIfFull",
        "frameLevel",
    },
    classPowerBar = {
        "enabled",
        "width,height",
        "spacing",
        "position,anchorTo",
        "texture",
        "barColor",
        "barLossColor",
        "bgColor,borderColor",
        "cooldownText",
        "frameLevel",
    },
    staggerBar = {
        "enabled",
        "width,height",
        "position,anchorTo",
        "texture",
        "bgColor,borderColor",
        "textWithFormat",
        "frameLevel",
    },
    nameText = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
        "textLength",
    },
    healthText = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
        "textFormat",
        "hideIfFull",
    },
    powerText = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
        "textFormat",
        "frequent",
        "hideIfFull,hideIfEmpty",
    },
    leaderText = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
    },
    levelText = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
    },
    targetCounter = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
    },
    statusTimer = {
        "enabled",
        "position,anchorTo,parent",
        "font,color",
        "showTimer,useEn",
    },
    rangeText = {
        "enabled",
        "position,anchorTo,parent",
        "font",
    },
    incDmgHealText = {
        "enabled",
        "position,anchorTo,parent",
        "font",
        "damage,healing",
        "numericFormat",
    },
    buffs = {
        "enabled",
        "cooldownStyle",
        "auraBaseFilters",
        "auraBlackListWhitelist",
        "auraTypeColor",
        "auraArrangement",
        "position,anchorTo",
        "stackText",
        "durationText",
        "tooltip",
        "frameLevel"
    },
    debuffs = {
        "enabled",
        "cooldownStyle",
        "auraBaseFilters",
        "auraBlackListWhitelist",
        "auraTypeColor",
        "auraArrangement",
        "auraSubFrame",
        "position,anchorTo",
        "stackText",
        "durationText",
        "tooltip",
        "frameLevel"
    },
    raidIcon = {
        "enabled",
        "position,anchorTo",
        "style",
        "size",
        "frameLevel",
    },
    statusIcon = {
        "enabled",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    readyCheckIcon = {
        "enabled",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    roleIcon = {
        "enabled",
        "hideDamager",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    leaderIcon = {
        "enabled",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    combatIcon = {
        "enabled",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    factionIcon = {
        "enabled",
        "position,anchorTo",
        "size",
        "frameLevel",
    },
    restingIndicator = {
        "enabled",
        "position,anchorTo",
        "style",
        "size",
        "frameLevel",
    },
    targetHighlight = {
        "enabled",
        "color",
        "size",
        "frameLevel",
    },
    mouseoverHighlight = {
        "enabled",
        "color",
        "size",
        "frameLevel",
    },
    threatGlow = {
        "enabled",
        "alpha",
        "size",
    }
}

---------------------------------------------------------------------
-- shared functions
---------------------------------------------------------------------
local function LoadIndicatorConfig(t)
    AF.Debug(AF.GetColorStr("darkgray"), "LoadIndicatorConfig", t.owner, t.id)
    if t.owner == "party" then
        for i = 1, 5 do
            UF.LoadIndicatorConfig(t.target.header[i], t.id, t.cfg)
        end
    elseif t.owner == "raid" then
        for i = 1, 40 do
            UF.LoadIndicatorConfig(t.target.header[i], t.id, t.cfg)
        end
    elseif t.owner == "boss" then
        for i = 1, 8 do
            UF.LoadIndicatorConfig(t.target[i], t.id, t.cfg)
        end
    else
        UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
    end
end

local function LoadIndicatorPosition(t)
    if t.owner == "party" then
        for i = 1, 5 do
            UF.LoadIndicatorPosition(t.target.header[i].indicators[t.id], t.cfg.position, t.cfg.anchorTo, t.cfg.parent)
        end
    elseif t.owner == "raid" then
        for i = 1, 40 do
            UF.LoadIndicatorPosition(t.target.header[i].indicators[t.id], t.cfg.position, t.cfg.anchorTo, t.cfg.parent)
        end
    elseif t.owner == "boss" then
        for i = 1, 8 do
            UF.LoadIndicatorPosition(t.target[i].indicators[t.id], t.cfg.position, t.cfg.anchorTo, t.cfg.parent)
        end
    else
        UF.LoadIndicatorPosition(t.target.indicators[t.id], t.cfg.position, t.cfg.anchorTo, t.cfg.parent)
    end
end

local function GetFormatItems(which)
    local numeric, percent

    if which == "staggerBar" or which == "powerText" then
        numeric = {
            {text = _G.NONE, value = "none"},
            {text = L["Current"], value = "current"},
            {text = L["Current (Short)"], value = "current_short"},
        }
        percent = {
            {text = _G.NONE, value = "none"},
            {text = L["Current"], value = "current"},
            {text = L["Current (Decimal)"], value = "current_decimal"},
        }
    elseif which == "healthText" then
        numeric = {
            {text = _G.NONE, value = "none"},
            {text = L["Current"], value = "current"},
            {text = L["Current (Short)"], value = "current_short"},
            {text = L["Current + Shields"], value = "current_absorbs"},
            {text = L["Current + Shields (Short)"], value = "current_absorbs_short"},
            {text = L["Effective"], value = "current_absorbs_sum"},
            {text = L["Effective (Short)"], value = "current_absorbs_short_sum"},
        }
        percent = {
            {text = _G.NONE, value = "none"},
            {text = L["Current"], value = "current"},
            {text = L["Current (Decimal)"], value = "current_decimal"},
            {text = L["Current + Shields"], value = "current_absorbs"},
            {text = L["Current + Shields (Decimal)"], value = "current_absorbs_decimal"},
            {text = L["Effective"], value = "current_absorbs_sum"},
            {text = L["Effective (Decimal)"], value = "current_absorbs_sum_decimal"},
        }
    elseif which == "incDmgHealText" then
        numeric = {
            {text = L["Current"], value = "current"},
            {text = L["Current (Short)"], value = "current_short"},
        }
    end

    return numeric, percent
end

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

local function UpdateAnchorToItems(t, items)
    local indicators
    if t.owner == "party" or t.owner == "raid" then
        indicators = t.target.header[1].indicators
    elseif t.owner == "boss" then
        indicators = t.target[1].indicators
    else
        indicators = t.target.indicators
    end
    for _, to in next, items do
        if to.value ~= "root" then
            to.disabled = not indicators[to.value] or to.value == t.id
        end
    end
end

local function GetParentItems()
    local validParents = {
        "root",  "healthBar", "powerBar", "portrait"
    }

    for i, to in next, validParents do
        if to == "root" then
            validParents[i] = {text = L["Unit Frame"], value = to}
        else
            validParents[i] = {text = L[to], value = to}
        end
    end
    return validParents
end

local function GetColorItems(which)
    local items = {
        {text = L["Class"], value = "class_color"},
    }

    if not (which:find("Text$") or which:find("Counter$") or which:find("Timer$")) then
        tinsert(items, {text = L["Class (Dark)"], value = "class_color_dark"})
    end

    if which:find("^power") or which:find("^classPower") then
        tinsert(items, {text = L["Power"], value = "power_color"})
        if not which:find("Text$") then
            tinsert(items, {text = L["Power (Dark)"], value = "power_color_dark"})
        end
    elseif which:find("^extraMana") then
        AF.InsertAll(items, {
            {text = L["Mana"], value = "mana_color"},
            {text = L["Mana (Dark)"], value = "mana_color_dark"},
        })
    elseif which:find("^level") then
        tinsert(items, {text = L["Level"], value = "level_color"})
    end

    tinsert(items, {text = _G.CUSTOM, value = "custom_color"})
    return items
end

---------------------------------------------------------------------
-- copy,paste,reset
---------------------------------------------------------------------
builder["copy,paste,reset"] = function(parent)
    if created["copy,paste,reset"] then return created["copy,paste,reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_CopyPasteReset", nil, 30)
    created["copy,paste,reset"] = pane
    pane:Hide()

    local copiedId, copiedOwnerName, copiedTime, copiedCfg, isWholeCfg

    local copy = AF.CreateButton(pane, L["Copy"], "BFI_hover", 107, 20)
    AF.SetPoint(copy, "LEFT", 15, 0)
    copy.tick = AF.CreateTexture(copy, AF.GetIcon("Fluent_Color_Yes"))
    AF.SetSize(copy.tick, 16, 16)
    AF.SetPoint(copy.tick, "RIGHT", -5, 0)
    copy.tick:Hide()

    local paste = AF.CreateButton(pane, L["Paste"], "BFI_hover", 107, 20)
    AF.SetPoint(paste, "TOPLEFT", copy, "TOPRIGHT", 7, 0)

    copy:SetOnClick(function()
        if pane.t.id:find("^general") and IsShiftKeyDown() then
            isWholeCfg = true
            copiedCfg = AF.Copy(UF.config[pane.t.owner])
            copiedCfg.general.position = nil
        else
            isWholeCfg = false
            copiedId = pane.t.id
            copiedCfg = AF.Copy(pane.t.cfg)
            if pane.t.id:find("^general") then
                copiedCfg.position = nil
            end
        end
        copiedOwnerName = pane.t.ownerName
        copiedTime = time()
        AF.FrameFadeInOut(copy.tick, 0.15)
        paste:SetEnabled(true)
    end)

    local copyTooltips = {L["Copy"], L["Hold %s while clicking to copy all settings for this unit frame"]:format(AF.WrapTextInColor("Shift", "BFI"))}
    copy._tooltipOwner = BFIOptionsFrame_UnitFramesPanel
    copy:HookOnEnter(function()
        if pane.t.id:find("^general") then
            AF.ShowTooltip(copy, "TOPLEFT", 0, 2, copyTooltips)
        end
    end)
    copy:HookOnLeave(AF.HideTooltip)

    paste:SetOnClick(function()
        local which
        if isWholeCfg then
            which = "All Settings"
        else
            which = copiedId:find("^general") and "General" or copiedId
        end
        local text = AF.WrapTextInColor(L["Overwrite with copied config?"], "BFI") .. "\n"
            .. AF.WrapTextInColor("[" .. L[which] .. "]", "softlime") .. "\n"
            .. copiedOwnerName .. AF.WrapTextInColor(" -> ", "darkgray") .. pane.t.ownerName .. "\n"
            .. AF.WrapTextInColor(AF.FormatRelativeTime(copiedTime), "darkgray")

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            if pane.t.id:find("^general") then
                if isWholeCfg then
                    AF.MergeExistingKeys(UF.config[pane.t.owner].general, copiedCfg.general)
                    for k, t in next, UF.config[pane.t.owner].indicators do
                        if copiedCfg.indicators[k] then
                            AF.MergeExistingKeys(UF.config[pane.t.owner].indicators[k], copiedCfg.indicators[k])
                        else
                            UF.config[pane.t.owner].indicators[k].enabled = false
                        end
                    end
                    AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner)
                else
                    -- NOTE: special "groupBy" handling
                    if pane.t.cfg.groupingOrder and not pane.t.cfg.groupBy then
                        pane.t.cfg.groupBy = "nil"
                    end
                    AF.MergeExistingKeys(pane.t.cfg, copiedCfg)
                    if pane.t.cfg.groupBy == "nil" then
                        pane.t.cfg.groupBy = nil
                    end
                    AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
                end
            else
                AF.MergeExistingKeys(pane.t.cfg, copiedCfg)
                LoadIndicatorConfig(pane.t)
            end

            AF.Fire("BFI_RefreshOptions", "unitFrames")
        end)
    end)


    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 107, 20)
    AF.SetPoint(reset, "TOPLEFT", paste, "TOPRIGHT", 7, 0)
    reset:SetOnClick(function()
        local which
        if pane.t.id:find("^general") then
            which = IsShiftKeyDown() and "All Settings" or "General"
        else
            which = pane.t.id
        end
        local text = AF.WrapTextInColor(L["Reset to default settings?"], "BFI") .. "\n"
            .. AF.WrapTextInColor(L[which], "softlime") .. "\n"
            .. pane.t.ownerName

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            wipe(pane.t.cfg)

            if pane.t.id:find("^general") then
                if which == "All Settings" then
                    UF.ResetFrame(pane.t.owner)
                    AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner)
                else
                    UF.ResetFrame(pane.t.owner, "general")
                    AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
                end
            else
                UF.ResetFrame(pane.t.owner, pane.t.id)
                LoadIndicatorConfig(pane.t)
            end

            AF.Fire("BFI_RefreshOptions", "unitFrames") -- and reload option panes
        end)
    end)

    local resetTooltips = {_G.RESET, L["Hold %s while clicking to reset all settings for this unit frame"]:format(AF.WrapTextInColor("Shift", "BFI"))}
    reset._tooltipOwner = BFIOptionsFrame_UnitFramesPanel
    reset:HookOnEnter(function()
        if pane.t.id:find("^general") then
            AF.ShowTooltip(reset, "TOPLEFT", 0, 2, resetTooltips)
        end
    end)
    reset:HookOnLeave(AF.HideTooltip)

    function pane.Load(t)
        pane.t = t
        paste:SetEnabled(t.id == copiedId)

        if t.id:find("^general") then
            AF.ApplyCombatProtectionToFrame(parent, 0, 0, 0, 0)
        else
            AF.RemoveCombatProtectionFromFrame(parent)
        end
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Enabled", nil, 30)
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
        -- pane.t is list button that carries info
        pane.t:SetTextColor(checked and "white" or "disabled")
        if pane.t.id:find("^general") then
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner)
            AF.Fire("BFI_RefreshOptions", "unitFrames")
        else
            LoadIndicatorConfig(pane.t)
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
-- width,height
---------------------------------------------------------------------
builder["width,height"] = function(parent)
    if created["width,height"] then return created["width,height"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_WidthHeight", nil, 55)
    created["width,height"] = pane

    local function ShowPreviewRect()
        if pane.t.id == "general_single" then
            AF.FrameFadeInOut(pane.t.target.previewRect, nil, nil, true)
        elseif pane.t.id == "general_party" then
            for i = 1, 5 do
                AF.FrameFadeInOut(pane.t.target.header[i].previewRect, nil, nil, true)
            end
        elseif pane.t.id == "general_raid" then
            for i = 1, 40 do
                AF.FrameFadeInOut(pane.t.target.header[i].previewRect, nil, nil, true)
            end
        elseif pane.t.id == "general_boss" then
            for i = 1, 8 do
                AF.FrameFadeInOut(pane.t.target[i].previewRect, nil, nil, true)
            end
        end
    end

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(width, "LEFT", 15, 0)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        if pane.t.id:find("^general") then
            ShowPreviewRect()
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        else
            LoadIndicatorConfig(pane.t)
        end
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 1000, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        if pane.t.id:find("^general") then
            ShowPreviewRect()
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        else
            LoadIndicatorConfig(pane.t)
        end
    end)

    function pane.Load(t)
        pane.t = t
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
    end

    return pane
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
builder["size"] = function(parent)
    if created["size"] then return created["size"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Size", nil, 55)
    created["size"] = pane

    local size = AF.CreateSlider(pane, L["Size"], 150, 5, 100, 1, nil, true)
    AF.SetPoint(size, "LEFT", 15, 0)
    size:SetOnValueChanged(function(value)
        pane.t.cfg.size = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t

        if t.id:find("Highlight$") then
            size:SetMinMaxValues(-10, 10)
        elseif t.id:find("Glow$") then
            size:SetMinMaxValues(3, 20)
        else
            size:SetMinMaxValues(5, 100)
        end

        size:SetValue(t.cfg.size)
    end

    return pane
end

---------------------------------------------------------------------
-- position,anchorTo
---------------------------------------------------------------------
builder["position,anchorTo"] = function(parent)
    if created["position,anchorTo"] then return created["position,anchorTo"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_PositionAnchorTo", nil, 148)
    created["position,anchorTo"] = pane

    local validRelativeTos = GetAnchorToItems()

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems(validRelativeTos)
    relativeTo:SetOnSelect(function(value)
        pane.t.cfg.anchorTo = value
        LoadIndicatorPosition(pane.t)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, 0, -45)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.position[1] = value
        LoadIndicatorPosition(pane.t)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.position[2] = value
        LoadIndicatorPosition(pane.t)
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)
    x:SetOnValueChanged(function(value)
        pane.t.cfg.position[3] = value
        LoadIndicatorPosition(pane.t)
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetOnValueChanged(function(value)
        pane.t.cfg.position[4] = value
        LoadIndicatorPosition(pane.t)
    end)

    function pane.Load(t)
        pane.t = t

        UpdateAnchorToItems(t, validRelativeTos)
        relativeTo.reloadRequired = true

        relativeTo:SetSelectedValue(t.cfg.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- position,anchorTo,parent
---------------------------------------------------------------------
builder["position,anchorTo,parent"] = function(parent)
    if created["position,anchorTo,parent"] then return created["position,anchorTo,parent"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_PositionAnchorToParent", nil, 150)
    created["position,anchorTo,parent"] = pane

    local validRelativeTos = GetAnchorToItems()

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "TOPLEFT", 15, -25)
    relativeTo:SetItems(validRelativeTos)
    relativeTo:SetOnSelect(function(value)
        pane.t.cfg.anchorTo = value
        LoadIndicatorPosition(pane.t)
    end)

    local parent = AF.CreateDropdown(pane, 150)
    parent:SetLabel(L["Parent"])
    AF.SetPoint(parent, "TOPLEFT", relativeTo, 185, 0)
    parent:SetItems(GetParentItems())
    parent:SetOnSelect(function(value)
        pane.t.cfg.parent = value
        LoadIndicatorPosition(pane.t)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", relativeTo, 0, -45)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.position[1] = value
        LoadIndicatorPosition(pane.t)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.position[2] = value
        LoadIndicatorPosition(pane.t)
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)
    x:SetOnValueChanged(function(value)
        pane.t.cfg.position[3] = value
        LoadIndicatorPosition(pane.t)
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetOnValueChanged(function(value)
        pane.t.cfg.position[4] = value
        LoadIndicatorPosition(pane.t)
    end)

    function pane.Load(t)
        pane.t = t

        UpdateAnchorToItems(t, validRelativeTos)
        relativeTo.reloadRequired = true

        relativeTo:SetSelectedValue(t.cfg.anchorTo)
        parent:SetSelectedValue(t.cfg.parent)
        anchorPoint:SetSelectedValue(t.cfg.position[1])
        relativePoint:SetSelectedValue(t.cfg.position[2])
        x:SetValue(t.cfg.position[3])
        y:SetValue(t.cfg.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- frameLevel
---------------------------------------------------------------------
builder["frameLevel"] = function(parent)
    if created["frameLevel"] then return created["frameLevel"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_FrameLevel", nil, 55)
    created["frameLevel"] = pane

    local frameLevel = AF.CreateSlider(pane, L["Frame Level"], 150, 0, 100, 1, nil, true)
    AF.SetPoint(frameLevel, "LEFT", 15, 0)
    frameLevel:SetOnValueChanged(function(value)
        pane.t.cfg.frameLevel = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        frameLevel:SetValue(t.cfg.frameLevel)
    end

    return pane
end

---------------------------------------------------------------------
-- smoothing
---------------------------------------------------------------------
builder["smoothing"] = function(parent)
    if created["smoothing"] then return created["smoothing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Smoothing", nil, 30)
    created["smoothing"] = pane

    local smoothing = AF.CreateCheckButton(pane, L["Smooth Bar Transition"])
    AF.SetPoint(smoothing, "LEFT", 15, 0)
    smoothing:SetOnCheck(function(checked)
        pane.t.cfg.smoothing = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        smoothing:SetChecked(t.cfg.smoothing)
    end

    return pane
end

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
builder["texture"] = function(parent)
    if created["texture"] then return created["texture"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Texture", nil, 55)
    created["texture"] = pane

    local texture = AF.CreateDropdown(pane, 150)
    texture:SetLabel(L["Texture"])
    AF.SetPoint(texture, "TOPLEFT", 15, -25)
    texture:SetItems(AF.LSM_GetBarTextureDropdownItems())
    texture:SetOnSelect(function(value)
        pane.t.cfg.texture = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        texture:SetSelectedValue(t.cfg.texture)
    end

    return pane
end

---------------------------------------------------------------------
-- pane for bar colors
---------------------------------------------------------------------
local function CreatePaneForBarColors(parent, colorType, frameName, label, gradientLabel, alphaLabel)
    local pane = AF.CreateBorderedFrame(parent, frameName, nil, 103)

    -- color --------------------------------------------------
    local colorDropdown = AF.CreateDropdown(pane, 150)
    colorDropdown:SetLabel(label)
    AF.SetPoint(colorDropdown, "TOPLEFT", 15, -25)

    local orientationDropdown = AF.CreateDropdown(pane, 150)
    orientationDropdown:SetLabel(gradientLabel)
    AF.SetPoint(orientationDropdown, "TOPLEFT", colorDropdown, 185, 0)
    orientationDropdown:SetItems({
        {text = L["Disabled"], value = "disabled"},
        {text = L["Horizontal"], value = "horizontal"},
        {text = L["Horizontal (Flipped)"], value = "horizontal_flipped"},
        {text = L["Vertical"], value = "vertical"},
        {text = L["Vertical (Flipped)"], value = "vertical_flipped"},
    })

    local colorPicker1 = AF.CreateColorPicker(pane)
    colorPicker1:SetOnChange(function(r, g, b, a)
        if #pane.t.cfg[colorType].rgb == 4 then
            pane.t.cfg[colorType].rgb[1] = r
            pane.t.cfg[colorType].rgb[2] = g
            pane.t.cfg[colorType].rgb[3] = b
        else
            pane.t.cfg[colorType].rgb[1][1] = r
            pane.t.cfg[colorType].rgb[1][2] = g
            pane.t.cfg[colorType].rgb[1][3] = b
        end
        LoadIndicatorConfig(pane.t)
    end)

    local colorPicker2 = AF.CreateColorPicker(pane)
    colorPicker2:SetOnChange(function(r, g, b, a)
        pane.t.cfg[colorType].rgb[2][1] = r
        pane.t.cfg[colorType].rgb[2][2] = g
        pane.t.cfg[colorType].rgb[2][3] = b
        LoadIndicatorConfig(pane.t)
    end)

    local colorAlphaSlider1 = AF.CreateSlider(pane, alphaLabel .. " 1", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(colorAlphaSlider1, "TOPLEFT", colorDropdown, 0, -45)
    colorAlphaSlider1:SetOnValueChanged(function(value)
        if pane.t.cfg[colorType].gradient == "disabled" then
            pane.t.cfg[colorType].alpha = value
        else
            pane.t.cfg[colorType].alpha[1] = value
        end
        LoadIndicatorConfig(pane.t)
    end)

    local colorAlphaSlider2 = AF.CreateSlider(pane, alphaLabel .. " 2", 150, 0, 1, 0.01, true, true)
    AF.SetPoint(colorAlphaSlider2, "TOPLEFT", colorAlphaSlider1, 185, 0)
    colorAlphaSlider2:SetOnValueChanged(function(value)
        pane.t.cfg[colorType].alpha[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateColorWidgets(color)
        AF.ClearPoints(colorPicker1)
        AF.ClearPoints(colorPicker2)

        if color.type:find("^class") or color.type:find("^power") or color.type:find("^mana") then
            if color.gradient == "disabled" then
                colorPicker1:Hide()
                colorPicker2:Hide()

                if type(color.alpha) ~= "number" then color.alpha = 1 end
                colorAlphaSlider1:SetValue(color.alpha)
                colorAlphaSlider2:SetEnabled(false)
            else
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                colorPicker1:Show()
                colorPicker2:Hide()

                if type(color.alpha) ~= "table" then color.alpha = {1, 1} end
                colorAlphaSlider1:SetValue(color.alpha[1])
                colorAlphaSlider2:SetValue(color.alpha[2])
                colorAlphaSlider2:SetEnabled(true)

                if #color.rgb ~= 4 then color.rgb = {1, 1, 1, 1} end
                colorPicker1:SetColor(color.rgb)
            end

        else -- custom_color
            if color.gradient == "disabled" then
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                colorPicker1:Show()
                colorPicker2:Hide()

                if type(color.alpha) ~= "number" then color.alpha = 1 end
                colorAlphaSlider1:SetValue(color.alpha)
                colorAlphaSlider2:SetEnabled(false)

                if #color.rgb ~= 4 then
                    color.rgb = colorType == "color" and AF.GetColorTable("uf") or AF.GetColorTable("uf_loss")
                end
                colorPicker1:SetColor(color.rgb)
            else
                AF.SetPoint(colorPicker2, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
                AF.SetPoint(colorPicker1, "BOTTOMRIGHT", colorPicker2, "BOTTOMLEFT", -2, 0)
                colorPicker1:Show()
                colorPicker2:Show()

                if type(color.alpha) ~= "table" then color.alpha = {1, 1} end
                colorAlphaSlider1:SetValue(color.alpha[1])
                colorAlphaSlider2:SetValue(color.alpha[2])
                colorAlphaSlider2:SetEnabled(true)

                if #color.rgb ~= 2 then color.rgb = {AF.GetColorTable("blazing_tangerine"), AF.GetColorTable("vivid_raspberry")} end
                colorPicker1:SetColor(color.rgb[1])
                colorPicker2:SetColor(color.rgb[2])
            end
        end
    end

    colorDropdown:SetOnSelect(function(value)
        AF.HideColorPicker()
        pane.t.cfg[colorType].type = value
        UpdateColorWidgets(pane.t.cfg[colorType])
        LoadIndicatorConfig(pane.t)
    end)

    orientationDropdown:SetOnSelect(function(value)
        AF.HideColorPicker()
        pane.t.cfg[colorType].gradient = value
        UpdateColorWidgets(pane.t.cfg[colorType])
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t

        colorDropdown:SetItems(GetColorItems(t.id))
        colorDropdown:SetSelectedValue(t.cfg[colorType].type)
        orientationDropdown:SetSelectedValue(t.cfg[colorType].gradient)
        UpdateColorWidgets(t.cfg[colorType])
    end

    return pane
end

---------------------------------------------------------------------
-- barColor
---------------------------------------------------------------------
builder["barColor"] = function(parent)
    if created["barColor"] then return created["barColor"] end

    created["barColor"] = CreatePaneForBarColors(parent, "color", "BFI_UnitFrameOption_BarColor", L["Bar Color"], L["Bar Gradient"], L["Bar Alpha"])
    return created["barColor"]
end

---------------------------------------------------------------------
-- barLossColor
---------------------------------------------------------------------
builder["barLossColor"] = function(parent)
    if created["barLossColor"] then return created["barLossColor"] end

    created["barLossColor"] = CreatePaneForBarColors(parent, "lossColor", "BFI_UnitFrameOption_BarLossColor", L["Loss Color"], L["Loss Gradient"], L["Loss Alpha"])
    return created["barLossColor"]
end

---------------------------------------------------------------------
-- bgColor,borderColor
---------------------------------------------------------------------
builder["bgColor,borderColor"] = function(parent)
    if created["bgColor,borderColor"] then return created["bgColor,borderColor"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_BgBorderColor", nil, 30)
    created["bgColor,borderColor"] = pane

    local bgColor = AF.CreateColorPicker(pane, L["Background Color"], true)
    AF.SetPoint(bgColor, "LEFT", 15, 0)
    bgColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.bgColor[1] = r
        pane.t.cfg.bgColor[2] = g
        pane.t.cfg.bgColor[3] = b
        pane.t.cfg.bgColor[4] = a
        if pane.t.id:find("^general") then
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        else
            LoadIndicatorConfig(pane.t)
        end
    end)

    local borderColor = AF.CreateColorPicker(pane, L["Border Color"], true)
    AF.SetPoint(borderColor, "TOPLEFT", bgColor, 185, 0)
    borderColor:SetOnChange(function(r, g, b, a)
        pane.t.cfg.borderColor[1] = r
        pane.t.cfg.borderColor[2] = g
        pane.t.cfg.borderColor[3] = b
        pane.t.cfg.borderColor[4] = a
        if pane.t.id:find("^general") then
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        else
            LoadIndicatorConfig(pane.t)
        end
    end)

    function pane.Load(t)
        pane.t = t
        bgColor:SetColor(t.cfg.bgColor)
        borderColor:SetColor(t.cfg.borderColor)
    end

    return created["bgColor,borderColor"]
end

---------------------------------------------------------------------
-- healPrediction
---------------------------------------------------------------------
builder["healPrediction"] = function(parent)
    if created["healPrediction"] then return created["healPrediction"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HealPrediction", nil, 51)
    created["healPrediction"] = pane

    local healPredictionCheckButton = AF.CreateCheckButton(pane, L["Heal Prediction"])
    AF.SetPoint(healPredictionCheckButton, "TOPLEFT", 15, -8)
    healPredictionCheckButton:SetOnCheck(function(checked)
        t.cfg.healPrediction = checked
        UF.LoadIndicatorConfig(t.target, t.id, t.cfg)
    end)

    local customColorCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(customColorCheckButton, "TOPLEFT", healPredictionCheckButton, "BOTTOMLEFT", 0, -7)

    local customColorPicker = AF.CreateColorPicker(pane, L["Custom Color"], true)
    AF.SetPoint(customColorPicker, "TOPLEFT", customColorCheckButton, "TOPRIGHT", 2, 0)
    customColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.healPrediction.color[1] = r
        pane.t.cfg.healPrediction.color[2] = g
        pane.t.cfg.healPrediction.color[3] = b
        pane.t.cfg.healPrediction.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.healPrediction.enabled, customColorCheckButton, customColorPicker)
        customColorPicker:SetEnabled(pane.t.cfg.healPrediction.useCustomColor)
    end

    healPredictionCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healPrediction.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    customColorCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healPrediction.useCustomColor = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        healPredictionCheckButton:SetChecked(t.cfg.healPrediction.enabled)
        customColorCheckButton:SetChecked(t.cfg.healPrediction.useCustomColor)
        customColorPicker:SetColor(t.cfg.healPrediction.color)
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- shield,overshieldGlow
---------------------------------------------------------------------
builder["shield,overshieldGlow"] = function(parent)
    if created["shield,overshieldGlow"] then return created["shield,overshieldGlow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Shields", nil, 78)
    created["shield,overshieldGlow"] = pane

    local shieldDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(shieldDropdown, "TOPLEFT", 15, -25)
    local items = AF.LSM_GetBarTextureDropdownItems()
    tinsert(items, 1, {text = _G.DEFAULT, value = "default"})
    shieldDropdown:SetItems(items)

    local shieldCheckButton = AF.CreateCheckButton(pane, L["Shield"])
    AF.SetPoint(shieldCheckButton, "BOTTOMLEFT", shieldDropdown, "TOPLEFT", 0, 2)

    local shieldColorPicker = AF.CreateColorPicker(pane, nil, true)
    AF.SetPoint(shieldColorPicker, "BOTTOMRIGHT", shieldDropdown, "TOPRIGHT", 0, 2)
    shieldColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.shield.color[1] = r
        pane.t.cfg.shield.color[2] = g
        pane.t.cfg.shield.color[3] = b
        pane.t.cfg.shield.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    local shieldReverseFillCheckButton = AF.CreateCheckButton(pane, L["Reverse Fill"])
    AF.SetPoint(shieldReverseFillCheckButton, "TOPLEFT", shieldDropdown, "BOTTOMLEFT", 0, -10)
    shieldReverseFillCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.shield.reverseFill = checked
        LoadIndicatorConfig(pane.t)
    end)

    local overshieldGlowCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(overshieldGlowCheckButton, "LEFT", shieldDropdown, 185, 0)

    local overshieldGlowColorPicker = AF.CreateColorPicker(pane, L["Overshield Texture"], true)
    AF.SetPoint(overshieldGlowColorPicker, "TOPLEFT", overshieldGlowCheckButton, "TOPRIGHT", 2, 0)
    overshieldGlowColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.overshieldGlow.color[1] = r
        pane.t.cfg.overshieldGlow.color[2] = g
        pane.t.cfg.overshieldGlow.color[3] = b
        pane.t.cfg.overshieldGlow.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()

        AF.SetEnabled(pane.t.cfg.shield.enabled, shieldDropdown, shieldColorPicker, shieldReverseFillCheckButton)
        AF.SetEnabled(pane.t.cfg.overshieldGlow.enabled, overshieldGlowColorPicker)

        shieldCheckButton:SetChecked(pane.t.cfg.shield.enabled)
        shieldDropdown:SetSelectedValue(pane.t.cfg.shield.texture)
        shieldColorPicker:SetColor(pane.t.cfg.shield.color)
        shieldReverseFillCheckButton:SetChecked(pane.t.cfg.shield.reverseFill)

        overshieldGlowCheckButton:SetChecked(pane.t.cfg.overshieldGlow.enabled)
        overshieldGlowColorPicker:SetColor(pane.t.cfg.overshieldGlow.color)
    end

    shieldDropdown:SetOnSelect(function(value)
        pane.t.cfg.shield.texture = value
        LoadIndicatorConfig(pane.t)
    end)

    shieldCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.shield.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    overshieldGlowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.overshieldGlow.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- healAbsorb,overabsorbGlow
---------------------------------------------------------------------
builder["healAbsorb,overabsorbGlow"] = function(parent)
    if created["healAbsorb,overabsorbGlow"] then return created["healAbsorb,overabsorbGlow"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HealAbsorbs", nil, 54)
    created["healAbsorb,overabsorbGlow"] = pane

    local absorbDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(absorbDropdown, "TOPLEFT", 15, -25)
    local items = AF.LSM_GetBarTextureDropdownItems()
    tinsert(items, 1, {text = _G.DEFAULT, value = "default"})
    absorbDropdown:SetItems(items)

    local absorbCheckButton = AF.CreateCheckButton(pane, L["Heal Absorb"])
    AF.SetPoint(absorbCheckButton, "BOTTOMLEFT", absorbDropdown, "TOPLEFT", 0, 2)

    local absorbColorPicker = AF.CreateColorPicker(pane, nil, true)
    AF.SetPoint(absorbColorPicker, "BOTTOMRIGHT", absorbDropdown, "TOPRIGHT", 0, 2)
    absorbColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.healAbsorb.color[1] = r
        pane.t.cfg.healAbsorb.color[2] = g
        pane.t.cfg.healAbsorb.color[3] = b
        pane.t.cfg.healAbsorb.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    local overabsorbGlowCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(overabsorbGlowCheckButton, "LEFT", absorbDropdown, 185, 0)

    local overabsorbGlowColorPicker = AF.CreateColorPicker(pane, L["Overabsorb Texture"], true)
    AF.SetPoint(overabsorbGlowColorPicker, "TOPLEFT", overabsorbGlowCheckButton, "TOPRIGHT", 2, 0)
    overabsorbGlowColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.overabsorbGlow.color[1] = r
        pane.t.cfg.overabsorbGlow.color[2] = g
        pane.t.cfg.overabsorbGlow.color[3] = b
        pane.t.cfg.overabsorbGlow.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()

        AF.SetEnabled(pane.t.cfg.healAbsorb.enabled, absorbDropdown, absorbColorPicker)
        AF.SetEnabled(pane.t.cfg.overabsorbGlow.enabled, overabsorbGlowColorPicker)

        absorbCheckButton:SetChecked(pane.t.cfg.healAbsorb.enabled)
        absorbDropdown:SetSelectedValue(pane.t.cfg.healAbsorb.texture)
        absorbColorPicker:SetColor(pane.t.cfg.healAbsorb.color)

        overabsorbGlowCheckButton:SetChecked(pane.t.cfg.overabsorbGlow.enabled)
        overabsorbGlowColorPicker:SetColor(pane.t.cfg.overabsorbGlow.color)
    end

    absorbDropdown:SetOnSelect(function(value)
        pane.t.cfg.healAbsorb.texture = value
        LoadIndicatorConfig(pane.t)
    end)

    absorbCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.healAbsorb.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    overabsorbGlowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.overabsorbGlow.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- mouseoverHighlight
---------------------------------------------------------------------
builder["mouseoverHighlight"] = function(parent)
    if created["mouseoverHighlight"] then return created["mouseoverHighlight"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_MouseoverHighlight", nil, 30)
    created["mouseoverHighlight"] = pane

    local mouseoverHighlightCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(mouseoverHighlightCheckButton, "LEFT", 15, 0)

    local mouseoverHighlightColorPicker = AF.CreateColorPicker(pane, L["Mouseover Highlight Color"], true)
    AF.SetPoint(mouseoverHighlightColorPicker, "TOPLEFT", mouseoverHighlightCheckButton, "TOPRIGHT", 2, 0)
    mouseoverHighlightColorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.mouseoverHighlight.color[1] = r
        pane.t.cfg.mouseoverHighlight.color[2] = g
        pane.t.cfg.mouseoverHighlight.color[3] = b
        pane.t.cfg.mouseoverHighlight.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    mouseoverHighlightCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.mouseoverHighlight.enabled = checked
        mouseoverHighlightColorPicker:SetEnabled(checked)
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        mouseoverHighlightCheckButton:SetChecked(t.cfg.mouseoverHighlight.enabled)
        mouseoverHighlightColorPicker:SetColor(t.cfg.mouseoverHighlight.color)
        mouseoverHighlightColorPicker:SetEnabled(t.cfg.mouseoverHighlight.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- dispelHighlight
---------------------------------------------------------------------
builder["dispelHighlight"] = function(parent)
    if created["dispelHighlight"] then return created["dispelHighlight"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_DispelHighlight", nil, 80)
    created["dispelHighlight"] = pane

    local dispelHighlightCheckButton = AF.CreateCheckButton(pane, L["Dispel Highlight"])
    AF.SetPoint(dispelHighlightCheckButton, "TOPLEFT", 15, -8)

    local onlyDispellableCheckButton = AF.CreateCheckButton(pane, L["Only Dispellable"])
    AF.SetPoint(onlyDispellableCheckButton, "TOPLEFT", dispelHighlightCheckButton, 185, 0)
    onlyDispellableCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.dispelHighlight.dispellable = checked
        LoadIndicatorConfig(pane.t)
    end)

    local alphaSlider = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alphaSlider, "TOPLEFT", dispelHighlightCheckButton, "BOTTOMLEFT", 0, -25)
    alphaSlider:SetOnValueChanged(function(value)
        pane.t.cfg.dispelHighlight.alpha = value
        LoadIndicatorConfig(pane.t)
    end)

    local blendModeDropdown = AF.CreateDropdown(pane, 150)
    blendModeDropdown:SetLabel(L["Blend Mode"])
    AF.SetPoint(blendModeDropdown, "TOPLEFT", alphaSlider, 185, 0)
    blendModeDropdown:SetItems({
        {text = "DISABLE"},
        {text = "ADD"},
        -- {text = "ALPHAKEY"},
        -- {text = "BLEND"},
        {text = "MOD"},
    })
    blendModeDropdown:SetOnSelect(function(value)
        pane.t.cfg.dispelHighlight.blendMode = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.dispelHighlight.enabled, onlyDispellableCheckButton, alphaSlider, blendModeDropdown)

        dispelHighlightCheckButton:SetChecked(pane.t.cfg.dispelHighlight.enabled)
        onlyDispellableCheckButton:SetChecked(pane.t.cfg.dispelHighlight.dispellable)
        alphaSlider:SetValue(pane.t.cfg.dispelHighlight.alpha)
        blendModeDropdown:SetSelectedValue(pane.t.cfg.dispelHighlight.blendMode)
    end

    dispelHighlightCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.dispelHighlight.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
    end

    return pane
end

---------------------------------------------------------------------
-- frequent
---------------------------------------------------------------------
builder["frequent"] = function(parent)
    if created["frequent"] then return created["frequent"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Frequent", nil, 30)
    created["frequent"] = pane

    local frequentCheckButton = AF.CreateCheckButton(pane, L["Frequent Updates"])
    AF.SetPoint(frequentCheckButton, "LEFT", 15, 0)
    frequentCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.frequent = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        frequentCheckButton:SetChecked(t.cfg.frequent)
    end

    return pane
end

---------------------------------------------------------------------
-- style,model
---------------------------------------------------------------------
builder["style,model"] = function(parent)
    if created["style,model"] then return created["style,model"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_PortraitStyle", nil, 252)
    created["style,model"] = pane

    local styleDropdown = AF.CreateDropdown(pane, 150)
    styleDropdown:SetLabel(L["Style"])
    AF.SetPoint(styleDropdown, "TOPLEFT", 15, -25)
    styleDropdown:SetItems({
        {text = "3D", value = "3d"},
        {text = "2D", value = "2d"},
        {text = L["Class Icon"], value = "class_icon"},
    })

    local warningText = AF.CreateFontString(pane, L["3D portraits may cause FPS drops"])
    AF.SetPoint(warningText, "BOTTOMLEFT", styleDropdown, 185, 3)
    warningText:Hide()
    warningText:SetWidth(150)
    warningText:SetSpacing(5)
    warningText:SetColor("firebrick")
    AF.CreateBlinkAnimation(warningText, 0.75, true)

    local xSlider = AF.CreateSlider(pane, L["X Offset"], 150, -200, 200, 1, nil, true)
    AF.SetPoint(xSlider, "TOPLEFT", styleDropdown, 0, -45)
    xSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.xOffset = value
        LoadIndicatorConfig(pane.t)
    end)

    local ySlider = AF.CreateSlider(pane, L["Y Offset"], 150, -200, 200, 1, nil, true)
    AF.SetPoint(ySlider, "TOPLEFT", xSlider, 185, 0)
    ySlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.yOffset = value
        LoadIndicatorConfig(pane.t)
    end)

    local rotationSlider = AF.CreateSlider(pane, L["Rotation"], 150, 0, 360, 1, nil, true)
    AF.SetPoint(rotationSlider, "TOPLEFT", xSlider, 0, -49)
    rotationSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.rotation = value
        LoadIndicatorConfig(pane.t)
    end)

    local distanceSlider = AF.CreateSlider(pane, L["Distance"], 150, 0.5, 5, 0.01, nil, true)
    AF.SetPoint(distanceSlider, "TOPLEFT", rotationSlider, 185, 0)
    distanceSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.camDistanceScale = value
        LoadIndicatorConfig(pane.t)
    end)

    local x1FixSlider = AF.CreateSlider(pane, L["TopLeft X Fix"], 150, -3, 3, 0.5, nil, true)
    AF.SetPoint(x1FixSlider, "TOPLEFT", rotationSlider, 0, -49)
    x1FixSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.x1Fix = value
        LoadIndicatorConfig(pane.t)
    end)

    local y1FixSlider = AF.CreateSlider(pane, L["TopLeft Y Fix"], 150, -3, 3, 0.5, nil, true)
    AF.SetPoint(y1FixSlider, "TOPLEFT", x1FixSlider, 185, 0)
    y1FixSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.y1Fix = value
        LoadIndicatorConfig(pane.t)
    end)

    local x2FixSlider = AF.CreateSlider(pane, L["BottomRight X Fix"], 150, -3, 3, 0.5, nil, true)
    AF.SetPoint(x2FixSlider, "TOPLEFT", x1FixSlider, 0, -49)
    x2FixSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.x2Fix = value
        LoadIndicatorConfig(pane.t)
    end)

    local y2FixSlider = AF.CreateSlider(pane, L["BottomRight Y Fix"], 150, -3, 3, 0.5, nil, true)
    AF.SetPoint(y2FixSlider, "TOPLEFT", x2FixSlider, 185, 0)
    y2FixSlider:SetOnValueChanged(function(value)
        pane.t.cfg.model.y2Fix = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.style == "3d", xSlider, ySlider, rotationSlider, distanceSlider, x1FixSlider, y1FixSlider, x2FixSlider, y2FixSlider)
        warningText:SetShown(pane.t.cfg.style == "3d")
    end

    styleDropdown:SetOnSelect(function(value)
        pane.t.cfg.style = value
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
        styleDropdown:SetSelectedValue(t.cfg.style)
        xSlider:SetValue(t.cfg.model.xOffset)
        ySlider:SetValue(t.cfg.model.yOffset)
        rotationSlider:SetValue(t.cfg.model.rotation)
        distanceSlider:SetValue(t.cfg.model.camDistanceScale)
        x1FixSlider:SetValue(t.cfg.model.x1Fix)
        y1FixSlider:SetValue(t.cfg.model.y1Fix)
        x2FixSlider:SetValue(t.cfg.model.x2Fix)
        y2FixSlider:SetValue(t.cfg.model.y2Fix)
    end

    return pane
end

---------------------------------------------------------------------
-- interruptibleCheck
---------------------------------------------------------------------
builder["interruptibleCheck"] = function(parent)
    if created["interruptibleCheck"] then return created["interruptibleCheck"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_InterruptibleCheck", nil, 93)
    created["interruptibleCheck"] = pane

    local enableInterruptibleCheck = AF.CreateCheckButton(pane, L["Enable Interruptible Check"])
    AF.SetPoint(enableInterruptibleCheck, "TOPLEFT", 15, -8)

    local requireInterruptUsable = AF.CreateCheckButton(pane, L["Require Interrupt Usable"])
    AF.SetPoint(requireInterruptUsable, "TOPLEFT", enableInterruptibleCheck, "BOTTOMLEFT", 0, -7)
    requireInterruptUsable._tooltipOwner = BFIOptionsFrame_UnitFramesPanel
    requireInterruptUsable:SetTooltip(L["Only show interruptible color when interrupt is usable"])
    requireInterruptUsable:SetOnCheck(function(checked)
        pane.t.cfg.interruptibleCheck.requireUsable = checked
        LoadIndicatorConfig(pane.t)
    end)

    local showUninterruptibleTexture = AF.CreateCheckButton(pane, L["Show Uninterruptible Texture"])
    AF.SetPoint(showUninterruptibleTexture, "TOPLEFT", requireInterruptUsable, "BOTTOMLEFT", 0, -7)
    showUninterruptibleTexture:SetOnCheck(function(checked)
        pane.t.cfg.interruptibleCheck.showTexture = checked
        LoadIndicatorConfig(pane.t)
    end)

    local changeBorderColor = AF.CreateCheckButton(pane, L["Change Border Color"])
    AF.SetPoint(changeBorderColor, "TOPLEFT", showUninterruptibleTexture, "BOTTOMLEFT", 0, -7)
    changeBorderColor:SetOnCheck(function(checked)
        pane.t.cfg.interruptibleCheck.colorBorder = checked
        LoadIndicatorConfig(pane.t)
    end)

    enableInterruptibleCheck:SetOnCheck(function(checked)
        pane.t.cfg.interruptibleCheck.enabled = checked
        AF.SetEnabled(checked, requireInterruptUsable, showUninterruptibleTexture, changeBorderColor)
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        enableInterruptibleCheck:SetChecked(t.cfg.interruptibleCheck.enabled)
        requireInterruptUsable:SetChecked(t.cfg.interruptibleCheck.requireUsable)
        showUninterruptibleTexture:SetChecked(t.cfg.interruptibleCheck.showTexture)
        changeBorderColor:SetChecked(t.cfg.interruptibleCheck.colorBorder)
        AF.SetEnabled(pane.t.cfg.interruptibleCheck.enabled, requireInterruptUsable, showUninterruptibleTexture, changeBorderColor)
    end

    return pane
end

---------------------------------------------------------------------
-- showIcon
---------------------------------------------------------------------
builder["showIcon"] = function(parent)
    if created["showIcon"] then return created["showIcon"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_ShowIcon", nil, 30)
    created["showIcon"] = pane

    local showIconCheckButton = AF.CreateCheckButton(pane, L["Show Icon"])
    AF.SetPoint(showIconCheckButton, "LEFT", 15, 0)
    showIconCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.showIcon = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        showIconCheckButton:SetChecked(t.cfg.showIcon)
    end

    return pane
end

---------------------------------------------------------------------
-- showLatency
---------------------------------------------------------------------
builder["showLatency"] = function(parent)
    if created["showLatency"] then return created["showLatency"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_ShowLatency", nil, 30)
    created["showLatency"] = pane

    local showLatencyCheckButton = AF.CreateCheckButton(pane, L["Show Latency"])
    AF.SetPoint(showLatencyCheckButton, "LEFT", 15, 0)
    showLatencyCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.showLatency = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.IsApplicable(t)
        return t.owner == "player"
    end

    function pane.Load(t)
        pane.t = t
        showLatencyCheckButton:SetChecked(t.cfg.showLatency)
    end

    return pane
end

---------------------------------------------------------------------
-- fadeDuration
---------------------------------------------------------------------
builder["fadeDuration"] = function(parent)
    if created["fadeDuration"] then return created["fadeDuration"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_FadeDuration", nil, 55)
    created["fadeDuration"] = pane

    local fadeDurationSlider = AF.CreateSlider(pane, L["Fade Duration"], 150, 0, 2, 0.1, nil, true)
    AF.SetPoint(fadeDurationSlider, "LEFT", 15, 0)
    fadeDurationSlider:SetAfterValueChanged(function(value)
        pane.t.cfg.fadeDuration = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        fadeDurationSlider:SetValue(t.cfg.fadeDuration)
    end

    return pane
end

---------------------------------------------------------------------
-- spark
---------------------------------------------------------------------
builder["spark"] = function(parent)
    if created["spark"] then return created["spark"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Spark", nil, 80)
    created["spark"] = pane

    local sparkCheckButton = AF.CreateCheckButton(pane, L["Spark"])
    AF.SetPoint(sparkCheckButton, "TOPLEFT", 15, -8)

    local sparkWidthSlider = AF.CreateSlider(pane, L["Width"], 150, 1, 1000, 1, nil, true)
    AF.SetPoint(sparkWidthSlider, "TOPLEFT", sparkCheckButton, "BOTTOMLEFT", 0, -25)
    sparkWidthSlider:SetOnValueChanged(function(value)
        pane.t.cfg.spark.width = value
        LoadIndicatorConfig(pane.t)
    end)

    local sparkHeightSlider = AF.CreateSlider(pane, L["Height"], 150, 0, 1000, 1, nil, true)
    AF.SetPoint(sparkHeightSlider, "TOPLEFT", sparkWidthSlider, 185, 0)
    sparkHeightSlider:SetOnValueChanged(function(value)
        pane.t.cfg.spark.height = value
        LoadIndicatorConfig(pane.t)
    end)

    sparkCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.spark.enabled = checked
        AF.SetEnabled(checked, sparkWidthSlider, sparkHeightSlider)
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        sparkCheckButton:SetChecked(t.cfg.spark.enabled)
        sparkWidthSlider:SetValue(t.cfg.spark.width)
        sparkHeightSlider:SetValue(t.cfg.spark.height)
        AF.SetEnabled(t.cfg.spark.enabled, sparkWidthSlider, sparkHeightSlider)
    end

    return pane
end

---------------------------------------------------------------------
-- ticks
---------------------------------------------------------------------
builder["ticks"] = function(parent)
    if created["ticks"] then return created["ticks"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Ticks", nil, 55)
    created["ticks"] = pane

    local ticksCheckButton = AF.CreateCheckButton(pane, L["Ticks"])
    AF.SetPoint(ticksCheckButton, "LEFT", 15, 0)

    local ticksWidthSlider = AF.CreateSlider(pane, L["Width"], 150, 1, 50, 1, nil, true)
    AF.SetPoint(ticksWidthSlider, "LEFT", ticksCheckButton, 185, 0)
    ticksWidthSlider:SetOnValueChanged(function(value)
        pane.t.cfg.ticks.width = value
        LoadIndicatorConfig(pane.t)
    end)

    ticksCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.ticks.enabled = checked
        ticksWidthSlider:SetEnabled(checked)
        LoadIndicatorConfig(pane.t)
    end)

    function pane.IsApplicable(t)
        return t.owner == "player"
    end

    function pane.Load(t)
        pane.t = t
        ticksCheckButton:SetChecked(t.cfg.ticks.enabled)
        ticksWidthSlider:SetValue(t.cfg.ticks.width)
        ticksWidthSlider:SetEnabled(t.cfg.ticks.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- castBarNameText
---------------------------------------------------------------------
builder["castBarNameText"] = function(parent)
    if created["castBarNameText"] then return created["castBarNameText"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_CastBarNameText", nil, 246)
    created["castBarNameText"] = pane

    local enabledCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(enabledCheckButton, "TOPLEFT", 15, -8)

    local colorPicker = AF.CreateColorPicker(pane, AF.GetGradientText(L["Name Text"], "BFI", "white"))
    AF.SetPoint(colorPicker, "TOPLEFT", enabledCheckButton, "TOPRIGHT", 2, 0)
    colorPicker:SetOnChange(function(r, g, b)
        pane.t.cfg.nameText.color[1] = r
        pane.t.cfg.nameText.color[2] = g
        pane.t.cfg.nameText.color[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    local showInterruptSourceCheckButton = AF.CreateCheckButton(pane, L["Show Interrupt Source"])
    AF.SetPoint(showInterruptSourceCheckButton, "TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 0, -7)
    showInterruptSourceCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.nameText.showInterruptSource = checked
        LoadIndicatorConfig(pane.t)
    end)

    local lengthSlider = AF.CreateSlider(pane, L["Length"], 150, 0, 1, 0.05, true, true)
    AF.SetPoint(lengthSlider, "TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 185, 0)
    lengthSlider:SetOnValueChanged(function(value)
        pane.t.cfg.nameText.length = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", showInterruptSourceCheckButton, "BOTTOMLEFT", 0, -30)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.nameText.font[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.nameText.font[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.nameText.font[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.nameText.font[4] = checked
        LoadIndicatorConfig(pane.t)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.nameText.position[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.nameText.position[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetOnValueChanged(function(value)
        pane.t.cfg.nameText.position[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetOnValueChanged(function(value)
        pane.t.cfg.nameText.position[4] = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()
        AF.SetEnabled(pane.t.cfg.nameText.enabled, colorPicker, lengthSlider, showInterruptSourceCheckButton,
            fontDropdown, fontOutlineDropdown, fontSizeSlider, shadowCheckButton,
            anchorPoint, relativePoint, xOffset, yOffset)
    end

    enabledCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.nameText.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
        enabledCheckButton:SetChecked(t.cfg.nameText.enabled)
        colorPicker:SetColor(pane.t.cfg.nameText.color)
        showInterruptSourceCheckButton:SetChecked(pane.t.cfg.nameText.showInterruptSource)
        lengthSlider:SetValue(pane.t.cfg.nameText.length)
        fontDropdown:SetSelectedValue(pane.t.cfg.nameText.font[1])
        fontSizeSlider:SetValue(pane.t.cfg.nameText.font[2])
        fontOutlineDropdown:SetSelectedValue(pane.t.cfg.nameText.font[3])
        shadowCheckButton:SetChecked(pane.t.cfg.nameText.font[4])
        anchorPoint:SetSelectedValue(pane.t.cfg.nameText.position[1])
        relativePoint:SetSelectedValue(pane.t.cfg.nameText.position[2])
        xOffset:SetValue(pane.t.cfg.nameText.position[3])
        yOffset:SetValue(pane.t.cfg.nameText.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- castBarDurationText
---------------------------------------------------------------------
builder["castBarDurationText"] = function(parent)
    if created["castBarDurationText"] then return created["castBarDurationText"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_CastBarDurationText", nil, 246)
    created["castBarDurationText"] = pane

    local enabledCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(enabledCheckButton, "TOPLEFT", 15, -8)

    local colorPicker = AF.CreateColorPicker(pane, AF.GetGradientText(L["Duration Text"], "BFI", "white"))
    AF.SetPoint(colorPicker, "TOPLEFT", enabledCheckButton, "TOPRIGHT", 2, 0)
    colorPicker:SetOnChange(function(r, g, b)
        pane.t.cfg.durationText.color[1] = r
        pane.t.cfg.durationText.color[2] = g
        pane.t.cfg.durationText.color[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    local showDelayCheckButton = AF.CreateCheckButton(pane, L["Show Delay"])
    AF.SetPoint(showDelayCheckButton, "TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 0, -7)
    showDelayCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.durationText.showDelay = checked
        LoadIndicatorConfig(pane.t)
    end)

    local formatDropdown = AF.CreateDropdown(pane, 150)
    formatDropdown:SetLabel(L["Format"])
    AF.SetPoint(formatDropdown, "TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 185, 0)
    formatDropdown:SetItems({
        {text = "7", value = "%d"},
        {text = "7.1", value =  "%.1f"},
        {text = "7.12", value = "%.2f"},
    })
    formatDropdown:SetOnSelect(function(value)
        pane.t.cfg.durationText.format = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", showDelayCheckButton, "BOTTOMLEFT", 0, -30)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.durationText.font[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.durationText.font[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.durationText.font[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.durationText.font[4] = checked
        LoadIndicatorConfig(pane.t)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.durationText.position[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.durationText.position[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetOnValueChanged(function(value)
        pane.t.cfg.durationText.position[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetOnValueChanged(function(value)
        pane.t.cfg.durationText.position[4] = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.HideColorPicker()
        AF.SetEnabled(pane.t.cfg.durationText.enabled, colorPicker, formatDropdown, showDelayCheckButton,
            fontDropdown, fontOutlineDropdown, fontSizeSlider, shadowCheckButton,
            anchorPoint, relativePoint, xOffset, yOffset)
    end

    enabledCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.durationText.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
        enabledCheckButton:SetChecked(t.cfg.durationText.enabled)
        colorPicker:SetColor(pane.t.cfg.durationText.color)
        showDelayCheckButton:SetChecked(pane.t.cfg.durationText.showDelay)
        formatDropdown:SetSelectedValue(pane.t.cfg.durationText.format)
        fontDropdown:SetSelectedValue(pane.t.cfg.durationText.font[1])
        fontSizeSlider:SetValue(pane.t.cfg.durationText.font[2])
        fontOutlineDropdown:SetSelectedValue(pane.t.cfg.durationText.font[3])
        shadowCheckButton:SetChecked(pane.t.cfg.durationText.font[4])
        anchorPoint:SetSelectedValue(pane.t.cfg.durationText.position[1])
        relativePoint:SetSelectedValue(pane.t.cfg.durationText.position[2])
        xOffset:SetValue(pane.t.cfg.durationText.position[3])
        yOffset:SetValue(pane.t.cfg.durationText.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- hideIfHasClassPower,hideIfFull
---------------------------------------------------------------------
builder["hideIfHasClassPower,hideIfFull"] = function(parent)
    if created["hideIfHasClassPower,hideIfFull"] then return created["hideIfHasClassPower,hideIfFull"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HideIfHasClassPower", nil, 51)
    created["hideIfHasClassPower,hideIfFull"] = pane

    local hideIfHasClassPowerCheckButton = AF.CreateCheckButton(pane, L["Hide When Class Power Exists"])
    AF.SetPoint(hideIfHasClassPowerCheckButton, "TOPLEFT", 15, -8)
    hideIfHasClassPowerCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideIfHasClassPower = checked
        LoadIndicatorConfig(pane.t)
    end)

    local hideIfFullCheckButton = AF.CreateCheckButton(pane, L["Hide When Full"])
    AF.SetPoint(hideIfFullCheckButton, "TOPLEFT", hideIfHasClassPowerCheckButton, "BOTTOMLEFT", 0, -7)
    hideIfFullCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideIfFull = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        hideIfHasClassPowerCheckButton:SetChecked(t.cfg.hideIfHasClassPower)
        hideIfFullCheckButton:SetChecked(t.cfg.hideIfFull)
    end

    return pane
end

---------------------------------------------------------------------
-- spacing
---------------------------------------------------------------------
builder["spacing"] = function(parent)
    if created["spacing"] then return created["spacing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Spacing", nil, 55)
    created["spacing"] = pane

    local spacingSlider = AF.CreateSlider(pane, L["Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacingSlider, "LEFT", 15, 0)
    spacingSlider:SetAfterValueChanged(function(value)
        pane.t.cfg.spacing = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        spacingSlider:SetValue(t.cfg.spacing)
    end

    return pane
end

---------------------------------------------------------------------
-- CreateFontPositionExtraPane
---------------------------------------------------------------------
local function CreateFontPositionExtraPane(parent, textType, frameName, label, extra)
    local height
    if extra == "format" then
        height = 315
    elseif extra == "duration" then
        height = 277
    else
        height = 198
    end

    local pane = AF.CreateBorderedFrame(parent, frameName, nil, height)

    local fontDropdown = AF.CreateDropdown(pane, 150)
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg[textType].font[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local enabledCheckButton = AF.CreateCheckButton(pane, label)
    AF.SetPoint(enabledCheckButton, "BOTTOMLEFT", fontDropdown, "TOPLEFT", 0, 2)

    local colorPicker = AF.CreateColorPicker(pane)
    AF.SetPoint(colorPicker, "BOTTOMRIGHT", fontDropdown, "TOPRIGHT", 0, 2)
    colorPicker:SetOnChange(function(r, g, b)
        pane.t.cfg[textType].color[1] = r
        pane.t.cfg[textType].color[2] = g
        pane.t.cfg[textType].color[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg[textType].font[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg[textType].font[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg[textType].font[4] = checked
        LoadIndicatorConfig(pane.t)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -40)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg[textType].position[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg[textType].position[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local xOffset = AF.CreateSlider(pane, L["X Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(xOffset, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    xOffset:SetOnValueChanged(function(value)
        pane.t.cfg[textType].position[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local yOffset = AF.CreateSlider(pane, L["Y Offset"], 150, -100, 100, 0.5, nil, true)
    AF.SetPoint(yOffset, "TOPLEFT", xOffset, 185, 0)
    yOffset:SetOnValueChanged(function(value)
        pane.t.cfg[textType].position[4] = value
        LoadIndicatorConfig(pane.t)
    end)

    --------------------------------------------------
    -- format
    local numericFormatDropdown, percentFormatDropdown, delimiterEditBox, percentSignCheckButton, useAsianUnitsCheckButton

    if extra == "format" then
        numericFormatDropdown = AF.CreateDropdown(pane, 250)
        numericFormatDropdown:SetLabel(L["Numeric Format"])
        AF.SetPoint(numericFormatDropdown, "TOPLEFT", xOffset, "BOTTOMLEFT", 0, -45)
        numericFormatDropdown:SetOnSelect(function(value)
            pane.t.cfg[textType].format.numeric = value
            LoadIndicatorConfig(pane.t)
        end)

        percentFormatDropdown = AF.CreateDropdown(pane, 250)
        percentFormatDropdown:SetLabel(L["Percent Format"])
        AF.SetPoint(percentFormatDropdown, "TOPLEFT", numericFormatDropdown, "BOTTOMLEFT", 0, -25)
        percentFormatDropdown:SetOnSelect(function(value)
            pane.t.cfg[textType].format.percent = value
            LoadIndicatorConfig(pane.t)
        end)

        delimiterEditBox = AF.CreateEditBox(pane, L["Delimiter"], 70, 20)
        delimiterEditBox:SetPoint("TOP", numericFormatDropdown)
        delimiterEditBox:SetPoint("RIGHT", yOffset)
        delimiterEditBox:SetMaxLetters(5)
        AF.ClearPoints(delimiterEditBox.label)
        AF.SetPoint(delimiterEditBox.label, "BOTTOMLEFT", delimiterEditBox, "TOPLEFT", 2, 2)
        delimiterEditBox.label:SetColor("white")
        delimiterEditBox:SetOnTextChanged(function(text, userChanged)
            delimiterEditBox.label:Show()
            if userChanged then
                pane.t.cfg[textType].format.delimiter = text
                LoadIndicatorConfig(pane.t)
            end
        end)

        percentSignCheckButton = AF.CreateCheckButton(pane, "%")
        AF.SetPoint(percentSignCheckButton, "TOP", percentFormatDropdown, 0, -3)
        AF.SetPoint(percentSignCheckButton, "LEFT", delimiterEditBox)
        percentSignCheckButton:SetOnCheck(function(checked)
            pane.t.cfg[textType].format.showPercentSign = checked
            LoadIndicatorConfig(pane.t)
        end)

        useAsianUnitsCheckButton = AF.CreateCheckButton(pane, L["Use Asian Units"])
        AF.SetPoint(useAsianUnitsCheckButton, "TOPLEFT", percentFormatDropdown, "BOTTOMLEFT", 0, -8)
        useAsianUnitsCheckButton:SetOnCheck(function(checked)
            pane.t.cfg[textType].format.useAsianUnits = checked
            LoadIndicatorConfig(pane.t)
        end)
    end
    --------------------------------------------------

    --------------------------------------------------
    -- duration
    local normalColorPicker, percentCheckButton, percentColorPicker, percentDropdown, secondsCheckButton, secondsColorPicker, secondsEditBox, sec

    if extra == "duration" then
        normalColorPicker = AF.CreateColorPicker(pane, L["Normal"])
        AF.SetPoint(normalColorPicker, "TOPLEFT", xOffset, "BOTTOMLEFT", 0, -35)
        normalColorPicker:SetOnChange(function(r, g, b)
            pane.t.cfg[textType].color.normal[1] = r
            pane.t.cfg[textType].color.normal[2] = g
            pane.t.cfg[textType].color.normal[3] = b
            LoadIndicatorConfig(pane.t)
        end)

        percentCheckButton = AF.CreateCheckButton(pane)
        AF.SetPoint(percentCheckButton, "TOPLEFT", normalColorPicker, "BOTTOMLEFT", 0, -7)

        percentColorPicker = AF.CreateColorPicker(pane, L["Remaining Time"] .. " <")
        AF.SetPoint(percentColorPicker, "TOPLEFT", percentCheckButton, "TOPRIGHT", 2, 0)
        percentColorPicker:SetOnChange(function(r, g, b)
            pane.t.cfg[textType].color.percent.rgb[1] = r
            pane.t.cfg[textType].color.percent.rgb[2] = g
            pane.t.cfg[textType].color.percent.rgb[3] = b
            LoadIndicatorConfig(pane.t)
        end)

        percentDropdown = AF.CreateDropdown(pane, 50, nil, "vertical")
        AF.SetPoint(percentDropdown, "LEFT", percentColorPicker.label, "RIGHT", 5, 0)
        percentDropdown:SetItems({
            {text = "90%", value = 0.9},
            {text = "80%", value = 0.8},
            {text = "70%", value = 0.7},
            {text = "60%", value = 0.6},
            {text = "50%", value = 0.5},
            {text = "40%", value = 0.4},
            {text = "30%", value = 0.3},
            {text = "20%", value = 0.2},
            {text = "10%", value = 0.1},
        })
        percentDropdown:SetOnSelect(function(value)
            pane.t.cfg[textType].color.percent.value = value
            LoadIndicatorConfig(pane.t)
        end)

        percentCheckButton:SetOnCheck(function(checked)
            pane.t.cfg[textType].color.percent.enabled = checked
            AF.SetEnabled(checked, percentColorPicker, percentDropdown)
            LoadIndicatorConfig(pane.t)
        end)

        secondsCheckButton = AF.CreateCheckButton(pane)
        AF.SetPoint(secondsCheckButton, "TOPLEFT", percentCheckButton, "BOTTOMLEFT", 0, -7)

        secondsColorPicker = AF.CreateColorPicker(pane, L["Remaining Time"] .. " <")
        AF.SetPoint(secondsColorPicker, "TOPLEFT", secondsCheckButton, "TOPRIGHT", 2, 0)
        secondsColorPicker:SetOnChange(function(r, g, b)
            pane.t.cfg[textType].color.seconds.rgb[1] = r
            pane.t.cfg[textType].color.seconds.rgb[2] = g
            pane.t.cfg[textType].color.seconds.rgb[3] = b
            LoadIndicatorConfig(pane.t)
        end)

        secondsEditBox = AF.CreateEditBox(pane, nil, 50, 20, "number")
        AF.SetPoint(secondsEditBox, "LEFT", secondsColorPicker.label, "RIGHT", 5, 0)
        secondsEditBox:SetMaxLetters(3)
        secondsEditBox:SetConfirmButton(function(value)
            pane.t.cfg[textType].color.seconds.value = value
            LoadIndicatorConfig(pane.t)
        end, nil, "RIGHT_OUTSIDE")

        sec = AF.CreateFontString(pane, L["sec"])
        AF.SetPoint(sec, "LEFT", secondsEditBox, "RIGHT", 5, 0)

        secondsCheckButton:SetOnCheck(function(checked)
            pane.t.cfg[textType].color.seconds.enabled = checked
            AF.SetEnabled(checked, secondsColorPicker, secondsEditBox, sec)
            LoadIndicatorConfig(pane.t)
        end)
    end
    --------------------------------------------------

    local function UpdateWidgets()
        AF.HideColorPicker()
        AF.SetEnabled(pane.t.cfg[textType].enabled, colorPicker,
            fontDropdown, fontOutlineDropdown, fontSizeSlider, shadowCheckButton,
            anchorPoint, relativePoint, xOffset, yOffset)
        if extra == "format" then
            AF.SetEnabled(pane.t.cfg[textType].enabled, numericFormatDropdown, percentFormatDropdown, delimiterEditBox, delimiterEditBox.label, percentSignCheckButton)
            useAsianUnitsCheckButton:SetEnabled(pane.t.cfg[textType].enabled and AF.isAsian)
        elseif extra == "duration" then
            AF.SetEnabled(pane.t.cfg[textType].enabled, normalColorPicker, percentCheckButton, secondsCheckButton)
            AF.SetEnabled(pane.t.cfg[textType].enabled and pane.t.cfg[textType].color.percent.enabled, percentColorPicker, percentDropdown)
            AF.SetEnabled(pane.t.cfg[textType].enabled and pane.t.cfg[textType].color.seconds.enabled, secondsColorPicker, secondsEditBox, sec)
        end
    end

    enabledCheckButton:SetOnCheck(function(checked)
        pane.t.cfg[textType].enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        enabledCheckButton:SetChecked(t.cfg[textType].enabled)
        fontDropdown:SetSelectedValue(pane.t.cfg[textType].font[1])
        fontSizeSlider:SetValue(pane.t.cfg[textType].font[2])
        fontOutlineDropdown:SetSelectedValue(pane.t.cfg[textType].font[3])
        shadowCheckButton:SetChecked(pane.t.cfg[textType].font[4])
        anchorPoint:SetSelectedValue(pane.t.cfg[textType].position[1])
        relativePoint:SetSelectedValue(pane.t.cfg[textType].position[2])
        xOffset:SetValue(pane.t.cfg[textType].position[3])
        yOffset:SetValue(pane.t.cfg[textType].position[4])

        if extra ~= "duration" then
            colorPicker:SetColor(pane.t.cfg[textType].color)
        end

        if extra == "format" then
            local numeric, percent = GetFormatItems(t.id)
            numericFormatDropdown:SetItems(numeric)
            percentFormatDropdown:SetItems(percent)

            numericFormatDropdown:SetSelectedValue(t.cfg[textType].format.numeric)
            percentFormatDropdown:SetSelectedValue(t.cfg[textType].format.percent)
            delimiterEditBox:SetText(t.cfg[textType].format.delimiter or "")
            percentSignCheckButton:SetChecked(t.cfg[textType].format.showPercentSign)
            useAsianUnitsCheckButton:SetChecked(t.cfg[textType].format.useAsianUnits)
        elseif extra == "duration" then
            colorPicker:Hide()
            normalColorPicker:SetColor(pane.t.cfg[textType].color.normal)
            percentColorPicker:SetColor(pane.t.cfg[textType].color.percent.rgb)
            secondsColorPicker:SetColor(pane.t.cfg[textType].color.seconds.rgb)
            percentCheckButton:SetChecked(pane.t.cfg[textType].color.percent.enabled)
            percentDropdown:SetSelectedValue(pane.t.cfg[textType].color.percent.value)
            secondsCheckButton:SetChecked(pane.t.cfg[textType].color.seconds.enabled)
            secondsEditBox:SetText(t.cfg[textType].color.seconds.value)
        end
    end

    return pane
end

---------------------------------------------------------------------
-- cooldownText
---------------------------------------------------------------------
builder["cooldownText"] = function(parent)
    if created["cooldownText"] then return created["cooldownText"] end

    created["cooldownText"] = CreateFontPositionExtraPane(parent, "cooldownText", "BFI_UnitFrameOption_CooldownText", L["Cooldown Text"])
    return created["cooldownText"]
end

---------------------------------------------------------------------
-- textWithFormat
---------------------------------------------------------------------
builder["textWithFormat"] = function(parent)
    if created["textWithFormat"] then return created["textWithFormat"] end

    created["textWithFormat"] = CreateFontPositionExtraPane(parent, "text", "BFI_UnitFrameOption_TextWithFormat", L["Text"], true)
    return created["textWithFormat"]
end

---------------------------------------------------------------------
-- stackText
---------------------------------------------------------------------
builder["stackText"] = function(parent)
    if created["stackText"] then return created["stackText"] end

    created["stackText"] = CreateFontPositionExtraPane(parent, "stackText", "BFI_UnitFrameOption_StackText", AF.GetGradientText(L["Stack Text"], "BFI", "white"))
    return created["stackText"]
end

---------------------------------------------------------------------
-- durationText
---------------------------------------------------------------------
builder["durationText"] = function(parent)
    if created["durationText"] then return created["durationText"] end

    created["durationText"] = CreateFontPositionExtraPane(parent, "durationText", "BFI_UnitFrameOption_DurationText", AF.GetGradientText(L["Duration Text"], "BFI", "white"), "duration")
    return created["durationText"]
end

---------------------------------------------------------------------
-- textLength
---------------------------------------------------------------------
builder["textLength"] = function(parent)
    if created["textLength"] then return created["textLength"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_TextLength", nil, 55)
    created["textLength"] = pane

    local textLengthSlider = AF.CreateSlider(pane, L["Length"], 150, 0, 1, 0.05, true, true)
    AF.SetPoint(textLengthSlider, "LEFT", 15, 0)
    textLengthSlider:SetAfterValueChanged(function(value)
        pane.t.cfg.length = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        textLengthSlider:SetValue(t.cfg.length)
    end

    return pane
end

---------------------------------------------------------------------
-- textFormat
---------------------------------------------------------------------
builder["textFormat"] = function(parent)
    if created["textFormat"] then return created["textFormat"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_TextFormat", nil, 120)
    created["textFormat"] = pane

    local numericFormatDropdown = AF.CreateDropdown(pane, 250)
    numericFormatDropdown:SetLabel(L["Numeric Format"])
    AF.SetPoint(numericFormatDropdown, "TOPLEFT", 15, -25)
    numericFormatDropdown:SetOnSelect(function(value)
        pane.t.cfg.format.numeric = value
        LoadIndicatorConfig(pane.t)
    end)

    local percentFormatDropdown = AF.CreateDropdown(pane, 250)
    percentFormatDropdown:SetLabel(L["Percent Format"])
    AF.SetPoint(percentFormatDropdown, "TOPLEFT", numericFormatDropdown, "BOTTOMLEFT", 0, -25)
    percentFormatDropdown:SetOnSelect(function(value)
        pane.t.cfg.format.percent = value
        LoadIndicatorConfig(pane.t)
    end)

    local delimiterEditBox = AF.CreateEditBox(pane, L["Delimiter"], 70, 20)
    AF.SetPoint(delimiterEditBox, "TOPLEFT", numericFormatDropdown, "TOPRIGHT", 15, 0)
    delimiterEditBox:SetMaxLetters(5)
    AF.ClearPoints(delimiterEditBox.label)
    AF.SetPoint(delimiterEditBox.label, "BOTTOMLEFT", delimiterEditBox, "TOPLEFT", 2, 2)
    delimiterEditBox.label:SetColor("white")
    delimiterEditBox:SetOnTextChanged(function(text, userChanged)
        delimiterEditBox.label:Show()
        if userChanged then
            pane.t.cfg.format.delimiter = text
            LoadIndicatorConfig(pane.t)
        end
    end)

    local percentSignCheckButton = AF.CreateCheckButton(pane, "%")
    AF.SetPoint(percentSignCheckButton, "TOP", percentFormatDropdown, 0, -3)
    AF.SetPoint(percentSignCheckButton, "LEFT", delimiterEditBox)
    percentSignCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.format.showPercentSign = checked
        LoadIndicatorConfig(pane.t)
    end)

    local useAsianUnitsCheckButton = AF.CreateCheckButton(pane, L["Use Asian Units"])
    AF.SetPoint(useAsianUnitsCheckButton, "TOPLEFT", percentFormatDropdown, "BOTTOMLEFT", 0, -8)
    useAsianUnitsCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.format.useAsianUnits = checked
        LoadIndicatorConfig(pane.t)
    end)
    useAsianUnitsCheckButton:SetEnabled(AF.isAsian)

    function pane.Load(t)
        pane.t = t

        local numeric, percent = GetFormatItems(t.id)
        numericFormatDropdown:SetItems(numeric)
        percentFormatDropdown:SetItems(percent)

        numericFormatDropdown:SetSelectedValue(t.cfg.format.numeric)
        percentFormatDropdown:SetSelectedValue(t.cfg.format.percent)
        delimiterEditBox:SetText(t.cfg.format.delimiter or "")
        percentSignCheckButton:SetChecked(t.cfg.format.showPercentSign)
        useAsianUnitsCheckButton:SetChecked(t.cfg.format.useAsianUnits)
    end

    return pane
end

---------------------------------------------------------------------
-- numericFormat
---------------------------------------------------------------------
builder["numericFormat"] = function(parent)
    if created["numericFormat"] then return created["numericFormat"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_NumericFormat", nil, 75)
    created["numericFormat"] = pane

    local numericFormatDropdown = AF.CreateDropdown(pane, 250)
    AF.SetPoint(numericFormatDropdown, "TOPLEFT", 15, -25)
    numericFormatDropdown:SetLabel(L["Numeric Format"])
    numericFormatDropdown:SetOnSelect(function(value)
        pane.t.cfg.format.numeric = value
        LoadIndicatorConfig(pane.t)
    end)

    local useAsianUnitsCheckButton = AF.CreateCheckButton(pane, L["Use Asian Units"])
    AF.SetPoint(useAsianUnitsCheckButton, "TOPLEFT", numericFormatDropdown, "BOTTOMLEFT", 0, -8)
    useAsianUnitsCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.format.useAsianUnits = checked
        LoadIndicatorConfig(pane.t)
    end)
    useAsianUnitsCheckButton:SetEnabled(AF.isAsian)

    function pane.Load(t)
        pane.t = t
        local numeric = GetFormatItems(t.id)
        numericFormatDropdown:SetItems(numeric)
        numericFormatDropdown:SetSelectedValue(t.cfg.format.numeric)
    end

    return pane
end

---------------------------------------------------------------------
-- hideIfFull,hideIfEmpty
---------------------------------------------------------------------
builder["hideIfFull,hideIfEmpty"] = function(parent)
    if created["hideIfFull,hideIfEmpty"] then return created["hideIfFull,hideIfEmpty"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HideIfFullOrEmpty", nil, 30)
    created["hideIfFull,hideIfEmpty"] = pane

    local hideIfFullCheckButton = AF.CreateCheckButton(pane, L["Hide When Full"])
    AF.SetPoint(hideIfFullCheckButton, "LEFT", 15, 0)
    hideIfFullCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideIfFull = checked
        LoadIndicatorConfig(pane.t)
    end)

    local hideIfEmptyCheckButton = AF.CreateCheckButton(pane, L["Hide When Empty"])
    AF.SetPoint(hideIfEmptyCheckButton, "TOPLEFT", hideIfFullCheckButton, 185, 0)
    hideIfEmptyCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideIfEmpty = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        hideIfFullCheckButton:SetChecked(t.cfg.hideIfFull)
        hideIfEmptyCheckButton:SetChecked(t.cfg.hideIfEmpty)
    end

    return pane
end

---------------------------------------------------------------------
-- hideIfFull
---------------------------------------------------------------------
builder["hideIfFull"] = function(parent)
    if created["hideIfFull"] then return created["hideIfFull"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HideIfFull", nil, 30)
    created["hideIfFull"] = pane

    local hideIfFullCheckButton = AF.CreateCheckButton(pane, L["Hide When Full"])
    AF.SetPoint(hideIfFullCheckButton, "LEFT", 15, 0)
    hideIfFullCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideIfFull = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        hideIfFullCheckButton:SetChecked(t.cfg.hideIfFull)
    end

    return pane
end

---------------------------------------------------------------------
-- font,color
---------------------------------------------------------------------
builder["font,color"] = function(parent)
    if created["font,color"] then return created["font,color"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_FontColor", nil, 148)
    created["font,color"] = pane

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.font[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.font[4] = checked
        LoadIndicatorConfig(pane.t)
    end)

    local colorDropdown = AF.CreateDropdown(pane, 150)
    colorDropdown:SetLabel(L["Color"])
    AF.SetPoint(colorDropdown, "TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -40)

    local colorPicker = AF.CreateColorPicker(pane)
    AF.SetPoint(colorPicker, "BOTTOMRIGHT", colorDropdown, "TOPRIGHT", 0, 2)
    colorPicker:SetOnChange(function(r, g, b)
        pane.t.cfg.color.rgb[1] = r
        pane.t.cfg.color.rgb[2] = g
        pane.t.cfg.color.rgb[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    colorDropdown:SetOnSelect(function(value)
        pane.t.cfg.color.type = value
        LoadIndicatorConfig(pane.t)
        colorPicker:SetShown(value == "custom_color")
    end)

    function pane.Load(t)
        pane.t = t

        colorDropdown:SetItems(GetColorItems(t.id))
        fontDropdown:SetSelectedValue(t.cfg.font[1])
        fontSizeSlider:SetValue(t.cfg.font[2])
        fontOutlineDropdown:SetSelectedValue(t.cfg.font[3])
        shadowCheckButton:SetChecked(t.cfg.font[4])
        colorDropdown:SetSelectedValue(t.cfg.color.type)
        colorPicker:SetColor(t.cfg.color.rgb)
        colorPicker:SetShown(t.cfg.color.type == "custom_color")
    end

    return pane
end

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
builder["font"] = function(parent)
    if created["font"] then return created["font"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Font", nil, 103)
    created["font"] = pane

    local fontDropdown = AF.CreateDropdown(pane, 150)
    fontDropdown:SetLabel(L["Font"])
    AF.SetPoint(fontDropdown, "TOPLEFT", 15, -25)
    fontDropdown:SetItems(AF.LSM_GetFontDropdownItems())
    fontDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[1] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontOutlineDropdown = AF.CreateDropdown(pane, 150)
    fontOutlineDropdown:SetLabel(L["Outline"])
    AF.SetPoint(fontOutlineDropdown, "TOPLEFT", fontDropdown, 185, 0)
    fontOutlineDropdown:SetItems(AF.LSM_GetFontOutlineDropdownItems())
    fontOutlineDropdown:SetOnSelect(function(value)
        pane.t.cfg.font[3] = value
        LoadIndicatorConfig(pane.t)
    end)

    local fontSizeSlider = AF.CreateSlider(pane, L["Size"], 150, 5, 50, 1, nil, true)
    AF.SetPoint(fontSizeSlider, "TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -25)
    fontSizeSlider:SetOnValueChanged(function(value)
        pane.t.cfg.font[2] = value
        LoadIndicatorConfig(pane.t)
    end)

    local shadowCheckButton = AF.CreateCheckButton(pane, L["Shadow"])
    AF.SetPoint(shadowCheckButton, "LEFT", fontSizeSlider, 185, 0)
    shadowCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.font[4] = checked
        LoadIndicatorConfig(pane.t)
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
-- showTimer,useEn
---------------------------------------------------------------------
builder["showTimer,useEn"] = function(parent)
    if created["showTimer,useEn"] then return created["showTimer,useEn"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_ShowTimerUseEn", nil, 30)
    created["showTimer,useEn"] = pane

    local showTimerCheckButton = AF.CreateCheckButton(pane, L["Show Timer"])
    AF.SetPoint(showTimerCheckButton, "LEFT", 15, 0)

    local useEnCheckButton = AF.CreateCheckButton(pane, L["Use English Label"])
    AF.SetPoint(useEnCheckButton, "TOPLEFT", showTimerCheckButton, 185, 0)
    useEnCheckButton:SetEnabled(not LOCALE_enUS)
    useEnCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.useEn = checked
        LoadIndicatorConfig(pane.t)
    end)

    showTimerCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.showTimer = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        showTimerCheckButton:SetChecked(t.cfg.showTimer)
        useEnCheckButton:SetChecked(t.cfg.useEn)
    end

    return pane
end

---------------------------------------------------------------------
-- damage,healing
---------------------------------------------------------------------
builder["damage,healing"] = function(parent)
    if created["damage,healing"] then return created["damage,healing"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_DamageHealing", nil, 30)
    created["damage,healing"] = pane

    local damageCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(damageCheckButton, "LEFT", 15, 0)

    local damageColorPicker = AF.CreateColorPicker(pane, L["Damage"])
    AF.SetPoint(damageColorPicker, "TOPLEFT", damageCheckButton, "TOPRIGHT", 2, 0)
    damageColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.cfg.types.damage.color[1] = r
        pane.t.cfg.types.damage.color[2] = g
        pane.t.cfg.types.damage.color[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    damageCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.types.damage.enabled = checked
        damageColorPicker:SetEnabled(checked)
        LoadIndicatorConfig(pane.t)
    end)

    local healingCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(healingCheckButton, "TOPLEFT", damageCheckButton, 185, 0)

    local healingColorPicker = AF.CreateColorPicker(pane, L["Healing"])
    AF.SetPoint(healingColorPicker, "TOPLEFT", healingCheckButton, "TOPRIGHT", 2, 0)
    healingColorPicker:SetOnConfirm(function(r, g, b)
        pane.t.cfg.types.healing.color[1] = r
        pane.t.cfg.types.healing.color[2] = g
        pane.t.cfg.types.healing.color[3] = b
        LoadIndicatorConfig(pane.t)
    end)

    healingCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.types.healing.enabled = checked
        healingColorPicker:SetEnabled(checked)
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        damageCheckButton:SetChecked(t.cfg.types.damage.enabled)
        healingCheckButton:SetChecked(t.cfg.types.healing.enabled)
        damageColorPicker:SetColor(t.cfg.types.damage.color)
        healingColorPicker:SetColor(t.cfg.types.healing.color)
        damageColorPicker:SetEnabled(t.cfg.types.damage.enabled)
        healingColorPicker:SetEnabled(t.cfg.types.healing.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- auraBaseFilters
---------------------------------------------------------------------
builder["auraBaseFilters"] = function(parent)
    if created["auraBaseFilters"] then return created["auraBaseFilters"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_AuraBaseFilters", nil, 94)
    created["auraBaseFilters"] = pane

    local tip = AF.CreateFontString(pane, L["The aura will show if any enabled filter is met"])
    tip:SetColor("tip")
    AF.SetPoint(tip, "TOPLEFT", 15, -8)

    local castByMe = AF.CreateCheckButton(pane, L["Cast By Me"])
    AF.SetPoint(castByMe, "TOPLEFT", 15, -30)
    castByMe:SetOnCheck(function(checked)
        pane.t.cfg.filters.castByMe = checked
        LoadIndicatorConfig(pane.t)
    end)

    local castByOthers = AF.CreateCheckButton(pane, L["Cast By Others"])
    AF.SetPoint(castByOthers, "TOPLEFT", castByMe, 185, 0)
    castByOthers:SetOnCheck(function(checked)
        pane.t.cfg.filters.castByOthers = checked
        LoadIndicatorConfig(pane.t)
    end)

    local castByUnit = AF.CreateCheckButton(pane, L["Cast By Unit"])
    AF.SetPoint(castByUnit, "TOPLEFT", castByMe, "BOTTOMLEFT", 0, -7)
    castByUnit:SetOnCheck(function(checked)
        pane.t.cfg.filters.castByUnit = checked
        LoadIndicatorConfig(pane.t)
    end)

    local castByNPC = AF.CreateCheckButton(pane, L["Cast By NPC"])
    AF.SetPoint(castByNPC, "TOPLEFT", castByUnit, 185, 0)
    castByNPC:SetOnCheck(function(checked)
        pane.t.cfg.filters.castByNPC = checked
        LoadIndicatorConfig(pane.t)
    end)

    local castByBoss = AF.CreateCheckButton(pane, L["Cast By Boss"])
    AF.SetPoint(castByBoss, "TOPLEFT", castByUnit, "BOTTOMLEFT", 0, -7)
    castByBoss:SetOnCheck(function(checked)
        pane.t.cfg.filters.isBossAura = checked
        LoadIndicatorConfig(pane.t)
    end)

    local dispellable = AF.CreateCheckButton(pane, L["Dispellable"])
    AF.SetPoint(dispellable, "TOPLEFT", castByBoss, 185, 0)
    dispellable:SetOnCheck(function(checked)
        pane.t.cfg.filters.dispellable = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        castByMe:SetChecked(t.cfg.filters.castByMe)
        castByOthers:SetChecked(t.cfg.filters.castByOthers)
        castByUnit:SetChecked(t.cfg.filters.castByUnit)
        castByNPC:SetChecked(t.cfg.filters.castByNPC)
        castByBoss:SetChecked(t.cfg.filters.isBossAura)
        dispellable:SetChecked(t.cfg.filters.dispellable)

        if t.id == "buffs" and (t.owner == "player" or t.owner == "pet" or t.owner == "party" or t.owner == "raid") then
            dispellable:SetEnabled(false)
        else
            dispellable:SetEnabled(true)
        end
    end

    return pane
end

---------------------------------------------------------------------
-- auraBlackListWhitelist
---------------------------------------------------------------------
builder["auraBlackListWhitelist"] = function(parent)
    if created["auraBlackListWhitelist"] then return created["auraBlackListWhitelist"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_AuraBlackListWhitelist", nil, 0)
    created["auraBlackListWhitelist"] = pane

    local mode = AF.CreateDropdown(pane, 150)
    AF.SetPoint(mode, "TOPLEFT", 15, -8)
    mode:SetItems({
        {text = L["Blacklist"], value = "blacklist"},
        {text = L["Whitelist"], value = "whitelist"},
    })

    local tip = AF.CreateFontString(pane, AF.GetIconString("MouseLeftClick") .. L["Edit"] .. "  " .. AF.GetIconString("MouseRightClick") .. L["Delete"])
    AF.SetPoint(tip, "LEFT", mode, "RIGHT", 8, 0)
    tip:SetColor("tip")

    local buttons = {}
    local editBox

    local function HideEditBox()
        if editBox then
            editBox:Hide()
            editBox = nil
        end
    end

    local function GetEditBox(owner)
        HideEditBox()

        editBox = AF.GetEditBox(parent:GetParent(), L["Input Spell ID"], nil, nil, "number")
        editBox:SetAllPoints(owner)
        editBox:SetBorderColor("BFI")

        editBox:SetOnTextChanged(function(spell)
            if not spell then
                AF.Tooltip2:Hide()
                return
            end
            AF.Tooltip2:SetOwner(editBox, "ANCHOR_NONE")
            AF.Tooltip2:SetSpellByID(spell, true)
            AF.Tooltip2:SetPoint("TOPRIGHT", editBox, "TOPLEFT", -1, 0)
            AF.Tooltip2:Show()
        end)

        editBox:SetOnEnterPressed(function(spell)
            if not (spell and AF.SpellExists(spell)) then return end
            if owner.index then
                pane.list[owner.index] = spell
            else
                tinsert(pane.list, spell)
            end
            pane.Load(pane.t)
            LoadIndicatorConfig(pane.t)
        end)

        editBox:SetText(owner.spell or "")
    end

    mode:SetOnSelect(function(value)
        HideEditBox()
        pane.t.cfg.mode = value
        pane.Load(pane.t)
        LoadIndicatorConfig(pane.t)
    end)

    pane:SetOnHide(function()
        HideEditBox()
        AF.Tooltip2:Hide()
    end)

    local addButton = AF.CreateButton(pane, nil, "BFI_hover", 150, 20)
    addButton:SetTexture(AF.GetIcon("Plus"))
    addButton:EnablePushEffect(false)
    addButton:SetOnClick(function()
        GetEditBox(addButton)
    end)

    local pool = AF.CreateObjectPool(function()
        local b = AF.CreateButton(pane, nil, "BFI_hover", 150, 20)
        b:SetTexture(AF.GetIcon("QuestionMark"), nil, {"LEFT", 2, 0}, nil, "black")
        b:EnablePushEffect(false)
        b:SetTextJustifyH("LEFT")
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        b:SetOnClick(function(_, click)
            if click == "LeftButton" then
                GetEditBox(b)
            elseif click == "RightButton" then
                AF.Remove(pane.list, b.spell)
                pane.Load(pane.t)
                LoadIndicatorConfig(pane.t)
            end
        end)

        b:HookOnEnter(function()
            if editBox and editBox:IsShown() then return end
            AF.Tooltip2:SetOwner(parent:GetParent(), "ANCHOR_NONE")
            AF.Tooltip2:SetSpellByID(b.spell, true)
            AF.Tooltip2:SetPoint("TOPRIGHT", b, "TOPLEFT", -1, 0)
            AF.Tooltip2:Show()
        end)

        b:HookOnLeave(function()
            if editBox and editBox:IsShown() then return end
            AF.Tooltip2:Hide()
        end)

        return b
    end, function(_, b)
        b:Hide()
        AF.ClearPoints(b)
    end)


    function pane.Load(t)
        pane.t = t
        mode:SetSelectedValue(t.cfg.mode)

        pane.list = t.cfg.mode == "blacklist" and t.cfg.blacklist or t.cfg.whitelist

        pool:ReleaseAll()
        wipe(buttons)

        local num = #pane.list

        for i = 1, num + 1 do
            local spell = pane.list[i]

            local b
            if i <= num then
                b = pool:Acquire()
                local name, icon = AF.GetSpellInfo(spell, true)
                b:SetText(name)
                b:SetTexture(icon, nil, nil, nil, "black")
                b.spell = spell
                b.index = i
            else
                b = addButton
            end

            buttons[i] = b
            b:Show()

            if i == 1 then
                AF.SetPoint(b, "TOPLEFT", mode, "BOTTOMLEFT", 0, -8)
            elseif i % 2 == 1 then
                AF.SetPoint(b, "TOPLEFT", buttons[i - 2], "BOTTOMLEFT", 0, -5)
            else
                AF.SetPoint(b, "TOPLEFT", buttons[i - 1], "TOPRIGHT", 5, 0)
            end
        end

        AF.SetListHeight(pane, ceil((num + 1) / 2), 20, 5, 8 + 20 + 8, 8)
        parent._contentHeights[pane.index] = tostring(pane:GetHeight()) -- update height
        AF.ReSize(parent) -- call AF.SetScrollContentHeight
    end

    return pane
end
---------------------------------------------------------------------
-- auraTypeColor
---------------------------------------------------------------------
builder["auraTypeColor"] = function(parent)
    if created["auraTypeColor"] then return created["auraTypeColor"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_AuraTypeColor", nil, 72)
    created["auraTypeColor"] = pane

    local tip = AF.CreateFontString(pane, AF.GetGradientText(L["Border Color"], "BFI", "white") .. "\n" .. L["Priority: top to bottom"])
    AF.SetPoint(tip, "TOPLEFT", 15, -8)
    AF.SetPoint(tip, "BOTTOMLEFT", 15, 8)
    tip:SetColor("tip")
    tip:SetJustifyH("LEFT")
    tip:SetJustifyV("MIDDLE")
    tip:SetSpacing(5)

    local castByMe = AF.CreateCheckButton(pane, L["Cast By Me"])
    AF.SetPoint(castByMe, "TOPLEFT", tip, 185, 0)
    castByMe:SetOnCheck(function(checked)
        pane.t.cfg.auraTypeColor.castByMe = checked
        LoadIndicatorConfig(pane.t)
    end)

    local dispellable = AF.CreateCheckButton(pane, L["Dispellable"])
    AF.SetPoint(dispellable, "TOPLEFT", castByMe, "BOTTOMLEFT", 0, -7)
    dispellable:SetOnCheck(function(checked)
        pane.t.cfg.auraTypeColor.dispellable = checked
        LoadIndicatorConfig(pane.t)
    end)

    local debuffType = AF.CreateCheckButton(pane, L["Debuff Type"])
    AF.SetPoint(debuffType, "TOPLEFT", dispellable, "BOTTOMLEFT", 0, -7)
    debuffType:SetOnCheck(function(checked)
        pane.t.cfg.auraTypeColor.debuffType = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        castByMe:SetChecked(t.cfg.auraTypeColor.castByMe)
        dispellable:SetChecked(t.cfg.auraTypeColor.dispellable)
        debuffType:SetChecked(t.cfg.auraTypeColor.debuffType)

        if t.id == "buffs" and (t.owner == "player" or t.owner == "pet" or t.owner == "party" or t.owner == "raid") then
            dispellable:SetEnabled(false)
        else
            dispellable:SetEnabled(true)
        end

        debuffType:SetEnabled(t.id == "debuffs")
    end

    return pane
end

---------------------------------------------------------------------
-- auraSubFrame
---------------------------------------------------------------------
builder["auraSubFrame"] = function(parent)
    if created["auraSubFrame"] then return created["auraSubFrame"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_AuraSubFrame", nil, 125)
    created["auraSubFrame"] = pane

    -- TODO: more filters and separate arrangement

    local enabled = AF.CreateCheckButton(pane, AF.GetGradientText(L["Enable Sub Frame"], "BFI", "white"))
    AF.SetPoint(enabled, "TOPLEFT", 15, -8)

    local filter = AF.CreateDropdown(pane, 150)
    filter:SetLabel(L["Filter"])
    AF.SetPoint(filter, "TOPLEFT", enabled, "BOTTOMLEFT", 0, -25)
    filter:SetItems({
        {text = L["Not Cast By Me"], value = "notCastByMe"},
    })
    filter:SetOnSelect(function(value)
        pane.t.cfg.subFrame.filter = value
        LoadIndicatorConfig(pane.t)
    end)

    local desaturated = AF.CreateCheckButton(pane, L["Desaturated"])
    AF.SetPoint(desaturated, "TOPLEFT", filter, 185, 0)
    desaturated:SetOnCheck(function(checked)
        pane.t.cfg.subFrame.desaturated = checked
        LoadIndicatorConfig(pane.t)
    end)

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(width, "TOPLEFT", filter, "BOTTOMLEFT", 0, -25)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.subFrame.width = value
        LoadIndicatorConfig(pane.t)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.subFrame.height = value
        LoadIndicatorConfig(pane.t)
    end)

    local function UpdateWidgets()
        AF.SetEnabled(pane.t.cfg.subFrame.enabled, filter, desaturated, width, height)
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.subFrame.enabled = checked
        UpdateWidgets()
        LoadIndicatorConfig(pane.t)
    end)

    function pane.IsApplicable(t)
        return t.owner == "target"
    end

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()
        enabled:SetChecked(t.cfg.subFrame.enabled)
        filter:SetSelectedValue(t.cfg.subFrame.filter)
        desaturated:SetChecked(t.cfg.subFrame.desaturated)
        width:SetValue(t.cfg.subFrame.width)
        height:SetValue(t.cfg.subFrame.height)
    end

    return pane
end

---------------------------------------------------------------------
-- auraArrangement
---------------------------------------------------------------------
builder["auraArrangement"] = function(parent)
    if created["auraArrangement"] then return created["auraArrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_AuraArrangement", nil, 203)
    created["auraArrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 150)
    arrangement:SetLabel(AF.GetGradientText(L["Arrangement"], "BFI", "white"))
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_SimpleOrientation())
    arrangement:SetOnSelect(function(value)
        pane.t.cfg.orientation = value
        LoadIndicatorConfig(pane.t)
    end)

    local width = AF.CreateSlider(pane, L["Width"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(width, "TOPLEFT",  arrangement, "BOTTOMLEFT", 0, -25)
    width:SetOnValueChanged(function(value)
        pane.t.cfg.width = value
        LoadIndicatorConfig(pane.t)
    end)

    local height = AF.CreateSlider(pane, L["Height"], 150, 10, 100, 1, nil, true)
    AF.SetPoint(height, "TOPLEFT", width, 185, 0)
    height:SetOnValueChanged(function(value)
        pane.t.cfg.height = value
        LoadIndicatorConfig(pane.t)
    end)

    local spacingX = AF.CreateSlider(pane, L["X Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingX, "TOPLEFT", width, "BOTTOMLEFT", 0, -40)
    spacingX:SetOnValueChanged(function(value)
        pane.t.cfg.spacingX = value
        LoadIndicatorConfig(pane.t)
    end)

    local spacingY = AF.CreateSlider(pane, L["Y Spacing"], 150, -1, 50, 1, nil, true)
    AF.SetPoint(spacingY, "TOPLEFT", spacingX, 185, 0)
    spacingY:SetOnValueChanged(function(value)
        pane.t.cfg.spacingY = value
        LoadIndicatorConfig(pane.t)
    end)

    local numPerLine = AF.CreateSlider(pane, L["Displayed Per Line"], 150, 2, 50, 1, nil, true)
    AF.SetPoint(numPerLine, "TOPLEFT", spacingX, "BOTTOMLEFT", 0, -40)
    numPerLine:SetOnValueChanged(function(value)
        pane.t.cfg.numPerLine = value
        LoadIndicatorConfig(pane.t)
    end)

    local numTotal = AF.CreateSlider(pane, L["Max Displayed"], 150, 1, 100, 1, nil, true)
    AF.SetPoint(numTotal, "TOPLEFT", numPerLine, 185, 0)
    numTotal:SetOnValueChanged(function(value)
        pane.t.cfg.numTotal = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.orientation)
        width:SetValue(t.cfg.width)
        height:SetValue(t.cfg.height)
        spacingX:SetValue(t.cfg.spacingX)
        spacingY:SetValue(t.cfg.spacingY)
        numPerLine:SetValue(t.cfg.numPerLine)
        numTotal:SetValue(t.cfg.numTotal)
    end

    return pane
end

---------------------------------------------------------------------
-- cooldownStyle
---------------------------------------------------------------------
builder["cooldownStyle"] = function(parent)
    if created["cooldownStyle"] then return created["cooldownStyle"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_CooldownStyle", nil, 54)
    created["cooldownStyle"] = pane

    local styleDropdown = AF.CreateDropdown(pane, 250)
    styleDropdown:SetLabel(L["Cooldown Style"])
    AF.SetPoint(styleDropdown, "TOPLEFT", 15, -25)

    -- none, vertical, block_vertical, clock(_with_leading_edge), block_clock(_with_leading_edge)
    styleDropdown:SetItems({
        {text = _G.NONE, value = "none"},
        {text = L["Vertical"], value = "vertical"},
        {text = L["Block Vertical"], value = "block_vertical"},
        {text = L["Clock"], value = "clock"},
        {text = L["Block Clock"], value = "block_clock"},
        {text = L["Clock (With Leading Edge)"], value = "clock_with_leading_edge"},
        {text = L["Block Clock (With Leading Edge)"], value = "block_clock_with_leading_edge"},
    })
    styleDropdown:SetOnSelect(function(value)
        pane.t.cfg.cooldownStyle = value
        LoadIndicatorConfig(pane.t)
    end)

    styleDropdown:SetTooltip(L["Cooldown Style"], L["Block type: Recommended for whitelist mode only, and set aura colors in %s"]:format(AF.WrapTextInColor(L["Auras"], "BFI")))

    function pane.Load(t)
        pane.t = t
        styleDropdown:SetSelectedValue(t.cfg.cooldownStyle)
    end

    return pane
end

---------------------------------------------------------------------
-- tooltip
---------------------------------------------------------------------
builder["tooltip"] = function(parent)
    if created["tooltip"] then return created["tooltip"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Tooltip", nil, 148)
    created["tooltip"] = pane

    local enabledCheckButton = AF.CreateCheckButton(pane)
    AF.SetPoint(enabledCheckButton, "TOPLEFT", 15, -25)

    local relativeTo = AF.CreateDropdown(pane, 150)
    relativeTo:SetLabel(L["Relative To"])
    AF.SetPoint(relativeTo, "LEFT", enabledCheckButton, 185, 0)
    AF.SetPoint(relativeTo, "TOP", pane, 0, -25)

    local singleItems = {
        {text = L["Unit Frame"], value = "self"},
        {text = _G.DEFAULT, value = "default"},
    }

    local groupItems = {
        {text = L["Unit Frame"], value = "self"},
        {text = L["Group"], value = "parent"},
        {text = _G.DEFAULT, value = "default"},
    }

    local auraItems = {
        {text = L["Unit Frame"], value = "root"},
        {text = L["Icon"], value = "self"},
        {text = L["Icon (Adaptive)"], value = "self_adaptive"},
        {text = L["Group"], value = "parent"},
        {text = _G.DEFAULT, value = "default"},
    }

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", enabledCheckButton, 0, -45)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[1] = value
    end)

    local relativePoint = AF.CreateDropdown(pane, 150)
    relativePoint:SetLabel(L["Relative Point"])
    AF.SetPoint(relativePoint, "TOPLEFT", anchorPoint, 185, 0)
    relativePoint:SetItems(AF.GetDropdownItems_AnchorPoint())
    relativePoint:SetOnSelect(function(value)
        pane.t.cfg.tooltip.position[2] = value
    end)

    local x = AF.CreateSlider(pane, L["X Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(x, "TOPLEFT", anchorPoint, 0, -45)
    x:SetOnValueChanged(function(value)
        pane.t.cfg.tooltip.position[3] = value
    end)

    local y = AF.CreateSlider(pane, L["Y Offset"], 150, -1000, 1000, 1, nil, true)
    AF.SetPoint(y, "TOPLEFT", x, 185, 0)
    y:SetOnValueChanged(function(value)
        pane.t.cfg.tooltip.position[4] = value
    end)

    local function UpdateWidgets()
        relativeTo:SetEnabled(pane.t.cfg.tooltip.enabled)
        AF.SetEnabled(pane.t.cfg.tooltip.enabled and pane.t.cfg.tooltip.anchorTo ~= "self_adaptive" and pane.t.cfg.tooltip.anchorTo ~= "default", anchorPoint, relativePoint, x, y)
    end

    enabledCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.tooltip.enabled = checked
        UpdateWidgets()
        if not pane.t.id:find("^general") then
            LoadIndicatorConfig(pane.t)
        end
    end)

     relativeTo:SetOnSelect(function(value)
        pane.t.cfg.tooltip.anchorTo = value
        UpdateWidgets()
    end)

    function pane.Load(t)
        pane.t = t
        UpdateWidgets()

        if t.id == "general_single" then
            enabledCheckButton:SetText(L["Enable Tooltip"])
            relativeTo:SetItems(singleItems)
        elseif t.id:find("^general") then
            enabledCheckButton:SetText(L["Enable Tooltip"])
            relativeTo:SetItems(groupItems)
        else
            enabledCheckButton:SetText(L["Enable Aura Tooltip"])
            relativeTo:SetItems(auraItems)
        end

        enabledCheckButton:SetChecked(t.cfg.tooltip.enabled)
        relativeTo:SetSelectedValue(t.cfg.tooltip.anchorTo)
        anchorPoint:SetSelectedValue(t.cfg.tooltip.position[1])
        relativePoint:SetSelectedValue(t.cfg.tooltip.position[2])
        x:SetValue(t.cfg.tooltip.position[3])
        y:SetValue(t.cfg.tooltip.position[4])
    end

    return pane
end

---------------------------------------------------------------------
-- style
---------------------------------------------------------------------
builder["style"] = function(parent)
    if created["style"] then return created["style"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Style", nil, 54)
    created["style"] = pane

    local styleDropdown = AF.CreateDropdown(pane, 150)
    styleDropdown:SetLabel(L["Style"])
    AF.SetPoint(styleDropdown, "TOPLEFT", 15, -25)
    styleDropdown:SetOnSelect(function(value)
        pane.t.cfg.style = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        if t.id == "raidIcon" then
            styleDropdown:SetItems({
                {text = L["Blizzard"], value = "blizzard"},
                {text = "AF", value = "af"},
            })
        else
            styleDropdown:SetItems({
                {text = L["Blizzard"], value = "blizzard"},
                {text = "BFI", value = "bfi"},
            })
        end

        pane.t = t
        styleDropdown:SetSelectedValue(t.cfg.style)
    end

    return pane
end

---------------------------------------------------------------------
-- hideDamager
---------------------------------------------------------------------
builder["hideDamager"] = function(parent)
    if created["hideDamager"] then return created["hideDamager"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_HideDamager", nil, 30)
    created["hideDamager"] = pane

    local hideDamagerCheckButton = AF.CreateCheckButton(pane, L["Hide Damager"])
    AF.SetPoint(hideDamagerCheckButton, "LEFT", 15, 0)
    hideDamagerCheckButton:SetOnCheck(function(checked)
        pane.t.cfg.hideDamager = checked
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        hideDamagerCheckButton:SetChecked(t.cfg.hideDamager)
    end

    return pane
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
builder["color"] = function(parent)
    if created["color"] then return created["color"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Color", nil, 30)
    created["color"] = pane

    local colorPicker = AF.CreateColorPicker(pane, L["Color"], true)
    AF.SetPoint(colorPicker, "LEFT", 15, 0)
    colorPicker:SetOnChange(function(r, g, b, a)
        pane.t.cfg.color[1] = r
        pane.t.cfg.color[2] = g
        pane.t.cfg.color[3] = b
        pane.t.cfg.color[4] = a
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        colorPicker:SetColor(t.cfg.color)
    end

    return pane
end

---------------------------------------------------------------------
-- alpha
---------------------------------------------------------------------
builder["alpha"] = function(parent)
    if created["alpha"] then return created["alpha"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_Alpha", nil, 55)
    created["alpha"] = pane

    local alphaSlider = AF.CreateSlider(pane, L["Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(alphaSlider, "LEFT", 15, 0)
    alphaSlider:SetOnValueChanged(function(value)
        pane.t.cfg.alpha = value
        LoadIndicatorConfig(pane.t)
    end)

    function pane.Load(t)
        pane.t = t
        alphaSlider:SetValue(t.cfg.alpha)
    end

    return pane
end

---------------------------------------------------------------------
-- oorAlpha
---------------------------------------------------------------------
builder["oorAlpha"] = function(parent)
    if created["oorAlpha"] then return created["oorAlpha"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_OorAlpha", nil, 55)
    created["oorAlpha"] = pane

    local oorAlphaSlider = AF.CreateSlider(pane, L["Out Of Range Alpha"], 150, 0, 1, 0.01, true, true)
    AF.SetPoint(oorAlphaSlider, "LEFT", 15, 0)
    oorAlphaSlider:SetAfterValueChanged(function(value)
        pane.t.cfg.oorAlpha = value
        -- AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        if pane.t.id == "general_single" then
            pane.t.target.oorAlpha = value
            pane.t.target.states.wasInRange = nil
        elseif pane.t.id == "general_party" then
            for i = 1, 5 do
                local b = pane.t.target.header[i]
                b.oorAlpha = value
                b.states.wasInRange = nil
            end
        elseif pane.t.id == "general_raid" then
            for i = 1, 40 do
                local b = pane.t.target.header[i]
                b.oorAlpha = value
                b.states.wasInRange = nil
            end
        elseif pane.t.id == "general_boss" then
            for i = 1, 8 do
                local b = pane.t.target[i]
                b.oorAlpha = value
                b.states.wasInRange = nil
            end
        end
    end)

    function pane.IsApplicable(t)
        return t.cfg.oorAlpha ~= nil
    end

    function pane.Load(t)
        pane.t = t
        oorAlphaSlider:SetValue(t.cfg.oorAlpha)
    end

    return pane
end

---------------------------------------------------------------------
-- partyArrangement
---------------------------------------------------------------------
builder["partyArrangement"] = function(parent)
    if created["partyArrangement"] then return created["partyArrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_PartyArrangement", nil, 103)
    created["partyArrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 150)
    arrangement:SetLabel(AF.GetGradientText(L["Arrangement"], "BFI", "white"))
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_SimpleOrientation())
    arrangement:SetOnSelect(function(value)
        pane.t.cfg.orientation = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", arrangement, 185, 0)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint(true))
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.anchor = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacing, "TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -25)
    spacing:SetOnValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local showPlayer = AF.CreateCheckButton(pane, L["Show Player"])
    AF.SetPoint(showPlayer, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -10)
    showPlayer:SetOnCheck(function(checked)
        pane.t.cfg.showPlayer = checked
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local sortByRole = AF.CreateCheckButton(pane, L["Sort By Role"])
    AF.SetPoint(sortByRole, "TOPLEFT", showPlayer, "BOTTOMLEFT", 0, -9)
    sortByRole:SetTooltip(L["Drag to reorder"])

    local sorter = AF.CreateDragSorter(pane)
    sorter:SetPoint("CENTER", sortByRole.label)
    sorter:SetPoint("RIGHT", arrangement)

    local widgets = {}
    local roles = {"TANK", "DAMAGER", "HEALER"}
    for i = 1, 3 do
        widgets[i] = AF.CreateIconButton(sorter, AF.GetIcon("Role_" .. roles[i]))
        widgets[i]:SetHoverBorder("BFI")
        widgets[i].tipText = AF.L[roles[i]]
        widgets[i].value = roles[i]
    end
    sorter:SetWidgets(widgets)

    local function callback(t)
        pane.t.cfg.groupingOrder = AF.TableToString(t, ",")
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end
    sorter:SetCallback(callback)

    sortByRole:SetOnCheck(function(checked)
        if checked then
            pane.t.cfg.sortMethod = "NAME"
            pane.t.cfg.groupBy = "ASSIGNEDROLE"
            pane.t.cfg.groupingOrder = "TANK,HEALER,DAMAGER,NONE"
            sorter:SetConfigTable(AF.StringToTable(pane.t.cfg.groupingOrder, ","))
            sortByRole:SetText(L["Order"])
            sorter:Show()
        else
            pane.t.cfg.sortMethod = "INDEX"
            pane.t.cfg.groupBy = nil
            pane.t.cfg.groupingOrder = ""
            sortByRole:SetText(L["Sort By Role"])
            sorter:Hide()
        end
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.orientation)
        anchorPoint:SetSelectedValue(t.cfg.anchor)
        spacing:SetValue(t.cfg.spacing)
        showPlayer:SetChecked(t.cfg.showPlayer)
        sortByRole:SetChecked(t.cfg.groupBy == "ASSIGNEDROLE")
        sorter:SetShown(t.cfg.groupBy == "ASSIGNEDROLE")
        if t.cfg.groupBy == "ASSIGNEDROLE" then
            sorter:SetConfigTable(AF.StringToTable(t.cfg.groupingOrder, ","))
            sortByRole:SetText(L["Order"])
        else
            sortByRole:SetText(L["Sort By Role"])
        end
    end

    return pane
end

---------------------------------------------------------------------
-- raidArrangement
---------------------------------------------------------------------
builder["raidArrangement"] = function(parent)
    if created["raidArrangement"] then return created["raidArrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_RaidArrangement", nil, 217)
    created["raidArrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 200)
    arrangement:SetLabel(AF.GetGradientText(L["Arrangement"], "BFI", "white"))
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_ComplexOrientation())

    local anchorPoint = AF.CreateDropdown(pane, 120)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", arrangement, 215, 0)
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint(true))
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.anchor = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local sortByRole = AF.CreateCheckButton(pane, L["Sort By Role"])
    AF.SetPoint(sortByRole, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -15)
    sortByRole:SetTooltip(L["Drag to reorder"])

    local sorter = AF.CreateDragSorter(pane)
    AF.SetPoint(sorter, "LEFT", sortByRole.label, "RIGHT", 10, 0)

    local widgets = {}
    local roles = {"TANK", "DAMAGER", "HEALER"}
    for i = 1, 3 do
        widgets[i] = AF.CreateIconButton(sorter, AF.GetIcon("Role_" .. roles[i]))
        widgets[i]:SetHoverBorder("BFI")
        widgets[i].tipText = AF.L[roles[i]]
        widgets[i].value = roles[i]
    end
    sorter:SetWidgets(widgets)

    local groups = {}

    local function UpdateGroupButtons()
        for i = 1, 8 do
            if pane.groupFilter[i] then
                groups[i]:SetBorderColor("BFI")
            else
                groups[i]:SetBorderColor("border")
            end
        end
    end

    for i = 1, 8 do
        groups[i] = AF.CreateButton(pane, i, "BFI_hover", 20, 20)
        AF.ClearPoints(groups[i].text)
        AF.SetPoint(groups[i].text, "CENTER")

        groups[i]:SetOnClick(function()
            if not pane.groupFilter[i] then
                pane.groupFilter[i] = true
            else
                pane.groupFilter[i] = nil
            end
            UpdateGroupButtons()
            pane.t.cfg.groupFilter = AF.TableToString(pane.groupFilter, ",", true)
            AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        end)

        if i == 1 then
            AF.SetPoint(groups[i], "TOPLEFT", sortByRole, "BOTTOMLEFT", 0, -15)
        else
            AF.SetPoint(groups[i], "TOPLEFT", groups[i - 1], "TOPRIGHT", 5, 0)
        end
    end

    local spacingX = AF.CreateSlider(pane, L["X Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacingX, "TOPLEFT", groups[1], "BOTTOMLEFT", 0, -25)
    spacingX:SetOnValueChanged(function(value)
        pane.t.cfg.spacingX = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local spacingY = AF.CreateSlider(pane, L["Y Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacingY, "TOPLEFT", spacingX, 185, 0)
    spacingY:SetOnValueChanged(function(value)
        pane.t.cfg.spacingY = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local maxColumns = AF.CreateSlider(pane, L["Max Columns"], 150, 1, 8, 1, nil, true)
    AF.SetPoint(maxColumns, "TOPLEFT", spacingX, "BOTTOMLEFT", 0, -40)

    local unitsPerColumn = AF.CreateSlider(pane, L["Units Per Column"], 150, 1, 40, 1, nil, true)
    AF.SetPoint(unitsPerColumn, "TOPLEFT", maxColumns, 185, 0)
    unitsPerColumn:SetOnValueChanged(function(value)
        pane.t.cfg.unitsPerColumn = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    maxColumns:SetOnValueChanged(function(value)
        pane.t.cfg.maxColumns = value
        local maxUnitsPerColumn = ceil(40 / value)
        unitsPerColumn:SetMinMaxValues(1, maxUnitsPerColumn)
        if pane.t.cfg.unitsPerColumn > maxUnitsPerColumn then
            pane.t.cfg.unitsPerColumn = maxUnitsPerColumn
            unitsPerColumn:SetValue(maxUnitsPerColumn)
        end
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    arrangement:SetOnSelect(function(value)
        pane.t.cfg.orientation = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
        if value:find("^left") or value:find("^right") then
            maxColumns:SetLabel(L["Max Rows"])
            unitsPerColumn:SetLabel(L["Units Per Row"])
        else
            maxColumns:SetLabel(L["Max Columns"])
            unitsPerColumn:SetLabel(L["Units Per Column"])
        end
    end)

    local function callback(t)
        pane.t.cfg.groupingOrder = AF.TableToString(t, ",")
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end
    sorter:SetCallback(callback)

    sortByRole:SetOnCheck(function(checked)
        if checked then
            pane.t.cfg.sortMethod = "NAME"
            pane.t.cfg.groupBy = "ASSIGNEDROLE"
            pane.t.cfg.groupingOrder = "TANK,HEALER,DAMAGER,NONE"
            sorter:SetConfigTable(AF.StringToTable(pane.t.cfg.groupingOrder, ","))
            sorter:Show()
        else
            pane.t.cfg.sortMethod = "INDEX"
            pane.t.cfg.groupBy = nil
            pane.t.cfg.groupingOrder = ""
            sorter:Hide()
        end
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    function pane.Load(t)
        pane.t = t

        arrangement:SetSelectedValue(t.cfg.orientation)
        anchorPoint:SetSelectedValue(t.cfg.anchor)
        spacingX:SetValue(t.cfg.spacingX)
        spacingY:SetValue(t.cfg.spacingY)

        local maxUnitsPerColumn = ceil(40 / t.cfg.maxColumns)
        unitsPerColumn:SetMinMaxValues(1, maxUnitsPerColumn)
        maxColumns:SetValue(t.cfg.maxColumns)
        unitsPerColumn:SetValue(t.cfg.unitsPerColumn)
        if t.cfg.orientation:find("^left") or t.cfg.orientation:find("^right") then
            maxColumns:SetLabel(L["Max Rows"])
            unitsPerColumn:SetLabel(L["Units Per Row"])
        else
            maxColumns:SetLabel(L["Max Columns"])
            unitsPerColumn:SetLabel(L["Units Per Column"])
        end

        sortByRole:SetChecked(t.cfg.groupBy == "ASSIGNEDROLE")
        sorter:SetShown(t.cfg.groupBy == "ASSIGNEDROLE")
        if t.cfg.groupBy == "ASSIGNEDROLE" then
            sorter:SetConfigTable(AF.StringToTable(t.cfg.groupingOrder, ","))
        end

        pane.groupFilter = AF.TransposeTable(AF.StringToTable(t.cfg.groupFilter, ",", true), true)
        UpdateGroupButtons()
    end

    return pane
end

---------------------------------------------------------------------
-- groupArrangement
---------------------------------------------------------------------
builder["groupArrangement"] = function(parent)
    if created["groupArrangement"] then return created["groupArrangement"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_UnitFrameOption_GroupArrangement", nil, 103)
    created["groupArrangement"] = pane

    local arrangement = AF.CreateDropdown(pane, 150)
    arrangement:SetLabel(AF.GetGradientText(L["Arrangement"], "BFI", "white"))
    AF.SetPoint(arrangement, "TOPLEFT", 15, -25)
    arrangement:SetItems(AF.GetDropdownItems_SimpleOrientation())
    arrangement:SetOnSelect(function(value)
        pane.t.cfg.orientation = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local anchorPoint = AF.CreateDropdown(pane, 150)
    anchorPoint:SetLabel(L["Anchor Point"])
    AF.SetPoint(anchorPoint, "TOPLEFT", arrangement, 185, 0)
    anchorPoint:SetEnabled(false) -- TODO: add auto-sized header
    anchorPoint:SetItems(AF.GetDropdownItems_AnchorPoint(true))
    anchorPoint:SetOnSelect(function(value)
        pane.t.cfg.anchor = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    local spacing = AF.CreateSlider(pane, L["Spacing"], 150, -1, 100, 1, nil, true)
    AF.SetPoint(spacing, "TOPLEFT", arrangement, "BOTTOMLEFT", 0, -25)
    spacing:SetOnValueChanged(function(value)
        pane.t.cfg.spacing = value
        AF.Fire("BFI_UpdateModule", "unitFrames", pane.t.owner, true)
    end)

    function pane.Load(t)
        pane.t = t
        arrangement:SetSelectedValue(t.cfg.orientation)
        anchorPoint:SetSelectedValue(t.cfg.anchor)
        spacing:SetValue(t.cfg.spacing)
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetUnitFrameOptions(parent, info)
    for _, pane in pairs(created) do
        pane:Hide()
        AF.ClearPoints(pane)
    end

    wipe(options)
    tinsert(options, builder["copy,paste,reset"](parent))
    created["copy,paste,reset"]:Show()

    local id = info.id
    if not settings[id] then return options end

    for _, option in pairs(settings[id]) do
        if builder[option] then
            local pane = builder[option](parent)
            if not pane.IsApplicable or pane.IsApplicable(info) then
                tinsert(options, pane)
                pane:Show()
            end
        end
    end

    return options
end