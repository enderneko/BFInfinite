local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- get icon
---------------------------------------------------------------------
function AW.GetIcon(icon, inAW)
    if inAW then
        return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Icons\\"..icon
    else
        return "Interface\\AddOns\\"..addonName.."\\Media\\Icons\\"..icon
    end
end

function AW.GetIconString(icon, inAW)
    return "|T"..AW.GetIcon(icon, inAW)..":0|t"
end

---------------------------------------------------------------------
-- get texture
---------------------------------------------------------------------
function AW.GetTexture(texture, inAW)
    if inAW then
        return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Textures\\"..texture
    else
        return "Interface\\AddOns\\"..addonName.."\\Media\\Textures\\"..texture
    end
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
function AW.GetSound(sound, inAW)
    if inAW then
        return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Sounds\\"..sound..".ogg"
    else
        return "Interface\\AddOns\\"..addonName.."\\Media\\Sounds\\"..sound..".ogg"
    end
end