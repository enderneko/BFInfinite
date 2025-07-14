---@class BFI
local BFI = select(2, ...)
_G.BFInfinite = BFI
_G.BFI = BFI

BFI.prefix = "BFI"
BFI.name = "BFInfinite"

---@class BFI
---@field L table
---@field utils Utils
---@field vars table
---@field media table
---@field libs table
---@field ActionBars ActionBars
---@field Auras Auras
---@field Chat Chat
---@field Colors Colors
---@field DataBars DataBars
---@field DisableBlizzard DisableBlizzard
---@field Maps Maps
---@field Misc Misc
---@field NamePlates NamePlates
---@field Style Style
---@field Tooltip Tooltip
---@field UIWidgets UIWidgets
---@field UnitFrames UnitFrames
-----@field General General

---------------------------------------------------------------------
-- AbstractFramework
---------------------------------------------------------------------
---@type AbstractFramework
local AF = _G.AbstractFramework
AF.RegisterAddon(BFI.name, "BFI")

---------------------------------------------------------------------
-- global
---------------------------------------------------------------------
BFI_DEFAULT = "BFI ".._G.DEFAULT
-- BFI_PATH = [[Interface/AddOns/BFInfinite]]

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
BFI.vars = {} -- vars
-- BFI.widgets = {} -- widgets (regions/frames)
-- BFI.funcs = {} -- functions
BFI.libs = {}

BFI.utils = {} -- utils
AF.AddEventHandler(BFI.utils)

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.General = {}
AF.AddEventHandler(BFI.General)

BFI.Colors = {}
AF.AddEventHandler(BFI.Colors)

BFI.Misc = {}
AF.AddEventHandler(BFI.Misc)

BFI.DisableBlizzard = {}
AF.AddEventHandler(BFI.DisableBlizzard)

BFI.UIWidgets = {}
AF.AddEventHandler(BFI.UIWidgets)

BFI.Auras = {}
AF.AddEventHandler(BFI.Auras)

BFI.ActionBars = {["bars"] = {}}
AF.AddEventHandler(BFI.ActionBars)

BFI.UnitFrames = {}
AF.AddEventHandler(BFI.UnitFrames)

BFI.NamePlates = {}
AF.AddEventHandler(BFI.NamePlates)

BFI.Maps = {}
AF.AddEventHandler(BFI.Maps)

BFI.DataBars = {}
AF.AddEventHandler(BFI.DataBars)

BFI.Chat = {}
AF.AddEventHandler(BFI.Chat)

BFI.Tooltip = {}
AF.AddEventHandler(BFI.Tooltip)

BFI.Style = {}
AF.AddEventHandler(BFI.Style)

---------------------------------------------------------------------
-- libs
---------------------------------------------------------------------
local function AddLib(name, major, silent)
    BFI.libs[name] = _G.LibStub(major, silent)
end

AddLib("LAB", "LibActionButton-1.0-BFI")
AddLib("LRC", "LibRangeCheck-3.0")

---------------------------------------------------------------------
-- media
---------------------------------------------------------------------
BFI.media = {}
BFI.media.bar = AF.GetTexture("StatusBar1")
-- AF.Libs.LSM:Register("statusbar", "BFI", AF.GetTexture("StatusBar", BFI.name))
-- AF.Libs.LSM:Register("statusbar", "BFI Plain", AF.GetPlainTexture())
AF.Libs.LSM:Register("font", "BFI", AF.GetFont("Noto_AP_SC", BFI.name), 255)

AF.CreateFont("BFI", "BFI_FONT", AF.GetFont("CloseAndOpen", BFI.name), 25, "OUTLINE")