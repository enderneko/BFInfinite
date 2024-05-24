local _, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- color utils
---------------------------------------------------------------------
function AW.ConvertRGB(r, g, b, saturation)
    if not saturation then saturation = 1 end
    r = r / 255 * saturation
    g = g / 255 * saturation
    b = b / 255 * saturation
    return r, g, b
end

function AW.ConvertRGB_256(r, g, b)
    return floor(r * 255), floor(g * 255), floor(b * 255)
end

function AW.ConvertRGBToHEX(r, g, b)
    local result = ""

    for key, value in pairs({r, g, b}) do
        local hex = ""

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = "00"

        elseif(string.len(hex) == 1)then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

function AW.ConvertHEXToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- https://warcraft.wiki.gg/wiki/ColorGradient
function AW.ColorGradient(perc, r1,g1,b1, r2,g2,b2, r3,g3,b3)
    perc = perc or 1
    if perc >= 1 then
        return r3, g3, b3
    elseif perc <= 0 then
        return r1, g1, b1
    end

    local segment, relperc = math.modf(perc * 2)
    local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1,g1,b1, r2,g2,b2, r3,g3,b3)

    return rr1 + (rr2 - rr1) * relperc, rg1 + (rg2 - rg1) * relperc, rb1 + (rb2 - rb1) * relperc
end

-- From ColorPickerAdvanced by Feyawen-Llane
--[[ Convert RGB to HSV ---------------------------------------------------
    Inputs:
        r = Red [0, 1]
        g = Green [0, 1]
        b = Blue [0, 1]
    Outputs:
        H = Hue [0, 360]
        S = Saturation [0, 1]
        B = Brightness [0, 1]
]]--
function AW.ConvertRGBToHSB(r, g, b)
    local colorMax = max(max(r, g), b)
    local colorMin = min(min(r, g), b)
    local delta = colorMax - colorMin
    local H, S, B

    -- WoW's LUA doesn't handle floating point numbers very well (Somehow 1.000000 != 1.000000   WTF?)
    -- So we do this weird conversion of, Number to String back to Number, to make the IF..THEN work correctly!
    colorMax = tonumber(format("%f", colorMax))
    r = tonumber(format("%f", r))
    g = tonumber(format("%f", g))
    b = tonumber(format("%f", b))

    if (delta > 0) then
        if (colorMax == r) then
            H = 60 * (((g - b) / delta) % 6)
        elseif (colorMax == g) then
            H = 60 * (((b - r) / delta) + 2)
        elseif (colorMax == b) then
            H = 60 * (((r - g) / delta) + 4)
        end

        if (colorMax > 0) then
            S = delta / colorMax
        else
            S = 0
        end

        B = colorMax
    else
        H = 0
        S = 0
        B = colorMax
    end

    if (H < 0) then
        H = H + 360
    end

    return H, S, B
end

--[[ Convert HSB to RGB ---------------------------------------------------
    Inputs:
        h = Hue [0, 360]
        s = Saturation [0, 1]
        b = Brightness [0, 1]
    Outputs:
        R = Red [0,1]
        G = Green [0,1]
        B = Blue [0,1]
]]--
function AW.ConvertHSBToRGB(h, s, b)
    local chroma = b * s
    local prime = (h / 60) % 6
    local X = chroma * (1 - abs((prime % 2) - 1))
    local M = b - chroma
    local R, G, B

    if (0 <= prime) and (prime < 1) then
        R = chroma
        G = X
        B = 0
    elseif (1 <= prime) and (prime < 2) then
        R = X
        G = chroma
        B = 0
    elseif (2 <= prime) and (prime < 3) then
        R = 0
        G = chroma
        B = X
    elseif (3 <= prime) and (prime < 4) then
        R = 0
        G = X
        B = chroma
    elseif (4 <= prime) and (prime < 5) then
        R = X
        G = 0
        B = chroma
    elseif (5 <= prime) and (prime < 6) then
        R = chroma
        G = 0
        B = X
    else
        R = 0
        G = 0
        B = 0
    end

    R = R + M
    G = G + M
    B =  B + M

    return R, G, B
