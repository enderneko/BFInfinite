---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.M_NamePlates

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
NP.created = {}
local SERVER_NAME = GetNormalizedRealmName()

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local WorldFrame = WorldFrame
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local SetCVar = C_CVar.SetCVar
local GetCVarDefault = C_CVar.GetCVarDefault
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitName = UnitName
local GetRaidTargetIndex = GetRaidTargetIndex

function NP.GetNameplateForUnit(unit)
    local nameplate = GetNamePlateForUnit(unit)
    if nameplate then
        return nameplate.bfi, nameplate
    end
end

function NP.ToggleClickableArea()
    NP.showClickableArea = not NP.showClickableArea
    for _, np in pairs(NP.created) do
        np.clickableArea:SetShown(NP.showClickableArea)
    end
end

function NP.IterateAllVisibleNamePlates(func, reaction)
    for _, np in pairs(NP.created) do
        if not reaction or reaction == np.reaction_current then
            if np:IsVisible() then
                func(np)
            end
        end
    end
end

local function GetUnitReaction(unit)
    local reaction = UnitReaction(unit, "player")
    -- if reaction == 4 then
    --     return "neutral"
    if reaction <= 4 then
        return "hostile"
    else
        return "friendly"
    end
end

-- player,pet,guardian,npc
local function GetUnitType(unit)
    if UnitIsPlayer(unit) then
        return "player"
    end
    if UnitIsOtherPlayersPet(unit) or UnitIsUnit(unit, "pet") then
        return "pet"
    end
    if UnitPlayerControlled(unit) then
        return "guardian"
    end
    return "npc"
end

-- boss,rare,elite,normal,minor,totem
local function GetUnitClassification(unit, level)
    if level == -1 then
        return "boss"
    end

    local classification = UnitClassification(unit)
    if strfind(classification, "^rare") then
        return "rare"
    elseif classification == "trivial" or classification == "minus" then
        return "minor"
    end
    return classification
end

---------------------------------------------------------------------
-- cvars
---------------------------------------------------------------------
local function ResetCVar(cvar)
    SetCVar(cvar, GetCVarDefault(cvar))
end

function NP.ResetCVars()
    ResetCVar("nameplateOccludedAlphaMult")
    ResetCVar("NamePlateHorizontalScale")
    ResetCVar("NamePlateVerticalScale")
    ResetCVar("nameplateMaxScale")
    ResetCVar("nameplateMinScale")
    ResetCVar("nameplateLargerScale")
    ResetCVar("nameplateGlobalScale")
    ResetCVar("nameplateSelectedScale")
    ResetCVar("nameplateOverlapH")
    ResetCVar("nameplateOverlapV")
end

local function UpdateCVars()
    SetCVar("NamePlateHorizontalScale", 1.0)
    SetCVar("NamePlateVerticalScale", 1.0)
    SetCVar("NamePlateClassificationScale", 1.0)
    if NP.config.alphas.occluded.enabled then
        SetCVar("nameplateOccludedAlphaMult", NP.config.alphas.occluded.value)
    end
    SetCVar("nameplateMaxScale", 1.0)
    SetCVar("nameplateMinScale", 1.0)
    SetCVar("nameplateLargerScale", 1.0)
    SetCVar("nameplateGlobalScale", 1.0)
    SetCVar("nameplateSelectedScale", 1.0)
end

---------------------------------------------------------------------
-- UpdateNameplateBase
---------------------------------------------------------------------
local function UpdateNameplateBase(np)
    -- BFI.Debug("|cffffff00UpdateNameplateBase:|r", np:GetName())

    wipe(np.states)

    local unit = np.unit

    np.reaction_current = GetUnitReaction(unit)

    np.states.name, np.states.server = UnitName(unit)
    np.states.server = np.states.server or SERVER_NAME
    np.states.level = UnitEffectiveLevel(unit)
    np.states.reaction = GetUnitReaction(unit)
    np.states.type = GetUnitType(unit)
    np.states.classification = GetUnitClassification(unit, np.states.level)

    np.states.isHostile = np.reaction_current ~= "friendly"
    np.states.isSameServer = np.states.server == SERVER_NAME
end

