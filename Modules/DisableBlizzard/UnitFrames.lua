---@class BFI
local BFI = select(2, ...)
---@class DisableBlizzard
local DB = BFI.DisableBlizzard
---@type AbstractFramework
local AF = _G.AbstractFramework

-- forked from ElvUI
local hookedFrames = {}

local function Reparent(self, parent)
    if parent ~= BFI.hiddenParent then
        self:SetParent(BFI.hiddenParent)
    end
end

local function SetShown(self, shown)
    if shown then
        self:Hide()
    end
end

function DB.DisableFrame(frame, doNotReparent)
    if not frame then return end

    frame:UnregisterAllEvents()
    pcall(frame.Hide, frame)

    if not doNotReparent then
        frame:SetParent(BFI.hiddenParent)
        if not hookedFrames[frame] then
            hookedFrames[frame] = true
            hooksecurefunc(frame, "SetParent", Reparent)
        end
    end

    local health = frame.healthBar or frame.healthbar or frame.HealthBar
    if health then
        health:UnregisterAllEvents()
    end

    local power = frame.manabar or frame.ManaBar
    if power then
        power:UnregisterAllEvents()
    end

    local spell = frame.castBar or frame.spellbar or frame.CastingBarFrame
    if spell then
        spell:UnregisterAllEvents()
    end

    local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
    if altpowerbar then
        altpowerbar:UnregisterAllEvents()
    end

    local buffFrame = frame.BuffFrame
    if buffFrame then
        buffFrame:UnregisterAllEvents()
    end

    local debuffFrame = frame.DebuffFrame
    if debuffFrame then
        debuffFrame:UnregisterAllEvents()
    end

    local classPowerBar = frame.classPowerBar
    if classPowerBar then
        classPowerBar:UnregisterAllEvents()
    end

    local ccRemoverFrame = frame.CcRemoverFrame
    if ccRemoverFrame then
        ccRemoverFrame:UnregisterAllEvents()
    end

    local petFrame = frame.petFrame or frame.PetFrame
    if petFrame then
        petFrame:UnregisterAllEvents()
    end

    local totFrame = frame.totFrame
    if totFrame then
        totFrame:UnregisterAllEvents()
    end
end

local allowedFuncs = {
    [_G.DefaultCompactUnitFrameSetup] = true,
    [_G.DefaultCompactNamePlateEnemyFrameSetup] = true,
    [_G.DefaultCompactNamePlateFriendlyFrameSetup] = true,
    [_G.DefaultCompactNamePlatePlayerFrameSetup] = true,
}

local frame_SetUp = {}
local frame_SetUnit = {}

local function DisableBlizzard_SetUpFrame(frame, func)
    if not allowedFuncs[func] then return end
    if frame.IsForbidden or frame:IsForbidden() then return end

    local name = frame:GetDebugName()
    if name then
        for _, pattern in pairs(frame_SetUp) do
            if strmatch(name, pattern) then
                frame_SetUnit[frame] = name
            end
        end
    end
end

local function DisableBlizzard_SetUnit(frame, unit)
    if frame_SetUnit[frame] and unit then
        -- CompactUnitFrame_UnregisterEvents(frame)
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
    end
end

local function DisableBlizzard_InitializeForGroup(frame)
    if not frame:IsForbidden() then
        frame:UnregisterAllEvents()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function DisableBlizzard()
    --! require ReloadUI to take effect
    if init then return end
    init = true

    local config = DB.config

    -- player
    if config.player then
        DB.DisableFrame(_G.PlayerFrame)
        DB.DisableFrame(_G.PetFrame)
        _G.MonkStaggerBar:UnregisterAllEvents()
    end

    -- target
    if config.target then
        DB.DisableFrame(_G.TargetFrame)
    end

    -- focus
    if config.focus then
        DB.DisableFrame(_G.FocusFrame)
    end

    -- party
    if config.party then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

        _G.CompactPartyFrame:UnregisterAllEvents()
        frame_SetUp[_G.CompactPartyFrame] = "^CompactPartyFrameMember%d+$"

        hooksecurefunc(_G.CompactPartyFrame, "Show", _G.CompactPartyFrame.Hide)
        hooksecurefunc(_G.CompactPartyFrame, "SetShown", SetShown)

        _G.PartyFrame:UnregisterAllEvents()
        _G.PartyFrame:SetScript("OnShow", nil)

        for frame in _G.PartyFrame.PartyMemberFramePool:EnumerateActive() do
            DB.DisableFrame(frame)
        end
        DB.DisableFrame(_G.PartyFrame)
    end

    -- raid
    if config.raid then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

        _G.CompactRaidFrameContainer:UnregisterAllEvents()
        frame_SetUp[_G.CompactRaidFrameContainer] = "^CompactRaidGroup%d+Member%d+$"

        hooksecurefunc(_G.CompactRaidFrameContainer, "Show", _G.CompactRaidFrameContainer.Hide)
        hooksecurefunc(_G.CompactRaidFrameContainer, "SetShown", SetShown)
        hooksecurefunc("CompactRaidGroup_InitializeForGroup", DisableBlizzard_InitializeForGroup)

        CompactRaidFrameManager_SetSetting("IsShown", "0")
        _G.CompactRaidFrameManager:UnregisterAllEvents()
        _G.CompactRaidFrameManager:SetParent(hiddenParent)
    end

    -- boss
    if config.boss then
        DB.DisableFrame(_G.BossTargetFrameContainer)
        for i = 1, 8 do
            DB.DisableFrame(_G["Boss" .. i .. "TargetFrame"], true)
        end
    end

    ---------------------------------------------
    hooksecurefunc("CompactUnitFrame_SetUpFrame", DisableBlizzard_SetUpFrame)
    hooksecurefunc("CompactUnitFrame_SetUnit", DisableBlizzard_SetUnit)
end
BFI.RegisterCallback("DisableBlizzard", "UnitFrames", DisableBlizzard)