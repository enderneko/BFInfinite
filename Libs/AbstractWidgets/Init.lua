local addonName, ns = ...
ns.AW = {}

---@class AbstractWidgets
local AW = ns.AW

---------------------------------------------------------------------
-- generate prefix
---------------------------------------------------------------------
if not ns.prefix or strtrim(ns.prefix) == "" then
    local it = string.gmatch(addonName, "%u") -- capital letters

    ns.prefix = ""

    while true do
        local s = it()
        if not s then break end
        ns.prefix = ns.prefix..s
    end

    if ns.prefix == "" then
        ns.prefix = strupper(addonName)
    end
end

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
AW.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
AW.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
AW.isCata = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

---------------------------------------------------------------------
-- UIParent
---------------------------------------------------------------------
AW.UIParent = CreateFrame("Frame", strupper(ns.prefix).."Parent", UIParent)
AW.UIParent:SetAllPoints(UIParent)
-- AW.UIParent:SetPoint("BOTTOM")
AW.UIParent:SetFrameLevel(0)

local function UpdatePixels()
    if InCombatLockdown() then
        AW.UIParent:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    AW.UIParent:UnregisterEvent("PLAYER_REGEN_ENABLED")
    AW.UpdatePixels()
end

-- hooksecurefunc(UIParent, "SetScale", UpdatePixels)
AW.UIParent:RegisterEvent("DISPLAY_SIZE_CHANGED")
AW.UIParent:RegisterEvent("UI_SCALE_CHANGED")
AW.UIParent:SetScript("OnEvent", UpdatePixels)

function AW.SetIgnoreParentScale(ignore)
    AW.UIParent:SetIgnoreParentScale(ignore)
end

--! scale CANNOT be TOO SMALL (effectiveScale should >= 0.43)
--! or it will lead to abnormal display of borders
--! since AW has changed SetSnapToPixelGrid / SetTexelSnappingBias
function AW.SetScale(scale)
    AW.UIParent:SetScale(scale)
    UpdatePixels()
end

function AW.SetUIParentScale(scale)
    UIParent:SetScale(scale)
    if not AW.UIParent:IsIgnoringParentScale() then
        UpdatePixels()
    end
end

---------------------------------------------------------------------
-- slash command
---------------------------------------------------------------------
local name = strupper(ns.prefix).."WIDGETS"
_G["SLASH_"..name.."1"] = "/"..strlower(ns.prefix).."widgets"
SlashCmdList[name] = function()
    AW.ShowDemo()
end

---------------------------------------------------------------------
-- enable / disable
---------------------------------------------------------------------
function AW.SetEnabled(isEnabled, ...)
    if isEnabled == nil then isEnabled = false end

    for _, w in pairs({...}) do
        if w:IsObjectType("FontString") then
            if isEnabled then
                w:SetTextColor(AW.GetColorRGB("white"))
            else
                w:SetTextColor(AW.GetColorRGB("disabled"))
            end
        elseif w:IsObjectType("Texture") then
            if isEnabled then
                w:SetDesaturated(false)
            else
                w:SetDesaturated(true)
            end
        elseif w.SetEnabled then
            w:SetEnabled(isEnabled)
        elseif isEnabled then
            w:Show()
        else
            w:Hide()
        end
    end
end

function AW.Enable(...)
    AW.SetEnabled(true, ...)
end

function AW.Disable(...)
    AW.SetEnabled(false, ...)
end

-- TODO: disable all children

---------------------------------------------------------------------
-- misc
---------------------------------------------------------------------
function AW.Unpack2(t)
    return t[1], t[2]
end

function AW.Unpack3(t)
    return t[1], t[2], t[3]
end

function AW.Unpack4(t)
    return t[1], t[2], t[3], t[4]
end