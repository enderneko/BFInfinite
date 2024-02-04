local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
--- @param color table|string
function AW.CreateTexture(parent, texture, color, drawLayer, subLevel)
    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)

    function tex:SetColor(c)
        if type(c) == "string" then c = AW.GetColorTable(c) end
        c = c or {1, 1, 1, 1}
        if texture then
            tex:SetTexture(texture)
            tex:SetVertexColor(unpack(c))
        else
            tex:SetColorTexture(unpack(c))
        end
    end

    tex:SetColor(color)

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
function AW.CreateGradientTexture(parent, orientation, color1, color2, texture, drawLayer, subLevel)
    texture = texture or "Interface\\Buttons\\WHITE8x8"
    if type(color1) == "string" then color1 = AW.GetColorTable(color1) end
    if type(color2) == "string" then color2 = AW.GetColorTable(color2) end
    color1 = color1 or {0, 0, 0, 0}
    color2 = color2 or {0, 0, 0, 0}

    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)
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
-- line
---------------------------------------------------------------------
function AW.CreateSeparator(parent, width, height, color)
    if type(color) == "string" then color = AW.GetColorTable(color) end
    color = color or AW.GetColorTable("accent")

    local line = parent:CreateTexture(nil, "ARTWORK", nil, 0)
    AW.SetSize(line, width, height)
    line:SetColorTexture(unpack(color))

    local shadow = parent:CreateTexture(nil, "ARTWORK", nil, -1)
    AW.SetSize(shadow, width, height)
    AW.SetPoint(shadow, "TOPLEFT", line, 1, -1)
    shadow:SetColorTexture(AW.GetColorRGB("black", color[4])) -- use line alpha

    function line:UpdatePixels()
        AW.ReSize(line)
        AW.RePoint(line)
        AW.ReSize(shadow)
        AW.RePoint(shadow)
    end

    AW.AddToPixelUpdater(line)

    return line
end

---------------------------------------------------------------------
-- get icon
---------------------------------------------------------------------
function AW.GetIcon(icon)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Icons\\"..icon..".png"
end

---------------------------------------------------------------------
-- get texture
---------------------------------------------------------------------
function AW.GetTexture(texture)
    return "Interface\\AddOns\\"..addonName.."\\Libs\\AbstractWidgets\\Media\\Textures\\"..texture..".png"
end