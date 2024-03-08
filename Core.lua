local addonName, BFI = ...

local AW = BFI.AW

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    BFI.Fire("InitModules")
end)