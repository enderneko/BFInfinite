---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils

-- forked from ThreatPlates
---------------------------------------------------------------------
-- CC TYPES (priorities) https://warcraft.wiki.gg/wiki/Crowd_control
--
-- loss of control
local CHARM = 1 -- 魅惑 - target is under control of the caster.
local FEAR = 2 -- 恐惧 - target runs randomly around.
local STUN = 3 -- 昏迷 - target is unable to move or perform any actions.
local INCAPACITATE = 4 -- 瘫痪 - a stun which breaks on damage to the target.
local SLEEP = 5 -- 沉睡 - target is put to sleep, unable to move or perform any actions.
local DISORIENT = 6 -- 迷惑 - target wanders around slowly, unable to perform actions.
local POLYMORPH = 7 -- 变形 - target is transformed into a critter, unable to perform actions. Most Polymorph effects also include Disorient.
local BANISH = 8 -- 放逐 - target is made immune to all effects but is unable to perform any.
local HORROR = 9 -- 惊骇 - similar to Fear effect, but duration tends to be short.
local SILENCE = 10 -- 沉默
local DISARM = 11 -- 缴械

-- positional control
local SNARE = 12 -- 诱捕 - targets movement speed is limited, often slowed to below normal run speed.
local ROOT = 13 -- 定身 - target is locked in place, stationery, but abilities may still be performed.
local DAZE = 14 -- 眩晕 - targets movement speed is reduced to 50%, and dismounted if applicable.
local GRIP = 15 -- 拖拽 - targets are pulled from their original position, often having spells interrupted.
local PUSHBACK = 16 -- 击退
local MODAGGRORANGE = 17 -- 仇恨范围

-- other
local OTHER = 18

---------------------------------------------------------------------
-- CC DATA
---------------------------------------------------------------------
local CC_DATA = {
    -- MONK
    [115078] = INCAPACITATE, -- 分筋错骨
    [119381] = STUN, -- 扫堂腿

    -- SHAMAN
    [118905] = STUN, -- 静电充能
}

function U.GetCrowdControlType(auraData)
    if auraData.isHelpful then return end
    return CC_DATA[auraData.spellId]
end