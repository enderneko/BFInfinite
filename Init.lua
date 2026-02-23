---@class BFI
local BFI = select(2, ...)
_G.BFInfinite = BFI

BFI.prefix = "BFI"
BFI.name = "BFInfinite"

---@class BFI
---@field L table
---@field funcs Funcs
---@field libs table
---@field media table
---@field modules Modules
---@field vars table

---@class Modules
---@field Enhancements Enhancements
---@field Colors Colors
---@field Auras Auras
---@field Misc Misc
---@field Style Style
---@field ActionBars ActionBars
---@field BuffsDebuffs BuffsDebuffs
---@field Chat Chat
---@field DataBars DataBars
---@field Maps Maps
---@field Nameplates Nameplates
---@field Tooltip Tooltip
---@field UIWidgets UIWidgets
---@field UnitFrames UnitFrames
---@field DisableBlizzard DisableBlizzard

---------------------------------------------------------------------
-- AbstractFramework
---------------------------------------------------------------------
---@type AbstractFramework
local AF = _G.AbstractFramework
AF.RegisterAddon(BFI.name, "BFI")

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
BFI.vars = {} -- vars
BFI.funcs = {} -- functions
BFI.modules = {}
BFI.libs = {}

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------

-- profile
BFI.modules.UIWidgets = {}
AF.AddEventHandler(BFI.modules.UIWidgets)

BFI.modules.BuffsDebuffs = {}
AF.AddEventHandler(BFI.modules.BuffsDebuffs)

BFI.modules.ActionBars = {["bars"] = {}}
AF.AddEventHandler(BFI.modules.ActionBars)

BFI.modules.UnitFrames = {}
AF.AddEventHandler(BFI.modules.UnitFrames)

BFI.modules.Nameplates = {}
AF.AddEventHandler(BFI.modules.Nameplates)

BFI.modules.Maps = {}
AF.AddEventHandler(BFI.modules.Maps)

BFI.modules.DataBars = {}
AF.AddEventHandler(BFI.modules.DataBars)

BFI.modules.Chat = {}
AF.AddEventHandler(BFI.modules.Chat)

BFI.modules.Tooltip = {}
AF.AddEventHandler(BFI.modules.Tooltip)

BFI.modules.DisableBlizzard = {}
AF.AddEventHandler(BFI.modules.DisableBlizzard)

-- global
BFI.modules.Enhancements = {}
AF.AddEventHandler(BFI.modules.Enhancements)

BFI.modules.Colors = {}
AF.AddEventHandler(BFI.modules.Colors)

BFI.modules.Auras = {}
AF.AddEventHandler(BFI.modules.Auras)

BFI.modules.Style = {}
AF.AddEventHandler(BFI.modules.Style)

BFI.modules.Misc = {}
AF.AddEventHandler(BFI.modules.Misc)

---------------------------------------------------------------------
-- libs
---------------------------------------------------------------------
local function AddLib(name, major, silent)
    BFI.libs[name] = _G.LibStub(major, silent)
end

AddLib("LAB", "LibActionButton-1.0-BFI")
-- AddLib("LRC", "LibRangeCheck-3.0")

---------------------------------------------------------------------
-- media
---------------------------------------------------------------------
BFI.media = {}
BFI.media.bar = AF.GetTexture("Bar_AF")
-- AF.Libs.LSM:Register("statusbar", "BFI", AF.GetTexture("StatusBar", BFI.name))
-- AF.Libs.LSM:Register("statusbar", "BFI Plain", AF.GetPlainTexture())
-- AF.Libs.LSM:Register("font", "BFI Default", AF.GetFont("NotoSansCJKsc_AP", BFI.name), 255)
-- AF.Libs.LSM:Register("font", "BFI Combat", AF.GetFont("NotoSansCJKsc_Dolphin", BFI.name), 255)

AF.CreateFont("BFI", "BFI_FONT", AF.GetFont("CloseAndOpen", BFI.name), 25, "OUTLINE")