end

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction

local colors = {
    -- accent
    ["accent"] = {["hex"]="FFFF6600", ["t"]={1, 0.4, 0, 1}, ["normal"]={1, 0.4, 0, 0.3}, ["hover"]={1, 0.4, 0, 0.6}}, -- orangered

    -- for regions
    ["background"] = {["hex"]="E61A1A1A", ["t"]={0.1, 0.1, 0.1, 0.9}},
    ["border"] = {["hex"]="FF000000", ["t"]={0, 0, 0, 1}},
    ["header"] = {["hex"]="FF202020", ["t"]={0.127, 0.127, 0.127, 1}}, -- header background
    ["widget"] = {["hex"]="FF262626", ["t"]={0.15, 0.15, 0.15, 1}}, -- widget background
    ["disabled"] = {["hex"]="FF666666", ["t"]={0.4, 0.4, 0.4, 1}},
    ["none"] = {["hex"]="00000000", ["t"]={0, 0, 0, 0}},

    -- common
    ["red"] = {["hex"]="FFFF0000", ["t"]={1, 0, 0, 1}},
    ["yellow"] = {["hex"]="FFFFFF00", ["t"]={1, 1, 0, 1}},
    ["green"] = {["hex"]="FF00FF00", ["t"]={0, 1, 0, 1}},
    ["cyan"] = {["hex"]="FF00FFFF", ["t"]={0, 1, 1, 1}},
    ["blue"] = {["hex"]="FF0000FF", ["t"]={0, 0, 1, 1}},
    ["purple"] = {["hex"]="FFFF00FF", ["t"]={1, 0, 1, 1}},
    ["white"] = {["hex"]="FFFFFFFF", ["t"]={1, 1, 1, 1}},
    ["black"] = {["hex"]="FF000000", ["t"]={0, 0, 0, 1}},

    -- others
    ["gray"] = {["hex"]="FFB2B2B2", ["t"]={0.7, 0.7, 0.7, 1}},
    ["sand"] = {["hex"]="FFECCC68", ["t"]={0.93, 0.8, 0.41, 1}},
    ["gold"] = {["hex"]="FFFFD100", ["t"]={1, 0.82, 0, 1}},
    ["darkred"] = {["hex"]="FF402020", ["t"]={0.17, 0.13, 0.13, 1}},
    ["orange"] = {["hex"]="FFFFA502", ["t"]={1, 0.65, 0.01, 1}},
    ["orangered"] = {["hex"]="FFFF4F00", ["t"]={1, 0.31, 0, 1}},
    ["firebrick"] = {["hex"]="FFFF3030", ["t"]={1, 0.19, 0.19, 1}},
    ["coral"] = {["hex"]="FFFF7F50", ["t"]={1, 0.5, 0.31, 1}},
    ["tomato"] = {["hex"]="FFFF6348", ["t"]={1, 0.39, 0.28, 1}},
    ["lightred"] = {["hex"]="FFFF4757", ["t"]={1, 0.28, 0.34, 1}},
    ["classicrose"] = {["hex"]="FFFBCCE7", ["t"]={1, 0.98, 0.8, 0.91}},
    ["pink"] = {["hex"]="FFFF6B81", ["t"]={1, 0.42, 0.51, 1}},
    ["hotpink"] = {["hex"]="FFFF4466", ["t"]={1, 0.27, 0.4, 1}},
    ["lime"] = {["hex"]="FF7BED9F", ["t"]={0.48, 0.93, 0.62, 1}},
    ["brightgreen"] = {["hex"]="FF2ED573", ["t"]={0.18, 0.84, 0.45, 1}},
    ["chartreuse"] = {["hex"]="FF80FF00", ["t"]={0.502, 1, 0, 1}},
    ["skyblue"] = {["hex"]="FF00CCFF", ["t"]={0, 0.8, 1, 1}},
    ["vividblue"] = {["hex"]="FF1E90FF", ["t"]={0.12, 0.56, 1, 1}},
    ["softblue"] = {["hex"]="FF5352ED", ["t"]={0.33, 0.32, 0.93, 1}},
    ["brightblue"] = {["hex"]="FF3742FA", ["t"]={0.22, 0.26, 0.98, 1}},

    -- class (data from RAID_CLASS_COLORS)
    ["DEATHKNIGHT"] = {["hex"]="ffc41e3a", ["t"]={0.7686275243759155, 0.1176470667123795, 0.2274509966373444}},
    ["DEMONHUNTER"] = {["hex"]="ffa330c9", ["t"]={0.6392157077789307, 0.1882353127002716, 0.7882353663444519}},
    ["DRUID"] = {["hex"]="ffff7c0a", ["t"]={1, 0.4862745404243469, 0.03921568766236305}},
    ["EVOKER"] = {["hex"]="ff33937f", ["t"]={0.2000000178813934, 0.5764706134796143, 0.4980392456054688}},
    ["HUNTER"] = {["hex"]="ffaad372", ["t"]={0.6666666865348816, 0.8274510502815247, 0.4470588564872742}},
    ["MAGE"] = {["hex"]="ff3fc7eb", ["t"]={0.2470588386058807, 0.7803922295570374, 0.9215686917304993}},
    ["MONK"] = {["hex"]="ff00ff98", ["t"]={0, 1, 0.5960784554481506}},
    ["PALADIN"] = {["hex"]="fff48cba", ["t"]={0.9568628072738647, 0.5490196347236633, 0.729411780834198}},
    ["PRIEST"] = {["hex"]="ffffffff", ["t"]={1, 1, 1}},
    ["ROGUE"] = {["hex"]="fffff468", ["t"]={1, 0.9568628072738647, 0.4078431725502014}},
    ["SHAMAN"] = {["hex"]="ff0070dd", ["t"]={0, 0.4392157196998596, 0.8666667342185974}},
    ["WARLOCK"] = {["hex"]="ff8788ee", ["t"]={0.529411792755127, 0.5333333611488342, 0.9333333969116211}},
    ["WARRIOR"] = {["hex"]="ffc69b6d", ["t"]={0.7764706611633301, 0.6078431606292725, 0.4274510145187378}},

    -- reaction
    ["FRIENDLY"] = {["hex"]="ff4ab04d", ["t"]={0.29, 0.69, 0.3}},
    ["NEUTRAL"] = {["hex"]="ffd9c45c", ["t"]={0.85, 0.77, 0.36}},
    ["HOSTILE"] = {["hex"]="ffc74040", ["t"]={0.78, 0.25, 0.25}},

    -- power color (data from PowerBarColor)
    ["MANA"] = {["hex"]="ff007fff", ["t"]={0, 0.5, 1}}, -- 0, 0, 1
    ["RAGE"] = {["hex"]="ffff0000", ["t"]={1, 0, 0}},
    ["FOCUS"] = {["hex"]="ffff7f3f", ["t"]={1, 0.50, 0.25}},
    ["ENERGY"] = {["hex"]="ffffff00", ["t"]={1, 1, 0}},
    ["COMBO_POINTS"] = {["hex"]="fffff468", ["t"]={1, 0.96, 0.41}},
    ["RUNES"] = {["hex"]="ff7f7f7f", ["t"]={0.50, 0.50, 0.50}},
    ["RUNIC_POWER"] = {["hex"]="ff00d1ff", ["t"]={0, 0.82, 1}},
    ["SOUL_SHARDS"] = {["hex"]="ff7f518c", ["t"]={0.50, 0.32, 0.55}},
    ["LUNAR_POWER"] = {["hex"]="ff4c84e5", ["t"]={0.30, 0.52, 0.90}},
    ["HOLY_POWER"] = {["hex"]="fff2e599", ["t"]={0.95, 0.90, 0.60}},
    ["MAELSTROM"] = {["hex"]="ff007fff", ["t"]={0, 0.5, 1}},
    ["INSANITY"] = {["hex"]="ff9933ff", ["t"]={0.6, 0.2, 1}}, -- 0.40, 0, 0.80
    ["CHI"] = {["hex"]="ffb5ffea", ["t"]={0.71, 1, 0.92}},
    ["ARCANE_CHARGES"] = {["hex"]="ff1919f9", ["t"]={0.10, 0.10, 0.98}},
    ["FURY"] = {["hex"]="ffc842fc", ["t"]={0.788, 0.259, 0.992}},
    ["PAIN"] = {["hex"]="ffff9c00", ["t"]={1, 0.612, 0}},
    -- vehicle colors
    ["AMMOSLOT"] = {["hex"]="ffcc9900", ["t"]={0.80, 0.60, 0}},
    ["FUEL"] = {["hex"]="ff008c7f", ["t"]={0.0, 0.55, 0.5}},
    -- alternate power bar colors
    ["EBON_MIGHT"] = {["hex"]="ffe58c4c", ["t"]={0.9, 0.55, 0.3}},
    ["STAGGER_GREEN"] = {["hex"]="ff84ff84", ["t"]={0.52, 1, 0.52,}},
    ["STAGGER_YELLOW"] = {["hex"]="fffff9b7", ["t"]={1, 0.98, 0.72}},
    ["STAGGER_RED"] = {["hex"]="ffff6b6b", ["t"]={1, 0.42, 0.42}},

    -- quality https://warcraft.wiki.gg/wiki/Quality
    ["Poor"] = {["hex"]="ff9d9d9d", ["t"]={0.62, 0.62, 0.62, 1}}, -- ITEM_QUALITY0_DESC
    ["Common"] = {["hex"]="ffffffff", ["t"]={1, 1, 1, 1}}, -- ITEM_QUALITY1_DESC
    ["Uncommon"] = {["hex"]="ff1eff00", ["t"]={0.12, 1, 0, 1}}, -- ITEM_QUALITY2_DESC
    ["Rare"] = {["hex"]="ff0070dd", ["t"]={0, 0.44, 0.87, 1}}, -- ITEM_QUALITY3_DESC
    ["Epic"] = {["hex"]="ffa335ee", ["t"]={0.64, 0.21, 0.93, 1}}, -- ITEM_QUALITY4_DESC
    ["Legendary"] = {["hex"]="ffff8000", ["t"]={1, 0.5, 0, 1}}, -- ITEM_QUALITY5_DESC
    ["Artifact"] = {["hex"]="ffe6cc80", ["t"]={0.9, 0.8, 0.5, 1}}, -- ITEM_QUALITY6_DESC
    ["Heirloom"] = {["hex"]="ff00ccff", ["t"]={0, 0.8, 1, 1}}, -- ITEM_QUALITY7_DESC
    ["WoWToken"] = {["hex"]="ff00ccff", ["t"]={0, 0.8, 1, 1}}, -- ITEM_QUALITY8_DESC
}

