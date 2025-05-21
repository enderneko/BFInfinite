---@class BFI
local BFI = select(2, ...)
local U = BFI.utils
---@class Chat
local C = BFI.Chat
---@type AbstractFramework
local AF = _G.AbstractFramework

local CHAT_FRAMES = _G.CHAT_FRAMES
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local CHAT_FRAME_TEXTURES = _G.CHAT_FRAME_TEXTURES
local EditModeManagerFrame = _G.EditModeManagerFrame
local ChatFrame2 = _G.ChatFrame2
local TextToSpeechButtonFrame = _G.TextToSpeechButtonFrame
local ChatFrameMenuButton = _G.ChatFrameMenuButton
local ChatFrameChannelButton = _G.ChatFrameChannelButton
local ChatFrameToggleVoiceDeafenButton = _G.ChatFrameToggleVoiceDeafenButton
local ChatFrameToggleVoiceMuteButton = _G.ChatFrameToggleVoiceMuteButton
local QuickJoinToastButton = _G.QuickJoinToastButton

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
    chatContainer = AF.CreateBorderedFrame(AF.UIParent, "BFI_ChatContainer")
    chatContainer:SetFrameStrata("LOW")
    AF.CreateMover(chatContainer, "BFI: " .. _G.OTHER, _G.HUD_EDIT_MODE_CHAT_FRAME_LABEL)
end

---------------------------------------------------------------------
-- copy frame
---------------------------------------------------------------------
local lines = {}
-- local debug = {}

local GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local function FixBNWhisper(text)
    --! be careful with ":" and "："
    -- 发送给 |HBNplayer:|Kp116|k:113:635:BN_WHISPER:|Kp116|k|h[|Kp116|k]|h：xxxxxx
    if strfind(text, "k:%d+:%d+:BN_WHISPER:") then
        local id = tonumber(strmatch(text, "k:(%d+):%d+:BN_WHISPER:"))
        local info = GetAccountInfoByID(id)
        if info and info.battleTag then
            local tag = strsplit("#", info.battleTag)
            return gsub(text, "|HBNplayer:.*:.*:.*:BN_WHISPER:.*|h", "[" .. tag .. "]")
        end
    end
    return text
end

-- forked from ElvUI
local function RaidIconRepl(index)
    index = index ~= "" and _G["RAID_TARGET_" .. index]
    return index and ("{" .. strlower(index) .. "}") or ""
end

local function CombatLogRaidIconRepl(index)
    -- star - |Hicon:1:dest|h|h
    -- circle - 2
    -- diamond - 4
    -- triangle - 8
    -- moon - 16
    -- square - 32
    -- cross - 64
    -- skull - |Hicon:128:source|h|h
    index = log(tonumber(index)) / log(2) + 1
    return "{" .. _G["RAID_TARGET_" .. index] .. "}"
end

-- forked from ElvUI
local function TextureRepl(w, x, y)
    if x == "" then
        return (w ~= "" and w) or (y ~= "" and y) or ""
    end
end

local function RemoveIcons(text)
    -- forked from ElvUI
    text = gsub(text, [[|TInterface\TargetingFrame\UI%-RaidTargetingIcon_(%d+):0|t]], RaidIconRepl)
    text = gsub(text, "(%s?)(|?)|[TA].-|[ta](%s?)", TextureRepl)
    text = gsub(text, [[|Hicon:(%d+):[^:]+|h|h]], CombatLogRaidIconRepl)
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

local chatCopyFrame
local function UpdateText(eb, shouldUpdate)
    if shouldUpdate then
        eb:SetText(table.concat(lines, "\n"))
    end
    chatCopyFrame.scroll:ScrollToBottom()
end

local function CreateChatCopyFrame()
    chatCopyFrame = CreateFrame("Frame", "BFIChatCopyFrame", AF.UIParent)
    chatCopyFrame:Hide()
    chatCopyFrame:SetFrameStrata("DIALOG")
    chatCopyFrame:EnableMouse(true)
    chatCopyFrame:SetScript("OnMouseWheel", AF.noop)
    tinsert(UISpecialFrames, "BFIChatCopyFrame")

    chatCopyFrame.scroll = AF.CreateScrollEditBox(chatCopyFrame, nil, nil, 20, 20, 5)
    chatCopyFrame.scroll:SetAllPoints()
    chatCopyFrame.scroll.eb:SetScript("OnEscapePressed", function()
        chatCopyFrame.scroll.eb:ClearFocus()
        chatCopyFrame:Hide()
    end)

    chatCopyFrame.scroll.eb:HookScript("OnTextChanged", UpdateText)
end

local function ShowChatCopyFrame(b)
    local frame = b:GetParent()
    chatCopyFrame:SetAllPoints(frame)

    wipe(lines)
    -- wipe(debug)
    for i = 1, frame:GetNumMessages() do
        local text, r, g, b, chatTypeID, messageAccessID, lineID = frame:GetMessageInfo(i)
        r, g, b = r or 1, g or 1, b or 1

        text = FixBNWhisper(text)
        text = RemoveIcons(text)
        text = FixColorES(text)

        tinsert(lines, AF.WrapTextInColorRGB(text, r, g, b))
        -- tinsert(debug, text)
    end
    -- texplore(debug)

    chatCopyFrame:Show()
    UpdateText(chatCopyFrame.scroll.eb, true)
end

local function HideChatCopyFrame()
    chatCopyFrame:Hide()
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
-- ignore FCF_FadeInChatFrame/FCF_FadeOutChatFrame
-- make it a fixed alpha
local function FixTabAlpha(tab, _, skip)
    if skip then return end
    local owner = tab.owner
    local selected = _G.GeneralDockManager.selected
    tab:SetAlpha((not owner.isDocked or owner == selected) and 1 or 0.6, true)
end

local function CreateScrollToBottomButton(frame)
    local b = AF.CreateIconButton(frame, AF.GetIcon("ArrowDoubleDown"), 18, 18, 0, AF.GetColorTable("white", 0.5))
    b:Hide()
    b:SetPoint("BOTTOMRIGHT")
    b:SetScript("OnClick", function()
        frame:ScrollToBottom()
    end)

    frame.BFIScrollToBottomButton = b
end

local function CreateCopyButton(frame)
    if frame.BFICopyButton then return end

    local b = AF.CreateIconButton(frame, AF.GetIcon("Copy", BFI.name), 18, 18, 1, AF.GetColorTable("white", 0.5))
    frame.BFICopyButton = b
    b:Hide()
    b:SetPoint("TOPRIGHT")
    b:SetScript("OnClick", ShowChatCopyFrame)
end

local function CreateMinimizeButton(frame)
    if frame.BFIMinimizeButton then return end

    local b = AF.CreateIconButton(frame, AF.GetIcon("Minimize"), 18, 18, 0, AF.GetColorTable("white", 0.5))
    frame.BFIMinimizeButton = b
    b:Hide()
    AF.SetPoint(b, "TOPRIGHT", -20, 0)
    b:SetOnClick(function()
        FCF_DockFrame(frame)
        frame.Background:Hide()
    end)
end

local function GetTab(frame)
    -- mainly for temporary window
    if not frame.tab then
        local tab = _G[format("ChatFrame%sTab", frame:GetID())]
        frame.tab = tab
        tab.owner = frame
        FixTabAlpha(tab)
        hooksecurefunc(tab, "SetAlpha", FixTabAlpha)

        tab.underline = AF.CreateSeparator(tab, nil, 1, BFI.name)
        AF.SetPoint(tab.underline, "TOP", tab.Text, "BOTTOM", 0, -2)
        tab.underline:Hide()
        tab:HookScript("OnClick", HideChatCopyFrame)
    end
    return frame.tab
end

local function UpdateFrameDocked(frame, isDocked)
    if not isDocked then
        local tab = GetTab(frame)
        tab.Text:SetTextColor(AF.GetColorRGB(BFI.name))
        frame.Background:Show()
        tab.underline:Hide()

        if frame:GetID() == 2 then
            AF.ClearPoints(frame.Background)
            AF.SetPoint(frame.Background, "TOPLEFT", frame, -3, 30)
            AF.SetPoint(frame.Background, "BOTTOMRIGHT", frame, 3, -3)
        else
            AF.SetOutside(frame.Background, frame, 3)
        end
    else
        frame.Background:Hide()
    end
end

local function SetupChat()
    for _, name in pairs(CHAT_FRAMES) do
        local frame = _G[name]
        -- local id = frame:GetID() -- 2:combatlog, 3:voice

        -- scorll to bottom
        U.Hide(frame.ScrollToBottomButton)
        if not frame.BFIScrollToBottomButton then
            CreateScrollToBottomButton(frame)
        end

        -- copy
        CreateCopyButton(frame)

        -- minimize
        CreateMinimizeButton(frame)

        -- texture
        for _, tex in pairs(CHAT_FRAME_TEXTURES) do
            local f = _G[name .. tex]
            f:Hide()
        end
        U.Hide(frame.ScrollBar)

        -- tab
        local tab = GetTab(frame)
        AF.SetFont(tab.Text, unpack(C.config.tabFont))
        tab.Text:ClearAllPoints()
        tab.Text:SetPoint("CENTER", 0, -5)
        tab.Text:SetJustifyH("CENTER")
        tab:SetPushedTextOffset(0, -1)

        for _, prefix in pairs(CHAT_TAB_TEXTURES) do
            local left = tab[prefix .. "Left"]
            local middle = tab[prefix .. "Middle"]
            local right = tab[prefix .. "Right"]

            if left then left:SetTexture() end
            if middle then middle:SetTexture() end
            if right then right:SetTexture() end
        end

        -- conversationIcon
        if tab.conversationIcon then
            tab.conversationIcon:ClearAllPoints()
            tab.conversationIcon:SetPoint("RIGHT", tab.Text, "LEFT", -1, 0)
            -- tab.conversationIcon:SetDrawLayer("HIGHLIGHT")
        end

        -- background
        AF.SetOutside(frame.Background, frame, 3)
        UpdateFrameDocked(frame, frame.isDocked)

        -- editBox
        if frame.editBox and not frame.editBox.skinned then
            local editBox = frame.editBox
            editBox.skinned = true
            editBox:SetAltArrowKeyMode(false)
            -- position
            editBox:ClearAllPoints()
            AF.SetHeight(editBox, 24)
            AF.SetWidth(editBox, C.config.width)
            AF.LoadWidgetPosition(editBox, C.config.editBoxPosition, frame)
            -- style
            U.ReSkinEditBox(editBox)
        end

        -- ButtonFrame
        if frame.buttonFrame then
            frame.buttonFrame:SetParent(AF.hiddenParent)
            frame.buttonFrame:Hide()
        end

        -- misc
        frame:SetMaxLines(C.config.maxLines)
        frame:SetTimeVisible(C.config.fadeTime)
        frame:SetFading(C.config.fading)
        AF.SetFont(frame, unpack(C.config.font))
    end
end

---------------------------------------------------------------------
-- setup default
---------------------------------------------------------------------
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

    -- TextToSpeechButtonFrame
    TextToSpeechButtonFrame:Hide()

    -- ChatFrameMenuButton
    ChatFrameMenuButton:SetParent(DEFAULT_CHAT_FRAME)
    AF.ClearPoints(ChatFrameMenuButton)
    AF.SetPoint(ChatFrameMenuButton, "TOPRIGHT", 0, -20)
    AF.SetSize(ChatFrameMenuButton, 18, 18)
    ChatFrameMenuButton:SetNormalTexture(AF.GetIcon("ChatMenu", BFI.name))
    ChatFrameMenuButton:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
    ChatFrameMenuButton:SetPushedTexture(AF.GetIcon("ChatMenu", BFI.name))
    ChatFrameMenuButton:GetPushedTexture():SetVertexColor(1, 1, 1, 1)
    ChatFrameMenuButton:SetHighlightTexture(AF.GetIcon("ChatMenu", BFI.name))
    ChatFrameMenuButton:GetHighlightTexture():SetVertexColor(1, 1, 1, 1)

    -- ChatFrameChannelButton
    ChatFrameChannelButton:SetParent(DEFAULT_CHAT_FRAME)
    AF.ClearPoints(ChatFrameChannelButton)
    AF.SetPoint(ChatFrameChannelButton, "TOPRIGHT", 0, -40)
    AF.SetSize(ChatFrameChannelButton, 18, 18)
    ChatFrameChannelButton:SetNormalTexture(AF.GetIcon("ChatChannel", BFI.name))
    ChatFrameChannelButton:SetPushedTexture(AF.GetIcon("ChatChannel", BFI.name))
    ChatFrameChannelButton:SetHighlightTexture(AF.GetIcon("ChatChannel", BFI.name))
    ChatFrameChannelButton.Icon:Hide()
    ChatFrameChannelButton.Flash:Hide()

    local function UpdateVoiceState()
        local isActive = C_VoiceChat.GetActiveChannelID()
        ChatFrameChannelButton.hasActiveVoiceChannel = isActive
        local r, g, b = AF.GetColorRGB(isActive and "brightgreen" or "white")
        ChatFrameChannelButton:GetNormalTexture():SetVertexColor(r, g, b, 0.5)
        ChatFrameChannelButton:GetPushedTexture():SetVertexColor(r, g, b, 1)
        ChatFrameChannelButton:GetHighlightTexture():SetVertexColor(r, g, b, 1)
    end
    UpdateVoiceState()
    ChatFrameChannelButton:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_ACTIVATED", UpdateVoiceState)
    ChatFrameChannelButton:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_DEACTIVATED", UpdateVoiceState)

    -- ChatFrameToggleVoiceDeafenButton
    ChatFrameToggleVoiceDeafenButton:SetParent(DEFAULT_CHAT_FRAME)
    AF.ClearPoints(ChatFrameToggleVoiceDeafenButton)
    AF.SetPoint(ChatFrameToggleVoiceDeafenButton, "TOPRIGHT", 0, -60)
    AF.SetSize(ChatFrameToggleVoiceDeafenButton, 18, 18)
    ChatFrameToggleVoiceDeafenButton.Icon:Hide()

    local function UpdateVoiceDeafen() -- self, state
        local state = ChatFrameToggleVoiceDeafenButton:CallAccessor()
        ChatFrameToggleVoiceDeafenButton:UpdateTooltipForState(state)

        local r, g, b = AF.GetColorRGB(state and "firebrick" or "brightgreen")
        local texture = AF.GetIcon(state and "Deafened" or "Undeafened", BFI.name)
        ChatFrameToggleVoiceDeafenButton:SetNormalTexture(texture)
        ChatFrameToggleVoiceDeafenButton:GetNormalTexture():SetVertexColor(r, g, b, 0.5)
        ChatFrameToggleVoiceDeafenButton:SetPushedTexture(texture)
        ChatFrameToggleVoiceDeafenButton:GetPushedTexture():SetVertexColor(r, g, b, 1)
        ChatFrameToggleVoiceDeafenButton:SetHighlightTexture(texture)
        ChatFrameToggleVoiceDeafenButton:GetHighlightTexture():SetVertexColor(r, g, b, 1)
    end
    UpdateVoiceDeafen()
    ChatFrameToggleVoiceDeafenButton:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED", UpdateVoiceDeafen)
    ChatFrameToggleVoiceDeafenButton:RegisterStateUpdateEvent("VOICE_CHAT_LOGIN", UpdateVoiceDeafen)
    ChatFrameToggleVoiceDeafenButton:RegisterStateUpdateEvent("VOICE_CHAT_LOGOUT", UpdateVoiceDeafen)

    -- ChatFrameToggleVoiceMuteButton
    ChatFrameToggleVoiceMuteButton:SetParent(DEFAULT_CHAT_FRAME)
    AF.ClearPoints(ChatFrameToggleVoiceMuteButton)
    AF.SetPoint(ChatFrameToggleVoiceMuteButton, "TOPRIGHT", 0, -80)
    AF.SetSize(ChatFrameToggleVoiceMuteButton, 18, 18)
    ChatFrameToggleVoiceMuteButton.Icon:Hide()

    local function UpdateVoiceMute() -- self, state
        -- MUTE_SILENCE_STATE_NONE = 0
        -- MUTE_SILENCE_STATE_MUTE = 1
        -- MUTE_SILENCE_STATE_SILENCE = 2
        -- MUTE_SILENCE_STATE_PARENTAL_MUTE = 4
        -- MUTE_SILENCE_STATE_MUTE_AND_SILENCE = 3
        -- MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE = 5

        local state = ChatFrameToggleVoiceMuteButton:CallAccessor()
        ChatFrameToggleVoiceMuteButton:UpdateTooltipForState(state)

        local r, g, b, texture
        if state == _G.MUTE_SILENCE_STATE_NONE then
            r, g, b = AF.GetColorRGB("brightgreen")
            texture = AF.GetIcon("Unmuted", BFI.name)
        elseif state == _G.MUTE_SILENCE_STATE_MUTE or state == _G.MUTE_SILENCE_STATE_PARENTAL_MUTE or state == _G.MUTE_SILENCE_STATE_MUTE_AND_PARENTAL_MUTE then
            r, g, b = AF.GetColorRGB("firebrick")
            texture = AF.GetIcon("Muted", BFI.name)
        elseif state == _G.MUTE_SILENCE_STATE_SILENCE or state == _G.MUTE_SILENCE_STATE_MUTE_AND_SILENCE then
            r, g, b = AF.GetColorRGB("firebrick")
            texture = AF.GetIcon("Unmuted", BFI.name)
        end
        ChatFrameToggleVoiceMuteButton:SetNormalTexture(texture)
        ChatFrameToggleVoiceMuteButton:GetNormalTexture():SetVertexColor(r, g, b, 0.5)
        ChatFrameToggleVoiceMuteButton:SetPushedTexture(texture)
        ChatFrameToggleVoiceMuteButton:GetPushedTexture():SetVertexColor(r, g, b, 1)
        ChatFrameToggleVoiceMuteButton:SetHighlightTexture(texture)
        ChatFrameToggleVoiceMuteButton:GetHighlightTexture():SetVertexColor(r, g, b, 1)
    end
    UpdateVoiceMute()
    ChatFrameToggleVoiceMuteButton:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED", UpdateVoiceMute)
    ChatFrameToggleVoiceMuteButton:RegisterStateUpdateEvent("VOICE_CHAT_SILENCED_CHANGED", UpdateVoiceMute)
    ChatFrameToggleVoiceMuteButton:RegisterStateUpdateEvent("VOICE_CHAT_LOGIN", UpdateVoiceMute)
    ChatFrameToggleVoiceMuteButton:RegisterStateUpdateEvent("VOICE_CHAT_LOGOUT", UpdateVoiceMute)

    -- QuickJoinToastButton
    QuickJoinToastButton:Hide()
end

---------------------------------------------------------------------
-- hooks
---------------------------------------------------------------------
local function UpdateTabUnderline(frame, name)
    local tab = GetTab(frame)
    -- FIXME: WHY???
    if frame.chatType == "PET_BATTLE_COMBAT_LOG" then
        tab.Text:SetText(_G.PET_BATTLE_COMBAT_LOG)
    end
    -- tab.Text:SetText(frame.name)

    C_Timer.After(0, function()
        tab.underline:SetWidth(tab.Text:GetStringWidth() + 2)
    end)
end

local function UpdateAllTabUnderlines()
    C_Timer.After(1, function()
        for _, name in pairs(CHAT_FRAMES) do
            UpdateTabUnderline(_G[name])
        end
    end)
end

local function UpdateTabColor(tab, selected)
    tab.selected = selected

    if selected then
        tab.Text:SetTextColor(AF.GetColorRGB(BFI.name))
    else
        tab.Text:SetTextColor(AF.GetColorRGB("white"))
    end

    if tab.underline then
        tab.underline:SetShown(selected)
    end
end

-- local function UpdateChatFont(dropdown, ...)
--     -- TODO: necessary?
--     print(...)
-- end

local function UpdateScrollToBottomButton(frame, elapsed)
    frame.__elapsed = (frame.__elapsed or 0) + elapsed
    if frame.__elapsed >= 0.2 then
        frame.__elapsed = 0

        frame.BFIScrollToBottomButton:SetShown(not frame:AtBottom())
        frame.BFICopyButton:SetShown(frame:IsMouseOver())
        frame.BFIMinimizeButton:SetShown(not frame.isDocked and frame:IsMouseOver())

        if frame == DEFAULT_CHAT_FRAME then
            ChatFrameMenuButton:SetShown(frame:IsMouseOver() or ChatFrameMenuButton.menu)
            ChatFrameChannelButton:SetShown(frame:IsMouseOver())
            ChatFrameToggleVoiceDeafenButton:SetShown(frame:IsMouseOver() and ChatFrameChannelButton.hasActiveVoiceChannel)
            ChatFrameToggleVoiceMuteButton:SetShown(frame:IsMouseOver() and ChatFrameChannelButton.hasActiveVoiceChannel)
        end
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
            if not fs then
                b:SetText("")
                fs = b:GetFontString()
            end
            AF.SetFont(fs, unpack(C.config.font))
        end
    end

    -- progress bar
    local bar = _G.CombatLogQuickButtonFrame_CustomProgressBar
    bar:SetStatusBarTexture(AF.LSM_GetBarTexture("BFI"))
    bar:SetAlpha(0.75)
    AF.SetOnePixelInside(bar, _G.CombatLogQuickButtonFrame_Custom)
end
AF.RegisterAddonLoaded("Blizzard_CombatLog", UpdateCombatLog)

local ChatTypeInfo = _G.ChatTypeInfo
local function UpdateEditBox(editbox)
    local chatType = editbox:GetAttribute("chatType")
    if not chatType then return end

    local info = ChatTypeInfo[chatType]
    local target = editbox:GetAttribute("channelTarget")
    local id = target and GetChannelName(target)

    if chatType == "CHANNEL" and id then
        if id == 0 then
            editbox:SetBackdropBorderColor(AF.GetColorRGB("border"))
        else
            info = ChatTypeInfo[chatType .. id]
            editbox:SetBackdropBorderColor(AF.ExtractColor(info))
        end
    else
        editbox:SetBackdropBorderColor(AF.ExtractColor(info))
    end
end

local function UpdateEditBoxFont(editbox)
    AF.SetFont(editbox, unpack(C.config.font))
    AF.SetFont(editbox.header, unpack(C.config.font))
end

local function InitHooks()
    hooksecurefunc("FCF_SetWindowName", UpdateTabUnderline)
    hooksecurefunc("FCFTab_UpdateColors", UpdateTabColor)
    -- hooksecurefunc("FCF_SetChatWindowFontSize", UpdateChatFont)
    hooksecurefunc("FCF_DockFrame", UpdateFrameDocked)
    hooksecurefunc("FCF_UnDockFrame", UpdateFrameDocked)
    hooksecurefunc("Blizzard_CombatLog_Update_QuickButtons", UpdateCombatLog)
    hooksecurefunc("Blizzard_CombatLog_QuickButtonFrame_OnLoad", UpdateCombatLog)
    hooksecurefunc("ChatFrame_OnUpdate", UpdateScrollToBottomButton)
    hooksecurefunc("ChatEdit_UpdateHeader", UpdateEditBox)
    hooksecurefunc("ChatEdit_ActivateChat", UpdateEditBoxFont)
    hooksecurefunc("FCF_OpenTemporaryWindow", SetupChat) -- PET_BATTLE_COMBAT_LOG
    -- hooksecurefunc("FCFDock_SelectWindow", function()
    --     print("FCFDock_SelectWindow")
    -- end)
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateChat(_, module)
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
    UpdateCombatLog()
    C:RegisterEvent("UPDATE_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", SetupChat)
    C:RegisterEvent("FIRST_FRAME_RENDERED", UpdateAllTabUnderlines)

    AF.SetFont(chatCopyFrame.scroll.eb, unpack(C.config.font))

    AF.UpdateMoverSave(chatContainer, config.position)
    AF.LoadPosition(chatContainer, config.position)
    AF.SetSize(chatContainer, config.width, config.height)
    chatContainer:SetBackdropColor(AF.UnpackColor(config.bgColor))
    chatContainer:SetBackdropBorderColor(AF.UnpackColor(config.borderColor))

    -- TODO: button size
end
AF.RegisterCallback("BFI_UpdateModules", UpdateChat)