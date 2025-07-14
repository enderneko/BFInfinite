---@class BFI
local BFI = select(2, ...)
---@class UnitFrames
local UF = BFI.UnitFrames
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- unit frame parent
---------------------------------------------------------------------
UF.Parent = CreateFrame("Frame", "BFIUnitFrameParent", AF.UIParent, "SecureHandlerStateTemplate")
UF.Parent:SetFrameStrata("LOW")
UF.Parent:SetAllPoints(AF.UIParent)
AF.RegisterCallback("BFI_UpdateModule", function()
    -- NOTE: in case of reload during pet battle
    RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")
    AF.UnregisterCallback("BFI_UpdateModule", "UF_Parent")
end, "low", "UF_Parent")

-- hide during minigame
-- UF.Parent:RegisterEvent("CLIENT_SCENE_OPENED")
-- UF.Parent:SetScript("OnEvent", function()
--     --TODO: show a popup or a text
-- end)

-- NOTE: 无法区分小游戏类型，携带的 Enum.ClientSceneType 似乎不太对劲儿
-- UF.Parent:RegisterEvent("CLIENT_SCENE_CLOSED")
-- UF.Parent:SetScript("OnEvent", function(_, event, sceneType)
--     if InCombatLockdown() then
--         UF.Parent:RegisterEvent("PLAYER_REGEN_ENABLED")
--         return
--     end

--     if event == "CLIENT_SCENE_OPENED" then
--         UnregisterAttributeDriver(UF.Parent, "state-visibility")
--         UF.Parent:Hide()
--     elseif event == "CLIENT_SCENE_CLOSED" then
--         RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")
--     else -- PLAYER_REGEN_ENABLED
--         UF.Parent:UnregisterEvent("PLAYER_REGEN_ENABLED")
--         RegisterAttributeDriver(UF.Parent, "state-visibility", "[petbattle] hide; show")
--     end
-- end)


local function UpdateGeneral(_, module, which)
    if module and module ~= "UnitFrames" then return end
    if which and which ~= "general" then return end
    UF.Parent:SetFrameStrata(UF.config.general.frameStrata)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateGeneral)

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
    for _, v in next, indicators do
        if type(v) == "table" then
            local builder, name = v[1], v[2]
            frame.indicators[name] = builders[builder](frame, frame:GetName().."_"..AF.UpperFirst(name), select(3, unpack(v)))
            frame.indicators[name].indicatorName = name
        else -- string:name
            frame.indicators[v] = builders[v](frame, frame:GetName().."_"..AF.UpperFirst(v))
            frame.indicators[v].indicatorName = v
        end
    end
end

function UF.SetupIndicators(frame, indicators, config)
    for _, v in next, indicators do
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
    for _, indicator in next, frame.indicators do
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
    for _, indicator in next, frame.indicators do
        if indicator.enabled then
            indicator:Update(force)
        end
    end
end

function UF.OnButtonShow(frame)
    for _, indicator in next, frame.indicators do
        if indicator.enabled then
            indicator:Enable()
        end
    end
end

function UF.OnButtonHide(frame)
    for _, indicator in next, frame.indicators do
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
        AF.LoadTextPosition(self, position, anchorTo)
    else
        AF.LoadWidgetPosition(self, position, anchorTo)
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
        AF.Fire("BFI_IncorrectAnchor", self)
    end
end

---------------------------------------------------------------------
-- setup frame
---------------------------------------------------------------------
function UF.SetupUnitFrame(frame, config, indicators)
    -- mover
    AF.UpdateMoverSave(frame, config.general.position)

    -- strata & level
    -- frame:SetFrameStrata(config.general.frameStrata)
    -- frame:SetFrameLevel(config.general.frameLevel)

    -- tooltip
    UF.SetupTooltip(frame, config.general.tooltip)

    -- size & position
    AF.SetSize(frame, config.general.width, config.general.height)
    AF.LoadPosition(frame, config.general.position)

    -- out of range alpha
    frame.oorAlpha = config.general.oorAlpha

    -- color
    AF.ApplyDefaultBackdropWithColors(frame, config.general.bgColor, config.general.borderColor)

    -- indicators
    UF.SetupIndicators(frame, indicators, config)
end

---------------------------------------------------------------------
-- setup group
---------------------------------------------------------------------
function UF.SetupUnitGroup(group, config, indicators)
    -- mover
    AF.UpdateMoverSave(group, config.general.position)

    -- position
    AF.LoadPosition(group, config.general.position)

    -- container size
    if config.general.orientation == "top_to_bottom" or config.general.orientation == "bottom_to_top" then
        AF.SetWidth(group, config.general.width)
        AF.SetListHeight(group, #group, config.general.height, config.general.spacing)
    else
        AF.SetHeight(group, config.general.height)
        AF.SetListWidth(group, #group, config.general.width, config.general.spacing)
    end

    -- arrangement & size
    local p, rp, _, x, y = AF.GetAnchorPoints_Simple("BOTTOMLEFT", config.general.orientation, config.general.spacing)

    local last
    for _, b in ipairs(group) do
        -- size
        AF.SetSize(b, config.general.width, config.general.height)
        -- out of range alpha
        b.oorAlpha = config.general.oorAlpha
        -- tooltip
        UF.SetupTooltip(b, config.general.tooltip)
        -- color
        AF.ApplyDefaultBackdropWithColors(b, config.general.bgColor, config.general.borderColor)
        -- indicators
        UF.SetupIndicators(b, indicators, config)
        -- position
        AF.ClearPoints(b)
        if last then
            AF.SetPoint(b, p, last, rp, x, y)
        else
            AF.SetPoint(b, p)
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