---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local S = BFI.modules.Style
local L = BFI.L
---@class Chat
local C = BFI.modules.Chat
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
local GeneralDockManager = _G.GeneralDockManager

local ChatFrameUtil = ChatFrameUtil
local ChatTypeInfo = _G.ChatTypeInfo

local TAB_NORMAL_ALPHA = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA or 0.6
local TAB_SELECTED_ALPHA = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA or 1.0

local GetCVar = GetCVar

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
    AF.CreateMover(chatContainer, "BFI: " .. _G.OTHER, L["Chat Frame"]) -- _G.HUD_EDIT_MODE_CHAT_FRAME_LABEL
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
    tinsert(_G.UISpecialFrames, "BFIChatCopyFrame")

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
local function CreateBackdrop(frame)
    if frame.BFIBackdrop then return end

    frame.BFIBackdrop = AF.CreateBorderedFrame(frame)
    frame.BFIBackdrop:Hide()
    AF.SetFrameLevel(frame.BFIBackdrop, -1)

    AF.SetPoint(frame.BFIBackdrop, "TOPLEFT", frame, -3, 27)
    AF.SetPoint(frame.BFIBackdrop, "BOTTOMRIGHT", frame, 3, -3)
end

local function CreateScrollToBottomButton(frame)
    if frame.BFIScrollToBottomButton then return end

    local b = AF.CreateIconButton(frame, AF.GetIcon("ArrowDoubleDown"), 18, 18, 0, AF.GetColorTable("white", 0.5))
    frame.BFIScrollToBottomButton = b
    b:Hide()
    b:SetPoint("BOTTOMRIGHT")
    b:SetScript("OnClick", function()
        frame:ScrollToBottom()
    end)
end

local function CreateCopyButton(frame)
    if frame.BFICopyButton then return end

    local b = AF.CreateIconButton(frame, AF.GetIcon("Copy", BFI.name), 18, 18, 1, AF.GetColorTable("white", 0.5))
    frame.BFICopyButton = b
    b:Hide()
    b:SetPoint("TOPRIGHT")
    b:SetScript("OnClick", ShowChatCopyFrame)
end

local function UpdateMinimizedColor(minFrame)
    local r, g, b
    if minFrame.selectedColorTable then
        r, g ,b = AF.ExtractColor(minFrame.selectedColorTable)
    else
        r, g, b = AF.GetColorRGB(BFI.name)
    end
    minFrame:GetFontString():SetTextColor(r, g, b)
    minFrame.glow:SetVertexColor(r, g, b)
end

local function StyleMinimizeFrame(frame)
    local minFrame = frame.minFrame

    if minFrame._BFIStyled then
        UpdateMinimizedColor(minFrame)
        return
    end
    minFrame._BFIStyled = true

    AF.SetSize(minFrame, 180, 24)
    S.RemoveRegions(minFrame)
    S.CreateBackdrop(minFrame)
    AF.SetBackdropHighlight(minFrame, minFrame.BFIBackdrop, "BFI")
    minFrame:SetPushedTextOffset(0, -AF.GetOnePixelForRegion(minFrame))

    -- maximize button
    _G[minFrame:GetName() .. "MaximizeButton"]:Hide()
    local button = AF.CreateIconButton(minFrame, AF.GetIcon("WindowRestore"), 20, 20, 2, AF.GetColorTable("white", 0.5))
    AF.SetPoint(button, "RIGHT", -2, 0)
    button:SetOnClick(function()
        FCF_MaximizeFrame(frame)
    end)
    button:HookOnEnter(function()
        minFrame:GetScript("OnEnter")(minFrame)
    end)
    button:HookOnLeave(function()
        minFrame:GetScript("OnLeave")(minFrame)
    end)

    -- text
    local text = minFrame:GetFontString()
    AF.SetFont(text, C.config.tabFont)
    AF.ClearPoints(text)
    AF.SetPoint(text, "LEFT", 5, 0)
    AF.SetPoint(text, "RIGHT", button, "LEFT", -5, 0)
    -- text:SetTextColor(AF.GetColorRGB(BFI.name))

    -- new message glow
    local glow = AF.CreateTexture(minFrame, AF.GetTexture("Gradient_Linear_Bottom"), nil, "BORDER", -1)
    glow:Hide()
    glow:SetAllPoints()

    minFrame.glow = glow
    _G[minFrame:GetName() .. "Glow"] = glow

    UpdateMinimizedColor(minFrame)
