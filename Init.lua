---@class BFI
local BFI = select(2, ...)
_G.BigFootInfinite = BFI
_G.BFI = BFI

---@class BFI
---@field AW AbstractWidgets
---@field L table
---@field utils Utils
---@field vars table
---@field libs table
---@field ActionBars ActionBars
---@field UnitFrames UnitFrames
---@field NamePlates NamePlates
---@field Maps Maps
---@field UIWidgets UIWidgets
---@field DisableBlizzard DisableBlizzard
---@field Misc Misc

---------------------------------------------------------------------
-- global
---------------------------------------------------------------------
BFI_DEFAULT = "BFI ".._G.DEFAULT
-- BFI_PATH = [[Interface/AddOns/BigFootInfinite]]

---------------------------------------------------------------------
-- prefix
---------------------------------------------------------------------
BFI.prefix = "BFI"
BFI.name = "BigFootInfinite"

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
BFI.vars = {} -- vars
-- BFI.widgets = {} -- widgets (regions/frames)
-- BFI.funcs = {} -- functions
BFI.libs = {}

BFI.utils = {} -- utils
BFI.AddEventHandler(BFI.utils)

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
BFI.vars.isAsian = LOCALE_zhCN or LOCALE_zhTW or LOCALE_koKR

BFI.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BFI.vars.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
BFI.vars.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
BFI.vars.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

BFI.vars.playerClass = UnitClassBase("player")

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.Colors = {}
BFI.AddEventHandler(BFI.Colors)

BFI.Misc = {}
BFI.AddEventHandler(BFI.Misc)

BFI.Shared = {}
BFI.AddEventHandler(BFI.Shared)

BFI.DisableBlizzard = {}
BFI.AddEventHandler(BFI.DisableBlizzard)

BFI.UIWidgets = {}
BFI.AddEventHandler(BFI.UIWidgets)

BFI.ActionBars = {["bars"] = {}}
BFI.AddEventHandler(BFI.ActionBars)

BFI.UnitFrames = {}
BFI.AddEventHandler(BFI.UnitFrames)

BFI.NamePlates = {}
BFI.AddEventHandler(BFI.NamePlates)

BFI.Maps = {}
BFI.AddEventHandler(BFI.Maps)

---------------------------------------------------------------------
-- hidden parent
---------------------------------------------------------------------
BFI.hiddenParent = CreateFrame("Frame", nil, UIParent)
BFI.hiddenParent:SetPoint("BOTTOMLEFT")
BFI.hiddenParent:SetSize(1, 1)
BFI.hiddenParent:Hide()

---------------------------------------------------------------------
-- dummy
---------------------------------------------------------------------
BFI.dummy = function() end

---------------------------------------------------------------------
-- libs
---------------------------------------------------------------------
local function AddLib(name, major, silent)
    BFI.libs[name] = _G.LibStub(major, silent)
end

AddLib("LAB", "LibActionButton-1.0-BFI")
AddLib("LCG", "LibCustomGlow-1.0")
AddLib("LRC", "LibRangeCheck-3.0")