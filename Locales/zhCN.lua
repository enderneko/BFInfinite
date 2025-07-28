-- local _L = select(2, ...).L
-- local L = {}
-- ---@type AbstractFramework
-- local AF = _G.AbstractFramework

-- AF.RegisterCallback("BFI_UpdateLocale", function(_, locale)
--     if locale == "zhCN" then
--         for key, value in next, L do
--             _L[key] = value
--         end
--     else
--         wipe(L)
--         L = nil
--     end
-- end)

if not LOCALE_zhCN then return end
local L = select(2, ...).L

L["DEAD"] = "死亡"
L["GHOST"] = "鬼魂"

---------------------------------------------------------------------
-- general
---------------------------------------------------------------------
L["A separate UI scale is saved for each resolution"] = "不同分辨率下会分别保存对应的UI缩放"

---------------------------------------------------------------------
-- mover
---------------------------------------------------------------------
L["Unit Frames"] = "单位框体"
L["Focus"] = "焦点"
L["Focus Target"] = "焦点的目标"
L["Target Target"] = "目标的目标"
L["Pet Target"] = "宠物的目标"
L["Action Bar"] = "动作条"
L["Action Bars"] = "动作条"
L["Stance Bar"] = "姿态条"
L["Pet Bar"] = "宠物动作条"
L["Power Bar Widget"] = "能量条组件"
L["Alt Power Bar"] = "额外能量条"
L["UI Widgets"] = "界面组件"
L["Micro Menu"] = "微型主菜单"
L["Queue Status"] = "队列状态"
L["Zone Ability"] = "区域技能"
L["Special Power Timer"] = "特殊能量计时器"
L["Tooltip"] = "鼠标提示"

---------------------------------------------------------------------
-- data bars
---------------------------------------------------------------------
L["Data Bars"] = "数据条"
L["Experience Bar"] = "经验条"
L["Reputation Bar"] = "声望条"
L["Honor Bar"] = "荣誉条"
L["Paragon"] = "巅峰"

---------------------------------------------------------------------
-- tooltip
---------------------------------------------------------------------
L["Targeted By"] = "选为目标"
L["Calculating..."] = "正在计算…"