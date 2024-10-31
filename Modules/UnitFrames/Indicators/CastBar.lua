---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames
local M = BFI.Misc

local strfind = string.find
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime
local GetUnitEmpowerStageDuration = GetUnitEmpowerStageDuration
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack

---------------------------------------------------------------------
-- channeled spell ticks
-- forked from Quartz and Gnosis (only static data)
---------------------------------------------------------------------
local channeledSpellTicks

if BFI.vars.isRetail then
    channeledSpellTicks = {
        -- druid
        [740] = 4, -- 宁静
        -- evoker
        [356995] = 3, -- 裂解
        -- mage
        [5143] = 5, -- 奥术飞弹
        [205021] = 5, -- 冰霜射线
        [314791] = 4, -- 变易幻能
        -- monk
        [117952] = 4, -- 碎玉闪电
        [191837] = 3, -- 精华之泉
        [115175] = 12, -- 抚慰之雾
        -- priest
        [64843] = 4, -- 神圣赞美诗
        [15407] = 6, -- 精神鞭笞
        [47540] = 2, -- 苦修（瞬发第一跳，忽略）
        [205065] = 5, -- 虚空洪流
        [64901] = 5, -- 希望象征
        -- warlock
        [234153] = 5, -- 吸取生命
        [198590] = 5, -- 吸取灵魂
        [217979] = 5, -- 生命通道
    }

elseif BFI.var.isCata then
    channeledSpellTicks = {
        -- druid
        [740] = 4, -- 宁静
        [16914] = 10, -- 飓风
        -- mage
        [10] = 8, -- 暴风雪
        [5143] = 3, -- 奥术飞弹
        -- priest
        [15407] = 3, -- 精神鞭笞
        [48045] = 5, -- 精神灼烧
        [47540] = 2, -- 苦修（瞬发第一跳，忽略）
        [64843] = 4, -- 神圣赞美诗
        [64901] = 4, -- 希望圣歌
        -- warlock
        [1949] = 15, -- 地狱烈焰
        [5740] = 4, -- 火焰之雨
        [689] = 5, -- 吸取生命
        [1120] = 5, -- 吸取灵魂
        [755] = 10, -- 生命通道
    }

else
    channeledSpellTicks = {}
end

do
    local temp = {}
    for id, ticks in pairs(channeledSpellTicks) do
        local name = U.GetSpellInfo(id)
        if name then
            temp[name] = ticks
        else
            BFI.Debug("|cffabababChanneledSpellTicks INVALID|r", id)
        end
    end
    channeledSpellTicks = temp
end

---------------------------------------------------------------------
-- Penance
---------------------------------------------------------------------
if BFI.vars.playerClass == "PRIEST" then
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    local baseTicks = 2

    local function TalentUpdate()
        local activeConfigID = C_ClassTalents.GetActiveConfigID()
        if activeConfigID then
            -- 82577 惩罚
            local nodeInfo = C_Traits.GetNodeInfo(activeConfigID, 82577)
            if nodeInfo then
                if nodeInfo.ranksPurchased ~= 0 then
                    baseTicks = 3
                else
                    baseTicks = 2
                end
            end

            -- 82572 严酷戒律
            -- nodeInfo = C_Traits.GetNodeInfo(activeConfigID, 82572)
            -- if nodeInfo then
            --     mult = nodeInfo.ranksPurchased
            -- end
        end
    end

    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
        TalentUpdate()
    end)

    local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

    local function GetPenanceTicks()
        local bonusTicks = 0

        local auraData = GetPlayerAuraBySpellID(373183)
        if auraData and auraData.points[2] then
            bonusTicks = auraData.points[2]
        end

        return baseTicks + bonusTicks
    end

    channeledSpellTicks[U.GetSpellInfo(47540)] = GetPenanceTicks
end

---------------------------------------------------------------------
-- ticks
---------------------------------------------------------------------
local function CreateTick(self, i)
    local tick = self.bar:CreateTexture(nil, "ARTWORK", nil, 2)
    self.ticks[i] = tick
    AF.SetWidth(tick, self.ticksConfig.width)
    tick:SetColorTexture(AF.UnpackColor(self.ticksConfig.color))
    return tick
end

