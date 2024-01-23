local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- style
---------------------------------------------------------------------
--- @param color string color name defined in Color.lua
--- @param borderColor string color name defined in Color.lua
function AW.StylizeFrame(frame, color, borderColor)
    color = color or "background"
    borderColor = borderColor or "border"

    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(frame)})
    frame:SetBackdropColor(AW.GetColorRGB(color))
    frame:SetBackdropBorderColor(AW.GetColorRGB(borderColor))
end

---------------------------------------------------------------------
-- titled frame
---------------------------------------------------------------------
function AW.CreateHeaderedFrame(parent, name, title, width, height, frameStrata, frameLevel, notUserPlaced)
    local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
    f:Hide()
    f:EnableMouse(true)
    -- f:SetIgnoreParentScale(true)
    -- f:SetResizable(false)
    f:SetMovable(true)
    f:SetUserPlaced(not notUserPlaced)
    f:SetFrameStrata(frameStrata or "HIGH")
    f:SetFrameLevel(frameLevel or 1)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(0, 0, AW.ConvertPixelsForRegion(20, f), 0)
    AW.SetSize(f, width, height)
    f:SetPoint("CENTER")
    AW.StylizeFrame(f)
    
    -- header
    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.header = header
    header:EnableMouse(true)
    header:SetClampedToScreen(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        f:StartMoving()
        if notUserPlaced then f:SetUserPlaced(false) end
    end)
    header:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    AW.SetPoint(header, "LEFT")
    AW.SetPoint(header, "RIGHT")
    AW.SetPoint(header, "BOTTOM", f, "TOP", 0, -1)
    AW.SetHeight(header, 20)
    AW.StylizeFrame(header, "header")

    header.text = header:CreateFontString(nil, "OVERLAY", AW.GetFont("accent_title"))
    header.text:SetText(title)
    header.text:SetPoint("CENTER")

    header.closeBtn = AW.CreateCloseButton(header, f, 20, 20)
    header.closeBtn:SetPoint("TOPRIGHT")

    local r, g, b = AW.GetColorRGB("accent")

    header.tex = header:CreateTexture(nil, "ARTWORK")
    header.tex:SetAllPoints(header)
    header.tex:SetColorTexture(r, g, b, 0.08)

    -- header.tex = AW.CreateGradientTexture(header, "Horizontal", {r, g, b, 0.25})
    -- AW.SetPoint(header.tex, "TOPLEFT", 1, -1)
    -- AW.SetPoint(header.tex, "BOTTOMRIGHT", -1, 1)

    -- header.tex = AW.CreateGradientTexture(header, "VERTICAL", nil, {r, g, b, 0.25})
    -- AW.SetPoint(header.tex, "TOPLEFT", 1, -1)
    -- AW.SetPoint(header.tex, "BOTTOMRIGHT", header, "RIGHT", -1, 0)

    -- header.tex2 = AW.CreateGradientTexture(header, "VERTICAL", {r, g, b, 0.25})
    -- AW.SetPoint(header.tex2, "TOPLEFT", header, "LEFT", 1, 0)
    -- AW.SetPoint(header.tex2, "BOTTOMRIGHT", -1, 1)

    -- header.tex = AW.CreateGradientTexture(header, "VERTICAL", nil, {r, g, b, 0.1})
    -- AW.SetPoint(header.tex, "TOPLEFT", 1, -1)
    -- AW.SetPoint(header.tex, "BOTTOMRIGHT", -1, 1)

    -- header.tex2 = AW.CreateGradientTexture(header, "VERTICAL", {r, g, b, 0.1})
    -- AW.SetPoint(header.tex2, "TOPLEFT", 1, -1)
    -- AW.SetPoint(header.tex2, "BOTTOMRIGHT", -1, 1)

    -- header.tex = AW.CreateGradientTexture(header, "VERTICAL", {r, g, b, 0.1})
    -- AW.SetPoint(header.tex, "TOPLEFT", 1, -1)
    -- AW.SetPoint(header.tex, "BOTTOMRIGHT", -1, 1)
    
    function f:UpdatePixels()
        f:SetClampRectInsets(0, 0, AW.ConvertPixelsForRegion(20, f), 0)
        AW.ReSize(f)
        AW.ReBorder(f)
        AW.ReSize(header)
        AW.RePoint(header)
        AW.ReBorder(header)
        AW.RePoint(header.tex)
        header.closeBtn:UpdatePixels()
    end

    AW.AddToPixelUpdater(f)

    return f
end

---------------------------------------------------------------------
-- bordered frame
---------------------------------------------------------------------
--- @param color string color name defined in Color.lua
--- @param borderColor string color name defined in Color.lua
function AW.CreateBorderedFrame(parent, title, width, height, color, borderColor)
    color = color or "background"
    borderColor = borderColor or "border"

    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(f)})
    f:SetBackdropColor(AW.GetColorRGB(color))
    f:SetBackdropBorderColor(AW.GetColorRGB(borderColor))

    AW.SetSize(f, width, height)

    if title then
        f.title = AW.CreateFontString(f, title, "accent", "accent_title")
        AW.SetPoint(f.title, "BOTTOMLEFT", f, "TOPLEFT", 2, 2)
    end

    function f:UpdatePixels()
        AW.ReSize(f)
        AW.RePoint(f)
        AW.ReBorder(f)
        if f.title then
            AW.RePoint(f.title)
        end
    end

    AW.AddToPixelUpdater(f)

    return f
end

---------------------------------------------------------------------
-- scroll frame
---------------------------------------------------------------------