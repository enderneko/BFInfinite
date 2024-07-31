---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.M_NamePlates
local M = BFI.M_Misc

local strfind = string.find
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime
local GetUnitEmpowerStageDuration = GetUnitEmpowerStageDuration

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
        local duration = GetUnitEmpowerStageDuration(self.root.unit, stage - 1)
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
            local nextDuration = GetUnitEmpowerStageDuration(self.root.unit, stage)
            pip:SetWidth(nextDuration / self.duration * width)
        end

        pip:Show()
    end

    for i = numStages + 1, #self.pips do
        self.pips[i]:Hide()
    end
end

---------------------------------------------------------------------
-- interrupt source
---------------------------------------------------------------------
local function UpdateInterrupt(self)
    local _, subEvent, _, _, sourceName, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subEvent ~= "SPELL_INTERRUPT" then return end

    if destGUID == self.root.guid then
        local shortName = U.ToShortName(sourceName)
        AW.SetText(self.nameText, shortName, self.nameTextLength)
        local class = M.GetPlayerClass(sourceName)
        self.nameText:SetText(AW.GetIconString("Warning", true) .. AW.WrapTextInColor(self.nameText:GetText(), class))
    end
end

---------------------------------------------------------------------
-- interruptible
---------------------------------------------------------------------
local function CastInterruptible(self, event, unit)
    if unit and unit ~= self.root.unit then return end

    if event then
        self.notInterruptible = event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    end

    if self.notInterruptible then
        self.bar.uninterruptible:Show()
        self:SetBackdropBorderColor(AW.UnpackColor(self.uninterruptibleColor, 1))
        self.iconBG:SetVertexColor(AW.UnpackColor(self.uninterruptibleColor, 1))
    else
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AW.UnpackColor(self.borderColor))
        self.iconBG:SetVertexColor(AW.UnpackColor(self.borderColor))
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
    if unit and unit ~= self.root.unit then return end

    if self.castGUID ~= castGUID or self.castSpellID ~= castSpellID then return end

    Reset(self)
    ShowOverlay(self, true)
    self.durationText:Hide()
    self:FadeOut()
end

local function CastStop(self, event, unit, castGUID, castSpellID, empowerComplete)
    if unit and unit ~= self.root.unit then return end

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
    local unit = self.root.unit
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

    if self.castType == "channel" then
        self.current = endTime - GetTime() * 1000
    else
        self.current = GetTime() * 1000 - startTime
    end

    self.duration = endTime - startTime
    self.startTime = startTime

    self.bar:SetMinMaxValues(0, self.duration)
    self.bar:SetValue(self.current)
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
            self.durationText:SetFormattedText(self.durationFormat, (self.duration - self.current) / 1000)
        else
            self.current = self.current - elapsed * 1000
            if self.current <= 0 then
                CastStop(self)
                return
            end
            self.durationText:SetFormattedText(self.durationFormat, self.current / 1000)
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
    local unit = self.root.unit
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

    if self.showDuration then
        self.durationText:Show()
    end
    if self.showName then
        AW.SetText(self.nameText, name, self.nameTextLength)
    end
    self.status:Hide()
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

    -- interrupt source
    if self.showName and self.showInterruptSource then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", UpdateInterrupt)
    else
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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
local function CastBar_SetTexture(self, texture)
    texture = U.GetBarTexture(texture)
    self.texture = texture
    self.bar:SetStatusBarTexture(texture)
    self.status:SetTexture(texture)
    for _, pip in pairs(self.pips) do
        pip.texture:SetTexture(texture)
    end
end

local function CastBar_SetupNameText(self, config, showIcon)
    self.nameText:SetShown(config.enabled)
    U.SetFont(self.nameText, config.font)
    AW.LoadTextPosition(self.nameText, config.position, showIcon and self.icon, true)
    self.nameText:SetTextColor(unpack(config.color))
    self.nameTextLength = config.length
    self.showName = config.enabled
    self.showInterruptSource = config.showInterruptSource
end

local function CastBar_SetupDurationText(self, config)
    self.durationText:SetShown(config.enabled)
    U.SetFont(self.durationText, config.font)
    AW.LoadTextPosition(self.durationText, config.position, nil, true)
    self.durationText:SetTextColor(unpack(config.color))
    self.durationFormat = config.format
    self.showDuration = config.enabled
end

local function CastBar_SetupIcon(self, config)
    if not config.enabled then
        self.icon:Hide()
        self.iconBG:Hide()
        return
    end

    AW.LoadWidgetPosition(self.iconBG, config.position)
    AW.SetSize(self.iconBG, config.width, config.height)

    self.icon:SetTexCoord(unpack(AW.CalcTexCoord(config.width, config.height, true)))
    self.iconBG:SetVertexColor(AW.UnpackColor(self.borderColor))

    self.icon:Show()
    self.iconBG:Show()
end

local function CastBar_SetupSpark(self, config)
    if not config.enabled then
        self.spark:Hide()
        return
    end

    self.spark:Show()

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

local function CastBar_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.ReSize(self.spark)
    AW.RePoint(self.bar)
    AW.RePoint(self.status)
    AW.RePoint(self.icon)
    AW.RePoint(self.iconBG)
    AW.RePoint(self.nameText)
    AW.RePoint(self.durationText)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CastBar_LoadConfig(self, config)
    self.failedColor = config.colors.failed
    self.succeededColor = config.colors.succeeded
    self.uninterruptibleColor = config.colors.uninterruptible
    self.borderColor = config.borderColor

    AW.SetFrameLevel(self, config.frameLevel, self.root)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)

    CastBar_SetTexture(self, config.texture)

    self:SetBackdropColor(AW.UnpackColor(config.bgColor))
    self:SetBackdropBorderColor(AW.UnpackColor(config.borderColor))

    self.bar:SetStatusBarColor(unpack(config.colors.normal))
    self.bar.uninterruptible:SetVertexColor(unpack(config.colors.uninterruptible))

    AW.SetFadeInOutAnimationDuration(self, config.fadeDuration)

    CastBar_SetupNameText(self, config.nameText, config.showIcon)
    CastBar_SetupDurationText(self, config.durationText)
    CastBar_SetupIcon(self, config.icon)
    CastBar_SetupSpark(self, config.spark)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
-- bar layers
-- pipTexture: -2
-- latency: -1, 1
-- bar: 0
-- pipBound: 1
-- spark: 3
-- uninterruptible: 4

function NP.CreateCastBar(parent, name)
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

    -- iconBG
    local iconBG = frame:CreateTexture(nil, "BORDER")
    frame.iconBG = iconBG
    iconBG:SetTexture(AW.GetPlainTexture())

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AW.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
    AW.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)

    -- bar
    local bar = CreateFrame("StatusBar", nil, frame)
    frame.bar = bar
    AW.SetOnePixelInside(bar, frame)
    bar:SetStatusBarTexture(AW.GetTexture("StatusBar"))
    bar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 0)
    AW.SetFrameLevel(bar, 1, frame)

    -- spark
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 3)
    frame.spark = spark
    spark:SetBlendMode("ADD")

    -- uninterruptible texture
    local uninterruptible = bar:CreateTexture(nil, "ARTWORK", nil, 4)
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
    frame.LoadConfig = CastBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, CastBar_UpdatePixels)

    return frame
end