local function UpdateTicks(self, spell, channelUpdated)
    if not self.ticksEnabled then return end

    if not (self.castType == "channel" and spell and channeledSpellTicks[spell]) then
        for _, tick in pairs(self.ticks) do
            tick:Hide()
        end
        return
    end

    local totalTicks
    if type(channeledSpellTicks[spell]) == "function" then
        totalTicks = channeledSpellTicks[spell]()
    else
        totalTicks = channeledSpellTicks[spell]
    end
    if channelUpdated then totalTicks = totalTicks + 1 end

    local timePerTick = self.duration / totalTicks
    local width = self.bar:GetWidth()

    for i = 1, totalTicks do
        local tick =  self.ticks[i] or CreateTick(self, i)
        tick:ClearAllPoints()

        local x = (self.duration - (i - 1) * timePerTick) / self.duration
        tick:SetPoint("LEFT", self.bar, "RIGHT", -width * x, 0)
        tick:SetPoint("TOP")
        tick:SetPoint("BOTTOM")
        tick:Show()
    end

    for i = totalTicks + 1, #self.ticks do
        self.ticks[i]:Hide()
    end
end

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
local function Reset(self)
    self.castType = nil
    self.castGUID = nil
    self.castSpellID = nil
    self.notInterruptible = nil
    self.resetDelay = nil
    self.numStages = nil
    self.curStage = nil
    wipe(self.stageBounds)
end

---------------------------------------------------------------------
-- empower pips
---------------------------------------------------------------------
local PIP_START_ALPHA = 0.3
local PIP_HIT_ALPHA = 1
local PIP_FADED_ALPHA = 0.7
local PIP_FADE_TIME = 0.4

local map = {
    "empowerstage1",
    "empowerstage2",
    "empowerstage3",
    "empowerstage4",
}

local function FlashPip(self, stage)
    -- print("flash", stage)
    -- print(stage, self.pips[stage]:GetAlpha())
    self.pips[stage].texture:SetAlpha(PIP_HIT_ALPHA)
    AF.FrameFadeOut(self.pips[stage].texture, PIP_FADE_TIME, PIP_HIT_ALPHA, PIP_FADED_ALPHA)
end

local function CreatePip(self, stage)
    local pip = CreateFrame("Frame", nil, self.bar)
    AF.SetFrameLevel(pip, 0, self.bar)

    pip.texture = pip:CreateTexture(nil, "ARTWORK", nil, -2)
    pip.texture:SetAllPoints()
    pip.texture:SetTexture(self.texture)
    pip.texture:SetVertexColor(AF.GetColorRGB(map[stage], PIP_START_ALPHA))

    pip.bound = pip:CreateTexture(nil, "ARTWORK", nil, 1)
    pip.bound:SetColorTexture(AF.GetColorRGB("black"))
    pip.bound:SetPoint("LEFT", pip)
    pip.bound:SetPoint("TOP", pip)
    pip.bound:SetPoint("BOTTOM", pip)
    AF.SetWidth(pip.bound, 1)

    self.pips[stage] = pip

    return pip
end

local function ResetPips(self)
    for _, pip in pairs(self.pips) do
        --! NOTE: IMPORTANT, or alpha can be weird!
        pip.texture:SetAlpha(PIP_START_ALPHA)
        pip:Hide()
    end
end

local function UpdateEmpowerPips(self, numStages)
    if not numStages then
        for _, pip in pairs(self.pips) do
            pip:Hide()
        end
        return
    end

    local width = self.bar:GetWidth()
    local totalDuration = 0
    self.numStages = numStages
    self.curStage = 0

    for stage = 1, numStages do
        local duration = GetUnitEmpowerStageDuration(self.root.displayedUnit, stage - 1) / 1000
        totalDuration = totalDuration + duration
        self.stageBounds[stage] = totalDuration

        local pip = self.pips[stage] or CreatePip(self, stage)
        pip:ClearAllPoints()
        pip:SetPoint("BOTTOM")
        pip:SetPoint("TOP")

        local offset = totalDuration / self.duration * width
        pip:SetPoint("LEFT", offset, 0)

        if stage == numStages then
            pip:SetPoint("RIGHT")
        else
            local nextDuration = GetUnitEmpowerStageDuration(self.root.displayedUnit, stage) / 1000
            pip:SetWidth(nextDuration / self.duration * width)
        end

        pip:Show()
    end

    for i = numStages + 1, #self.pips do
        self.pips[i]:Hide()
    end
end

