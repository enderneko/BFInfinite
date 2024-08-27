---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local function UpdateName(self, event, unitId)
    local unit = self.root.displayedUnit
    if unitId and unit ~= unitId then return end

    local name = UnitName(unit)
    if not name then return end

    local class = UnitClassBase(unit)

    -- length
    AW.SetText(self, name, self.length)

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
    else
        if U.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AW.GetClassColor(class)
            else
                r, g, b = unpack(self.color.rgb)
            end
        else
            r, g, b = unpack(self.color.rgb)
        end
    end
    self:SetTextColor(r, g, b)
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
    self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
    self:RegisterEvent("UNIT_FACTION", UpdateName)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function NameText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.length = config.length
    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function NameText_EnableConfigMode(self)
    self.Enable = NameText_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    UpdateName(self)
    self:Show()
end

local function NameText_DisableConfigMode(self)
    self.Enable = NameText_Enable
    self.Update = NameText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateNameText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = NameText_Enable
    text.Update = NameText_Update
    text.EnableConfigMode = NameText_EnableConfigMode
    text.DisableConfigMode = NameText_DisableConfigMode
    text.LoadConfig = NameText_LoadConfig

    return text
end