local _, addon = ...

---------------------------------------------------------------------
-- add event handler for module (non-Frame)
---------------------------------------------------------------------
function addon.AddEventHandler(module)
    module.eventFrame = CreateFrame("Frame")
    module.eventFrame.events = {}

    function module.RegisterEvent(event, onEventFunc)
        module.eventFrame:RegisterEvent(event)
        if type(module.eventFrame.events[event]) == "function" then
            local old = module.eventFrame.events[event]
            module.eventFrame.events[event] = {}
            tinsert(module.eventFrame.events[event], old)
            tinsert(module.eventFrame.events[event], onEventFunc)
        elseif type(module.eventFrame.events[event]) == "table" then
            tinsert(module.eventFrame.events[event], onEventFunc)
        else
            module.eventFrame.events[event] = onEventFunc
        end
    end

    function module.UnregisterEvent(event, funcToRemove)
        if funcToRemove then
            if type(module.eventFrame.events[event]) == "function" then
                if funcToRemove == module.eventFrame.events[event] then
                    module.eventFrame.events[event] = nil
                    module.eventFrame:UnregisterEvent(event)
                end
            elseif type(module.eventFrame.events[event]) == "table" then
                for i, f in pairs(module.eventFrame.events[event]) do
                    if f == funcToRemove then
                        tremove(module.eventFrame.events[event], i)
                        break
                    end
                end
                -- check if isEmpty
                if #module.eventFrame.events[event] == 0 then
                    module.eventFrame.events[event] = nil
                    module.eventFrame:UnregisterEvent(event)
                end
            end
        else
            module.eventFrame.events[event] = nil
            module.eventFrame:UnregisterEvent(event)
        end
    end

    function module.UnregisterAllEvents(event)
        module.eventFrame:UnregisterEvent(event)
        wipe(module.eventFrame.events)
    end

    module.eventFrame:SetScript("OnEvent", function(self, event, ...)
        if type(self.events[event]) == "function" then
            self.events[event](event, ...)
        elseif type(self.events[event]) == "table" then
            for _, f in pairs(self.events[event]) do
                f(event, ...)
            end
        end
    end)
end

---------------------------------------------------------------------
-- add simple event handler for frame
---------------------------------------------------------------------
function addon.SetSimpleEventHandler(frame)
    frame:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

---------------------------------------------------------------------
-- add event handler
---------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "BFI_EVENT_HANDLER")
local _RegisterEvent = eventFrame.RegisterEvent
local _UnregisterEvent = eventFrame.UnregisterEvent
local _UnregisterAllEvents = eventFrame.UnregisterAllEvents

-- for objects with OnEvent handler -------------
local function RegisterEvent(self, event, ...)
    if type(self.events[event]) == "function" then
        local old = self.events[event]
        self.events[event] = {}
        tinsert(self.events[event], old)
        for i = 1, select("#", ...) do
            local f = select(i, ...)
            tinsert(self.events[event], f)
        end
    elseif type(self.events[event]) == "table" then
        for i = 1, select("#", ...) do
            local f = select(i, ...)
            tinsert(self.events[event], f)
        end
    else
        if select("#", ...) == 1 then
            self.events[event] = ...        
        elseif select("#", ...) > 1 then
            self.events[event] = {}
            for i = 1, select("#", ...) do
                local f = select(i, ...)
                tinsert(self.events[event], f)
            end
        end
    end
    _RegisterEvent(self, event)
end

local function UnregisterEvent(self, event, ...)
    if select("#", ...) ~= 0 then
        if type(self.events[event]) == "function" then
            for i = 1, select("#", ...) do
                local f = select(i, ...)
                if f == self.events[event] then
                    self.events[event] = nil
                    _UnregisterEvent(self, event)
                    break
                end
            end
        elseif type(self.events[event]) == "table" then
            for i = 1, select("#", ...) do
                local _f = select(i, ...)
                for j, f in pairs(self.events[event]) do
                    if f == _f then
                        tremove(self.events[event], j)
                        break
                    end
                end
            end
            -- check if isEmpty
            if #self.events[event] == 0 then
                self.events[event] = nil
                _UnregisterEvent(self, event)
            end
        end
    else
        _UnregisterEvent(self, event)
        self.events[event] = nil
    end
end

local function UnregisterAllEvents(self)
    _UnregisterAllEvents(self)
    wipe(self.events)
end
-------------------------------------------------

-- for objects without OnEvent handler ----------
local function IsEmpty(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

eventFrame.events = {}
eventFrame.RegisterEvent = function(self, event, ...)
    if not eventFrame.events[event] then
        eventFrame.events[event] = {}
    end

    if not eventFrame.events[event][self] then
        eventFrame.events[event][self] = {}
    end

    local t = eventFrame.events[event][self]

    for i = 1, select("#", ...) do
        local f = select(i, ...)
        tinsert(t, f)
    end

    _RegisterEvent(eventFrame, event)
end

eventFrame.UnregisterEvent = function(self, event, ...)
    if not eventFrame.events[event] then return end
    if not eventFrame.events[event][self] then return end

    local t = eventFrame.events[event][self]

    if select("#", ...) ~= 0 then
        for i = 1, select("#", ...) do
            local _f = select(i, ...)
            for j, f in pairs(t) do
                if f == _f then
                    tremove(t, j)
                    break
                end
            end
        end
        -- check if isEmpty
        if #t == 0 then
            eventFrame.events[event][self] = nil
        end
    else
        eventFrame.events[event][self] = nil
    end

    -- check if event registered by other objects
    if IsEmpty(eventFrame.events[event]) then
        eventFrame.events[event] = nil
        _UnregisterEvent(eventFrame, event)
    end
end

eventFrame.UnregisterAllEvents = function(self)
    for event, et in pairs(eventFrame.events) do
        et[self] = nil

        if IsEmpty(eventFrame.events[event]) then
            eventFrame.events[event] = nil
            _UnregisterEvent(eventFrame, event)
        end
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    for obj, funcs in pairs(self.events[event]) do
        for _, fn in pairs(funcs) do
            fn(obj, event, ...)
        end
    end
end)
-------------------------------------------------

function addon.SetEventHandler(obj)
    if obj:GetObjectType() == "FontString" or obj:GetObjectType() == "Texture" then
        obj.RegisterEvent = eventFrame.RegisterEvent
        obj.UnregisterEvent = eventFrame.UnregisterEvent
        obj.UnregisterAllEvents = eventFrame.UnregisterAllEvents
    else
        obj.events = {}
        obj.RegisterEvent = RegisterEvent
        obj.UnregisterEvent = UnregisterEvent
        obj.UnregisterAllEvents = UnregisterAllEvents
    
        obj:SetScript("OnEvent", function(self, event, ...)
            if type(self.events[event]) == "function" then
                self.events[event](self, event, ...)
            elseif type(self.events[event]) == "table" then
                for _, fn in pairs(self.events[event]) do
                    fn(self, event, ...)
                end
            end
        end)
    end
end