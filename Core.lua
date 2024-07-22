local addonName, BFI = ...
local AW = BFI.AW

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

function eventFrame:ADDON_LOADED(arg)
    if arg == addonName then
        eventFrame:UnregisterEvent("ADDON_LOADED")

        if type(BFIConfig) ~= "table" then BFIConfig = {} end

        if type(BFIConfig["default"]) ~= "table" then
            BFIConfig["default"] = {}
        end

        -- init configs
        BFI.Fire("UpdateConfigs", BFIConfig["default"], "default")

        -- TODO:
        BFI.vars.currentConfig = "default"
        BFI.vars.currentConfigTable = BFIConfig["default"]
    end
end

function eventFrame:PLAYER_LOGIN()
    BFI.Fire("UpdateModules")
end

local inInstance
local IsInInstance = IsInInstance
-- local GetInstanceInfo = GetInstanceInfo
function eventFrame:PLAYER_ENTERING_WORLD()
    local isIn, iType = IsInInstance()
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