---------------------------------------------------------------------
-- interruptible
---------------------------------------------------------------------
local function CastInterruptible(self, event, unit)
    if unit and unit ~= self.root.displayedUnit then return end

    if event then
        self.notInterruptible = event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    end

    if self.notInterruptible then
        self.bar:SetColor(AF.UnpackColor(self.uninterruptibleColor))
        self.bar.uninterruptible:Show()
        self:SetBackdropBorderColor(AF.UnpackColor(self.uninterruptibleTextureColor, 1))
        self.gap:SetColorTexture(AF.UnpackColor(self.uninterruptibleTextureColor, 1))
    elseif self.checkInterruptCD and (not self.requireInterruptUsable or U.InterruptUsable()) then -- interruptible
        self.bar:SetColor(AF.UnpackColor(self.interruptibleColor))
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AF.UnpackColor(self.interruptibleColor, 1))
        self.gap:SetVertexColor(AF.UnpackColor(self.interruptibleColor, 1))
    else
        self.bar:SetColor(AF.UnpackColor(self.normalColor))
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AF.UnpackColor(self.borderColor))
        self.gap:SetColorTexture(AF.UnpackColor(self.borderColor))
    end
end

---------------------------------------------------------------------
-- interrupt source
---------------------------------------------------------------------
local function UpdateInterrupt(self)
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subEvent ~= "SPELL_INTERRUPT" then return end

    sourceName = M.GetPetOwner(sourceGUID) or sourceName

    if destGUID == self.root.states.guid then
        local shortName = U.ToShortName(sourceName)
        AF.SetText(self.nameText, shortName, self.nameTextLength)
        local class = M.GetPlayerClass(sourceName)
        self.nameText:SetText(AF.GetIconString("Warning") .. AF.WrapTextInColor(self.nameText:GetText(), class))
    end
end

---------------------------------------------------------------------
-- latency
-- forked from oUF
---------------------------------------------------------------------
-- NOTE: not ideal
-- local function UpdateLatency(self)
--     if not self.latencyEnabled then return end

--     self.latency:ClearAllPoints()
--     if self.castType == "channel" then
--         self.latency:SetPoint("TOPLEFT")
--         self.latency:SetPoint("BOTTOMLEFT")
--     else
--         self.latency:SetPoint("TOPRIGHT")
--         self.latency:SetPoint("BOTTOMRIGHT")
--     end

--     local ratio = select(4, GetNetStats()) / self.duration
--     if ratio > 1 then ratio = 1 end

--     self.latency:SetWidth(self.bar:GetWidth() * ratio)
-- end

---------------------------------------------------------------------
-- latency
-- forked from Quartz
---------------------------------------------------------------------
local function UpdateLatency(self, event, unit)
    if not self.latencyEnabled then return end
    if unit and unit ~= self.root.displayedUnit then return end

    if event == "CURRENT_SPELL_CAST_CHANGED" then
        self.changeTime = GetTime()

    elseif event == "UNIT_SPELLCAST_SENT" then
        self.sendTime = self.changeTime
        self.changeTime = nil

    -- elseif event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- self.sendTime = nil

    elseif event == "UNIT_SPELLCAST_START" then
        if not self.sendTime then
            self.latency:Hide()
            return
        end

        self.timeDiff = GetTime() - self.sendTime
        self.timeDiff = self.timeDiff > self.duration and self.duration or self.timeDiff

        local ratio = self.timeDiff / self.duration
        if ratio > 1 then ratio = 1 end
        if ratio > 0 then
            self.latency:ClearAllPoints()
            if self.castType == "channel" then
                self.latency:SetPoint("TOPLEFT")
                self.latency:SetPoint("BOTTOMLEFT")
                self.latency:SetDrawLayer("ARTWORK", 1)
            else
                self.latency:SetPoint("TOPRIGHT")
                self.latency:SetPoint("BOTTOMRIGHT")
                self.latency:SetDrawLayer("ARTWORK", -1)
            end
            self.latency:SetWidth(self.bar:GetWidth() * ratio)
            self.latency:Show()
        else
            self.latency:Hide()
        end

        -- print(format("%dms", self.timeDiff))
        self.sendTime = nil
    end
end

---------------------------------------------------------------------
-- stop & fail
---------------------------------------------------------------------
local function ShowOverlay(self, failed)
    if failed then
        self.status:SetVertexColor(AF.UnpackColor(self.failedColor))
    else
        self.status:SetVertexColor(AF.UnpackColor(self.succeededColor))
    end
    self.bar:Hide()
    self.status:Show()
end

