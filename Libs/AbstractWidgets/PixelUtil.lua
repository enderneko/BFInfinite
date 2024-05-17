local addonName, ns = ...
local AW = ns.AW

-- Interface\SharedXML\PixelUtil.lua
---------------------------------------------------------------------
-- pixel perfect
---------------------------------------------------------------------
function AW.GetPixelFactor()
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    return 768.0 / physicalHeight
end

function AW.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)
    if uiUnitSize == 0 and (not minPixels or minPixels == 0) then
        return 0
    end

    local uiUnitFactor = AW.GetPixelFactor()
    local numPixels = Round((uiUnitSize * layoutScale) / uiUnitFactor)
    if minPixels then
        if uiUnitSize < 0.0 then
            if numPixels > -minPixels then
                numPixels = -minPixels
            end
        else
            if numPixels < minPixels then
                numPixels = minPixels
            end
        end
    end

    return numPixels * uiUnitFactor / layoutScale
end

function AW.ConvertPixels(desiredPixels, layoutScale)
    return AW.GetNearestPixelSize(desiredPixels, layoutScale)
end

function AW.ConvertPixelsForRegion(desiredPixels, region)
    return AW.GetNearestPixelSize(desiredPixels, region:GetEffectiveScale())
end

---------------------------------------------------------------------
-- 1 pixel
---------------------------------------------------------------------
function AW.GetOnePixelForRegion(region)
    return AW.GetNearestPixelSize(1, region:GetEffectiveScale())
end

---------------------------------------------------------------------
-- size
---------------------------------------------------------------------
function AW.SetWidth(region, width, minPixels)
    -- clear conflicts
    region._itemNum = nil
    region._itemWidth = nil
    region._itemSpacing = nil
    region._extraWidth = nil
    -- add new
    region._width = width
    region._minwidth = minPixels
    region:SetWidth(AW.GetNearestPixelSize(width, region:GetEffectiveScale(), minPixels))
end

function AW.SetHeight(region, height, minPixels)
    -- clear conflicts
    region._itemNum = nil
    region._itemHeight = nil
    region._itemSpacing = nil
    region._extraHeight = nil
    -- add new
    region._height = height
    region._minheight = minPixels
    region:SetHeight(AW.GetNearestPixelSize(height, region:GetEffectiveScale(), minPixels))
end

-- NOTE: DO NOT USE WITH SetListHeight
function AW.SetListWidth(region, itemNum, itemWidth, itemSpacing, extraWidth)
    -- clear old
    region._width = nil
    region._minwidth = nil
    -- add new
    region._itemNum = itemNum
    region._itemWidth = itemWidth
    region._itemSpacing = itemSpacing
    extraWidth = extraWidth or 0
    region._extraWidth = extraWidth
    region:SetWidth(AW.GetNearestPixelSize(itemWidth, region:GetEffectiveScale())*itemNum
        + AW.GetNearestPixelSize(itemSpacing, region:GetEffectiveScale())*(itemNum-1)
        + AW.GetNearestPixelSize(extraWidth, region:GetEffectiveScale()))
end

-- NOTE: DO NOT USE WITH SetListWidth
function AW.SetListHeight(region, itemNum, itemHeight, itemSpacing, extraHeight)
    -- clear conflicts
    region._height = nil
    region._minheight = nil
    -- add new
    region._itemNum = itemNum
    region._itemHeight = itemHeight
    region._itemSpacing = itemSpacing
    extraHeight = extraHeight or 0
    region._extraHeight = extraHeight
    region:SetHeight(AW.GetNearestPixelSize(itemHeight, region:GetEffectiveScale())*itemNum
        + AW.GetNearestPixelSize(itemSpacing, region:GetEffectiveScale())*(itemNum-1)
        + AW.GetNearestPixelSize(extraHeight, region:GetEffectiveScale()))
end

function AW.SetSize(region, width, height)
    height = height or width
    if width then AW.SetWidth(region, width) end
    if height then AW.SetHeight(region, height) end
end

