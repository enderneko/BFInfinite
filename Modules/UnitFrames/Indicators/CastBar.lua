local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local strfind = string.find
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitClassBase = UnitClassBase
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime
local GetUnitEmpowerStageDuration = GetUnitEmpowerStageDuration

---------------------------------------------------------------------
-- channeled spell ticks
-- forked from Quartz and Gnosis
---------------------------------------------------------------------
local classMaxTicks, channeledSpellTicks

if BFI.vars.isRetail then
    classMaxTicks = { -- +1
        ["DRUID"] = 5,
        ["EVOKER"] = 4,
        ["MAGE"] = 6,
        ["MONK"] = 9,
        ["PRIEST"] = 7,
        ["WARLOCK"] = 6,
    }

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
        [115175] = 8, -- 抚慰之雾
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
    classMaxTicks = { -- +1
        ["DRUID"] = 11,
        ["MAGE"] = 9,
        ["PRIEST"] = 6,
        ["WARLOCK"] = 16,
    }

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
    classMaxTicks = {}
    channeledSpellTicks = {}
end

do
    local temp = {}
    for id, ticks in pairs(channeledSpellTicks) do
        local name = GetSpellInfo(id)
        if name then
            temp[GetSpellInfo(id)] = ticks
        else
            BFI.Debug("|cffabababChanneledSpellTicks INVALID|r", id)
        end
    end
    channeledSpellTicks = temp
end

-- TODO: 苦修
-- local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
-- eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

-- local function TalentUpdate()
--     local activeConfigID = C_ClassTalents.GetActiveConfigID()
--     if activeConfigID and dispelNodeIDs[Cell.vars.playerSpecID] then
--         for dispelType, value in pairs(dispelNodeIDs[Cell.vars.playerSpecID]) do
--             if type(value) == "boolean" then
--                 dispellable[dispelType] = value
--             elseif type(value) == "table" then -- more than one trait
--                 for _, v in pairs(value) do
--                     local nodeInfo = C_Traits.GetNodeInfo(activeConfigID, v)
--                     if nodeInfo and nodeInfo.ranksPurchased ~= 0 then
--                         dispellable[dispelType] = true
--                         break
--                     end
--                 end
--             else -- number: check node info
--                 local nodeInfo = C_Traits.GetNodeInfo(activeConfigID, value)
--                 if nodeInfo and nodeInfo.ranksPurchased ~= 0 then
--                     dispellable[dispelType] = true
--                 end
--             end
--         end
--     end
-- end

-- eventFrame:SetScript("OnEvent", function(self, event)
--     if event == "PLAYER_ENTERING_WORLD" then
--         eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
--     end
--     TalentUpdate()
-- end)

local function UpdateTicks(self, spell, channelUpdated)
    if not self.ticksEnabled then return end

    if not (self.castType == "channel" and spell and channeledSpellTicks[spell]) then
        for _, tick in pairs(self.ticks) do
            tick:Hide()
        end
        return
    end

    local width = self.bar:GetWidth()
    local totalTicks = channelUpdated and channeledSpellTicks[spell] + 1 or channeledSpellTicks[spell]
    local timePerTick = self.duration / totalTicks

    for i = 1, totalTicks do
        local tick =  self.ticks[i]
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
    AW.FrameFadeOut(self.pips[stage].texture, PIP_FADE_TIME, PIP_HIT_ALPHA, PIP_FADED_ALPHA)
end

