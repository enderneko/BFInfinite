---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local U = BFI.utils
local NP = BFI.NamePlates
local DB = BFI.DisableBlizzard

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
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsEnemy = UnitIsEnemy
local UnitIsGameObject = UnitIsGameObject
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
-- local UnitIsSameServer = UnitIsSameServer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitReaction = UnitReaction

function NP.GetNameplateForUnit(unit)
    local nameplate = GetNamePlateForUnit(unit)
    if nameplate then
        return nameplate.bfi, nameplate.UnitFrame
    end
end

function NP.ToggleClickableArea()
    NP.showClickableArea = not NP.showClickableArea
    for _, np in pairs(NP.created) do
        np.clickableArea:SetShown(NP.showClickableArea)
    end
end

function NP.IterateAllVisibleNamePlates(func, type)
    for _, np in pairs(NP.created) do
        if not type or type == np.type then
            if np:IsVisible() then
                func(np)
            end
        end
    end
end

-- local function GetUnitReaction(unit)
--     local reaction = UnitReaction("player", unit)
--     -- if reaction == 4 then
--     --     return "neutral"
--     if reaction > 4 then
--         return "friendly"
--     else
--         return "hostile"
--     end
-- end

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
-- reset cvar to game default
---------------------------------------------------------------------
local function ResetCVar(cvar)
    SetCVar(cvar, GetCVarDefault(cvar))
end

function NP.ResetCVars()
    ResetCVar("nameplateOccludedAlphaMult")
    -- nameOnly
    ResetCVar("nameplateShowOnlyNames")
    -- scale
    ResetCVar("nameplateGlobalScale")
    ResetCVar("nameplateLargerScale")
    ResetCVar("NamePlateHorizontalScale")
    ResetCVar("NamePlateVerticalScale")
    ResetCVar("nameplateMaxScale")
    ResetCVar("nameplateMinScale")
    ResetCVar("nameplateSelectedScale")
    -- overlap
    ResetCVar("nameplateOverlapH")
    ResetCVar("nameplateOverlapV")
    -- motion
    ResetCVar("nameplateMotion")
    ResetCVar("nameplateMotionSpeed")
    -- distance
    ResetCVar("nameplateMaxDistance")
    ResetCVar("nameplateTargetBehindMaxDistance")
    -- inset
    ResetCVar("nameplateTargetRadialPosition")
    ResetCVar("nameplateLargeTopInset")
    ResetCVar("nameplateLargeBottomInset")
    ResetCVar("nameplateOtherTopInset")
    ResetCVar("nameplateOtherBottomInset")
end

---------------------------------------------------------------------
-- reset cvar to BFI default
---------------------------------------------------------------------
function NP.ResetCVarDefaults()
    -- TODO:
end

---------------------------------------------------------------------
-- UpdateCVars
---------------------------------------------------------------------
local function UpdateCVars(config)
    if config.alphas.occluded.enabled then
        SetCVar("nameplateOccludedAlphaMult", NP.config.alphas.occluded.value)
    end

    for cvar, value in pairs(config.cvars) do
        SetCVar(cvar, value)
    end
end

---------------------------------------------------------------------
-- UpdateNameplateBase
---------------------------------------------------------------------
local function UpdateNameplateBase(np)
    -- BFI.Debug("|cffffff00UpdateNameplateBase:|r", np:GetName())

    local unit = np.unit

    np.states.reaction = UnitReaction("player", unit)
    np.states.name, np.states.server = UnitName(unit)
    np.states.server = np.states.server or SERVER_NAME
    np.states.level = UnitEffectiveLevel(unit)
    np.states.type = GetUnitType(unit)
    np.states.classification = GetUnitClassification(unit, np.states.level)
    -- np.states.isSameServer = UnitIsSameServer(unit)
    np.states.isPVPSanctuary = UnitIsPVPSanctuary(unit)
    np.states.isEnemy = UnitIsEnemy("player", unit)
    np.states.isPlayer = UnitIsPlayer(unit)
    np.states.canAttack = UnitCanAttack("player", unit)

    if np.states.isPVPSanctuary then
        np.type = "friendly_player"
    elseif not np.states.isEnemy and (np.states.reaction and (np.states.reaction > 4 or np.states.reaction == 4 and not np.states.canAttack)) then
        np.type = np.states.isPlayer and "friendly_player" or "friendly_npc"
    else
        np.type = np.states.isPlayer and "hostile_player" or "hostile_npc"
    end
end

---------------------------------------------------------------------
-- alphas
---------------------------------------------------------------------
local alphas
local alpha_order = {
    "occluded",
    "focus",
    "target",
    "marked",
    "casting",
    "mouseover",
    "non_target",
    "no_target",
}

local alpha_funcs = {}
local occluded_alpha

