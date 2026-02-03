---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local G = AF.Glyphs
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit
local UnitAffectingCombat = UnitAffectingCombat

---------------------------------------------------------------------
-- show/hide
---------------------------------------------------------------------
local function UpdateCombatIcon(self)
    local unit = self.root.effectiveUnit

    if UnitAffectingCombat(unit) then
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function CombatIcon_Update(self)
    UpdateCombatIcon(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function CombatIcon_Enable(self)
    if UnitIsUnit(self.root.unit, "player") then
        -- self:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateCombatIcon)
        -- self:RegisterEvent("PLAYER_REGEN_DISABLED", UpdateCombatIcon)
        self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED", UpdateCombatIcon)
    else
        if not self.ticker then
            self.ticker = C_Timer.NewTicker(0.5, function()
                CombatIcon_Update(self)
            end)
        end
    end
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function CombatIcon_Disable(self)
    self:Hide()
    self:UnregisterAllEvents()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CombatIcon_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.size, config.size)
    -- self.icon:SetTexture(AF.GetTexture(config.texture))
    G.SetFont(self.text, config.size, "outline")
    G.SetGlyph(self.text, G.Combat)
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function CombatIcon_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = CombatIcon_EnableConfigMode
    self.Update = AF.noop

    if self.ticker then self.ticker:Cancel() end
    self:SetShown(self.enabled)
end

local function CombatIcon_DisableConfigMode(self)
    self.Enable = CombatIcon_Enable
    self.Update = CombatIcon_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateCombatIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    -- frame.icon = frame:CreateTexture(nil, "ARTWORK")
    -- frame.icon:SetAllPoints()

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = CombatIcon_Enable
    frame.Disable = CombatIcon_Disable
    frame.Update = CombatIcon_Update
    frame.EnableConfigMode = CombatIcon_EnableConfigMode
    frame.DisableConfigMode = CombatIcon_DisableConfigMode
    frame.LoadConfig = CombatIcon_LoadConfig

    return frame
end