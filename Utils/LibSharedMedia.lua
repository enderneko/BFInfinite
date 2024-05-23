local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW

local LSM = LibStub("LibSharedMedia-3.0", true)

-- texture
local DEFAULT_BAR_TEXTURE = AW.GetTexture("StatusBar")
LSM:Register("statusbar", BFI_DEFAULT, DEFAULT_BAR_TEXTURE)

-- font
local DEFAULT_FONT = AW.GetFont("Noto_AP_SC")
LSM:Register("font", BFI_DEFAULT, DEFAULT_FONT, 255)
LSM:Register("font", "BFI 1", AW.GetFont("visitor"), 255)

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

--- @param fs FontString
function U.SetFont(fs, font, size, outline, shadow)
    font = U.GetFont(font)

    local flags
    if outline == "none" then
        flags = ""
    elseif outline == "outline" then
        flags = "OUTLINE"
    else
        flags = "OUTLINE,MONOCHROME"
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