end

-- NOTE: this function is called before FCF_MinimizeFrame(StyleMinimizeFrame)
-- hooksecurefunc("FCFMin_UpdateColors", function(minFrame)
--     local r, g, b
--     if minFrame.selectedColorTable then
--         r, g ,b = AF.ExtractColor(minFrame.selectedColorTable)
--     else
--         r, g, b = AF.GetColorRGB(BFI.name)
--     end
--     print(minFrame:GetName(), "FCFMin_UpdateColors", r, g, b)
--     minFrame:GetFontString():SetTextColor(r, g, b)
--     minFrame.glow:SetVertexColor(r, g, b)
-- end)

local function CreateMinimizeButton(frame)
    if frame.BFIMinimizeButton then return end

    local b = AF.CreateIconButton(frame, AF.GetIcon("WindowMinimize"), 18, 18, 0, AF.GetColorTable("white", 0.5))
    frame.BFIMinimizeButton = b
    b:Hide()
    AF.SetPoint(b, "TOPRIGHT", -20, 0)
    b:SetOnClick(function()
        -- FCF_DockFrame(frame)
        -- frame.Background:Hide()
        FCF_MinimizeFrame(frame, frame.buttonSide)
    end)
end

local function UpdateButtonsVisibility(frame, elapsed)
    frame._elapsed = (frame._elapsed or 0) + elapsed
    if frame._elapsed >= 0.15 then
        frame._elapsed = 0

        frame.BFIScrollToBottomButton:SetShown(not frame:AtBottom())

        local isMouseOver = frame:IsMouseOver()
        if frame._isMouseOver ~= isMouseOver then
            frame._isMouseOver = isMouseOver

            -- print(frame:GetName(), "isMouseOver", isMouseOver)
            frame.BFICopyButton:SetShown(isMouseOver)
            frame.BFIMinimizeButton:SetShown(isMouseOver and not frame.isDocked)

            if frame == DEFAULT_CHAT_FRAME then
                ChatFrameMenuButton:SetShown(isMouseOver or ChatFrameMenuButton.menu)
                ChatFrameChannelButton:SetShown(isMouseOver)
                ChatFrameToggleVoiceDeafenButton:SetShown(isMouseOver and ChatFrameChannelButton.hasActiveVoiceChannel)
                ChatFrameToggleVoiceMuteButton:SetShown(isMouseOver and ChatFrameChannelButton.hasActiveVoiceChannel)
            end
        end
    end
end

local function GetTab(frame)
    if not frame.tab then
        local tab = _G[format("ChatFrame%sTab", frame:GetID())]
        frame.tab = tab
        tab.owner = frame
        tab:HookScript("OnClick", HideChatCopyFrame)

        -- underline
        tab.underline = AF.CreateSeparator(tab, nil, 1, BFI.name)
        tab.underline:SetIgnoreParentAlpha(true)
        -- AF.SetPoint(tab.underline, "TOP", tab.Text, "BOTTOM", 0, -1)
        AF.SetPoint(tab.underline, "BOTTOMLEFT", 2, 2)
        AF.SetPoint(tab.underline, "BOTTOMRIGHT", -2, 2)
        tab.underline:Hide()

        -- glow
        local glow = AF.CreateTexture(tab, AF.GetTexture("Gradient_Linear_Bottom"), nil, "BORDER", -1)
        glow:Hide()
        glow:SetPoint("BOTTOMLEFT", tab.underline)
        glow:SetPoint("BOTTOMRIGHT", tab.underline)
        glow:SetPoint("TOP")
        tab.glow = glow
        _G[tab:GetName() .. "Glow"] = glow
    end
    return frame.tab
end

