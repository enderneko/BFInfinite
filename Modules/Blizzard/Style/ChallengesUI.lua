---@type BFI
local BFI = select(2, ...)
local S = BFI.modules.Style
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local PVEFrame = _G.PVEFrame
local ChallengesFrame

---------------------------------------------------------------------
--    ___ _         _ _                      ___
--   / __| |_  __ _| | |___ _ _  __ _ ___ __| __| _ __ _ _ __  ___
--  | (__| ' \/ _` | | / -_) ' \/ _` / -_|_-< _| '_/ _` | '  \/ -_)
--   \___|_||_\__,_|_|_\___|_||_\__, \___/__/_||_| \__,_|_|_|_\___|
--                              |___/
---------------------------------------------------------------------
local function StyleChallengesFrame()
    ChallengesFrame = _G.ChallengesFrame
    _G.ChallengesFrameInset:Hide()
    ChallengesFrame:DisableDrawLayer("BACKGROUND")

    --------------------------------------------------
    -- WeeklyInfo
    --------------------------------------------------
    local WeeklyInfo = ChallengesFrame.WeeklyInfo
    WeeklyInfo:SetAllPoints(ChallengesFrame)

    local Child = WeeklyInfo.Child
    Child:SetPoint("TOPLEFT", 6, -12)
    -- Child:SetPoint("TOPRIGHT", -6, -12)

    --------------------------------------------------
    -- AffixesContainer
    --------------------------------------------------
    local AffixesContainer = Child.AffixesContainer
    hooksecurefunc(AffixesContainer, "Layout", function(self)
        local children = self:GetLayoutChildren()
        for i, child in ipairs(children) do
            -- ChallengesKeystoneFrameAffixTemplate
            child.Border:Hide()
            S.StyleIcon(child.Portrait, true)
        end
    end)

    --------------------------------------------------
    -- ChallengesDungeonIconFrameTemplate
    --------------------------------------------------
    local function UpdateDungeon(frame)
        if frame._BFIStyled then return end
        frame._BFIStyled = true
        -- print(frame.mapID, C_ChallengeMode.GetMapUIInfo(frame.mapID))

        frame:DisableDrawLayer("BORDER")

        -- Icon
        S.StyleIcon(frame.Icon, true)
        frame.Icon:SetAllPoints()

        -- HighestLevel
        frame.HighestLevel:SetDrawLayer("OVERLAY")
        AF.RemoveFontShadow(frame.HighestLevel)
    end

    local function LineUpFrames(frames)
        local num = #frames
        local width = WeeklyInfo:GetWidth()
        local spacing = 2
        local padding = 3
        local frameWidth = (width - (num - 1) * spacing - padding * 2) / num

        for i, f in ipairs(frames) do
            f:ClearAllPoints()
            f:SetSize(frameWidth, frameWidth)
            if i == 1 then
                f:SetPoint("BOTTOMLEFT", WeeklyInfo, padding, padding)
                Child.SeasonBest:ClearAllPoints()
                Child.SeasonBest:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 2, 2)
            else
                f:SetPoint("BOTTOMLEFT", frames[i - 1], "BOTTOMRIGHT", spacing, 0)
            end
        end
    end

    hooksecurefunc(ChallengesFrame, "Update", function()
        for _, f in next, ChallengesFrame.DungeonIcons do
            UpdateDungeon(f)
        end
        LineUpFrames(ChallengesFrame.DungeonIcons)
    end)
end

---------------------------------------------------------------------
-- SeasonChangeNoticeFrame
---------------------------------------------------------------------
local function StyleSeasonChangeNoticeFrame()
    local SeasonChangeNoticeFrame = ChallengesFrame.SeasonChangeNoticeFrame

    SeasonChangeNoticeFrame:ClearAllPoints()
    SeasonChangeNoticeFrame:SetPoint("TOPLEFT", PVEFrame.BFIHeader, "BOTTOMLEFT", 2, -1)
    SeasonChangeNoticeFrame:SetPoint("BOTTOMRIGHT", PVEFrame.BFIBg, -2, 2)

    S.RemoveTextures(SeasonChangeNoticeFrame)
    S.StyleButton(SeasonChangeNoticeFrame.Leave, "BFI")
    S.CreateBackdrop(SeasonChangeNoticeFrame)
    SeasonChangeNoticeFrame.BFIBackdrop:SetBackdropColor(AF.GetColorRGB("widget", 0.95))

    --------------------------------------------------
    -- Affix
    --------------------------------------------------
    local Affix = SeasonChangeNoticeFrame.Affix
    Affix.AffixBorder:Hide()
    S.StyleIcon(Affix.Portrait, true)

    --------------------------------------------------
    -- texts
    --------------------------------------------------
    local function UpdateText(text, color)
        text:SetTextColor(AF.GetColorRGB(color))
        AF.SetFontShadow(text)
    end

    UpdateText(SeasonChangeNoticeFrame.NewSeason, "yellow_text")
    UpdateText(SeasonChangeNoticeFrame.SeasonDescription, "white")
    UpdateText(SeasonChangeNoticeFrame.SeasonDescription2, "white")
    UpdateText(SeasonChangeNoticeFrame.SeasonDescription3, "white")
end

AF.RegisterAddonLoaded("Blizzard_ChallengesUI", function()
    StyleChallengesFrame()
    StyleSeasonChangeNoticeFrame()
end)