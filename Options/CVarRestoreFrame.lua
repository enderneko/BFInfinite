---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local cvarRestoreFrame

local function CreateCVarRestoreFrame()
    cvarRestoreFrame = AF.CreateBorderedFrame(BFIOptionsFrame_AboutPanel, "BFIOptionsFrame_CVarRestoreFrame", 350, 300, nil, "BFI")
    AF.SetPoint(cvarRestoreFrame, "TOPRIGHT", BFIOptionsFrame_AboutPanel.bfiPane.line, "BOTTOMRIGHT", 0, -1)
    cvarRestoreFrame:Hide()

    AF.SetFrameLevel(cvarRestoreFrame, 110)
    cvarRestoreFrame:SetOnShow(function()
        cvarRestoreFrame:Show()
        AF.SetFrameLevel(BFIOptionsFrame_AboutPanel.bfiPane.cvarRestore, 110)
        AF.ShowMask(BFIOptionsFrame_AboutPanel)
    end)
    cvarRestoreFrame:SetOnHide(function()
        cvarRestoreFrame:Hide()
        AF.SetFrameLevel(BFIOptionsFrame_AboutPanel.bfiPane.cvarRestore, 1)
        AF.HideMask(BFIOptionsFrame_AboutPanel)
    end)

    local restore = AF.CreateButton(cvarRestoreFrame, L["Restore CVars & Disable BFI"], "red", nil, 20)
    AF.SetPoint(restore, "BOTTOMLEFT", 10, 10)
    AF.SetPoint(restore, "BOTTOMRIGHT", -10, 10)
    restore:SetTooltip(L["Shift Click"])
    restore:SetOnClick(function()
        if IsShiftKeyDown() then
            for k, v in next, BFICVarBackup.cvars do
                SetCVar(k, v)
            end
            wipe(BFICVarBackup)
            C_AddOns.DisableAddOn(BFI.name)
            ReloadUI()
        end
    end)

    local box = AF.CreateScrollEditBox(cvarRestoreFrame)
    AF.SetPoint(box, "TOPLEFT", 10, -25)
    AF.SetPoint(box, "BOTTOMRIGHT", restore, "TOPRIGHT", 0, 10)
    box:SetNotUserChangable(true)

    local label = AF.CreateFontString(cvarRestoreFrame, L["BFI Modified CVars"], "BFI")
    AF.SetPoint(label, "BOTTOMLEFT", box, "TOPLEFT", 2, 2)

    local pattern = AF.WrapTextInColor("\"", "darkgray") .. "%s" .. AF.WrapTextInColor("\":\"", "darkgray")
        .. AF.WrapTextInColor("%s", "softlime") .. AF.WrapTextInColor("\"", "darkgray")

    local lines = {}
    for k, v in next, BFICVarBackup.cvars do
        tinsert(lines, pattern:format(k, v))
    end
    table.sort(lines)
    box:SetText(table.concat(lines, "\n"))
end

---------------------------------------------------------------------
-- show notice
---------------------------------------------------------------------
function F.ShowCVarBackupNotice()
    AF.RegisterCallback("AF_POPUPS_READY", function()
        AF.ShowConfirmPopup(L["CVars that will be modified by BFI have been backed up. You can restore them in %1$s under %2$s if needed"]:format(
            AF.WrapTextInColor(L["CVar Restore"], "BFI"),
            AF.WrapTextInColor(L["About"], "BFI")
        ), nil, false)
    end)
end

---------------------------------------------------------------------
-- toggle
---------------------------------------------------------------------
function F.ToggleCVarRestoreFrame()
    if not cvarRestoreFrame then
        CreateCVarRestoreFrame()
    end
    AF.Toggle(cvarRestoreFrame)
end