---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
-- TODO: check inheritances
local fonts = {
    -- Fonts.xml
    "SystemFont_Outline_Small",
    "SystemFont_Outline",
    "SystemFont_InverseShadow_Small",
    "SystemFont_Huge1",
    "SystemFont_Huge1_Outline",
    "SystemFont_OutlineThick_Huge2",
    "SystemFont_OutlineThick_Huge4",
    "SystemFont_OutlineThick_WTF",
    "NumberFont_GameNormal",
    "NumberFont_OutlineThick_Mono_Small",
    "Number12Font_o1",
    "NumberFont_Small",
    "Number11Font",
    "Number12Font",
    "Number12FontOutline",
    "Number13Font",
    "PriceFont",
    "Number15Font",
    "Number16Font",
    "Number18Font",
    "NumberFont_Outline_Huge",
    "Fancy22Font",
    "QuestFont_Outline_Huge",
    "QuestFont_Super_Huge",
    "QuestFont_Super_Huge_Outline",
    "SplashHeaderFont",
    "Game11Font_Shadow",
    "Game11Font",
    "Game12Font",
    "Game13Font",
    "Game13FontShadow",
    "Game15Font",
    "Game15Font_Shadow",
    "Game18Font",
    "Game20Font",
    "Game24Font",
    "Game27Font",
    "Game32Font",
    "Game36Font",
    "Game40Font",
    "Game42Font",
    "Game46Font",
    "Game48Font",
    "Game48FontShadow",
    "Game60Font",
    "Game120Font",
    "Game11Font_o1",
    "Game12Font_o1",
    "Game13Font_o1",
    "Game15Font_o1",
    "QuestFont_Enormous",
    "DestinyFontMed",
    "DestinyFontLarge",
    "CoreAbilityFont",
    "OrderHallTalentRowFont",
    "DestinyFontHuge",
    "QuestFont_Shadow_Small",
    "MailFont_Large",
    "SpellFont_Small",
    "InvoiceFont_Med",
    "InvoiceFont_Small",
    "AchievementFont_Small",
    "ReputationDetailFont",
    "GameFont_Gigantic",
    "ChatBubbleFont",
    "Fancy12Font",
    "Fancy14Font",
    "Fancy16Font",
    "Fancy18Font",
    "Fancy20Font",
    "Fancy24Font",
    "Fancy27Font",
    "Fancy30Font",
    "Fancy32Font",
    "Fancy36Font",
    "Fancy40Font",
    "Fancy48Font",
    "SystemFont_NamePlateFixed",
    "SystemFont_LargeNamePlateFixed",
    "SystemFont_NamePlate",
    "SystemFont_LargeNamePlate",
    "SystemFont_NamePlateCastBar",
    "Game19Font",
    "Game21Font",
    "Game22Font",

    -- Fonts.xml (Shared)
    "SystemFont_Shadow_Outline_Small",
    "SystemFont_Outline_Med2",
    "SystemFont_Shadow_Outline_Large",
    "QuestFont_Huge",
    "SystemFont_Med2",
    "QuestFont_Shadow_Huge",
    "ChatFontNormal",

    -- FontStyles.xml
    "GameFontGreenLarge",
    "GameFontNormalHugeBlack",
    "BossEmoteNormalHuge",
    "NumberFontNormalRightGreen",
    "NumberFontNormalSmall",
    "NumberFontNormalSmallGray",
    "NumberFontNormalGray",
    "NumberFontNormalLargeYellow",
    "NumberFontNormalHuge",
    "NumberFontSmallYellowLeft",
    "NumberFontSmallWhiteLeft",
    "NumberFontSmallBattleNetBlueLeft",
    "Number11FontWhite",
    "Number13FontWhite",
    "Number13FontYellow",
    "Number13FontGray",
    "Number13FontRed",
    "PriceFontWhite",
    "PriceFontYellow",
    "PriceFontGray",
    "PriceFontRed",
    "PriceFontGreen",
    "Number14FontGreen",
    "Number14FontRed",
    "Number15FontWhite",
    "Number18FontWhite",
    "QuestTitleFontBlackShadow",
    "QuestFontLeft",
    "QuestFontNormalSmall",
    "ItemTextFontNormal",
    "MailTextFontNormal",
    "SubSpellFont",
    "NewSubSpellFont",
    "DialogButtonNormalText",
    "DialogButtonHighlightText",
    "ZoneTextFont",
    "SubZoneTextFont",
    "PVPInfoTextFont",
    "ErrorFont",
    "TextStatusBarText",
    "GameNormalNumberFont",
    "WhiteNormalNumberFont",
    "TextStatusBarTextLarge",
    "WorldMapTextFont",
    "InvoiceTextFontNormal",
    "InvoiceTextFontSmall",
    "CombatTextFont",
    "CombatTextFontOutline",
    "MissionCombatTextFontOutline",
    "AchievementPointsFont",
    "AchievementPointsFontSmall",
    "AchievementDescriptionFont",
    "AchievementCriteriaFont",
    "AchievementDateFont",
    "VehicleMenuBarStatusBarText",
    "FocusFontSmall",
    "ArtifactAppearanceSetNormalFont",
    "ArtifactAppearanceSetHighlightFont",
    "CommentatorTeamScoreFont",
    "CommentatorDampeningFont",
    "CommentatorTeamNameFont",
    "CommentatorCCFont",
    "CommentatorFontSmall",
    "CommentatorFontMedium",
    "CommentatorVictoryFanfare",
    "CommentatorVictoryFanfareTeam",
    "OptionsFontSmall",
    "OptionsFontSmallLeft",
    "OptionsFontHighlightSmall",
    "OptionsFontHighlight",
    "OptionsFontLarge",
    "OptionsFontLeft",

    -- SharedFonts.xml
    "SystemFont_Tiny2",
    "SystemFont_Tiny",
    "SystemFont_Shadow_Small",
    "Game10Font_o1",
    "SystemFont_Small",
    "SystemFont_Small2",
    "SystemFont_Shadow_Small2",
    "SystemFont_Shadow_Small_Outline",
    "SystemFont_Shadow_Small2_Outline",
    "SystemFont_Shadow_Med1_Outline",
    "SystemFont_Shadow_Med1",
    "SystemFont_Med3",
    "SystemFont_Shadow_Med3",
    "SystemFont_Shadow_Med3_Outline",
    "QuestFont_Large",
    "QuestFont_30",
    "QuestFont_39",
    "SystemFont_Large",
    "SystemFont_Shadow_Large_Outline",
    "SystemFont_Shadow_Med2",
    "SystemFont_Shadow_Med2_Outline",
    "SystemFont_Shadow_Large",
    "SystemFont_Large2",
    "SystemFont_Shadow_Large2",
    "SystemFont_Shadow_Large2_Outline",
    "Game17Font_Shadow",
    "SystemFont_Shadow_Huge1",
    "SystemFont_Shadow_Huge1_Outline",
    "SystemFont_Huge2",
    "SystemFont_Shadow_Huge2",
    "SystemFont_Shadow_Huge2_Outline",
    "SystemFont_Shadow_Huge3",
    "SystemFont_Shadow_Outline_Huge3",
    "SystemFont_Huge4",
    "SystemFont_Shadow_Huge4",
    "SystemFont_Shadow_Huge4_Outline",
    "SystemFont_World",
    "SystemFont_World_ThickOutline",
    "SystemFont22_Outline",
    "SystemFont22_Shadow_Outline",
    "SystemFont16_Shadow_ThickOutline",
    "SystemFont18_Shadow_ThickOutline",
    "SystemFont22_Shadow_ThickOutline",
    "SystemFont_Med1",
    "SystemFont_WTF2",
    "SystemFont_Outline_WTF2",
    "GameTooltipHeader",
    "System_IME",
    "NumberFont_Shadow_Tiny",
    "NumberFont_Shadow_Small",
    "NumberFont_Shadow_Med",
    "NumberFont_Shadow_Large",
    "Tooltip_Med",
    "Tooltip_Small",
    "System15Font",
    "Game16Font",
    "Game30Font",
    "Game32Font_Shadow2",
    "Game36Font_Shadow2",
    "Game40Font_Shadow2",
    "Game46Font_Shadow2",
    "Game52Font_Shadow2",
    "Game58Font_Shadow2",
    "Game69Font_Shadow2",
    "Game72Font",
    "Game72Font_Shadow",
    "FriendsFont_Normal",
    "FriendsFont_11",
    "FriendsFont_Small",
    "FriendsFont_Large",
    "FriendsFont_UserText",
    "NumberFont_Normal_Med",
    "NumberFont_Outline_Med",
    "NumberFont_Outline_Large",

    -- FontStyles.xml (Shared)
    "QuestTitleFont",
    "QuestFont",
    "GameFontNormal",
    "GameFontNormalLeft",
    "GameFontNormalSmall",
    "GameFontNormalSmallLeft",
    "GameFontHighlight",
    "GameFontRed",
    "GameFontGreen",
    "GameFontHighlightLeft",
    "GameFontHighlightCenter",
    "GameFontHighlightRight",
    "CombatLogFont",
    "ObjectiveFont",
    "GameFontDisable",
    "GameFontDisableLeft",
    "GameFontHighlightSmall",
    "GameFontHighlightSmallRight",
    "GameFontHighlightExtraSmall",
    "GameFontHighlightSmallLeft",
    "GameFontHighlightSmallLeftTop",
    "GameFontHighlightExtraSmallLeft",
    "GameFontHighlightExtraSmallLeftTop",
    "GameFontHighlightSmallOutline",
    "GameFontDisableSmall",
    "GameFontDarkGraySmall",
    "GameFontGreenSmall",
    "GameFontRedSmall",
    "GameFontNormalSmallBattleNetBlueLeft",
    "GameFontDisableSmallLeft",
    "GameFontDisableSmall2",
    "GameFontNormalLeftBottom",
    "GameFontNormalLeftGreen",
    "GameFontNormalLeftYellow",
    "GameFontNormalLeftOrange",
    "GameFontNormalLeftLightGreen",
    "GameFontNormalLeftGrey",
    "GameFontNormalLeftLightGrey",
    "GameFontNormalLeftLightBlue",
    "GameFontNormalLeftRed",
    "GameFontNormalLarge",
    "GameFontNormalLarge2",
    "GameFontNormalLargeOutline",
    "GameFontNormalLargeLeft",
    "GameFontNormalLargeLeftTop",
    "GameFontRedLarge",
    "GameFontHighlightLarge",
    "GameFontDisableLarge",
    "GameFontHighlightLarge2",
    "QuestDifficulty_Impossible",
    "QuestDifficulty_VeryDifficult",
    "QuestDifficulty_Difficult",
    "QuestDifficulty_Standard",
    "QuestDifficulty_Trivial",
    "QuestDifficulty_Header",
    "LFGActivityHeader",
    "LFGActivityEntry",
    "LFGActivityEntryTrivial",
    "LFGActivityEntryDifficult",
    "CharacterCreateTooltipFont",
    "Number14FontWhite",
    "Number14FontGray",
    "NumberFontNormal",
    "NumberFontNormalRight",
    "NumberFontNormalRightRed",
    "NumberFontNormalRightYellow",
    "NumberFontNormalRightGray",
    "NumberFontNormalYellow",

    -- Blizzard_ObjectiveTrackerFonts.xml
    "ObjectiveTrackerFont12",
    "ObjectiveTrackerFont13",
    "ObjectiveTrackerFont14",
    "ObjectiveTrackerFont15",
    "ObjectiveTrackerFont16",
    "ObjectiveTrackerFont17",
    "ObjectiveTrackerFont18",
    "ObjectiveTrackerFont19",
    "ObjectiveTrackerFont20",
    "ObjectiveTrackerFont21",
    "ObjectiveTrackerFont22",
    "ObjectiveTrackerLineFont",
    "ObjectiveTrackerHeaderFont",

    "ChatBubbleFont",
}

local fontSizeOverrides = {
    GameFontNormalSmall = 12,
    SystemFont_Shadow_Small2 = 12,
    SystemFont_Shadow_Small2_Outline = 12,

    ObjectiveTrackerHeaderFont = 14,
    ObjectiveTrackerLineFont = 13,
    ObjectiveTrackerFont12 = 12,
    ObjectiveTrackerFont13 = 13,
    ObjectiveTrackerFont14 = 14,
    ObjectiveTrackerFont15 = 15,
    ObjectiveTrackerFont16 = 16,
    ObjectiveTrackerFont17 = 17,
    ObjectiveTrackerFont18 = 18,
    ObjectiveTrackerFont19 = 19,
    ObjectiveTrackerFont20 = 20,
    ObjectiveTrackerFont21 = 21,
    ObjectiveTrackerFont22 = 22,

    ChatBubbleFont = 13,

    -- NOTE: these fonts inherit GameFontNormalSmall
    -- GameFontNormalSmallLeft = 12,
    -- GameFontHighlightSmall = 12,
    -- GameFontHighlightSmallLeft = 12,
    -- GameFontHighlightSmallLeftTop = 12,
    -- GameFontHighlightSmallRight = 12,
    -- GameFontHighlightSmallOutline = 12,
}

BFI.vars.blizzardFontSizeDelta = 0

