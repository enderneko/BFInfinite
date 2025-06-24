---@class BFI
local BFI = select(2, ...)
local T = BFI.Tooltip
local L = BFI.L
local M = BFI.Misc
---@type AbstractFramework
local AF = _G.AbstractFramework
local IL = AF.ItemLevel

local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar
local ShoppingTooltip1 = ShoppingTooltip1
local ShoppingTooltip2 = ShoppingTooltip2

local AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall
local GetTooltipItem = TooltipUtil.GetDisplayedItem
local GetItemQualityByID = C_Item.GetItemQualityByID
local GetItemQualityColor = C_Item.GetItemQualityColor
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local UnpackAuraData = AuraUtil.UnpackAuraData

local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local GetWorldCursor = C_TooltipInfo.GetWorldCursor

local WrapTextInColor = WrapTextInColor
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local GetUnitName = GetUnitName
local UnitPVPName = UnitPVPName
local UnitIsPVP = UnitIsPVP
local UnitLevel = UnitLevel
local UnitClassBase = AF.UnitClassBase
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo
local IsInGroup = IsInGroup
local strfind = strfind
local format = format
local tconcat = table.concat
local utf8sub = string.utf8sub

local tooltipAnchor
local combatModifierKey, itemLevelEnabled

---------------------------------------------------------------------
-- IsWorldUnitTooltip
---------------------------------------------------------------------
local function IsWorldUnitTooltip()
    local data = GetWorldCursor()
    return data and data.type == Enum.TooltipDataType.Unit
end

---------------------------------------------------------------------
-- IsModifierKeyDown
---------------------------------------------------------------------
local IsModifierKeyDown = AF.noop_true
local modifiers = {
    ["SHIFT"] = IsShiftKeyDown,
    ["CTRL"] = IsControlKeyDown,
    ["ALT"] = IsAltKeyDown,
}

---------------------------------------------------------------------
-- get anchor
---------------------------------------------------------------------
local function GetTooltipAnchorPoint(owner)
    local scale = owner:GetScale()
    local x, y = owner:GetCenter()
    local point, anchorPoint

    local height = AF.UIParent:GetTop() / scale
    local width = AF.UIParent:GetRight() / scale

    if y >= (height * 2 / 3) then
        point, anchorPoint = "TOP", "BOTTOM"
        y = -1
    else
        point, anchorPoint = "BOTTOM", "TOP"
        y = 1
    end

    if x >= (width * 2 / 3) then
        point = point .. "RIGHT"
        anchorPoint = anchorPoint .. "RIGHT"
        x = -1
    else
        point = point .. "LEFT"
        anchorPoint = anchorPoint .. "LEFT"
        x = 1
    end

    return point, anchorPoint, x, y
end

---------------------------------------------------------------------
-- update anchor
---------------------------------------------------------------------
local function UpdateAnchor(tooltip, parent)
    if not T.config.enabled or tooltip:IsForbidden() or tooltip:GetAnchorType() ~= "ANCHOR_NONE" then
        return
    end

    tooltip:ClearAllPoints()

    if parent.tooltip then
        --! use module settings
        local tt = parent.tooltip
        if tt.enabled and not (tt.hideInCombat and InCombatLockdown()) then
            if tooltip == GameTooltip and type(tt.supportsItemComparison) == "boolean" then
                tooltip.supportsItemComparison = tt.supportsItemComparison
            end

            if tt.anchorTo == "self" then
                tooltip:SetPoint(tt.position[1], parent, tt.position[2], tt.position[3], tt.position[4])
            elseif tt.anchorTo == "self_adaptive" then
                local point, anchorPoint, x, y = GetTooltipAnchorPoint(parent)
                tooltip:SetPoint(point, parent, anchorPoint, x, y)
            -- elseif tt.anchorTo then
            --     tooltip:SetPoint(tt.position[1], tt.anchorTo, tt.position[2], tt.position[3], tt.position[4])
            else
                local point = GetTooltipAnchorPoint(tooltipAnchor)
                tooltip:SetPoint(point, tooltipAnchor)
            end
        else
            tooltip:Hide()
        end

    else
        --! use tooltip settings
        if InCombatLockdown() and IsWorldUnitTooltip() and not IsModifierKeyDown() then
            return
        end

        if tooltip.StatusBar then
            local statusBar = tooltip.StatusBar
            statusBar:SetAlpha(T.config.healthBar.enabled and 1 or 0)
            -- AF.SetPoint(statusBar, "TOPLEFT", tooltip, "BOTTOMLEFT", 0, 0)
        end

        if T.config.cursorAnchor.type then
            -- NOTE: x, y won't be used if type is "ANCHOR_CURSOR"
            tooltip:SetOwner(parent, T.config.cursorAnchor.type, T.config.cursorAnchor.x, T.config.cursorAnchor.y)
        else
            local point = GetTooltipAnchorPoint(tooltipAnchor)
            tooltip:SetPoint(point, tooltipAnchor)
        end
    end
