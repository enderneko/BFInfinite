local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- fonts
---------------------------------------------------------------------
local prefix = strupper(ns.prefix or addonName)

local font_title_name = prefix.."_FONT_TITLE"
local font_title_disable_name = prefix.."_FONT_TITLE_DISABLE"
local font_normal_name = prefix.."_FONT_NORMAL"
local font_normal_disable_name = prefix.."_FONT_NORMAL_DISABLE"
local font_chinese_name = prefix.."_FONT_CHINESE"
local font_special_name = prefix.."_FONT_SPECIAL"
local font_accent_title_name = prefix.."_FONT_ACCENT_TITLE"
local font_accent_name = prefix.."_FONT_ACCENT"

local base_font = GameFontNormal:GetFont()

local font_title = CreateFont(font_title_name)
font_title:SetFont(base_font, 14, "")
font_title:SetTextColor(1, 1, 1, 1)
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

local font_title_disable = CreateFont(font_title_disable_name)
font_title_disable:SetFont(base_font, 14, "")
font_title_disable:SetTextColor(AW.GetColorRGB("disabled"))
font_title_disable:SetShadowColor(0, 0, 0)
font_title_disable:SetShadowOffset(1, -1)
font_title_disable:SetJustifyH("CENTER")

local font_normal = CreateFont(font_normal_name)
font_normal:SetFont(base_font, 13, "")
font_normal:SetTextColor(1, 1, 1, 1)
font_normal:SetShadowColor(0, 0, 0)
font_normal:SetShadowOffset(1, -1)
font_normal:SetJustifyH("CENTER")

local font_normal_disable = CreateFont(font_normal_disable_name)
font_normal_disable:SetFont(base_font, 13, "")
font_normal_disable:SetTextColor(AW.GetColorRGB("disabled"))
font_normal_disable:SetShadowColor(0, 0, 0)
font_normal_disable:SetShadowOffset(1, -1)
font_normal_disable:SetJustifyH("CENTER")

local font_chinese = CreateFont(font_chinese_name)
font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, 14, "")
font_chinese:SetTextColor(1, 1, 1, 1)
font_chinese:SetShadowColor(0, 0, 0)
font_chinese:SetShadowOffset(1, -1)
font_chinese:SetJustifyH("CENTER")

local font_special = CreateFont(font_special_name)
font_special:SetFont("Interface\\AddOns\\"..addonName.."\\Media\\Fonts\\font.ttf", 12, "")
font_special:SetTextColor(1, 1, 1, 1)
font_special:SetShadowColor(0, 0, 0)
font_special:SetShadowOffset(1, -1)
font_special:SetJustifyH("CENTER")
font_special:SetJustifyV("MIDDLE")

local font_accent_title = CreateFont(font_accent_title_name)
font_accent_title:SetFont(base_font, 14, "")
font_accent_title:SetTextColor(AW.GetColorRGB("accent"))
font_accent_title:SetShadowColor(0, 0, 0)
font_accent_title:SetShadowOffset(1, -1)
font_accent_title:SetJustifyH("CENTER")

local font_accent = CreateFont(font_accent_name)
font_accent:SetFont(base_font, 13, "")
font_accent:SetTextColor(AW.GetColorRGB("accent"))
font_accent:SetShadowColor(0, 0, 0)
font_accent:SetShadowOffset(1, -1)
font_accent:SetJustifyH("CENTER")

---------------------------------------------------------------------
-- update size for all used fonts
---------------------------------------------------------------------
function AW.UpdateFontSize(offset)
    font_title:SetFont(base_font, 14+offset, "")
    font_title_disable:SetFont(base_font, 14+offset, "")
    font:SetFont(base_font, 13+offset, "")
    font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, 14+offset, "")
    font_normal_disable:SetFont(base_font, 13+offset, "")
    font_accent_title:SetFont(base_font, 14+offset, "")
    font_accent:SetFont(base_font, 13+offset, "")
end

---------------------------------------------------------------------
-- get font by "type"
---------------------------------------------------------------------
function AW.GetFont(font, isDisabled, isFontObj)
    if font == "title" then
        if isFontObj then
            return isDisabled and font_title_disable or font_title
        else
            return isDisabled and font_title_disable_name or font_title_name
        end
    elseif font == "normal" then
        if isFontObj then
            return isDisabled and font_normal_disable or font_normal
        else
            return isDisabled and font_normal_disable_name or font_normal_name
        end
    elseif font == "accent_title" then
        if isFontObj then
            return font_accent_title
        else
            return font_accent_title_name
        end
    elseif font == "accent" then
        if isFontObj then
            return font_accent
        else
            return font_accent_name
        end
    else
        assert(nil, "no such font!")
    end
end
