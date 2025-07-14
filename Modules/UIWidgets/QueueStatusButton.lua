---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class UIWidgets
local UI = BFI.UIWidgets
---@type AbstractFramework
local AF = _G.AbstractFramework

local queueStatusHolder
local QueueStatusButton = _G.QueueStatusButton
local QueueStatusButtonIcon = _G.QueueStatusButtonIcon

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local UpdateQueueStatusPoint, UpdateQueueStatusParent, UpdateQueueStatusScale

local function CreateQueueStatusHolder()
    queueStatusHolder = CreateFrame("Frame", "BFI_QueueStatusHolder", AF.UIParent)
    AF.CreateMover(queueStatusHolder, "BFI: " .. L["UI Widgets"], L["Queue Status"])

    queueStatusHolder:SetFrameLevel(10)
    QueueStatusButton:SetParent(queueStatusHolder)
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint("CENTER", queueStatusHolder)

    hooksecurefunc(QueueStatusButton, "SetParent", UpdateQueueStatusParent)
    hooksecurefunc(QueueStatusButton, "SetPoint", UpdateQueueStatusPoint)
    hooksecurefunc(QueueStatusButton, "SetScale", UpdateQueueStatusScale)
end

function UpdateQueueStatusParent(self, parent)
    if parent ~= queueStatusHolder then
        self:SetParent(queueStatusHolder)
    end
end

function UpdateQueueStatusPoint(self, _, anchorTo)
    if anchorTo ~= queueStatusHolder then
        self:ClearAllPoints()
        self:SetPoint("CENTER", queueStatusHolder)
    end
end

function UpdateQueueStatusScale(self, scale)
    if scale ~= queueStatusHolder.scale then
        self:SetScale(queueStatusHolder.scale)
        local w, h = self:GetSize()
        queueStatusHolder:SetSize(AF.ConvertPixels(w) * queueStatusHolder.scale, AF.ConvertPixels(h) * queueStatusHolder.scale)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateQueueStatus(_, module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "queue" then return end

    local config = UI.config.queueStatus

    if not queueStatusHolder then
        CreateQueueStatusHolder()
    end

    AF.UpdateMoverSave(queueStatusHolder, config.position)
    AF.LoadPosition(queueStatusHolder, config.position)

    queueStatusHolder.scale = config.scale
    QueueStatusButton:SetScale(0.001)
end
AF.RegisterCallback("BFI_UpdateModule", UpdateQueueStatus)