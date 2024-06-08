local addonName, ns = ...
---@class AbstractWidgets
local AW = ns.AW

---------------------------------------------------------------------
-- fonts
---------------------------------------------------------------------
local prefix = strupper(ns.prefix or addonName)

local FONT_TITLE_NAME = prefix.."_FONT_TITLE"
local FONT_TITLE_DISABLE_NAME = prefix.."_FONT_TITLE_DISABLE"
local FONT_ACCENT_OUTLINE_NAME = prefix.."_FONT_OUTLINE"
local FONT_OUTLINE_DISABLE_NAME = prefix.."_FONT_OUTLINE_DISABLE"
local FONT_NORMAL_NAME = prefix.."_FONT_NORMAL"
local FONT_NORMAL_DISABLE_NAME = prefix.."_FONT_NORMAL_DISABLE"
local FONT_SMALL_NAME = prefix.."_FONT_SMALL"
local FONT_SMALL_DISABLE_NAME = prefix.."_FONT_SMALL_DISABLE"
local FONT_CHINESE_NAME = prefix.."_FONT_CHINESE"
local FONT_SPECIAL_NAME = prefix.."_FONT_SPECIAL"
local FONT_ACCENT_TITLE_NAME = prefix.."_FONT_ACCENT_TITLE"
local FONT_ACCENT_NAME = prefix.."_FONT_ACCENT"

local FONT_TITLE_SIZE = 14
local FONT_NORMAL_SIZE = 13
local FONT_ACCENT_OUTLINE_SIZE = 13
local FONT_SMALL_SIZE = 11
local FONT_CHINESE_SIZE = 14
local FONT_SPECIAL_SIZE = 12
local FONT_ACCENT_TITLE_SIZE = 14
local FONT_ACCENT_SIZE = 13

local BASE_FONT = GameFontNormal:GetFont()

local font_title = CreateFont(FONT_TITLE_NAME)
font_title:SetFont(BASE_FONT, FONT_TITLE_SIZE, "")
font_title:SetTextColor(1, 1, 1, 1)
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

local font_title_disable = CreateFont(FONT_TITLE_DISABLE_NAME)
font_title_disable:SetFont(BASE_FONT, FONT_TITLE_SIZE, "")
font_title_disable:SetTextColor(AW.GetColorRGB("disabled"))
font_title_disable:SetShadowColor(0, 0, 0)
font_title_disable:SetShadowOffset(1, -1)
font_title_disable:SetJustifyH("CENTER")

local font_normal = CreateFont(FONT_NORMAL_NAME)
font_normal:SetFont(BASE_FONT, FONT_NORMAL_SIZE, "")
font_normal:SetTextColor(1, 1, 1, 1)
font_normal:SetShadowColor(0, 0, 0)
font_normal:SetShadowOffset(1, -1)
font_normal:SetJustifyH("CENTER")

local font_normal_disable = CreateFont(FONT_NORMAL_DISABLE_NAME)
font_normal_disable:SetFont(BASE_FONT, FONT_NORMAL_SIZE, "")
font_normal_disable:SetTextColor(AW.GetColorRGB("disabled"))
font_normal_disable:SetShadowColor(0, 0, 0)
font_normal_disable:SetShadowOffset(1, -1)
font_normal_disable:SetJustifyH("CENTER")

local font_small = CreateFont(FONT_SMALL_NAME)
font_small:SetFont(BASE_FONT, FONT_SMALL_SIZE, "")
font_small:SetTextColor(1, 1, 1, 1)
font_small:SetShadowColor(0, 0, 0)
font_small:SetShadowOffset(1, -1)
font_small:SetJustifyH("CENTER")

local font_small_disable = CreateFont(FONT_SMALL_DISABLE_NAME)
font_small_disable:SetFont(BASE_FONT, FONT_SMALL_SIZE, "")
font_small_disable:SetTextColor(AW.GetColorRGB("disabled"))
font_small_disable:SetShadowColor(0, 0, 0)
font_small_disable:SetShadowOffset(1, -1)
font_small_disable:SetJustifyH("CENTER")

local font_chinese = CreateFont(FONT_CHINESE_NAME)
font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, FONT_CHINESE_SIZE, "")
font_chinese:SetTextColor(1, 1, 1, 1)
font_chinese:SetShadowColor(0, 0, 0)
font_chinese:SetShadowOffset(1, -1)
font_chinese:SetJustifyH("CENTER")

local font_special = CreateFont(FONT_SPECIAL_NAME)
font_special:SetFont("Interface\\AddOns\\"..addonName.."\\Media\\Fonts\\font.ttf", FONT_SPECIAL_SIZE, "")
font_special:SetTextColor(1, 1, 1, 1)
font_special:SetShadowColor(0, 0, 0)
font_special:SetShadowOffset(1, -1)
font_special:SetJustifyH("CENTER")
font_special:SetJustifyV("MIDDLE")

