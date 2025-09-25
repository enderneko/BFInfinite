---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local NP = BFI.modules.Nameplates

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local UnitClassBase = AF.UnitClassBase

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local r, g, b
    if self.color.type == "level_color" then
        r, g, b = AF.ExtractColor(GetCreatureDifficultyColor(UnitEffectiveLevel(unit)))
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
local highLevelTexture = "|T"..AF.GetTexture("HighLevelTexture", BFI.name)..":%d|t"
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
    self:RegisterUnitEvent("UNIT_LEVEL", self.root.unit, UpdateLevel, UpdateColor)
    self:RegisterEvent("PLAYER_LEVEL_UP", UpdateLevel, UpdateColor)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LevelText_LoadConfig(self, config)
    AF.SetFont(self, unpack(config.font))
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo, config.parent)

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
    AF.AddEventHandler(text)

    -- functions
    text.Enable = LevelText_Enable
    text.Update = LevelText_Update
    text.LoadConfig = LevelText_LoadConfig

    return text
end