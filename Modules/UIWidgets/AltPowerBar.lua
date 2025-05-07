---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class UIWidgets
local UI = BFI.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local altPowerBar, altPowerBarHolder
local blizzardAltPowerBar = _G.PlayerPowerBarAlt
local ALTERNATE_POWER_INDEX = _G.ALTERNATE_POWER_INDEX
local GetUnitPowerBarInfo = GetUnitPowerBarInfo
local GetUnitPowerBarStrings = GetUnitPowerBarStrings

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local formatter = {
    current = function()
        return altPowerBar.current
    end,
    total = function()
        return altPowerBar.max
    end,
    percent = function()
        return AF.Round(altPowerBar.current / altPowerBar.max * 100) .. "%"
    end,
    name = function()
        return altPowerBar.name
    end
}

local function FormatText(text)
    return string.gsub(text, "%[(%w+)%]", function(s)
        if formatter[s] then
            return formatter[s]()
        else
            return ""
        end
    end)
end

local function UpdateAltPower()
    blizzardAltPowerBar:UnregisterAllEvents()
    blizzardAltPowerBar:Hide()

    local info = GetUnitPowerBarInfo("player")
    if info then
        altPowerBar.name, altPowerBar.tooltip = GetUnitPowerBarStrings("player")
        altPowerBar.current = UnitPower("player", ALTERNATE_POWER_INDEX) or 0
		altPowerBar.max = UnitPowerMax("player", ALTERNATE_POWER_INDEX) or 1

        altPowerBar:SetMinMaxValues(info.minPower, altPowerBar.max)
        altPowerBar:SetBarValue(altPowerBar.current)

        altPowerBar.leftText:SetText(FormatText(altPowerBar.leftFormat))
        altPowerBar.centerText:SetText(FormatText(altPowerBar.centerFormat))
        altPowerBar.rightText:SetText(FormatText(altPowerBar.rightFormat))

        altPowerBar:Show()
    else
        altPowerBar:Hide()
    end
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitAltPowerBar()
    altPowerBarHolder = CreateFrame("Frame", "BFI_AltPowerBarHolder", AF.UIParent)
    AF.CreateMover(altPowerBarHolder, "BFI: " .. L["UI Widgets"], L["Alt Power Bar"])
    AF.AddEventHandler(altPowerBarHolder)

    altPowerBar = AF.CreateSimpleStatusBar(altPowerBarHolder, "BFI_AltPowerBar")
    altPowerBar.loss:Hide()
    altPowerBar:SetAllPoints()

    altPowerBar.leftText = AF.CreateFontString(altPowerBar)
    AF.SetPoint(altPowerBar.leftText, "LEFT", 5, 0)
    altPowerBar.centerText = AF.CreateFontString(altPowerBar)
    AF.SetPoint(altPowerBar.centerText, "CENTER")
    altPowerBar.rightText = AF.CreateFontString(altPowerBar)
    AF.SetPoint(altPowerBar.rightText, "RIGHT", -5, 0)

    -- blizzard
    blizzardAltPowerBar:SetParent(altPowerBarHolder)
    blizzardAltPowerBar:ClearAllPoints()
    blizzardAltPowerBar:SetPoint("CENTER")

    hooksecurefunc(blizzardAltPowerBar, "SetPoint", function(_, _, anchorTo)
        if anchorTo ~= altPowerBarHolder then
            blizzardAltPowerBar:ClearAllPoints()
            blizzardAltPowerBar:SetPoint("CENTER", altPowerBarHolder)
        end
    end)

    blizzardAltPowerBar.statusFrame:Show()
    blizzardAltPowerBar.statusFrame.Hide = blizzardAltPowerBar.statusFrame.Show
end

---------------------------------------------------------------------
-- update config
---------------------------------------------------------------------
local function UpdateAltPowerBar(_, module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "altpower" then return end

    local config = UI.config.altPowerBar

    if not altPowerBarHolder then
        InitAltPowerBar()
    end

    if config.useBlizzardStyle then
        blizzardAltPowerBar:SetScale(config.scale)
        altPowerBarHolder:UnregisterAllEvents()
    else
        -- bar
        altPowerBar:SetTexture(AF.LSM_GetBarTexture(config.texture))
        altPowerBar:SetColor(AF.UnpackColor(config.color))
        altPowerBar:SetBackgroundColor(AF.UnpackColor(config.bgColor))
        altPowerBar:SetBorderColor(AF.UnpackColor(config.borderColor))

        -- text
        AF.SetFont(altPowerBar.leftText, unpack(config.texts.font))
        altPowerBar.leftText:SetTextColor(AF.UnpackColor(config.texts.color))
        AF.SetFont(altPowerBar.centerText, unpack(config.texts.font))
        altPowerBar.centerText:SetTextColor(AF.UnpackColor(config.texts.color))
        AF.SetFont(altPowerBar.rightText, unpack(config.texts.font))
        altPowerBar.rightText:SetTextColor(AF.UnpackColor(config.texts.color))
        altPowerBar.leftFormat = config.texts.leftFormat
        altPowerBar.centerFormat = config.texts.centerFormat
        altPowerBar.rightFormat = config.texts.rightFormat

        -- events
        altPowerBarHolder:RegisterEvent("UNIT_POWER_UPDATE", UpdateAltPower)
        altPowerBarHolder:RegisterEvent("UNIT_POWER_BAR_SHOW", UpdateAltPower)
        altPowerBarHolder:RegisterEvent("UNIT_POWER_BAR_HIDE", UpdateAltPower)
        altPowerBarHolder:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateAltPower)
        UpdateAltPower()
    end

    AF.ClearPoints(altPowerBarHolder)
    AF.LoadPosition(altPowerBarHolder, config.position)
    AF.SetSize(altPowerBarHolder, config.width, config.height)
end
AF.RegisterCallback("BFI_UpdateModules", UpdateAltPowerBar)