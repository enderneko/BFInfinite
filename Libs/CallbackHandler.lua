---------------------------------------------------------------------
-- File: CallbackHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-04 17:24 +08:00
-- Modified: 2024-06-02 19:23 +08:00
---------------------------------------------------------------------

local _, addon = ...

local callbacks = {
    -- invoke orders
    {}, -- 1
    {}, -- 2
    {}, -- 3
}

function addon.RegisterCallback(eventName, onEventFuncName, onEventFunc, order)
    local t = order and callbacks[order] or callbacks[2]
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