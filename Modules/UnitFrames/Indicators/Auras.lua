local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local UnitIsUnit = UnitIsUnit
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit

local function IsAppliedByPlayer(unit)
    return unit and (UnitIsUnit("player", unit) or UnitIsOwnerOrControllerOfUnit("player", unit))
end

local Auras_UpdateSize

---------------------------------------------------------------------
-- SortAuras
---------------------------------------------------------------------
local function SortAuras(a, b)
    local aFromPlayer = IsAppliedByPlayer(a.sourceUnit)
    local bFromPlayer = IsAppliedByPlayer(b.sourceUnit)
    if aFromPlayer ~= bFromPlayer then
        return aFromPlayer
    end

    if a.canApplyAura ~= b.canApplyAura then
        return a.canApplyAura
    end

    if a.duration ~= b.duration then
        if a.duration == 0 and b.duration ~= 0 then
            return false
        elseif a.duration ~= 0 and b.duration == 0 then
            return true
        end
    end

    return a.auraInstanceID < b.auraInstanceID
end

---------------------------------------------------------------------
-- ShowAura
---------------------------------------------------------------------
local function ShowAura(self, auraInfo, index)
    -- local auraInstanceID = auraInfo.auraInstanceID
    -- local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local auraType = auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    -- local spellId = auraInfo.spellId

    -- print(self:GetName(), index, name, start, duration, count, auraType, icon)
    self:SetCooldown(index, source, start, duration, count, auraType, icon, self.desaturated)
end

---------------------------------------------------------------------
-- HandleUpdateInfo
---------------------------------------------------------------------
local function MatchFilter(self, isHarmful, isHelpful)
    if self.filter == "HARMFUL" then
        return isHarmful
    elseif self.filter == "HELPFUL" then
        return isHelpful
    end
end

local function HandleUpdateInfo(self, updateInfo)
    local changed

    if updateInfo.addedAuras then
        for _, auraInfo in pairs(updateInfo.addedAuras) do
            if MatchFilter(self, auraInfo.isHarmful, auraInfo.isHelpful) and self.matcher(auraInfo) then
                self.auras[auraInfo.auraInstanceID] = true
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
            tinsert(self.sortedAuras, C_UnitAuras.GetAuraDataByAuraInstanceID(self.root.displayedUnit, auraInstanceID))
        end
        sort(self.sortedAuras, SortAuras)

        -- show
        self.numAuras = 0
        for i, auraInfo in pairs(self.sortedAuras) do
            if i > self.numSlots then break end
            self.numAuras = self.numAuras + 1
            ShowAura(self, auraInfo, i)
        end

        -- resize
        Auras_UpdateSize(self, self.numAuras)
    end
end

