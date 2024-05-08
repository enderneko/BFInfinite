local _, BFI = ...
_G.BigFootInfinite = BFI

---------------------------------------------------------------------
-- prefix
---------------------------------------------------------------------
BFI.prefix = "BFI"

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
-- BFI.widgets = {} -- widgets (regions/frames)
BFI.vars = {} -- vars
BFI.funcs = {} -- functions
BFI.utils = {} -- utils
BFI.libs = {}

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
BFI.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BFI.vars.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
BFI.vars.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

BFI.vars.playerClass = UnitClassBase("player")

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.M_AB = {["bars"] = {}}
BFI.AddEventHandler(BFI.M_AB)

---------------------------------------------------------------------
-- hidden parent
---------------------------------------------------------------------
BFI.hiddenParent = CreateFrame("Frame")
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