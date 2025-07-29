---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- OnEnter / OnLeave
---------------------------------------------------------------------
local function MouseoverHighlight_OnEnter(self)
    if self.indicators.mouseoverHighlight.enabled then
        self.indicators.mouseoverHighlight:Show()
    end
end

local function MouseoverHighlight_OnLeave(self)
    self.indicators.mouseoverHighlight:Hide()
end

---------------------------------------------------------------------
-- enable / update
---------------------------------------------------------------------
local function MouseoverHighlight_Enable(self) end
local function MouseoverHighlight_Update(self) end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function MouseoverHighlight_LoadConfig(self, config)
    self.enabled = config.enabled and config.size ~= 0

    AF.SetFrameLevel(self, config.frameLevel, self.root)

    if config.size ~= 0 then
        -- AF.ClearPoints(self)

        -- -- update point
        -- if config.size < 0 then
        --     AF.SetPoint(self, "TOPLEFT")
        --     AF.SetPoint(self, "BOTTOMRIGHT")
        -- else
        --     AF.SetPoint(self, "TOPLEFT", -config.size, config.size)
        --     AF.SetPoint(self, "BOTTOMRIGHT", config.size, -config.size)
        -- end

        -- -- update thickness
        -- AF.ApplyDefaultBackdrop_NoBackground(self, abs(config.size))

        -- -- update color
        -- self:SetBackdropBorderColor(AF.UnpackColor(config.color))

        -- update thichness
        local thickness = abs(config.size)
        AF.ClearPoints(self.mask)
        AF.ClearPoints(self.tex)

        if config.size < 0 then
            AF.SetPoint(self.mask, "TOPLEFT", thickness, -thickness)
            AF.SetPoint(self.mask, "BOTTOMRIGHT", -thickness, thickness)
            self.tex:SetAllPoints()
        else
            AF.SetPoint(self.tex, "TOPLEFT", -thickness, thickness)
            AF.SetPoint(self.tex, "BOTTOMRIGHT", thickness, -thickness)
            self.mask:SetAllPoints()
        end

        -- update color
        self.tex:SetVertexColor(AF.UnpackColor(config.color))
    else
        self:Hide()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateMouseoverHighlight(parent, name)
    local highlight = CreateFrame("Frame", name, parent)
    highlight.root = parent
    highlight:Hide()
    highlight:SetAllPoints()
    highlight:SetIgnoreParentAlpha(true)

    parent:HookScript("OnEnter", MouseoverHighlight_OnEnter)
    parent:HookScript("OnLeave", MouseoverHighlight_OnLeave)

    -- mask
    local mask = highlight:CreateMaskTexture()
    highlight.mask = mask
    mask:SetTexture(AF.GetEmptyTexture(), "CLAMPTOWHITE","CLAMPTOWHITE", "NEAREST")

    -- texture
    local tex = highlight:CreateTexture(nil, "BORDER")
    highlight.tex = tex
    tex:SetTexture(AF.GetPlainTexture(), nil, nil, "NEAREST")
    tex:AddMaskTexture(mask)

    -- events
    AF.AddEventHandler(highlight)

    -- functions
    highlight.Enable = MouseoverHighlight_Enable
    highlight.Update = MouseoverHighlight_Update
    highlight.LoadConfig = MouseoverHighlight_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(highlight)

    return highlight
end