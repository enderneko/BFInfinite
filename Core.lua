---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local GetCVar = GetCVar
local SetCVar = SetCVar
local GetPhysicalScreenSize = GetPhysicalScreenSize
local InCombatLockdown = InCombatLockdown
local GetNumSpecializationsForClassID = C_SpecializationInfo.GetNumSpecializationsForClassID
local eventHandler = AF.CreateSimpleEventHandler("ADDON_LOADED")

---------------------------------------------------------------------
-- ADDON_LOADED
---------------------------------------------------------------------
function eventHandler:ADDON_LOADED(arg)
    if arg == BFI.name then
        eventHandler:UnregisterEvent("ADDON_LOADED")

        BFI.version, BFI.versionNum = AF.GetAddOnVersion(BFI.name)

        if type(BFIConfig) ~= "table" then BFIConfig = {} end

        --------------------------------------------------
        -- general
        --------------------------------------------------
        if type(BFIConfig.general) ~= "table" then
            BFIConfig.general = {}
        end

        -- general.gameMenuScale
        if type(BFIConfig.general.gameMenuScale) ~= "number" then
            BFIConfig.general.gameMenuScale = 0.8
        end

        -- general.scale
        if type(BFIConfig.general.scale) ~= "table" then
            BFIConfig.general.scale = {}
        end

        -- accent color
        if type(BFIConfig.general.accentColor) ~= "table" then
            BFIConfig.general.accentColor = {
                type = "default",
                color = AF.GetColorTable("hotpink"),
            }
        end

        if BFIConfig.general.accentColor.type == "custom" then
            AF.SetAddonAccentColor(BFI.name, BFIConfig.general.accentColor.color)
        else
            AF.SetAddonAccentColor(BFI.name, "blazing_tangerine")
        end

        -- general.language
        -- if type(BFIConfig.general.locale) ~= "string" then
        --     BFIConfig.general.locale = GetLocale()
        -- end
        -- AF.Fire("BFI_UpdateLocale", BFIConfig.general.locale)

        -- general.font
        if type(BFIConfig.general.font) ~= "table" then
            BFIConfig.general.font = {
                common = {
                    font = "BFI Default",
                    overrideAF = false,
                    overrideBlizzard = false,
                    blizzardFontSizeDelta = 0,
                },
                combatText = {
                    override = false,
                    font = "BFI Combat",
                },
                nameText = {
                    override = false,
                    font = "BFI",
                },
            }
        end
        AF.Libs.LSM:Register("font", "BFI", AF.Libs.LSM:Fetch("font", BFIConfig.general.font.common.font), 255)
        AF.Fire("BFI_UpdateFont")

        --------------------------------------------------
        -- profile
        --------------------------------------------------
        if type(BFIProfile) ~= "table" then BFIProfile = {} end

        -- default profile
        if type(BFIProfile.default) ~= "table" then
            BFIProfile.default = {
                revision = BFI.versionNum,
                -- pAuthor = (string),
                -- pVersion = (string),
                -- pURL = (string),
                -- pDescription = (string),
            }
        end

        -- profile assignment
        if type(BFIConfig.profileAssignment) ~= "table" then
            BFIConfig.profileAssignment = {
                role = {
                    TANK = "default",
                    HEALER = "default",
                    DAMAGER = "default",
                },
                spec = {},
                character = {},
            }
        end

        F.CheckProfileAssignments()

        --------------------------------------------------
        -- revise
        --------------------------------------------------
        F.ReviseCommon()

        for _, t in next, BFIProfile or {} do
            F.ReviseProfile(t)
            -- if AF.IsBlank(t.pAuthor) then t.pAuthor = nil end
            -- if AF.IsBlank(t.pVersion) then t.pVersion = nil end
            -- if AF.IsBlank(t.pURL) then t.pURL = nil end
            -- if AF.IsBlank(t.pDescription) then t.pDescription = nil end
        end
    end
end