local alpha_funcs_default = {
    occluded = function(np)
        if np.parent:GetAlpha() <= occluded_alpha then
            return alphas.occluded.value
        end
    end,
    focus = function(np)
        if np.states.isFocus then
            return alphas.focus.value
        end
    end,
    target = function(np)
        if np.states.isTarget then
            return alphas.target.value
        end
    end,
    marked = function(np)
        if np.states.isMarked then
            return alphas.marked.value
        end
    end,
    casting = function(np)
        if np.states.isCasting then
            return alphas.casting.value
        end
    end,
    mouseover = function(np)
        if np.states.isMouseOver then
            return alphas.mouseover.value
        end
    end,
    non_target = function(np)
        if NP.targetExists and not np.states.isTarget then
            return alphas.non_target.value
        end
    end,
    no_target = function()
        if not NP.targetExists then
            return alphas.no_target.value
        end
    end,
}

local function GetAlpha(np)
    local alpha

    -- base alpha
    for _, f in ipairs(alpha_funcs) do
        alpha = f(np)
        if alpha then
            break
        end
    end

    alpha = alpha or 1

    -- type & classification (multiplier)
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

---------------------------------------------------------------------
-- scales
---------------------------------------------------------------------
local scales
local scale_order = {
    "focus",
    "target",
    "marked",
    "casting",
    "mouseover",
    "non_target",
    "no_target",
}

local scale_funcs = {}

local scale_funcs_default = {
    focus = function(np)
        if np.states.isFocus then
            return scales.focus.value
        end
    end,
    target = function(np)
        if np.states.isTarget then
            return scales.target.value
        end
    end,
    marked = function(np)
        if np.states.isMarked then
            return scales.marked.value
        end
    end,
    casting = function(np)
        if np.states.isCasting then
            return scales.casting.value
        end
    end,
    mouseover = function(np)
        if np.states.isMouseOver then
            return scales.mouseover.value
        end
    end,
    non_target = function(np)
        if NP.targetExists and not np.states.isTarget then
            return scales.non_target.value
        end
    end,
    no_target = function()
        if not NP.targetExists then
            return scales.no_target.value
        end
    end,
}

local function GetScale(np)
    local scale

    -- return directly
    for _, f in ipairs(scale_funcs) do
        scale = f(np)
        if scale then
            break
        end
    end

    scale = scale or 1

    -- type & classification
    if np.states.type == "npc" then
        if np.states.classification == "normal" then
            scale = NP.config.scales.npc * scale
        else
            scale = NP.config.scales[np.states.classification] * scale
        end
    else
        scale = NP.config.scales[np.states.type] * scale
    end

    return scale
end

---------------------------------------------------------------------
-- UpdateTarget
---------------------------------------------------------------------
local function UpdateTarget()
    NP.targetExists = UnitExists("target")
end

---------------------------------------------------------------------
-- OnNameplateUpdate -- REVIEW: use event to mark "updateRequired"?
---------------------------------------------------------------------
local function OnNameplateUpdate(np, elapsed)
    np.elapsed = (np.elapsed or 0) + elapsed
    if np.elapsed >= 0.25 then
        --! frame level
        np:SetFrameLevel(np.parent:GetFrameLevel() * 10)

        if np.unit then
            np.states.isFocus = UnitIsUnit("focus", np.unit)
            np.states.isTarget = UnitIsUnit("target", np.unit)
            np.states.isMarked = (GetRaidTargetIndex(np.unit) or 9) <= 8
            np.states.isCasting = UnitCastingInfo(np.unit) or UnitChannelInfo(np.unit)
            np.states.isMouseOver = UnitIsUnit("mouseover", np.unit)

            -- alpha
            np:SetAlpha(GetAlpha(np))

            -- scale
            if scales.animatedScaling then
                AW.FrameZoomTo(np, 0.1, GetScale(np))
            else
                np:SetScale(GetScale(np))
            end
        else
            np:SetAlpha(1)
            np:SetScale(1)
        end
    end
end

---------------------------------------------------------------------
-- blizzard widget container
---------------------------------------------------------------------
local function UpdateWidgetContainer(np, reset)
    if reset then
        if np.widgetContainer then
            np.widgetContainer:SetParent(np.bUnitFrame)
            -- np.widgetContainer:ClearAllPoints()
            -- np.widgetContainer:SetPoint("TOP", np.bUnitFrame.castBar, "BOTTOM")
        end
    else
        np.widgetContainer = np.bUnitFrame and np.bUnitFrame.WidgetContainer
        if np.widgetContainer then
            np.widgetContainer:SetParent(np)
            -- FIXME:
            -- np.widgetContainer:ClearAllPoints()
            -- np.widgetContainer:SetPoint("CENTER", 0, -10)
        end
    end
end

---------------------------------------------------------------------
-- show / hide
---------------------------------------------------------------------
local function Show(np)
    np.unit = np.bUnitFrame.displayedUnit
    np.elapsed = 0.25 -- update now
    np.guid = UnitGUID(np.unit)
    np.widgetsOnly = UnitNameplateShowsWidgetsOnly(np.unit)
    np.isGameObject = UnitIsGameObject(np.unit)

    UpdateWidgetContainer(np)
    UpdateNameplateBase(np)

    -- if guid ~= np.guid then
    --     np.guid = guid
    --     -- BFI.Debug("|cffff7700NP.UnitChanged:|r", np:GetName())
    --     UpdateNameplateBase(np)
    -- end

    -- load indicator config
    if np.previousType ~= np.type then
        -- BFI.Debug("|cffffff00NP.UnitTypeChanged:|r", np:GetName(), np.previousType, "->", np.type)
        np.previousType = np.type
        NP.SetupIndicators(np, NP.config[np.type])
    end

    -- show
    np:Show()

    -- update indicators
    if np.widgetsOnly or np.isGameObject then
        NP.DisableIndicators(np)
    else
        NP.OnNameplateShow(np)
    end