local function UpdateEditBoxPosition(editBox, isDocked)
    local position = isDocked and C.config.editBoxDockedPosition or C.config.editBoxUndockedPosition

    AF.ClearPoints(editBox)

    local target = isDocked and chatContainer or editBox.chatFrame.BFIBackdrop

    if position == "TOP" then
        AF.SetPoint(editBox, "BOTTOMLEFT", target, "TOPLEFT", 0, 5)
        AF.SetPoint(editBox, "BOTTOMRIGHT", target, "TOPRIGHT", 0, 5)
    else -- "BOTTOM"
        AF.SetPoint(editBox, "TOPLEFT", target, "BOTTOMLEFT", 0, -5)
        AF.SetPoint(editBox, "TOPRIGHT", target, "BOTTOMRIGHT", 0, -5)
    end
end

local function UpdateTabText()
    local isIM = GetCVar("chatStyle") == "im"

    for _, name in pairs(CHAT_FRAMES) do
        local chatFrame = _G[name]
        local tab = GetTab(chatFrame)

        if isIM then
            local active = chatFrame == ChatFrameUtil.GetLastActiveWindow().chatFrame
            if active and chatFrame:IsShown() then
                tab.Text:SetTextColor(AF.GetColorRGB(BFI.name, TAB_SELECTED_ALPHA))
                tab.underline:SetColorTexture(AF.GetColorRGB(BFI.name, TAB_SELECTED_ALPHA))
                tab.underline:Show()
            elseif chatFrame.isDocked and tab.selected then
                tab.Text:SetTextColor(AF.GetColorRGB("white", TAB_NORMAL_ALPHA))
                tab.underline:SetColorTexture(AF.GetColorRGB("white", TAB_NORMAL_ALPHA))
                tab.underline:Show()
            else
                tab.Text:SetTextColor(AF.GetColorRGB("white", TAB_NORMAL_ALPHA))
                tab.underline:Hide()
            end
        else
            if tab.selected and chatFrame.isDocked then
                tab.Text:SetTextColor(AF.GetColorRGB(BFI.name, TAB_SELECTED_ALPHA))
                tab.underline:SetColorTexture(AF.GetColorRGB(BFI.name, TAB_SELECTED_ALPHA))
                tab.underline:Show()
            elseif not chatFrame.isDocked then
                tab.Text:SetTextColor(AF.GetColorRGB(BFI.name, TAB_SELECTED_ALPHA))
                tab.underline:Hide()
            else
                tab.Text:SetTextColor(AF.GetColorRGB("white", TAB_NORMAL_ALPHA))
                tab.underline:Hide()
            end
        end
    end
end

local function UpdateFrameDocked(frame, isDocked)
    CreateBackdrop(frame) -- UpdateFrameDocked may be called before SetupChatFrames

    local tab = GetTab(frame)
    tab.Text:ClearAllPoints()

    if isDocked then
        frame.BFIBackdrop:Hide()

        tab.Text:SetPoint("CENTER")
        tab.Text:SetJustifyH("CENTER")
    else
        frame.BFIBackdrop:Show()

        tab:SetParent(frame)
        tab.Text:SetJustifyH("LEFT")
        if tab.conversationIcon and tab.conversationIcon:IsShown() then
            tab.Text:SetPoint("LEFT", 20, 0)
        else
            tab.Text:SetPoint("LEFT", 7, 0)
        end

        if frame:GetID() == 2 then
            AF.ClearPoints(frame.Background)
            AF.SetPoint(frame.Background, "TOPLEFT", frame, -3, 30)
            AF.SetPoint(frame.Background, "BOTTOMRIGHT", frame, 3, -3)
        else
            AF.SetOutside(frame.Background, frame, 3)
        end
    end

    if isDocked and GetCVar("chatStyle") == "im" then
        ChatFrameUtil.SetLastActiveWindow(frame.editBox)
    end
    AF.DelayedInvoke(0, UpdateTabText)
    UpdateEditBoxPosition(frame.editBox, isDocked)
end

