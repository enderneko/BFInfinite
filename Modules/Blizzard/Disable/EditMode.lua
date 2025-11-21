---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

local GameMenuFrame = _G.GameMenuFrame

---------------------------------------------------------------------
-- edit mode button
---------------------------------------------------------------------
local function GetGameMenuEditModeButton()
    for b in GameMenuFrame.buttonPool:EnumerateActive() do
        if b:GetText() == _G.HUD_EDIT_MODE_MENU then
            return b
        end
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function DisableBlizzard()
    --! require ReloadUI to take effect
    if init then return end
    init = true

    -- disable Edit Mode button during combat
    hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
        local btn = GetGameMenuEditModeButton()
        if btn and InCombatLockdown() then
            btn:Disable()
        end
    end)
end
AF.RegisterCallback("BFI_DisableBlizzard", DisableBlizzard)