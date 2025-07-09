---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    for i = 1, 4 do
        local popup = _G["StaticPopup" .. i]
        S.RemoveBorder(popup)
        S.CreateBackdrop(popup)
        AF.SetPoint(popup.BFIBackdrop, "TOPLEFT", popup, 5, -2)
        AF.SetPoint(popup.BFIBackdrop, "BOTTOMRIGHT", popup, -5, 5)

        -- strip
        local strip = AF.CreateTexture(popup, nil, "BFI")
        AF.SetPoint(strip, "TOPLEFT", popup.BFIBackdrop, 1, -1)
        AF.SetPoint(strip, "TOPRIGHT", popup.BFIBackdrop, -1, -1)
        AF.SetHeight(strip, 2)

        -- button
        for j = 1, 4 do
            local button = popup["button" .. j]
            S.StyleButton(button)

            -- pulse animation
            button.Flash:Hide() -- old target
            AF.CreateGlow(button, "BFI", 3)
            button.glow:SetAlpha(0)

            local anim1, anim2 = button.PulseAnim:GetAnimations()
            anim1:SetTarget(button.glow)
            anim2:SetTarget(button.glow)
        end

        -- editbox
        S.StyleEditBox(popup.editBox, -2, -5, 2, 5)

        -- moneyInputFrame
        S.StyleEditBox(popup.moneyInputFrame.copper, -2, nil, -11)
        S.StyleEditBox(popup.moneyInputFrame.silver, -2, nil, -11)
        S.StyleEditBox(popup.moneyInputFrame.gold, -2)

        -- ItemFrame (BlackMarket, Purchase, Upgrade, Refund ...)
        -- StaticPopup.xml
        S.StyleItemButton(popup.ItemFrame)
        _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetAlpha(0) -- name background texture
    end
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)