local function UpdateEditBox(editBox)
    local chatType = editBox:GetAttribute("chatType")
    if not chatType then return end

    local info = ChatTypeInfo[chatType]
    local target = editBox:GetAttribute("channelTarget")
    local id = target and GetChannelName(target)

    if chatType == "CHANNEL" and id then
        if id == 0 then
            editBox.BFIBackdrop:SetBackdropBorderColor(AF.GetColorRGB("border"))
        else
            info = ChatTypeInfo[chatType .. id]
            editBox.BFIBackdrop:SetBackdropBorderColor(AF.ExtractColor(info))
        end
    else
        editBox.BFIBackdrop:SetBackdropBorderColor(AF.ExtractColor(info))
    end

	editBox:SetTextInsets(
        5 + editBox.header:GetWidth() + (editBox.headerSuffix:IsShown() and editBox.headerSuffix:GetWidth() or 0) + editBox:UpdateLanguageHeader(),
        CHAT_SHOW_IME and 23 or 5,
        0, 0)
end

local function SetupChatFrames()
    for _, name in pairs(CHAT_FRAMES) do
        local frame = _G[name]
        -- local id = frame:GetID() -- 2:combatlog, 3:voice

        -- scorll to bottom
        F.Hide(frame.ScrollToBottomButton)
            CreateScrollToBottomButton(frame)

        -- copy
        CreateCopyButton(frame)

        -- minimize
        CreateMinimizeButton(frame)

        -- texture
        for _, tex in pairs(CHAT_FRAME_TEXTURES) do
            local f = _G[name .. tex]
            f:Hide()
        end
        F.Hide(frame.ScrollBar)

        -- tab
        local tab = GetTab(frame)
        AF.SetFont(tab.Text, C.config.tabFont)
        -- tab.Text:SetWidth(0)
        -- tab.Text:SetHeight(0)
        tab.Text:SetJustifyV("MIDDLE")
        tab.Text:SetIgnoreParentAlpha(true)
        tab:SetPushedTextOffset(0, -1)
        AF.SetHeight(tab, 22)

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
        if frame.editBox then
            local editBox = frame.editBox
            if not editBox._BFIStyled then
                S.StyleEditBox(editBox)
                editBox:SetAltArrowKeyMode(false)
                hooksecurefunc(editBox, "UpdateHeader", UpdateEditBox)
                -- hooksecurefunc(editBox, "Deactivate", editBox.Hide)
                editBox.header:SetPoint("LEFT", 5, 0)
                -- language
                local lang = _G[editBox:GetName() .. "Language"]
                lang:ClearAllPoints()
                lang:SetPoint("RIGHT")
                lang:GetNormalTexture():SetAlpha(0)
                lang:SetSize(22, 22)
                lang:SetPushedTextOffset(0, -AF.GetOnePixelForRegion(lang))
            end
            editBox.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("background"))
            editBox:SetHeight(C.config.font[2] + 10)
        end

        -- ButtonFrame
        if frame.buttonFrame then
            frame.buttonFrame:SetParent(AF.hiddenParent)
            frame.buttonFrame:Hide()
        end

        -- backdrop
        frame.Background:Hide()
        CreateBackdrop(frame)

        -- misc
        frame:SetMaxLines(C.config.maxLines)
        frame:SetTimeVisible(C.config.fadeTime)
        frame:SetFading(C.config.fading)
        AF.SetFont(frame, C.config.font)

        -- OnUpdate: update buttons visibility
        frame:SetScript("OnUpdate", UpdateButtonsVisibility) -- ChatFrameMixin:OnUpdate
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
    F.DisableEditMode(DEFAULT_CHAT_FRAME)
    F.Hide(DEFAULT_CHAT_FRAME.EditModeResizeButton)
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

    -- GeneralDockManager
    AF.SetHeight(GeneralDockManager, 22)
    AF.SetHeight(GeneralDockManager.scrollFrame, 22) -- GeneralDockManagerScrollFrame
    AF.SetHeight(GeneralDockManager.scrollFrame.child, 22) -- GeneralDockManagerScrollFrameChild
end

---------------------------------------------------------------------
-- hooks
---------------------------------------------------------------------
local function FixTabName(frame, name)
    local tab = GetTab(frame)
    -- FIXME: WHY???
    if frame.chatType == "PET_BATTLE_COMBAT_LOG" then
        tab.Text:SetText(_G.PET_BATTLE_COMBAT_LOG)
    end
    -- tab.Text:SetText(frame.name)
