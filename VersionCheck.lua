---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local BFI_VER_CHK_PREFIX = "BFI_VER"

local function VersionCheckReceived(version)
    if type(version) == "number" and version > BFI.versionNum and (not BFIConfig.lastVersionCheck or time() - BFIConfig.lastVersionCheck >= 3600) then
        BFIConfig.lastVersionCheck = time()
        AF.Print(L["New version (%s) available!"]:format("r" .. version))
    end
end
AF.RegisterComm(BFI_VER_CHK_PREFIX, VersionCheckReceived)

local function BroadcastVersion(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        AF.SendCommMessage_Guild(BFI_VER_CHK_PREFIX, BFI.versionNum)
    else
        AF.SendCommMessage_Group(BFI_VER_CHK_PREFIX, BFI.versionNum)
    end
end
AF.CreateBasicEventHandler(BroadcastVersion, "PLAYER_ENTERING_WORLD", "GROUP_JOINED")