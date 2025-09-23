---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local ReloadUI = _G.ReloadUI

local moduleResetFrame

---------------------------------------------------------------------
-- resetter
---------------------------------------------------------------------
local function ResetCommonModule(moduleKey)
    BFI.modules[F.GetModuleClassName(moduleKey)].ResetToDefaults()
    AF.Fire("BFI_UpdateConfig", moduleKey)
    AF.Fire("BFI_RefreshOptions", moduleKey)
end

local function ResetProfileModule(moduleKey)
    BFI.modules[F.GetModuleClassName(moduleKey)].ResetToDefaults()
    AF.Fire("BFI_UpdateModule", moduleKey)
    AF.Fire("BFI_RefreshOptions", moduleKey)
end

local currentResetter
local resetterInfo = {
    -- common
    general = {
        requireReload = true,
        isCommon = true,
        func = function()
            BFIConfig.general = nil
            AFConfig.accentColor = nil
            AFConfig.fontSizeDelta = nil
            AFConfig.scale = nil
        end
    },
    enhancements = {isCommon = true},
    colors = {isCommon = true},
    auras = {isCommon = true},

    -- profile
    unitFrames = {},
    nameplates = {},
    actionBars = {},
    buffsDebuffs = {},
    tooltip = {},
    uiWidgets = {},
    dataBars = {},
    maps = {},
    chat = {},
}

AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if moduleResetFrame and moduleResetFrame:IsShown() then
        moduleResetFrame:HideOut()
    end

    local b = BFIOptionsFrame_HeaderPane.resetButton
    currentResetter = id

    if resetterInfo[id] then
        b:SetEnabled(true)
    else
        b:SetEnabled(false)
    end
end)

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateModuleResetFrame()
    moduleResetFrame = AF.CreateBorderedFrame(BFIOptionsFrame, "BFIOptionsFrame_ModuleResetFrame", 300, 2, nil, "BFI")
    AF.SetFrameLevel(moduleResetFrame, 310)
    moduleResetFrame:Hide()
    AF.SetPoint(moduleResetFrame, "TOPRIGHT", BFIOptionsFrame_ContentPane, -7, -1)

    AF.ApplyCombatProtectionToFrame(moduleResetFrame)

    -- mask
    AF.ShowMask(BFIOptionsFrame_ContentPane)
    AF.HideMask(BFIOptionsFrame_ContentPane)
    AF.SetFrameLevel(BFIOptionsFrame_ContentPane.mask, 300)

    -- scroll container
    local scroll = AF.CreateScrollFrame(moduleResetFrame, nil, nil, nil, "none", "none")
    AF.SetPoint(scroll, "TOPLEFT", 7, -7)
    AF.SetPoint(scroll, "BOTTOMRIGHT", -7, 7)

    local text = AF.CreateFontString(scroll.scrollContent)
    text:SetAlpha(0)
    text:SetPoint("TOPLEFT", 0, -2)
    text:SetPoint("TOPRIGHT", 0, -2)
    text:SetWordWrap(true)
    text:SetSpacing(5)

    local yes = AF.CreateButton(scroll.scrollContent, L["Okay"], "green", nil, 17)
    yes:SetAlpha(0)
    AF.SetPoint(yes, "BOTTOMLEFT", scroll)
    AF.SetPoint(yes, "BOTTOMRIGHT", scroll, "BOTTOM")
    yes:SetOnClick(function()
        local resetter = resetterInfo[currentResetter]

        local func
        if resetter.func then
            func = resetter.func
        elseif resetter.isCommon then
            func = ResetCommonModule
        else
            func = ResetProfileModule
        end

        if resetter.requireReload then
            func(currentResetter)
            ReloadUI()
        else
            moduleResetFrame:ShowResetMessage()
            func(currentResetter)

            C_Timer.After(1, function()
                moduleResetFrame:HideOut()
            end)
        end
    end)

    local no = AF.CreateButton(scroll.scrollContent, L["Cancel"], "red", nil, 17)
    no:SetAlpha(0)
    AF.SetPoint(no, "BOTTOMLEFT", yes, "BOTTOMRIGHT", -1, 0)
    AF.SetPoint(no, "BOTTOMRIGHT", scroll)
    no:SetOnClick(function()
        moduleResetFrame:HideOut()
    end)

    local module = AF.WrapTextInColor(L["Module"] .. ": ", "gray")
    local profile = AF.WrapTextInColor(L["Profile"] .. ": ", "gray")

    function moduleResetFrame:ShowUp()
        moduleResetFrame:Show()

        if resetterInfo[currentResetter].isCommon then
            text:SetText(L["Are you sure you want to reset the current module?"]
                .. "\n" .. module .. AF.WrapTextInColor(F.GetModuleLocalizedName(currentResetter), "softlime")
                .. "\n" ..  AF.WrapTextInColor(L["This action cannot be undone"], "firebrick")
            )
        else
            local profileName = BFI.vars.profileName == "default" and L["Default"] or BFI.vars.profileName
            text:SetText(L["Are you sure you want to reset the current module?"]
                .. "\n" .. module .. AF.WrapTextInColor(F.GetModuleLocalizedName(currentResetter), "softlime")
                .. "\n" .. profile .. AF.WrapTextInColor(profileName, "vividblue")
                .. "\n" ..  AF.WrapTextInColor(L["This action cannot be undone"], "firebrick")
            )
        end

        AF.FrameFadeIn(BFIOptionsFrame_ContentPane.mask)
        AF.FrameFadeIn(text)
        AF.FrameFadeIn(yes)
        AF.FrameFadeIn(no)

        AF.AnimatedResize(moduleResetFrame, nil, ceil(text:GetHeight() + 50), nil, 5)
    end

    function moduleResetFrame:HideOut()
        AF.FrameFadeOut(BFIOptionsFrame_ContentPane.mask, nil, nil, nil, true)
        AF.FrameFadeOut(text)
        AF.FrameFadeOut(yes)
        AF.FrameFadeOut(no)
        AF.AnimatedResize(moduleResetFrame, nil, 2, nil, 5, nil, function()
            moduleResetFrame:Hide()
        end)
    end

    function moduleResetFrame:ShowResetMessage()
        text:SetText(L["Module %s has been reset"]:format(AF.WrapTextInColor(L[currentResetter], "softlime")))
        yes:Hide()
        yes:SetAlpha(0)
        no:Hide()
        no:SetAlpha(0)
        AF.AnimatedResize(moduleResetFrame, nil, ceil(text:GetHeight() + 20), nil, 5)
    end

    BFIOptionsFrame_ContentPane:HookOnHide(function()
        if moduleResetFrame and moduleResetFrame:IsShown() then
            moduleResetFrame:HideOut()
        end
    end)
end

---------------------------------------------------------------------
-- toggle
---------------------------------------------------------------------
function F.ToggleModuleResetFrame()
    if not moduleResetFrame then
        CreateModuleResetFrame()
    end

    if moduleResetFrame:IsShown() then
        moduleResetFrame:HideOut()
    else
        moduleResetFrame:ShowUp()
    end
end