local function CastFail(self, event, unit, castGUID, castSpellID)
    if unit and unit ~= self.root.displayedUnit then return end

    if self.castGUID ~= castGUID or self.castSpellID ~= castSpellID then return end

    Reset(self)
    ShowOverlay(self, true)
    self.durationText:Hide()
    self:FadeOut()
end

local function CastStop(self, event, unit, castGUID, castSpellID, empowerComplete)
    if unit and unit ~= self.root.displayedUnit then return end

    if event then
        if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            if self.castSpellID ~= castSpellID then return end
            Reset(self)
            self.bar:Hide()
        elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            if self.castSpellID ~= castSpellID then return end
            Reset(self)
            ResetPips(self)
            ShowOverlay(self, not empowerComplete)
        else
            if self.castGUID ~= castGUID or self.castSpellID ~= castSpellID then return end
            -- NOTE:
            -- normally, CAST_INTERRUPTED fires before CAST_STOP
            -- but if ESC a spell, CAST_INTERRUPTED fires AFTER CAST_STOP
            self.resetDelay = 0.3
            ShowOverlay(self)
        end

    else
        if self.castType == "channel" then
            self.bar:Hide()
        else
            ShowOverlay(self)
        end
        Reset(self)
    end

    self.durationText:Hide()
    self:FadeOut()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function CastUpdate(self, event, unitId, castGUID, castSpellID)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local name, startTime, endTime, _
    if event == "UNIT_SPELLCAST_DELAYED" then
        name, _, _, startTime, endTime = UnitCastingInfo(unit)
    else
        name, _, _, startTime, endTime = UnitChannelInfo(unit)
    end

    if not name then return end

    if self.castType == "empower" then
        endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    local delay
    if self.castType == "channel" then
        delay = self.startTime - startTime
        self.current = endTime - GetTime()
    else
        delay = startTime - self.startTime
        self.current = GetTime() - startTime
    end

    if delay < 0 then
        delay = 0
    end

    self.duration = endTime - startTime
    self.startTime = startTime
    self.endTime = endTime
    self.delay = self.delay + delay

    self.bar:SetBarMinMaxValues(0, self.duration)
    self.bar:SetBarValue(self.current)

    -- ticks
    UpdateTicks(self, name, true)
end

---------------------------------------------------------------------
-- start / onupdate
---------------------------------------------------------------------
local function OnUpdate(self, elapsed)
    if self.castType then
        if self.resetDelay then
            self.resetDelay = self.resetDelay - elapsed
            if self.resetDelay <= 0 then
                Reset(self)
                return
            end
        end

        local isCasting = self.castType == "cast" or self.castType == "empower"
        if isCasting then
            self.current = self.current + elapsed
            if self.current >= self.duration then
                CastStop(self)
                return
            end
            if self.showDelay and self.delay ~= 0 then
                self.durationText:SetFormattedText(self.delayedDurationFormat, "+", self.delay, self.duration - self.current)
            else
                self.durationText:SetFormattedText(self.durationFormat, self.duration - self.current)
            end
        else
            self.current = self.current - elapsed
            if self.current <= 0 then
                CastStop(self)
                return
            end
            if self.showDelay and self.delay ~= 0 then
                self.durationText:SetFormattedText(self.delayedDurationFormat, "-", self.delay, self.current)
            else
                self.durationText:SetFormattedText(self.durationFormat, self.current)
            end
        end

        self.bar:SetBarValue(self.current)

        if self.castType == "empower" then
            for i = self.curStage + 1, self.numStages do
                if self.stageBounds[i] then
                    if self.current > self.stageBounds[i] then
                        self.curStage = i
                        FlashPip(self, self.curStage)
                    else
                        break
                    end
                end
            end
        end

        if self.enableInterruptibleCheck and self.checkInterruptCD and self.requireInterruptUsable and not self.notInterruptible then
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed >= 0.25 then
                CastInterruptible(self)
            end
        end
    end
end

