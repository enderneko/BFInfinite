---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.M_Shared
local NP = BFI.M_NamePlates

local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local UnitIsUnit = UnitIsUnit
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack

local Auras_UpdateSize, Auras_UpdateSiblings

---------------------------------------------------------------------
-- sort
---------------------------------------------------------------------
local function SortAuras(a, b)
    if a.priority ~= b.priority then
        return a.priority < b.priority
    end

    if a.isBossAura ~= b.isBossAura then
        return a.isBossAura
    end

    if a.noDuration ~= b.noDuration then
        return b.noDuration
    end

    return a.auraInstanceID < b.auraInstanceID
end

---------------------------------------------------------------------
-- UpdateExtraData
---------------------------------------------------------------------
local function IsCastByMe(source)
    return source and (UnitIsUnit("player", source) or UnitIsOwnerOrControllerOfUnit("player", source))
end

local function IsCastByUnit(source, unit)
    return source and not UnitIsUnit(source, "player") and (UnitIsUnit(source, unit) or UnitIsOwnerOrControllerOfUnit(unit, source))
end

local function IsDispellable(self, auraData)
    if auraData.isHelpful then
        return auraData.isStealable
    end

    if auraData.isHarmful and UnitIsFriend("player", self.root.unit) and not UnitCanAttack("player", self.root.unit) then
        return U.CanDispel(auraData.debuffType)
    end
end

local function UpdateExtraData(self, auraData)
    -- local icon = auraData.icon
    -- local count = auraData.applications
    -- local auraType = auraData.dispelName
    -- local duration = auraData.duration
    -- local source = auraData.sourceUnit
    auraData.start = auraData.expirationTime - auraData.duration
    auraData.castByMe = IsCastByMe(auraData.sourceUnit)
    auraData.notCastByMe = not auraData.castByMe
    auraData.castByOthers = auraData.isFromPlayerOrPlayerPet and not auraData.castByMe
    auraData.castByUnit = IsCastByUnit(auraData.sourceUnit, self.root.unit)
    auraData.castByNPC = not auraData.isFromPlayerOrPlayerPet
    -- auraData.castByBoss = auraData.isBossAura
    -- auraData.castByUnknown = not auraData.sourceUnit
    auraData.debuffType = U.GetDebuffType(auraData)
    auraData.dispellable = IsDispellable(self, auraData)
    auraData.noDuration = auraData.duration == 0
    auraData.priority = self.priorities[auraData.spellId] or 999
end

---------------------------------------------------------------------
-- filters
---------------------------------------------------------------------
local function CheckAuraFilter(self, auraData)
    if self.auraFilter == "HARMFUL" then
        return auraData.isHarmful
    elseif self.auraFilter == "HELPFUL" then
        return auraData.isHelpful
    end
end

local function CheckFilters(self, auraData)
    -- blacklist
    if self.blacklist[auraData.spellId] then return end

    -- filter
    for f in pairs(self.filters) do
        if auraData[f] then
            return true
        end
    end
end

---------------------------------------------------------------------
-- UpdateAuraType
---------------------------------------------------------------------
local auraColorOrder = {"castByMe", "dispellable", "debuffType"}
local function GetAuraType(self, auraData)
    for _, type in pairs(self.colorTypes) do
        if auraData[type] then
            if type == "debuffType" then
                return auraData.debuffType
            else
                return type
            end
        end
    end
end

---------------------------------------------------------------------
-- ShowAura
---------------------------------------------------------------------
local function ShowAura(self, auraData)
    local aura = self.slots[self.numAuras]
    aura:SetCooldown(auraData.start, auraData.duration, auraData.applications, auraData.icon, GetAuraType(self, auraData))
end

---------------------------------------------------------------------
-- HandleUpdateInfo
---------------------------------------------------------------------
local function HandleUpdateInfo(self, updateInfo)
    local changed

    if updateInfo.addedAuras then
        for _, auraData in pairs(updateInfo.addedAuras) do
            if CheckAuraFilter(self, auraData) then
                self.auras[auraData.auraInstanceID] = true
                changed = true
            end
        end
    end

    if updateInfo.updatedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.updatedAuraInstanceIDs) do
            if self.auras[auraInstanceID] then
                changed = true
                break
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
            if self.auras[auraInstanceID] then
                self.auras[auraInstanceID] = nil
                changed = true
            end
        end
    end

    if changed then
        -- reset
        wipe(self.sortedAuras)

        -- sort
        for auraInstanceID in pairs(self.auras) do
            local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(self.root.unit, auraInstanceID)
            UpdateExtraData(self, auraData)
            if CheckFilters(self, auraData) then
                tinsert(self.sortedAuras, auraData)
            end
        end
        sort(self.sortedAuras, SortAuras)

        -- show
        self.numAuras = 0
        for i, auraData in pairs(self.sortedAuras) do
            self.numAuras = self.numAuras + 1
            ShowAura(self, auraData, i)
            if self.numAuras == self.numSlots then break end
        end

        -- resize
        Auras_UpdateSize(self, self.numAuras)
    else
        Auras_UpdateSiblings(self)
    end