end

---------------------------------------------------------------------
-- WORLD_CURSOR_TOOLTIP_UPDATE
---------------------------------------------------------------------
local function WORLD_CURSOR_TOOLTIP_UPDATE(_, _, state)
    if GameTooltip:IsForbidden() or T.config.cursorAnchor.type then return end
    if state == 0 then
        -- hide immediately
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- toggle visibility in combat with modifier key
---------------------------------------------------------------------
local function RefreshData()
    GameTooltip:RefreshData()
end

local function ShowItemLevel(_, unit)
    if unit and unit ~= "mouseover" then return end
    if not (UnitExists("mouseover") and UnitIsPlayer("mouseover")) then return end

    local itemLevel, elapsed = IL.GetCache(UnitGUID("mouseover"))
    if itemLevel and elapsed < 120 then
        AF.UnregisterCallback("AF_UNIT_ITEM_LEVEL_UPDATE")
        RefreshData()
    else
        -- print("REGISTER AF_UNIT_ITEM_LEVEL_UPDATE")
        AF.RegisterCallback("AF_UNIT_ITEM_LEVEL_UPDATE", RefreshData)
        IL.UpdateCache("mouseover")
    end
end

local function MODIFIER_STATE_CHANGED(_, _, key, down)
    if GameTooltip:IsForbidden() then return end

    if combatModifierKey and InCombatLockdown() and IsWorldUnitTooltip() and key:find(combatModifierKey) then
        if down == 1 then
            GameTooltip:SetWorldCursor(Enum.WorldCursorAnchorType.Default)
        else
            GameTooltip:Hide()
        end
    end

    if itemLevelEnabled and not InCombatLockdown() and key:find("ALT") then
        if down == 1 then
            GameTooltip:RefreshData()
            ShowItemLevel()
        else
            GameTooltip:RefreshData()
        end
    end
end

local function PLAYER_REGEN_ENABLED()
    if not GameTooltip:IsForbidden() and IsWorldUnitTooltip() then
        GameTooltip:SetWorldCursor(Enum.WorldCursorAnchorType.Default)
    end
end

local function PLAYER_REGEN_DISABLED()
    if not GameTooltip:IsForbidden() and IsWorldUnitTooltip() then
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- UpdateStatusBarText
---------------------------------------------------------------------
local FormatNumber

local function UpdateStatusBarText(bar, value)
    if bar:IsForbidden() or not (T.config.healthBar.enabled and T.config.healthBar.text.enabled) or not bar.text then
        return
    end

    local _, unit = GameTooltip:GetUnit()

    local maxValue
    if unit then
        value = UnitHealth(unit)
        maxValue = UnitHealthMax(unit)

        if UnitIsGhost(unit) then
            bar.text:SetText(AF.WrapTextInColor(AF.L["Ghost"], "red"))
        elseif UnitIsDead(unit) then
            bar.text:SetText(AF.WrapTextInColor(AF.L["Dead"], "red"))
        else
            bar.text:SetFormattedText("%s | %d%%", FormatNumber(value), value / maxValue * 100)
        end
    else
        _, maxValue = bar:GetMinMaxValues()
        bar.text:SetFormattedText("%.1f%%", value / maxValue * 100)
    end
