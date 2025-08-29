---@class BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local WeeklyRewardsFrame
local StaticPopup_FindVisible = StaticPopup_FindVisible

local function SelectReward()
    local frame = WeeklyRewardsFrame.confirmSelectionFrame
    if not frame then return end

    _G.WeeklyRewardsFrameNameFrame:Hide()
    S.StyleIcon(frame.ItemFrame.Icon, true)
    S.StyleIconBorder(frame.ItemFrame.IconBorder, frame.ItemFrame.Icon.BFIBackdrop)

    local alsoItemsFrame = frame.AlsoItemsFrame
    if alsoItemsFrame and alsoItemsFrame.pool then
        for item in alsoItemsFrame.pool:EnumerateActive() do
            S.StyleIcon(item.Icon, true)
            S.StyleIconBorder(item.IconBorder, item.Icon.BFIBackdrop)
        end
    end

    -- fix confirmSelectionFrame not visible after hiding issue
    if not frame:IsShown() then
        frame:Show()

        -- StaticPopup1?
        local dialog = StaticPopup_FindVisible("CONFIRM_SELECT_WEEKLY_REWARD", WeeklyRewardsFrame:GetSelectedActivityInfo().claimID)
        dialog:SetupElementAnchoring()
        dialog:Resize()
    end
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    if not _G.WeeklyRewardsFrame then return end
    WeeklyRewardsFrame = _G.WeeklyRewardsFrame

    hooksecurefunc(WeeklyRewardsFrame, "SelectReward", SelectReward)
end
-- AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)
AF.RegisterAddonLoaded("Blizzard_WeeklyRewards", StyleBlizzard)