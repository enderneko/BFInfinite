---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class UIWidgets
local W = BFI.modules.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local MICRO_BUTTONS = {
    "CharacterMicroButton",
    "ProfessionMicroButton",
    "PlayerSpellsMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "CollectionsMicroButton",
    "EJMicroButton",
    "StoreMicroButton",
    "MainMenuMicroButton",
}

local function UpdateHelpTicketButtonAnchor()
    local ticket = _G.HelpOpenWebTicketButton
    if not ticket then return end

    local first = _G[MICRO_BUTTONS[1]]
    if first then
        ticket:ClearAllPoints()
        ticket:SetPoint("CENTER", first, "TOP")
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local microMenu
local function CreateMicroMenu()
    microMenu = CreateFrame("Frame", "BFI_MicroMenu", AF.UIParent)

    microMenu.visibility = CreateFrame("Frame", nil, AF.UIParent, "SecureHandlerStateTemplate")
    microMenu.visibility:SetScript("OnShow", function()
        microMenu:Show()
    end)
    microMenu.visibility:SetScript("OnHide", function()
        microMenu:Hide()
    end)

    -- OnEnter/OnLeave
    microMenu.onEnter = function()
        AF.FrameFadeIn(microMenu, 0.25)
    end

    microMenu.onLeave = function()
        AF.FrameFadeOut(microMenu, 0.25, nil, microMenu.alpha)
    end

    microMenu:SetScript("OnEnter", microMenu.onEnter)
    microMenu:SetScript("OnLeave", microMenu.onLeave)

    -- buttons
    _G.ResetMicroMenuPosition()
    microMenu.buttons = {}
    for _, b in pairs(MICRO_BUTTONS) do
        if _G[b] then
            tinsert(microMenu.buttons, _G[b])
            _G[b]:SetParent(microMenu)
            _G[b]:HookScript("OnEnter", microMenu.onEnter)
            _G[b]:HookScript("OnLeave", microMenu.onLeave)
        end
    end

    -- ticket button anchor
    microMenu.UpdateHelpTicketButtonAnchor = AF.noop
    hooksecurefunc(_G.MicroMenu, "UpdateHelpTicketButtonAnchor", UpdateHelpTicketButtonAnchor)

    -- mover
    AF.CreateMover(microMenu, "BFI: " .. L["UI Widgets"], L["Micro Menu"])
end

---------------------------------------------------------------------
-- update button style
---------------------------------------------------------------------
local function UpdateButton(b)
    -- highlight
    b:SetHighlightTexture(AF.GetPlainTexture())
    local highlight = b:GetHighlightTexture()
    AF.SetOnePixelInside(highlight, b)
    highlight:SetVertexColor(1, 1, 1, 0.2)

    -- normal
    local normal = b:GetNormalTexture()
    AF.SetOnePixelInside(normal, b)
    normal:SetTexCoord(unpack(microMenu.buttonTexCoord))

    -- pushed
    local pushed = b:GetPushedTexture()
    AF.SetOnePixelInside(pushed, b)
    pushed:SetTexCoord(unpack(microMenu.buttonTexCoord))

    -- disabled
    local disabled = b:GetDisabledTexture()
    AF.SetOnePixelInside(disabled, b)
    disabled:SetTexCoord(unpack(microMenu.buttonTexCoord))

    -- FlashBorder
    -- AF.SetOnePixelInside(b.FlashBorder, b)
    -- b.FlashBorder:SetColorTexture(1, 1, 1, 0)

    -- guild emblem
    if b.Emblem then
        b.Emblem:SetScale(microMenu.guildEmblemScale)
        b.HighlightEmblem:SetScale(microMenu.guildEmblemScale)
    end

    -- hide unused
    if b.PushedBackground then b.PushedBackground:SetTexture() end
    if b.FlashContent then b.FlashContent:SetTexture() end
    if b.Background then b.Background:SetTexture() end
end

