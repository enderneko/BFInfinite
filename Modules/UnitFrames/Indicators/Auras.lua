---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local S = BFI.Shared
local UF = BFI.UnitFrames

local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local UnitIsUnit = UnitIsUnit
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack

local Auras_UpdateSize

---------------------------------------------------------------------
-- sort
---------------------------------------------------------------------
local function SortAuras(a, b)
    if a.priority ~= b.priority then
        return a.priority < b.priority
    end

    if a.dispellable ~= b.dispellable then
        return a.dispellable
    end

    if a.castByMe ~= b.castByMe then
        return a.castByMe
    end

    if a.isBossAura ~= b.isBossAura then
        return a.isBossAura
    end

    if a.noDuration ~= b.noDuration then
        return b.noDuration
    end

    -- if a.expirationTime ~= b.expirationTime then
    --     return a.expirationTime < b.expirationTime
    -- end

    -- if a.start ~= b.start then
    --     -- print(a.name, b.name, a.start > b.start)
    --     return a.start > b.start
    -- end

    return a.auraInstanceID < b.auraInstanceID
end

local function SortAuras_Whitelist(a, b)
    if a.priority ~= b.priority then
        return a.priority < b.priority
    end
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

    if auraData.isHarmful and UnitIsFriend("player", self.root.unit) and not self.canAttack then
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
    if self.whitelist then
        auraData.priority = self.whitelist[auraData.spellId] or 999
    else
        auraData.priority = self.priorities[auraData.spellId] or 999
    end
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

local function CheckAdvancedFilters(self, auraData)
    for f in pairs(self.filters) do
        if auraData[f] then
            return true
        end
    end
end

local function CheckWhitelist(self, auraData)
    if self.whitelist[auraData.spellId] then
        return true
    end
end

local function CheckBlacklist(self, auraData)
    if not self.blacklist[auraData.spellId] then
        return true
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
    if self.canAttack and self.subFrameFilter and auraData[self.subFrameFilter] then
        self.subShown = self.subShown + 1
        local aura = self.subFrame.slots[self.subShown]
        aura.auraInstanceID = auraData.auraInstanceID -- tooltips
        aura:SetCooldown(auraData.start, auraData.duration, auraData.applications, auraData.icon, GetAuraType(self, auraData), self.subFrameDesaturated)
    else
        self.mainShown = self.mainShown + 1
        local aura = self.slots[self.mainShown]
        aura.auraInstanceID = auraData.auraInstanceID -- tooltips
        if self.isBlock then
            aura:SetCooldown(auraData.start, auraData.duration, auraData.applications, auraData.icon, GetAuraType(self, auraData), nil, nil, AW.GetColorRGB(auraData.spellId))
        else
            aura:SetCooldown(auraData.start, auraData.duration, auraData.applications, auraData.icon, GetAuraType(self, auraData))
        end
    end
end

---------------------------------------------------------------------
-- UpdateSize
---------------------------------------------------------------------
local function UpdateSize(self)
    if self.subFrameEnabled then
        Auras_UpdateSize(self, self.mainShown)
        Auras_UpdateSize(self.subFrame, self.subShown)
        if self.mainShown == 0 then
            AW.ClearPoints(self.subFrame)
            self.subFrame:SetPoint(self.anchor)
        else
            AW.LoadWidgetPosition(self.subFrame, self.subFramePosition, self)
        end
    else
        Auras_UpdateSize(self, self.numAuras)
    end
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
            local auraData = GetAuraDataByAuraInstanceID(self.root.displayedUnit, auraInstanceID)
            if auraData and self:CheckBasicFilter(auraData) then
                UpdateExtraData(self, auraData)
                if CheckAdvancedFilters(self, auraData) then
                    tinsert(self.sortedAuras, auraData)
                end
            end
        end
        sort(self.sortedAuras, self.Comparator)

        -- show
        self.numAuras = 0
        self.mainShown = 0
        self.subShown = 0

        for i, auraData in pairs(self.sortedAuras) do
            self.numAuras = self.numAuras + 1
            ShowAura(self, auraData, i)
            if self.numAuras == self.numSlots then break end
        end

        -- resize
        UpdateSize(self)
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
        local auraData = GetAuraDataBySlot(self.root.displayedUnit, slot)
        if auraData and self:CheckBasicFilter(auraData) then
            UpdateExtraData(self, auraData)
            if CheckAdvancedFilters(self, auraData) then
                self.auras[auraData.auraInstanceID] = true
                tinsert(self.sortedAuras, auraData)
            end
        end
    end
