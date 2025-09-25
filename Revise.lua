---@type BFI
local BFI = select(2, ...)
---@class Funcs
local F = BFI.funcs

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
}

function F.ReviseCommon()
    if BFIConfig.revision then
        for _, revise in ipairs(commonRevisions) do
            if BFIConfig.revision < revise.ver then
                revise.fn(BFIConfig)
            end
        end
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
}

function F.ReviseProfile(profile)
    if profile.revision then
        for _, revise in ipairs(profileRevisions) do
            if profile.revision < revise.ver then
                revise.fn(profile)
            end
        end
    end

    profile.revision = BFI.versionNum
end