local function CastStart(self, event, unitId, castGUID, castSpellID)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID, isEmpowered, numEmpowerStages = UnitCastingInfo(unit)
    self.castType = "cast"

    if not name then
        name, text, texture, startTime, endTime, isTradeskill, notInterruptible, spellID, isEmpowered, numEmpowerStages = UnitChannelInfo(unit)
        if numEmpowerStages and numEmpowerStages > 0 then
            self.castType = "empower"
            endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
        else
            self.castType = "channel"
        end
    end

    if not name then
        Reset(self)
        self:HideNow()
        return
    end

    self.delay = 0
    self.resetDelay = nil
    self.castGUID = castGUID or castID
    self.castSpellID = castSpellID or spellID
    self.startTime = startTime / 1000
    self.endTime = endTime / 1000

    -- curent progress
    if self.castType == "channel" then
        self.current = self.endTime - GetTime()
    else
        self.current = GetTime() - self.startTime
    end
    self.duration = self.endTime - self.startTime

    -- interruptible
    if self.enableInterruptibleCheck and not isTradeSkill then
        if UnitIsUnit(unit, "player") or not UnitCanAttack("player", unit) then
            self.checkInterruptCD = nil
        else
            self.checkInterruptCD = true
        end
        self.notInterruptible = notInterruptible
        CastInterruptible(self)
    else
        self.checkInterruptCD = nil
        self.notInterruptible = nil
        -- restore to normal
        self.bar:SetColor(AF.UnpackColor(self.normalColor))
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AF.UnpackColor(self.borderColor))
        self.gap:SetColorTexture(AF.UnpackColor(self.borderColor))
    end

    -- empower
    UpdateEmpowerPips(self, numEmpowerStages)

    -- ticks
    UpdateTicks(self, name)

    -- latency
    UpdateLatency(self, "UNIT_SPELLCAST_START", unitId)

    if self.showDuration then
        self.durationText:Show()
    end
    if self.showName then
        AF.SetText(self.nameText, name, self.nameTextLength)
    end
    self.status:Hide()
    self.icon:SetTexture(texture or 134400)
    self.bar:SetBarMinMaxValues(0, self.duration)
    self.bar:SetBarValue(self.current)
    self.bar:Show()
    self:ShowNow()
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function CastBar_Update(self)
    CastStart(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function CastBar_Enable(self)
    -- start
    self:RegisterEvent("UNIT_SPELLCAST_START", CastStart)
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", CastStart)
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START", CastStart)

    -- update
    self:RegisterEvent("UNIT_SPELLCAST_DELAYED", CastUpdate)
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", CastUpdate)
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", CastUpdate)

    -- stop (succeeded)
    self:RegisterEvent("UNIT_SPELLCAST_STOP", CastStop)
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", CastStop)
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", CastStop)

    -- interrupted
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", CastFail)

    -- interruptible
    if self.enableInterruptibleCheck then
        self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", CastInterruptible)
        self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", CastInterruptible)
        self:RegisterEvent("UNIT_FACTION", CastInterruptible)
    end

    -- latency
    if self.latencyEnabled then
        self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UpdateLatency)
        self:RegisterEvent("UNIT_SPELLCAST_SENT", UpdateLatency)
    else
        self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED")
        self:UnregisterEvent("UNIT_SPELLCAST_SENT")
    end

    -- interrupt source
    if self.showName and self.showInterruptSource then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", UpdateInterrupt)
    else
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end

    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function CastBar_Disable(self)
    Reset(self)
    self:UnregisterAllEvents()
    self:Hide()
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
-- local function CastBar_SetBackgroudColor(self, color)
--     self:SetBackdropColor(unpack(color))
-- end

-- local function CastBar_SetBorderColor(self, color)
--     self:SetBackdropBorderColor(unpack(color))
--     self.gap:SetColorTexture(unpack(color))
-- end

-- local function CastBar_SetPipsColor(self, color)
--     for i, pip in pairs(self.pips) do
--         pip.texture:SetVertexColor(AF.GetColorRGB(map[i], PIP_START_ALPHA))
--     end
-- end

local function CastBar_SetTexture(self, texture)
    texture = AF.LSM_GetBarTexture(texture)
    self.texture = texture
    self.bar.fg:SetTexture(texture)
    self.status:SetTexture(texture)
    for _, pip in pairs(self.pips) do
        pip.texture:SetTexture(texture)
    end
end

local function CastBar_SetupNameText(self, config, showIcon)
    self.nameText:SetShown(config.enabled)
    AF.SetFont(self.nameText, config.font)
    AF.LoadTextPosition(self.nameText, config.position, showIcon and self.icon)
    self.nameText:SetTextColor(AF.UnpackColor(config.color))
    self.nameTextLength = config.length
    self.showName = config.enabled
    self.showInterruptSource = config.showInterruptSource
end

