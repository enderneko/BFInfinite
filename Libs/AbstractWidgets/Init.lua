local addonName, ns = ...
ns.AW = {}

assert(ns.prefix, "a \"prefix\" is required in your addon namespace.")

local AW = ns.AW

AW.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
AW.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
AW.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

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
    for _, w in pairs({...}) do
        if w:IsObjectType("FontString") then
            if isEnabled then
                w:SetTextColor(1, 1, 1, 1)
            else
                w:SetTextColor(0.4, 0.4, 0.4, 1)
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

-- TODO: disable all children