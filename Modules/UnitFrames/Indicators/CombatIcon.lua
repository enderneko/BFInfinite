---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.Shared
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit
local UnitAffectingCombat = UnitAffectingCombat

---------------------------------------------------------------------
-- show/hide
---------------------------------------------------------------------
local function UpdateCombatIcon(self)
    local unit = self.root.displayedUnit

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
        self:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateCombatIcon)
        self:RegisterEvent("PLAYER_REGEN_DISABLED", UpdateCombatIcon)
    else
        self.ticker = C_Timer.NewTicker(0.5, function()
            CombatIcon_Update(self)
        end)
    end
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function CombatIcon_Disable(self)
    self:Hide()
    self:UnregisterAllEvents()
    if self.ticker then
        self:Cancel()
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function CombatIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    -- self.icon:SetTexture(AW.GetTexture(config.texture))
    self.text:SetFont(AW.GetFont("glyphs"), config.width, "OUTLINE")
    self.text:SetText(S.CombatGlyph.char)
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
    text:SetTextColor(AW.UnpackColor(S.CombatGlyph.color))

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = CombatIcon_Enable
    frame.Disable = CombatIcon_Disable
    frame.Update = CombatIcon_Update
    frame.LoadConfig = CombatIcon_LoadConfig

    return frame
end