local function CastBar_SetupDurationText(self, config)
    self.durationText:SetShown(config.enabled)
    AF.SetFont(self.durationText, config.font)
    AF.LoadTextPosition(self.durationText, config.position)
    self.durationText:SetTextColor(AF.UnpackColor(config.color))
    self.durationFormat = config.format
    self.delayedDurationFormat = "|cffff0000%s%.2f|r "..config.format
    self.showDelay = config.showDelay
    self.showDuration = config.enabled
end

local function CastBar_SetupIcon(self, show)
    if show then
        AF.SetPoint(self.bar, "TOPLEFT", self.gap, "TOPRIGHT")
        AF.SetPoint(self.status, "TOPLEFT", self.gap, "TOPRIGHT")
        self.icon:Show()
        self.gap:Show()
    else
        AF.SetPoint(self.bar, "TOPLEFT", 1, -1)
        AF.SetPoint(self.status, "TOPLEFT", 1, -1)
        self.icon:Hide()
        self.gap:Hide()
    end
end

local function CastBar_SetupSpark(self, config)
    if not config.enabled then
        self.spark:Hide()
        return
    end

    self.spark:Show()

    self.spark:ClearAllPoints()
    self.spark:SetPoint("RIGHT", self.bar.fg)
    if config.height == 0 then
        self.spark:SetPoint("TOP")
        self.spark:SetPoint("BOTTOM")
        self.spark:SetPoint("RIGHT", self.bar.fg)
    else
        self.spark:SetHeight(config.height)
    end

    AF.SetWidth(self.spark, config.width)
    if config.texture == "plain" then
        self.spark:SetTexture(AF.GetPlainTexture())
    else
        -- TODO:
    end
    self.spark:SetVertexColor(AF.UnpackColor(config.color))
end

local function CastBar_UpdateTicks(self, config)
    self.ticksEnabled = config.enabled
    if not config.enabled then
        if self.ticks then
            for _, tick in pairs(self.ticks) do
                tick:Hide()
            end
        end
        return
    end

    if not self.ticks then self.ticks = {} end

    for _, tick in pairs(self.ticks) do
        AF.SetWidth(tick, config.width)
        tick:SetColorTexture(AF.UnpackColor(config.color))
    end
end

local function CastBar_UpdateLatency(self, config)
    self.latencyEnabled = config.enabled
    if not config.enabled then
        if self.latency then
            self.latency:Hide()
            return
        end
    end

    if not self.latency then
        self.latency = self.bar:CreateTexture(nil, "ARTWORK", nil, -1)
    end
    self.latency:SetColorTexture(AF.UnpackColor(config.color))
end

local function CastBar_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.ReSize(self.gap)
    AF.ReSize(self.spark)
    AF.RePoint(self.bar)
    AF.RePoint(self.status)
    AF.RePoint(self.icon)
    AF.RePoint(self.nameText)
    AF.RePoint(self.durationText)

    if self.ticks then
        for _, tick in pairs(self.ticks) do
            AF.ReSize(tick)
        end
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CastBar_LoadConfig(self, config)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)
    AF.SetWidth(self.icon, config.height-2)

    AF.SetFrameLevel(self, config.frameLevel, self.root)

    CastBar_SetTexture(self, config.texture)

    self:SetBackdropColor(AF.UnpackColor(config.bgColor))
    self:SetBackdropBorderColor(AF.UnpackColor(config.borderColor))
    self.gap:SetColorTexture(AF.UnpackColor(config.borderColor))

    self.bar:SetColor(AF.UnpackColor(config.colors.normal))
    self.bar.uninterruptible:SetVertexColor(AF.UnpackColor(config.colors.uninterruptibleTexture))

    AF.SetFadeInOutAnimationDuration(self, config.fadeDuration)

    CastBar_SetupNameText(self, config.nameText, config.showIcon)
    CastBar_SetupDurationText(self, config.durationText)
    CastBar_SetupIcon(self, config.showIcon)
    CastBar_SetupSpark(self, config.spark)

    if self.root.hasCastBarTicks then
        CastBar_UpdateTicks(self, config.ticks)
        self.ticksConfig = config.ticks
    end

    if self.root.hasLatency then
        CastBar_UpdateLatency(self, config.latency)
    end

    self.normalColor = config.colors.normal
    self.failedColor = config.colors.failed
    self.succeededColor = config.colors.succeeded
    self.interruptibleColor = config.colors.interruptible.value
    self.uninterruptibleColor = config.colors.uninterruptible
    self.uninterruptibleTextureColor = config.colors.uninterruptibleTexture
    self.borderColor = config.borderColor

    self.requireInterruptUsable = config.colors.interruptible.requireInterruptUsable
    self.enableInterruptibleCheck = config.enableInterruptibleCheck
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function CastBar_EnableConfigMode(self)
    self.Enable = CastBar_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()

    UnitIsUnit = UF.CFG_UnitIsUnit
    UnitCastingInfo = UF.CFG_UnitCastingInfo

    if not self._preview then
        self._preview = CreateFrame("Frame")
        self._preview:Hide()
        self._preview:SetScript("OnUpdate", function(_, elapsed)
            self._elapsed = self._elapsed + elapsed
            if self._elapsed >= 9 then
                self._elapsed = 0
                self._previewInterrupt = not self._previewInterrupt
                self._isPreviewInterrupt = false
                CastStart(self)
            elseif self._elapsed >= 1.5 and self._previewInterrupt and not self._isPreviewInterrupt then
                self._isPreviewInterrupt = true
                CastFail(self, nil, self.root.displayedUnit, self.castGUID, self.castSpellID)
                self._elapsed = self._elapsed + 1.5
            end
        end)
    end

    self._elapsed = 9
    self._previewInterrupt = false
    self._preview:Show()
