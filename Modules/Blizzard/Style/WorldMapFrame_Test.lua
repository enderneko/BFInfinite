local timeNow = time()

-- Test Ongoing Events
local testOngoingEvents = {
    {
        areaPoiID = 8422,
        rewardsClaimed = false,
        displayInfo = {
            hideTimeLeft = false,
            hideDescription = false,
            overrideAtlas = nil,
            overrideTooltipWidgetSetID = nil,
        },
    },
    {
        areaPoiID = 8423,
        rewardsClaimed = true,
        displayInfo = {
            hideTimeLeft = false,
            hideDescription = false,
            overrideAtlas = nil,
            overrideTooltipWidgetSetID = 123,
        },
    },
}

-- Test Scheduled Events
local testScheduledEvents = {
    {
        eventKey = "event_2025_1",
        eventID = 8527,
        areaPoiID = 8527,
        startTime = timeNow - 1800,  -- 30分钟前开始
        endTime = timeNow + 1800,     -- 30分钟后结束
        duration = 3600,
        hasReminder = false,
        rewardsClaimed = false,
        displayInfo = {
            hideTimeLeft = false,
            hideDescription = false,
            overrideAtlas = nil,
            overrideTooltipWidgetSetID = nil,
        },
    },
    {
        eventKey = "event_2025_2",
        eventID = 8463,
        areaPoiID = 8463,
        startTime = timeNow + 600, -- 10分钟后开始
        endTime = timeNow + 3600 + 600, -- 1小时10分钟后结束
        duration = 3600,
        hasReminder = false,
        rewardsClaimed = false,
        displayInfo = {
            hideTimeLeft = false,
            hideDescription = false,
            overrideAtlas = nil,
            overrideTooltipWidgetSetID = nil,
        },
    },
    {
        eventKey = "event_2025_3",
        eventID = 8244,
        areaPoiID = 8244,
        startTime = timeNow + 86400, -- 1天后开始
        endTime = timeNow + 172800, -- 2天后结束
        duration = 86400,
        hasReminder = true,
        rewardsClaimed = false,
        displayInfo = {
            hideTimeLeft = false,
            hideDescription = false,
            overrideAtlas = nil,
            overrideTooltipWidgetSetID = 456,
        },
    },
}

-- Function to display test data in EventScheduler UI
function DisplayTestDataInEventScheduler()
    local eventScheduler = QuestMapFrame.EventsFrame

    -- Override the API methods to return our test data
    C_EventScheduler.GetOngoingEvents = function()
        return testOngoingEvents
    end

    C_EventScheduler.GetScheduledEvents = function()
        return testScheduledEvents
    end

    C_EventScheduler.HasData = function()
        return true
    end

    -- Refresh the EventScheduler to display the test data
    eventScheduler:Refresh()

    print("|cff00ff00Test data loaded successfully!|r")
    print(format("  Ongoing Events: %d", #testOngoingEvents))
    print(format("  Scheduled Events: %d", #testScheduledEvents))

    return true
end

DisplayTestDataInEventScheduler()