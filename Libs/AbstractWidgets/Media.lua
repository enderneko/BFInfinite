local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- get icon
---------------------------------------------------------------------
function AW.GetIcon(icon)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Icons\\"..icon..".png"
end

function AW.GetIconString(icon)
    return "|T"..AW.GetIcon(icon)..":0|t"
end

---------------------------------------------------------------------
-- get texture
---------------------------------------------------------------------
function AW.GetTexture(texture)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Textures\\"..texture..".png"
end

---------------------------------------------------------------------
-- get plain texture
---------------------------------------------------------------------
function AW.GetPlainTexture()
    return "Interface\\Buttons\\WHITE8x8"
end

---------------------------------------------------------------------
-- get sound
---------------------------------------------------------------------
function AW.GetSound(sound)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Sounds\\"..sound..".ogg"
end