end

local function HandleAllAuras(self)
    -- reset
    wipe(self.auras)
    wipe(self.sortedAuras)
    self.numAuras = 0
    self.mainShown = 0
    self.subShown = 0

    -- iterate
    ForEachAura(self, GetAuraSlots(self.root.displayedUnit, self.auraFilter))

    -- sort
    sort(self.sortedAuras, self.Comparator)

    -- show
    for i, auraData in pairs(self.sortedAuras) do
        self.numAuras = self.numAuras + 1
        ShowAura(self, auraData)
        if self.numAuras == self.numSlots then break end
    end

    -- resize
    UpdateSize(self)
end

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
-- UNIT_FACTION
---------------------------------------------------------------------
local function UpdateFaction(self)
    self.canAttack = UnitCanAttack("player", self.root.unit)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function Auras_Update(self)
    UpdateFaction(self)
    UpdateAuras(self)
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function Auras_Enable(self)
    self:RegisterEvent("UNIT_FACTION", UpdateFaction)
    self:RegisterEvent("UNIT_AURA", UpdateAuras)

    self:Show()
    self:Update()
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
    self.mainShown = 0
    self.subShown = 0
end

---------------------------------------------------------------------
-- config
---------------------------------------------------------------------
Auras_UpdateSize = function(self, numAuras)
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
        aura:EnableTooltip(config.tooltip, self.auraFilter == "HELPFUL")
        -- aura:SetDesaturated(config.desaturated)
        aura:SetCooldownStyle(config.cooldownStyle)
        aura:SetupDurationText(config.durationText)
        aura:SetupStackText(config.stackText)
    end
end

local function Auras_UpdateSubFramePosition(self, orientation)
    local point1, newLinePoint2, newLineX, newLineY

    if orientation == "left_to_right" then
        if strfind(self.anchor, "^BOTTOM") then
            point1 = "BOTTOMLEFT"
            newLinePoint2 = "TOPLEFT"
            newLineY = self.spacingV
        else
            point1 = "TOPLEFT"
            newLinePoint2 = "BOTTOMLEFT"
            newLineY = -self.spacingV
        end
        newLineX = 0

    elseif orientation == "right_to_left" then
        if strfind(self.anchor, "^BOTTOM") then
            point1 = "BOTTOMRIGHT"
            newLinePoint2 = "TOPRIGHT"
            newLineY = self.spacingV
        else
            point1 = "TOPRIGHT"
            newLinePoint2 = "BOTTOMRIGHT"
            newLineY = -self.spacingV
        end
        newLineX = 0

    elseif orientation == "top_to_bottom" then
        if strfind(self.anchor, "RIGHT$") then
            point1 = "TOPRIGHT"
            newLinePoint2 = "TOPLEFT"
            newLineX = -self.spacingH
        else
            point1 = "TOPLEFT"
            newLinePoint2 = "TOPRIGHT"
            newLineX = self.spacingH
        end
        newLineY = 0

    elseif orientation == "bottom_to_top" then
        if strfind(self.anchor, "RIGHT$") then
            point1 = "BOTTOMRIGHT"
            newLinePoint2 = "BOTTOMLEFT"
            newLineX = -self.spacingH
        else
            point1 = "BOTTOMLEFT"
            newLinePoint2 = "BOTTOMRIGHT"
            newLineX = self.spacingH
        end
        newLineY = 0
    end

    self.subFramePosition = {point1, newLinePoint2, newLineX, newLineY}
    AW.SetPoint(self.subFrame, point1, self, newLinePoint2, newLineX, newLineY)
end

local function Auras_OnHide(self)
    for i = 1, self.numSlots do
        self.slots[i]:Hide()
    end

    if self.subFrameEnabled then
        for i = 1, self.numSlots do
            self.subFrame.slots[i]:Hide()
        end
    end
end