function AW.GetColorRGB(name, alpha, saturation)
    assert(colors[name], "no such color:", name)
    saturation = saturation or 1
    alpha = alpha or colors[name]["t"][4]
    return colors[name]["t"][1]*saturation, colors[name]["t"][2]*saturation, colors[name]["t"][3]*saturation, alpha
end

function AW.GetClassColor(class, alpha, saturation)
    saturation = saturation or 1

    if colors[class] then
        return AW.GetColorRGB(class, alpha, saturation)
    end

    if RAID_CLASS_COLORS[class] then
        local r, g, b = RAID_CLASS_COLORS[class]:GetRGB()
        return r*saturation, g*saturation, b*saturation, alpha
    end

    return AW.GetColorRGB("uf_fg")
end

function AW.GetReactionColor(unit, alpha, saturation)
    local reaction = UnitReaction(unit, "player") or 0
    if reaction <= 2 then
        return AW.GetColorRGB("HOSTILE", alpha, saturation)
    elseif reaction <= 4 then
        return AW.GetColorRGB("NEUTRAL", alpha, saturation)
    else
        return AW.GetColorRGB("FRIENDLY", alpha, saturation)
    end
end

function AW.GetPowerColor(power, unit, alpha, saturation)
    saturation = saturation or 1

    if colors[power] then
        return AW.GetColorRGB(power, alpha, saturation)
    end

    if unit then
        local r, g, b = select(3, UnitPowerType(unit))
        if r then
            return r, g, b
        end
    end

    return AW.GetColorRGB("MANA", alpha, saturation)