end

---------------------------------------------------------------------
-- OnTooltipSetUnit
---------------------------------------------------------------------
local UNKNOWN = _G.UNKNOWN
local LEVEL = _G.LEVEL
local UNIT_SKINNABLE_BOLTS = _G.UNIT_SKINNABLE_BOLTS
local UNIT_SKINNABLE_LEATHER = _G.UNIT_SKINNABLE_LEATHER
local PVP = _G.PVP
local FACTION_HORDE = _G.FACTION_HORDE
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local BOSS = _G.BOSS
local RARE = _G.MAP_LEGEND_RARE
-- local RAREELITE = _G.MAP_LEGEND_RAREELITE
local genders = {UNKNOWN, _G.MALE, _G.FEMALE}
local AI_RACE_MATCHER = _G.TOOLTIP_UNIT_LEVEL_RACE:gsub("%%s", "[0-9?]+", 1):gsub("%%s", "(.+)")
local TARGET = _G.TARGET .. ": %s"
local YOU = AF.WrapTextInColor(_G.YOU .. "!", "firebrick")
local CHALLENGE_COMPLETE_DUNGEON_SCORE = _G.CHALLENGE_COMPLETE_DUNGEON_SCORE
local RENOWN_REWARD_MOUNT_NAME_FORMAT = _G.RENOWN_REWARD_MOUNT_NAME_FORMAT:gsub("%%s", "|cffffffff%%s|r%%s")
local CHARACTER_LINK_ITEM_LEVEL_TOOLTIP = _G.CHARACTER_LINK_ITEM_LEVEL_TOOLTIP:gsub("%%d", "|cffffffff%%s|r")
local CALCULATING = AF.WrapTextInColor(L["Calculating..."], "gray")

--? UNUSED
-- local function UpdateLine(tooltip, line, text, r, g, b)
--     if tooltip:IsForbidden() then return end

--     if line then
--         local leftText = _G["GameTooltipTextLeft" .. line]
--         leftText:SetText(AF.WrapTextInColorRGB(text, r, g, b))
--     else
--         tooltip:AddLine(text, r, g, b)
--     end
-- end

--! save some required system lines ---------------------------------
local requiredLines = {}
local specLine, levelLine

-- Enum.TooltipDataType
local IGNORED_UNIT_LINES = {
    [0] = true, -- None
    [1] = true, -- Blank
    [2] = true, -- UnitName
}

local function SaveRequiredLines(data, isPlayer, isAI)
    if not data.lines then return end

    wipe(requiredLines)

    local levelLineIndex, requiredIndex
    local leftText

    for i, line in next, data.lines do
        leftText = line.leftText

        if not levelLineIndex and strfind(leftText, LEVEL) then
            levelLineIndex = i
            requiredIndex = i + 2
        end

        if levelLineIndex == i and (isPlayer or isAI) then
            levelLine = line
        end

        if not IGNORED_UNIT_LINES[line.type] then
            requiredIndex = i
        end

        -- if not IGNORED_UNIT_LINES[line.type] or (leftText == UNIT_SKINNABLE_BOLTS or leftText == UNIT_SKINNABLE_LEATHER) then
        if requiredIndex and i >= requiredIndex and leftText ~= PVP and leftText ~= FACTION_HORDE and leftText ~= FACTION_ALLIANCE then
            if line.type == 8 then
                line.leftText = AF.WrapTextInColor(" - ", "darkgray") .. leftText -- add space for QuestObjective
            end
            tinsert(requiredLines, line)
        end
    end

    if (isPlayer or isAI) and levelLineIndex then
        specLine = data.lines[levelLineIndex + 1]
    end
end

