---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
local L = BFI.L
---@class Auras
local A = BFI.Auras
---@class AbstractFramework
local AF = _G.AbstractFramework

local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide

---------------------------------------------------------------------
-- header
---------------------------------------------------------------------
local function CreateHeader(name, moverName, filter)
    local header = CreateFrame("Frame", name, AF.UIParent, "SecureAuraHeaderTemplate")
    header:SetAttribute("template", "BFIAuraButtonTemplate")
    header:SetAttribute("includeWeapons", 1)
    header:SetAttribute("filter", filter)
    header.filter = filter

    header:UnregisterEvent("UNIT_AURA")
    header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    header:SetAttribute("unit", "player")
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle;player")

    AF.CreateMover(header, "BFI: " .. L["UI Widgets"], moverName)
    header:Show()

    return header
end

---------------------------------------------------------------------
-- create header
---------------------------------------------------------------------
local buffFrame, debuffFrame
local function CreateAuraHeaders()
    buffFrame = CreateHeader("BFIBuffFrame", _G.HUD_EDIT_MODE_BUFF_FRAME_LABEL, "HELPFUL")
    -- debuffFrame = CreateHeader("BFIDebuffFrame", _G.HUD_EDIT_MODE_DEBUFF_FRAME_LABEL, "HARMFUL")
end

---------------------------------------------------------------------
-- create aura button
---------------------------------------------------------------------
local function Button_OnEnter(button)
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", 0, -5)
    -- button.elapsed = 1

    if button:GetAttribute("index") then -- normal aura
        GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
    elseif button:GetAttribute("target-slot") then -- temp weapon enchant
        GameTooltip:SetInventoryItem("player", button:GetID())
    end
end

function A.CreateAuraButton(button)
    button.header = button:GetParent()
    button.filter = button.header.filter

    AF.SetDefaultBackdrop(button)
    AF.ApplyDefaultBackdropColors(button)

    button:RegisterForClicks("RightButtonUp", "RightButtonDown")

    button:SetScript("OnEnter", Button_OnEnter)
    button:SetScript("OnLeave", GameTooltip_Hide)
end

---------------------------------------------------------------------
-- setup header
---------------------------------------------------------------------
--[[
filter = [STRING] -- a pipe-separated list of aura filter options ("RAID" will be ignored)
separateOwn = [NUMBER] -- indicate whether buffs you cast yourself should be separated before (1) or after (-1) others. If 0 or nil, no separation is done.
sortMethod = ["INDEX", "NAME", "TIME"] -- defines how the group is sorted (Default: "INDEX")
sortDirection = ["+", "-"] -- defines the sort order (Default: "+")
groupBy = [nil, auraFilter] -- if present, a series of comma-separated filters, appended to the base filter to separate auras into groups within a single stream
includeWeapons = [nil, NUMBER] -- The aura sub-stream before which to include temporary weapon enchants. If nil or 0, they are ignored.
consolidateTo = [nil, NUMBER] -- The aura sub-stream before which to place a proxy for the consolidated header. If nil or 0, consolidation is ignored.
consolidateDuration = [nil, NUMBER] -- the minimum total duration an aura should have to be considered for consolidation (Default: 30)
consolidateThreshold = [nil, NUMBER] -- buffs with less remaining duration than this many seconds should not be consolidated (Default: 10)
consolidateFraction = [nil, NUMBER] -- The fraction of remaining duration a buff should still have to be eligible for consolidation (Default: .10)

template = [STRING] -- the XML template to use for the unit buttons. If the created widgets should be something other than Buttons, append the Widget name after a comma.
weaponTemplate = [STRING] -- the XML template to use for temporary enchant buttons. Can be nil if you preset the tempEnchant1 and tempEnchant2 attributes, or if you don't include temporary enchants.
consolidateProxy = [STRING|Frame] -- Either the button which represents consolidated buffs, or the name of the template used to construct one.
consolidateHeader = [STRING|Frame] -- Either the aura header which contains consolidated buffs, or the name of the template used to construct one.

point = [STRING] -- a valid XML anchoring point (Default: "TOPRIGHT")
minWidth = [nil, NUMBER] -- the minimum width of the container frame
minHeight = [nil, NUMBER] -- the minimum height of the container frame
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons. This should typically be set to at least the width of your buff template.
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons. This should typically be set to at least the height of your buff template.
wrapAfter = [NUMBER] -- begin a new row or column after this many auras. If 0 or nil, never wrap or limit the first row
wrapXOffset = [NUMBER] -- the x-offset from one row or column to the next
wrapYOffset = [NUMBER] -- the y-offset from one row or column to the next
maxWraps = [NUMBER] -- limit the number of rows or columns. If 0 or nil, the number of rows or columns will not be limited.
--]]

