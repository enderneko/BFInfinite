---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class UnitFrame
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- indicator
---------------------------------------------------------------------
local builders = {
    healthBar = UF.CreateHealthBar,
    powerBar = UF.CreatePowerBar,
    extraManaBar = UF.CreateExtraManaBar,
    classPowerBar = UF.CreateClassPowerBar,
    staggerBar = UF.CreateStaggerBar,
    nameText = UF.CreateNameText,
    healthText = UF.CreateHealthText,
    powerText = UF.CreatePowerText,
    levelText = UF.CreateLevelText,
    targetCounter = UF.CreateTargetCounter,
    portrait = UF.CreatePortrait,
    castBar = UF.CreateCastBar,
    combatIcon = UF.CreateCombatIcon,
    leaderIcon = UF.CreateLeaderIcon,
    leaderText = UF.CreateLeaderText,
    rangeText = UF.CreateRangeText,
    statusTimer = UF.CreateStatusTimer,
    statusIcon = UF.CreateStatusIcon,
    raidIcon = UF.CreateRaidIcon,
    readyCheckIcon = UF.CreateReadyCheckIcon,
    roleIcon = UF.CreateRoleIcon,
    factionIcon = UF.CreateFactionIcon,
    restingIndicator = UF.CreateRestingIndicator,
    targetHighlight = UF.CreateTargetHighlight,
    mouseoverHighlight = UF.CreateMouseoverHighlight,
    threatGlow = UF.CreateThreatGlow,
    incDmgHealText = UF.CreateIncDmgHealText,
    auras = UF.CreateAuras,
}

function UF.CreateIndicators(frame, indicators)
    for _, v in pairs(indicators) do
        if type(v) == "table" then
            local builder, name = v[1], v[2]
            frame.indicators[name] = builders[builder](frame, frame:GetName().."_"..U.UpperFirst(name), select(3, unpack(v)))
            frame.indicators[name].indicatorName = name
        else -- string:name
            frame.indicators[v] = builders[v](frame, frame:GetName().."_"..U.UpperFirst(v))
            frame.indicators[v].indicatorName = v
        end
    end
end

function UF.SetupIndicators(frame, indicators, config)
    for _, v in pairs(indicators) do
        local name
        if type(v) == "table" then
            name = v[2]
        else
            name = v
        end
        UF.LoadIndicatorConfig(frame, name, config.indicators[name])
    end
end

function UF.LoadIndicatorConfig(frame, indicatorName, indicatorConfig)
    local indicator = frame.indicators[indicatorName]

    if indicatorConfig then
        indicator:LoadConfig(indicatorConfig)
    end

    indicator.enabled = indicatorConfig and indicatorConfig.enabled

    if indicator.enabled then
        indicator:Enable()
        -- NOTE: let each indicator handle this
        -- if frame:IsVisible() then
        --     indicator:Update()
        -- end
    else
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
        end
    end
end

function UF.DisableIndicators(frame)
    for _, indicator in pairs(frame.indicators) do
        if indicator.Disable then
            indicator:Disable()
        else
            indicator:UnregisterAllEvents()
            indicator:Hide()
        end
    end
end

function UF.UpdateIndicators(frame, force)
    for _, indicator in pairs(frame.indicators) do
        if indicator.enabled then
            indicator:Update(force)
        end
    end
end

function UF.OnButtonShow(frame)
    for _, indicator in pairs(frame.indicators) do
        if indicator.enabled then
            indicator:Enable()
        end
    end
end

function UF.OnButtonHide(frame)
    for _, indicator in pairs(frame.indicators) do
        if indicator.enabled then
            indicator:UnregisterAllEvents()
        end
    end
end


local function LoadPosition(self, position, anchorTo)
    if self:GetObjectType() == "FontString" then
        AW.LoadTextPosition(self, position, anchorTo)
    else
        AW.LoadWidgetPosition(self, position, anchorTo)
    end
end

function UF.LoadIndicatorPosition(self, position, anchorTo)
    if anchorTo == "root" then
        anchorTo = self.root
    elseif anchorTo then
        anchorTo = self.root.indicators[anchorTo]
    end

    local success = pcall(LoadPosition, self, position, anchorTo)
    if not success then
        -- Cannot anchor to itself
        -- Cannot anchor to a region dependent on it
        BFI.Fire("IncorrectAnchor", self)
    end
end

