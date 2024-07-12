local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local C = BFI.M_C
local UF = BFI.M_UF

---------------------------------------------------------------------
-- recalc texcoords
---------------------------------------------------------------------
local function ReCalcTexCoord(self, width, height)
    self.icon:SetTexCoord(unpack(AW.CalcTexCoord(width, height, true)))
end

---------------------------------------------------------------------
-- cooldown style: vertical progress
---------------------------------------------------------------------
local function VerticalCooldown_OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.1 then
        self:SetValue(self:GetValue() + self.elapsed)
        self.elapsed = 0
    end
end

-- for LCG.ButtonGlow_Start
local function VerticalCooldown_GetCooldownDuration()
    return 0
end

local function VerticalCooldown_ShowCooldown(self, start, duration, _, icon, auraType )
    if auraType then
        self.spark:SetColorTexture(C.GetAuraTypeColor(auraType))
    else
        self.spark:SetColorTexture(0.5, 0.5, 0.5, 1)
    end
    self.icon:SetTexture(icon)

    self.elapsed = 0.1 -- update immediately
    self:SetMinMaxValues(0, duration)
    self:SetValue(GetTime() - start)
    self:Show()
end

local function CreateCooldown_Vertical(self)
    local cooldown = CreateFrame("StatusBar", nil, self)
    self.cooldown = cooldown
    cooldown:Hide()

    cooldown.GetCooldownDuration = VerticalCooldown_GetCooldownDuration
    cooldown.ShowCooldown = VerticalCooldown_ShowCooldown
    cooldown:SetScript("OnUpdate", VerticalCooldown_OnUpdate)

    AW.SetPoint(cooldown, "TOPLEFT", self.icon)
    AW.SetPoint(cooldown, "BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", 0, 1)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    cooldown:SetStatusBarTexture(AW.GetPlainTexture())

    local texture = cooldown:GetStatusBarTexture()
    texture:SetAlpha(0)

    local spark = cooldown:CreateTexture(nil, "BORDER")
    cooldown.spark = spark
    AW.SetHeight(spark, 1)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", texture, "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", texture, "BOTTOMRIGHT")

    local mask = cooldown:CreateMaskTexture()
    mask:SetTexture(AW.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT", texture)

    local icon = cooldown:CreateTexture(nil, "ARTWORK")
    cooldown.icon = icon
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    icon:SetDesaturated(true)
    icon:SetAllPoints(self.icon)
    icon:SetVertexColor(0.5, 0.5, 0.5, 1)
    icon:AddMaskTexture(mask)
    cooldown:SetScript("OnSizeChanged", ReCalcTexCoord)
end

---------------------------------------------------------------------
-- cooldown style: clock (w/ or w/o leading edge)
---------------------------------------------------------------------
local function CreateCooldown_Clock(self, drawEdge)
    local cooldown = CreateFrame("Cooldown", nil, self, "BFICooldownFrameTemplate")
    self.cooldown = cooldown
    cooldown:Hide()

    cooldown:SetAllPoints(self.icon)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(drawEdge)

    -- NOTE: shit, why this EDGE not work, but xml does?
    -- cooldown:SetSwipeTexture(AW.GetPlainTexture())
    -- cooldown:SetSwipeColor(0, 0, 0, 0.8)
    -- cooldown:SetEdgeTexture([[Interface\Cooldown\UI-HUD-ActionBar-SecondaryCooldown]])

    -- cooldown text
    cooldown:SetHideCountdownNumbers(true)
    -- disable omnicc
    cooldown.noCooldownCount = true
    -- prevent some dirty addons from adding cooldown text
    cooldown.ShowCooldown = cooldown.SetCooldown
    cooldown.SetCooldown = nil
end

local function Aura_SetCooldownStyle(self, style)
    if self.style == style then return end

    if self.cooldown then
        self.cooldown:SetParent(nil)
        self.cooldown:Hide()
    end

    self.style = style
    if style == "vertical_progress" then
        CreateCooldown_Vertical(self)
    elseif strfind(style, "^clock") then
        CreateCooldown_Clock(self, strfind(style, "edge$") and true or false)
    end
end

---------------------------------------------------------------------
-- SetCooldown
---------------------------------------------------------------------
local function UpdateDuration(self, elapsed)
    self._elapsed = self._elapsed + elapsed

    self._remain = self._duration - (GetTime() - self._start)
    if self._remain < 0 then self._remain = 0 end

    if self._elapsed >= 0.1 then
        self._elapsed = 0
        -- color
        if self.durationColor[3][1] and self._remain < self.durationColor[3][2] then
            self.duration:SetTextColor(AW.UnpackColor(self.durationColor[3][3]))
        elseif self.durationColor[2][1] and self._remain < (self.durationColor[2][2] * self._duration) then
            self.duration:SetTextColor(AW.UnpackColor(self.durationColor[2][3]))
        else
            self.duration:SetTextColor(AW.UnpackColor(self.durationColor[1]))
        end
    end

    -- format
    if self._remain > 60 then
        self.duration:SetFormattedText("%dm", self._remain / 60)
    elseif self._remain < 5 then
        self.duration:SetFormattedText("%.1f", self._remain)
    else
        self.duration:SetFormattedText("%d", self._remain)
    end
end

local function Aura_SetCooldown(self, start, duration, count, icon, auraType, desaturated)
    if duration == 0 then
        if self.cooldown then self.cooldown:Hide() end
        self.duration:SetText("")
        self.stack:SetParent(self)
        self:SetScript("OnUpdate", nil)
        self._start = nil
        self._duration = nil
        self._remain = nil
        self._elapsed = nil
    else
        if self.cooldown then
            -- NOTE: the "nil" is to make it compatible with Cooldown:SetCooldown(start, duration [, modRate])
            self.cooldown:ShowCooldown(start, duration, nil, icon, auraType)
            self.duration:SetParent(self.cooldown)
            self.stack:SetParent(self.cooldown)
        else
            self.duration:SetParent(self)
            self.stack:SetParent(self)
        end
        self._start = start
        self._duration = duration
        self._elapsed = 0.1
        self:SetScript("OnUpdate", UpdateDuration)
    end

    self:SetDesaturated(desaturated)
    self:SetBackdropBorderColor(C.GetAuraTypeColor(auraType))
    self.stack:SetText((count == 0 or count == 1) and "" or count)
    self.icon:SetTexture(icon)
    self:Show()
end

---------------------------------------------------------------------
-- ShowTooltips
---------------------------------------------------------------------
local function Aura_SetTooltipPosition(self)
    if self.tooltipAnchorTo == "self" then
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(self.tooltipPosition[1], self, self.tooltipPosition[2], self.tooltipPosition[3], self.tooltipPosition[4])
    else -- default
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
    end
end

local function Aura_ShowBuffTooltip(self)
    Aura_SetTooltipPosition(self)
    GameTooltip:SetUnitBuffByAuraInstanceID(self.root.unit, self.auraInstanceID)
    end

local function Aura_ShowDebuffTooltip(self)
    Aura_SetTooltipPosition(self)
    GameTooltip:SetUnitDebuffByAuraInstanceID(self.root.unit, self.auraInstanceID)
end

local function Aura_HideTooltips()
    GameTooltip:Hide()
end

local function Aura_EnableTooltip(self, config, helpful)
    if config.enabled then
        self.tooltipAnchorTo = config.anchorTo
        self.tooltipPosition = config.position
        self:SetScript("OnEnter", helpful and Aura_ShowBuffTooltip or Aura_ShowDebuffTooltip)
        self:SetScript("OnLeave", Aura_HideTooltips)
    else
        self.tooltipAnchorTo = nil
        self.tooltipPosition = nil
        self:SetScript("OnEnter", nil)
        self:SetScript("OnLeave", nil)
    end
end

---------------------------------------------------------------------
-- desaturated
---------------------------------------------------------------------
local function Aura_SetDesaturated(self, desaturated)
    self.icon:SetDesaturated(desaturated)
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function Aura_SetupStackText(self, config)
    self.stack:SetShown(config.enabled)
    AW.LoadWidgetPosition(self.stack, config.position, self)
    U.SetFont(self.stack, unpack(config.font))
    self.stack:SetTextColor(unpack(config.color))
end

local function Aura_SetupDurationText(self, config)
    self.duration:SetShown(config.enabled)
    AW.LoadWidgetPosition(self.duration, config.position, self)
    U.SetFont(self.duration, unpack(config.font))
    self.durationColor = config.color
end

local function Aura_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.RePoint(self.icon)
    if self.cooldown then
        AW.RePoint(self.cooldown)
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateAura(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:Hide()

    AW.SetDefaultBackdrop(frame)

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AW.SetOnePixelInside(icon, frame)
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    frame:SetScript("OnSizeChanged", ReCalcTexCoord)

    -- stack text
    local stack = frame:CreateFontString(nil, "OVERLAY")
    frame.stack = stack

    -- duration text
    local duration = frame:CreateFontString(nil, "OVERLAY")
    frame.duration = duration

    -- functions
    frame.SetCooldown = Aura_SetCooldown
    frame.SetCooldownStyle = Aura_SetCooldownStyle
    frame.SetupStackText = Aura_SetupStackText
    frame.SetupDurationText = Aura_SetupDurationText
    frame.SetDesaturated = Aura_SetDesaturated
    frame.EnableTooltip = Aura_EnableTooltip

    -- pixels
    -- AW.AddToPixelUpdater(frame, Aura_UpdatePixels)
    frame.UpdatePixels = Aura_UpdatePixels

    return frame
end