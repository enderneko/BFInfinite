local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local strfind = string.find
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

---------------------------------------------------------------------
-- reset
---------------------------------------------------------------------
local function Reset(self)
    self.castType = nil
    self.castGUID = nil
    self.castSpellID = nil
    self.notInterruptible = nil
    self.resetDelay = nil
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

local function CastStop(self, event, unit, castGUID, castSpellID)
    if unit and unit ~= self.root.displayedUnit then return end

    if event then
        if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            if self.castSpellID ~= castSpellID then return end
            Reset(self)
            self.bar:Hide()
        else
            if self.castGUID ~= castGUID or self.castSpellID ~= castSpellID then return end
            -- NOTE:
            -- normally, CAST_INTERRUPTED fires before CAST_STOP
            -- but if ESC a spell, CAST_INTERRUPTED fires AFTER CAST_STOP
            self.resetDelay = 0.2
            ShowOverlay(self)
        end

    else
        Reset(self)
        if self.castType == "channel" then
            self.bar:Hide()
        else
            ShowOverlay(self)
        end
    end

    self.durationText:Hide()
    self:FadeOut()
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

    -- curent progress
    if self.castType == "cast" then
        self.current = GetTime() * 1000 - startTime
    else
        self.current = endTime - GetTime() * 1000
    end
    self.duration = endTime - startTime

    -- interruptible
    self.notInterruptible = notInterruptible
    if unit ~= "player" then
        CastInterruptible(self)
    end

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

    -- stop (succeeded)
    self:RegisterEvent("UNIT_SPELLCAST_STOP", CastStop)
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", CastStop)
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", CastStop)

    -- interrupted
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", CastFail)

    -- interruptible
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", CastInterruptible)
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", CastInterruptible)

    -- onupdate
    self:SetScript("OnUpdate", OnUpdate)

    self:Update()
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function CastBar_Disable(self)
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

local function CastBar_SetTexture(self, texture)
    texture = U.GetBarTexture(texture)
    self.bar:SetStatusBarTexture(texture)
    self.status:SetTexture(texture)
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

local function CastBar_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.ReSize(self.gap)
    AW.RePoint(self.bar)
    AW.RePoint(self.name)
    AW.RePoint(self.status)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CastBar_LoadConfig(self, config)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
    AW.SetWidth(self.icon, config.height)

    self:SetFrameLevel(self.root:GetFrameLevel() + config.frameLevel)
    self.overlay:SetFrameLevel(self:GetFrameLevel() + 1)

    self:SetTexture(config.texture)
    self:SetBackgroundColor(config.bgColor)
    self:SetBorderColor(config.borderColor)
    self.bar:SetStatusBarColor(unpack(config.colors.normal))
    self.bar.uninterruptible:SetVertexColor(unpack(config.colors.uninterruptible))

    AW.SetFadeInOutAnimationDuration(self, config.fadeDuration)

    self:UpdateNameText(config.nameText, config.showIcon)
    self:UpdateDurationText(config.durationText)

    self:SetIconShown(config.showIcon)

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

    -- spark
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    bar.spark = spark
    spark:SetPoint("RIGHT", bar:GetStatusBarTexture())
    spark:SetPoint("TOP")
    spark:SetPoint("BOTTOM")
    spark:SetTexture(AW.GetPlainTexture())
    spark:SetVertexColor(0.9, 0.9, 0.9, 0.6)
    spark:SetBlendMode("ADD")
    AW.SetWidth(spark, 2)

    -- uninterruptible texture
    local uninterruptible = bar:CreateTexture(nil, "ARTWORK", nil, 2)
    bar.uninterruptible = uninterruptible
    uninterruptible:SetAllPoints()
    uninterruptible:SetTexture(AW.GetTexture("Uninterruptible1"), "REPEAT", "REPEAT")
    uninterruptible:SetHorizTile(true)
    uninterruptible:SetVertTile(true)
    uninterruptible:Hide()

    -- overlay
    local overlay = CreateFrame("Frame", nil, frame)
    frame.overlay = overlay
    overlay:SetAllPoints()

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
    frame.LoadConfig = CastBar_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, CastBar_UpdatePixels)

    return frame
end