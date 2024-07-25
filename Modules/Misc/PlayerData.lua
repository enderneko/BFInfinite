---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Misc
local M = BFI.M_Misc

local classCache = {}
local UnitClassBase = UnitClassBase
local UnitLevel = UnitLevel
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildInfo = GetGuildInfo
local IsInGuild = IsInGuild
local GetNumFriends = C_FriendList.GetNumFriends
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
function M.GetPlayerClass(fullName)
    return classCache[fullName]
end

function M.GetPlayerInfo(fullName)
    return BFIPlayer[fullName]
end

function M.GetMain(fullName)
    -- TODO:
end

function M.GetAlts(fullName)
    -- TODO:
end

---------------------------------------------------------------------
-- ADDON_LOADED
---------------------------------------------------------------------
local function InitCache(_, _, addon)
    if addon == BFI.name then
        M:UnregisterEvent("ADDON_LOADED", InitCache)
        if type(BFIPlayer) ~= "table" then BFIPlayer = {} end
        if type(BFIGuild) ~= "table" then BFIGuild = {members = {}} end
    end
end
M:RegisterEvent("ADDON_LOADED", InitCache)

---------------------------------------------------------------------
-- PLAYER_LOGIN
---------------------------------------------------------------------
local function CacheSelf()
    if not BFIPlayer[BFI.vars.playerNameFull] then
        BFIPlayer[BFI.vars.playerNameFull] = {}
    end
    BFIPlayer[BFI.vars.playerNameFull]["class"] = BFI.vars.playerClass
    BFIPlayer[BFI.vars.playerNameFull]["level"] = UnitLevel("player")
end
BFI.RegisterCallback("PLAYER_LOGIN", "Misc_PlayerData", CacheSelf)

---------------------------------------------------------------------
-- all
---------------------------------------------------------------------
local CacheAll, CacheGroup, CacheGuild, CacheFriends

function CacheAll(_, event)
    M:UnregisterEvent("PLAYER_ENTERING_WORLD", CacheAll)
    CacheGroup(nil, event)
    -- CacheGuild(nil, event)
    CacheFriends(nil, event)
end
M:RegisterEvent("PLAYER_ENTERING_WORLD", CacheAll)

---------------------------------------------------------------------
-- group
---------------------------------------------------------------------
function CacheGroup(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        M:RegisterEvent("GROUP_ROSTER_UPDATE", CacheGroup)
    elseif event == "PLAYER_REGEN_ENABLED" then
        M:UnregisterEvent(event, CacheGroup)
    end

    if InCombatLockdown() then
        if event == "PLAYER_ENTERING_WORLD" then
            M:RegisterEvent("PLAYER_REGEN_ENABLED", CacheGroup)
        end
        return
    end

    for unit in U.GroupMembersIterator() do
        local name = U.UnitFullName(unit)
        if name then
            local class = UnitClassBase(unit)
            classCache[name] = class

            -- BFIPlayer
            if BFIPlayer[name] then
                BFIPlayer[name]["class"] = class
                BFIPlayer[name]["level"] = UnitLevel(unit)
            end
        end
    end
end

---------------------------------------------------------------------
-- guild
---------------------------------------------------------------------
function CacheGuild(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", CacheGuild)
    end

    if IsInGuild() then -- only save once per login
        M:UnregisterEvent("GUILD_ROSTER_UPDATE", CacheGuild)

        local guild = GetGuildInfo("player")

        local skipReporting
        if BFIGuild.name ~= guild or U.IsEmpty(BFIGuild.members) then
            wipe(BFIGuild.members)
            skipReporting = true
        end

        BFIGuild.name = guild

        local newMember = {}
        local leftGuild = U.Copy(BFIGuild.members)

        for i = 1, GetNumGuildMembers() do
            local name, _, _, level, _, _, _, _, _, _, classFile = GetGuildRosterInfo(i)

            if not BFIGuild["members"][name] then
                tinsert(newMember, {name = name, level = level, class = classFile})
            end
            leftGuild[name] = nil

            -- add to BFIGuild
            BFIGuild["members"][name] = {level = level, class = classFile}

            -- add to BFIPlayer
            if not BFIPlayer[name] then BFIPlayer[name] = {} end
            BFIPlayer[name]["class"] = classFile
            BFIPlayer[name]["level"] = level
            BFIPlayer[name]["lastSeen"] = GetServerTime()
        end

        -- remove left
        for name in pairs(leftGuild) do
            BFIGuild["members"][name] = nil
            if BFIPlayer[name] and not BFIPlayer[name]["isFriend"] then
                BFIPlayer[name] = nil
            end
        end

        if not skipReporting then
            texplore(newMember)
            texplore(leftGuild)
        end

        wipe(leftGuild)
        wipe(newMember)
    else
        wipe(BFIGuild.members)
        BFIGuild.name = nil
        M:RegisterEvent("GUILD_ROSTER_UPDATE", CacheGuild)
    end

end

---------------------------------------------------------------------
-- friends
---------------------------------------------------------------------
function CacheFriends(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        M:UnregisterEvent("PLAYER_ENTERING_WORLD", CacheFriends)
        M:RegisterEvent("FRIENDLIST_UPDATE", CacheFriends)
    end

    for i = 1, GetNumFriends() do
        local info = GetFriendInfoByIndex(i)
        if info.connected and info.className ~= _G.UNKNOWN then
            local name = info.name
            if name and name ~= "" then
                if not strfind(name, "-") then
                    name = name .. "-" .. BFI.vars.playerRealm
                end
                if not BFIPlayer[name] then BFIPlayer[name] = {} end
                BFIPlayer[name]["class"] = U.GetClassFileName(info.className)
                BFIPlayer[name]["level"] = info.level
            end
        end
    end
end

---------------------------------------------------------------------
-- TODO: BN friends
---------------------------------------------------------------------