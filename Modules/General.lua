---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- update config
---------------------------------------------------------------------
local function UpdateConfig()
    local config = BFIConfig

    -- GameMenuFrame scale
    local GameMenuFrame = _G.GameMenuFrame
    if not GameMenuFrame._BFIHooked then
        GameMenuFrame._BFIHooked = true
        hooksecurefunc(GameMenuFrame, "SetScale", function(self, scale)
            if scale ~= config.gameMenuScale then
                self:SetScale(config.gameMenuScale)
            end
            AF.DefaultUpdatePixels(GameMenuFrame.BFIBackdrop)
        end)
    end
    GameMenuFrame:SetScale(config.gameMenuScale)
end
AF.RegisterCallback("BFI_UpdateConfig", UpdateConfig)