local function RestoreRequiredLines()
    if GameTooltip:IsForbidden() then return end
    if not next(requiredLines) then return end

    for _, line in next, requiredLines do
        if line.rightText then
            GameTooltip:AddDoubleLine(line.leftText, line.rightText,
                line.leftColor.r, line.leftColor.g, line.leftColor.b,
                line.rightColor.r, line.rightColor.g, line.rightColor.b)
        else
            GameTooltip:AddLine(line.leftText,
                line.leftColor.r, line.leftColor.g, line.leftColor.b, line.wrapText)
        end
    end
end

--! formatters ------------------------------------------------------
local targetedBy = {}
local targetedByFormat = "%s (|cffffffff%d|r): %s"
local targetedBySep = AF.WrapTextInColor(", ", "gray")
local guildFormat = "<" .. AF.WrapTextInColor("%s", "guild") .. ">"
local bracketFormat = AF.WrapTextInColor(" (%d)", "gray")
local mythicPlusFormat = "%s" .. bracketFormat

local function GetLevel(unit)
    local r, g, b = AF.GetLevelColor(unit)
    local level = AF.WrapTextInColorRGB(AF.GetLevelText(unit), r, g, b)

    local classification = UnitClassification(unit)
    if strfind(classification, "^rare") then
        level = level .. " " .. AF.WrapTextInColor(RARE, "hotpink")
    elseif classification == "elite" and UnitLevel(unit) == -1 then
        level = level .. " " .. AF.WrapTextInColor(BOSS, "firebrick")
    end

    return level
end

local function GetRace(unit, isPlayer)
    local race
    if isPlayer then
        race = UnitRace(unit)
    elseif levelLine then
        race = levelLine.leftText:match(AI_RACE_MATCHER)
    else
        local type = UnitCreatureType(unit)
        local family = UnitCreatureFamily(unit)

        if family and type then
            race = family .. " " .. AF.WrapTextInColor(type, "gray")
        elseif type then
            race = type
        elseif family then
            race = family
        end
    end

    return race
end

