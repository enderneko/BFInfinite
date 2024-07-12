---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function RoleIcon_Update(self)
    local unit = self.root.unit
    local role = UnitGroupRolesAssigned(unit)

    if role == "NONE" or (self.hideDamager and role == "DAMAGER") then
        self:Hide()
    else
        self.icon:SetTexture(AW.GetTexture(role))
        self:Show()
    end
end

---------------------------------------------------------------------
-- enable
---------------------------------------------------------------------
local function RoleIcon_Enable(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", RoleIcon_Update)
    if self.root:IsVisible() then self:Update() end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function RoleIcon_LoadConfig(self, config)
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    AW.LoadWidgetPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
    self.hideDamager = config.hideDamager
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
function UF.CreateRoleIcon(parent, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.root = parent
    frame:Hide()

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    icon:SetAllPoints()

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = RoleIcon_Enable
    frame.Update = RoleIcon_Update
    frame.LoadConfig = RoleIcon_LoadConfig

    return frame
end