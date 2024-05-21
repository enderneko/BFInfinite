local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected

--! for AI followers, UnitClassBase is buggy
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local function UpdateName(self)
    local unit = self.root.displayedUnit
    if not unit then return end

    local name = UnitName(unit)
    local class = UnitClassBase(unit)

    -- length
    if self.length <= 1 then
        local width = self:GetParent():GetWidth() - 2
        for i = string.utf8len(name), 0, -1 do
            self:SetText(string.utf8sub(name, 1, i))
            if self:GetWidth() / width <= self.length then
                break
            end
        end
    else
        self:SetText(string.utf8sub(name, 1, self.length))
    end

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

    if self:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function NameText_LoadConfig(self, config)
    self:SetNameFont(unpack(config.font))

    if config.anchorTo == "button" then
        self:SetParent(self.root)
    else
        self:SetParent(self.root.indicators[config.anchorTo])
    end
    AW.LoadWidgetPosition(self, config.position)

    self.length = config.length
    self.color = config.color
end

function UF.CreateNameText(parent, name)
    local text = parent:CreateFontString(name, "OVERLAY")
    text.root = parent

    -- events
    BFI.SetEventHandler(text)

    -- functions
    text.Enable = NameText_Enable
    text.Update = NameText_Update
    text.SetNameFont = U.SetFont
    text.LoadConfig = NameText_LoadConfig

    return text
end