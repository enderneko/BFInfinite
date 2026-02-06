---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitClassBase = AF.UnitClassBase
local issecretvalue = issecretvalue

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local function UpdateName(self, event, unitId)
    local unit = self.root.effectiveUnit
    -- if unitId and unit ~= unitId then return end

    local name = UnitName(unit)
    if not name then
        self:SetText(nil)
        self:SetColor(AF.GetColorRGB("darkgray"))
        return
    end

    -- color
    local class = UnitClassBase(unit)
    local r, g, b
    if self.color.type == "class_color" then
        if AF.UnitIsPlayer(unit) then
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    else
        if AF.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AF.GetClassColor(class)
            else
                r, g, b = unpack(self.color.rgb)
            end
        else
            r, g, b = unpack(self.color.rgb)
        end
    end

    self:SetText(name)
    self:SetColor(r, g, b)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function NameText_Update(self)
    UpdateName(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function NameText_Enable(self)
    local effectiveUnit = self.root.effectiveUnit

    self:RegisterUnitEvent("UNIT_NAME_UPDATE", effectiveUnit, UpdateName)
    self:RegisterUnitEvent("UNIT_FACTION", effectiveUnit, UpdateName)

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

    UpdateName(self)

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