local function UpdatePortrait(b)
    AF.SetOnePixelInside(b.Portrait, b)
    b.Portrait:SetTexCoord(unpack(microMenu.portraitTexCoord))

    -- highlight
    b:SetHighlightTexture(AF.GetPlainTexture())
    local highlight = b:GetHighlightTexture()
    AF.SetOnePixelInside(highlight, b)
    highlight:SetAlpha(0.2)

    -- pushed
    b:SetPushedTexture(AF.GetPlainTexture())
    local pushed = b:GetPushedTexture()
    pushed:SetAlpha(0.2)
    pushed:SetDrawLayer("OVERLAY", 1)
    AF.SetOnePixelInside(pushed, b)

    -- hide unused
    b.PushedBackground:SetTexture()
    b.Background:SetTexture()
    b.PushedShadow:SetTexture()
    b.Shadow:SetTexture()
    b.PortraitMask:Hide()
end

local function ButtonOnEnter(b)
    b:GetNormalTexture():SetAlpha(1)
end

local function UpdatePixels()
    AF.DefaultUpdatePixels(microMenu)
    for _, b in next, microMenu.buttons do
        if b:GetName() == "CharacterMicroButton" then
            UpdatePortrait(b)
        else
            UpdateButton(b)
        end
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdateMicroMenu(_, module, which)
    if module and module ~= "uiWidgets" then return end
    if which and which ~= "microMenu" then return end

    if not microMenu then
        CreateMicroMenu()
        AF.AddToPixelUpdater_Auto(microMenu, UpdatePixels)
    end

    local config = W.config.microMenu

    microMenu.enabled = config.enabled

    -- alpha
    microMenu.alpha = config.alpha
    microMenu:SetAlpha(config.alpha)

    -- texCoord
    microMenu.buttonTexCoord = AF.CalcTexCoordPreCrop(0.17, config.width / config.height, 16 / 20.5)
    microMenu.portraitTexCoord = AF.CalcTexCoordPreCrop(0.1, config.width / config.height)
    microMenu.guildEmblemScale = AF.CalcScale(32, 40, config.width, config.height, 0.17)

    -- menu size
    AF.SetGridSize(microMenu, config.width, config.height, config.spacing, config.spacing, config.buttonsPerRow, ceil(11 / config.buttonsPerRow))

    -- buttons
    for i, b in pairs(microMenu.buttons) do
        AF.SetSize(b, config.width, config.height)

        -- style
        AF.ApplyDefaultBackdropWithColors(b)
        if b:GetName() == "CharacterMicroButton" then
            hooksecurefunc(b, "SetPushed", UpdatePortrait)
            hooksecurefunc(b, "SetNormal", UpdatePortrait)
        else
            hooksecurefunc(b, "SetHighlightAtlas", UpdateButton)
            hooksecurefunc(b, "SetPushed", UpdateButton)
            hooksecurefunc(b, "SetNormal", UpdateButton)
            b:HookScript("OnEnter", ButtonOnEnter)
        end

        -- arrangement
        AF.ClearPoints(b)
        if i == 1 then
            AF.SetPoint(b, "TOPLEFT")
        else
            if i % config.buttonsPerRow == 1 then
                AF.SetPoint(b, "TOPLEFT", microMenu.buttons[i - config.buttonsPerRow], "BOTTOMLEFT", 0, -config.spacing)
            else
                AF.SetPoint(b, "TOPLEFT", microMenu.buttons[i - 1], "TOPRIGHT", config.spacing, 0)
            end
        end
    end

    -- if not, MicroMenuMixin:GetEdgeButton will fail
    _G.HelpMicroButton:SetParent(microMenu)
    _G.HelpMicroButton:SetAllPoints(_G.StoreMicroButton)
    _G.HelpMicroButton:Hide()

    -- visibility
    if config.enabled then
        RegisterStateDriver(microMenu.visibility, "visibility", "[petbattle] hide; show")
    else
        RegisterStateDriver(microMenu.visibility, "visibility", "hide")
    end

    -- mover
    AF.UpdateMoverSave(microMenu, config.position)

    -- position
    AF.LoadPosition(microMenu, config.position)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateMicroMenu)