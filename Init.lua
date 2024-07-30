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
---@field M_UnitFrames UnitFrame

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
BFI.M_Colors = {}
BFI.AddEventHandler(BFI.M_Colors)

BFI.M_Misc = {}
BFI.AddEventHandler(BFI.M_Misc)

BFI.M_Shared = {}
BFI.AddEventHandler(BFI.M_Shared)

BFI.M_ActionBars = {["bars"] = {}}
BFI.AddEventHandler(BFI.M_ActionBars)

BFI.M_UnitFrames = {}
BFI.AddEventHandler(BFI.M_UnitFrames)

BFI.M_NamePlates = {}
BFI.AddEventHandler(BFI.M_NamePlates)

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