---------------------------------------------------------------------
-- File: EventHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-14 11:46 +08:00
-- Modified: 2024-09-06 20:48 +08:00
---------------------------------------------------------------------

local _, addon = ...

local function IsEmpty(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local sharedEventHandler = CreateFrame("Frame", "BFI_EVENT_HANDLER")
local _RegisterEvent = sharedEventHandler.RegisterEvent
local _RegisterUnitEvent = sharedEventHandler.RegisterUnitEvent
local _UnregisterEvent = sharedEventHandler.UnregisterEvent
local _UnregisterAllEvents = sharedEventHandler.UnregisterAllEvents

---------------------------------------------------------------------
-- self
---------------------------------------------------------------------
local function RegisterEvent(self, event, ...)
    if not self.events[event] then self.events[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.events[event][fn] = true
    end

    _RegisterEvent(self, event)
end

local function UnregisterEvent(self, event, ...)
    if not self.events[event] then return end

    if select("#", ...) == 0 then
        self.events[event] = nil
        _UnregisterEvent(self, event)
        return
    end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.events[event][fn] = nil
    end

    -- check if isEmpty
    if IsEmpty(self.events[event]) then
        self.events[event] = nil
        _UnregisterEvent(self, event)
    end
end

local function UnregisterAllEvents(self)
    wipe(self.events)
    _UnregisterAllEvents(self)
end

---------------------------------------------------------------------
-- embeded
---------------------------------------------------------------------
local function RegisterEvent_Embeded(self, event, ...)
    if not self.eventHandler.events[event] then self.eventHandler.events[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.eventHandler.events[event][fn] = true
    end

    _RegisterEvent(self.eventHandler, event)
end

local function RegisterUnitEvent_Embeded(self, event, unit, ...)
    if not self.eventHandler.events[event] then self.eventHandler.events[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.eventHandler.events[event][fn] = true
    end

    _RegisterUnitEvent(self.eventHandler, event, unit)
end

local function UnregisterEvent_Embeded(self, event, ...)
    if not self.eventHandler.events[event] then return end

    if select("#", ...) == 0 then
        self.eventHandler.events[event] = nil
        _UnregisterEvent(self.eventHandler, event)
        return
    end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.eventHandler.events[event][fn] = nil
    end

    -- check if isEmpty
    if IsEmpty(self.eventHandler.events[event]) then
        self.eventHandler.events[event] = nil
        _UnregisterEvent(self.eventHandler, event)
    end
end

local function UnregisterAllEvents_Embeded(self)
    wipe(self.eventHandler.events)
    _UnregisterAllEvents(self.eventHandler)
end

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function RegisterEvent_Shared(self, event, ...)
    if not sharedEventHandler.events[event] then sharedEventHandler.events[event] = {} end
    if not sharedEventHandler.events[event][self] then sharedEventHandler.events[event][self] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        sharedEventHandler.events[event][self][fn] = true
    end

    _RegisterEvent(sharedEventHandler, event)
end

local function UnregisterEvent_Shared(self, event, ...)
    if not (sharedEventHandler.events[event] and sharedEventHandler.events[event][self]) then return end

    local t = sharedEventHandler.events[event][self]

    if select("#", ...) == 0 then
        sharedEventHandler.events[event][self] = nil
    else
        for i = 1, select("#", ...) do
            local fn = select(i, ...)
            sharedEventHandler.events[event][self][fn] = nil
        end

        -- check if isEmpty
        if IsEmpty(sharedEventHandler.events[event][self]) then
            sharedEventHandler.events[event][self] = nil
        end
    end

    -- check if event registered by other objects
    if IsEmpty(sharedEventHandler.events[event]) then
        sharedEventHandler.events[event] = nil
        _UnregisterEvent(sharedEventHandler, event)
    end
end

local function UnregisterAllEvents_Shared(self)
    for event, et in pairs(sharedEventHandler.events) do
        if et[self] then
            et[self] = nil
            -- check if isEmpty
            if IsEmpty(sharedEventHandler.events[event]) then
                sharedEventHandler.events[event] = nil
                _UnregisterEvent(sharedEventHandler, event)
            end
        end
    end
end

sharedEventHandler.events = {}
sharedEventHandler:SetScript("OnEvent", function(self, event, ...)
    for obj, funcs in pairs(self.events[event]) do
        for fn in pairs(funcs) do
            fn(obj, event, ...)
        end
    end
end)

---------------------------------------------------------------------
-- add event handler
---------------------------------------------------------------------
function addon.AddEventHandler(obj)
    if not obj.GetObjectType then
        -- use embeded
        obj.RegisterEvent = RegisterEvent_Embeded
        obj.RegisterUnitEvent = RegisterUnitEvent_Embeded
        obj.UnregisterEvent = UnregisterEvent_Embeded
        obj.UnregisterAllEvents = UnregisterAllEvents_Embeded

        obj.eventHandler = CreateFrame("Frame")
        obj.eventHandler.events = {}

        obj.eventHandler:SetScript("OnEvent", function(self, event, ...)
            for fn in pairs(self.events[event]) do
                fn(self, event, ...)
            end
        end)

    elseif obj:GetObjectType() == "FontString" or obj:GetObjectType() == "Texture" then
        -- use shared
        obj.RegisterEvent = RegisterEvent_Shared
        obj.UnregisterEvent = UnregisterEvent_Shared
        obj.UnregisterAllEvents = UnregisterAllEvents_Shared

    else
        -- use self
        obj.events = {}
        obj.RegisterEvent = RegisterEvent
        obj.UnregisterEvent = UnregisterEvent
        obj.UnregisterAllEvents = UnregisterAllEvents

        obj:SetScript("OnEvent", function(self, event, ...)
            for fn in pairs(self.events[event]) do
                fn(self, event, ...)
            end
        end)
    end
end

---------------------------------------------------------------------
-- add simple event handler for frame
---------------------------------------------------------------------
function addon.AddSimpleEventHandler(frame)
    frame:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end