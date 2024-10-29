---@class BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.Chat
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local U = BFI.utils

-- Interface/AddOns/Blizzard_ChatFrameBase/Mainline/FloatingChatFrame.lua#L385
C.CHAT_FONT_HEIGHTS = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

local CHAT_TAB_TEXTURES = {
    "",
    "Active",
    "Highlight"
}

---------------------------------------------------------------------
-- container
---------------------------------------------------------------------
local chatContainer
local function CreateChatContainer()
    chatContainer = AW.CreateBorderedFrame(AW.UIParent, "BFIChatFrame")
    chatContainer:SetFrameStrata("BACKGROUND")
    AW.CreateMover(chatContainer, _G.OTHER, _G.HUD_EDIT_MODE_CHAT_FRAME_LABEL)
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local CHAT_FRAMES = _G.CHAT_FRAMES
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local CHAT_FRAME_TEXTURES = _G.CHAT_FRAME_TEXTURES
local EditModeManagerFrame = _G.EditModeManagerFrame
local ChatFrame2 = _G.ChatFrame2

-- ignore FCF_FadeInChatFrame/FCF_FadeOutChatFrame
-- make it a fixed alpha
local function FixTabAlpha(tab, _, skip)
    if skip then return end
    local owner = tab.owner
    local selected = _G.GeneralDockManager.selected
    tab:SetAlpha((not owner.isDocked or owner == selected) and 1 or 0.6, true)
end

local function SetupChat()
    for _, name in pairs(CHAT_FRAMES) do
        local frame = _G[name]

        local id = frame:GetID() -- 2:combatlog, 3:voice
        if not frame.tab then
            frame.tab = _G[format("ChatFrame%sTab", id)]
            frame.tab.owner = frame
            FixTabAlpha(frame.tab)
            hooksecurefunc(frame.tab, "SetAlpha", FixTabAlpha)
        end

        -- texture
        for _, tex in pairs(CHAT_FRAME_TEXTURES) do
            local f = _G[name .. tex]
            f:Hide()
        end
        U.Hide(frame.ScrollBar)

        -- tab
        local tab = frame.tab
        U.SetFont(tab.Text, unpack(C.config.tabFont))
        tab.Text:SetTextColor(AW.GetAccentColorRGB())
        tab:SetPushedTextOffset(0, -1)

        if not tab.underline then
            tab.underline = AW.CreateSeparator(tab, 1, 1, BFI.name)
            tab.underline:SetPoint("TOP", tab.Text, "BOTTOM", 0, -2)
            tab.underline:Hide()
        end

        for _, prefix in pairs(CHAT_TAB_TEXTURES) do
            local left = tab[prefix .. "Left"]
            local middle = tab[prefix .. "Middle"]
            local right = tab[prefix .. "Right"]

            if left then left:SetTexture() end
            if middle then middle:SetTexture() end
            if right then right:SetTexture() end
        end

        -- docked
        if frame.isDocked then
            frame.Background:Hide()
        else
            frame.Background:Show()
        end

        -- misc
        frame:SetMaxLines(C.config.maxLines)
        frame:SetTimeVisible(C.config.fadeTime)
        frame:SetFading(C.config.fading)
        U.SetFont(frame, unpack(C.config.font))
    end
end

local function SetupDefaultChatFrame()
    local function Update()
        DEFAULT_CHAT_FRAME:SetClampRectInsets(0, 0, 0, 0)
        DEFAULT_CHAT_FRAME:SetParent(chatContainer)
        AW.ClearPoints(DEFAULT_CHAT_FRAME)
        AW.SetPoint(DEFAULT_CHAT_FRAME, "TOPLEFT", chatContainer, 3, -27)
        AW.SetPoint(DEFAULT_CHAT_FRAME, "BOTTOMRIGHT", chatContainer, -3, 3)
    end
    Update()

    -- editmode
    U.DisableEditMode(DEFAULT_CHAT_FRAME)
    U.Hide(DEFAULT_CHAT_FRAME.EditModeResizeButton)
    hooksecurefunc(EditModeManagerFrame, "UpdateLayoutInfo", Update)
