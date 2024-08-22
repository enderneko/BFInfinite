---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
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
        -- self.icon:SetTexture(AW.GetTexture(role))
        self.text:SetText(S.RoleGlyphs[role].char)
        self.text:SetTextColor(AW.UnpackColor(S.RoleGlyphs[role].color))
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
    AW.SetFrameLevel(self, config.frameLevel, self.root)
    UF.LoadIndicatorPosition(self, config.position, config.anchorTo)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs"), config.width, "OUTLINE")
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
    -- local icon = frame:CreateTexture(nil, "ARTWORK")
    -- frame.icon = icon
    -- icon:SetAllPoints()

    -- text
    local text = frame:CreateFontString(nil, "ARTWORK")
    frame.text = text
    text:SetPoint("CENTER")

    -- events
    BFI.AddEventHandler(frame)

    -- functions
    frame.Enable = RoleIcon_Enable
    frame.Update = RoleIcon_Update
    frame.LoadConfig = RoleIcon_LoadConfig

    return frame
end