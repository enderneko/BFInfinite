---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class UIWidgets
local UI = BFI.modules.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local buffTimerHolder
local UpdateTimers

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitBuffTimerHolder()
    buffTimerHolder = CreateFrame("Frame", "BFI_BuffTimerHolder", AF.UIParent)
    AF.CreateMover(buffTimerHolder, "BFI: " .. L["UI Widgets"], L["Special Power Timer"])
    AF.SetSize(buffTimerHolder, 256, 64)
    hooksecurefunc("PlayerBuffTimerManager_UpdateTimers", UpdateTimers)
end

---------------------------------------------------------------------
-- update timers
---------------------------------------------------------------------
UpdateTimers = function(self)
    if _G.BuffTimer1 then
        _G.BuffTimer1:ClearAllPoints()
        _G.BuffTimer1:SetPoint("BOTTOM", buffTimerHolder)

        local scale = UI.config.buffTimer.scale
        local index = 1
        local timer = _G["BuffTimer" .. index]
        while timer do
            timer:SetScale(scale)
            index = index + 1
            timer = _G["BuffTimer" .. index]
        end
    end
end

---------------------------------------------------------------------
-- update config
---------------------------------------------------------------------
local function UpdateConfig(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "bufftimer" then return end

    local config = UI.config.buffTimer

    if not buffTimerHolder then
        InitBuffTimerHolder()
    end

    buffTimerHolder:SetScale(config.scale)
    AF.ClearPoints(buffTimerHolder)
    AF.LoadPosition(buffTimerHolder, config.position)
    AF.UpdateMoverSave(buffTimerHolder, config.position)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateConfig)