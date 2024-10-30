---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Chat
local C = BFI.Chat
---@class AbstractFramework
local AF = _G.AbstractFramework

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
    chatContainer = AF.CreateBorderedFrame(AF.UIParent, "BFIChatContainer")
    chatContainer:SetFrameStrata("BACKGROUND")
    AF.CreateMover(chatContainer, "BFI: " .. _G.OTHER, _G.HUD_EDIT_MODE_CHAT_FRAME_LABEL)
end

---------------------------------------------------------------------
-- copy frame
---------------------------------------------------------------------
local lines = {}
-- local debug = {}

local function RaidIconRepl(index)
    index = index ~= "" and _G["RAID_TARGET_" .. index]
    return index and ("{" .. strlower(index) .. "}") or ""
end

local function TextureRepl(w, x, y)
    if x == "" then
        return (w ~= "" and w) or (y ~= "" and y) or ""
    end
end

local function RemoveIcons(text)
    text = gsub(text, [[|TInterface\TargetingFrame\UI%-RaidTargetingIcon_(%d+):0|t]], RaidIconRepl)
    text = gsub(text, "(%s?)(|?)|[TA].-|[ta](%s?)", TextureRepl)
    return text
end

local function FixColorES(text)
    local _, count1 = gsub(text, "|c", "")
    local _, count2 = gsub(text, "|r", "")
    if count1 > count2 then
        for i = 1, count1 - count2 do
            text = text .. "|r"
        end
    elseif count1 < count2 then
        text = gsub(text, "|r", "", count2 - count1)
    end
    return text
end

local function UpdateText(eb, shouldUpdate)
    if shouldUpdate then
        eb:SetText(table.concat(lines, "\n"))
    end
end

local chatCopyFrame
local function CreateChatCopyFrame()
    chatCopyFrame = CreateFrame("Frame", "BFIChatCopyFrame", AF.UIParent)
    chatCopyFrame:Hide()
    chatCopyFrame:SetFrameStrata("DIALOG")
    chatCopyFrame:EnableMouse(true)
    chatCopyFrame:SetScript("OnMouseWheel", BFI.dummy)
    tinsert(UISpecialFrames, "BFIChatCopyFrame")

    chatCopyFrame.scroll = AF.CreateScrollEditBox(chatCopyFrame, nil, nil, 20, 20)
    chatCopyFrame.scroll:SetAllPoints()
    chatCopyFrame.scroll.eb:SetScript("OnEscapePressed", function()
        chatCopyFrame.scroll.eb:ClearFocus()
        chatCopyFrame:Hide()
    end)

    chatCopyFrame.scroll.eb:HookScript("OnTextChanged", UpdateText)
    chatCopyFrame.scroll:HookScript("OnSizeChanged", chatCopyFrame.scroll.ScrollToBottom)
end

local function ShowChatCopyFrame(b)
    local frame = b:GetParent()
    chatCopyFrame:SetAllPoints(frame)

    wipe(lines)
    -- wipe(debug)
    for i = 1, frame:GetNumMessages() do
        local text, r, g, b, chatTypeID, messageAccessID, lineID = frame:GetMessageInfo(i)
        r, g, b = r or 1, g or 1, b or 1

        text = RemoveIcons(text)
        text = FixColorES(text)

        tinsert(lines, AF.WrapTextInColorRGB(text, r, g, b))
        -- tinsert(debug, text)
    end
    -- texplore(debug)

    chatCopyFrame:Show()
    C_Timer.After(0.05, function()
        UpdateText(chatCopyFrame.scroll.eb, true)
    end)
end

local function HideChatCopyFrame()
    chatCopyFrame:Hide()
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

local function CreateScrollToBottomButton(frame)
    local b = AF.CreateIconButton(frame, AF.GetIcon("ArrowDoubleDown"), 20, 20, 0, AF.GetColorTable("white", 0.5))
    b:Hide()
    b:SetPoint("BOTTOMRIGHT")
    b:SetScript("OnClick", function()
        frame:ScrollToBottom()
    end)

    frame.BFIScrollToBottomButton = b
