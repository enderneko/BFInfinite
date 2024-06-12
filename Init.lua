---@class BFI
local BFI = select(2, ...)
_G.BigFootInfinite = BFI
_G.BFI = BFI

---@class BFI
---@field AW AbstractWidgets
---@field utils Utils
---@field vars table
---@field libs table
---@field M_UF UnitFrame

---------------------------------------------------------------------
-- global
---------------------------------------------------------------------
BFI_DEFAULT = "BFI ".._G.DEFAULT
-- BFI_PATH = [[Interface/AddOns/BigFootInfinite]]

---------------------------------------------------------------------
-- prefix
---------------------------------------------------------------------
BFI.prefix = "BFI"

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
BFI.vars = {} -- vars
-- BFI.widgets = {} -- widgets (regions/frames)
-- BFI.funcs = {} -- functions
BFI.utils = {} -- utils
BFI.libs = {}

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
BFI.vars.isAsian = LOCALE_zhCN or LOCALE_zhTW or LOCALE_koKR

BFI.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BFI.vars.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
BFI.vars.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

BFI.vars.playerClass = UnitClassBase("player")
BFI.vars.playerSpecID = GetSpecialization()

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.M_C = {}
BFI.AddEventHandler(BFI.M_C)

BFI.M_AB = {["bars"] = {}}
BFI.AddEventHandler(BFI.M_AB)

BFI.M_UF = {}
BFI.AddEventHandler(BFI.M_UF)

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