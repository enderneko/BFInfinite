local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- font string
---------------------------------------------------------------------
--- @param color string color name defined in Color.lua
--- @param font string color name defined in Font.lua
function AW.CreateFontString(parent, text, color, font, isDisabled)
    font = font or "normal"
    font = AW.GetFont(font, isDisabled)

    local fs = parent:CreateFontString(nil, "OVERLAY", font)
    if color then AW.ColorFontString(fs, color) end
    fs:SetText(text)

    return fs
end