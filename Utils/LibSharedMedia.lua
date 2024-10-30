---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework

local LSM = LibStub("LibSharedMedia-3.0", true)

-- statusbar
local DEFAULT_BAR_TEXTURE = AF.GetTexture("StatusBar", BFI.name)
LSM:Register("statusbar", "BFI", DEFAULT_BAR_TEXTURE)
LSM:Register("statusbar", "BFI Plain", AF.GetPlainTexture())

-- font
local DEFAULT_FONT = AF.GetFont("Noto_AP_SC", BFI.name)
LSM:Register("font", "BFI", DEFAULT_FONT, 255)
LSM:Register("font", "Visitor", AF.GetFont("visitor", BFI.name), 255)
LSM:Register("font", "Emblem", AF.GetFont("Emblem", BFI.name), 255)
LSM:Register("font", "Expressway", AF.GetFont("Expressway", BFI.name), 255)

function U.GetBarTexture(name)
    if LSM:IsValid("statusbar", name) then
        return LSM:Fetch("statusbar", name)
    end
    return DEFAULT_BAR_TEXTURE
end

function U.GetFont(name)
    if LSM:IsValid("font", name) then
        return LSM:Fetch("font", name)
    end
    return DEFAULT_FONT
end

--- @param fs FontString|EditBox
function U.SetFont(fs, font, size, outline, shadow)
    if type(font) == "table" then
        font, size, outline, shadow = unpack(font)
    end

    font = U.GetFont(font)

    local flags
    if outline == "none" then
        flags = ""
    elseif outline == "outline" then
        flags = "OUTLINE"
    elseif outline == "monochrome_outline" then
        flags = "OUTLINE,MONOCHROME"
    elseif outline == "monochrome" then
        flags = "MONOCHROME"
    end

    fs:SetFont(font, size, flags)

    if shadow then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
    else
        fs:SetShadowOffset(0, 0)
        fs:SetShadowColor(0, 0, 0, 0)
    end
end