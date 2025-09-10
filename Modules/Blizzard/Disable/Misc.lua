
---@class BFI
local BFI = select(2, ...)
local DB = BFI.modules.DisableBlizzard
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function DisableBlizzard()
    --! require ReloadUI to take effect
    if init then return end
    init = true

    local config = DB.config

    -- manager
    if config.manager then
        DB.DisableFrame(_G.CompactRaidFrameManager)
        CompactRaidFrameManager_SetSetting("IsShown", "0")
    end

    -- castBar
    if config.castBar then
        DB.DisableFrame(_G.PlayerCastingBarFrame)
        DB.DisableFrame(_G.PetCastingBarFrame)
    end

    -- auras
    if config.auras then
        DB.DisableFrame(_G.BuffFrame)
        _G.BuffFrame.numHideableBuffs = 0
        DB.DisableFrame(_G.DebuffFrame)
    end
end
AF.RegisterCallback("BFI_DisableBlizzard", DisableBlizzard)