---------------------------------------------------------------------
-- OnNameplateShow
---------------------------------------------------------------------
local function OnNameplateShow(np)
    UpdateNameplateBase(np)

    if np.reaction_previous ~= np.reaction_current then
        np.reaction_previous = np.reaction_current
        NP.SetupIndicators(np, NP.config[np.states.isHostile and "hostile" or "friendly"])
        BFI.Debug("|cffffff00NameplateUnitTypeChanged:|r", np:GetName())
    end

    NP.OnNameplateShow(np)
end

---------------------------------------------------------------------
-- OnNameplateUpdate
---------------------------------------------------------------------
local alphas
local alpha_order = {"occluded", "mouseover", "marked", "casting"}

local alpha_funcs = {}
local alpha_target_func
local alpha_no_target_func

local occluded_alpha

local alpha_funcs_default = {
    occluded = function(np)
        if np.blz:GetAlpha() <= occluded_alpha then
            return alphas.occluded.value
        end
    end,
    mouseover = function(np)
        if UnitIsUnit("mouseover", np.unit) then
            return alphas.mouseover.value
        end
    end,
    marked = function(np)
        if GetRaidTargetIndex(np.unit) then
            return alphas.marked.value
        end
    end,
    casting = function(np)
        if UnitCastingInfo(np.unit) or UnitChannelInfo(np.unit) then
            return alphas.casting.value
        end
    end,
    target = function(np)
        if UnitIsUnit("target", np.unit) then
            return alphas.target.value
        end
    end,
    non_target = function(np)
        if not UnitIsUnit("target", np.unit) then
            return alphas.non_target.value
        end
    end,
    target_non_target = function(np)
        if UnitIsUnit("target", np.unit) then
            return alphas.target.value
        else
            return alphas.non_target.value
        end
    end,
    no_target = function()
        return alphas.no_target.value
    end,
}

local function GetAlpha(np)
    local alpha

    -- return directly
    for _, f in ipairs(alpha_funcs) do
        alpha = f(np)
        if alpha then
            return alpha
        end
    end

    -- target related
    if UnitExists("target") then
        if alpha_target_func then
            alpha = alpha_target_func(np)
        end
    else
        if alpha_no_target_func then
            alpha = alpha_no_target_func()
        end
    end

    alpha = alpha or 1

    -- type & classification
    if np.states.type == "npc" then
        if np.states.classification == "normal" then
            alpha = NP.config.alphas.npc * alpha
        else
            alpha = NP.config.alphas[np.states.classification] * alpha
        end
    else
        alpha = NP.config.alphas[np.states.type] * alpha
    end

    return alpha
end

local function OnNameplateUpdate(np, elapsed)
    np.elapsed = (np.elapsed or 0) + elapsed
    if np.elapsed >= 0.25 then
        --! frame level
        np:SetFrameLevel(np.blz:GetFrameLevel() * 10)

        if np.unit then
            local guid = UnitGUID(np.unit)
            if guid ~= np.guid then
                np.guid = guid
                BFI.Debug("|cffff7700NameplateUnitChanged:|r", np:GetName())
                UpdateNameplateBase(np)
            end
            np:SetAlpha(GetAlpha(np))
        else
            np:SetAlpha(1)
        end
    end
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
local function ShowNameplate(self, event, unit)
    local np, blz = NP.GetNameplateForUnit(unit)
    if not np then return end

    -- BFI.Debug("|cff00ff00ShowNameplate:|r", np:GetName())

    local show

    if blz.UnitFrame then
        if UnitIsUnit("player", unit) or UnitNameplateShowsWidgetsOnly(unit) then
            blz.UnitFrame:Show()
            np.unit = nil
            np:Hide()
        else
            -- blz.UnitFrame:ClearAllPoints()
            -- blz.UnitFrame:SetParent(nil)
            blz.UnitFrame:Hide()
            np.unit = blz.namePlateUnitToken
            np.guid = UnitGUID(np.unit)
            show = true
        end
    -- else
    --     np.unit = nil
    --     show = true -- TODO: progress bar?
    end

    if show then
        np:Show()
    else
        np:Hide()
    end

    -- TODO: filters