---------------------------------------------------------------------
-- setup frame
---------------------------------------------------------------------
function UF.SetupUnitFrame(self, config, indicators)
    -- mover
    AW.UpdateMoverSave(self, config.general.position)

    -- strata & level
    self:SetFrameStrata(config.general.frameStrata)
    self:SetFrameLevel(config.general.frameLevel)

    -- tooltip
    UF.SetupTooltip(self, config.general.tooltip)

    -- size & position
    AW.SetSize(self, config.general.width, config.general.height)
    AW.LoadPosition(self, config.general.position)

    -- out of range alpha
    self.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(self, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.SetupIndicators(self, indicators, config)
end

---------------------------------------------------------------------
-- setup group
---------------------------------------------------------------------
function UF.SetupUnitGroup(self, config, indicators)
    -- strata & level
    self:SetFrameStrata(config.general.frameStrata)
    self:SetFrameLevel(config.general.frameLevel)

    -- position
    AW.LoadPosition(self, config.general.position)

    -- arrangement & size
    local p, rp, x, y
    if config.general.orientation == "bottom_to_top" then
        p = "BOTTOMLEFT"
        rp = "TOPLEFT"
        x = 0
        y = config.general.spacing
        AW.SetWidth(self, config.general.width)
        AW.SetListHeight(self, 4, config.general.height, config.general.spacing)
    elseif config.general.orientation == "top_to_bottom" then
        p = "TOPLEFT"
        rp = "BOTTOMLEFT"
        x = 0
        y = -config.general.spacing
    elseif config.general.orientation == "left_to_right" then
        p = "BOTTOMLEFT"
        rp = "BOTTOMRIGHT"
        x = config.general.spacing
        y = 0
    elseif config.general.orientation == "right_to_left" then
        p = "BOTTOMRIGHT"
        rp = "BOTTOMLEFT"
        x = -config.general.spacing
        y = 0
    end

    local last
    for _, b in ipairs(self) do
        -- size
        AW.SetSize(b, config.general.width, config.general.height)

        -- indicators
        UF.CreateIndicators(b, indicators)

        -- out of range alpha
        b.oorAlpha = config.general.oorAlpha

        -- tooltip
        UF.SetupTooltip(b, config.general.tooltip)

        -- out of range alpha
        b.oorAlpha = config.general.oorAlpha

        -- color
        AW.StylizeFrame(b, config.general.bgColor, config.general.borderColor)

        -- indicators
        UF.SetupIndicators(b, indicators, config)

        -- position
        AW.ClearPoints(b)
        if last then
            AW.SetPoint(b, p, last, rp, x, y)
        else
            AW.SetPoint(b, p)
        end
        last = b
    end
end

---------------------------------------------------------------------
-- setup tooltip
---------------------------------------------------------------------
function UF.SetupTooltip(self, config)
    if config.enabled then
        self.tooltipEnabled = true
        self.tooltipAnchorTo = config.anchorTo
        self.tooltipPosition = config.position
    else
        self.tooltipEnabled = nil
        self.tooltipAnchorTo = nil
        self.tooltipPosition = nil
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local inConfigMode = {}

function UF.AddToConfigMode(frame)
    inConfigMode[frame] = true
end

function UF.RemoveFromConfigMode(frame)
    inConfigMode[frame] = nil
end

local EnableConfigMode, DisableConfigMode

function EnableConfigMode()
    UF.configModeEnabled = true
    UF:RegisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
    for frame in pairs(inConfigMode) do
        UnregisterUnitWatch(frame)
        frame.oldUnit = frame.unit
        frame:SetAttribute("unit", "player")
        RegisterUnitWatch(frame)
    end
end

function DisableConfigMode()
    UF.configModeEnabled = nil
    UF:UnregisterEvent("PLAYER_REGEN_DISABLED", DisableConfigMode)
    for frame in pairs(inConfigMode) do
        UnregisterUnitWatch(frame)
        frame:SetAttribute("unit", frame.oldUnit)
        frame.oldUnit = nil
        RegisterUnitWatch(frame)
    end
end

local function ToggleConfigMode(module)
    if InCombatLockdown() then return end
    if module and module ~= "UnitFrames" then return end
    if UF.configModeEnabled then
        DisableConfigMode()
    else
        EnableConfigMode()
    end
end
BFI.RegisterCallback("ConfigMode", "UnitFrames", ToggleConfigMode)