---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

-- local function OpenMenu(manager, ownerRegion, menuDescription, anchor)
--     print("OpenMenu called with:", manager, ownerRegion, menuDescription, anchor)
-- end

-- local function OpenContextMenu(manager, ownerRegion, menuDescription)
--     print("OpenContextMenu called with:", manager, ownerRegion, menuDescription)
-- end

local backdrops = {}

local function StyleMenu(menu)
    S.RemoveTextures(menu)

    if backdrops[menu] then return end
    backdrops[menu] = true

    S.CreateBackdrop(menu)
    menu.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget", 0.9))
    AF.ClearPoints(menu.BFIBackdrop)
    AF.SetPoint(menu.BFIBackdrop, "TOPLEFT", menu, 0, -1)
    AF.SetPoint(menu.BFIBackdrop, "BOTTOMRIGHT", menu, 0, 8)

    -- texplore({menu:GetChildren()})
    -- TODO: .ScrollBar
end

local function Manager_OpenMenu(manager, ownerRegion, menuDescription)
    local menu = manager:GetOpenMenu()
    if not menu then return end
    StyleMenu(menu)
    menuDescription:AddMenuAcquiredCallback(StyleMenu) -- submenus
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    -- Interface\AddOns\Blizzard_Menu\Menu.lua
    local manager = _G.Menu.GetManager()
    if manager then
        hooksecurefunc(manager, "OpenMenu", Manager_OpenMenu)
        hooksecurefunc(manager, "OpenContextMenu", Manager_OpenMenu)
    end
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)