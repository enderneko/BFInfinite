local _, BFI = ...
_G.BigFootInfinite = BFI

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
-- BFI.widgets = {} -- widgets (regions/frames)
BFI.vars = {} -- vars
BFI.funcs = {} -- functions
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

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.M_AB = {["bars"] = {}}
BFI.AddEventHandler(BFI.M_AB)

BFI.M_UF = {}
BFI.AddEventHandler(BFI.M_UF)

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

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
local AW = BFI.AW

local colors = {
    -- BFI
    ["uf"] = {["t"]={0.125, 0.125, 0.125}}, -- unitframe foreground
    ["uf_loss"] = {["t"]={0.667, 0, 0}}, -- unitframe background
    ["uf_power"] = {["t"]={0.7, 0.7, 0.7}}, -- unitframe background
    ["cast_normal"] = {["t"]={0.4, 0.4, 0.4}},
    ["cast_failed"] = {["t"]={0.7, 0.3, 0.3}},
    ["cast_succeeded"] = {["t"]={0.3, 0.7, 0.3}},
    ["cast_uninterruptible"] = {["t"]={1, 0, 0}},
    ["shield"] = {["t"]={1, 1, 1, 1}},
    ["absorb"] = {["t"]={1, 0.1, 0.1, 1}},
    ["heal_prediction"] = {["t"]={1, 1, 1, 0.4}},
}

AW.AddColors(colors)