local function UpdateFont()
    local config = BFIConfig.general.font
    local commonFont = config.common.font

    if config.common.overrideAF then
        AF.UpdateBaseFont(AF.LSM_GetFont(commonFont))
    end

    if config.common.overrideBlizzard then
        _G.STANDARD_TEXT_FONT = AF.LSM_GetFont(commonFont)

        local delta = config.common.blizzardFontSizeDelta
        BFI.vars.blizzardFontSizeDelta = delta

        for _, font in next, fonts do
            local fontObj = _G[font]
            local _, size, outline = fontObj:GetFont()
            local hasShadow = fontObj:GetShadowOffset() ~= 0
            -- local delta = fontSizeDeltas[font] or 0
            size = fontSizeOverrides[font] or size
            AF.SetFont(fontObj, commonFont, size + delta, outline, hasShadow)
        end

        -- update default LSM font
        AF.Libs.LSM:SetDefault("font", commonFont)
    end

    if config.combatText.override then
        _G.DAMAGE_TEXT_FONT = AF.LSM_GetFont(config.combatText.font)
    end

    if config.nameText.override then
        _G.UNIT_NAME_FONT = AF.LSM_GetFont(config.nameText.font)
    end
end
AF.RegisterCallback("BFI_UpdateFont", UpdateFont)

---------------------------------------------------------------------
-- update config
---------------------------------------------------------------------
local function UpdateConfig(_, module)
    if module then return end -- init

    local config = BFIConfig.general

    -- GameMenuFrame scale
    local GameMenuFrame = _G.GameMenuFrame
    if not GameMenuFrame._BFIHooked then
        GameMenuFrame._BFIHooked = true
        hooksecurefunc(GameMenuFrame, "SetScale", function(self, scale)
            if scale ~= config.gameMenuScale then
                self:SetScale(config.gameMenuScale)
            end
            AF.DefaultUpdatePixels(GameMenuFrame.BFIBackdrop)
        end)
    end
    GameMenuFrame:SetScale(config.gameMenuScale)
end
AF.RegisterCallback("BFI_UpdateConfig", UpdateConfig)