---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

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

        if not BFIConfig.cvarInited then
            BFIConfig.cvarInited = true
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

        -- scales
        if type(BFIConfig.scale) ~= "table" then
            BFIConfig.scale = {}
        end

        -- accent color
        if type(BFIConfig.accentColor) ~= "table" then
            BFIConfig.accentColor = {
                type = "default",
                color = AF.GetColorTable("hotpink"),
            }
        end

        if BFIConfig.accentColor.type == "custom" then
            AF.SetAddonAccentColor(BFI.name, BFIConfig.accentColor.color)
        else
            AF.SetAddonAccentColor(BFI.name, "blazing_tangerine")
        end

        -- language
        -- if type(BFIConfig.locale) ~= "string" then
        --     BFIConfig.locale = GetLocale()
        -- end
        -- AF.Fire("BFI_UpdateLocale", BFIConfig.locale)

        -- font
        if type(BFIConfig.font) ~= "table" then
            BFIConfig.font = {
                common = {
                    font = "BFI",
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
        AF.Fire("BFI_UpdateFont")

        --------------------------------------------------
        -- revise
        --------------------------------------------------
        for _, t in next, BFIProfile or {} do
            BFI.funcs.Revise(t)
            -- if AF.IsBlank(t.pAuthor) then t.pAuthor = nil end
            -- if AF.IsBlank(t.pVersion) then t.pVersion = nil end
            -- if AF.IsBlank(t.pURL) then t.pURL = nil end
            -- if AF.IsBlank(t.pDescription) then t.pDescription = nil end
        end

        --------------------------------------------------
        -- profile
        --------------------------------------------------
        if type(BFIProfile) ~= "table" then BFIProfile = {} end

        -- default profile
        if type(BFIProfile.default) ~= "table" then
            BFIProfile.default = {
                version = BFI.version,
                versionNum = BFI.versionNum,
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
    end
end

---------------------------------------------------------------------
-- UI_SCALE_CHANGED
---------------------------------------------------------------------
local uiScaleUpdateRequired
function eventHandler:UI_SCALE_CHANGED()
    local res = ("%dx%d"):format(GetPhysicalScreenSize())
    if res == BFI.vars.resolution then return end
    BFI.vars.resolution = res

    if type(BFIConfig.scale[res]) ~= "number" then
        BFIConfig.scale[res] = AF.GetBestScale() -- AF.RoundToDecimal(UIParent:GetScale(), 2)
    else
        if InCombatLockdown() then
            uiScaleUpdateRequired = true
            eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            AF.SetUIParentScale(BFIConfig.scale[res])
        end
    end
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

local function AF_PLAYER_LOGIN_DELAYED()
    -- ui scale
    eventHandler:RegisterEvent("UI_SCALE_CHANGED")
    local res = ("%dx%d"):format(GetPhysicalScreenSize())
    BFI.vars.resolution = res

    if type(BFIConfig.scale[res]) ~= "number" then
        BFIConfig.scale[res] = AF.GetBestScale() -- AF.RoundToDecimal(UIParent:GetScale(), 2)
    else
        AF.SetUIParentScale(BFIConfig.scale[res], true)
    end

    -- game menu scale
    if type(BFIConfig.gameMenuScale) ~= "number" then
        BFIConfig.gameMenuScale = 0.8
    end

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
        AF.SetUIParentScale(BFIConfig.scale[BFI.vars.resolution])
    end
    if profileLoadRequired then
        profileLoadRequired = nil
        F.LoadProfile()
    end
end