-------------------------------------------------
-- ForEachAura
-------------------------------------------------
--- @param matcher function
local function ForEachAura(self, matcher, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select("#", ...)
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = GetAuraDataBySlot(self.root.displayedUnit, slot)
        local matched = matcher(auraInfo)
        if matched then
            self.numAuras = self.numAuras + 1
            self.auras[auraInfo.auraInstanceID] = true
            tinsert(self.sortedAuras, auraInfo)
        end
    end
end

local function HandleAllAuras(self)
    -- reset
    wipe(self.auras)
    wipe(self.sortedAuras)
    self.numAuras = 0

    -- iterate
    ForEachAura(self, self.matcher, GetAuraSlots(self.root.displayedUnit, self.filter, self.numSlots))

    -- sort
    sort(self.sortedAuras, SortAuras)

    -- show
    for i, auraInfo in pairs(self.sortedAuras) do
        -- if i > self.numSlots then break end --! already limited
        ShowAura(self, auraInfo, i)
    end

    -- resize
    Auras_UpdateSize(self, self.numAuras)
end

---------------------------------------------------------------------
-- matchers
---------------------------------------------------------------------
local matchers = {
    all = function()
        return true
    end,

    mine = function(auraInfo)
        return IsAppliedByPlayer(auraInfo.sourceUnit)
    end,

    others = function(auraInfo)
        return not IsAppliedByPlayer(auraInfo.sourceUnit)
    end
}

---------------------------------------------------------------------
-- UNIT_AURA
---------------------------------------------------------------------
local function UpdateAuras(self, event, unitId, updateInfo)
    local unit = self.root.displayedUnit
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
-- SetCooldown
---------------------------------------------------------------------
local set_cooldown = {
    cast_by_me = function(self, index, source, start, duration, count, auraType, icon, desaturated)
        if IsAppliedByPlayer(source) then
            self.slots[index]:SetCooldown(start, duration, count, "Self", icon, desaturated)
        else
            self.slots[index]:SetCooldown(start, duration, count, nil, icon, desaturated)
        end
    end,
    debuff_type = function(self, index, source, start, duration, count, auraType, icon, desaturated)
        self.slots[index]:SetCooldown(start, duration, count, auraType or "None", icon, desaturated)
    end,
    none = function(self, index, source, start, duration, count, auraType, icon, desaturated)
        self.slots[index]:SetCooldown(start, duration, count, nil, icon, desaturated)
    end,
}

---------------------------------------------------------------------
-- config
---------------------------------------------------------------------
Auras_UpdateSize = function(self, numAuras)
    if not (self.width and self.height and self.orientation) then return end

    -- check shown slots
    if numAuras then
        for i = numAuras + 1, self.numSlots do
            self.slots[i]:Hide()
        end
    else
        numAuras = 0
        for i = 1, self.numSlots do
            if self.slots[i]:IsShown() then
                numAuras = i
            end
        end
    end

    -- set size
    local lines = ceil(numAuras / self.numPerLine)
    numAuras = min(numAuras, self.numPerLine)

    if self.isHorizontal then
        AW.SetGridSize(self, self.width, self.height, self.spacing, numAuras, lines)
    else
        AW.SetGridSize(self, self.width, self.height, self.spacing, lines, numAuras)
    end
end

local function Auras_SetSize(self, width, height)
    self.width = width
    self.height = height

    for i = 1, self.numSlots do
        AW.SetSize(self.slots[i], width, height)
    end

    Auras_UpdateSize(self)
end

local function Auras_SetOrientation(self, orientation)
    self.orientation = orientation

    local anchor = self:GetPoint()
    assert(anchor, "[indicator] position must be set before SetOrientation")

    self.isHorizontal = not strfind(orientation, "top")

    local point1, point2, newLinePoint2, x, y
    if orientation == "left_to_right" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMLEFT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            y = self.spacing
        else
            point1 = "TOPLEFT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            y = -self.spacing
        end
        x = self.spacing

    elseif orientation == "right_to_left" then
        if strfind(anchor, "^BOTTOM") then
            point1 = "BOTTOMRIGHT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            y = self.spacing
        else
            point1 = "TOPRIGHT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            y = -self.spacing
        end
        x = -self.spacing

    elseif orientation == "top_to_bottom" then
        if strfind(anchor, "RIGHT$") then
            point1 = "TOPRIGHT"
            point2 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPLEFT"
            x = -self.spacing
        else
            point1 = "TOPLEFT"
            point2 = "BOTTOMLEFT"
            newLinePoint2 = "TOPRIGHT"
            x = self.spacing
        end
        y = -self.spacing

    elseif orientation == "bottom_to_top" then
        if strfind(anchor, "RIGHT$") then
            point1 = "BOTTOMRIGHT"
            point2 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            x = -self.spacing
        else
            point1 = "BOTTOMLEFT"
            point2 = "TOPLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            x = self.spacing
        end
        y = self.spacing
    end

    for i = 1, self.numSlots do
        AW.ClearPoints(self.slots[i])
        if i == 1 then
            AW.SetPoint(self.slots[i], point1)
        elseif i % self.numPerLine == 1 then
            AW.SetPoint(self.slots[i], point1, self.slots[i-self.numPerLine], newLinePoint2, 0, y)
        else
            AW.SetPoint(self.slots[i], point1, self.slots[i-1], point2, x, 0)
        end
    end

    Auras_UpdateSize(self)
end

local function Auras_SetNumPerLine(self, numPerLine)
    self.numPerLine = min(numPerLine, self.numSlots)

    if self.orientation then
        Auras_SetOrientation(self, self.orientation)
    else
        Auras_UpdateSize(self)
    end
end

local function Auras_SetNumSlots(self, numSlots)
    self.numSlots = numSlots

    for i = 1, numSlots do
        if not self.slots[i] then
            self.slots[i] = UF.CreateAura(self)
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
        aura:SetCooldownStyle(config.cooldownStyle)
        aura:SetupDurationText(config.durationText)
        aura:SetupStackText(config.stackText)
    end
end

local func

local function Auras_OnHide(self)
    for i = 1, self.numSlots do
        self.slots[i]:Hide()
    end
end

local function Auras_LoadConfig(self, config)
    -- texplore(config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    if config.anchorTo then
        AW.LoadWidgetPosition(self, config.position, self.root.indicators[config.anchorTo])
    else
        AW.LoadWidgetPosition(self, config.position)
    end
    Auras_SetNumSlots(self, config.numTotal)
    self.spacing = config.spacing
    Auras_SetSize(self, config.width, config.height)
    Auras_SetNumPerLine(self, config.numPerLine)
    Auras_SetOrientation(self, config.orientation)
    Auras_SetupAuras(self, config)

    self.SetCooldown = set_cooldown[config.borderColor]
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
function UF.CreateAuras(parent, name, auraFilter, sourceFilter, desaturated)
    local frame = CreateFrame("Frame", name, parent)

    frame.root = parent
    frame.filter = auraFilter
    frame.matcher = matchers[sourceFilter or "all"]
    frame.desaturated = desaturated

    -- events
    BFI.AddEventHandler(frame)

    -- slots
    local slots = {}
    frame.slots = slots

    -- data
    frame.auras = {}
    frame.sortedAuras = {}
    frame.numAuras = 0

    -- scripts
    frame:SetScript("OnHide", Auras_OnHide)

    -- functions
    frame.Enable = Auras_Enable
    frame.Update = Auras_Update
    frame.LoadConfig = Auras_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, Auras_UpdatePixels)

    return frame
end