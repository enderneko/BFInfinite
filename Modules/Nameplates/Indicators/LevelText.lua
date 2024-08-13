---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local NP = BFI.NamePlates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local UnitClassBase = U.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local r, g, b
    if self.color.type == "level_color" then
        r, g, b = AW.ExtractColor(GetCreatureDifficultyColor(UnitEffectiveLevel(unit)))
    elseif self.color.type == "class_color" then
        local class = UnitClassBase(unit)
        if U.UnitIsPlayer(unit) then
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
    else
        r, g, b = unpack(self.color.rgb)
    end
    self:SetTextColor(r, g, b)
end

---------------------------------------------------------------------
-- level
---------------------------------------------------------------------
local highLevelTexture = "|T"..AW.GetTexture("HighLevelTexture")..":%d|t"
local function UpdateLevel(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local level = UnitEffectiveLevel(unit)
    local plus = strfind(UnitClassification(unit), "elite$") and "+" or ""

    if level > 0 then
        self:SetText(level..plus)
    elseif self.highLevelTextureEnabled then
        self:SetText(highLevelTexture:format(self.highLevelTextureSize))
    else
        self:SetText("??")
    end
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
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LevelText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.color = config.color
    self.highLevelTextureEnabled = config.highLevelTexture.enabled
    self.highLevelTextureSize = config.highLevelTexture.size
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function NP.CreateLevelText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent
    text:Hide()

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = LevelText_Enable
    text.Update = LevelText_Update
    text.LoadConfig = LevelText_LoadConfig

    return text
end