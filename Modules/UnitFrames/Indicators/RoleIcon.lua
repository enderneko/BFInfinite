---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class AbstractFramework
local AF = _G.AbstractFramework
local S = BFI.Shared
local UF = BFI.UnitFrames

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
        self.text:SetText(S.RoleGlyphs[role].char)
        self.text:SetTextColor(AF.UnpackColor(S.RoleGlyphs[role].color))
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
    AF.SetSize(self, config.width, config.height)
    self.text:SetFont(AF.GetFont("glyphs", BFI.name), config.width, "OUTLINE")
    self.hideDamager = config.hideDamager
end

---------------------------------------------------------------------
-- config mode
---------------------------------------------------------------------
local function RoleIcon_EnableConfigMode(self)
    self.Enable = RoleIcon_EnableConfigMode
    self.Update = BFI.dummy

    self:UnregisterAllEvents()
    self:Show()

    self.text:SetText(S.RoleGlyphs.HEALER.char)
    self.text:SetTextColor(AF.UnpackColor(S.RoleGlyphs.HEALER.color))
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