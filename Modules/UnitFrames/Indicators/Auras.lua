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

-------------------------------------------------
-- ForEachAura
-------------------------------------------------
local function ForEachAuraHelper(indicator, handler, continuationToken, ...)
    -- continuationToken is the first return value of GetAuraSlots()
    local n = select("#", ...)
    local count1, count2 = 1, 1
    for i = 1, n do
        local slot = select(i, ...)
        local auraInfo = GetAuraDataBySlot(indicator.root.displayedUnit, slot)
        local ret = handler(indicator, auraInfo, i, count1, count2)
        if ret then
            count1 = count1 + 1
        else
            count2 = count2 + 1
        end
    end
    return n, count1, count2
end

local function ForEachAura(indicator, handler)
    return ForEachAuraHelper(indicator, handler, GetAuraSlots(indicator.root.displayedUnit, indicator.filter, indicator.numSlots))
end

---------------------------------------------------------------------
-- UNIT_AURA
---------------------------------------------------------------------
local function HandleAura(self, auraInfo, index)
    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local auraType = auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId

    -- print(self:GetName(), index, name, start, duration, count, auraType, icon)

    self.auras[auraInstanceID] = index

    self:SetCooldown(index, source, start, duration, count, auraType, icon)

    return true -- TODO: filter, before SetCooldown
end

local function HandleAura_Mine(self, auraInfo, index, found)
    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local auraType = auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId

    self.auras[auraInstanceID] = self.slots[found]

    if IsAppliedByPlayer(source) then
        print("MINE", found, name, start, duration, count, auraType, icon)
        self:SetCooldown(found, source, start, duration, count, auraType, icon)
        return true
    end
end

local function HandleAura_Others(self, auraInfo, index, found)
    local auraInstanceID = auraInfo.auraInstanceID
    local name = auraInfo.name
    local icon = auraInfo.icon
    local count = auraInfo.applications
    local auraType = auraInfo.dispelName
    local expirationTime = auraInfo.expirationTime or 0
    local start = expirationTime - auraInfo.duration
    local duration = auraInfo.duration
    local source = auraInfo.sourceUnit
    local spellId = auraInfo.spellId

    self.auras[auraInstanceID] = self.slots[found]

    if not IsAppliedByPlayer(source) then
        print("OTHERS", found, name, start, duration, count, auraType, icon)
        self:SetCooldown(found, source, start, duration, count, auraType, icon, true)
        return true
    end
end

local function UpdateAuras(self, event, unitId, updateInfo)
    local unit = self.root.displayedUnit
    if unitId and unitId ~= unit then return end

    local isFullUpdate = true
    -- local isFullUpdate = not updateInfo or updateInfo.isFullUpdate
    local num

    local handler
    if self.onlyShowMine then
        handler = HandleAura_Mine
    elseif self.onlyShowOthers then
        handler = HandleAura_Others
    else
        handler = HandleAura
    end

    if isFullUpdate then
        wipe(self.auras)
        num = ForEachAura(self, handler)
    end

    Auras_UpdateSize(self, num)
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
local function Auras_UpdateFrameSize(self, numAuras)
    local lines = ceil(numAuras / self.numPerLine)
    numAuras = min(numAuras, self.numPerLine)

    if self.isHorizontal then
        AW.SetGridSize(self, self.width, self.height, self.spacing, numAuras, lines)
    else
        AW.SetGridSize(self, self.width, self.height, self.spacing, lines, numAuras)
    end
end

Auras_UpdateSize = function(self, numAuras)
    if not (self.width and self.height and self.orientation) then return end

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

    Auras_UpdateFrameSize(self, numAuras)
end

local function Auras_SetSize(self, width, height)
    self.width = width
    self.height = height

    for i = 1, self.numSlots do
        -- TODO: update texcoord
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
    texplore(config)
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
function UF.CreateAuras(parent, name, filter)
    local frame = CreateFrame("Frame", name, parent)

    frame.root = parent

    if strfind(filter, "_OTHERS$") then
        frame.filter = filter:gsub("_OTHERS$", "")
        frame.onlyShowOthers = true
    elseif strfind(filter, "_MINE$") then
        frame.filter = filter:gsub("_MINE$", "")
        frame.onlyShowMine = true
    else
        frame.filter = filter
    end

    -- events
    BFI.AddEventHandler(frame)

    -- slots
    local slots = {}
    frame.slots = slots

    -- data
    local auras = {
        -- [auraInstanceID] = slotIndex,
    }
    frame.auras = auras

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