local lineFormatters = {
    name = function(config, tooltip, unit, isPlayer, isNotSpecified)
        local name, realm = UnitName(unit)

        if config.showTitle then
            name = isPlayer and UnitPVPName(unit) or UnitName(unit)
        end

        if name then
            if config.showServer and realm then
                name = name .. "-" .. realm
            end

            local r, g, b
            if UnitIsTapDenied(unit) then
                r, g, b = AF.GetColorRGB("gray")
            elseif not isNotSpecified then
                r, g, b = AF.GetUnitColor(unit)
            end
            tooltip:AddLine(name, r, g, b)
        end
    end,

    level_race = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if isNotSpecified then return end

        local level = GetLevel(unit)
        local race = GetRace(unit, isPlayer)

        if config.showGender and isPlayer then
            local sex = UnitSex(unit)
            sex = AF.WrapTextInColor(genders[sex], "gray")
            race = race .. " " .. sex
        end

        if isPlayer then
            local faction = UnitFactionGroup(unit)
            race = AF.GetIconString("Faction_" .. faction) .. race
        end

        if level and race then
            tooltip:AddLine(level .. " " .. race, 1, 1, 1)
        end
    end,

    guild = function(config, tooltip, unit, isPlayer)
        if not isPlayer then return end
        local name, rank, index, realm = GetGuildInfo(unit)
        if name and rank and index then
            if realm then
                name = name .. "-" .. realm
            end
            local fmt = guildFormat
            if config.showRankName then
                fmt = fmt .. " %s"
            end
            if config.showRankIndex then
                fmt = fmt .. bracketFormat
            end
            tooltip:AddLine(format(fmt, name, rank, index), 1, 1, 1)
        end
    end,

    spec = function(config, tooltip, unit)
        if specLine then
            local class = UnitClassBase(unit)
            tooltip:AddLine(specLine.leftText, AF.GetClassColor(class))
        end
    end,

    npc_subtitle = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if isPlayer or isNotSpecified then return end
        local subtitle = AF.GetNPCSubtitle(unit)
        if subtitle then
            tooltip:AddLine(format("<%s>", subtitle), 1, 1, 1)
        end
    end,

    npc_faction = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if isPlayer or isNotSpecified then return end
        local faction = AF.GetNPCFaction(unit)
        if faction then
            tooltip:AddLine(faction, 1, 1, 1)
        end
    end,

    npc_pvp = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if isNotSpecified then return end
        if not isPlayer and UnitIsPVP(unit) then
            tooltip:AddLine(PVP, 1, 1, 1)
        end
    end,

    target = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if isNotSpecified then return end
        local unit = unit == "player" and "target" or unit .. "target"
        if not UnitExists(unit) then return end

        if UnitIsUnit(unit, "player") then
            tooltip:AddLine(TARGET:format(YOU))
        else
            local name = GetUnitName(unit)
            if name then
                local r, g, b = AF.GetUnitColor(unit)
                tooltip:AddLine(TARGET:format(AF.WrapTextInColorRGB(name, r, g, b)))
            end
        end
    end,

    targeted_by = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if not IsInGroup() then return end
        wipe(targetedBy)

        local name
        if config.includeSelf then
            for member in AF.GroupPlayersIterator() do
                name = AF.TruncateStringByLength(UnitName(member), config.enChars, config.nonEnChars)
                if name and UnitIsUnit(member .. "target", unit) then
                    if UnitIsUnit(member, "player") then
                        tinsert(targetedBy, 1, AF.WrapTextInColor(name, AF.UnitClassBase(member) or "white"))
                    else
                        tinsert(targetedBy, AF.WrapTextInColor(name, AF.UnitClassBase(member) or "white"))
                    end
                end
            end
        else
            for member in AF.GroupPlayersIterator() do
                name = AF.TruncateStringByLength(UnitName(member), config.enChars, config.nonEnChars)
                if name and UnitIsUnit(member .. "target", unit) and not UnitIsUnit(member, "player") then
                    tinsert(targetedBy, AF.WrapTextInColor(name, AF.UnitClassBase(member) or "white"))
                end
            end
        end

        local num = #targetedBy
        if num > 0 then
            tooltip:AddLine(format(targetedByFormat, L["Targeted By"], num, tconcat(targetedBy, targetedBySep)), nil, nil, nil, true)
        end
    end,

    mythic_plus_rating = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if not isPlayer then return end
        local info = GetPlayerMythicPlusRatingSummary(unit)
        if not (info and info.currentSeasonScore) then return end

        local score = info.currentSeasonScore
        score = WrapTextInColor(score, GetDungeonScoreRarityColor(score))

        if config.showBestRunLevel and info.runs then
            local bestRunLevel = 0
            for _, run in next, info.runs do
                if run.finishedSuccess and run.bestRunLevel > bestRunLevel then
                    bestRunLevel = run.bestRunLevel
                end
            end
            if bestRunLevel > 0 then
                score = format(mythicPlusFormat, score, bestRunLevel)
            end
        end

        tooltip:AddLine(format(CHALLENGE_COMPLETE_DUNGEON_SCORE, score))
    end,

    mount = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if not isPlayer then return end
        if config.showIfOutOfCombat and InCombatLockdown() then return end

        local mountInfo = M.GetMountInfoFromUnit(unit)
        if mountInfo and mountInfo.name then
            tooltip:AddLine(format(RENOWN_REWARD_MOUNT_NAME_FORMAT, mountInfo.name, AF.GetIconString(mountInfo.isCollected and "Fluent_Color_Yes" or "Fluent_Color_No")))
        end
    end,

    item_level = function(config, tooltip, unit, isPlayer, isNotSpecified)
        if not (isPlayer and IsAltKeyDown()) then return end
        if InCombatLockdown() then return end

        local itemLevel, elapsed = IL.GetCache(UnitGUID(unit))
        if itemLevel and elapsed < 120 then
            tooltip:AddLine(format(CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, itemLevel))
        else
            tooltip:AddLine(format(CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, CALCULATING))
            ShowItemLevel()
        end
    end,
}

--! save tooltip lines added by other addons ------------------------
local addonLines = {}