---------------------------------------------------------------------
-- point
---------------------------------------------------------------------
function AW.SetPoint(region, ...)
    if not region._points then region._points = {} end
    local point, relativeTo, relativePoint, offsetX, offsetY
    
    local n = select("#", ...)
    if n == 1 then
        point = ...
    elseif n == 3 then
        if type(select(2, ...)) == "number" then -- "TOPLEFT", 0, 0
            point, offsetX, offsetY = ...
        else -- "TOPLEFT", AW.UIParent, "TOPRIGHT"
            point, relativeTo, relativePoint = ...
        end
    elseif n == 4 then
        point, relativeTo, offsetX, offsetY = ...
    else
        point, relativeTo, relativePoint, offsetX, offsetY = ...
    end

    offsetX = offsetX and offsetX or 0
    offsetY = offsetY and offsetY or 0

    local points = {point, relativeTo or region:GetParent(), relativePoint or point, offsetX, offsetY}
    region._points[point] = points

    if region._useOriginalPoints then
        region:SetPoint(points[1], points[2], points[3], points[4], points[5])
    else
        region:SetPoint(points[1], points[2], points[3], AW.GetNearestPixelSize(points[4], region:GetEffectiveScale()), AW.GetNearestPixelSize(points[5], region:GetEffectiveScale()))
    end
end

function AW.SetOnePixelInside(region, relativeTo)
    AW.ClearPoints(region)
    AW.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", 1, -1)
    AW.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -1, 1)
end

function AW.SetOnePixelOutside(region, relativeTo)
    AW.ClearPoints(region)
    AW.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", -1, 1)
    AW.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", 1, -1)
end

function AW.SetInside(region, relativeTo, x, y)
    AW.ClearPoints(region)
    AW.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", x, -y)
    AW.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -x, y)
end

function AW.SetOutside(region, relativeTo, x, y)
    AW.ClearPoints(region)
    AW.SetPoint(region, "TOPLEFT", relativeTo, "TOPLEFT", -x, y)
    AW.SetPoint(region, "BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", x, -y)
end

function AW.ClearPoints(region)
    region:ClearAllPoints()
    if region._points then wipe(region._points) end
end

---------------------------------------------------------------------
-- re-set
---------------------------------------------------------------------
function AW.ReSize(region)
    if region._width then
        region:SetWidth(AW.GetNearestPixelSize(region._width, region:GetEffectiveScale(), region._minwidth))
    end
    if region._height then
        region:SetHeight(AW.GetNearestPixelSize(region._height, region:GetEffectiveScale(), region._minheight))
    end
    if region._itemWidth then
        AW.SetListWidth(region, region._itemNum, region._itemWidth, region._itemSpacing, region._extraWidth)
    end
    if region._itemHeight then
        AW.SetListHeight(region, region._itemNum, region._itemHeight, region._itemSpacing, region._extraHeight)
    end
end

local function IsEmpty(t)
    if not t then return true end
    for _ in pairs(t) do
        return false
    end
    return true
end

function AW.RePoint(region)
    if IsEmpty(region._points) then return end
    region:ClearAllPoints()
    for _, t in pairs(region._points) do
        local x, y
        if region._useOriginalPoints then
            x = t[4]
            y = t[5]
        else
            x = AW.ConvertPixelsForRegion(t[4], region)
            y = AW.ConvertPixelsForRegion(t[5], region)
        end
        region:SetPoint(t[1], t[2], t[3], x, y)
    end
end

function AW.ReBorder(region)
    local backdropInfo = region:GetBackdrop()
    if not backdropInfo then return end

    local r, g, b, a = region:GetBackdropColor()
    local br, bg, bb, ba = region:GetBackdropBorderColor()

    local n = AW.GetOnePixelForRegion(region)
    if backdropInfo.edgeSize then
        backdropInfo.edgeSize = n
    end
    if backdropInfo.insets then
        backdropInfo.insets.left = n
        backdropInfo.insets.right = n
        backdropInfo.insets.top = n
        backdropInfo.insets.bottom = n
    end

    region:SetBackdrop(backdropInfo)
    region:SetBackdropColor(r, g, b, a)
    region:SetBackdropBorderColor(br, bg, bb, ba)
end

---------------------------------------------------------------------
-- pixel updater
---------------------------------------------------------------------
local function DefaultUpdatePixels(self)
    AW.ReSize(self)
    AW.RePoint(self)
    AW.ReBorder(self)
end

local regions = {}
function AW.AddToPixelUpdater(r)
    if not r.UpdatePixels then
        r.UpdatePixels = DefaultUpdatePixels
    end
    tinsert(regions, r)
end

function AW.RemoveFromPixelUpdater(r)
    for i, _r in ipairs(r) do
        if r == _r then
            tremove(regions, i)
            break    
        end
    end
end

function AW.UpdatePixels()
    for _, r in ipairs(regions) do
        r:UpdatePixels() 
    end
end

