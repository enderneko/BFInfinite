---@class BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs

function F.Revise(profile)
    if profile.versionNum and profile.versionNum < 10 then

    end

    profile.version = BFI.version
    profile.versionNum = BFI.versionNum
end