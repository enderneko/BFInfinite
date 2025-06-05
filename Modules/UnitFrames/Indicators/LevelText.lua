---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitClassBase = AF.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local r, g, b
    if self.color.type == "level_color" then
        r, g, b = AF.GetLevelColor(unit)
    elseif self.color.type == "class_color" then
        local class = UnitClassBase(unit)
        if AF.UnitIsPlayer(unit) then
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    else
        r, g, b = unpack(self.color.rgb)
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- level
---------------------------------------------------------------------
local function UpdateLevel(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    self:SetText(AF.GetLevelText(unit))
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function LevelText_Update(self)
    UpdateLevel(self)
    UpdateColor(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function LevelText_Enable(self)
    self:RegisterEvent("UNIT_LEVEL", UpdateLevel, UpdateColor)
    self:RegisterEvent("PLAYER_LEVEL_UP", UpdateLevel, UpdateColor)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LevelText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLevelText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Enable = LevelText_Enable
    text.Update = LevelText_Update
    text.LoadConfig = LevelText_LoadConfig

    return text
end