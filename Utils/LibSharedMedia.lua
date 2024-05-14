local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW

local LSM = LibStub("LibSharedMedia-3.0", true)
LSM:Register("statusbar", BFI_DEFAULT, AW.GetPlainTexture())

function U.GetBarTexture(name)
    if LSM:IsValid("statusbar", name) then
        return LSM:Fetch("statusbar", name)
    end
    return AW.GetPlainTexture()
end