---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local C = BFI.modules.Colors
---@type AbstractFramework
local AF = _G.AbstractFramework

local colorsPanel

---------------------------------------------------------------------
-- colors panel
---------------------------------------------------------------------
local function CreateColorsPanel()
    colorsPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_ColorsPanel")
    colorsPanel:SetAllPoints()

    local scroll = AF.CreateScrollGrid(colorsPanel, nil, 15, 15, 2, 2, nil, nil, 30, "none", "none")
    colorsPanel.scroll = scroll
    AF.SetPoint(scroll, "TOPLEFT")
    AF.SetPoint(scroll, "BOTTOMRIGHT")
    scroll.scrollBar:SetBorderColor("border")
end

---------------------------------------------------------------------
-- casts pane
---------------------------------------------------------------------
local castsPane
local function CreateCastsPane()
    castsPane = AF.CreateTitledPane(colorsPanel, L["Casts"])

    local colorPickers = {}

    colorPickers.normal = AF.CreateColorPicker(castsPane, L["Normal"], true)
    AF.SetPoint(colorPickers.normal, "TOPLEFT", 10, -25)

    colorPickers.failed = AF.CreateColorPicker(castsPane, L["Failed"], true)
    AF.SetPoint(colorPickers.failed, "TOPLEFT", colorPickers.normal, "BOTTOMLEFT", 0, -7)

    colorPickers.succeeded = AF.CreateColorPicker(castsPane, L["Succeeded"], true)
    AF.SetPoint(colorPickers.succeeded, "TOPLEFT", colorPickers.failed, "BOTTOMLEFT", 0, -7)

    colorPickers.interruptible = AF.CreateColorPicker(castsPane, L["Interruptible"], true)
    AF.SetPoint(colorPickers.interruptible, "TOPLEFT", colorPickers.succeeded, "BOTTOMLEFT", 0, -7)

    colorPickers.uninterruptible = AF.CreateColorPicker(castsPane, L["Uninterruptible"], true)
    AF.SetPoint(colorPickers.uninterruptible, "TOPLEFT", colorPickers.interruptible, "BOTTOMLEFT", 0, -7)

    colorPickers.uninterruptible_texture = AF.CreateColorPicker(castsPane, L["Uninterruptible Texture"], true)
    AF.SetPoint(colorPickers.uninterruptible_texture, "TOPLEFT", colorPickers.uninterruptible, "BOTTOMLEFT", 0, -7)

    colorPickers.spark = AF.CreateColorPicker(castsPane, L["Spark"], true)
    AF.SetPoint(colorPickers.spark, "TOPLEFT", colorPickers.uninterruptible_texture, "BOTTOMLEFT", 0, -7)

    colorPickers.tick = AF.CreateColorPicker(castsPane, L["Ticks"], true)
    AF.SetPoint(colorPickers.tick, "TOPLEFT", colorPickers.spark, "BOTTOMLEFT", 0, -7)

    colorPickers.latency = AF.CreateColorPicker(castsPane, L["Latency"], true)
    AF.SetPoint(colorPickers.latency, "TOPLEFT", colorPickers.tick, "BOTTOMLEFT", 0, -7)

    for which, picker in pairs(colorPickers) do
        picker:SetOnConfirm(function(r, g, b, a)
            local k = "cast_" .. which
            C.config.casts[k][1] = r
            C.config.casts[k][2] = g
            C.config.casts[k][3] = b
            C.config.casts[k][4] = a
            AF.AddColor(k, C.config.casts[k])
            AF.Fire("BFI_UpdateConfig", "colors", "casts", which)
        end)
    end

    function castsPane.Load()
        colorPickers.normal:SetColor(C.config.casts.cast_normal)
        colorPickers.failed:SetColor(C.config.casts.cast_failed)
        colorPickers.succeeded:SetColor(C.config.casts.cast_succeeded)
        colorPickers.interruptible:SetColor(C.config.casts.cast_interruptible)
        colorPickers.uninterruptible:SetColor(C.config.casts.cast_uninterruptible)
        colorPickers.uninterruptible_texture:SetColor(C.config.casts.cast_uninterruptible_texture)
        colorPickers.spark:SetColor(C.config.casts.cast_spark)
        colorPickers.tick:SetColor(C.config.casts.cast_tick)
        colorPickers.latency:SetColor(C.config.casts.cast_latency)
    end
end