local function CreatePip(self, stage)
    local pip = CreateFrame("Frame", nil, self.bar)
    AW.SetFrameLevel(pip, 0, self.bar)

    pip.texture = pip:CreateTexture(nil, "ARTWORK", nil, -2)
    pip.texture:SetAllPoints()
    pip.texture:SetTexture(self.texture)
    pip.texture:SetVertexColor(AW.GetColorRGB(map[stage], PIP_START_ALPHA))

    pip.bound = pip:CreateTexture(nil, "ARTWORK", nil, 1)
    pip.bound:SetColorTexture(AW.GetColorRGB("black"))
    pip.bound:SetPoint("LEFT", pip)
    pip.bound:SetPoint("TOP", pip)
    pip.bound:SetPoint("BOTTOM", pip)
    AW.SetWidth(pip.bound, 1)

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
    if not numStages then return end

    local width = self.bar:GetWidth()
    local totalDuration = 0
    self.numStages = numStages
    self.curStage = 0

    for stage = 1, numStages do
        local duration = GetUnitEmpowerStageDuration(self.root.displayedUnit, stage - 1)
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
            local nextDuration = GetUnitEmpowerStageDuration(self.root.displayedUnit, stage)
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
        self.bar.uninterruptible:Show()
        self:SetBackdropBorderColor(AW.UnpackColor(self.uninterruptibleColor, 1))
        self.gap:SetColorTexture(AW.UnpackColor(self.uninterruptibleColor, 1))
    else
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AW.UnpackColor(self.borderColor))
        self.gap:SetColorTexture(AW.UnpackColor(self.borderColor))
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
        self.changeTime = GetTime() * 1000

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

        self.timeDiff = GetTime() * 1000 - self.sendTime
        self.timeDiff = self.timeDiff > self.duration and self.duration or self.timeDiff

        local ratio = self.timeDiff / self.duration
        if ratio > 1 then ratio = 1 end
        if ratio > 0 then
            self.latency:ClearAllPoints()
            if self.castType == "channel" then
                self.latency:SetPoint("TOPLEFT")
                self.latency:SetPoint("BOTTOMLEFT")
                self.latency:SetDrawLayer("ARTWORK", 0)
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
        self.status:SetVertexColor(AW.UnpackColor(self.failedColor))
    else
        self.status:SetVertexColor(AW.UnpackColor(self.succeededColor))
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

    local delay
    if self.castType == "channel" then
        delay = self.startTime - startTime
        self.current = endTime - GetTime() * 1000
    else
        delay = startTime - self.startTime
        self.current = GetTime() * 1000 - startTime
    end

    if delay < 0 then
        delay = 0
    end

    self.duration = endTime - startTime
    self.startTime = startTime
    self.delay = self.delay + delay

    self.bar:SetMinMaxValues(0, self.duration)
    self.bar:SetValue(self.current)

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
            self.current = self.current + elapsed * 1000
            if self.current >= self.duration then
                CastStop(self)
                return
            end
            if self.showDelay and self.delay ~= 0 then
                self.durationText:SetFormattedText(self.delayedDurationFormat, "+", self.delay / 1000, (self.duration - self.current) / 1000)
            else
                self.durationText:SetFormattedText(self.durationFormat, (self.duration - self.current) / 1000)
            end
        else
            self.current = self.current - elapsed * 1000
            if self.current <= 0 then
                CastStop(self)
                return
            end
            if self.showDelay and self.delay ~= 0 then
                self.durationText:SetFormattedText(self.delayedDurationFormat, "-", self.delay / 1000, self.current / 1000)
            else
                self.durationText:SetFormattedText(self.durationFormat, self.current / 1000)
            end
        end

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

        self.bar:SetValue(self.current)
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
    self.startTime = startTime
    self.endTime = endTime

    -- curent progress
    if self.castType == "channel" then
        self.current = endTime - GetTime() * 1000
    else
        self.current = GetTime() * 1000 - startTime
    end
    self.duration = endTime - startTime

    -- interruptible
    self.notInterruptible = notInterruptible
    if unit ~= "player" then
        CastInterruptible(self)
    end

    -- empower
    UpdateEmpowerPips(self, numEmpowerStages)

    -- ticks
    UpdateTicks(self, name)

    -- latency
    UpdateLatency(self, "UNIT_SPELLCAST_START", unitId)

    self.status:Hide()
    self.durationText:Show()
    AW.SetText(self.nameText, name, self.nameTextLength)
    self.icon:SetTexture(texture or 134400)
    self.bar:SetMinMaxValues(0, self.duration)
    self.bar:SetValue(self.current)
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
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", CastInterruptible)
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", CastInterruptible)

    -- latency
    if self.latencyEnabled then
        self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UpdateLatency)
        self:RegisterEvent("UNIT_SPELLCAST_SENT", UpdateLatency)
    end

    -- onupdate
    self:SetScript("OnUpdate", OnUpdate)

    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function CastBar_Disable(self)
    Reset(self)
    self:UnregisterAllEvents()
    self:SetScript("OnUpdate", nil)
    self:Hide()
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function CastBar_SetBackgroudColor(self, color)
    self:SetBackdropColor(unpack(color))
