local _, BFI = ...
local U = BFI.utils

---------------------------------------------------------------------
-- IsXXX
---------------------------------------------------------------------
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

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local GetUnitName = GetUnitName
local GetNormalizedRealmName = GetNormalizedRealmName

function U.UnitFullName(unit)
    if not unit or not UnitIsPlayer(unit) then return end

    local name = GetUnitName(unit, true)
    
    if name and not string.find(name, "-") then
        local server = GetNormalizedRealmName()
        if server then
            name = name.."-"..server
        end
    end
    
    return name
end