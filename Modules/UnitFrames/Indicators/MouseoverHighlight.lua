---@class BFI
local BFI = select(2, ...)
local AW = BFI.AW
local UF = BFI.M_UnitFrames

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
function UF.CreateMouseoverHighlight(parent, name)
    local highlight = CreateFrame("Frame", name, parent, "BackdropTemplate")
    highlight.root = parent
    highlight:Hide()

    parent:HookScript("OnEnter", MouseoverHighlight_OnEnter)
    parent:HookScript("OnLeave", MouseoverHighlight_OnLeave)

    -- events
    BFI.AddEventHandler(highlight)

    -- functions
    highlight.Enable = MouseoverHighlight_Enable
    highlight.Update = MouseoverHighlight_Update
    highlight.LoadConfig = MouseoverHighlight_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(highlight)

    return highlight
end