---------------------------------------------------------------------
-- pixel perfect point
---------------------------------------------------------------------
function AW.PixelPerfectPoint(region)
    local left = Round(region:GetLeft())
    local bottom = Round(region:GetBottom())
    AW.ClearPoints(region)
    AW.SetPoint(region, "BOTTOMLEFT", left, bottom)
end

---------------------------------------------------------------------
-- statusbar
---------------------------------------------------------------------
function AW.SetStatusBarValue(statusBar, value)
    local width = statusBar:GetWidth()
    if width and width > 0.0 then
        local min, max = statusBar:GetMinMaxValues()
        local percent = ClampedPercentageBetween(value, min, max)
        if percent == 0.0 or percent == 1.0 then
            statusBar:SetValue(value)
        else
            local numPixels = AW.GetNearestPixelSize(statusBar:GetWidth() * percent, statusBar:GetEffectiveScale())
            local roundedValue = Lerp(min, max, numPixels / width)
            statusBar:SetValue(roundedValue)
        end
    else
        statusBar:SetValue(value)
    end
end

---------------------------------------------------------------------
-- load widget position
---------------------------------------------------------------------
function AW.LoadWidgetPosition(region, pos, relativeTo)
    AW.ClearPoints(region)
    AW.SetPoint(region, pos[1], relativeTo or region:GetParent(), pos[2], pos[3], pos[4])
end

---------------------------------------------------------------------
-- load position
---------------------------------------------------------------------
--- @param pos table|string
function AW.LoadPosition(region, pos)
    region._useOriginalPoints = true
    AW.ClearPoints(region)
    if type(pos) == "string" then
        pos = string.gsub(pos, " ", "")
        local p, x, y = strsplit(",", pos)
        x = tonumber(x)
        y = tonumber(y)
        AW.SetPoint(region, p, x, y)
    elseif type(pos) == "table" then
        AW.SetPoint(region, unpack(pos))
    end
end

---------------------------------------------------------------------
-- save position
---------------------------------------------------------------------
function AW.SavePositionAsTable(region, t)
    wipe(t)
    t[1], t[2], t[3], t[4], t[5] = region:GetPoint()
end

function AW.SavePositionAsString(region, t, i)
    t[i] = table.concat({region:GetPoint()}, ",")
end

---------------------------------------------------------------------
-- pixel perfect (ElvUI)
---------------------------------------------------------------------
local function CheckPixelSnap(frame, snap)
    if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
        frame.PixelSnapDisabled = nil
    end
end

local function DisablePixelSnap(frame)
    if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
        if frame.SetSnapToPixelGrid then
            frame:SetSnapToPixelGrid(false)
            frame:SetTexelSnappingBias(0)
            frame.PixelSnapDisabled = true
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if type(texture) == "table" and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
                frame.PixelSnapDisabled = true
            end
        end
    end
end

local function UpdateMetatable(obj)
    local t = getmetatable(obj).__index

    if not obj.DisabledPixelSnap and (t.SetSnapToPixelGrid or t.SetStatusBarTexture or t.SetColorTexture or t.SetVertexColor or t.CreateTexture or t.SetTexCoord or t.SetTexture) then
        if t.SetSnapToPixelGrid then hooksecurefunc(t, "SetSnapToPixelGrid", CheckPixelSnap) end
        if t.SetStatusBarTexture then hooksecurefunc(t, "SetStatusBarTexture", DisablePixelSnap) end
        if t.SetColorTexture then hooksecurefunc(t, "SetColorTexture", DisablePixelSnap) end
        if t.SetVertexColor then hooksecurefunc(t, "SetVertexColor", DisablePixelSnap) end
        if t.CreateTexture then hooksecurefunc(t, "CreateTexture", DisablePixelSnap) end
        if t.SetTexCoord then hooksecurefunc(t, "SetTexCoord", DisablePixelSnap) end
        if t.SetTexture then hooksecurefunc(t, "SetTexture", DisablePixelSnap) end

        t.DisabledPixelSnap = true
    end
end

local obj = CreateFrame("Frame")
UpdateMetatable(CreateFrame("StatusBar"))
UpdateMetatable(obj:CreateTexture())
UpdateMetatable(obj:CreateMaskTexture())

local handled = {Frame = true}
obj = EnumerateFrames()
while obj do
    local objType = obj:GetObjectType()
    if not obj:IsForbidden() and not handled[objType] then
        UpdateMetatable(obj)
        handled[objType] = true
    end
    obj = EnumerateFrames(obj)
end