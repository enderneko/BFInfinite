---------------------------------------------------------------------
-- File: CallbackHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-04 17:24 +08:00
-- Modified: 2024-05-27 12:32 +08:00
---------------------------------------------------------------------

local _, addon = ...

local callbacks = {}

function addon.RegisterCallback(eventName, onEventFuncName, onEventFunc)
    if not callbacks[eventName] then callbacks[eventName] = {} end
    callbacks[eventName][onEventFuncName] = onEventFunc
end

function addon.UnregisterCallback(eventName, onEventFuncName)
    if not callbacks[eventName] then return end
    callbacks[eventName][onEventFuncName] = nil
end

function addon.UnregisterAllCallbacks(eventName)
    if not callbacks[eventName] then return end
    callbacks[eventName] = nil
end

function addon.Fire(eventName, ...)
    if not callbacks[eventName] then return end

    for onEventFuncName, onEventFunc in pairs(callbacks[eventName]) do
        onEventFunc(...)
    end
end