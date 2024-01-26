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
    region._width = width
    region._minwidth = minPixels
    region:SetWidth(AW.GetNearestPixelSize(width, region:GetEffectiveScale(), minPixels))
end

function AW.SetHeight(region, height, minPixels)
    region._height = height
    region._minheight = minPixels
    region:SetHeight(AW.GetNearestPixelSize(height, region:GetEffectiveScale(), minPixels))
end

function AW.SetListHeight(region, itemHeight, itemNum, itemSpacing)
    -- clear old
    region._height = nil
    region._minheight = nil
    -- add new
    region._itemHeight = itemHeight
    region._itemNum = itemNum
    region._itemSpacing = itemSpacing
    region:SetHeight(AW.GetNearestPixelSize(itemHeight, region:GetEffectiveScale())*itemNum + AW.GetNearestPixelSize(itemSpacing, region:GetEffectiveScale())*(itemNum-1))
end

function AW.SetSize(region, width, height, minWidthPixels, minHeightPixels)
    AW.SetWidth(region, width, minWidthPixels)
    AW.SetHeight(region, height, minHeightPixels)
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
        else -- "TOPLEFT", UIParent, "TOPRIGHT"
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
    region:SetPoint(points[1], points[2], points[3], AW.GetNearestPixelSize(points[4], region:GetEffectiveScale()), AW.GetNearestPixelSize(points[5], region:GetEffectiveScale()))
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
    if region._itemHeight then
        region:SetHeight(AW.GetNearestPixelSize(region._itemHeight, region:GetEffectiveScale())*region._itemNum + AW.GetNearestPixelSize(region._itemSpacing, region:GetEffectiveScale())*(region._itemNum-1))
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
        region:SetPoint(t[1], t[2], t[3], AW.GetNearestPixelSize(t[4], region:GetEffectiveScale()), AW.GetNearestPixelSize(t[5], region:GetEffectiveScale()))
    end
end

function AW.ReBorder(region)
    local r, g, b, a = region:GetBackdropColor()
    local br, bg, bb, ba = region:GetBackdropBorderColor()

    local n = AW.GetOnePixelForRegion(region)
    local backdropInfo = region:GetBackdrop()
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
local regions = {}
function AW.AddToPixelUpdater(r)
    assert(r.UpdatePixels, "no UpdatePixels() for this region")
    tinsert(regions, r)
end

function AW.UpdatePixels()
    for _, r in ipairs(regions) do
        r:UpdatePixels() 
    end
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