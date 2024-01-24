local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- style
---------------------------------------------------------------------
--- @param color string|table color name defined in Color.lua or color table
--- @param borderColor string|table color name defined in Color.lua or color table
function AW.StylizeFrame(frame, color, borderColor)
    color = color or "background"
    borderColor = borderColor or "border"

    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=AW.GetOnePixelForRegion(frame)})
    if type(color) == "string" then
        frame:SetBackdropColor(AW.GetColorRGB(color))
    else
        frame:SetBackdropColor(unpack(color))
    end
    if type(borderColor) == "string" then
        frame:SetBackdropBorderColor(AW.GetColorRGB(borderColor))
    else
        frame:SetBackdropBorderColor(unpack(borderColor))
    end
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
-- titled pane
---------------------------------------------------------------------
--- @param color string color name defined in Color.lua
function AW.CreateTitledPane(parent, title, width, height, color)
    color = color or "accent"

    local pane = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    AW.SetSize(pane, width, height)

    -- underline
    local line = pane:CreateTexture()
    pane.line = line
    line:SetColorTexture(AW.GetColorRGB(color, 0.8))
    AW.SetHeight(line, 1)
    AW.SetPoint(line, "TOPLEFT", pane, 0, -17)
    AW.SetPoint(line, "TOPRIGHT", pane, 0, -17)
    
    local shadow = pane:CreateTexture()
    AW.SetHeight(shadow, 1)
    shadow:SetColorTexture(0, 0, 0, 1)
    AW.SetPoint(shadow, "TOPLEFT", line, 1, -1)
    AW.SetPoint(shadow, "TOPRIGHT", line, 1, -1)

    -- title
    local text = AW.CreateFontString(pane, title, "accent")
    pane.title = text
    text:SetJustifyH("LEFT")
    AW.SetPoint(text, "BOTTOMLEFT", line, "TOPLEFT", 0, 2)

    function pane:SetTitle(t)
        text:SetText(t)
    end

    function pane:UpdatePixels()
        AW.ReSize(pane)
        AW.RePoint(pane)
        AW.ReSize(line)
        AW.RePoint(line)
        AW.ReSize(shadow)
        AW.RePoint(shadow)
        AW.RePoint(text)
    end

    AW.AddToPixelUpdater(pane)

    return pane
end