end

local function CastBar_SetBorderColor(self, color)
    self:SetBackdropBorderColor(unpack(color))
    self.gap:SetColorTexture(unpack(color))
end

local function CastBar_SetPipsColor(self, color)
    for i, pip in pairs(self.pips) do
        pip.texture:SetVertexColor(AW.GetColorRGB(map[i], PIP_START_ALPHA))
    end
end

local function CastBar_SetTexture(self, texture)
    texture = U.GetBarTexture(texture)
    self.texture = texture
    self.bar:SetStatusBarTexture(texture)
    self.status:SetTexture(texture)
    for _, pip in pairs(self.pips) do
        pip:SetTexture(texture)
    end
end

local function CastBar_UpdateNameText(self, config, showIcon)
    U.SetFont(self.nameText, config.font)
    AW.LoadWidgetPosition(self.nameText, config.position, showIcon and self.icon)
    self.nameText:SetTextColor(unpack(config.color))
    self.nameTextLength = config.length
end

local function CastBar_UpdateDurationText(self, config)
    U.SetFont(self.durationText, config.font)
    AW.LoadWidgetPosition(self.durationText, config.position)
    self.durationText:SetTextColor(unpack(config.color))
    self.durationFormat = config.format
    self.delayedDurationFormat = "|cffff0000%s%.2f|r "..config.format
    self.showDelay = config.showDelay
end

local function CastBar_SetIconShown(self, show)
    if show then
        AW.SetPoint(self.bar, "TOPLEFT", self.gap, "TOPRIGHT")
        AW.SetPoint(self.status, "TOPLEFT", self.gap, "TOPRIGHT")
        self.icon:Show()
        self.gap:Show()
    else
        AW.SetPoint(self.bar, "TOPLEFT", 1, -1)
        AW.SetPoint(self.status, "TOPLEFT", 1, -1)
        self.icon:Hide()
        self.gap:Hide()
    end
end

local function CastBar_UpdateSpark(self, config)
    self.spark:ClearAllPoints()
    self.spark:SetPoint("RIGHT", self.bar:GetStatusBarTexture())
    if config.height == 0 then
        self.spark:SetPoint("TOP")
        self.spark:SetPoint("BOTTOM")
        self.spark:SetPoint("RIGHT", self.bar:GetStatusBarTexture())
    else
        self.spark:SetHeight(config.height)
    end

    AW.SetWidth(self.spark, config.width)
    self.spark:SetTexture(config.texture)
    self.spark:SetVertexColor(unpack(config.color))
end

local function CastBar_UpdateTicks(self, config)
    local class = UnitClassBase(self.root:GetAttribute("unit"))
    if not classMaxTicks[class] then return end

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

    for i = 1, classMaxTicks[class] do
        if not self.ticks[i] then
            self.ticks[i] = self.bar:CreateTexture(nil, "ARTWORK", nil, 1)
            self.ticks[i]:Hide()
        end

        AW.SetWidth(self.ticks[i], config.width)
        self.ticks[i]:SetColorTexture(unpack(config.color))
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
    self.latency:SetColorTexture(unpack(config.color))
end