---------------------------------------------------------------------
-- empowered casts
---------------------------------------------------------------------
local empoweredCastsPane
local function CreateEmpoweredCastsPane()
    empoweredCastsPane = AF.CreateTitledPane(colorsPanel, L["Empowered Casts"])

    local colorPickers = {}

    colorPickers.stage1 = AF.CreateColorPicker(empoweredCastsPane, L["Stage 1"])
    AF.SetPoint(colorPickers.stage1, "TOPLEFT", 10, -25)

    colorPickers.stage2 = AF.CreateColorPicker(empoweredCastsPane, L["Stage 2"])
    AF.SetPoint(colorPickers.stage2, "TOPLEFT", colorPickers.stage1, "BOTTOMLEFT", 0, -7)

    colorPickers.stage3 = AF.CreateColorPicker(empoweredCastsPane, L["Stage 3"])
    AF.SetPoint(colorPickers.stage3, "TOPLEFT", colorPickers.stage2, "BOTTOMLEFT", 0, -7)

    colorPickers.stage4 = AF.CreateColorPicker(empoweredCastsPane, L["Stage 4"])
    AF.SetPoint(colorPickers.stage4, "TOPLEFT", colorPickers.stage3, "BOTTOMLEFT", 0, -7)

    for which, picker in pairs(colorPickers) do
        picker:SetOnConfirm(function(r, g, b)
            local k = "empower" .. which
            C.config.empowerStages[k][1] = r
            C.config.empowerStages[k][2] = g
            C.config.empowerStages[k][3] = b
            AF.AddColor(k, C.config.empowerStages[k])
            AF.Fire("BFI_UpdateConfig", "colors", "empowerStages", which)
        end)
    end

    function empoweredCastsPane.Load()
        colorPickers.stage1:SetColor(C.config.empowerStages.empowerstage1)
        colorPickers.stage2:SetColor(C.config.empowerStages.empowerstage2)
        colorPickers.stage3:SetColor(C.config.empowerStages.empowerstage3)
        colorPickers.stage4:SetColor(C.config.empowerStages.empowerstage4)
    end
end

---------------------------------------------------------------------
-- units
---------------------------------------------------------------------
local unitsPane
local function CreateUnitsPane()
    unitsPane = AF.CreateTitledPane(colorsPanel, L["Units"])
    AF.ShowMask(unitsPane, AF.L.WIP_WITH_ICON, 0, 0, 0, 0)

    local friendlyColorPicker = AF.CreateColorPicker(unitsPane, L["Friendly"], true)
    AF.SetPoint(friendlyColorPicker, "TOPLEFT", 10, -25)

    local hostileColorPicker = AF.CreateColorPicker(unitsPane, L["Hostile"], true)
    AF.SetPoint(hostileColorPicker, "TOPLEFT", friendlyColorPicker, "BOTTOMLEFT", 0, -7)

    local neutralColorPicker = AF.CreateColorPicker(unitsPane, L["Neutral"], true)
    AF.SetPoint(neutralColorPicker, "TOPLEFT", hostileColorPicker, "BOTTOMLEFT", 0, -7)

    local offlineColorPicker = AF.CreateColorPicker(unitsPane, L["Offline"], true)
    AF.SetPoint(offlineColorPicker, "TOPLEFT", neutralColorPicker, "BOTTOMLEFT", 0, -7)

    local charmedColorPicker = AF.CreateColorPicker(unitsPane, L["Charmed"], true)
    AF.SetPoint(charmedColorPicker, "TOPLEFT", offlineColorPicker, "BOTTOMLEFT", 0, -7)

    local tapDeniedColorPicker = AF.CreateColorPicker(unitsPane, L["Tap Denied"], true)
    AF.SetPoint(tapDeniedColorPicker, "TOPLEFT", charmedColorPicker, "BOTTOMLEFT", 0, -7)

    function unitsPane.Load()
        friendlyColorPicker:SetColor(C.config.unit.FRIENDLY)
        hostileColorPicker:SetColor(C.config.unit.HOSTILE)
        neutralColorPicker:SetColor(C.config.unit.NEUTRAL)
        offlineColorPicker:SetColor(C.config.unit.OFFLINE)
        charmedColorPicker:SetColor(C.config.unit.CHARMED)
        tapDeniedColorPicker:SetColor(C.config.unit.TAP_DENIED)
    end
end

