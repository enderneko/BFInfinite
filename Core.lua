---@class BFI
local BFI = select(2, ...)
---@class AbstractFramework
local AF = _G.AbstractFramework
local U = BFI.utils

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

function eventFrame:ADDON_LOADED(arg)
    if arg == BFI.name then
        eventFrame:UnregisterEvent("ADDON_LOADED")

        if type(BFIConfig) ~= "table" then
            BFIConfig = {}

            -- init some cvar
            SetCVar("fstack_preferParentKeys", 0)
            SetCVar("screenshotQuality", 10)
            SetCVar("cameraDistanceMaxZoomFactor", 2.6)
            SetCVar("ActionButtonUseKeyDown", 1)
            SetCVar("chatMouseScroll", 1)
            SetCVar("threatWarning", 0)
            SetCVar("statusText", 1)
            SetCVar("statusTextDisplay", "NUMERIC") -- NONE,NUMERIC,PERCENT,BOTH
        end

        if type(BFIConfig["default"]) ~= "table" then
            BFIConfig["default"] = {}
        end

        -- appearance
        if type(BFIConfig["appearance"]) ~= "table" then
            BFIConfig["appearance"] = {
                ["scale"] = 1,
            }
        end
        AF.SetScale(BFIConfig["appearance"]["scale"])

        -- init configs
        BFI.Fire("UpdateConfigs", BFIConfig["default"], "default")

        -- TODO:
        BFI.vars.currentConfig = "default"
        BFI.vars.currentConfigTable = BFIConfig["default"]
    end
end

function eventFrame:PLAYER_LOGIN()
    BFI.vars.playerNameFull = U.UnitFullName("player")
    BFI.vars.playerNameShort = GetUnitName("player")
    BFI.vars.playerSpecID = GetSpecialization()
    BFI.vars.playerRealm = GetNormalizedRealmName()
    BFI.vars.playerGUID = UnitGUID("player")

    BFI.Fire("PLAYER_LOGIN")
    BFI.Fire("UpdateModules")
    BFI.Fire("DisableBlizzard")
end

local inInstance
local IsInInstance = IsInInstance
-- local GetInstanceInfo = GetInstanceInfo
function eventFrame:UPDATE_INSTANCE_INFO()
    local isIn, iType = IsInInstance()
    BFI.vars.inInstance = isIn
    if isIn then
        inInstance = true
        BFI.Fire("EnterInstance", iType)

        -- NOTE: delayed check mythic raid
        -- if iType == "raid" then
        --     C_Timer.After(0.5, function()
        --         local difficultyID, difficultyName = select(3, GetInstanceInfo()) --! can't get difficultyID, difficultyName immediately after entering an instance
        --         if difficultyID == 16 then -- mythic raid
        --             BFI.Fire("EnterInstance", iType, "mythic")
        --         end
        --     end)
        -- end

    elseif inInstance then -- leave instance
        inInstance = false
        BFI.Fire("LeaveInstance")
    end
end