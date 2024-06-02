local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local C = BFI.M_C
local UF = BFI.M_UF

---------------------------------------------------------------------
-- cooldown style
---------------------------------------------------------------------
-- vertical progress
local function CreateCooldown_Vertical(self)

end

-- clock (w/ or w/o leading edge)
local function CreateCooldown_Clock(self, drawEdge)
    local cooldown = CreateFrame("Cooldown", nil, self, "BFICooldownFrameTemplate")
    self.cooldown = cooldown

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
        CreateCooldown_Clock(self)
    elseif strfind(style, "^clock") then
        CreateCooldown_Clock(self, strfind(style, "edge$") and true or false)
    end
end

---------------------------------------------------------------------
-- SetCooldown
---------------------------------------------------------------------
local function UpdateDuration(self, elapsed)
    self._elapsed = self._elapsed + elapsed
    if self._elapsed >= 0.1 then
        self._elapsed = 0

        self._remain = self._duration - (GetTime() - self._start)
        if self._remain < 0 then self._remain = 0 end

        -- color
        if self._remain < self.durationColor[3][1] then
            self.duration:SetTextColor(AW.UnpackColor(self.durationColor[3][2]))
        elseif self._remain < (self.durationColor[2][1] * self._duration) then
            self.duration:SetTextColor(AW.UnpackColor(self.durationColor[2][2]))
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

local function Aura_SetCooldown(self, start, duration, auraType, icon, count)
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
            self.cooldown:ShowCooldown(start, duration)
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

    self:SetBackdropBorderColor(C.GetAuraTypeColor(auraType))
    self.stack:SetText((count == 0 or count == 1) and "" or count)
    self.icon:SetTexture(icon)
    self:Show()
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
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateAura(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:Hide()

    AW.SetDefaultBackdrop(frame)

    -- TODO: cooldown

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AW.SetOnePixelInside(icon, frame)
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)

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

    -- pixels
    -- AW.AddToPixelUpdater(frame, Aura_UpdatePixels)
    frame.UpdatePixels = Aura_UpdatePixels

    return frame
end