---------------------------------------------------------------------
-- auras
---------------------------------------------------------------------
local aurasPane
local function CreateAurasPane()
    aurasPane = AF.CreateTitledPane(colorsPanel, L["Auras"])
    AF.ShowMask(aurasPane, AF.L.WIP_WITH_ICON, 0, 0, 0, 0)

    local curseColorPicker = AF.CreateColorPicker(aurasPane, L["Curse"], true)
    AF.SetPoint(curseColorPicker, "TOPLEFT", 10, -25)

    local diseaseColorPicker = AF.CreateColorPicker(aurasPane, L["Disease"], true)
    AF.SetPoint(diseaseColorPicker, "TOPLEFT", curseColorPicker, "BOTTOMLEFT", 0, -7)

    local magicColorPicker = AF.CreateColorPicker(aurasPane, L["Magic"], true)
    AF.SetPoint(magicColorPicker, "TOPLEFT", diseaseColorPicker, "BOTTOMLEFT", 0, -7)

    local poisonColorPicker = AF.CreateColorPicker(aurasPane, L["Poison"], true)
    AF.SetPoint(poisonColorPicker, "TOPLEFT", magicColorPicker, "BOTTOMLEFT", 0, -7)

    local bleedColorPicker = AF.CreateColorPicker(aurasPane, L["Bleed"], true)
    AF.SetPoint(bleedColorPicker, "TOPLEFT", poisonColorPicker, "BOTTOMLEFT", 0, -7)

    local noneColorPicker = AF.CreateColorPicker(aurasPane, _G.NONE, true)
    AF.SetPoint(noneColorPicker, "TOPLEFT", bleedColorPicker, "BOTTOMLEFT", 0, -7)

    local castByMeColorPicker = AF.CreateColorPicker(aurasPane, L["Cast By Me"], true)
    AF.SetPoint(castByMeColorPicker, "TOPLEFT", noneColorPicker, "BOTTOMLEFT", 0, -7)

    local dispellableColorPicker = AF.CreateColorPicker(aurasPane, L["Dispellable"], true)
    AF.SetPoint(dispellableColorPicker, "TOPLEFT", castByMeColorPicker, "BOTTOMLEFT", 0, -7)

    function aurasPane.Load()
        curseColorPicker:SetColor(C.config.auras.aura_curse)
        diseaseColorPicker:SetColor(C.config.auras.aura_disease)
        magicColorPicker:SetColor(C.config.auras.aura_magic)
        poisonColorPicker:SetColor(C.config.auras.aura_poison)
        bleedColorPicker:SetColor(C.config.auras.aura_bleed)
        noneColorPicker:SetColor(C.config.auras.aura_none)
        castByMeColorPicker:SetColor(C.config.auras.aura_castbyme)
        dispellableColorPicker:SetColor(C.config.auras.aura_dispellable)
    end
end

---------------------------------------------------------------------
-- threat
---------------------------------------------------------------------
local threatPane
local function CreateThreatPane()
    threatPane = AF.CreateTitledPane(colorsPanel, L["Threat"])
    AF.ShowMask(threatPane, AF.L.WIP_WITH_ICON, 0, 0, 0, 0)

    local lowColorPicker = AF.CreateColorPicker(threatPane, L["Low"], true)
    AF.SetPoint(lowColorPicker, "TOPLEFT", 10, -25)

    local mediumColorPicker = AF.CreateColorPicker(threatPane, L["Medium"], true)
    AF.SetPoint(mediumColorPicker, "TOPLEFT", lowColorPicker, "BOTTOMLEFT", 0, -7)

    local highColorPicker = AF.CreateColorPicker(threatPane, L["High"], true)
    AF.SetPoint(highColorPicker, "TOPLEFT", mediumColorPicker, "BOTTOMLEFT", 0, -7)

    local offtankColorPicker = AF.CreateColorPicker(threatPane, L["Off Tank"], true)
    AF.SetPoint(offtankColorPicker, "TOPLEFT", highColorPicker, "BOTTOMLEFT", 0, -7)

    function threatPane.Load()
        lowColorPicker:SetColor(C.config.threat.threat_low)
        mediumColorPicker:SetColor(C.config.threat.threat_medium)
        highColorPicker:SetColor(C.config.threat.threat_high)
        offtankColorPicker:SetColor(C.config.threat.threat_offtank)
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function Load()
    castsPane.Load()
    empoweredCastsPane.Load()
    unitsPane.Load()
    aurasPane.Load()
    threatPane.Load()
end

AF.RegisterCallback("BFI_RefreshOptions", function(_, which)
    if which ~= "colors" or not colorsPanel then return end
    Load()
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Colors" then
        if not colorsPanel then
            CreateColorsPanel()
            CreateCastsPane()
            CreateEmpoweredCastsPane()
            CreateUnitsPane()
            CreateAurasPane()
            CreateThreatPane()
            colorsPanel.scroll:SetWidgets({
                castsPane,
                empoweredCastsPane,
                unitsPane,
                aurasPane,
                threatPane,
            })
        end
        Load()
        colorsPanel:Show()
    elseif colorsPanel then
        colorsPanel:Hide()
    end
end)