end

---------------------------------------------------------------------
-- hooks
---------------------------------------------------------------------
local function UpdateTabUnderline(frame)
    frame.tab.underline:SetWidth(frame.tab.Text:GetStringWidth() + 2)
end

local function UpdateAllTabUnderlines()
    C_Timer.After(1, function()
        for _, name in pairs(CHAT_FRAMES) do
            UpdateTabUnderline(_G[name])
        end
    end)
end

local function UpdateTabColor(tab, selected)
    if not tab.underline then return end
    if selected then
        tab.Text:SetTextColor(AW.GetAccentColorRGB())
        tab.underline:Show()
    else
        tab.Text:SetTextColor(1, 1, 1)
        tab.underline:Hide()
    end
end

-- local function UpdateChatFont(dropdown, ...)
--     -- TODO: necessary?
--     print(...)
-- end

local function UpdateFrameDocked(frame, isDocked)
    if not isDocked then
        frame.tab.Text:SetTextColor(AW.GetAccentColorRGB())
        frame.tab.underline:Hide()
        frame.Background:Show()
    else
        frame.Background:Hide()
    end
end

local function UpdateCombatLog()
    if not C.config.enabled then return end

    _G.CombatLogQuickButtonFrame_Custom:SetPoint("BOTTOMRIGHT", ChatFrame2, "TOPRIGHT", 0, 3)

    -- font
    for i in ipairs(_G.Blizzard_CombatLog_Filters.filters) do
        local b = _G["CombatLogQuickButtonFrameButton" .. i]
        if b then
            local fs = b:GetFontString()
            if fs then
                fs:SetFont(AW.GetFont("Noto_AP_SC", BFI.name), 13, "")
            end
        end
    end

    -- progress bar
    local bar = _G.CombatLogQuickButtonFrame_CustomProgressBar
    bar:SetStatusBarTexture(U.GetBarTexture("BFI"))
    bar:SetAlpha(0.75)
    AW.SetOnePixelInside(bar, _G.CombatLogQuickButtonFrame_Custom)
end
BFI.RegisterCallbackForAddon("Blizzard_CombatLog", UpdateCombatLog)

local function InitHooks()
    hooksecurefunc("FCF_SetWindowName", UpdateTabUnderline)
    hooksecurefunc("FCFTab_UpdateColors", UpdateTabColor)
    -- hooksecurefunc("FCF_SetChatWindowFontSize", UpdateChatFont)
    hooksecurefunc("FCF_DockFrame", UpdateFrameDocked)
    hooksecurefunc("FCF_UnDockFrame", UpdateFrameDocked)
    hooksecurefunc("Blizzard_CombatLog_Update_QuickButtons", UpdateCombatLog)
    hooksecurefunc("Blizzard_CombatLog_QuickButtonFrame_OnLoad", UpdateCombatLog)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateChat(module)
    if module and module ~= "Chat" then return end

    local config = C.config
    if chatContainer then
        chatContainer.enabled = config.enabled -- for mover
    end
    if not config.enabled then
        C:UnregisterAllEvents()
        return
    end

    -- override CHAT_FONT_HEIGHTS
    _G.CHAT_FONT_HEIGHTS = C.CHAT_FONT_HEIGHTS

    if not chatContainer then
        CreateChatContainer()
        SetupDefaultChatFrame()
        InitHooks()
    end

    SetupChat()
    C:RegisterEvent("UPDATE_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("FIRST_FRAME_RENDERED", UpdateAllTabUnderlines)

    AW.UpdateMoverSave(chatContainer, config.position)
    AW.LoadPosition(chatContainer, config.position)
    AW.SetSize(chatContainer, config.width, config.height)
end
BFI.RegisterCallback("UpdateModules", "Chat", UpdateChat)