local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local Clamp = Clamp

local function UpdateValue(self)
    if self.value == self.min or self.max == 0 then
        self.fg:SetWidth(0.1)
    else
        self.value = Clamp(self.value, self.min, self.max)
        local p = (self.value - self.min) / (self.max - self.min)
        AW.SetWidth(self.fg, p * (self._width - 2))
    end
end

local prototype = {
    -- appearance
    SetTexture = function(self, texture)
        texture = U.GetBarTexture(texture)
        self.fg:SetTexture(texture)
        self.loss:SetTexture(texture)
    end,
    SetColor = function(self, r, g, b, a)
        self.fg:SetVertexColor(r, g, b, a)
    end,
    SetLossColor = function(self, r, g, b, a)
        self.loss:SetVertexColor(r, g, b, a)
    end,
    SetBackgroundColor = function(self, r, g, b, a)
        self:SetBackdropColor(r, g, b, a)
    end,
    SetBorderColor = function(self, r, g, b, a)
        self:SetBackdropBorderColor(r, g, b, a)
    end,

    -- smooth
    SetSmoothing = function(self, smoothing)
        self:ResetSmoothedValue()
        if smoothing then
            self.SetBarValue = self.SetSmoothedValue
            self.SetBarMinMaxValues = self.SetMinMaxSmoothedValue
        else
            self.SetBarValue = self.SetValue
            self.SetBarMinMaxValues = self.SetMinMaxValues
        end
    end,

    -- get
    GetMinMaxValues = function(self)
        return self.min, self.max
    end,
    GetValue = function(self)
        return self.value
    end,

    -- set
    SetMinMaxValues = function(self, min, max)
        self.min = min
        self.max = max
        UpdateValue(self)
    end,
    -- SetMaxValue = function(self, max)
    --     self.max = max,
    --     UpdateValue(self)
    -- end,
    -- SetMinValue = function(self, min)
    --     self.min = min,
    --     UpdateValue(self)
    -- end,
    SetValue = function(self, value)
        self.value = value
        UpdateValue(self)
    end,

    -- pixel perfect
    UpdatePixels = function(self)
        AW.ReSize(self)
        AW.RePoint(self)
        AW.ReBorder(self)
        AW.ReSize(self.fg)
        AW.RePoint(self.fg)
        AW.RePoint(self.loss)
    end,
}

function UF.CreateBar(parent, name)
    local bar = CreateFrame("Frame", name, parent, "BackdropTemplate")
    AW.SetDefaultBackdrop(bar)

    bar.min = 0
    bar.max = 0
    bar.value = 0

    Mixin(bar, UF.SmoothStatusBarMixin)

    local fg = bar:CreateTexture(nil, "ARTWORK", nil, 0)
    bar.fg = fg
    AW.SetPoint(fg, "TOPLEFT", 1, -1)
    AW.SetPoint(fg, "BOTTOMLEFT", 1, 1)
    -- already done in PixelUtil
    -- fg:SetTexelSnappingBias(0)
    -- fg:SetSnapToPixelGrid(false)

    local loss = bar:CreateTexture(nil, "ARTWORK", nil, 0)
    bar.loss = loss
    AW.SetPoint(loss, "TOPLEFT", fg, "TOPRIGHT")
    AW.SetPoint(loss, "BOTTOMLEFT", fg, "BOTTOMRIGHT")
    AW.SetPoint(loss, "TOPRIGHT", -1, -1)
    AW.SetPoint(loss, "BOTTOMRIGHT", -1, 1)

    for k, v in pairs(prototype) do
        bar[k] = v
    end

    -- pixel perfect
    AW.AddToPixelUpdater(bar)

    return bar
end