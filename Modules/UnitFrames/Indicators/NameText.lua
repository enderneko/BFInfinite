---@type BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitClassBase = AF.UnitClassBase
local issecretvalue = issecretvalue

---------------------------------------------------------------------
-- name
---------------------------------------------------------------------
local function UpdateName(self, event, unitId)
    local unit = self.root.effectiveUnit
    if unitId and unit ~= unitId then return end

    local name = UnitName(unit)
    if not name then
        self.normalText:SetText("")
        self.secretText:SetText("")
        return
    end

    local class = UnitClassBase(unit)

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if AF.UnitIsPlayer(unit) then
            r, g, b = AF.GetClassColor(class)
        else
            r, g, b = AF.GetReactionColor(unit)
        end
    else
        if AF.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AF.GetClassColor(class)
            else
                r, g, b = unpack(self.color.rgb)
            end
        else
            r, g, b = unpack(self.color.rgb)
        end
    end

    -- length
    if issecretvalue(name) then
        self.normalText:SetText("")
        self.secretText:SetWidth(self.secretText:GetParent():GetWidth() * self.length)
        self.secretText:SetText(name)
        self.secretText:SetTextColor(r, g, b)
    else
        self.secretText:SetText("")
        -- https://warcraft.wiki.gg/wiki/API_FrameScriptObject_HasSecretAspect
        -- print(self:HasSecretAspect(Enum.SecretAspect.Text))
        -- self:SetToDefaults() -- NOTE: NOT IDEAL, resets all other settings
        AF.SetText(self.normalText, name, self.length)
        self.normalText:SetTextColor(r, g, b)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function NameText_Update(self)
    UpdateName(self)
end

---------------------------------------------------------------------
-- show/hide
---------------------------------------------------------------------
local function NameText_Show(self)
    self.normalText:Show()
    self.secretText:Show()
end

local function NameText_Hide(self)
    self.normalText:Hide()
    self.secretText:Hide()
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function NameText_Enable(self)
    self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
    self:RegisterEvent("UNIT_FACTION", UpdateName)

    self:Show()
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function NameText_LoadConfig(self, config)
    AF.SetFont(self.secretText, unpack(config.font))
    UF.LoadIndicatorPosition(self.secretText, config.position, config.anchorTo, config.parent)
    AF.SetFont(self.normalText, unpack(config.font))
    UF.LoadIndicatorPosition(self.normalText, config.position, config.anchorTo, config.parent)

    self.length = config.length
    self.color = config.color
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function NameText_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = NameText_EnableConfigMode
    self.Update = AF.noop

    UpdateName(self)

    self:SetShown(self.enabled)
end

local function NameText_DisableConfigMode(self)
    self.Enable = NameText_Enable
    self.Update = NameText_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateNameText(parent, name)
    local text = {root = parent}

    local secretText = parent:CreateFontString(name .. "_Secret", "OVERLAY")
    text.secretText = secretText
    secretText:SetWordWrap(false)
    secretText.root = parent
    secretText:Hide()

    local normalText = parent:CreateFontString(name .. "_Normal", "OVERLAY")
    text.normalText = normalText
    normalText.root = parent
    normalText:Hide()

    -- events
    AF.AddEventHandler(text)

    -- functions
    text.Show = NameText_Show
    text.Hide = NameText_Hide
    text.Enable = NameText_Enable
    text.Update = NameText_Update
    text.EnableConfigMode = NameText_EnableConfigMode
    text.DisableConfigMode = NameText_DisableConfigMode
    text.LoadConfig = NameText_LoadConfig

    return text
end