---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function NameText_Update(self)
    self:UpdateName()
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function NameText_Enable(self)
    self:SetUnit(self.root.effectiveUnit)
    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function NameText_LoadConfig(self, config)
    self:SetFont(config.font)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)
    self:SetLength(config.length)
    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function NameText_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = NameText_EnableConfigMode
    self.Update = AF.noop

    self:UpdateName()

    self:SetShown(self.enabled)
end

local function NameText_DisableConfigMode(self)
    self.Enable = NameText_Enable
    self.Update = NameText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateNameText(parent, name)
    local text = AF.CreateSecretNameText(parent, name)
    text.root = parent

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = NameText_Enable
    text.Update = NameText_Update
    text.EnableConfigMode = NameText_EnableConfigMode
    text.DisableConfigMode = NameText_DisableConfigMode
    text.LoadConfig = NameText_LoadConfig

    return text
end