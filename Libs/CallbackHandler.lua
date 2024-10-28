---------------------------------------------------------------------
-- File: CallbackHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-04 17:24 +08:00
-- Modified: 2024-10-25 18:28 +08:00
---------------------------------------------------------------------

---@class BFI
local addon = select(2, ...)

local callbacks = {
    -- invoke priority
    {}, -- 1
    {}, -- 2
    {}, -- 3
}

function addon.RegisterCallback(eventName, onEventFuncName, onEventFunc, priority)
    local t = priority and callbacks[priority] or callbacks[2]
    if not t[eventName] then t[eventName] = {} end
    t[eventName][onEventFuncName] = onEventFunc
end

function addon.UnregisterCallback(eventName, onEventFuncName)
    for _, t in pairs(callbacks) do
        if t[eventName] then
            t[eventName][onEventFuncName] = nil
        end
    end
end

function addon.UnregisterAllCallbacks(eventName)
    for _, t in pairs(callbacks) do
        t[eventName] = nil
    end
end

function addon.Fire(eventName, ...)
    for _, t in pairs(callbacks) do
        if t[eventName] then
            for _, fn in pairs(t[eventName]) do
                fn(...)
            end
        end
    end
end

---------------------------------------------------------------------
-- addon loaded
---------------------------------------------------------------------
local addonCallbacks = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addonCallbacks[addon] then
        for _, fn in pairs(addonCallbacks[addon]) do
            fn(addon)
        end
    end
end)

function addon.RegisterCallbackForAddon(addon, func)
    if not addonCallbacks[addon] then addonCallbacks[addon] = {} end
    tinsert(addonCallbacks[addon], func)
end