local function SaveOtherAddonsLines(index)
    wipe(addonLines)

    local lt, rt = _G["GameTooltipTextLeft" .. index], _G["GameTooltipTextRight" .. index]
    local r, g, b
    while lt and rt do
        -- left
        local textLeft = lt:GetText()
        if lt:IsShown() and textLeft then
            if not addonLines[index] then addonLines[index] = {} end
            addonLines[index]["left"] = {
                text = textLeft,
                rgb = {lt:GetTextColor()},
            }
        end

        -- right
        local textRight = rt:GetText()
        if rt:IsShown() and textRight then
            if not addonLines[index] then addonLines[index] = {} end
            addonLines[index]["right"] = {
                text = textRight,
                rgb = {rt:GetTextColor()},
            }
        end

        index = index + 1

        lt = _G["GameTooltipTextLeft" .. index]
        rt = _G["GameTooltipTextRight" .. index]
    end
end

local function RestoreOtherAddonsLines()
    if GameTooltip:IsForbidden() then return end
    if not next(addonLines) then return end

    for _, line in next, addonLines do
        if line.right then
            if line.left then
                GameTooltip:AddDoubleLine(line.left.text, line.right.text,
                    line.left.rgb[1], line.left.rgb[2], line.left.rgb[3],
                    line.right.rgb[1], line.right.rgb[2], line.right.rgb[3])
            else
                GameTooltip:AddDoubleLine("", line.right.text,
                    1, 1, 1,
                    line.right.rgb[1], line.right.rgb[2], line.right.rgb[3])
            end
        elseif line.left then
            GameTooltip:AddLine(line.left.text,
                line.left.rgb[1], line.left.rgb[2], line.left.rgb[3])
        end
    end

    wipe(addonLines)
end

--! target ----------------------------------------------------------
local lastMouseoverTargetGUID, newMouseoverTargetGUID -- for "target"
local groupTargetChanged -- for "targeted_by"

local function UpdateTarget()
    --! NOTE: if mouse is down, the mouseover unit DOES NOT EXIST!!!
    newMouseoverTargetGUID = UnitGUID("mouseovertarget")
    if UnitExists("mouseover") and (lastMouseoverTargetGUID ~= newMouseoverTargetGUID or groupTargetChanged) then
        lastMouseoverTargetGUID = newMouseoverTargetGUID
        groupTargetChanged = nil
        GameTooltip:RefreshData()
        GameTooltip.UpdateTooltip = UpdateTarget
    end
end

local function UNIT_TARGET()
    groupTargetChanged = true
end

local function OnTooltipCleared()
    GameTooltip.UpdateTooltip = nil
end

local function OnTooltipSetUnit(tooltip, data)
    if tooltip:IsForbidden() or tooltip ~= GameTooltip then return end
    -- texplore(data)

    local _, unit = tooltip:GetUnit()
    if not (unit and UnitExists(unit)) then return end
    if UnitIsBattlePetCompanion(unit) or UnitIsWildBattlePet(unit) then return end

    local isPlayer = UnitIsPlayer(unit)
    local isAI = UnitInPartyIsAI(unit)
    local isNotSpecified = select(2, UnitCreatureType(unit)) == 10
    local numLines = #data.lines

    -- save
    SaveRequiredLines(data, isPlayer, isAI)
    SaveOtherAddonsLines(numLines + 1)

    -- clear
    tooltip:ClearLines()

    -- BFI lines
    local lines = T.config.lines
    for i, line in next, lines do
        if line.enabled and lineFormatters[line.type] then
            lineFormatters[line.type](line, tooltip, unit, isPlayer, isNotSpecified)
        end
    end
    specLine = nil
    levelLine = nil

    -- restore
    RestoreRequiredLines()
    RestoreOtherAddonsLines()

    -- update target
    lastMouseoverTargetGUID = UnitGUID(unit .. "target")
    tooltip.UpdateTooltip = UpdateTarget

    -- tooltip:Show()

    -- faction icon
    -- if isPlayer then
    --     local faction = UnitFactionGroup(unit)
    --     tooltip.factionIcon:SetTexture(AF.GetIcon("Faction_" .. faction))
    --     tooltip.factionIcon:Show()
    -- end

    --? UNUSED
    -- local currentLine = 1
    -- for _, line in next, lines do
    --     if lineFormatters[line] then
    --         if currentLine > numLines then
    --             lineFormatters[line](tooltip, unit, isPlayer)
    --         else
    --             lineFormatters[line](tooltip, unit, isPlayer)
    --         end
    --         currentLine = currentLine + 1
    --     end
    -- end

    -- clear unused lines
    -- for i = currentLine, numLines do
    --     local leftText = _G["GameTooltipTextLeft" .. i]
    --     if leftText then
    --         leftText:SetText("")
    --         leftText:Hide()
    --     end
    -- end
