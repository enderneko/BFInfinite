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
-- IconIntroTracker
---------------------------------------------------------------------
local function StyleIconIntroTracker()
    -- crop the new spells being added to the actionbars
    _G.IconIntroTracker:HookScript("OnEvent", function(self)
        local l, r, t, b = 0.1, 0.9, 0.1, 0.9
        for _, iconIntro in ipairs(self.iconList) do
            if not iconIntro._BFIStyled then
                iconIntro.trail1.icon:SetTexCoord(l, r, t, b)
                iconIntro.trail1.bg:SetTexCoord(l, r, t, b)

                iconIntro.trail2.icon:SetTexCoord(l, r, t, b)
                iconIntro.trail2.bg:SetTexCoord(l, r, t, b)

                iconIntro.trail3.icon:SetTexCoord(l, r, t, b)
                iconIntro.trail3.bg:SetTexCoord(l, r, t, b)

                iconIntro.icon.icon:SetTexCoord(l, r, t, b)
                iconIntro.icon.bg:SetTexCoord(l, r, t, b)

                iconIntro._BFIStyled = true
            end
        end
    end)
end

---------------------------------------------------------------------
-- SetCheckButtonIsRadio
---------------------------------------------------------------------
local function HookSetCheckButtonIsRadio()
    hooksecurefunc("SetCheckButtonIsRadio", function(button, isRadio)
        if not button._BFIStyled then return end
        S.ReStyleCheckButtonTexture(button)
    end)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    StyleQueueStatusFrame()
    StyleIconIntroTracker()
    HookSetCheckButtonIsRadio()
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)