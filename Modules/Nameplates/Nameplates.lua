---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.M_NP

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
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitName = UnitName

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

local function GetUnitReaction(unit)
    local reaction = UnitReaction(unit, "player")
    if reaction == 4 then
        return "neutral"
    elseif reaction < 4 then
        return "hostile"
    else
        return "friendly"
    end
end

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

local function GetUnitClassification(unit)
    local classification = UnitClassification(unit)
    if strfind(classification, "^rare") then
        return "rare"
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
end

local function UpdateCVars()
    SetCVar("nameplateOccludedAlphaMult", NP.config.occludedAlpha)
    SetCVar("NamePlateHorizontalScale", 1.0)
    SetCVar("NamePlateVerticalScale", 1.0)
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
    BFI.Debug("|cffffff00UpdateNameplateBase:|r", np:GetName())

    wipe(np.states)

    local unit = np.unit

    np.states.name, np.states.server = UnitName(unit)
    np.states.server = np.states.server or SERVER_NAME
    np.states.level = UnitEffectiveLevel(unit)
    np.states.reaction = GetUnitReaction(unit)
    np.states.type = GetUnitType(unit)
    np.states.classification = GetUnitClassification(unit)

    np.states.isHostile = np.states.reaction ~= "friendly"
    np.states.isBoss = np.states.level == -1
    np.states.isSameServer = np.states.server == SERVER_NAME
end

---------------------------------------------------------------------
-- OnNameplateShow
---------------------------------------------------------------------
local function OnNameplateShow(np)
    UpdateNameplateBase(np)
    NP.OnNameplateShow(np)

    if np.previous ~= np.states.reaction then
        NP.SetupIndicators(np, NP.config[np.states.isHostile and "hostile" or "friendly"])
    end
    np.previous = np.states.reaction
end

---------------------------------------------------------------------
-- OnNameplateUpdate
---------------------------------------------------------------------
local function OnNameplateUpdate(np, elapsed)
    np.elapsed = (np.elapsed or 0) + elapsed
    if np.elapsed >= 0.25 then
        -- check occluded
        if np.blz:GetAlpha() <= 0.4 then
            np:SetAlpha(NP.config.occludedAlpha)
        else
            np:SetAlpha(1)
        end

        -- check unit
        if np.unit then
            local guid = UnitGUID(np.unit)
            if guid ~= np.guid then
                np.guid = guid
                BFI.Debug("|cffff7700NameplateUnitChanged:|r", np:GetName())
                UpdateNameplateBase(np)
            end
        end
    end
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
local function ShowNameplate(self, event, unit)
    local np, blz = NP.GetNameplateForUnit(unit)
    if not np then return end

    BFI.Debug("|cff00ff00ShowNameplate:|r", np:GetName())

    if blz.UnitFrame then
        if UnitIsUnit("player", unit) then
            blz.UnitFrame:Show()
            np.unit = nil
            np:Hide()
        else
            blz.UnitFrame:Hide()
            np.unit = blz.namePlateUnitToken
            np.guid = UnitGUID(np.unit)
            np:Show()
        end
    else
        np.unit = nil
        np:Show()
    end

    -- TODO: filters
end

---------------------------------------------------------------------
-- hide
---------------------------------------------------------------------
local function HideNameplate(self, event, unit)
    local np = NP.GetNameplateForUnit(unit)
    if not np then return end

    BFI.Debug("|cff229922HideNameplate:|r", np:GetName())

    np:Hide()
    wipe(np.states)
    np.unit = nil
    np.guid = nil

    NP.OnNameplateHide(np)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
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
    np.clickableArea:SetShown(NP.showClickableArea or true)
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

    -- cvar
    UpdateCVars()

    -- update parent size
    SetNamePlateFriendlySize(config.friendly.width + config.friendly.insetX, config.friendly.height + config.friendly.insetY)
    SetNamePlateEnemySize(config.hostile.width + config.hostile.insetX, config.hostile.height + config.hostile.insetY)
end
BFI.RegisterCallback("UpdateModules", "Nameplates", UpdateNameplates)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitNameplates()
--     UpdateNameplates()

--     NP:RegisterEvent("NAME_PLATE_CREATED", CreateNameplate)
--     NP:RegisterEvent("NAME_PLATE_UNIT_ADDED", ShowNameplate)
-- end
-- BFI.RegisterCallback("InitModules", "Nameplates", InitNameplates)