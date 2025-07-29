---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local IsResting = IsResting

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RestingIndicator_Update(self)
    self:SetShown(IsResting())
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RestingIndicator_Enable(self)
    self:RegisterEvent("PLAYER_UPDATE_RESTING", RestingIndicator_Update)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", RestingIndicator_Update)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RestingIndicator_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)

    if config.style == "blizzard" then
        self.texture:Show()
        for i, l in next, self.letters do
            l:Hide()
        end
        AF.SetSize(self, config.size, config.size)
        self:SetScript("OnShow", function()
            self.blizzard_ag:Play()
        end)
        self:SetScript("OnHide", function()
            self.blizzard_ag:Stop()
        end)
    else
        self.texture:Hide()
        for i, l in next, self.letters do
            l:Show()
            AF.SetFont(l, AF.GetFont("CloseAndOpen", BFI.name), config.size, "outline")
            l:SetText("Z")

            if i == 1 then
                l:SetPoint("LEFT", 0, -5)
            else
                l:SetPoint("LEFT", self.letters[i - 1], "RIGHT", -l:GetStringWidth() * 0.35, 0)
            end
        end
        self:SetSize(self.letters[1]:GetStringWidth() * 0.7 * 3, self.letters[1]:GetStringHeight())
        self:SetScript("OnShow", function()
            self.bfi_ag:Play()
        end)
        self:SetScript("OnHide", function()
            self.bfi_ag:Stop()
        end)
    end
    self:Hide()
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function RestingIndicator_EnableConfigMode(self)
    self.Enable = RestingIndicator_EnableConfigMode
    self.Update = AF.noop

    self:UnregisterAllEvents()
    self:Show()
end

local function RestingIndicator_DisableConfigMode(self)
    self.Enable = RestingIndicator_Enable
    self.Update = RestingIndicator_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRestingIndicator(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture = texture
    texture:SetAllPoints()
    texture:SetAtlas("UI-HUD-UnitFrame-Player-Rest-Flipbook")
    texture:SetParentKey("Flipbook")

    -- blizzard
    local blizzard_ag = frame:CreateAnimationGroup()
    frame.blizzard_ag = blizzard_ag
    blizzard_ag:SetLooping("REPEAT")

    local flip = blizzard_ag:CreateAnimation("FlipBook")
    flip:SetChildKey("Flipbook")
    flip:SetDuration(1.5)
    flip:SetFlipBookColumns(6)
    flip:SetFlipBookRows(7)
    flip:SetFlipBookFrames(42)

    -- bfi
    local letters = {}
    frame.letters = letters

    letters[1] = frame:CreateFontString()
    letters[2] = frame:CreateFontString()
    letters[3] = frame:CreateFontString()

    local bfi_ag = frame:CreateAnimationGroup()
    frame.bfi_ag = bfi_ag
    bfi_ag:SetLooping("REPEAT")

    for i, l in next, letters do
        l:SetTextColor(1, 0.84, 0.1)
        l:SetAlpha(0)
        l:SetDrawLayer("ARTWORK", i)

        -- fade in
        l.fade_in = bfi_ag:CreateAnimation("Alpha")
        l.fade_in:SetFromAlpha(0)
        l.fade_in:SetToAlpha(1)
        l.fade_in:SetDuration(0.25)
        l.fade_in:SetOrder(1)
        l.fade_in:SetTarget(l)
        l.fade_in:SetStartDelay(i * 0.3)

        -- move up
        l.move_up = bfi_ag:CreateAnimation("Translation")
        l.move_up:SetOffset(0, 5)
        l.move_up:SetDuration(0.25)
        l.move_up:SetOrder(1)
        l.move_up:SetTarget(l)
        l.move_up:SetStartDelay(i * 0.3)

        -- fade out
        l.fade_out = bfi_ag:CreateAnimation("Alpha")
        l.fade_out:SetFromAlpha(1)
        l.fade_out:SetToAlpha(0)
        l.fade_out:SetDuration(0.5)
        l.fade_out:SetOrder(2)
        l.fade_out:SetTarget(l)
        l.fade_out:SetStartDelay(i * 0.3)
    end

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = RestingIndicator_Enable
    frame.Update = RestingIndicator_Update
    frame.EnableConfigMode = RestingIndicator_EnableConfigMode
    frame.DisableConfigMode = RestingIndicator_DisableConfigMode
    frame.LoadConfig = RestingIndicator_LoadConfig

    return frame
end