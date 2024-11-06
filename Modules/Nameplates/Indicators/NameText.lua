---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitIsSameServer = UnitIsSameServer
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local function UpdateName(self, event, unitId)
    local unit = self.root.unit
    if unitId and unit ~= unitId then return end

    local name = UnitName(unit)
    if not name then return end

    local class = UnitClassBase(unit)

    -- length
    AF.SetText(self, name, self.length, (self.showOtherServerSign and not UnitIsSameServer(unit)) and "*")

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    else
        if U.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AF.GetClassColor(class)
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
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.root.unit, UpdateName)
    self:RegisterUnitEvent("UNIT_FACTION", self.root.unit, UpdateName)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function NameText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.length = config.length
    self.color = config.color
    self.showOtherServerSign = config.showOtherServerSign
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateNameText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = NameText_Enable
    text.Update = NameText_Update
    text.LoadConfig = NameText_LoadConfig

    return text
end