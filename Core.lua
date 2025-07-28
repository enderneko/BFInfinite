---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

local eventHandler = AF.CreateSimpleEventHandler("ADDON_LOADED")

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
            SetCVar("cameraDistanceMaxZoomFactor", 2.6)
            SetCVar("CameraReduceUnexpectedMovement", 1)
            SetCVar("ResampleAlwaysSharpen", 1)
            SetCVar("ActionButtonUseKeyDown", 1)
            SetCVar("chatMouseScroll", 1)
            SetCVar("threatWarning", 0)
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

        if type(BFIProfile) ~= "table" then BFIProfile = {} end

        -- default profile
        if type(BFIProfile.default) ~= "table" then
            BFIProfile.default = {}
        end

        -- profile
        AF.Fire("BFI_UpdateProfile", BFIProfile.default, "default")

        -- TODO:
        BFI.vars.profileName = "default"
        BFI.vars.profile = BFIProfile.default
    end
end

function eventHandler:UI_SCALE_CHANGED()
    local res = ("%dx%d"):format(GetPhysicalScreenSize())
    if res == BFI.vars.resolution then return end
    BFI.vars.resolution = res

    if type(BFIConfig.scale[res]) ~= "number" then
        BFIConfig.scale[res] = AF.RoundToDecimal(UIParent:GetScale(), 2)
    else
        if InCombatLockdown() then
            eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            AF.SetUIParentScale(BFIConfig.scale[res])
        end
    end
end

function eventHandler:PLAYER_REGEN_ENABLED()
    eventHandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
    AF.SetUIParentScale(BFIConfig.scale[BFI.vars.resolution])
end

AF.RegisterCallback("AF_PLAYER_DATA_UPDATE", function(_, isLogin)
    AF.UnregisterCallback("AF_PLAYER_DATA_UPDATE", "BFI_Init")

    if isLogin then
        eventHandler:RegisterEvent("UI_SCALE_CHANGED")

        local res = ("%dx%d"):format(GetPhysicalScreenSize())
        BFI.vars.resolution = res

        -- ui scale
        if type(BFIConfig.scale[res]) ~= "number" then
            BFIConfig.scale[res] = AF.RoundToDecimal(UIParent:GetScale(), 2)
        else
            AF.SetUIParentScale(BFIConfig.scale[res], true)
        end

        -- game menu scale
        if type(BFIConfig.gameMenuScale) ~= "number" then
            BFIConfig.gameMenuScale = 0.8
        end
    end

    -- disable blizzard frames
    AF.Fire("BFI_DisableBlizzard")
    -- restyle blizzard frames
    AF.Fire("BFI_StyleBlizzard")
    -- update general config
    AF.Fire("BFI_UpdateConfig")
    -- update modules
    AF.Fire("BFI_UpdateModule")

end, "high", "BFI_Init")