---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local GameMenuFrame = _G.GameMenuFrame
local IsStoreEnabled = C_StorePublic.IsEnabled
local HasExternalEventURL = C_ExternalEventURL.HasURL
local GAMEMENU_EXTERNALEVENT = _G.GAMEMENU_EXTERNALEVENT
local GAMEMENU_OPTIONS = _G.GAMEMENU_OPTIONS
local BLIZZARD_STORE = _G.BLIZZARD_STORE
local LOG_OUT = _G.LOG_OUT
local EXIT_GAME = _G.EXIT_GAME
local RETURN_TO_GAME = _G.RETURN_TO_GAME
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT

---------------------------------------------------------------------
-- header
---------------------------------------------------------------------
local function UpdateHeader()
    GameMenuFrame.Header:SetAlpha(0)

    local text = GameMenuFrame.Header.Text
    text:SetParent(GameMenuFrame)
    text:SetFontObject("GameFontNormalLarge")
    text:SetTextColor(AF.GetColorRGB("BFI"))
    AF.ClearPoints(text)
    AF.SetPoint(text, "TOP", 0, -15)
end

---------------------------------------------------------------------
-- BFI button
---------------------------------------------------------------------
local function ReArrangeButtons()
    local BFIButton = GameMenuFrame.BFI
    if not BFIButton then return end

    AF.ReBorder(BFIButton)

    local target = IsStoreEnabled() and BLIZZARD_STORE or GAMEMENU_OPTIONS
    local anchored

    for button in GameMenuFrame.buttonPool:EnumerateActive() do
        local text = button:GetText()
        if text == target then
            BFIButton:SetPoint("TOP", button, "BOTTOM", 0, -14)
            BFIButton:SetSize(button.BFIBackdrop:GetSize())
            AF.ReBorder(BFIButton)
        elseif text == LOG_OUT or text == EXIT_GAME then
            button:AdjustPointsOffset(0, -35)
        elseif text == RETURN_TO_GAME then
            button:AdjustPointsOffset(0, -28)
        elseif text ~= BLIZZARD_STORE and text ~= GAMEMENU_OPTIONS and text ~= GAMEMENU_EXTERNALEVENT then
            button:AdjustPointsOffset(0, -42)
        end
    end

    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 15)
end

local function CreateBFIButton()
    local button = AF.CreateButton(GameMenuFrame, "BFI", "BFI_hover", nil, nil, nil, nil, nil, "GameFontHighlightLarge")
    GameMenuFrame.BFI = button

    button:SetOnClick(function()
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1.0, 0.1, 0.1, 1.0)
        else
            F.ToggleOptionsFrame()
            HideUIPanel(GameMenuFrame)
        end
    end)
end

---------------------------------------------------------------------
-- ReHook
---------------------------------------------------------------------
local function ReHook(self, script)
    if script == "OnEnter" then
        self:HookScript("OnEnter", self.BFI_OnEnter)
    elseif script == "OnLeave" then
        self:HookScript("OnLeave", self.BFI_OnLeave)
    elseif script == "OnEnable" then
        self:HookScript("OnEnable", self.BFI_OnEnable)
    elseif script == "OnDisable" then
        self:HookScript("OnDisable", self.BFI_OnDisable)
    end
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    S.RemoveBorder(GameMenuFrame)
    S.CreateBackdrop(GameMenuFrame)

    -- LayoutMixin:Layout()
    hooksecurefunc(GameMenuFrame, "Layout", ReArrangeButtons)

    hooksecurefunc(GameMenuFrame, "InitButtons", function(menu)
        if not menu.buttonPool then return end

        for button in menu.buttonPool:EnumerateActive() do
            if not button._BFIStyled then
                S.StyleButton(button)
                AF.SetInside(button.BFIBackdrop, button, 1, 1)
                hooksecurefunc(button, "SetScript", ReHook)
            end
        end
    end)

    UpdateHeader()
    CreateBFIButton()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)