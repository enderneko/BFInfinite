---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class DataBars
local DB = BFI.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local threatFrame

local function UpdatePixels()
    AF.RePoint(threatFrame)
    AF.ReSize(threatFrame)
end

local function CreateThreatFrame()
    threatFrame = CreateFrame("Frame")
    AF.AddToPixelUpdater_Auto(threatFrame, UpdatePixels)
    AF.CreateMover(threatFrame, "BFI: " .. L["Data Bars"], L["Threats"])
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateThreats(_, module, which)
    if module and module ~= "DataBars" then return end
    if which and which ~= "threats" then return end

    local config = DB.config.threats
    if not config.enabled then
        if threatFrame then
            threatFrame.enabled = false
            threatFrame:UnregisterAllEvents()
            threatFrame:Hide()
        end
        return
    end

    if not threatFrame then
        CreateThreatFrame()
    end
    threatFrame.enabled = true

    AF.UpdateMoverSave(threatFrame, config.position)
    AF.LoadPosition(threatFrame, config.position)
    AF.SetSize(threatFrame, config.width, config.height)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateThreats)