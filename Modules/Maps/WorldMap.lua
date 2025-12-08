---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local M = BFI.modules.Maps
---@type AbstractFramework
local AF = _G.AbstractFramework

local WorldMapFrame = _G.WorldMapFrame
local PlayerMovementFrameFader = PlayerMovementFrameFader

local function MapFadePredicate()
    return GetCVarBool("mapFade") and not WorldMapFrame:IsMouseOver()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateWorldMap(_, module, which)
    if module and module ~= "maps" then return end
    if which and which ~= "worldMap" then return end

    local config = M.config.worldMap

    if not config.general.enabled then return end

    if not init then
        init = true
    end

    -- map fade
    SetCVar("mapFade", config.general.mapFade)
    -- original: PlayerMovementFrameFader.AddDeferredFrame(self, .5, 1.0, .5, function() return GetCVarBool("mapFade") and not self:IsMouseOver() end)
    PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, config.general.mapFadeAlpha, 1.0, 0.25, MapFadePredicate)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateWorldMap)