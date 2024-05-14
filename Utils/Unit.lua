local _, BFI = ...
local U = BFI.utils

local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI

function U.UnitIsPlayer(unit)
    return UnitIsPlayer(unit) or UnitInPartyIsAI(unit)
end

function U.IsPlayer(guid)
    return strfind(guid, "^Player")
end

function U.IsPet(guid)
    return strfind(guid, "^Pet")
end

function U.IsNPC(guid)
    return strfind(guid, "^Creature")
end

function U.IsVehicle(guid)
    return strfind(guid, "^Vehicle")
end