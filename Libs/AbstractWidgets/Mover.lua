local addonName, ns = ...
local AW = ns.AW

local MOVER_PARENT_FRAME_LEVEL = 700
local MOVER_ON_TOP_FRAME_LEVEL = 777
local movers = {}

---------------------------------------------------------------------
-- parent
---------------------------------------------------------------------
local moverParent, alignmentGrid

local function CreateLine(color, alpha, x, y, w, h, subLevel)
    local l = AW.CreateTexture(alignmentGrid, nil, AW.GetColorTable(color, alpha), "BACKGROUND", subLevel or 0, nil, nil, "NEAREST")
    AW.SetSize(l, w, h)
    AW.SetPoint(l, "BOTTOMLEFT", x, y)
    return l
end

-- local function CreateLine2(color, alpha, x1, y1, x2, y2)
--     local l = alignmentGrid:CreateLine(nil, "BACKGROUND")
--     l:SetThickness(1)
--     l:SetColorTexture(AW.GetColorRGB(color, alpha))
--     l:SetStartPoint("BOTTOMLEFT", x1, y1)
--     l:SetEndPoint("BOTTOMLEFT", x2, y2)
--     return l
-- end

local function CreateAlignmentGrid()
    alignmentGrid = CreateFrame("Frame", strupper(ns.prefix).."AlignmentGrid", moverParent)
    alignmentGrid:SetFrameStrata("BACKGROUND")
    -- alignmentGrid:SetBackdrop({bgFile=AW.GetPlainTexture()})
    -- alignmentGrid:SetBackdropColor(AW.GetColorRGB("disabled", 0)) -- for user customization?
    alignmentGrid:SetAllPoints(moverParent)
    alignmentGrid:SetIgnoreParentScale(true)
    alignmentGrid:SetScale(AW.GetPixelFactor())

    -- re-create if DISPLAY_SIZE_CHANGED
    alignmentGrid:RegisterEvent("DISPLAY_SIZE_CHANGED")
    alignmentGrid:SetScript("OnEvent", function()
        alignmentGrid:Hide()
        alignmentGrid:SetParent(nil)
        alignmentGrid:ClearAllPoints()
        -- re-create
        CreateAlignmentGrid()
    end)

    local width, height = GetPhysicalScreenSize()

    -- center cross
    local centerX = math.floor((width-1) / 2)
    local centerY = math.floor((height-1) / 2)
    
    -- v center
    CreateLine("red", 0.75, centerX, 0, 1, height, 1)
    
    -- h center
    CreateLine("red", 0.75, 0, centerY, width, 1, 1)
    
    -- vleft
    local offset = centerX
    repeat
        offset = offset - 25
        CreateLine("black", 0.35, offset, 0, 1, height)
    until offset < 0
    
    -- vright
    offset = centerX
    repeat
        offset = offset + 25
        CreateLine("black", 0.35, offset, 0, 1, height)
    until offset > width

    -- hbottom
    local offset = centerY
    repeat
        offset = offset - 25
        CreateLine("black", 0.35, 0, offset, width, 1)
    until offset < 0
    
    -- htop
    offset = centerY
    repeat
        offset = offset + 25
        CreateLine("black", 0.35, 0, offset, width, 1)
    until offset > height
end

local function CreateMoverParent()
    moverParent = CreateFrame("Frame", strupper(ns.prefix).."MoverParent", AW.UIParent)
    moverParent:SetFrameStrata("FULLSCREEN")
    moverParent:SetFrameLevel(MOVER_PARENT_FRAME_LEVEL)
    moverParent:SetAllPoints(AW.UIParent)
    moverParent:Hide()

    moverParent.textOverlay = CreateFrame("Frame", nil, moverParent)
    moverParent.textOverlay:SetAllPoints()
    moverParent.textOverlay:SetFrameLevel(150)

    -- hide in combat
    moverParent:RegisterEvent("PLAYER_REGEN_DISABLED")
    moverParent:SetScript("OnEvent", function()
        AW.HideMovers()
    end)

    CreateAlignmentGrid()
end

---------------------------------------------------------------------
-- calc new point
---------------------------------------------------------------------
local function CalcPoint(mover)
    local centerX, centerY = AW.UIParent:GetCenter()
    local width = AW.UIParent:GetRight()
    local x, y = mover:GetCenter()
    
    local point
    if y >= centerY then
        point = "TOP"
        y = -(AW.UIParent:GetTop() - mover:GetTop())
    else
        point = "BOTTOM"
        y = mover:GetBottom()
    end

    if x >= (width * 2 / 3) then 
        point = point.."RIGHT"
        x = mover:GetRight() - width
    elseif x <= (width / 3) then
        point = point.."LEFT"
        x = mover:GetLeft()
    else
        x = x - centerX
    end

    -- x = tonumber(string.format("%.2f", x))
    -- y = tonumber(string.format("%.2f", y))
    x = Round(x)
    y = Round(y)

    return point, x, y
end

---------------------------------------------------------------------
-- stop moving
---------------------------------------------------------------------
--- @param save function
local function StopMoving(region, save)
    region:SetScript("OnUpdate", nil)
    if region.mover.moved then
        region.mover.moved = nil

        -- calc new point
        local p, x, y = CalcPoint(region.mover)
        region:ClearAllPoints()
        region:SetPoint(p, x, y)

        -- update ._points
        region._useOriginalPoints = true
        region._points = {}
        region._points[p] = {p, AW.UIParent, p, x, y}
        
        -- save position
        if save then
            save(p, x, y)
        end
    end