end

---------------------------------------------------------------------
-- ForEachAura
---------------------------------------------------------------------
local function ForEachAura(self, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select("#", ...)
    for i = 1, n do
        local slot = select(i, ...)
        local auraData = GetAuraDataBySlot(self.root.unit, slot)
        UpdateExtraData(self, auraData)
        if CheckFilters(self, auraData) then
            self.auras[auraData.auraInstanceID] = true
            tinsert(self.sortedAuras, auraData)
        end
    end
end

local function HandleAllAuras(self)
    -- reset
    wipe(self.auras)
    wipe(self.sortedAuras)
    self.numAuras = 0

    -- iterate
    ForEachAura(self, GetAuraSlots(self.root.unit, self.auraFilter))

    -- sort
    sort(self.sortedAuras, SortAuras)

    -- show
    for i, auraData in pairs(self.sortedAuras) do
        self.numAuras = self.numAuras + 1
        ShowAura(self, auraData)
        if self.numAuras == self.numSlots then break end
    end

    -- resize
    Auras_UpdateSize(self, self.numAuras)
end

---------------------------------------------------------------------
-- UNIT_AURA
---------------------------------------------------------------------
local function UpdateAuras(self, event, unitId, updateInfo)
    local unit = self.root.unit
    if unitId and unitId ~= unit then return end

    local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

    if isFullUpdate then
        HandleAllAuras(self)
    else
        HandleUpdateInfo(self, updateInfo)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function Auras_Update(self)
    UpdateAuras(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function Auras_Enable(self)
    self:RegisterEvent("UNIT_AURA", UpdateAuras)

    self:Show()
    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- disable
---------------------------------------------------------------------
local function Auras_Disable(self)
    self:UnregisterAllEvents()
    self:Hide()
    wipe(self.auras)
    wipe(self.sortedAuras)
    self.numAuras = 0
end

---------------------------------------------------------------------
-- siblings
---------------------------------------------------------------------
local function Auras_AddSibling(self, sibling)
    if not self.siblings then
        self.siblings = {}
    end
    self.siblings[sibling] = true
end

local function Auras_RemoveSibling(self, sibling)
    if not self.siblings then
        return
    end
    self.siblings[sibling] = nil
end

function Auras_UpdateSiblings(self)
    if not self.siblings then
        return
    end
    for sibling in pairs(self.siblings) do
        AW.ClearPoints(sibling)
        if self.numAuras == 0 then
            AW.SetPoint(sibling, sibling.position[1], self, sibling.position[2])
        else
            AW.SetPoint(sibling, sibling.position[1], self, sibling.position[2], sibling.position[3], sibling.position[4])
        end
    end
end

---------------------------------------------------------------------
-- config
---------------------------------------------------------------------
function Auras_UpdateSize(self, numAuras)
    -- if not (self.width and self.height and self.orientation) then return end

    -- hide unused
    for i = numAuras + 1, self.numSlots do
        self.slots[i]:Hide()
    end

    -- set size
    local lines = ceil(numAuras / self.numPerLine)
    numAuras = min(numAuras, self.numPerLine)

    if self.isHorizontal then
        AW.SetGridSize(self, self.width, self.height, self.spacingH, self.spacingV, numAuras, lines)
    else
        AW.SetGridSize(self, self.width, self.height, self.spacingH, self.spacingV, lines, numAuras)
    end

    Auras_UpdateSiblings(self)
end

local function Auras_SetSize(self, width, height)
    self.width = width
    self.height = height

    for i = 1, self.numSlots do
        AW.SetSize(self.slots[i], width, height)
    end
end

local function Auras_SetOrientation(self, orientation)
    self.orientation = orientation

    assert(self.anchor, "[indicator] position must be set before SetOrientation")

    self.isHorizontal = not strfind(orientation, "top")

    local point1, point2, x, y
    local newLinePoint2, newLineX, newLineY

    if orientation == "left_to_right" then
        if strfind(self.anchor, "^BOTTOM") then
            point1 = "BOTTOMLEFT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            y = 0
            newLineY = self.spacingV
        else
            point1 = "TOPLEFT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            y = 0
            newLineY = -self.spacingV
        end
        x = self.spacingH
        newLineX = 0

    elseif orientation == "right_to_left" then
        if strfind(self.anchor, "^BOTTOM") then
            point1 = "BOTTOMRIGHT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            y = 0
            newLineY = self.spacingV
        else
            point1 = "TOPRIGHT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            y = 0
            newLineY = -self.spacingV
        end
        x = -self.spacingH
        newLineX = 0

    elseif orientation == "top_to_bottom" then
        if strfind(self.anchor, "RIGHT$") then
            point1 = "TOPRIGHT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            x = 0
            newLineX = -self.spacingH
        else
            point1 = "TOPLEFT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            x = 0
            newLineX = self.spacingH
        end
        y = -self.spacingV
        newLineY = 0

    elseif orientation == "bottom_to_top" then
        if strfind(self.anchor, "RIGHT$") then
            point1 = "BOTTOMRIGHT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            x = 0
            newLineX = -self.spacingH
        else
            point1 = "BOTTOMLEFT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            x = 0
            newLineX = self.spacingH
        end
        y = self.spacingV
        newLineY = 0
    end

    for i = 1, self.numSlots do
        AW.ClearPoints(self.slots[i])
        if i == 1 then
            AW.SetPoint(self.slots[i], point1)
        elseif i % self.numPerLine == 1 then
            AW.SetPoint(self.slots[i], point1, self.slots[i-self.numPerLine], newLinePoint2, newLineX, newLineY)
        else
            AW.SetPoint(self.slots[i], point1, self.slots[i-1], point2, x, y)
        end
    end
end

local function Auras_SetNumPerLine(self, numPerLine)
    self.numPerLine = min(numPerLine, self.numSlots)
end

local function Auras_SetNumSlots(self, numSlots)
    self.numSlots = numSlots

    for i = 1, numSlots do
        if not self.slots[i] then
            self.slots[i] = S.CreateAura(self)
        end
    end

    -- hide if reduced
    for i = numSlots + 1, #self.slots do
        self.slots[i]:Hide()
    end
end

local function Auras_SetupAuras(self, config)
    for i = 1, self.numSlots do
        local aura = self.slots[i]
        aura.root = self.root
        -- aura:SetDesaturated(config.desaturated)
        aura:SetCooldownStyle(config.cooldownStyle)
        aura:SetupDurationText(config.durationText)
        aura:SetupStackText(config.stackText)
    end
end

local function Auras_OnHide(self)
    for i = 1, self.numSlots do
        self.slots[i]:Hide()
    end
end

local function Auras_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    NP.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.position = config.position -- for sibling update
    self.anchor = config.position[1]
    self.spacingH = config.spacingH
    self.spacingV = config.spacingV

    Auras_SetNumSlots(self, config.numTotal)
    Auras_SetSize(self, config.width, config.height)
    Auras_SetNumPerLine(self, config.numPerLine)
    Auras_SetOrientation(self, config.orientation)
    Auras_SetupAuras(self, config)
    Auras_UpdateSize(self, 0)

    -- priorities
    self.priorities = config.priorities

    -- blacklist
    self.blacklist = U.ConvertSpellTable(config.blacklist)

    -- filters
    wipe(self.filters)
    if self.overallFilter then
        -- always add overall filter
        self.filters[self.overallFilter] = true
    end
    for f, v in pairs(config.filters) do
        if v then
            self.filters[f] = true
        end
    end

    -- auraTypeColor
    wipe(self.colorTypes)
    for _, type in pairs(auraColorOrder) do
        if config.auraTypeColor[type] then
            tinsert(self.colorTypes, type)
        end
    end
end

local function Auras_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    for _, slot in pairs(self.slots) do
        slot:UpdatePixels()
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateAuras(parent, name, auraFilter)
    local frame = CreateFrame("Frame", name, parent)

    frame.root = parent
    frame.auraFilter = auraFilter
    -- frame.overallFilter = sourceFilter
    frame.canHaveSibling = true

    -- events
    BFI.AddEventHandler(frame)

    -- slots
    frame.slots = {}

    -- data
    frame.auras = {}
    frame.sortedAuras = {}
    frame.numAuras = 0
    frame.filters = {}
    frame.colorTypes = {}

    -- scripts
    frame:SetScript("OnHide", Auras_OnHide)

    -- functions
    frame.Enable = Auras_Enable
    frame.Update = Auras_Update
    frame.LoadConfig = Auras_LoadConfig
    frame.AddSibling = Auras_AddSibling
    frame.RemoveSibling = Auras_RemoveSibling

    -- pixel perfect
    AW.AddToPixelUpdater(frame, Auras_UpdatePixels)

    return frame
end

function NP.CreateDebuffs(parent, name)
    return CreateAuras(parent, name, "HARMFUL")
end

function NP.CreateBuffs(parent, name)
    return CreateAuras(parent, name, "HELPFUL")
end