end

---------------------------------------------------------------------
-- hide
---------------------------------------------------------------------
local function HideNameplate(self, event, unit)
    local np = NP.GetNameplateForUnit(unit)
    if not np then return end

    -- BFI.Debug("|cff229922HideNameplate:|r", np:GetName())

    np:Hide()
    wipe(np.states)
    np.unit = nil
    np.guid = nil

    NP.OnNameplateHide(np)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function UpdatePixels(self)
    for _, indicator in pairs(self.indicators) do
        if indicator.UpdatePixels then
            indicator:UpdatePixels()
        end
    end
end

local function CreateNameplate(self, event, nameplate)
    local np = CreateFrame("Frame", "BFI" .. nameplate:GetName(), AW.UIParent)
    np:Hide()
    np:SetFrameStrata("BACKGROUND")
    np:SetAllPoints(nameplate)

    np.blz = nameplate
    nameplate.bfi = np
    NP.created[nameplate] = np

    BFI.Debug("|cffff7777CreateNameplate:|r", np:GetName())

    np.states = {}
    np.indicators = {}
    -- texplore(np.states)
    NP.CreateIndicators(np)

    -- script
    np:SetScript("OnUpdate", OnNameplateUpdate)
    np:SetScript("OnShow", OnNameplateShow)

    -- clickable area
    np.clickableArea = np:CreateTexture(nil, "BACKGROUND", nil, -7)
    np.clickableArea:SetAllPoints()
    np.clickableArea:SetColorTexture(0, 1, 0, 0.15)
    np.clickableArea:SetShown(NP.showClickableArea)

    -- pixel perfect
    AW.AddToPixelUpdater(np, UpdatePixels)
end

---------------------------------------------------------------------
-- hide blizzard
---------------------------------------------------------------------
local function HideBlzNameplates(self, cvar)
    if not strfind(strlower(cvar), "nameplate") then return end
    C_Timer.After(0.25, function()
        for blz, np in pairs(NP.created) do
            if blz.UnitFrame then
                blz.UnitFrame:Hide()
            end
        end
    end)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateNameplates(module, which)
    if module and module ~= "Nameplates" then return end
    -- if which and which ~= "focus" then return end

    local config = NP.config

    if not config.enabled then
        NP:UnregisterAllEvents()
        return
    end

    NP:RegisterEvent("NAME_PLATE_CREATED", CreateNameplate)
    NP:RegisterEvent("NAME_PLATE_UNIT_ADDED", ShowNameplate)
    NP:RegisterEvent("NAME_PLATE_UNIT_REMOVED", HideNameplate)
    NP:RegisterEvent("UI_SCALE_CHANGED", HideBlzNameplates)
    NP:RegisterEvent("CVAR_UPDATE", HideBlzNameplates)

    -- cvar
    UpdateCVars()

    -- update clickable area size
    SetNamePlateFriendlySize(config.friendly.clickableAreaWidth, config.friendly.clickableAreaHeight)
    SetNamePlateEnemySize(config.hostile.clickableAreaWidth, config.hostile.clickableAreaHeight)

    -- alphas
    alphas = NP.config.alphas
    occluded_alpha = 0.6 * alphas.occluded.value
    wipe(alpha_funcs)
    for _, k in pairs(alpha_order) do
        if alphas[k].enabled then
            tinsert(alpha_funcs, alpha_funcs_default[k])
        end
    end
    if alphas.target.enabled and alphas.non_target.enabled then
        alpha_target_func = alpha_funcs_default.target_non_target
    elseif alphas.target.enabled then
        alpha_target_func = alpha_funcs_default.target
    elseif alphas.non_target.enabled then
        alpha_target_func = alpha_funcs_default.non_target
    else
        alpha_target_func = nil
    end
    if alphas.no_target.enabled then
        alpha_no_target_func = alpha_funcs_default.no_target
    else
        alpha_no_target_func = nil
    end

    -- scales

    -- indicators
    NP.EnableQuestIndicator(config.hostile.questIndicator.enabled, config.hostile.questIndicator.hideInInstance)
end
BFI.RegisterCallback("UpdateModules", "Nameplates", UpdateNameplates)