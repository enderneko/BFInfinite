local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW

local DEFAULT_BAR_TEXTURE = AW.GetTexture("StatusBar")
local DEFAULT_FONT = AW.GetFont("Noto_AP_SC")

local LSM = LibStub("LibSharedMedia-3.0", true)
LSM:Register("statusbar", BFI_DEFAULT, DEFAULT_BAR_TEXTURE)
LSM:Register("font", BFI_DEFAULT, DEFAULT_FONT)

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