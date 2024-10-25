---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractWidgets
local AW = _G.AbstractWidgets
---@class UIWidgets
local UI = BFI.UIWidgets

local queueStatusHolder
local QueueStatusButton = _G.QueueStatusButton
local QueueStatusButtonIcon = _G.QueueStatusButtonIcon

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local UpdateQueueStatusPoint, UpdateQueueStatusParent, UpdateQueueStatusScale

local function CreateQueueStatusHolder()
    queueStatusHolder = CreateFrame("Frame", "BFI_QueueStatusHolder", AW.UIParent)
    AW.CreateMover(queueStatusHolder, L["UI Widgets"], L["Queue Status"])

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
        queueStatusHolder:SetSize(AW.ConvertPixels(w) * queueStatusHolder.scale, AW.ConvertPixels(h) * queueStatusHolder.scale)
    end
end

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
local init
local function UpdateQueueStatus(module, which)
    if module and module ~= "UIWidgets" then return end
    if which and which ~= "queue" then return end

    local config = UI.config.queueStatus

    if not queueStatusHolder then
        CreateQueueStatusHolder()
    end

    AW.UpdateMoverSave(queueStatusHolder, config.position)
    AW.LoadPosition(queueStatusHolder, config.position)

    queueStatusHolder.scale = config.scale
    QueueStatusButton:SetScale(0.001)
end
BFI.RegisterCallback("UpdateModules", "UI_QueueStatus", UpdateQueueStatus)