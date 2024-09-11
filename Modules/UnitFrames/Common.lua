---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
---@class UnitFrames
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- unit frame parent
---------------------------------------------------------------------
UF.Parent = CreateFrame("Frame", "BFIUnitFrameParent", AW.UIParent, "SecureHandlerStateTemplate")
UF.Parent:SetFrameStrata("LOW")
UF.Parent:SetAllPoints(AW.UIParent)
RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")

-- hide during minigame
-- UF.Parent:RegisterEvent("CLIENT_SCENE_OPENED")
-- UF.Parent:RegisterEvent("CLIENT_SCENE_CLOSED")
UF.Parent:SetScript("OnEvent", function(_, event, sceneType)
    if InCombatLockdown() then
        UF.Parent:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    if event == "CLIENT_SCENE_OPENED" then
        UnregisterAttributeDriver(UF.Parent, "state-visibility")
        UF.Parent:Hide()
    elseif event == "CLIENT_SCENE_CLOSED" then
        RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")
    else -- PLAYER_REGEN_ENABLED
        UF.Parent:UnregisterEvent("PLAYER_REGEN_ENABLED")
        RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")
    end
end)


local function UpdateGeneral(module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "general" then return end
    UF.Parent:SetFrameStrata(UF.config.general.frameStrata)
end
BFI.RegisterCallback("UpdateModules", "UF_General", UpdateGeneral)

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
        indicator.enabled = indicatorConfig.enabled
    else
        indicator.enabled = false
    end

    if indicator.enabled then
        if frame:IsVisible() then
            indicator:Enable()
        end
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
        if indicator.DisableConfigMode then
            indicator:DisableConfigMode()
        end

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
            if indicator.Disable then
                indicator:Disable()
            else
                indicator:UnregisterAllEvents()
                indicator:Hide()
            end
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

function UF.LoadIndicatorPosition(self, position, anchorTo, parent)
    if anchorTo == "root" then
        anchorTo = self.root
    elseif anchorTo then
        anchorTo = self.root.indicators[anchorTo]
    end

    if parent then
        if parent == "root" then
            parent = self.root
        else
            parent = self.root.indicators[parent]
        end
        self:SetParent(parent)
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
function UF.SetupUnitFrame(frame, config, indicators)
    -- mover
    AW.UpdateMoverSave(frame, config.general.position)

    -- strata & level
    -- frame:SetFrameStrata(config.general.frameStrata)
    -- frame:SetFrameLevel(config.general.frameLevel)

    -- tooltip
    UF.SetupTooltip(frame, config.general.tooltip)

    -- size & position
    AW.SetSize(frame, config.general.width, config.general.height)
    AW.LoadPosition(frame, config.general.position)

    -- out of range alpha
    frame.oorAlpha = config.general.oorAlpha

    -- color
    AW.StylizeFrame(frame, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.SetupIndicators(frame, indicators, config)
end

---------------------------------------------------------------------
-- setup group
---------------------------------------------------------------------
function UF.SetupUnitGroup(group, config, indicators)
    -- mover
    AW.UpdateMoverSave(group, config.general.position)

    -- position
    AW.LoadPosition(group, config.general.position)

    -- container size
    if config.general.orientation == "top_to_bottom" or config.general.orientation == "bottom_to_top" then
        AW.SetWidth(group, config.general.width)
        AW.SetListHeight(group, #group, config.general.height, config.general.spacing)
    else
        AW.SetHeight(group, config.general.height)
        AW.SetListWidth(group, #group, config.general.width, config.general.spacing)
    end

    -- arrangement & size
    local p, rp, x, y = UF.GetSimplePositionArgs(config)

    local last
    for _, b in ipairs(group) do
        -- size
        AW.SetSize(b, config.general.width, config.general.height)
        -- out of range alpha
        b.oorAlpha = config.general.oorAlpha
        -- tooltip
        UF.SetupTooltip(b, config.general.tooltip)
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
-- header arrangement
---------------------------------------------------------------------
function UF.GetSimplePositionArgs(config)
    local p, rp, x, y, hp
    if config.general.orientation == "bottom_to_top" then
        p = "BOTTOMLEFT"
        rp = "TOPLEFT"
        x = 0
        y = config.general.spacing
        hp = "BOTTOM"
    elseif config.general.orientation == "top_to_bottom" then
        p = "TOPLEFT"
        rp = "BOTTOMLEFT"
        x = 0
        y = -config.general.spacing
        hp = "TOP"
    elseif config.general.orientation == "left_to_right" then
        p = "BOTTOMLEFT"
        rp = "BOTTOMRIGHT"
        x = config.general.spacing
        y = 0
        hp = "LEFT"
    elseif config.general.orientation == "right_to_left" then
        p = "BOTTOMRIGHT"
        rp = "BOTTOMLEFT"
        x = -config.general.spacing
        y = 0
        hp = "RIGHT"
    end
    return p, rp, x, y, hp
end

function UF.GetCombinedPositionArgs(config)
    -- point, relativePoint, headerPoint, columnSpacing, columnAnchorPoint
    local p, rp, x, y, cs, hp, cp
    if config.general.orientation == "bottom_to_top_then_left" then
        p = "BOTTOMRIGHT"
        rp = "TOPRIGHT"
        x = 0
        y = config.general.spacingV
        cs = -config.general.spacingH
        hp = "BOTTOM"
        cp = "RIGHT"
    elseif config.general.orientation == "bottom_to_top_then_right" then
        p = "BOTTOMLEFT"
        rp = "TOPLEFT"
        x = 0
        y = config.general.spacingV
        cs = config.general.spacingH
        hp = "BOTTOM"
        cp = "LEFT"
    elseif config.general.orientation == "top_to_bottom_then_left" then
        p = "TOPTOPRIGHT"
        rp = "BOTTOMRIGHT"
        x = 0
        y = -config.general.spacingV
        cs = -config.general.spacingH
        hp = "TOP"
        cp = "RIGHT"
    elseif config.general.orientation == "top_to_bottom_then_right" then
        p = "TOPLEFT"
        rp = "BOTTOMLEFT"
        x = 0
        y = -config.general.spacingV
        cs = config.general.spacingH
        hp = "TOP"
        cp = "LEFT"
    elseif config.general.orientation == "left_to_right_then_bottom" then
        p = "TOPLEFT"
        rp = "TOPRIGHT"
        x = config.general.spacingH
        y = 0
        cs = -config.general.spacingV
        hp = "LEFT"
        cp = "TOP"
    elseif config.general.orientation == "left_to_right_then_top" then
        p = "BOTTOMLEFT"
        rp = "BOTTOMRIGHT"
        x = config.general.spacingH
        y = 0
        cs = config.general.spacingV
        hp = "LEFT"
        cp = "BOTTOM"
    elseif config.general.orientation == "right_to_left_then_bottom" then
        p = "TOPRIGHT"
        rp = "TOPLEFT"
        x = -config.general.spacingH
        y = 0
        cs = -config.general.spacingV
        hp = "RIGHT"
        cp = "TOP"
    elseif config.general.orientation == "right_to_left_then_top" then
        p = "BOTTOMRIGHT"
        rp = "BOTTOMLEFT"
        x = -config.general.spacingH
        y = 0
        cs = config.general.spacingV
        hp = "RIGHT"
        cp = "BOTTOM"
    end
    return p, rp, x, y, cs, hp, cp
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