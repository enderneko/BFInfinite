local _, addon = ...

function addon.AddEventHandler(module)
    if module.eventFrame then return end

    module.eventFrame = CreateFrame("Frame")
    module.eventFrame.events = {}

    function module.RegisterEvent(event, onEventFunc)
        module.eventFrame:RegisterEvent(event)
        if type(module.eventFrame.events[event]) == "function" then
            local old = module.eventFrame.events[event]
            module.eventFrame.events[event] = {}
            module.eventFrame.events[event][old] = true
            module.eventFrame.events[event][onEventFunc] = true
        elseif type(module.eventFrame.events[event]) == "table" then
            module.eventFrame.events[event][onEventFunc] = true
        else
            module.eventFrame.events[event] = onEventFunc
        end
    end

    function module.UnregisterEvent(event, funcToRemove)
        module.eventFrame:UnregisterEvent(event)
        if funcToRemove then
            if type(module.eventFrame.events[event]) == "function" then
                if funcToRemove == module.eventFrame.events[event] then
                    module.eventFrame.events[event] = nil
                end
            elseif type(module.eventFrame.events[event]) == "table" then
                module.eventFrame.events[event][funcToRemove] = nil
            end
        else
            module.eventFrame.events[event] = nil
        end
    end

    function module.UnregisterAllEvents(event)
        module.eventFrame:UnregisterEvent(event)
        wipe(module.eventFrame.events)
    end

    module.eventFrame:SetScript("OnEvent", function(self, event, ...)
        if type(self.events[event]) == "function" then
            self.events[event](...)
        elseif type(self.events[event]) == "table" then
            for f in pairs(self.events[event]) do
                f(...)
            end
        end
    end)
end