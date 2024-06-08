local addonName, ns = ...
---@class AbstractWidgets
local AW = ns.AW

---------------------------------------------------------------------
-- texture
---------------------------------------------------------------------
--- @param color table|string
function AW.CreateTexture(parent, texture, color, drawLayer, subLevel, wrapModeHorizontal, wrapModeVertical, filterMode)
    local tex = parent:CreateTexture(nil, drawLayer or "ARTWORK", nil, subLevel)

    function tex:SetColor(c)
        if type(c) == "string" then c = AW.GetColorTable(c) end
        c = c or {1, 1, 1, 1}
        if texture then
            tex:SetTexture(texture, wrapModeHorizontal, wrapModeVertical, filterMode)
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
-- calc texcoord
---------------------------------------------------------------------
function AW.CalcTexCoord(width, height, isIcon)
    local texCoord
    if isIcon then
        -- ULx,ULy, LLx,LLy, URx,URy, LRx,LRy
        texCoord = {0.12, 0.12, 0.12, 0.88, 0.88, 0.12, 0.88, 0.88}
    else
        texCoord = {0, 0, 0, 1, 1, 0, 1, 1}
    end

    local aspectRatio = width / height

    local xRatio = aspectRatio < 1 and aspectRatio or 1
    local yRatio = aspectRatio > 1 and 1 / aspectRatio or 1

    for i, coord in ipairs(texCoord) do
        local aspectRatio = (i % 2 == 1) and xRatio or yRatio
        texCoord[i] = (coord - 0.5) * aspectRatio + 0.5
    end

    return texCoord
end

---------------------------------------------------------------------
-- gradient texture
---------------------------------------------------------------------
--- @param color1 table|string
--- @param color2 table|string
function AW.CreateGradientTexture(parent, orientation, color1, color2, texture, drawLayer, subLevel)
    texture = texture or AW.GetPlainTexture()
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