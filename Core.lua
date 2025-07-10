---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

local eventHandler = AF.CreateSimpleEventHandler("ADDON_LOADED")

function eventHandler:ADDON_LOADED(arg)
    if arg == BFI.name then
        eventHandler:UnregisterEvent("ADDON_LOADED")

        if type(BFIConfig) ~= "table" then
            BFIConfig = {}

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

        if type(BFIConfig["default"]) ~= "table" then
            BFIConfig["default"] = {}
        end

        -- init general
        AF.Fire("BFI_UpdateGeneral", BFIConfig["default"])

        -- init configs
        AF.Fire("BFI_UpdateConfigs", BFIConfig["default"], "default")

        -- TODO:
        BFI.vars.currentConfig = "default"
        BFI.vars.currentConfigTable = BFIConfig["default"]
    end
end

AF.RegisterCallback("AF_PLAYER_DATA_UPDATE", function(_, isLogin)
    AF.UnregisterCallback("AF_PLAYER_DATA_UPDATE", "BFI_Init")
    AF.Fire("BFI_DisableBlizzard")
    AF.Fire("BFI_StyleBlizzard")
    AF.Fire("BFI_UpdateModules")
end, "high", "BFI_Init")