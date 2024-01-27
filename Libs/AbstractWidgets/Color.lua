local _, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- color utils
---------------------------------------------------------------------
function AW.ConvertRGB(r, g, b, desaturation)
    if not desaturation then desaturation = 1 end
    r = r / 255 * desaturation
    g = g / 255 * desaturation
    b = b / 255 * desaturation
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
--[[ Convert RGB to HSV	---------------------------------------------------
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

--[[ Convert HSB to RGB	---------------------------------------------------
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
local button_color_normal = {0.115, 0.115, 0.115, 1}

local colors = {
    -- accent
    ["accent"] = {["s"]="FFFF5F00", ["t"]={1, 0.37, 0, 1}, ["normal"]={1, 0.37, 0, 0.3}, ["hover"]={1, 0.37, 0, 0.6}}, -- orangered

    -- for regions
    ["background"] = {["s"]="E61A1A1A", ["t"]={0.1, 0.1, 0.1, 0.9}},
    ["border"] = {["s"]="FF000000", ["t"]={0, 0, 0, 1}},
    ["header"] = {["s"]="FF202020", ["t"]={0.127, 0.127, 0.127, 1}}, -- header background
    ["widget"] = {["s"]="FF262626", ["t"]={0.15, 0.15, 0.15, 1}}, -- widget background
    ["disabled"] = {["s"]="FF666666", ["t"]={0.4, 0.4, 0.4, 1}},
    
    -- rgb
    ["red"] = {["s"]="FFFF0000", ["t"]={1, 0, 0, 1}},
    ["green"] = {["s"]="FF00FF00", ["t"]={0, 1, 0, 1}},
    ["blue"] = {["s"]="FF0000FF", ["t"]={0, 0, 1, 1}},
    
    -- others
    ["white"] = {["s"]="FFFFFFFF", ["t"]={1, 1, 1, 1}},
    ["black"] = {["s"]="FF000000", ["t"]={0, 0, 0, 1}},
    ["gray"] = {["s"]="FFB2B2B2", ["t"]={0.7, 0.7, 0.7, 1}},
    ["sand"] = {["s"]="FFECCC68", ["t"]={0.93, 0.8, 0.41, 1}},
    ["gold"] = {["s"]="FFFFD100", ["t"]={1, 0.82, 0, 1}},
    ["orange"] = {["s"]="FFFFA502", ["t"]={1, 0.65, 0.01}},
    ["orangered"] = {["s"]="FFFF4F00", ["t"]={1, 0.31, 0, 1}},
    ["firebrick"] = {["s"]="FFFF3030", ["t"]={1, 0.19, 0.19, 1}},
    ["coral"] = {["s"]="FFFF7F50", ["t"]={1, 0.5, 0.31, 1}},
    ["tomato"] = {["s"]="FFFF6348", ["t"]={1, 0.39, 0.28, 1}},
    ["pink"] = {["s"]="FFFF6B81", ["t"]={1, 0.42, 0.51, 1}},
    ["hotpink"] = {["s"]="FFFF4757", ["t"]={1, 0.28, 0.34, 1}},
    ["lime"] = {["s"]="FF7BED9F", ["t"]={0.48, 0.93, 0.62, 1}},
    ["brightgreen"] = {["s"]="FF2ED573", ["t"]={0.18, 0.84, 0.45, 1}},
    ["chartreuse"] = {["s"]="FF80FF00", ["t"]={0.502, 1, 0, 1}},
    ["skyblue"] = {["s"]="FF00CCFF", ["t"]={0, 0.8, 1, 1}},
    ["vividblue"] = {["s"]="FF1E90FF", ["t"]={0.12, 0.56, 1, 1}},
    ["softblue"] = {["s"]="FF5352ED", ["t"]={0.33, 0.32, 0.93, 1}},
    ["brightblue"] = {["s"]="FF3742FA", ["t"]={0.22, 0.26, 0.98, 1}},
    
    -- class (data from RAID_CLASS_COLORS)
    ["DEATHKNIGHT"] = {["s"]="ffc41e3a", ["t"]={0.7686275243759155, 0.1176470667123795, 0.2274509966373444, 1}},
    ["DEMONHUNTER"] = {["s"]="ffa330c9", ["t"]={0.6392157077789307, 0.1882353127002716, 0.7882353663444519, 1}},
    ["DRUID"] = {["s"]="ffff7c0a", ["t"]={1, 0.4862745404243469, 0.03921568766236305, 1}},
    ["EVOKER"] = {["s"]="ff33937f", ["t"]={0.2000000178813934, 0.5764706134796143, 0.4980392456054688, 1}},
    ["HUNTER"] = {["s"]="ffaad372", ["t"]={0.6666666865348816, 0.8274510502815247, 0.4470588564872742, 1}},
    ["MAGE"] = {["s"]="ff3fc7eb", ["t"]={0.2470588386058807, 0.7803922295570374, 0.9215686917304993, 1}},
    ["MONK"] = {["s"]="ff00ff98", ["t"]={0, 1, 0.5960784554481506, 1}},
    ["PALADIN"] = {["s"]="fff48cba", ["t"]={0.9568628072738647, 0.5490196347236633, 0.729411780834198, 1}},
    ["PRIEST"] = {["s"]="ffffffff", ["t"]={1, 1, 1, 1}},
    ["ROGUE"] = {["s"]="fffff468", ["t"]={1, 0.9568628072738647, 0.4078431725502014, 1}},
    ["SHAMAN"] = {["s"]="ff0070dd", ["t"]={0, 0.4392157196998596, 0.8666667342185974, 1}},
    ["WARLOCK"] = {["s"]="ff8788ee", ["t"]={0.529411792755127, 0.5333333611488342, 0.9333333969116211, 1}},
    ["WARRIOR"] = {["s"]="ffc69b6d", ["t"]={0.7764706611633301, 0.6078431606292725, 0.4274510145187378, 1}},
}

function AW.GetColorRGB(name, alpha)
    assert(colors[name], "no such color!")
    if alpha then
        return colors[name]["t"][1], colors[name]["t"][2], colors[name]["t"][3], alpha
    else
        return unpack(colors[name]["t"])
    end
end

function AW.GetColorTable(name, alpha)
    assert(colors[name], "no such color!")
    if alpha then
        return {colors[name]["t"][1], colors[name]["t"][2], colors[name]["t"][3], alpha}
    else
        return colors[name]["t"] -- use default alpha 1
    end
end

function AW.GetColorStr(name)
    assert(colors[name], "no such color!")
    return colors[name]["s"]
end

function AW.ColorFontString(fs, name)
    assert(colors[name], "no such color!")
    fs:SetTextColor(colors[name]["t"][1], colors[name]["t"][2], colors[name]["t"][3])
end

function AW.WrapTextInColor(text, name)
    assert(colors[name], "no such color!")
    return WrapTextInColorCode(text, colors[name]["s"])
end

---------------------------------------------------------------------
-- button colors
---------------------------------------------------------------------
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
}

function AW.GetButtonNormalColor(name)
    assert(buttonColors[name], "no such color!")
    return buttonColors[name]["normal"]
end

function AW.GetButtonHoverColor(name)
    assert(buttonColors[name], "no such color!")
    return buttonColors[name]["hover"]
end