---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.NamePlates
local M = BFI.Misc

local strfind = string.find
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime
local GetUnitEmpowerStageDuration = GetUnitEmpowerStageDuration
local UnitCanAttack = UnitCanAttack

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
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subEvent ~= "SPELL_INTERRUPT" then return end

    sourceName = M.GetPetOwner(sourceGUID) or sourceName

    if destGUID == self.root.guid then
        local shortName = U.ToShortName(sourceName)
        AF.SetText(self.nameText, shortName, self.nameTextLength)
        local class = M.GetPlayerClass(sourceName)
        self.nameText:SetText(AF.GetIconString("Warning") .. AF.WrapTextInColor(self.nameText:GetText(), class))
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
        self.bar:SetColor(AF.UnpackColor(self.uninterruptibleColor))
        self.bar.uninterruptible:Show()
        self:SetBackdropBorderColor(AF.UnpackColor(self.uninterruptibleTextureColor, 1))
        self.iconBG:SetVertexColor(AF.UnpackColor(self.uninterruptibleTextureColor, 1))
    elseif self.checkInterruptCD and (not self.requireInterruptUsable or U.InterruptUsable()) then -- interruptible
        self.bar:SetColor(AF.UnpackColor(self.interruptibleColor))
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AF.UnpackColor(self.interruptibleColor, 1))
        self.iconBG:SetVertexColor(AF.UnpackColor(self.interruptibleColor, 1))
    else -- interrupt cd
        self.bar:SetColor(AF.UnpackColor(self.normalColor))
        self.bar.uninterruptible:Hide()
        self:SetBackdropBorderColor(AF.UnpackColor(self.borderColor))
        self.iconBG:SetVertexColor(AF.UnpackColor(self.borderColor))
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

    self.startTime = startTime / 1000
    self.endTime = endTime / 1000
    self.duration = self.endTime - self.startTime

    if self.castType == "channel" then
        self.current = self.endTime - GetTime()
    else
        self.current = GetTime() - self.startTime
    end

    self.bar:SetBarMinMaxValues(0, self.duration)
    self.bar:SetBarValue(self.current)
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
            self.durationText:SetFormattedText(self.durationFormat, self.duration - self.current)
        else
            self.current = self.current - elapsed
            if self.current <= 0 then
                CastStop(self)
                return
            end
            self.durationText:SetFormattedText(self.durationFormat, self.current)
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
        if UnitCanAttack("player", unit) then
            self.checkInterruptCD = true
        else
            self.checkInterruptCD = nil
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
    self.nameText:SetTextColor(unpack(config.color))
    self.nameTextLength = config.length
    self.showName = config.enabled
    self.showInterruptSource = config.showInterruptSource
end

local function CastBar_SetupDurationText(self, config)
    self.durationText:SetShown(config.enabled)
    AF.SetFont(self.durationText, config.font)
    AF.LoadTextPosition(self.durationText, config.position)
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

    NP.LoadIndicatorPosition(self.iconBG, config.position)
    AF.SetSize(self.iconBG, config.width, config.height)

    self.icon:SetTexCoord(unpack(AF.CalcTexCoordPreCrop(config.width, config.height, 1, 0.12)))
    self.iconBG:SetVertexColor(AF.UnpackColor(self.borderColor))

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
    self.spark:SetVertexColor(unpack(config.color))
end

local function CastBar_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.ReSize(self.spark)
    AF.RePoint(self.bar)
    AF.RePoint(self.status)
    AF.RePoint(self.icon)
    AF.RePoint(self.iconBG)
    AF.RePoint(self.nameText)
    AF.RePoint(self.durationText)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CastBar_LoadConfig(self, config)
    self.normalColor = config.colors.normal
    self.failedColor = config.colors.failed
    self.succeededColor = config.colors.succeeded
    self.interruptibleColor = config.colors.interruptible.value
    self.uninterruptibleColor = config.colors.uninterruptible
    self.uninterruptibleTextureColor = config.colors.uninterruptibleTexture
    self.borderColor = config.borderColor

    self.requireInterruptUsable = config.colors.interruptible.requireInterruptUsable
    self.enableInterruptibleCheck = config.enableInterruptibleCheck

    AF.SetFrameLevel(self, config.frameLevel, self.root)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.width, config.height)

    CastBar_SetTexture(self, config.texture)

    self:SetBackdropColor(AF.UnpackColor(config.bgColor))
    self:SetBackdropBorderColor(AF.UnpackColor(config.borderColor))

    self.bar:SetColor(AF.UnpackColor(config.colors.normal))
    self.bar.uninterruptible:SetVertexColor(unpack(config.colors.uninterruptibleTexture))

    AF.SetFadeInOutAnimationDuration(self, config.fadeDuration)

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

    -- iconBG
    local iconBG = frame:CreateTexture(nil, "BORDER")
    frame.iconBG = iconBG
    iconBG:SetTexture(AF.GetPlainTexture())

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AF.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
    AF.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)

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
    frame.LoadConfig = CastBar_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater(frame, CastBar_UpdatePixels)

    return frame
end