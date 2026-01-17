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
local DUNGEON_TELEPORTS = {
    [2] = {
        -- 青龙寺 - Temple of the Jade Serpent
        131204, -- 青龙之路
    },
    [56] = {
        -- 风暴烈酒酿造厂 - Stormstout Brewery
        131205, -- 烈酒之路
    },
    [57] = {
        -- 残阳关 - Gate of the Setting Sun
        131225, -- 残阳之路
    },
    [58] = {
        -- 影踪禅院 - Shado-Pan Monastery
        131206, -- 影踪派之路
    },
    [59] = {
        -- 围攻砮皂寺 - Siege of Niuzao Temple
        131228, -- 玄牛之路
    },
    [60] = {
        -- 魔古山宫殿 - Mogu'shan Palace
        131222, -- 魔古皇帝之路
    },
    [76] = {
        -- 通灵学院 - Scholomance
        131232, -- 通灵师之路
    },
    [77] = {
        -- 血色大厅 - Scarlet Halls
        131231, -- 血色利刃之路
    },
    [78] = {
        -- 血色修道院 - Scarlet Monastery
        131229, -- 血色法冠之路
    },
    [161] = {
        -- 通天峰 - Skyreach
        1254557, -- 加冕巅峰之路
        159898, -- 通天之路
    },
    [163] = {
        -- 血槌炉渣矿井 - Bloodmaul Slag Mines
        159895, -- 血槌之路
    },
    [164] = {
        -- 奥金顿 - Auchindoun
        159897, -- 警戒者之路
    },
    [165] = {
        -- 影月墓地 - Shadowmoon Burial Grounds
        159899, -- 新月之路
    },
    [166] = {
        -- 恐轨车站 - Grimrail Depot
        159900, -- 暗轨之路
    },
    [167] = {
        -- 黑石塔上层 - Upper Blackrock Spire
        159902, -- 火山之路
    },
    [168] = {
        -- 永茂林地 - The Everbloom
        159901, -- 青翠之路
    },
    [169] = {
        -- 钢铁码头 - Iron Docks
        159896, -- 铁船之路
    },
    [197] = {
        -- 艾萨拉之眼 - Eye of Azshara
        0, -- TODO: 未知传送法术
    },
    [198] = {
        -- 黑心林地 - Darkheart Thicket
        424163, -- 梦魇之王之路
    },
    [199] = {
        -- 黑鸦堡垒 - Black Rook Hold
        424153, -- 上古恐惧之路
    },
    [200] = {
        -- 英灵殿 - Halls of Valor
        393764, -- 证明价值之路
    },
    [206] = {
        -- 奈萨里奥的巢穴 - Neltharion's Lair
        410078, -- 大地守护者之路
    },
    [207] = {
        -- 守望者地窟 - Vault of the Wardens
        0, -- TODO: 未知传送法术
    },
    [208] = {
        -- 噬魂之喉 - Maw of Souls
        0, -- TODO: 未知传送法术
    },
    [209] = {
        -- 魔法回廊 - The Arcway
        0, -- TODO: 未知传送法术
    },
    [210] = {
        -- 群星庭院 - Court of Stars
        393766, -- 大魔导师之路
    },
    [227] = {
        -- 卡拉赞（下层） - Return to Karazhan: Lower
        373262, -- 堕落守护者之路
    },
    [233] = {
        -- 永夜大教堂 - Cathedral of Eternal Night
        0, -- TODO: 未知传送法术
    },
    [234] = {
        -- 卡拉赞（上层） - Return to Karazhan: Upper
        373262, -- 堕落守护者之路
    },
    [239] = {
        -- 执政团之座 - Seat of the Triumvirate
        1254551, -- 黑暗废弃之路
    },
    [244] = {
        -- 阿塔达萨 - Atal'Dazar
        424187, -- 鎏金皇陵之路
    },
    [245] = {
        -- 自由镇 - Freehold
        410071, -- 无拘海匪之路
    },
    [246] = {
        -- 托尔达戈 - Tol Dagor
        0, -- TODO: 未知传送法术
    },
    [247] = {
        -- 暴富矿区！！ - The MOTHERLODE!!
        467553, -- 艾泽里特精炼厂之路
        467555, -- 艾泽里特精炼厂之路
    },
    [248] = {
        -- 维克雷斯庄园 - Waycrest Manor
        424167, -- 巫心灾厄之路
    },
    [249] = {
        -- 诸王之眠 - Kings' Rest
        0, -- TODO: 未知传送法术
    },
    [250] = {
        -- 塞塔里斯神庙 - Temple of Sethraliss
        0, -- TODO: 未知传送法术
    },
    [251] = {
        -- 地渊孢林 - The Underrot
        410074, -- 腐败丛生之路
    },
    [252] = {
        -- 风暴神殿 - Shrine of the Storm
        0, -- TODO: 未知传送法术
    },
    [353] = {
        -- 围攻伯拉勒斯 - Siege of Boralus
        445418, -- 困守孤港之路
        464256, -- 困守孤港之路
    },
    [369] = {
        -- 麦卡贡行动：垃圾场 - Operation: Mechagon - Junkyard
        373274, -- 机械王子之路
    },
    [370] = {
        -- 麦卡贡行动：车间 - Operation: Mechagon - Workshop
        373274, -- 机械王子之路
    },
    [375] = {
        -- 塞兹仙林的迷雾 - Mists of Tirna Scithe
        354464, -- 雾林之路
    },
    [376] = {
        -- 通灵战潮 - The Necrotic Wake
        354462, -- 勇者之路
    },
    [377] = {
        -- 彼界 - De Other Side
        354468, -- 狡诈之神之路
    },
    [378] = {
        -- 赎罪大厅 - Halls of Atonement
        354465, -- 罪魂之路
    },
    [379] = {
        -- 凋魂之殇 - Plaguefall
        354463, -- 瘟疫之路
    },
    [380] = {
        -- 赤红深渊 - Sanguine Depths
        354469, -- 石头守望者之路
    },
    [381] = {
        -- 晋升高塔 - Spires of Ascension
        354466, -- 晋升者之路
    },
    [382] = {
        -- 伤逝剧场 - Theater of Pain
        354467, -- 不败之路
    },
    [391] = {
        -- 塔扎维什：琳彩天街 - Tazavesh: Streets of Wonder
        367416, -- 街头商贩之路
    },
    [392] = {
        -- 塔扎维什：索·莉亚的宏图 - Tazavesh: So'leah's Gambit
        367416, -- 街头商贩之路
    },
    [399] = {
        -- 红玉新生法池 - Ruby Life Pools
        393256, -- 利爪防御者之路
    },
    [400] = {
        -- 诺库德阻击战 - The Nokhud Offensive
        393262, -- 啸风平原之路
    },
    [401] = {
        -- 碧蓝魔馆 - The Azure Vault
        393279, -- 奥秘之路
    },
    [402] = {
        -- 艾杰斯亚学院 - Algeth'ar Academy
        393273, -- 巨龙学位之路
    },
    [403] = {
        -- 奥达曼：提尔的遗产 - Uldaman: Legacy of Tyr
        393222, -- 看护者遗产之路
    },
    [404] = {
        -- 奈萨鲁斯 - Neltharus
        393276, -- 黑曜宝藏之路
    },
    [405] = {
        -- 蕨皮山谷 - Brackenhide Hollow
        393267, -- 腐木之路
    },
    [406] = {
        -- 注能大厅 - Halls of Infusion
        393283, -- 泰坦水库之路
    },
    [438] = {
        -- 旋云之巅 - The Vortex Pinnacle
        410080, -- 风神领域之路
    },
    [456] = {
        -- 潮汐王座 - Throne of the Tides
        424142, -- 猎潮者之路
    },
    [463] = {
        -- 永恒黎明：迦拉克隆的陨落 - Dawn of the Infinite: Galakrond's Fall
        424197, -- 扭曲之光之路
    },
    [464] = {
        -- 永恒黎明：慕瑟霜德的崛起 - Dawn of the Infinite: Murozond's Rise
        424197, -- 扭曲之光之路
    },
    [499] = {
        -- 圣焰隐修院 - Priory of the Sacred Flame
        445444, -- 敬奉圣光之路
        445414, -- 阿拉希飞艇之路
    },
    [500] = {
        -- 驭雷栖巢 - The Rookery
        445443, -- 堕落驭雷者之路
    },
    [501] = {
        -- 矶石宝库 - The Stonevault
        445269, -- 腐化铸造厂之路
    },
    [502] = {
        -- 千丝之城 - City of Threads
        445416, -- 蛛魔扬升之路
        445417, -- 荒弃古城之路
    },
    [503] = {
        -- 艾拉-卡拉，回响之城 - Ara-Kara, City of Echoes
        445417, -- 荒弃古城之路
        445416, -- 蛛魔扬升之路
    },
    [504] = {
        -- 暗焰裂口 - Darkflame Cleft
        445441, -- 防身明烛之路
    },
    [505] = {
        -- 破晨号 - The Dawnbreaker
        445414, -- 阿拉希飞艇之路
        445444, -- 敬奉圣光之路
    },
    [506] = {
        -- 燧酿酒庄 - Cinderbrew Meadery
        445440, -- 焰光酒庄之路
    },
    [507] = {
        -- 格瑞姆巴托 - Grim Batol
        445424, -- 暮光要塞之路
    },
    [525] = {
        -- 水闸行动 - Operation: Floodgate
        1216786, -- 断路器之路
    },
    [556] = {
        -- 萨隆矿坑 - Pit of Saron
        1254555, -- 不屈凋零之路
    },
    [557] = {
        -- 风行者之塔 - Windrunner Spire
        1254400, -- 风行者之路
    },
    [558] = {
        -- 魔导师平台 - Magister's Terrace
        1254572, -- 虔心魔导之路
    },
    [559] = {
        -- 节点希纳斯 - Nexus-Point Xenas
        1254563, -- 破碎核心之路
    },
    [560] = {
        -- 迈萨拉洞窟 - Maisara Caverns
        1254559, -- 幽深洞穴之路
    },
}

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
    local function UpdateDungeons(frame)
        if frame._BFIStyled then return end
        frame._BFIStyled = true

        frame:DisableDrawLayer("BORDER")

        -- Icon
        S.StyleIcon(frame.Icon, true)
        frame.Icon:SetAllPoints()

        -- HighestLevel
        frame.HighestLevel:SetDrawLayer("OVERLAY")
        AF.RemoveFontShadow(frame.HighestLevel)

        -- print(frame.mapID, C_ChallengeMode.GetMapUIInfo(frame.mapID))
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
            UpdateDungeons(f)
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
    AF.SetFontShadow(SeasonChangeNoticeFrame.NewSeason, nil, "yellow_text")
    AF.SetFontShadow(SeasonChangeNoticeFrame.SeasonDescription, nil, "white")
    AF.SetFontShadow(SeasonChangeNoticeFrame.SeasonDescription2, nil, "white")
    AF.SetFontShadow(SeasonChangeNoticeFrame.SeasonDescription3, nil, "white")
end

AF.RegisterAddonLoaded("Blizzard_ChallengesUI", function()
    StyleChallengesFrame()
    StyleSeasonChangeNoticeFrame()
end)