local function CastBar_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.ReSize(self.gap)
    AW.ReSize(self.spark)
    AW.RePoint(self.bar)
    AW.RePoint(self.status)
    AW.RePoint(self.icon)
    AW.RePoint(self.nameText)
    AW.RePoint(self.durationText)

    if self.ticks then
        for _, tick in pairs(self.ticks) do
            AW.ReSize(tick)
        end
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CastBar_LoadConfig(self, config)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
    AW.SetWidth(self.icon, config.height-2)

    AW.SetFrameLevel(self, config.frameLevel, self.root)

    self:SetTexture(config.texture)
    self:SetBackgroundColor(config.bgColor)
    self:SetBorderColor(config.borderColor)
    self.bar:SetStatusBarColor(unpack(config.colors.normal))
    self.bar.uninterruptible:SetVertexColor(unpack(config.colors.uninterruptible))

    AW.SetFadeInOutAnimationDuration(self, config.fadeDuration)

    self:UpdateNameText(config.nameText, config.showIcon)
    self:UpdateDurationText(config.durationText)
    self:SetIconShown(config.showIcon)
    self:UpdateSpark(config.spark)

    if self.root.hasCastBarTicks then
        self:UpdateTicks(config.ticks)
    end

    if self.root.hasLatency then
        self:UpdateLatency(config.latency)
    end

    self.failedColor = config.colors.failed
    self.succeededColor = config.colors.succeeded
    self.uninterruptibleColor = config.colors.uninterruptible
    self.borderColor = config.borderColor
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateCastBar(parent, name)
    -- frame
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    AW.SetDefaultBackdrop(frame)
    frame:Hide()

    frame.root = parent

    -- events
    BFI.AddEventHandler(frame)

    -- fade out
    AW.CreateFadeInOutAnimation(frame)
    frame.fadeOut.alpha:SetSmoothing("IN")

    -- cast status texture
    local status = frame:CreateTexture(nil, "OVERLAY")
    frame.status = status
    AW.SetOnePixelInside(status, frame)
    status:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AW.SetPoint(icon, "TOPLEFT", 1, -1)
    AW.SetPoint(icon, "BOTTOMLEFT", 1, 1)

    -- gap
    local gap = frame:CreateTexture(nil, "BORDER")
    frame.gap = gap
    gap:SetPoint("TOPLEFT", icon, "TOPRIGHT")
    gap:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT")
    AW.SetWidth(gap, 1)

    -- bar
    local bar = CreateFrame("StatusBar", nil, frame)
    frame.bar = bar
    AW.SetOnePixelInside(bar, frame)
    bar:SetStatusBarTexture(AW.GetTexture("StatusBar"))
    bar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 0)
    AW.SetFrameLevel(bar, 1, frame)

    -- spark
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 2)
    frame.spark = spark
    spark:SetBlendMode("ADD")

    -- uninterruptible texture
    local uninterruptible = bar:CreateTexture(nil, "ARTWORK", nil, 3)
    bar.uninterruptible = uninterruptible
    uninterruptible:SetAllPoints()
    uninterruptible:SetTexture(AW.GetTexture("Uninterruptible1"), "REPEAT", "REPEAT")
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
    AW.SetFrameLevel(overlay, 2, frame)

    -- name
    local nameText = overlay:CreateFontString(nil, "OVERLAY", AW.GetFontName("normal"))
    frame.nameText = nameText

    -- duration
    local durationText = overlay:CreateFontString(nil, "OVERLAY", AW.GetFontName("normal"))
    frame.durationText = durationText

    -- functions
    frame.Update = CastBar_Update
    frame.Enable = CastBar_Enable
    frame.Disable = CastBar_Disable
    frame.SetTexture = CastBar_SetTexture
    frame.SetBorderColor = CastBar_SetBorderColor
    frame.SetBackgroundColor = CastBar_SetBackgroudColor
    frame.UpdateNameText = CastBar_UpdateNameText
    frame.UpdateDurationText = CastBar_UpdateDurationText
    frame.SetIconShown = CastBar_SetIconShown
    frame.UpdateSpark = CastBar_UpdateSpark
    frame.UpdateTicks = CastBar_UpdateTicks
    frame.UpdateLatency = CastBar_UpdateLatency
    frame.SetPipsColor = CastBar_SetPipsColor
    frame.LoadConfig = CastBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, CastBar_UpdatePixels)

    return frame
end