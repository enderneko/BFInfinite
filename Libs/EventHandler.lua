local _, addon = ...

function addon.AddEventHandler(module)
    if module.eventFrame then return end

    module.eventFrame = CreateFrame("Frame")
    module.eventFrame.events = {}

    function module.RegisterEvent(event, onEventFunc)
        module.eventFrame:RegisterEvent(event)
        module.eventFrame.events[event] = onEventFunc
    end

    function module.UnregisterEvent(event)
        module.eventFrame:UnregisterEvent(event)
        module.eventFrame.events[event] = nil
    end

    function module.UnregisterAllEvents(event)
        module.eventFrame:UnregisterEvent(event)
        wipe(module.eventFrame.events)
    end

    module.eventFrame:SetScript("OnEvent", function(self, event, ...)
        if self.events[event] then
            self.events[event](...)
        end
    end)
end