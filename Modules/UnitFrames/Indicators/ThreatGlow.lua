---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

---------------------------------------------------------------------
-- threat
---------------------------------------------------------------------
local function UpdateThreat(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local status = UnitThreatSituation(unit)
    if status and status >= 1 then
        local r, g, b = GetThreatStatusColor(status)
        self:SetBackdropBorderColor(r, g, b, self.alpha)
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function ThreatGlow_Update(self)
    UpdateThreat(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function ThreatGlow_Enable(self)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", UpdateThreat)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function ThreatGlow_LoadConfig(self, config)
    -- AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.SetOutside(self, self.root, config.size)
    self:SetBackdrop({edgeFile=AW.GetTexture("StaticGlow", true), edgeSize=AW.ConvertPixelsForRegion(config.size, self)})
    self.alpha = config.alpha
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ThreatGlow_EnableConfigMode(self)
    self.Enable = ThreatGlow_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:SetBackdropBorderColor(1, 0, 0, self.alpha)
    self:Show()
end

local function ThreatGlow_DisableConfigMode(self)
    self.Enable = ThreatGlow_Enable
    self.Update = ThreatGlow_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateThreatGlow(parent, name)
    local glow = CreateFrame("Frame", name, parent, "BackdropTemplate")
    glow:SetFrameStrata("BACKGROUND")
    glow.root = parent
    glow:Hide()

    -- events
    BFI.AddEventHandler(glow)

    -- functions
    glow.Enable = ThreatGlow_Enable
    glow.Update = ThreatGlow_Update
    glow.EnableConfigMode = ThreatGlow_EnableConfigMode
    glow.DisableConfigMode = ThreatGlow_DisableConfigMode
    glow.LoadConfig = ThreatGlow_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(glow)

    return glow
end