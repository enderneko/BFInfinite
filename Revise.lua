---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- common revisions
---------------------------------------------------------------------
local commonRevisions = {
    -- {
    --     ver = 2,
    --     fn = function(config)
    --         -- do something for version 2
    --     end,
    -- },
    {
        ver = 4,
        fn = function(config)
            config.enhancements.mythicPlus = BFI.modules.Enhancements.GetDefaults().mythicPlus
        end,
    }
}

function F.ReviseCommon()
    if BFIConfig.revision and BFIConfig.revision < BFI.versionNum then
        for _, revise in ipairs(commonRevisions) do
            if BFIConfig.revision < revise.ver then
                revise.fn(BFIConfig)
            end
        end
    end

    if BFIConfig.revision and BFIConfig.revision ~= BFI.versionNum then
        AF.ShowNotificationPopup(
            L["BFI has been updated to version %s\nClick here to view the changelog"]:format(AF.WrapTextInColor(BFI.version, "BFI")),
            27,
            "!" .. AF.GetIcon("BFI_64", BFI.name),
            nil, nil, "LEFT",
            F.ToggleChangelogsFrame
        )
    end

    BFIConfig.revision = BFI.versionNum
end

---------------------------------------------------------------------
-- profile revisions
---------------------------------------------------------------------
local profileRevisions = {
    -- {
    --     ver = 2,
    --     fn = function(profile)
    --         -- do something for version 2
    --     end,
    -- },
    {
        ver = 3,
        fn = function(profile)
            profile.chat = BFI.modules.Chat.GetDefaults()
        end,
    },
    {
        ver = 4,
        fn = function(profile)
            profile.maps.worldMap = BFI.modules.Maps.GetDefaults().worldMap
        end,
    }
}

function F.ReviseProfile(profile, force)
    if (profile.revision and profile.revision < BFI.versionNum) or force then
        for _, revise in ipairs(profileRevisions) do
            if profile.revision < revise.ver then
                revise.fn(profile)
            end
        end
    end

    profile.revision = BFI.versionNum
end