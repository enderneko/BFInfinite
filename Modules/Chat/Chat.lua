---@class BFI
local BFI = select(2, ...)
---@class Chat
local C = BFI.Chat
---@class AbstractWidgets
local AW = _G.AbstractWidgets
local U = BFI.utils

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

local function SetupDefaultChatFrame()
    local name = DEFAULT_CHAT_FRAME:GetName()
    DEFAULT_CHAT_FRAME:SetClampRectInsets(0, 0, 0, 0)

    -- parent
    DEFAULT_CHAT_FRAME:SetParent(chatContainer)
    hooksecurefunc(DEFAULT_CHAT_FRAME, "SetParent", function(self, parent)
        if parent ~= chatContainer then
            DEFAULT_CHAT_FRAME:SetParent(chatContainer)
        end
    end)

    -- point
    local function Repoint()
        AW.ClearPoints(DEFAULT_CHAT_FRAME)
        AW.SetPoint(DEFAULT_CHAT_FRAME, "TOPLEFT", chatContainer, 3, -27)
        AW.SetPoint(DEFAULT_CHAT_FRAME, "BOTTOMRIGHT", chatContainer, -3, 3)
    end
    Repoint()
    hooksecurefunc(DEFAULT_CHAT_FRAME, "SetPoint", function(self, _, relativeTo)
        if relativeTo ~= chatContainer then
            Repoint()
        end
    end)

    -- texture
    for _, tex in pairs(CHAT_FRAME_TEXTURES) do
        local f = _G[name .. tex]
        U.Hide(f)
    end
    U.Hide(DEFAULT_CHAT_FRAME.ScrollBar)

    -- editmode
    U.DisableEditMode(DEFAULT_CHAT_FRAME)
    -- hooksecurefunc(EditModeManagerFrame, "UpdateLayoutInfo", function()
    --     AW.ClearPoints(DEFAULT_CHAT_FRAME)
    --     AW.SetPoint(DEFAULT_CHAT_FRAME, "TOPLEFT", chatContainer, 1, -27)
    --     AW.SetPoint(DEFAULT_CHAT_FRAME, "BOTTOMRIGHT", chatContainer, -1, 1)
    -- end)
end

local function SetupChat()
    for _, name in pairs(CHAT_FRAMES) do
        local frame = _G[name]

        -- hook
        -- local id = frame:GetID()
        -- if id ~= 2 and id ~= 3 then
        -- end

        -- DEFAULT_CHAT_FRAME:
    end
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
    if not config.enabled then return end

    if not chatContainer then
        CreateChatContainer()
        SetupDefaultChatFrame()
    end

    SetupChat()

    AW.UpdateMoverSave(chatContainer, config.position)
    AW.LoadPosition(chatContainer, config.position)
    AW.SetSize(chatContainer, config.width, config.height)
end
BFI.RegisterCallback("UpdateModules", "Chat", UpdateChat)