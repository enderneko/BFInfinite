---@class BFI
local BFI = select(2, ...)
local S = BFI.Style
---@type AbstractFramework
local AF = _G.AbstractFramework

local CommunitiesFrame = _G.CommunitiesFrame

-- local function CommunitiesList_ScrollBox_Update(...)

-- end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function StyleBlizzard()
    -- hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, "Update", CommunitiesList_ScrollBox_Update)

    -- hooksecurefunc(CommunitiesMemberListEntryMixin, "SetMember", function(self, memberInfo, isInvitation, professionId)
    --     if not self._fontSizeUpdated then
    --         self._fontSizeUpdated = true
    --         AF.UpdateFont(self.NameFrame.Level, nil, "+2")
    --         AF.UpdateFont(self.NameFrame.Name, nil, "+2")
    --         AF.UpdateFont(self.NameFrame.Zone, nil, "+2")
    --         AF.UpdateFont(self.NameFrame.Rank, nil, "+2")
    --         AF.UpdateFont(self.NameFrame.Note, nil, "+2")
    --         AF.UpdateFont(self.NameFrame.GuildInfo, nil, "+2")
    --     end
    -- end)

    CommunitiesFrame.Chat.MessageFrame:SetFont(_G.STANDARD_TEXT_FONT, 13 + BFI.vars.blizzardFontSizeDelta, "")
end
AF.RegisterCallback("BFI_StyleBlizzard", StyleBlizzard)