---------------------------------------------------------------------
-- UI_SCALE_CHANGED
---------------------------------------------------------------------
local uiScaleUpdateRequired

local function UpdateUIParentScale(skipPixelsUpdate)
    local res = ("%dx%d"):format(GetPhysicalScreenSize())
    if res == BFI.vars.resolution then return end
    BFI.vars.resolution = res

    if type(BFIConfig.general.scale[res]) ~= "number" then
        BFIConfig.general.scale[res] = AF.GetBestScale() -- AF.RoundToDecimal(UIParent:GetScale(), 2)
    end

    if InCombatLockdown() then
        uiScaleUpdateRequired = true
        eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        AF.SetUIParentScale(BFIConfig.general.scale[res], skipPixelsUpdate)
    end
end

function eventHandler:UI_SCALE_CHANGED()
    AF.DelayedInvoke(0.5, UpdateUIParentScale)
end

---------------------------------------------------------------------
-- profile
---------------------------------------------------------------------
local lastProfile
local function PreloadProfile()
    if BFIConfig.profileAssignment.character[AF.player.fullName] then
        BFI.vars.profileName = BFIConfig.profileAssignment.character[AF.player.fullName]
        BFI.vars.profileTypeName = "character"
        BFI.vars.profileTypeValue = AF.player.fullName
    elseif BFIConfig.profileAssignment.spec[AF.player.specID] then
        BFI.vars.profileName = BFIConfig.profileAssignment.spec[AF.player.specID]
        BFI.vars.profileTypeName = "spec"
        BFI.vars.profileTypeValue = AF.player.specID
    else
        BFI.vars.profileName = BFIConfig.profileAssignment.role[AF.player.specRole]
        BFI.vars.profileTypeName = "role"
        BFI.vars.profileTypeValue = AF.player.specRole
    end

    BFI.vars.profileName = BFI.vars.profileName or "default"
    BFI.vars.profile = BFIProfile[BFI.vars.profileName]

    if not BFI.vars.profile then
        BFI.vars.profile = BFIProfile.default
        BFI.vars.profileName = "default"
    end

    if lastProfile == BFI.vars.profile then
        AF.Debug("Profile not changed:", BFI.vars.profileName)
        return false
    end

    AF.Fire("BFI_UpdateProfile", BFI.vars.profile, BFI.vars.profileName)

    lastProfile = BFI.vars.profile
    return true
end

local profileLoadRequired
function F.LoadProfile()
    if InCombatLockdown() then
        profileLoadRequired = true
        eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    if PreloadProfile() then
        AF.Fire("BFI_UpdateModule")
    end
end

function F.CheckProfileAssignments()
    for type, t in next, BFIConfig.profileAssignment do
        for k, v in next, t do
            if not BFIProfile[v] then
                if type == "role" then
                    t[k] = "default"
                else
                    t[k] = nil
                end
            end
        end
    end

    if not BFIConfig.profileAssignment.role.TANK then
        BFIConfig.profileAssignment.role.TANK = "default"
    end
    if not BFIConfig.profileAssignment.role.HEALER then
        BFIConfig.profileAssignment.role.HEALER = "default"
    end
    if not BFIConfig.profileAssignment.role.DAMAGER then
        BFIConfig.profileAssignment.role.DAMAGER = "default"
    end
end

local function AF_PLAYER_SPEC_UPDATE(_, specID, lastSpecID)
    if specID and specID == lastSpecID then return end
    F.LoadProfile()
end

