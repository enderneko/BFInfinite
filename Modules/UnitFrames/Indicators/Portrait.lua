---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- the portrait frame
---------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitClassBase = U.UnitClassBase
local mult = math.pi / 180

local function Portrait_Update_3D(self, unit)
    local model = self.model
    local config = self.modelConfig

    if UnitIsConnected(unit) and UnitIsVisible(unit) then
        model:SetCamDistanceScale(config.camDistanceScale)
        model:SetPortraitZoom(1)
        model:SetPosition(0, 0, 0)
        model:SetViewTranslation(config.xOffset, config.yOffset)
        model:SetRotation(config.rotation * mult)
        model:ClearModel()
        model:SetUnit(unit)
        model:SetAnimation(804) -- StandCharacterCreate, no idle animation
    else
        model:SetCamDistanceScale(1.75)
        model:SetPortraitZoom(0)
        model:SetPosition(0, 0, 0.25)
        -- if model:GetFacing() ~= (config.rotation * mult) then
        --     model:SetFacing(config.rotation * mult)
        -- end
        model:ClearModel()
        model:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
    end
end

local function Portrait_Update_2D(self, unit)
    self.texture:SetTexCoord(unpack(AW.CalcTexCoord(self:GetWidth(), self:GetHeight())))
    SetPortraitTexture(self.texture, unit)
end

local function Portrait_Update_ClassIcon(self, unit)
    self.texture:SetTexCoord(unpack(AW.CalcTexCoord(self:GetWidth(), self:GetHeight())))
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

    if self.type == "3d" then
        Portrait_Update_3D(self, unit)
    elseif config.type == "2d" then
        Portrait_Update_2D(self, unit)
    else
        Portrait_Update_ClassIcon(self, unit)
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function Portrait_Enable(self)
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE", UpdatePortrait)
    self:RegisterEvent("UNIT_MODEL_CHANGED", UpdatePortrait)

    self:Show()
    if self:IsVisible() then self:Update(true) end
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
    AW.SetSize(self, config.width, config.height)

    -- if config.anchorTo == "button" then
        self:SetParent(self.root)
        UF.LoadIndicatorPosition(self, config.position)
        AW.SetFrameLevel(self, config.frameLevel, self.root)
    -- elseif config.anchorTo == "healthBar" then
    --     AW.ClearPoints(self)
    --     self:SetParent(self.root.indicators.healthBar)
    --     self:SetAllPoints()
    --     self:SetFrameLevel(0) -- bottom layer
    -- end

    self:SetBackdropColor(unpack(config.bgColor))
    self:SetBackdropBorderColor(unpack(config.borderColor))

    if config.type == "3d" then
        self.model:Show()
        self.texture:Hide()
        self.modelConfig = config.model
    else
        self.model:Hide()
        self.texture:Show()
        self.modelConfig = nil
    end

    self.type = config.type
end

local function Portrait_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
    AW.RePoint(self.model)
    AW.RePoint(self.texture)
    if self.type == "3d" then
        UpdatePortrait(self)
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreatePortrait(parent, name)
    local portrait = CreateFrame("Frame", name, parent, "BackdropTemplate")
    portrait.root = parent
    portrait:Hide()
    AW.SetDefaultBackdrop(portrait)

    -- events
    BFI.AddEventHandler(portrait)

    -- 3d
    portrait.model = CreateFrame("PlayerModel", nil, portrait)

    -- NOTE: LIKE A SHIT!
    portrait.model:SetPoint("TOPLEFT", 1, -0.5)
    portrait.model:SetPoint("BOTTOMRIGHT", -1.5, 2)
    -- AW.SetOnePixelInside(portrait.model, portrait)
    -- AW.SetPoint(portrait.model, "TOPLEFT", portrait, 1, -1)
    -- AW.SetPoint(portrait.model, "BOTTOMRIGHT", portrait, -1, 2)

    -- 2d
    portrait.texture = portrait:CreateTexture(nil, "ARTWORK")
    AW.SetOnePixelInside(portrait.texture, portrait)

    -- functions
    portrait.Enable = Portrait_Enable
    portrait.Update = Portrait_Update
    portrait.LoadConfig = Portrait_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(portrait, Portrait_UpdatePixels)

    return portrait
end