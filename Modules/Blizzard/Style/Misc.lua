---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- QueueStatusFrame
---------------------------------------------------------------------
local function StyleQueueStatusFrame()
    local button = _G.QueueStatusButton
    local frame = _G.QueueStatusFrame

    S.RemoveNineSliceAndBackground(frame)
    S.CreateBackdrop(frame)
    AF.ClearPoints(frame.BFIBackdrop)
    AF.SetPoint(frame.BFIBackdrop, "TOPLEFT", frame, 0, -2)
    AF.SetPoint(frame.BFIBackdrop, "BOTTOMRIGHT", frame, 0, -2)

    frame:HookScript("OnShow", function()
        local p, rp, yMult = AF.GetAdaptiveAnchor_Vertical(frame)
        local hp = AF.GetAdaptiveAnchor_Horizontal(frame)

        AF.ClearPoints(frame)
        if yMult == -1 then
            AF.SetPoint(frame, p .. hp, button, rp .. hp, 0, -2)
        else
            AF.SetPoint(frame, p .. hp, button, rp .. hp, 0, 4)
        end
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    StyleQueueStatusFrame()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)