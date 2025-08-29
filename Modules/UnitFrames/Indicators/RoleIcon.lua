---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local G = AF.Glyphs
local UF = BFI.modules.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RoleIcon_Update(self)
    local unit = self.root.unit
    local role = UnitGroupRolesAssigned(unit)

    if role == "NONE" or (self.hideDamager and role == "DAMAGER") then
        self:Hide()
    else
        -- self.icon:SetTexture(AF.GetTexture(role))
        G.SetGlyph(self.text, G.Role[role])
        self:Show()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RoleIcon_Enable(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", RoleIcon_Update)
    self:Update()
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RoleIcon_LoadConfig(self, config)
    AF.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AF.SetSize(self, config.size, config.size)
    G.SetFont(self.text, config.size, "outline")
    self.hideDamager = config.hideDamager
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function RoleIcon_EnableConfigMode(self)
    self:UnregisterAllEvents()
    self.Enable = RoleIcon_EnableConfigMode
    self.Update = AF.noop

    G.SetGlyph(self.text, G.Role.HEALER)

    self:SetShown(self.enabled)
end

local function RoleIcon_DisableConfigMode(self)
    self.Enable = RoleIcon_Enable
    self.Update = RoleIcon_Update
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRoleIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    -- local icon = frame:CreateTexture(nil, "ARTWORK")
    -- frame.icon = icon
    -- icon:SetAllPoints()

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    AF.AddEventHandler(frame)

    -- functions
    frame.Enable = RoleIcon_Enable
    frame.Update = RoleIcon_Update
    frame.EnableConfigMode = RoleIcon_EnableConfigMode
    frame.DisableConfigMode = RoleIcon_DisableConfigMode
    frame.LoadConfig = RoleIcon_LoadConfig

    return frame
end