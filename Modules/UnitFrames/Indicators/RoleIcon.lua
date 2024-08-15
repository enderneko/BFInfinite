---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.UnitFrames

---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
--! CodePoints -> Unicode -> Decimal
-- https://onlinetools.com/unicode/convert-code-points-to-unicode
local GLYPHS = {
    TANK = "\238\128\130",
    HEALER = "\238\128\131",
    DAMAGER = "\238\128\132",
}

local function RoleIcon_Update(self)
    local unit = self.root.unit
    local role = UnitGroupRolesAssigned(unit)

    if role == "NONE" or (self.hideDamager and role == "DAMAGER") then
        self:Hide()
    else
        -- self.icon:SetTexture(AW.GetTexture(role))
        self.text:SetText(GLYPHS[role])
        self.text:SetTextColor(AW.GetColorRGB(role))
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
    UF.LoadIndicatorPosition(self, config.position)
    AW.SetSize(self, config.width, config.height)
    self.text:SetFont(AW.GetFont("glyphs3"), config.width, "OUTLINE")
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