---------------------------------------------------------------------
-- scroll frame
---------------------------------------------------------------------
function AW.CreateScrollFrame(parent, width, height, color, borderColor)
    local scrollParent = AW.CreateBorderedFrame(parent, nil, width, height, color, borderColor)

    local scrollFrame = CreateFrame("ScrollFrame", nil, scrollParent)
    scrollParent.scrollFrame = scrollFrame
    AW.SetPoint(scrollFrame, "TOPLEFT")
    AW.SetPoint(scrollFrame, "BOTTOMRIGHT")

    -- content
    local content = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    scrollParent.scrollContent = content
    AW.SetSize(content, width, 5)
    scrollFrame:SetScrollChild(content)
    -- AW.SetPoint(content, "RIGHT") -- update width with scrollFrame
    
    -- scrollBar
    local scrollBar = CreateFrame("Frame", nil, scrollParent, "BackdropTemplate")
    scrollBar:Hide()
    AW.SetWidth(scrollBar, 5)
    AW.SetPoint(scrollBar, "TOPRIGHT")
    AW.SetPoint(scrollBar, "BOTTOMRIGHT")
    AW.StylizeFrame(scrollBar, color, borderColor)
    scrollParent.scrollBar = scrollBar
    
    -- scrollBar thumb
    local scrollThumb = CreateFrame("Frame", nil, scrollBar, "BackdropTemplate")
    AW.SetWidth(scrollThumb, 5)
    AW.SetPoint(scrollThumb, "TOP")
    AW.StylizeFrame(scrollThumb, AW.GetColorTable("accent", 0.8))
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)
    scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
    scrollParent.scrollThumb = scrollThumb
    
    -- reset content height (reset scroll range)
    function scrollParent:ResetHeight()
        AW.SetHeight(content, 5)
    end
    
    -- reset scroll to top
    function scrollParent:ResetScroll()
        scrollFrame:SetVerticalScroll(0)
    end
    
    -- scrollFrame:GetVerticalScrollRange may return 0
    function scrollFrame:GetVerticalScrollRange()
        local range = content:GetHeight() - scrollFrame:GetHeight()
        return range > 0 and range or 0
    end
    scrollParent.GetVerticalScrollRange = scrollFrame.GetVerticalScrollRange

    -- for mouse wheel
    function scrollParent:VerticalScroll(step)
        local scroll = scrollFrame:GetVerticalScroll() + step
        if scroll <= 0 then
            scrollFrame:SetVerticalScroll(0)
        elseif scroll >= scrollFrame:GetVerticalScrollRange() then
            scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
        else
            scrollFrame:SetVerticalScroll(scroll)
        end
    end

    -- NOTE: do not call this if not visible, GetVerticalScrollRange may not be valid.
    function scrollParent:ScrollToBottom()
        scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
    end

    function scrollParent:SetContentHeight(height, num, spacing)
        if num and spacing then
            AW.SetListHeight(content, height, num, spacing)
        else
            AW.SetHeight(content, height)
        end
    end

    function scrollParent:ClearContent()
        for _, c in pairs({content:GetChildren()}) do
            c:SetParent(nil)
            c:ClearAllPoints()
            c:Hide()
        end
        scrollParent:ResetHeight()
    end

    function scrollParent:Reset()
        scrollParent:ResetScroll()
        scrollParent:ClearContent()
    end
    
    -- on width changed (scrollBar show/hide)
    scrollFrame:SetScript("OnSizeChanged", function()
        -- update content width
        content:SetWidth(scrollFrame:GetWidth())
    end)

    -- check if it can scroll
    -- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
    -- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
    -- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)
    content:SetScript("OnSizeChanged", function()
        print("OnSizeChanged")
        -- set thumb height (%)
        local p = scrollFrame:GetHeight() / content:GetHeight()
        p = tonumber(string.format("%.3f", p))
        if p < 1 then -- can scroll
            scrollThumb:SetHeight(scrollBar:GetHeight()*p)
            -- space for scrollBar
            AW.SetPoint(scrollFrame, "BOTTOMRIGHT", -7, 0)
            scrollBar:Show()
        else
            AW.SetPoint(scrollFrame, "BOTTOMRIGHT")
            scrollBar:Hide()
            scrollFrame:SetVerticalScroll(0)
        end
    end)

    local function OnVerticalScroll(self, offset)
        if scrollFrame:GetVerticalScrollRange() ~= 0 then
            local scrollP = scrollFrame:GetVerticalScroll()/scrollFrame:GetVerticalScrollRange()
            local yoffset = -((scrollBar:GetHeight()-scrollThumb:GetHeight())*scrollP)
            scrollThumb:SetPoint("TOP", 0, yoffset)
        end
    end
    scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll)

    -- dragging and scrolling
    scrollThumb:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        scrollFrame:SetScript("OnVerticalScroll", nil) -- disable OnVerticalScroll

        local offsetY = select(5, scrollThumb:GetPoint(1))
        local mouseY = select(2, GetCursorPosition())
        local scale = scrollThumb:GetEffectiveScale() -- https://warcraft.wiki.gg/wiki/API_GetCursorPosition
        local currentScroll = scrollFrame:GetVerticalScroll()
        self:SetScript("OnUpdate", function(self)
            local newMouseY = select(2, GetCursorPosition())
            ------------------ y offset before dragging + mouse offset
            local newOffsetY = offsetY + (newMouseY - mouseY) / scale

            -- even scrollThumb:SetPoint is already done in OnVerticalScroll, but it's useful in some cases.
            if newOffsetY >= 0 then -- top
                AW.SetPoint(scrollThumb, "TOP")
                newOffsetY = 0
            elseif (-newOffsetY) + scrollThumb:GetHeight() >= scrollBar:GetHeight() then -- bottom
                AW.SetPoint(scrollThumb, "TOP", 0, -(scrollBar:GetHeight() - scrollThumb:GetHeight()))
                newOffsetY = -(scrollBar:GetHeight() - scrollThumb:GetHeight())
            else
                AW.SetPoint(scrollThumb, "TOP", 0, newOffsetY)
            end
            local vs = (-newOffsetY / (scrollBar:GetHeight()-scrollThumb:GetHeight())) * scrollFrame:GetVerticalScrollRange()
            scrollFrame:SetVerticalScroll(vs)
        end)
    end)

    scrollThumb:SetScript("OnMouseUp", function(self)
        scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll) -- enable OnVerticalScroll
        self:SetScript("OnUpdate", nil)
    end)

    local step = 25
    function scrollParent:SetScrollStep(s)
        step = s
    end
    
    -- enable mouse wheel scroll
    scrollParent:EnableMouseWheel(true)
    scrollParent:SetScript("OnMouseWheel", function(self, delta)
        if delta == 1 then -- scroll up
            scrollParent:VerticalScroll(AW.ConvertPixelsForRegion(-step, scrollFrame))
        elseif delta == -1 then -- scroll down
            scrollParent:VerticalScroll(AW.ConvertPixelsForRegion(step, scrollFrame))
        end
    end)

    function scrollParent:UpdatePixels()
        AW.ReSize(scrollParent)
        AW.RePoint(scrollParent)
        AW.ReBorder(scrollParent)

        AW.ReSize(scrollFrame)
        AW.RePoint(scrollFrame)
        content:SetWidth(scrollFrame:GetWidth())
        
        AW.ReSize(scrollBar)
        AW.RePoint(scrollBar)
        AW.ReBorder(scrollBar)
        
        AW.ReSize(scrollThumb)
        AW.RePoint(scrollThumb)
        AW.ReBorder(scrollThumb)
        
        -- NOTE: children should've been AddToPixelUpdater, so there's no need
        -- for _, c in pairs({content:GetChildren()}) do
        --     if c.UpdatePixels() then
        --         c:UpdatePixels()
        --     end
        -- end
        
        -- reset scroll
        scrollParent:ResetScroll()
    end

    AW.AddToPixelUpdater(scrollParent)
    
    return scrollParent
end