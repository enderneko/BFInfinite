---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.M_UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitIsUnit = UnitIsUnit

---------------------------------------------------------------------
-- target
---------------------------------------------------------------------
local function UpdateTarget(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    if self.enabled and UnitIsUnit(unit, "target") then
        self:Show()
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function TargetHighlight_Update(self)
    UpdateTarget(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function TargetHighlight_Enable(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget)
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function TargetHighlight_LoadConfig(self, config)
    self.enabled = config.enabled and config.size ~= 0

    AW.SetFrameLevel(self, config.frameLevel, self.root)

    if config.size ~= 0 then
        AW.ClearPoints(self)

        -- update point
        if config.size < 0 then
            AW.SetPoint(self, "TOPLEFT")
            AW.SetPoint(self, "BOTTOMRIGHT")
        else
            AW.SetPoint(self, "TOPLEFT", -config.size, config.size)
            AW.SetPoint(self, "BOTTOMRIGHT", config.size, -config.size)
        end

        -- update thickness
        AW.SetDefaultBackdrop_NoBackground(self, abs(config.size))

        -- update color
        self:SetBackdropBorderColor(AW.UnpackColor(config.color))
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateTargetHighlight(parent, name)
    local highlight = CreateFrame("Frame", name, parent, "BackdropTemplate")
    highlight.root = parent
    highlight:Hide()

    -- events
    BFI.AddEventHandler(highlight)

    -- functions
    highlight.Enable = TargetHighlight_Enable
    highlight.Update = TargetHighlight_Update
    highlight.LoadConfig = TargetHighlight_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(highlight)

    return highlight
end