local function GetAttributes(config)
    local point, x, y, wrapX, wrapY, minWidth, minHeight, _
    point, _, _, x, y, wrapX, wrapY = AF.GetAnchorPoints_Complex(config.orientation, config.spacingX, config.spacingY)

    -- local width = config.width
    -- local height = AF.ConvertPixels(config.height)

    -- local spacingX = AF.ConvertPixels(config.spacingX)
    -- local spacingY = AF.ConvertPixels(config.spacingY)


    if config.orientation == "bottom_to_top_then_left" then

    elseif config.orientation == "bottom_to_top_then_right" then

    elseif config.orientation == "top_to_bottom_then_left" then

    elseif config.orientation == "top_to_bottom_then_right" then

    elseif config.orientation == "left_to_right_then_bottom" then

    elseif config.orientation == "left_to_right_then_top" then

    elseif config.orientation == "right_to_left_then_bottom" then
        x = x - config.width
        wrapY = wrapY - config.height
        minWidth = config.width * config.wrapAfter + config.spacingX * (config.wrapAfter - 1)
        minHeight = config.height * config.maxWraps + config.spacingY * (config.maxWraps - 1)
    elseif config.orientation == "right_to_left_then_top" then

    end

    return point, x, y, wrapX, wrapY, minWidth, minHeight
end

local function SetupHeader(header, config)
    header:SetAttribute("initialConfigFunction", [[
        local header = self:GetParent()
        self:SetWidth(header:GetAttribute("buttonWidth"))
        self:SetHeight(header:GetAttribute("buttonHeight"))
    ]])

    header:SetAttribute("separateOwn", 1)
    header:SetAttribute("sortMethod", config.sortMethod)
    header:SetAttribute("sortDirection", config.sortDirection)
    header:SetAttribute("maxWraps", config.maxWraps)
    header:SetAttribute("wrapAfter", config.wrapAfter)

    local point, x, y, wrapX, wrapY, minWidth, minHeight = GetAttributes(config)
    header:SetAttribute("point", point)
    header:SetAttribute("xOffset", x)
    header:SetAttribute("yOffset", y)
    header:SetAttribute("wrapXOffset", wrapX)
    header:SetAttribute("wrapYOffset", wrapY)
    header:SetAttribute("minWidth", minWidth)
    header:SetAttribute("minHeight", minHeight)

    -- size
    header:SetAttribute("buttonWidth", config.width)
    header:SetAttribute("buttonHeight", config.height)
    for _, b in pairs({header:GetChildren()}) do
        b:SetSize(config.width, config.height)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateAuras(module, which)
    if module and module ~= "Auras" then return end

    local config = A.config

    if not config.enabled then
        -- A:UnregisterAllEvents()
        if buffFrame then
            buffFrame.enabled = false
        end
        if debuffFrame then
            debuffFrame.enabled = false
        end
        return
    end

    if not (buffFrame and debuffFrame) then
        CreateAuraHeaders()
    end

    buffFrame.enabled = true
    -- debuffFrame.enabled = true

    SetupHeader(buffFrame, config.buffs)
    -- SetupHeader(debuffFrame)

    AF.LoadPosition(buffFrame, config.buffs.position)
end
AF.RegisterCallback("UpdateModules", "Auras", UpdateAuras)