---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitIsPlayer = UnitIsPlayer
local IsInInstance = IsInInstance
local UnitPhaseReason = UnitPhaseReason
local UnitInOtherParty = UnitInOtherParty
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local HasIncomingSummon = C_IncomingSummon.HasIncomingSummon
local IncomingSummonStatus = C_IncomingSummon.IncomingSummonStatus
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

---------------------------------------------------------------------
-- status
---------------------------------------------------------------------
local function UpdateStatus(self, event, unitId)
    local unit = self.root.unit
    if unitId and unitId ~= unit then return end

    if not UnitIsPlayer(unit) then return end

    local phaseReason = UnitPhaseReason(unit)

    if UnitInOtherParty(unit) then
        self.icon:SetVertexColor(1, 1, 1, 1)
        self.icon:SetTexture("Interface\\LFGFrame\\LFG-Eye")
        self.icon:SetTexCoord(0.14, 0.235, 0.28, 0.47)
        self:Show()
    elseif UnitHasIncomingResurrection(unit) then
        self.icon:SetVertexColor(1, 1, 1, 1)
        self.icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        self.icon:SetTexCoord(0, 1, 0, 1)
        self:Show()
    elseif HasIncomingSummon(unit) then
        local status = IncomingSummonStatus(unit)
        if status == Enum.SummonStatus.Pending then
            self.icon:SetAtlas("Raid-Icon-SummonPending")
            self.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        else
            if status == Enum.SummonStatus.Accepted then
                self.icon:SetAtlas("Raid-Icon-SummonAccepted")
                self.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
            elseif status == Enum.SummonStatus.Declined then
                self.icon:SetAtlas("Raid-Icon-SummonDeclined")
                self.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
            end
            C_Timer.After(6, function() UpdateStatus(self) end)
        end
        self:Show()
    elseif phaseReason then
        if phaseReason == 3 then -- chromie, yellow
            self.icon:SetVertexColor(1, 1, 0)
        elseif phaseReason == 2 then -- warmode, red
            self.icon:SetVertexColor(1, 0.6, 0.6)
        elseif phaseReason == 1 then -- sharding, green
            self.icon:SetVertexColor(0.5, 1, 0.5)
        else -- 0, phasing
            self.icon:SetVertexColor(1, 1, 1)
        end
        self.icon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
        self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        self:Show()
    -- elseif UnitIsDeadOrGhost(unit) then
    --     self.icon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    --     self.icon:SetTexCoord(0, 1, 0, 1)
    --     self:Show()
    elseif self.BGFlag then
        self.icon:SetVertexColor(1, 1, 1, 1)
        self.icon:SetAtlas("nameplates-self.icon-flag-"..self.BGFlag)
        self.icon:SetTexCoord(0, 1, 0, 1)
        self:Show()
    elseif self.BGOrb then
        self.icon:SetVertexColor(1, 1, 1, 1)
        self.icon:SetAtlas("nameplates-self.icon-orb-"..self.BGOrb)
        self.icon:SetTexCoord(0, 1, 0, 1)
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- battleground
---------------------------------------------------------------------
local function CheckAura(self, event, unitId)
    local unit = self.root.unit
    if unitId and unitId ~= unit then return end

    self.BGFlag = nil
    self.BGOrb = nil

    local i = 1
    repeat
        local auraData = GetAuraDataByIndex(unit, i)
        if auraData then
            if auraData.spellId == 156621 then
                self.BGFlag = "alliance"
            elseif auraData.spellId == 156618 then
                self.BGFlag = "horde"
            elseif auraData.spellId == 121164 then
                self.BGOrb = "blue"
            elseif auraData.spellId == 121175 then
                self.BGOrb = "purple"
            elseif auraData.spellId == 121176 then
                self.BGOrb = "green"
            elseif auraData.spellId == 121177 then
                self.BGOrb = "orange"
            end
            i = i + 1
        end
    until not auraData or self.BGFlag or self.BGOrb

    UpdateStatus(self)
end

local function CheckBattleground(self)
    local instanceType = IsInInstance()
    if instanceType == "pvp" then
        self.inBattleground = true
        self:RegisterEvent("UNIT_AURA", CheckAura)
        CheckAura(self)
    else
        self.inBattleground = nil
        self:UnregisterEvent("UNIT_AURA")
        UpdateStatus(self)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function StatusIcon_Update(self)
    if self.inBattleground then
        CheckAura(self)
    else
        UpdateStatus(self)
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function StatusIcon_Enable(self)
    self:RegisterEvent("INCOMING_RESURRECT_CHANGED", UpdateStatus)
    self:RegisterEvent("INCOMING_SUMMON_CHANGED", UpdateStatus)
    self:RegisterEvent("UNIT_PHASE", UpdateStatus)
    self:RegisterEvent("PARTY_MEMBER_ENABLE", UpdateStatus)
    self:RegisterEvent("PARTY_MEMBER_DISABLE", UpdateStatus)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", CheckBattleground)

    CheckBattleground(self)
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function StatusIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateStatusIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = StatusIcon_Enable
    frame.Update = StatusIcon_Update
    frame.LoadConfig = StatusIcon_LoadConfig

    return frame
end