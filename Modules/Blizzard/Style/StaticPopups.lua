---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- init -- Interface\AddOns\Blizzard_StaticPopup_Game\GameDialog.xml
---------------------------------------------------------------------
local function StyleBlizzard()
    for i = 1, 4 do
        local popup = _G["StaticPopup" .. i]
        S.RemoveBackground(popup)
        S.CreateBackdrop(popup)
        AF.SetPoint(popup.BFIBackdrop, "TOPLEFT", popup, 5, -2)
        AF.SetPoint(popup.BFIBackdrop, "BOTTOMRIGHT", popup, -5, 5)

        -- strip
        local strip = AF.CreateTexture(popup, nil, "BFI")
        AF.SetPoint(strip, "TOPLEFT", popup.BFIBackdrop, 1, -1)
        AF.SetPoint(strip, "TOPRIGHT", popup.BFIBackdrop, -1, -1)
        AF.SetHeight(strip, 2)

        local buttons = {popup.ExtraButton}
        for j = 1, 4 do
            tinsert(buttons, popup.ButtonContainer["Button" .. j])
        end

        -- button
        for _, b in next, buttons do
            S.StyleButton(b)

            -- pulse animation
            b.Flash:Hide() -- old target
            AF.CreateGlow(b, "BFI", 3)
            b.glow:SetAlpha(0)

            local anim1, anim2 = b.PulseAnim:GetAnimations()
            anim1:SetTarget(b.glow)
            anim2:SetTarget(b.glow)
        end

        -- editbox
        S.StyleEditBox(popup.EditBox, -2, -5, 2, 5)

        -- dropdown
        S.StyleDropdownButton(popup.Dropdown)

        -- moneyInputFrame
        S.StyleEditBox(popup.MoneyInputFrame.copper, -2, nil, -11)
        S.StyleEditBox(popup.MoneyInputFrame.silver, -2, nil, -11)
        S.StyleEditBox(popup.MoneyInputFrame.gold, -2)

        -- ItemFrame (BlackMarket, Purchase, Upgrade, Refund ...)
        S.StyleItemButton(popup.ItemFrame.Item)
        popup.ItemFrame.NameFrame:SetAlpha(0) -- name background texture
    end
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)