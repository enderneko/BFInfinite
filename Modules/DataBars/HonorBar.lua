---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class DataBars
local DB = BFI.modules.DataBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local honorBar
local HONOR_LEVEL_LABEL = _G.HONOR_LEVEL_LABEL

---------------------------------------------------------------------
-- text
---------------------------------------------------------------------
local formatter = {
    current = function()
        return BreakUpLargeNumbers(honorBar.current)
    end,
    total = function()
        return BreakUpLargeNumbers(honorBar.max)
    end,
    progress = function()
        if honorBar.max == 0 then
            return ""
        else
            return format("%s / %s", BreakUpLargeNumbers(honorBar.current), BreakUpLargeNumbers(honorBar.max))
        end
    end,
    level = function()
        return format(HONOR_LEVEL_LABEL, honorBar.level)
    end,
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

local function ShowText()
    honorBar.textFrame:Show()
end

local function HideText()
    honorBar.textFrame:Hide()
end

local function UpdateTextVisibility(alwaysShow)
    if alwaysShow == true then
        honorBar.textFrame:Show()
        honorBar:SetScript("OnEnter", nil)
        honorBar:SetScript("OnLeave", nil)
    elseif alwaysShow == false then
        honorBar.textFrame:Hide()
        honorBar:SetScript("OnEnter", ShowText)
        honorBar:SetScript("OnLeave", HideText)
    else
        honorBar.textFrame:Hide()
        honorBar:SetScript("OnEnter", nil)
        honorBar:SetScript("OnLeave", nil)
    end
end

---------------------------------------------------------------------
-- update rep
---------------------------------------------------------------------
local function UpdateHonor(self)
    local honor = UnitHonor("player")
    local honorMax = UnitHonorMax("player")
    local honorLevel = UnitHonorLevel("player")

    honorMax = honorMax == 0 and 1 or honorMax

    honorBar:SetMinMaxValues(0, honorMax)
    honorBar:SetBarValue(honor)

    honorBar.current = honor
    honorBar.max = honorMax
    honorBar.level = honorLevel

    if honorBar.textEnabled then
        self.leftText:SetText(FormatText(self.leftFormat))
        self.centerText:SetText(FormatText(self.centerFormat))
        self.rightText:SetText(FormatText(self.rightFormat))
    end
end

local function UpdateHonorVisibility(self)
    -- level check
    if self.hideBelowMaxLevel and not AF.IsMaxLevel() then
        self:RegisterEvent("PLAYER_LEVEL_UP", UpdateHonorVisibility)
        self:UnregisterEvent("HONOR_XP_UPDATE")
        self:Hide()
    else
        self:RegisterEvent("HONOR_XP_UPDATE", UpdateHonor)
        self:UnregisterEvent("PLAYER_LEVEL_UP")
        UpdateHonor(self)
        self:Show()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateHonorBar()
    honorBar = AF.CreateSimpleStatusBar(AF.UIParent, "BFI_HonorBar")
    honorBar.loss:Hide()
    honorBar:Hide()

    AF.CreateMover(honorBar, "BFI: " .. L["Data Bars"], L["Honor Bar"])

    -- text frame
    local textFrame = CreateFrame("Frame", nil, honorBar)
    honorBar.textFrame = textFrame
    textFrame:SetAllPoints()

    -- left text
    local leftText = textFrame:CreateFontString(nil, "OVERLAY")
    honorBar.leftText = leftText

    -- right text
    local centerText = textFrame:CreateFontString(nil, "OVERLAY")
    honorBar.centerText = centerText

    -- right text
    local rightText = textFrame:CreateFontString(nil, "OVERLAY")
    honorBar.rightText = rightText

    -- events
    AF.AddEventHandler(honorBar)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateHonorBar(_, module, which)
    if module and module ~= "dataBars" then return end
    if which and which ~= "honorBar" then return end

    local config = DB.config.honorBar
    if not config.enabled then
        if honorBar then
            honorBar.enabled = false
            honorBar:UnregisterAllEvents()
            honorBar:Hide()
        end
        return
    end

    if not honorBar then
        CreateHonorBar()
    end
    honorBar.enabled = true

    honorBar:RegisterEvent("HONOR_XP_UPDATE", UpdateHonor)
    -- honorBar:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", "player", UpdateHonor)

    AF.UpdateMoverSave(honorBar, config.position)
    AF.LoadPosition(honorBar, config.position)
    AF.SetSize(honorBar, config.width, config.height)

    if config.color.type == "gradient" then
        honorBar:SetGradientColor(nil,
            config.color.startColor[1], config.color.startColor[2], config.color.startColor[3], config.color.startAlpha,
            config.color.endColor[1], config.color.endColor[2], config.color.endColor[3], config.color.endAlpha
        )
    else -- solid
        honorBar:SetColor(config.color.endColor[1], config.color.endColor[2], config.color.endColor[3], config.color.endAlpha)
    end
    honorBar:SetBorderColor(AF.UnpackColor(config.borderColor))
    honorBar:SetBackgroundColor(AF.UnpackColor(config.bgColor))
    honorBar:SetTexture(AF.LSM_GetBarTexture(config.texture))

    -- text
    honorBar.textEnabled = config.texts.enabled
    if config.texts.enabled then
        AF.SetFont(honorBar.leftText, config.texts.font)
        AF.LoadTextPosition(honorBar.leftText, {"LEFT", "LEFT", 5, config.texts.yOffset})
        honorBar.leftFormat = config.texts.leftFormat

        AF.SetFont(honorBar.centerText, config.texts.font)
        AF.LoadTextPosition(honorBar.centerText, {"CENTER", "CENTER", 0, config.texts.yOffset})
        honorBar.centerFormat = config.texts.centerFormat

        AF.SetFont(honorBar.rightText, config.texts.font)
        AF.LoadTextPosition(honorBar.rightText, {"RIGHT", "RIGHT", -5, config.texts.yOffset})
        honorBar.rightFormat = config.texts.rightFormat

        UpdateTextVisibility(config.texts.alwaysShow)
    else
        UpdateTextVisibility()
    end

    honorBar.hideBelowMaxLevel = config.hideBelowMaxLevel
    UpdateHonorVisibility(honorBar)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateHonorBar)