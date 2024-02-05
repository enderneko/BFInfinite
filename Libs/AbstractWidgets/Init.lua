local addonName, ns = ...
ns.AW = {}

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

-- TODO: disable all children