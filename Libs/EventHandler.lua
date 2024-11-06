---------------------------------------------------------------------
-- File: EventHandler.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2024-03-14 11:46 +08:00
-- Modified: 2024-11-06 18:39 +08:00
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

local function RegisterUnitEvent(self, event, unit, ...)
    if not self.events[event] then self.events[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self.events[event][fn] = true
    end

    if type(unit) == "table" then
        _RegisterUnitEvent(self, event, unpack(unit))
    else
        _RegisterUnitEvent(self, event, unit)
    end
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

local function CoroutineEventHandler(obj, event, ...)
    -- print(obj:GetName(), event)
    for fn in pairs(obj.events[event]) do
        fn(obj, event, ...)
    end
end

local function CoroutineProcessEvents()
    while true do
        -- print("CoroutineProcessEvents", coroutine.running())
        CoroutineEventHandler(coroutine.yield())
    end
end

local sharedCoroutine = coroutine.create(CoroutineProcessEvents)

local function CoroutineOnEvent(obj, event, ...)
    -- if not sharedCoroutine or coroutine.status(sharedCoroutine) == "dead" then
    --     print("CREATE")
    --     sharedCoroutine = coroutine.create(CoroutineProcessEvents)
    -- end
    coroutine.resume(sharedCoroutine, obj, event, ...)
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

    if type(unit) == "table" then
        _RegisterUnitEvent(self.eventHandler, event, unpack(unit))
    else
        _RegisterUnitEvent(self.eventHandler, event, unit)
    end
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
-- add event handler
---------------------------------------------------------------------
function addon.AddEventHandler(obj)
    if not obj.RegisterEvent then
        -- use embeded
        obj.RegisterEvent = RegisterEvent_Embeded
        obj.RegisterUnitEvent = RegisterUnitEvent_Embeded
        obj.UnregisterEvent = UnregisterEvent_Embeded
        obj.UnregisterAllEvents = UnregisterAllEvents_Embeded

        obj.eventHandler = CreateFrame("Frame")
        obj.eventHandler.events = {}

        obj.eventHandler:SetScript("OnEvent", function(self, event, ...)
            for fn in pairs(self.events[event]) do
                fn(obj, event, ...)
            end
        end)
    else
        -- use self
        obj.events = {}
        obj.RegisterEvent = RegisterEvent
        obj.RegisterUnitEvent = RegisterUnitEvent
        obj.UnregisterEvent = UnregisterEvent
        obj.UnregisterAllEvents = UnregisterAllEvents

        -- obj:SetScript("OnEvent", function(self, event, ...)
        --     for fn in pairs(self.events[event]) do
        --         fn(self, event, ...)
        --     end
        -- end)

        obj:SetScript("OnEvent", CoroutineOnEvent)
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