end

local function Hide(np)
    UpdateWidgetContainer(np, true)
    np:Hide()
    wipe(np.states)
    U.RemoveElementsByKeys(np,
        "unit", "guid", "elapsed",
        "widgetsOnly", "isGameObject"
    )

    -- update indicators
    NP.OnNameplateHide(np)
end

---------------------------------------------------------------------
-- NAME_PLATE_UNIT_ADDED
---------------------------------------------------------------------
local function ShowNameplate(_, event, unit)
    local np, bUnitFrame = NP.GetNameplateForUnit(unit)
    if not np then return end

    -- BFI.Debug("|cff00ff00ShowNameplate:|r", np:GetName())

    np.bUnitFrame = bUnitFrame

    if bUnitFrame then
        -- TODO: self nameplate
        -- if UnitIsUnit("player", unit) then
        --     bUnitFrame:Show()
        --     Hide(np)
        -- else
            bUnitFrame:Hide()
            Show(np)
        -- end
    end

    -- TODO: filters
end

---------------------------------------------------------------------
-- NAME_PLATE_UNIT_REMOVED
---------------------------------------------------------------------
local function HideNameplate(_, event, unit)
    local np = NP.GetNameplateForUnit(unit)
    if not np then return end

    -- BFI.Debug("|cff229922HideNameplate:|r", np:GetName())
    Hide(np)
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
    local np = CreateFrame("Frame", "BFI_" .. nameplate:GetName(), AW.UIParent)
    np:Hide()
    np:SetFrameStrata("BACKGROUND")
    np:SetAllPoints(nameplate)

    np.parent = nameplate
    nameplate.bfi = np
    NP.created[nameplate] = np

    -- BFI.Debug("|cffff7777CreateNameplate:|r", np:GetName())

    np.states = {}
    np.indicators = {}
    -- texplore(np.states)
    NP.CreateIndicators(np)

    -- script
    np:SetScript("OnUpdate", OnNameplateUpdate)

    -- clickable area
    np.clickableArea = np:CreateTexture(nil, "BACKGROUND", nil, -7)
    np.clickableArea:SetAllPoints()
    np.clickableArea:SetColorTexture(0, 1, 0, 0.15)
    np.clickableArea:SetShown(NP.showClickableArea)

    -- pixel perfect
    AW.AddToPixelUpdater(np, UpdatePixels)
end

---------------------------------------------------------------------
-- NamePlateDriverFrame.AcquireUnitFrame
---------------------------------------------------------------------
local function InsecureHide(self)
    self:Hide()
end

local hookedNameplates = {}

local function NamePlateDriverFrame_AcquireUnitFrame(_, nameplate)
    if not (nameplate and nameplate.UnitFrame) then return end
    if nameplate.UnitFrame:IsForbidden() then return end

    if not hookedNameplates[nameplate] then
        hookedNameplates[nameplate] = true
        nameplate.UnitFrame:HookScript("OnShow", InsecureHide)
    end

    DB.DisableFrame(nameplate.UnitFrame, true)
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
    NP:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget)
    NP:RegisterEvent("UNIT_FACTION", ShowNameplate)

    if not NP.isAcquireUnitFrameHooked then
        NP.isAcquireUnitFrameHooked = true
        hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", NamePlateDriverFrame_AcquireUnitFrame)
    end

    -- cvar
    if not which or which == "cvar" then
        UpdateCVars(config)
    end

    -- update clickable area size
    SetNamePlateFriendlySize(config.friendlyClickableAreaWidth, config.friendlyClickableAreaHeight)
    SetNamePlateEnemySize(config.hostileClickableAreaWidth, config.hostileClickableAreaHeight)

    -- alphas
    alphas = NP.config.alphas
    -- occluded_alpha = 0.6 * alphas.occluded.value
    occluded_alpha = alphas.occluded.value + 0.05
    wipe(alpha_funcs)
    for _, k in pairs(alpha_order) do
        if alphas[k].enabled then
            tinsert(alpha_funcs, alpha_funcs_default[k])
        end
    end

    -- scales
    scales = NP.config.scales
    wipe(scale_funcs)
    for _, k in pairs(scale_order) do
        if scales[k].enabled then
            tinsert(scale_funcs, scale_funcs_default[k])
        end
    end

    -- indicators
    NP.EnableQuestIndicator(config.hostile_npc.questIndicator.enabled, config.hostile_npc.questIndicator.hideInInstance)
end
BFI.RegisterCallback("UpdateModules", "Nameplates", UpdateNameplates)