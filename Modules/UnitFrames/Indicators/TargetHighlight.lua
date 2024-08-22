---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.UnitFrames

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
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function TargetHighlight_LoadConfig(self, config)
    self.enabled = config.enabled and config.size ~= 0

    AW.SetFrameLevel(self, config.frameLevel, self.root)

    if config.size ~= 0 then
        -- AW.ClearPoints(self)

        -- -- update point
        -- if config.size < 0 then
        --     AW.SetPoint(self, "TOPLEFT")
        --     AW.SetPoint(self, "BOTTOMRIGHT")
        -- else
        --     AW.SetPoint(self, "TOPLEFT", -config.size, config.size)
        --     AW.SetPoint(self, "BOTTOMRIGHT", config.size, -config.size)
        -- end

        -- -- update thickness
        -- AW.SetDefaultBackdrop_NoBackground(self, abs(config.size))

        -- -- update color
        -- self:SetBackdropBorderColor(AW.UnpackColor(config.color))

        -- update thichness
        local thickness = abs(config.size)
        AW.ClearPoints(self.mask)
        AW.ClearPoints(self.tex)

        if config.size < 0 then
            AW.SetPoint(self.mask, "TOPLEFT", thickness, -thickness)
            AW.SetPoint(self.mask, "BOTTOMRIGHT", -thickness, thickness)
            self.tex:SetAllPoints()
        else
            AW.SetPoint(self.tex, "TOPLEFT", -thickness, thickness)
            AW.SetPoint(self.tex, "BOTTOMRIGHT", thickness, -thickness)
            self.mask:SetAllPoints()
        end

        -- update color
        self.tex:SetVertexColor(AW.UnpackColor(config.color))
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateTargetHighlight(parent, name)
    local highlight = CreateFrame("Frame", name, parent)
    highlight.root = parent
    highlight:Hide()
    highlight:SetAllPoints()

    -- mask
    local mask = highlight:CreateMaskTexture()
    highlight.mask = mask
    mask:SetTexture(AW.GetTexture("Empty", true), "CLAMPTOWHITE","CLAMPTOWHITE")

    -- texture
    local tex = highlight:CreateTexture(nil, "BORDER")
    highlight.tex = tex
    tex:SetTexture(AW.GetTexture("White", true))
    tex:AddMaskTexture(mask)

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