---------------------------------------------------------------------
-- cvars
---------------------------------------------------------------------
local function InitAndBackupCVars()
    --------------------------------------------------
    -- backup
    --------------------------------------------------
    -- cvars that BFI has modified or will modify
    local cvars = {
        "fstack_preferParentKeys",
        "screenshotQuality",
        "CameraReduceUnexpectedMovement",
        "ActionButtonUseKeyDown",
        "chatMouseScroll",
        "removeChatDelay",
        "statusText",
        "statusTextDisplay",
        -- action bars
        "autoSelfCast",
        "enableMouseoverCast",
        "assistedCombatHighlight",
        "lockActionBars",
        "AutoPushSpellToActionBar",
        -- nameplates
        "nameplateOccludedAlphaMult",
        "nameplateShowOnlyNames",
        "nameplateGlobalScale",
        "nameplateLargerScale",
        "NamePlateHorizontalScale",
        "NamePlateVerticalScale",
        "NamePlateClassificationScale",
        "nameplateMaxScale",
        "nameplateMinScale",
        "nameplateSelectedScale",
        "nameplateOverlapH",
        "nameplateOverlapV",
        "nameplateMotion",
        "nameplateMotionSpeed",
        "nameplateMaxDistance",
        "nameplateTargetBehindMaxDistance",
        "nameplateTargetRadialPosition",
        "nameplateLargeTopInset",
        "nameplateLargeBottomInset",
        "nameplateOtherTopInset",
        "nameplateOtherBottomInset",
    }

    if type(BFICVarBackup) ~= "table" then BFICVarBackup = {} end
    if type(BFICVarBackup.cvars) ~= "table" then BFICVarBackup.cvars = {} end
    if BFICVarBackup.battleTagMD5 ~= AF.player.battleTagMD5 then
        wipe(BFICVarBackup.cvars)
        BFICVarBackup.battleTagMD5 = AF.player.battleTagMD5
        F.ShowCVarBackupNotice()
    end

    for _, cvar in next, cvars do
        if not BFICVarBackup.cvars[cvar] then
            BFICVarBackup.cvars[cvar] = GetCVar(cvar)
        end
    end

    --------------------------------------------------
    -- init
    --------------------------------------------------
    if BFIConfig.cvarInited ~= AF.player.battleTagMD5 then
        BFIConfig.cvarInited = AF.player.battleTagMD5
        -- init some cvar
        SetCVar("fstack_preferParentKeys", 0)
        SetCVar("screenshotQuality", 10)
        -- SetCVar("cameraDistanceMaxZoomFactor", 2.6)
        SetCVar("CameraReduceUnexpectedMovement", 1)
        -- SetCVar("ResampleAlwaysSharpen", 1)
        SetCVar("ActionButtonUseKeyDown", 1)
        SetCVar("chatMouseScroll", 1)
        SetCVar("removeChatDelay", 1)
        -- SetCVar("threatWarning", 0)
        SetCVar("statusText", 1)
        SetCVar("statusTextDisplay", "NUMERIC") -- NONE,NUMERIC,PERCENT,BOTH
    end
end

local function AF_PLAYER_LOGIN_DELAYED()
    InitAndBackupCVars()

    -- ui scale
    eventHandler:RegisterEvent("UI_SCALE_CHANGED")
    UpdateUIParentScale(true)

    -- profile
    PreloadProfile()
    AF.RegisterCallback("AF_PLAYER_SPEC_UPDATE", AF_PLAYER_SPEC_UPDATE)

    -- disable blizzard frames
    AF.Fire("BFI_DisableBlizzard")
    -- restyle blizzard frames
    AF.Fire("BFI_StyleBlizzard")
    -- update shared configs
    AF.Fire("BFI_UpdateConfig")
    -- update modules
    AF.Fire("BFI_UpdateModule")
end
AF.RegisterCallback("AF_PLAYER_LOGIN_DELAYED", AF_PLAYER_LOGIN_DELAYED, "high")

---------------------------------------------------------------------
-- PLAYER_REGEN_ENABLED
---------------------------------------------------------------------
function eventHandler:PLAYER_REGEN_ENABLED()
    eventHandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if uiScaleUpdateRequired then
        uiScaleUpdateRequired = nil
        AF.SetUIParentScale(BFIConfig.general.scale[BFI.vars.resolution])
    end
    if profileLoadRequired then
        profileLoadRequired = nil
        F.LoadProfile()
    end
end