-- self == L
-- rawset(t, key, value)
-- Sets the value associated with a key in a table without invoking any metamethods
-- t - A table (table)
-- key - A key in the table (cannot be nil) (value)
-- value - New value to set for the key (value)
select(2, ...).L = setmetatable({
    ["buffs"] = "Buffs",
    ["castBar"] = "Cast Bar",
    ["classPowerBar"] = "Class Power Bar",
    ["combatIcon"] = "Combat Icon",
    ["debuffs"] = "Debuffs",
    ["extraManaBar"] = "Extra Mana Bar",
    ["factionIcon"] = "Faction Icon",
    ["healthBar"] = "Health Bar",
    ["healthText"] = "Health Text",
    ["incDmgHealText"] = "Incoming Damage/Heal Text",
    ["leaderIcon"] = "Leader Icon",
    ["leaderText"] = "Leader Text",
    ["levelText"] = "Level Text",
    ["mouseoverHighlight"] = "Mouseover Highlight",
    ["nameText"] = "Name Text",
    ["portrait"] = "Portrait",
    ["powerBar"] = "Power Bar",
    ["powerText"] = "Power Text",
    ["privateAuras"] = "Private Auras",
    ["raidIcon"] = "Raid Icon",
    ["rangeText"] = "Range Text",
    ["readyCheckIcon"] = "Ready Check Icon",
    ["restingIndicator"] = "Resting Indicator",
    ["roleIcon"] = "Role Icon",
    ["staggerBar"] = "Stagger Bar",
    ["statusIcon"] = "Status Icon",
    ["statusTimer"] = "Status Timer",
    ["targetCounter"] = "Target Counter",
    ["targetHighlight"] = "Target Highlight",
    ["threatGlow"] = "Threat Glow",
}, {
    __index = AbstractFramework.L
})