end

local function CreateCopyButton(frame)
    local b = AF.CreateIconButton(frame, AF.GetIcon("Copy", BFI.name), 20, 20, 3, AF.GetColorTable("white", 0.5))
    b:Hide()
    b:SetPoint("TOPRIGHT")
    b:SetScript("OnClick", ShowChatCopyFrame)

    frame.BFICopyButton = b
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

        -- scorll to bottom
        U.Hide(frame.ScrollToBottomButton)
        if not frame.BFIScrollToBottomButton then
            CreateScrollToBottomButton(frame)
        end

        -- copy
        if not frame.BFICopyButton then
            CreateCopyButton(frame)
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
        tab.Text:SetTextColor(AF.GetAccentColorRGB())
        tab:SetPushedTextOffset(0, -1)

        if not tab.underline then
            tab.underline = AF.CreateSeparator(tab, 1, 1, BFI.name)
            tab.underline:SetPoint("TOP", tab.Text, "BOTTOM", 0, -2)
            tab.underline:Hide()
            tab:HookScript("OnClick", HideChatCopyFrame)
        end

        for _, prefix in pairs(CHAT_TAB_TEXTURES) do
            local left = tab[prefix .. "Left"]
            local middle = tab[prefix .. "Middle"]
            local right = tab[prefix .. "Right"]

            if left then left:SetTexture() end
            if middle then middle:SetTexture() end
            if right then right:SetTexture() end
        end

        -- background
        AF.SetOutside(frame.Background, frame, 3)
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
        AF.ClearPoints(DEFAULT_CHAT_FRAME)
        AF.SetPoint(DEFAULT_CHAT_FRAME, "TOPLEFT", chatContainer, 3, -27)
        AF.SetPoint(DEFAULT_CHAT_FRAME, "BOTTOMRIGHT", chatContainer, -3, 3)
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
        tab.Text:SetTextColor(AF.GetAccentColorRGB())
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
        frame.tab.Text:SetTextColor(AF.GetAccentColorRGB())
        frame.tab.underline:Hide()
        frame.Background:Show()
    else
        frame.Background:Hide()
    end
end

local function UpdateScrollToBottomButton(frame, elapsed)
    frame.__elapsed = (frame.__elapsed or 0) + elapsed
    if frame.__elapsed >= 0.2 then
        frame.__elapsed = 0
        frame.BFIScrollToBottomButton:SetShown(not frame:AtBottom())
        frame.BFICopyButton:SetShown(frame:IsMouseOver() or frame.BFICopyButton:IsMouseOver() or frame.BFIScrollToBottomButton:IsMouseOver())
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
                fs:SetFont(AF.GetFont("Noto_AP_SC", BFI.name), 13, "")
            end
        end
    end

    -- progress bar
    local bar = _G.CombatLogQuickButtonFrame_CustomProgressBar
    bar:SetStatusBarTexture(U.GetBarTexture("BFI"))
    bar:SetAlpha(0.75)
    AF.SetOnePixelInside(bar, _G.CombatLogQuickButtonFrame_Custom)
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
    hooksecurefunc("ChatFrame_OnUpdate", UpdateScrollToBottomButton)
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
        CreateChatCopyFrame()
        SetupDefaultChatFrame()
        InitHooks()
    end

    SetupChat()
    C:RegisterEvent("UPDATE_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("FIRST_FRAME_RENDERED", UpdateAllTabUnderlines)

    U.SetFont(chatCopyFrame.scroll.eb, unpack(C.config.font))

    AF.UpdateMoverSave(chatContainer, config.position)
    AF.LoadPosition(chatContainer, config.position)
    AF.SetSize(chatContainer, config.width, config.height)
end
BFI.RegisterCallback("UpdateModules", "Chat", UpdateChat)