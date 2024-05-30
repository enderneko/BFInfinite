local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local C = BFI.M_C
local UF = BFI.M_UF

---------------------------------------------------------------------
-- SetCooldown
---------------------------------------------------------------------
local function Aura_SetCooldown(self, start, duration, auraType, texture, count)
    self:SetBackdropBorderColor(C.GetAuraTypeColor(auraType))
    self.icon:SetTexture(texture)
    self:Show()
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function Aura_SetStackFont(self, config)
    U.SetFont(self.stack, unpack(config.font))
    self.stack:SetTextColor(unpack(config.color))
end

local function Aura_SetDurationFont(self, config)
    U.SetFont(self.duration, unpack(config.font))
    self.duration:SetTextColor(unpack(config.color))
end

local function Aura_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.RePoint(self.icon)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateAura(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:Hide()

    AW.SetDefaultBackdrop(frame)

    -- TODO: cooldown

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AW.SetOnePixelInside(icon, frame)
    icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)

    -- stack text
    local stack = frame:CreateFontString(nil, "OVERLAY")
    frame.stack = stack

    -- duration text
    local duration = frame:CreateFontString(nil, "OVERLAY")
    frame.duration = duration

    -- functions
    frame.SetCooldown = Aura_SetCooldown
    frame.SetStackFont = Aura_SetStackFont
    frame.SetDurationFont = Aura_SetDurationFont

    -- pixels
    -- AW.AddToPixelUpdater(frame, Aura_UpdatePixels)
    frame.UpdatePixels = Aura_UpdatePixels

    return frame
end