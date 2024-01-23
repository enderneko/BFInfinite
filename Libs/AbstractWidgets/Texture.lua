local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- gradient texture
---------------------------------------------------------------------
function AW.CreateGradientTexture(parent, orientation, color1, color2, texture)
    texture = texture or "Interface\\Buttons\\WHITE8x8"
    color1 = color1 or {0, 0, 0, 0}
    color2 = color2 or {0, 0, 0, 0}

    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(texture)
    tex:SetGradient(orientation, CreateColor(unpack(color1)), CreateColor(unpack(color2)))

    return tex
end

---------------------------------------------------------------------
-- get icon texture
---------------------------------------------------------------------
function AW.GetIcon(icon)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Icons\\"..icon..".png"
end