end

function AW.GetColorTable(name, alpha, saturation)
    assert(colors[name], "no such color:", name)
    saturation = saturation or 1
    alpha = alpha or colors[name]["t"][4]

    return {colors[name]["t"][1]*saturation, colors[name]["t"][2]*saturation, colors[name]["t"][3]*saturation, alpha}
end

function AW.GetColorHex(name)
    assert(colors[name], "no such color:", name)
    return colors[name]["hex"]
end

function AW.ColorFontString(fs, name)
    assert(colors[name], "no such color:", name)
    fs:SetTextColor(colors[name]["t"][1], colors[name]["t"][2], colors[name]["t"][3])
end

function AW.WrapTextInColor(text, name)
    assert(colors[name], "no such color:", name)
    return WrapTextInColorCode(text, colors[name]["hex"])
end

function AW.AddColors(t)
    for k, v in pairs(t) do
        colors[k] = v
    end
end

function AW.UnpackColor(t, alpha)
    return t[1], t[2], t[3], alpha or t[4]
end

---------------------------------------------------------------------
-- button colors
---------------------------------------------------------------------
local button_color_normal = {0.127, 0.127, 0.127, 1}
local buttonColors = {
    ["accent"] = {["normal"]=colors["accent"]["normal"], ["hover"]=colors["accent"]["hover"]},
    ["accent-hover"] = {["normal"]=button_color_normal, ["hover"]=colors["accent"]["hover"]},
    ["accent-transparent"] = {["normal"]={0, 0, 0, 0}, ["hover"]=colors["accent"]["hover"]},
    ["border-only"] = {["normal"]={0, 0, 0, 0}, ["hover"]={0, 0, 0, 0}},
    ["none"] = {["normal"]={0, 0, 0, 0}, ["hover"]={0, 0, 0, 0}},
    ["red"] = {["normal"]={0.6, 0.1, 0.1, 0.6}, ["hover"]={0.6, 0.1, 0.1, 1}},
    ["red-hover"] = {["normal"]=button_color_normal, ["hover"]={0.6, 0.1, 0.1, 1}},
    ["green"] = {["normal"]={0.1, 0.6, 0.1, 0.6}, ["hover"]={0.1, 0.6, 0.1, 1}},
    ["green-hover"] = {["normal"]=button_color_normal, ["hover"]={0.1, 0.6, 0.1, 1}},
    ["blue"] = {["normal"]={0, 0.5, 0.8, 0.6}, ["hover"]={0, 0.5, 0.8, 1}},
    ["blue-hover"] = {["normal"]=button_color_normal, ["hover"]={0, 0.5, 0.8, 1}},
    ["yellow"] = {["normal"]={0.7, 0.7, 0, 0.6}, ["hover"]={0.7, 0.7, 0, 1}},
    ["yellow-hover"] = {["normal"]=button_color_normal, ["hover"]={0.7, 0.7, 0, 1}},
    ["hotpink"] = {["normal"]={1, 0.27, 0.4, 0.6}, ["hover"]={1, 0.27, 0.4, 1}},
    ["lime"] = {["normal"]={0.8, 1, 0, 0.35}, ["hover"]={0.8, 1, 0, 0.65}},
    ["lavender"] = {["normal"]={0.96, 0.73, 1, 0.35}, ["hover"]={0.96, 0.73, 1, 0.65}},
}

function AW.GetButtonNormalColor(name)
    assert(buttonColors[name], "no such button color:", name)
    return buttonColors[name]["normal"]
end

function AW.GetButtonHoverColor(name)
    assert(buttonColors[name], "no such button color:", name)
    return buttonColors[name]["hover"]
end