end

---------------------------------------------------------------------
-- create mover
---------------------------------------------------------------------
--- @param save function
function AW.CreateMover(owner, group, text, save)
    assert(owner:GetNumPoints() == 1, "mover owner must have 1 anchor point")
    assert(owner:GetParent() == AW.UIParent, "owner must be the direct child of AW.UIParent")

    if not moverParent then CreateMoverParent() end

    local mover = AW.CreateBorderedFrame(moverParent, nil, nil, nil, "accent")
    owner.mover = mover
    mover:SetBackdropColor(AW.GetColorRGB("background", 0.75))

    if not movers[group] then movers[group] = {} end
    tinsert(movers[group], mover)
    
    mover:SetAllPoints(owner)
    mover:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
    mover:EnableMouse(true)
    mover:SetClampedToScreen(true)
    mover:Hide()

    mover.text = AW.CreateFontString(mover, text,  nil, "accent_outline", nil, "OVERLAY")
    mover.text:SetPoint("CENTER")
    mover.text:SetText(text)

    mover:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        mover.isDragging = true

        local scale = owner:GetEffectiveScale()
        local mouseX, mouseY = GetCursorPosition()
        
        local start, minX, maxX, minY, maxY
        
        local point, _, _, startX, startY = owner:GetPoint()

        if strfind(point, "^BOTTOM") then
            minY = 0
            maxY = AW.UIParent:GetHeight()-owner:GetHeight()
        elseif strfind(point, "^TOP") then
            minY = -(AW.UIParent:GetHeight()-owner:GetHeight())
            maxY = 0
        else -- LEFT/RIGHT/CENTER
            minY = -((AW.UIParent:GetHeight()-owner:GetHeight())/2)
            maxY = (AW.UIParent:GetHeight()-owner:GetHeight())/2
        end
        
        if strfind(point, "LEFT$") then
            minX = 0
            maxX = AW.UIParent:GetWidth()-owner:GetWidth()
        elseif strfind(point, "RIGHT$") then
            minX = -(AW.UIParent:GetWidth()-owner:GetWidth())
            maxX = 0
        else -- TOP/BOTTOM/CENTER
            minX = -((AW.UIParent:GetWidth()-owner:GetWidth())/2)
            maxX = (AW.UIParent:GetWidth()-owner:GetWidth())/2
        end

        local lastX = mouseX
        local lastY = mouseY

        owner:SetScript("OnUpdate", function()
            local newMouseX, newMouseY = GetCursorPosition()
            if newMouseX == lastX and newMouseY == lastY then return end
            
            lastX = newMouseX
            lastY = newMouseY

            local newX = startX + (newMouseX - mouseX) / scale
            newX = max(newX, minX)
            newX = min(newX, maxX)

            local newY = startY + (newMouseY - mouseY) / scale
            newY = max(newY, minY)
            newY = min(newY, maxY)

            -- print(newX, newY)

            owner:SetPoint(point, newX, newY)
            mover.moved = true
        end)
    end)

    mover:SetScript("OnMouseUp", function()
        mover.isDragging = nil
        owner:SetScript("OnUpdate", nil)
        StopMoving(owner, save)
    end)

    mover:SetScript("OnMouseWheel", function(self, delta)
        if mover.isDragging then return end

        local point, _, _, startX, startY = owner:GetPoint()
        startX = Round(startX)
        startY = Round(startY)

        mover.moved = true
        
        if delta == 1 then
            if IsShiftKeyDown() then
                -- move right
                owner:SetPoint(point, startX + 1, startY)
            else
                -- move up
                owner:SetPoint(point, startX, startY + 1)
            end
        else
            if IsShiftKeyDown() then
                -- move left
                owner:SetPoint(point, startX - 1, startY)
            else
                -- move down
                owner:SetPoint(point, startX, startY - 1)
            end
        end

        StopMoving(owner, save)
    end)
    
    mover:SetScript("OnEnter", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                if m == mover then
                    m.text:SetColor("white")
                    m:SetFrameLevel(888)
                    AW.FrameFadeIn(m, 0.25)
                else
                    m.text:SetColor("accent")
                    AW.FrameFadeOut(m, 0.25, nil, 0.5)
                end
            end
        end
    end)
    
    mover:SetScript("onLeave", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                m.text:SetColor("accent")
                m:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
                AW.FrameFadeIn(m, 0.25)
            end
        end
    end)
end

---------------------------------------------------------------------
-- toggle movers
---------------------------------------------------------------------
function AW.ShowMovers(group)
    if not moverParent then CreateMoverParent() end

    for g, gt in pairs(movers) do
        local show
        if not group then
            show = true
        else
            show = group == g
        end
        for _, m in pairs(gt) do
            if show then m:Show() else m:Hide() end
        end
    end
    moverParent:Show()
end

function AW.HideMovers()
    if not moverParent then return end

    for _, g in pairs(movers) do
        for _, m in pairs(g) do
            m:Hide()
        end
    end
    moverParent:Hide()
end