end

local function CastBar_DisableConfigMode(self)
    self.Enable = CastBar_Enable
    self.Update = CastBar_Update

    UnitIsUnit = UF.UnitIsUnit
    UnitCastingInfo = UF.UnitCastingInfo

    self._preview:Hide()
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
-- bar layers
-- pipTexture: -2
-- latency: -1, 1
-- bar: 0
-- pipBound: 1
-- ticks: 2
-- spark: 3
-- uninterruptible: 4

function UF.CreateCastBar(parent, name)
    -- frame
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    AF.SetDefaultBackdrop(frame)
    frame:Hide()

    frame.root = parent

    frame:SetScript("OnUpdate", OnUpdate)

    -- events
    BFI.AddEventHandler(frame)

    -- fade out
    AF.CreateFadeInOutAnimation(frame, 0.5)
    frame.fadeOut.alpha:SetSmoothing("IN")

    -- cast status texture
    local status = frame:CreateTexture(nil, "OVERLAY")
    frame.status = status
    AF.SetOnePixelInside(status, frame)
    status:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AF.SetPoint(icon, "TOPLEFT", 1, -1)
    AF.SetPoint(icon, "BOTTOMLEFT", 1, 1)

    -- gap
    local gap = frame:CreateTexture(nil, "BORDER")
    frame.gap = gap
    gap:SetPoint("TOPLEFT", icon, "TOPRIGHT")
    gap:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT")
    AF.SetWidth(gap, 1)

    -- bar
    local bar = AF.CreateSimpleBar(frame, nil, true)
    frame.bar = bar
    AF.SetOnePixelInside(bar, frame)
    bar.fg:SetDrawLayer("ARTWORK", 0)
    AF.SetFrameLevel(bar, 1, frame)

    -- spark
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 3)
    frame.spark = spark
    spark:SetBlendMode("ADD")

    -- uninterruptible texture
    local uninterruptible = bar:CreateTexture(nil, "ARTWORK", nil, 4)
    bar.uninterruptible = uninterruptible
    uninterruptible:SetAllPoints()
    uninterruptible:SetTexture(AF.GetTexture("Uninterruptible1", BFI.name), "REPEAT", "REPEAT")
    uninterruptible:SetHorizTile(true)
    uninterruptible:SetVertTile(true)
    uninterruptible:Hide()

    -- empower
    frame.pips = {}
    frame.stageBounds = {}

    -- overlay
    local overlay = CreateFrame("Frame", nil, frame)
    frame.overlay = overlay
    overlay:SetAllPoints()
    AF.SetFrameLevel(overlay, 2, frame)

    -- name
    local nameText = overlay:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
    frame.nameText = nameText

    -- duration
    local durationText = overlay:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
    frame.durationText = durationText

    -- functions
    frame.Update = CastBar_Update
    frame.Enable = CastBar_Enable
    frame.Disable = CastBar_Disable
    frame.EnableConfigMode = CastBar_EnableConfigMode
    frame.DisableConfigMode = CastBar_DisableConfigMode
    frame.LoadConfig = CastBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater(frame, CastBar_UpdatePixels)

    return frame
end