end

-- local function UpdateChatFont(dropdown, ...)
--     -- REVIEW: necessary?
--     print(...)
-- end

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
            AF.SetFont(fs, C.config.font)
        end
    end

    -- progress bar
    local bar = _G.CombatLogQuickButtonFrame_CustomProgressBar
    bar:SetStatusBarTexture(AF.LSM_GetBarTexture("BFI"))
    bar:SetAlpha(0.75)
    AF.SetOnePixelInside(bar, _G.CombatLogQuickButtonFrame_Custom)
end
-- AF.RegisterAddonLoaded("Blizzard_CombatLog", UpdateCombatLog)

local function UpdateEditBoxFont(editBox)
    AF.SetFont(editBox, C.config.font)
    AF.SetFont(editBox.header, C.config.font)
    AF.SetFont(_G[editBox:GetName() .. "Language"]:GetFontString(), C.config.font)
end

local function FixFirstTabPosition(dock)
    if dock ~= GeneralDockManager then return end
    for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
        if not chatFrame.isStaticDocked then
            chatFrame.tab:SetPoint("LEFT")
            break
        end
    end
end

local function UpdateTabColor(tab, selected)
    tab.selected = selected

    if tab.underline then
        AF.DelayedInvoke(0, UpdateTabText)
    end
end

local function UpdateTabColor_IM()
    AF.DelayedInvoke(0, UpdateTabText)
end

local function InitHooks()
    hooksecurefunc("FCF_SetWindowName", FixTabName)
    hooksecurefunc("FCF_DockFrame", UpdateFrameDocked)
    hooksecurefunc("FCF_UnDockFrame", UpdateFrameDocked)
    hooksecurefunc("FCF_OpenTemporaryWindow", SetupChatFrames) -- PET_BATTLE_COMBAT_LOG
    hooksecurefunc("FCFDock_UpdateTabs", FixFirstTabPosition)
    hooksecurefunc("FCF_MinimizeFrame", StyleMinimizeFrame)
    -- hooksecurefunc("FCF_SetChatWindowFontSize", UpdateChatFont)
    -- hooksecurefunc("FCFDock_SelectWindow", function()
    --     print("FCFDock_SelectWindow")
    -- end)
    hooksecurefunc("Blizzard_CombatLog_Update_QuickButtons", UpdateCombatLog)
    hooksecurefunc("Blizzard_CombatLog_QuickButtonFrame_OnLoad", UpdateCombatLog)

    hooksecurefunc(ChatFrameUtil, "ActivateChat", UpdateEditBoxFont)

    hooksecurefunc("FCFTab_UpdateColors", UpdateTabColor) -- GetCVar("chatStyle") == "classic/im"
    hooksecurefunc(ChatFrameUtil, "SetLastActiveWindow", UpdateTabColor_IM) -- GetCVar("chatStyle") == "im"
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local function UpdateChat(_, module)
    if module and module ~= "chat" then return end

    local config = C.config
    if not config.enabled then
        C:UnregisterAllEvents()
        if chatContainer then
            chatContainer.enabled = false
            chatContainer:Hide()
        end
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

    chatContainer.enabled = true
    chatContainer:Show()

    SetupChatFrames()
    UpdateCombatLog()

    C:RegisterEvent("UPDATE_CHAT_WINDOWS", SetupChatFrames)
    C:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", SetupChatFrames)
    C:RegisterEvent("FIRST_FRAME_RENDERED", UpdateTabText)

    AF.SetFont(chatCopyFrame.scroll.eb, C.config.font)

    AF.UpdateMoverSave(chatContainer, config.position)
    AF.LoadPosition(chatContainer, config.position)
    AF.SetSize(chatContainer, config.width, config.height)
    chatContainer:SetBackdropColor(AF.UnpackColor(config.bgColor))
    chatContainer:SetBackdropBorderColor(AF.UnpackColor(config.borderColor))

    -- TODO: button size
end
AF.RegisterCallback("BFI_UpdateModule", UpdateChat)