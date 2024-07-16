local addonName, BFI = ...
local AW = BFI.AW

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

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