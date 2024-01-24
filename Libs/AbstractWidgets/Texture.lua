local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
--- @param color table|string
function AW.CreateTexture(parent, texture, color)
    if type(color) == "string" then color = AW.GetColorTable(color) end
    color = color or {0, 0, 0, 1}

    local tex = parent:CreateTexture(nil, "ARTWORK")
    if texture then
        tex:SetTexture(texture)
        tex:SetVertexColor(unpack(color))
    else
        tex:SetColorTexture(unpack(color))
    end

    function tex:UpdatePixels()
        AW.ReSize(tex)
        AW.RePoint(tex)
    end

    AW.AddToPixelUpdater(tex)

    return tex
end

---------------------------------------------------------------------
-- gradient texture
---------------------------------------------------------------------
--- @param color1 table|string
--- @param color2 table|string
function AW.CreateGradientTexture(parent, orientation, color1, color2, texture)
    texture = texture or "Interface\\Buttons\\WHITE8x8"
    if type(color1) == "string" then color1 = AW.GetColorTable(color1) end
    if type(color2) == "string" then color2 = AW.GetColorTable(color2) end
    color1 = color1 or {0, 0, 0, 0}
    color2 = color2 or {0, 0, 0, 0}

    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(texture)
    tex:SetGradient(orientation, CreateColor(unpack(color1)), CreateColor(unpack(color2)))

    function tex:UpdatePixels()
        AW.ReSize(tex)
        AW.RePoint(tex)
    end

    AW.AddToPixelUpdater(tex)

    return tex
end

---------------------------------------------------------------------
-- get icon texture
---------------------------------------------------------------------
function AW.GetIcon(icon)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Icons\\"..icon..".png"
end