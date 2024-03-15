local _, BFI = ...
_G.BigFootInfinite = BFI

---------------------------------------------------------------------
-- prefix
---------------------------------------------------------------------
BFI.prefix = "BFI"

---------------------------------------------------------------------
-- tables
---------------------------------------------------------------------
BFI.widgets = {} -- widgets (regions/frames)
BFI.vars = {} -- vars
BFI.funcs = {} -- functions
BFI.utils = {} -- utils
BFI.libs = {}

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
BFI.vars.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BFI.vars.isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
BFI.vars.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

---------------------------------------------------------------------
-- modules
---------------------------------------------------------------------
BFI.M_AB = {
    ["bars"] = {},
}
BFI.AddEventHandler(BFI.M_AB)

---------------------------------------------------------------------
-- hidden parent
---------------------------------------------------------------------
BFI.widgets.hiddenParent = CreateFrame("Frame")
BFI.widgets.hiddenParent:SetPoint("BOTTOMLEFT")
BFI.widgets.hiddenParent:SetSize(1, 1)
BFI.widgets.hiddenParent:Hide()

---------------------------------------------------------------------
-- libs
---------------------------------------------------------------------
local function AddLib(name, major, silent)
    BFI.libs[name] = _G.LibStub(major, silent)
end

AddLib("LAB", "LibActionButton-1.0-BFI")
AddLib("LCG", "LibCustomGlow-1.0")

do
    -- expand LCG
    local LCG, buttons, proc = BFI.libs.LCG, {}, {xOffset = 3, yOffset = 3}

    function LCG.ShowOverlayGlow(button)
        
    end
    
    function LCG.HideOverlayGlow(button)
        
    end
end