local font_accent_title = CreateFont(FONT_ACCENT_TITLE_NAME)
font_accent_title:SetFont(BASE_FONT, FONT_ACCENT_TITLE_SIZE, "")
font_accent_title:SetTextColor(AW.GetColorRGB("accent"))
font_accent_title:SetShadowColor(0, 0, 0)
font_accent_title:SetShadowOffset(1, -1)
font_accent_title:SetJustifyH("CENTER")

local font_accent_outline = CreateFont(FONT_ACCENT_OUTLINE_NAME)
font_accent_outline:SetFont(BASE_FONT, FONT_ACCENT_OUTLINE_SIZE, "OUTLINE")
font_accent_outline:SetTextColor(AW.GetColorRGB("accent"))
font_accent_outline:SetShadowColor(0, 0, 0)
font_accent_outline:SetShadowOffset(0, 0)
font_accent_outline:SetJustifyH("CENTER")

local font_accent = CreateFont(FONT_ACCENT_NAME)
font_accent:SetFont(BASE_FONT, FONT_ACCENT_SIZE, "")
font_accent:SetTextColor(AW.GetColorRGB("accent"))
font_accent:SetShadowColor(0, 0, 0)
font_accent:SetShadowOffset(1, -1)
font_accent:SetJustifyH("CENTER")

---------------------------------------------------------------------
-- update size for all used fonts
---------------------------------------------------------------------
local fontStrings = {}
function AW.AddToFontSizeUpdater(fs, originalSize)
    fs.originalSize = originalSize
    tinsert(fontStrings, fs)
end

AW.fontSizeOffset = 0
function AW.UpdateFontSize(offset)
    AW.fontSizeOffset = offset
    font_title:SetFont(BASE_FONT, FONT_TITLE_SIZE+offset, "")
    font_title_disable:SetFont(BASE_FONT, FONT_TITLE_SIZE+offset, "")
    font_normal:SetFont(BASE_FONT, FONT_NORMAL_SIZE+offset, "")
    font_normal_disable:SetFont(BASE_FONT, FONT_NORMAL_SIZE+offset, "")
    font_small:SetFont(BASE_FONT, FONT_SMALL_SIZE+offset, "")
    font_small_disable:SetFont(BASE_FONT, FONT_SMALL_SIZE+offset, "")
    font_chinese:SetFont(UNIT_NAME_FONT_CHINESE, FONT_CHINESE_SIZE+offset, "")
    font_accent_title:SetFont(BASE_FONT, FONT_ACCENT_TITLE_SIZE+offset, "")
    font_accent_outline:SetFont(BASE_FONT, FONT_ACCENT_OUTLINE_SIZE+offset, "")
    font_accent:SetFont(BASE_FONT, FONT_ACCENT_SIZE+offset, "")

    for _, fs in ipairs(fontStrings) do
        local f, _, o = fs:GetFont()
        fs:SetFont(f, (fs.originalSize or FONT_NORMAL_SIZE)+offset, o)
    end
end

---------------------------------------------------------------------
-- get font by "type"
---------------------------------------------------------------------
function AW.GetFontName(font, isDisabled)
    if font == "title" then
        return isDisabled and FONT_TITLE_DISABLE_NAME or FONT_TITLE_NAME
    elseif font == "normal" then
        return isDisabled and FONT_NORMAL_DISABLE_NAME or FONT_NORMAL_NAME
    elseif font == "small" then
        return isDisabled and FONT_SMALL_DISABLE_NAME or FONT_SMALL_NAME
    elseif font == "accent_title" then
        return FONT_ACCENT_TITLE_NAME
    elseif font == "accent_outline" then
        return FONT_ACCENT_OUTLINE_NAME
    elseif font == "accent" then
        return FONT_ACCENT_NAME
    end
end

function AW.GetFontObject(font, isDisabled)
    if font == "title" then
        return isDisabled and font_title_disable or font_title
    elseif font == "normal" then
        return isDisabled and font_normal_disable or font_normal
    elseif font == "small" then
        return isDisabled and font_small_disable or font_small
    elseif font == "accent_title" then
        return font_accent_title
    elseif font == "accent_outline" then
        return font_accent_outline
    elseif font == "accent" then
        return font_accent
    end
end

function AW.GetFontFile(font)
    if font == "title" then
            return BASE_FONT, FONT_TITLE_SIZE+AW.fontSizeOffset, ""
    elseif font == "normal" then
            return BASE_FONT, FONT_NORMAL_SIZE+AW.fontSizeOffset, ""
    elseif font == "small" then
            return BASE_FONT, FONT_SMALL_SIZE+AW.fontSizeOffset, ""
    elseif font == "accent_title" then
        return BASE_FONT, FONT_ACCENT_TITLE_SIZE+AW.fontSizeOffset, ""
    elseif font == "accent_outline" then
        return BASE_FONT, FONT_ACCENT_OUTLINE_SIZE+AW.fontSizeOffset, "OUTLINE"
    elseif font == "accent" then
        return BASE_FONT, FONT_ACCENT_SIZE+AW.fontSizeOffset, ""
    else
        return font, FONT_NORMAL_SIZE+AW.fontSizeOffset, ""
    end
end
