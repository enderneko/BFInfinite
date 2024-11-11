---------------------------------------------------------------------
-- Fix CommunitiesGuildNewsFrame_OnEvent
-- A LARGE number of GUILD_NEWS_UPDATE events are triggered when changing the map
---------------------------------------------------------------------
local lastTime, timer = 0
local CommunitiesGuildNews_Update = _G.CommunitiesGuildNews_Update
local newsFrame = _G.CommunitiesFrameGuildDetailsFrameNews

local function DelayedUpdate()
    -- print("CommunitiesGuildNews_Update")
    CommunitiesGuildNews_Update(newsFrame)
end

local function CommunitiesGuildNewsFrame_OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        QueryGuildNews()
    else
        if self:IsShown() then
            if timer then timer:Cancel() end
            timer = C_Timer.NewTimer(1, DelayedUpdate)
        end
    end
end
newsFrame:SetScript("OnEvent", CommunitiesGuildNewsFrame_OnEvent)