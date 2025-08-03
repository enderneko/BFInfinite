---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs
local L = BFI.L
local AB = BFI.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local created = {}
local builder = {}
local options = {}

---------------------------------------------------------------------
-- settings
---------------------------------------------------------------------
local settings = {
    general = {
        "enabled",
        "lock,pickUpKey",
    },
    bar = {
        "enabled",
    },
}

---------------------------------------------------------------------
-- copy,paste,reset
---------------------------------------------------------------------
builder["copy,paste,reset"] = function(parent)
    if created["copy,paste,reset"] then return created["copy,paste,reset"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_CopyPasteReset", nil, 30)
    created["copy,paste,reset"] = pane
    pane:Hide()

    local copiedId, copiedOwnerName, copiedTime, copiedCfg

    local copy = AF.CreateButton(pane, L["Copy"], "BFI_hover", 107, 20)
    AF.SetPoint(copy, "LEFT", 15, 0)
    copy.tick = AF.CreateTexture(copy, AF.GetIcon("Fluent_Color_Yes"))
    AF.SetSize(copy.tick, 16, 16)
    AF.SetPoint(copy.tick, "RIGHT", -5, 0)
    copy.tick:Hide()

    local paste = AF.CreateButton(pane, L["Paste"], "BFI_hover", 107, 20)
    AF.SetPoint(paste, "TOPLEFT", copy, "TOPRIGHT", 7, 0)

    copy:SetOnClick(function()
        copiedId = pane.t.id
        copiedCfg = AF.Copy(pane.t.cfg)
        copiedOwnerName = pane.t.ownerName
        copiedTime = time()
        AF.FrameFadeInOut(copy.tick, 0.15)
        paste:SetEnabled(true)
    end)

    paste:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Overwrite with copied config?"], "BFI") .. "\n"
            .. copiedOwnerName .. AF.WrapTextInColor(" -> ", "darkgray") .. pane.t.ownerName .. "\n"
            .. AF.WrapTextInColor(AF.FormatRelativeTime(copiedTime), "darkgray")

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            AF.MergeExistingKeys(pane.t.cfg, copiedCfg)
            AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
        end)
    end)


    local reset = AF.CreateButton(pane, _G.RESET, "red_hover", 107, 20)
    AF.SetPoint(reset, "TOPLEFT", paste, "TOPRIGHT", 7, 0)
    reset:SetOnClick(function()
        local text = AF.WrapTextInColor(L["Reset to default config?"], "BFI") .. "\n" .. pane.t.ownerName

        local dialog = AF.GetDialog(BFIOptionsFrame_UnitFramesPanel, text, 250)
        dialog:SetPoint("TOP", pane, "BOTTOM")
        dialog:SetOnConfirm(function()
            -- TODO:
            -- wipe(pane.t.cfg)
        end)
    end)

    function pane.Load(t)
        pane.t = t
        copy:SetEnabled(t.id ~= "general")
        paste:SetEnabled(t.id ~= "general" and copiedId == t.id)
    end

    return pane
end

---------------------------------------------------------------------
-- enabled
---------------------------------------------------------------------
builder["enabled"] = function(parent)
    if created["enabled"] then return created["enabled"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_Enabled", nil, 30)
    created["enabled"] = pane

    local enabled = AF.CreateCheckButton(pane, L["Enabled"])
    AF.SetPoint(enabled, "LEFT", 15, 0)

    local function UpdateColor(checked)
        if checked then
            enabled.label:SetTextColor(AF.GetColorRGB("softlime"))
        else
            enabled.label:SetTextColor(AF.GetColorRGB("firebrick"))
        end
    end

    enabled:SetOnCheck(function(checked)
        pane.t.cfg.enabled = checked
        UpdateColor(checked)
        if pane.t.id == "general" then
            AF.Fire("BFI_UpdateModule", "actionBars")
        else
            AF.Fire("BFI_UpdateModule", "actionBars", pane.t.id)
        end
        pane.t:SetTextColor(checked and "white" or "disabled")
    end)

    function pane.Load(t)
        pane.t = t
        UpdateColor(t.cfg.enabled)
        enabled:SetChecked(t.cfg.enabled)
    end

    return pane
end

---------------------------------------------------------------------
-- lock,pickUpKey
---------------------------------------------------------------------
builder["lock,pickUpKey"] = function(parent)
    if created["lock,pickUpKey"] then return created["lock,pickUpKey"] end

    local pane = AF.CreateBorderedFrame(parent, "BFI_ActionBarOption_LockPickUpKey", nil, 51)
    created["lock,pickUpKey"] = pane

    local lock = AF.CreateCheckButton(pane, L["Lock"])
    AF.SetPoint(lock, "LEFT", 15, 0)
    lock:SetOnCheck(function(checked)
        pane.t.sharedCfg.lock = checked
        AF.Fire("BFI_UpdateModule", "actionBars")
        Settings.SetValue("lockActionBars", checked)
    end)

    local pickUpKey = AF.CreateDropdown(pane, 150)
    pickUpKey:SetLabel(L["Pick Up Key"])
    AF.SetPoint(pickUpKey, "TOPLEFT", lock, 185, -5)

    function pane.Load(t)
        pane.t = t
        lock:SetChecked(t.sharedCfg.lock)
    end

    return pane
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
function F.GetActionBarOptions(parent, info)
    for _, pane in pairs(created) do
        pane:Hide()
        AF.ClearPoints(pane)
    end

    wipe(options)
    tinsert(options, builder["copy,paste,reset"](parent))
    created["copy,paste,reset"]:Show()

    local setting = info.setting
    if not settings[setting] then return options end

    for _, option in pairs(settings[setting]) do
        if builder[option] then
            local pane = builder[option](parent)
            tinsert(options, pane)
            pane:Show()
        end
    end

    return options
end