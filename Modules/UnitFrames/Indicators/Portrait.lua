---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- the portrait frame
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitClassBase = AF.UnitClassBase

local function UpdatePortrait3DAlpha(parent, alpha)
    local portrait = parent.indicators.portrait
    if portrait and portrait.enabled and portrait.style == "3d" then
        portrait.model:SetModelAlpha(alpha)
    end
end

--! only for non-smooth health bar
-- local function UpdatePortrait3DCutaway(self, _, unitId)
--     local unit = self.root.displayedUnit
--     if unitId and unit ~= unitId then return end

--     local cur = UnitHealth(unit)
--     local max = UnitHealthMax(unit)

--     local width = self.healthBar:GetBarWidth()
--     local inset = (cur / max * width) - width
--     self.model:SetViewInsets(0, inset, 0, 0)
-- end

local function UpdatePortrait3D(self, unit)
    local model = self.model
    local config = self.modelConfig

    if UnitIsConnected(unit) and UnitIsVisible(unit) then
        model:SetCamDistanceScale(config.camDistanceScale)
        model:SetPortraitZoom(config.zoom or 1)
        model:SetPosition(0, 0, 0)
        model:SetRotation(rad(config.rotation))
        model:SetViewTranslation(config.xOffset, config.yOffset)
        -- model:SetViewInsets(0, 0, 0, 0)
        model:ClearModel()
        model:SetUnit(unit)
        model:SetAnimation(804) -- StandCharacterCreate, no idle animation
    else
        model:SetCamDistanceScale(0.75)
        model:SetPortraitZoom(0)
        model:SetPosition(0, 0, 0.25)
        model:SetRotation(0)
        model:SetViewTranslation(0, 0)
        -- model:SetViewInsets(0, 0, 0, 0)
        model:ClearModel()
        model:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
    end

    model:SetModelAlpha(self.root:GetAlpha())
end

local function UpdatePortrait2D(self, unit)
    self.texture:SetTexCoord(AF.Unpack8(AF.CalcTexCoordPreCrop(0.12, self:GetWidth() / self:GetHeight())))
    SetPortraitTexture(self.texture, unit)
end

local function UpdatePortraitClassIcon(self, unit)
    self.texture:SetTexCoord(AF.Unpack8(AF.CalcTexCoordPreCrop(0.12, self:GetWidth() / self:GetHeight())))
    local class = UnitClassBase(unit)
    if class then
        self.texture:SetAtlas("classicon-"..class)
    else
        self.texture:SetAtlas("QuestTurnin")
    end
end

local function UpdatePortrait(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    if self.style == "3d" then
        UpdatePortrait3D(self, unit)
        -- if self.cutaway then
        --     UpdatePortrait3DCutaway(self)
        -- end
    elseif self.style == "2d" then
        UpdatePortrait2D(self, unit)
    else
        UpdatePortraitClassIcon(self, unit)
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function Portrait_Enable(self)
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE", UpdatePortrait)
    self:RegisterEvent("UNIT_MODEL_CHANGED", UpdatePortrait)

    -- if self.cutaway then
    --     self:RegisterEvent("UNIT_HEALTH", UpdatePortrait3DCutaway)
    --     self:RegisterEvent("UNIT_MAXHEALTH", UpdatePortrait3DCutaway)
    -- else
    --     self:UnregisterEvent("UNIT_HEALTH")
    --     self:UnregisterEvent("UNIT_MAXHEALTH")
    -- end

    self:Show()
    self:Update(true)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function Portrait_Update(self, force)
    --! only accept force update
    if force then
        UpdatePortrait(self)
    end
end

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local function Portrait_LoadConfig(self, config)
    AF.SetSize(self, config.width, config.height)
    AF.SetFrameLevel(self, config.frameLevel, self.root)

    -- cutaway (not ideal)
    -- if config.anchorTo == "healthBar" then
    --     AF.ClearPoints(self)
    --     if config.style == "3d" and config.cutaway then
    --         self.cutaway = true
    --         self.healthBar = self.root.indicators.healthBar
    --         AF.SetPoint(self, "TOPLEFT")
    --         AF.SetPoint(self, "BOTTOMRIGHT", self.healthBar.fg.mask)
    --         self:SetBackdropColor(0, 0, 0, 0)
    --         self:SetBackdropBorderColor(0, 0, 0, 0)
    --     else
    --         self.cutaway = nil
    --         self.healthBar = nil
    --         self:SetAllPoints(self.root.indicators.healthBar)
    --         self:SetBackdropColor(unpack(config.bgColor))
    --         self:SetBackdropBorderColor(unpack(config.borderColor))
    --     end
    -- else
    --     UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    --     self.cutaway = nil
    --     self.healthBar = nil
    --     self:SetBackdropColor(unpack(config.bgColor))
    --     self:SetBackdropBorderColor(unpack(config.borderColor))
    -- end

    -- if config.anchorTo == "healthBar" then
    --     AF.ClearPoints(self)
    --     self:SetAllPoints(self.root.indicators.healthBar)
    -- else
        UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    -- end

    self:SetBackdropColor(unpack(config.bgColor))
    self:SetBackdropBorderColor(unpack(config.borderColor))

    if config.style == "3d" then
        self.model:Show()
        self.texture:Hide()
        self.modelConfig = config.model

        self.model:SetPoint("TOPLEFT", config.model.x1Fix, config.model.y1Fix)
        self.model:SetPoint("BOTTOMRIGHT", config.model.x2Fix, config.model.y2Fix)
    else
        self.model:Hide()
        self.texture:Show()
        self.modelConfig = nil
    end

    self.style = config.style
end

local function Portrait_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.model)
    AF.RePoint(self.texture)
    if self:IsVisible() and self.style == "3d" then
        UpdatePortrait(self)
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function Portrait_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = Portrait_EnableConfigMode
    self.Update = AF.noop

    Portrait_Update(self, true)

    self:SetShown(self.enabled)
end

local function Portrait_DisableConfigMode(self)
    self.Enable = Portrait_Enable
    self.Update = Portrait_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePortrait(parent, name)
    local portrait = CreateFrame("Frame", name, parent, "BackdropTemplate")
    portrait.root = parent
    portrait:Hide()
    AF.ApplyDefaultBackdrop(portrait)

    hooksecurefunc(parent, "SetAlpha", UpdatePortrait3DAlpha)

    -- events
    AF.AddEventHandler(portrait)

    -- 3d
    portrait.model = CreateFrame("PlayerModel", nil, portrait)

    -- NOTE: LIKE A SHIT!
    -- portrait.model:SetPoint("TOPLEFT", 1, -0.5)
    -- portrait.model:SetPoint("BOTTOMRIGHT", -1.5, 2)
    -- AF.SetOnePixelInside(portrait.model, portrait)
    -- AF.SetPoint(portrait.model, "TOPLEFT", portrait, 1, -1)
    -- AF.SetPoint(portrait.model, "BOTTOMRIGHT", portrait, -1, 2)

    -- 2d
    portrait.texture = portrait:CreateTexture(nil, "ARTWORK")
    AF.SetOnePixelInside(portrait.texture, portrait)

    -- functions
    portrait.Enable = Portrait_Enable
    portrait.Update = Portrait_Update
    portrait.EnableConfigMode = Portrait_EnableConfigMode
    portrait.DisableConfigMode = Portrait_DisableConfigMode
    portrait.LoadConfig = Portrait_LoadConfig

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(portrait, Portrait_UpdatePixels)

    return portrait
end