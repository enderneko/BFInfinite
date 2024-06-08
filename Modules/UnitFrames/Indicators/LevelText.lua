---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitClassification = UnitClassification
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsConnected = UnitIsConnected
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local QuestDifficultyColors = QuestDifficultyColors
local GetPetTeamAverageLevel = C_PetJournal and C_PetJournal.GetPetTeamAverageLevel

--! for AI followers
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- color
---------------------------------------------------------------------
local function GetLevelColor(unit)
    if BFI.vars.isRetail and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
        local teamLevel = GetPetTeamAverageLevel()
        local level = UnitBattlePetLevel(unit)
        if teamLevel ~= level then
            color = GetRelativeDifficultyColor(teamLevel, level)
        else
            color = QuestDifficultyColors.difficult
        end
    else
        color = GetCreatureDifficultyColor(UnitEffectiveLevel(unit))
    end
    return color.r, color.g, color.b
end

local function UpdateColor(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local class = UnitClassBase(unit)

    local r, g, b
    if self.color.type == "level_color" then
        r, g, b = GetLevelColor(unit)
    elseif self.color.type == "class_color" then
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
local function UpdateLevel(self, event, unitId)
    local unit = self.root.unit
    if type(unitId) == "string" and unit ~= unitId then return end

    local level = UnitEffectiveLevel(unit)
    local plus = strfind(UnitClassification(unit), "elite$") and "+" or ""

    if level > 0 then
        self:SetText(level..plus)
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
    -- if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function LevelText_LoadConfig(self, config)
    U.SetFont(self, unpack(config.font))
    UF.LoadTextPosition(self, config)

    self.color = config.color
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateLevelText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent

    -- events
    BFI.AddEventHandler(text)

    -- functions
    text.Enable = LevelText_Enable
    text.Update = LevelText_Update
    text.LoadConfig = LevelText_LoadConfig

    return text
end