end

---------------------------------------------------------------------
-- OnTooltipSetItem
---------------------------------------------------------------------
local function OnTooltipSetItem(tooltip, data)
    if tooltip:IsForbidden() or (tooltip ~= GameTooltip and tooltip ~= ShoppingTooltip1 and tooltip ~= ShoppingTooltip2) then return end

    if tooltip == GameTooltip then
        tooltip.supportsItemComparison = true
    end

    -- Interface\AddOns\Blizzard_SharedXMLGame\Tooltip\TooltipUtil.lua
    local name, link, id = GetTooltipItem(tooltip)
    if not link then return end

    local quality = GetItemQualityByID(link)
    if quality and quality >= 2 then
        local r, g, b = GetItemQualityColor(quality)
        tooltip.NineSlice:SetBorderColor(r, g, b)
    end
end

---------------------------------------------------------------------
-- GameTooltip_SetUnitAura / GameTooltip_SetUnitAuraByAuraInstanceID
---------------------------------------------------------------------
local lastDataInstanceID, lastAuraData

local function UpdateAuraTooltip(tooltip, auraData)
    if not auraData then return end

    local data = tooltip:GetTooltipData()
    if data then
        lastDataInstanceID = data.dataInstanceID
        lastAuraData = auraData
    end

    if auraData.sourceUnit and UnitExists(auraData.sourceUnit) then
        local name = GetUnitName(auraData.sourceUnit) or UNKNOWN
        local r, g, b = AF.GetUnitColor(auraData.sourceUnit)
        tooltip:AddDoubleLine(utf8sub(_G.SOURCE, 1, -2), AF.WrapTextInColorRGB(name, r, g, b))
    end

    local mountInfo = M.GetMountInfoFromSpell(auraData.spellId)
    if mountInfo then
        tooltip:AddDoubleLine("MountID", mountInfo.id, nil, nil, nil, 1, 1, 1)
        if mountInfo.source then
            tooltip:AddLine(" ")
            tooltip:AddLine(mountInfo.source, 1, 1, 1)
            -- print(string.gsub(mountInfo.source, "|", "||"))
        end
    end

    tooltip:Show()
end

local function GameTooltip_SetUnitAura(tooltip, unit, index, filter)
    if tooltip:IsForbidden() then return end
    -- local name, _, _, _, _, _, source, _, _, spellID = UnpackAuraData(GetAuraDataByIndex(unit, index, filter))
    UpdateAuraTooltip(tooltip, GetAuraDataByIndex(unit, index, filter))
end

local function GameTooltip_SetUnitAuraByAuraInstanceID(tooltip, unit, auraInstanceID)
    if tooltip:IsForbidden() then return end
    UpdateAuraTooltip(tooltip, GetAuraDataByAuraInstanceID(unit, auraInstanceID))
end