local function Auras_LoadConfig(self, config)
    -- texplore(config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)

    self.anchor = config.position[1]
    self.spacingH = config.spacingH
    self.spacingV = config.spacingV
    self.isBlock = strfind(config.cooldownStyle, "^block")
    self.tooltipEnabled = config.tooltip.enabled

    Auras_SetNumSlots(self, config.numTotal)
    Auras_SetSize(self, config.width, config.height)
    Auras_SetNumPerLine(self, config.numPerLine)
    Auras_SetOrientation(self, config.orientation)
    Auras_SetupAuras(self, config)
    Auras_UpdateSize(self, 0)

    if config.mode == "whitelist" then
        -- use whitelist
        self.whitelist = U.ConvertSpellTable(config.whitelist)
        -- comparator
        self.Comparator = SortAuras_Whitelist
        -- basic filter
        self.CheckBasicFilter = CheckWhitelist
    else
        -- priorities
        self.priorities = config.priorities
        -- blacklist
        self.blacklist = U.ConvertSpellTable(config.blacklist)
        -- comparator
        self.Comparator = SortAuras
        -- basic filter
        self.CheckBasicFilter = CheckBlacklist
    end

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

    -- subFrame
    if config.subFrame then
        self.subFrameEnabled = config.subFrame.enabled
        self.subFrameFilter = config.subFrame.filter
        self.subFrameDesaturated = config.subFrame.desaturated

        if config.subFrame.enabled then
            self.subFrame:Show()

            self.subFrame.anchor = config.position[1]
            self.subFrame.spacingH = config.spacingH
            self.subFrame.spacingV = config.spacingV

            Auras_SetNumSlots(self.subFrame, config.numTotal)
            Auras_SetSize(self.subFrame, config.subFrame.width, config.subFrame.height)
            Auras_SetNumPerLine(self.subFrame, config.numPerLine)
            Auras_SetOrientation(self.subFrame, config.orientation)
            Auras_SetupAuras(self.subFrame, config)
            Auras_UpdateSize(self, 0)
            Auras_UpdateSubFramePosition(self, config.orientation)
        else
            self.subFrame:Hide()
        end
    end
end

local function Auras_UpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    for _, slot in pairs(self.slots) do
        slot:UpdatePixels()
    end
    if self.subFrame then
        AW.ReSize(self.subFrame)
        AW.RePoint(self.subFrame)
        for _, slot in pairs(self.subFrame.slots) do
            slot:UpdatePixels()
        end
    end
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function ConfigMode_RefreshAuras(self)
    local icon = self.auraFilter == "HELPFUL" and 135953 or 136071
    if self.isBlock then
        for i = 1, self.numSlots do
            self.slots[i]:SetCooldown(GetTime(), 15, i, icon, nil, nil, nil, AW.GetColorRGB("accent"))
            self.slots[i]:EnableMouse(false)
        end
    else
        for i = 1, self.numSlots do
            self.slots[i]:SetCooldown(GetTime(), 15, i, icon)
            self.slots[i]:EnableMouse(false)
        end
    end
    Auras_UpdateSize(self, self.numSlots)
end

local function Auras_EnableConfigMode(self)
    self.Enable = Auras_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    if not self.configModeTicker then
        ConfigMode_RefreshAuras(self)
        self.configModeTicker = C_Timer.NewTicker(15, function()
            ConfigMode_RefreshAuras(self)
        end)
    end
    self:Show()
end

local function Auras_DisableConfigMode(self)
    self.Enable = Auras_Enable
    self.Update = Auras_Update

    if self.configModeTicker then
        self.configModeTicker:Cancel()
        self.configModeTicker = nil
    end

    if self.tooltipEnabled then
        for i = 1, self.numSlots do
            self.slots[i]:EnableMouse(true)
        end
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateAuras(parent, name, auraFilter, hasSubFrame)
    local frame = CreateFrame("Frame", name, parent)

    frame.root = parent
    frame.auraFilter = auraFilter
    -- frame.overallFilter = sourceFilter

    -- events
    BFI.AddEventHandler(frame)

    -- slots
    frame.slots = {}

    -- subFrame
    if hasSubFrame then
        frame.subFrame = CreateFrame("Frame", nil, frame)
        frame.subFrame.root = parent
        frame.subFrame.slots = {}
    end

    -- data
    frame.auras = {}
    frame.sortedAuras = {}
    frame.numAuras = 0
    frame.mainShown = 0
    frame.subShown = 0
    frame.filters = {}
    frame.colorTypes = {}

    -- scripts
    frame:SetScript("OnHide", Auras_OnHide)

    -- functions
    frame.Enable = Auras_Enable
    frame.Disable = Auras_Disable
    frame.Update = Auras_Update
    frame.EnableConfigMode = Auras_EnableConfigMode
    frame.DisableConfigMode = Auras_DisableConfigMode
    frame.LoadConfig = Auras_LoadConfig

    -- pixel perfect
    AW.AddToPixelUpdater(frame, Auras_UpdatePixels)

    return frame
end