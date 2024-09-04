---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local B = BFI.Blizzard

local function DisableFrame(frame)
    if not frame then return end

    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(BFI.hiddenParent)

    local health = frame.healthBar or frame.healthbar
    if health then
        health:UnregisterAllEvents()
    end

    local power = frame.manabar
    if power then
        power:UnregisterAllEvents()
    end

    local spell = frame.castBar or frame.spellbar
    if spell then
        spell:UnregisterAllEvents()
    end

    local altpowerbar = frame.powerBarAlt
    if altpowerbar then
        altpowerbar:UnregisterAllEvents()
    end

    local buffFrame = frame.BuffFrame
    if buffFrame then
        buffFrame:UnregisterAllEvents()
    end

    local petFrame = frame.PetFrame
    if petFrame then
        petFrame:UnregisterAllEvents()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function DisableBlizzard(module, which)
    if module and module ~= "Blizzard" then return end

    if init then return end
    init = true

    local config = B.config.disableBlizzard

    -- player
    if config.player then
        DisableFrame(_G.PlayerFrame)
        DisableFrame(_G.PetFrame)
    end

    -- target
    if config.target then
        DisableFrame(_G.TargetFrame)
    end

    -- focus
    if config.focus then
        DisableFrame(_G.FocusFrame)
    end

    -- party
    if config.party then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        _G.CompactPartyFrame:UnregisterAllEvents()
        _G.PartyFrame:UnregisterAllEvents()
        _G.PartyFrame:SetScript("OnShow", nil)
        for frame in _G.PartyFrame.PartyMemberFramePool:EnumerateActive() do
            DisableFrame(frame)
        end
        DisableFrame(_G.PartyFrame)
    end

    -- raid
    if config.raid then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        _G.CompactRaidFrameContainer:UnregisterAllEvents()
        hooksecurefunc(_G.CompactRaidFrameContainer, "Show", _G.CompactRaidFrameContainer.Hide)
        hooksecurefunc(_G.CompactRaidFrameContainer, "SetShown", function(frame, shown)
            if shown then
                frame:Hide()
            end
        end)
        CompactRaidFrameManager_SetSetting("IsShown", "0")
    end

    -- manager
    if config.manager then
        DisableFrame(_G.CompactRaidFrameManager)
    end

    -- castBar
    if config.castBar then
        DisableFrame(_G.PlayerCastingBarFrame)
    end
end
BFI.RegisterCallback("UpdateModules", "DisableBlizzard", DisableBlizzard)