local function GameTooltip_RefreshData()
    if GameTooltip:IsForbidden() or not lastAuraData then return end

    local info = GameTooltip:GetPrimaryTooltipInfo()
    if not (info and info.tooltipData) then return end

    -- if not (lastDataInstanceID and GameTooltip:HasDataInstanceID(lastDataInstanceID + 1)) then return end
    -- if info.tooltipData.dataInstanceID ~= lastDataInstanceID + 1 then return end

    if info.tooltipData.id == lastAuraData.spellId then
        UpdateAuraTooltip(GameTooltip, lastAuraData)
    end
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitTooltip()
    tooltipAnchor = CreateFrame("Frame", "BFI_TooltipAnchor", AF.UIParent)
    AF.SetSize(tooltipAnchor, 150, 30)
    AF.CreateMover(tooltipAnchor, "BFI: " .. _G.OTHER, L["Tooltip"])

    -- statusBar
    GameTooltipStatusBar:HookScript("OnValueChanged", UpdateStatusBarText)

    local text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
    GameTooltipStatusBar.text = text
    AF.SetFont(text, T.config.healthBar.text.font)
    text:SetPoint("CENTER")

    -- faction icon
    -- local factionIcon = AF.CreateTexture(GameTooltip, nil, nil, "ARTWORK")
    -- GameTooltip.factionIcon = factionIcon
    -- GameTooltip:HookScript("OnHide", function()
    --     factionIcon:Hide()
    -- end)

    -- post call - https://warcraft.wiki.gg/wiki/Patch_10.0.2/API_changes
    AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
    AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)

    -- hooks
    GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
    hooksecurefunc("GameTooltip_SetDefaultAnchor", UpdateAnchor)

    hooksecurefunc(GameTooltip, "RefreshData", GameTooltip_RefreshData)
    hooksecurefunc(GameTooltip, "SetUnitAura", GameTooltip_SetUnitAura)
    hooksecurefunc(GameTooltip, "SetUnitBuff", GameTooltip_SetUnitAura)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", GameTooltip_SetUnitAura)
    hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", GameTooltip_SetUnitAuraByAuraInstanceID)
    hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", GameTooltip_SetUnitAuraByAuraInstanceID)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateTooltip(_, module, which)
    if module and module ~= "Tooltip" then return end

    local config = T.config

    if tooltipAnchor then
        tooltipAnchor.enabled = config.enabled
    end

    if not config.enabled then
        T:UnregisterAllEvents()
        return
    end

    if not init then
        init = true
        InitTooltip()
    end

    -- position
    AF.UpdateMoverSave(tooltipAnchor, config.position)
    AF.LoadPosition(tooltipAnchor, config.position)

    -- modifier keys
    T:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)

    -- combat modifier key
    combatModifierKey = config.combatModifierKey
    if combatModifierKey then
        IsModifierKeyDown = modifiers[combatModifierKey]
        T:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
        T:RegisterEvent("PLAYER_REGEN_DISABLED", PLAYER_REGEN_DISABLED)
    else
        IsModifierKeyDown = AF.noop_true
        T:UnregisterEvent("PLAYER_REGEN_ENABLED")
        T:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end

    -- targetedBy
    for _, line in next, config.lines do
        if line.type == "targeted_by" then
            if line.enabled then
                T:RegisterEvent("UNIT_TARGET", UNIT_TARGET)
            else
                groupTargetChanged = nil
                T:UnregisterEvent("UNIT_TARGET")
            end
        elseif line.type == "item_level" then
            if line.enabled then
                itemLevelEnabled = true
            end
        end
    end

    -- WORLD_CURSOR_TOOLTIP_UPDATE
    T:RegisterEvent("WORLD_CURSOR_TOOLTIP_UPDATE", WORLD_CURSOR_TOOLTIP_UPDATE)

    -- health text format
    if config.healthBar.text.useAsianUnits and AF.isAsian then
        FormatNumber = AF.FormatNumber_Asian
    else
        FormatNumber = AF.FormatNumber
    end

    -- status bar
    AF.SetHeight(GameTooltipStatusBar, config.healthBar.height)

    -- faction icon
    -- if config.factionIcon.enabled then
    --     AF.LoadWidgetPosition(GameTooltip.factionIcon, config.factionIcon.position, GameTooltip)
    --     AF.SetSize(GameTooltip.factionIcon, config.factionIcon.size, config.factionIcon.size)
    --     GameTooltip.factionIcon:SetAlpha(config.factionIcon.alpha)
    -- end
end
AF.RegisterCallback("BFI_UpdateModules", UpdateTooltip)