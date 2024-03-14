local addonName, ns = ...
local L = ns.L
local AW = ns.AW

local MOVER_PARENT_FRAME_LEVEL = 700
local MOVER_ON_TOP_FRAME_LEVEL = 777
local FINE_TUNING_FRAME_LEVEL = 800
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
-- fine-tuning frame
---------------------------------------------------------------------
local fineTuningFrame
local AnchorFineTuningFrame, UpdateAndSave, UpdateFineTuningFrame

local function CreateFineTuningFrame()
    fineTuningFrame = AW.CreateBorderedFrame(moverParent, nil, nil, nil, "accent")
    fineTuningFrame:SetFrameLevel(FINE_TUNING_FRAME_LEVEL)
    fineTuningFrame:EnableMouse(true)
    fineTuningFrame:SetClampedToScreen(true)
    AW.SetSize(fineTuningFrame, 200, 91)
    fineTuningFrame:Hide()

    -- title
    fineTuningFrame.tp = AW.CreateTitledPane(fineTuningFrame, "")
    AW.SetPoint(fineTuningFrame.tp, "TOPLEFT", 7, -7)
    AW.SetPoint(fineTuningFrame.tp, "BOTTOMRIGHT", -7, 7)

    -- anchor
    fineTuningFrame.anchor = AW.CreateTexture(fineTuningFrame.tp, AW.GetIcon("Anchor_BOTTOMLEFT", true))
    AW.SetSize(fineTuningFrame.anchor, 18, 18)
    AW.SetPoint(fineTuningFrame.anchor, "TOPLEFT", 0, -30)
    
    -- x
    fineTuningFrame.x = AW.CreateEditBox(fineTuningFrame.tp, "", 60, 20)
    AW.SetPoint(fineTuningFrame.x, "LEFT", fineTuningFrame.anchor, "RIGHT", 20, 0)
    
    local x = AW.CreateFontString(fineTuningFrame.tp, "X", "accent")
    AW.SetPoint(x, "RIGHT", fineTuningFrame.x, "LEFT", -2, 0)
    
    -- y
    fineTuningFrame.y = AW.CreateEditBox(fineTuningFrame.tp, "", 60, 20)
    AW.SetPoint(fineTuningFrame.y, "BOTTOM", fineTuningFrame.x)
    AW.SetPoint(fineTuningFrame.y, "RIGHT")
    
    local y = AW.CreateFontString(fineTuningFrame.tp, "Y", "accent")
    AW.SetPoint(y, "RIGHT", fineTuningFrame.y, "LEFT", -2, 0)
    
    -- edit x
    fineTuningFrame.x:SetOnEditFocusGained(function()
        fineTuningFrame._x = fineTuningFrame.x:GetNumber()
    end)
    fineTuningFrame.x:SetOnEditFocusLost(function()
        fineTuningFrame.x:SetText(fineTuningFrame._x)
    end)
    fineTuningFrame.x:SetOnEnterPressed(function(text)
        local v = tonumber(text)
        if v then
            fineTuningFrame._x = v

            local owner = fineTuningFrame.owner
            local _p, _, _, _x, _y = owner:GetPoint()
            
            -- validate
            local mv = AW.UIParent:GetRight() - owner:GetWidth()
            if strfind(_p, "LEFT$") then
                v = max(v, 0)
                v = min(v, mv)
            elseif strfind(_p, "RIGHT$") then
                v = max(-mv, v)
                v = min(v, 0)
            else
                v = max(v, -mv/2)
                v = min(v, mv/2)
            end

            owner:ClearAllPoints()
            owner:SetPoint(_p, v, _y)

            UpdateAndSave(owner, CalcPoint(owner.mover))
            AnchorFineTuningFrame(owner)
        end
    end)
    
    -- edit y
    fineTuningFrame.y:SetOnEditFocusGained(function()
        fineTuningFrame._y = fineTuningFrame.y:GetNumber()
    end)
    fineTuningFrame.y:SetOnEditFocusLost(function()
        fineTuningFrame.y:SetText(fineTuningFrame._y)
    end)
    fineTuningFrame.y:SetOnEnterPressed(function(text)
        local v = tonumber(text)
        if v then
            fineTuningFrame._y = v

            local owner = fineTuningFrame.owner
            local _p, _, _, _x, _y = owner:GetPoint()

            -- validate
            local mv = AW.UIParent:GetTop() - owner:GetHeight()
            if strfind(_p, "^BOTTOM") then
                v = max(v, 0)
                v = min(v, mv)
            elseif strfind(_p, "^TOP") then
                v = max(-mv, v)
                v = min(v, 0)
            else
                v = max(v, -mv/2)
                v = min(v, mv/2)
            end
            
            owner:ClearAllPoints()
            owner:SetPoint(_p, _x, v)

            UpdateAndSave(owner, CalcPoint(owner.mover))
            AnchorFineTuningFrame(owner)
        end
    end)

    -- restore previous
    fineTuningFrame.restore = AW.CreateButton(fineTuningFrame.tp, L and L["Restore"] or "Restore", "accent", 17, 17)
    fineTuningFrame.restore:SetEnabled(false)
    AW.SetPoint(fineTuningFrame.restore, "BOTTOMLEFT")
    AW.SetPoint(fineTuningFrame.restore, "BOTTOMRIGHT")
    fineTuningFrame.restore:SetScript("OnClick", function()
        fineTuningFrame.restore:SetEnabled(false)
        local owner = fineTuningFrame.owner
        UpdateAndSave(owner, unpack(owner.mover._original))
        AnchorFineTuningFrame(owner)
    end)
end

UpdateFineTuningFrame = function(owner)
    if not (fineTuningFrame and fineTuningFrame:IsShown()) then return end
    
    fineTuningFrame.tp:SetTitle(owner.mover.text:GetText())

    local p, _, _, x, y = owner:GetPoint()
    x = Round(x)
    y = Round(y)

    fineTuningFrame.x:ClearFocus()
    fineTuningFrame.y:ClearFocus()

    fineTuningFrame.anchor:SetTexture(AW.GetIcon("Anchor_"..p, true))
    fineTuningFrame.x:SetText(x)
    fineTuningFrame.y:SetText(y)

    if owner.mover._original and (owner.mover._original[1] ~= p or owner.mover._original[2] ~= x or owner.mover._original[3] ~= y) then
        fineTuningFrame.restore:SetEnabled(true)
    else
        fineTuningFrame.restore:SetEnabled(false)
    end
end

AnchorFineTuningFrame = function(owner)
    if not (fineTuningFrame and fineTuningFrame:IsShown()) then return end

    fineTuningFrame.owner = owner

    local centerX, centerY = AW.UIParent:GetCenter()
    local width = AW.UIParent:GetRight()
    local x, y = owner.mover:GetCenter()
    
    local point, relativePoint

    if x >= (width * 2 / 3) then 
        point, relativePoint = "RIGHT", "LEFT"
        x, y = -1, 0
    elseif x <= (width / 3) then
        point, relativePoint = "LEFT", "RIGHT"
        x, y = 1, 0
    else
        if y >= centerY then
            point, relativePoint = "TOP", "BOTTOM"
            x, y = 0, -1
        else
            point, relativePoint = "BOTTOM", "TOP"
            x, y = 0, 1
        end
    end

    AW.ClearPoints(fineTuningFrame)
    AW.SetPoint(fineTuningFrame, point, owner.mover, relativePoint, x, y)

    UpdateFineTuningFrame(owner)
end

local function ToggleFineTuningFrame(owner)
    if not fineTuningFrame then CreateFineTuningFrame() end

    if fineTuningFrame:IsShown() then
        fineTuningFrame:Hide()
        fineTuningFrame.owner = nil
    else
        fineTuningFrame:Show()
        AnchorFineTuningFrame(owner)
    end
end

---------------------------------------------------------------------
-- restore
---------------------------------------------------------------------
UpdateAndSave = function(owner, p, x, y)
    -- update ._points
    owner._useOriginalPoints = true
    owner._points = {}
    owner._points[p] = {p, AW.UIParent, p, x, y}
    AW.RePoint(owner)

    -- save position
    if owner.mover.save then
        owner.mover.save(p, x, y)
    end
end

---------------------------------------------------------------------
-- stop moving
---------------------------------------------------------------------
local function StopMoving(owner)
    owner:SetScript("OnUpdate", nil)
    if owner.mover.moved then
        owner.mover.moved = nil

        -- calc new point
        local p, x, y = CalcPoint(owner.mover)
        UpdateAndSave(owner, p, x, y)
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
    mover:SetBackdropColor(AW.GetColorRGB("background", 0.75))

    owner.mover = mover
    mover.owner = owner
    mover.save = save

    if not movers[group] then movers[group] = {} end
    tinsert(movers[group], mover)
    
    mover:SetAllPoints(owner)
    mover:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
    mover:EnableMouse(true)
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
            owner:ClearAllPoints()
            owner:SetPoint(point, newX, newY)
            mover.moved = true

            AnchorFineTuningFrame(owner)
        end)
    end)

    mover:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            ToggleFineTuningFrame(owner)
        end

        if button ~= "LeftButton" then return end
        mover.isDragging = nil
        owner:SetScript("OnUpdate", nil)
        StopMoving(owner)

        -- update fine tuning
        UpdateFineTuningFrame(owner)
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

        StopMoving(owner)

        -- update fine tuning
        UpdateFineTuningFrame(owner)
    end)
    
    mover:SetScript("OnEnter", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                if m == mover then
                    m.text:SetColor("white")
                    m:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
                    AW.FrameFadeIn(m, 0.25)
                elseif m:IsShown() then
                    m.text:SetColor("accent")
                    AW.FrameFadeOut(m, 0.25, nil, 0.5)
                end
            end
        end
        
        AnchorFineTuningFrame(owner)
    end)
    
    mover:SetScript("onLeave", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                if m:IsShown() then
                    m.text:SetColor("accent")
                    m:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
                    AW.FrameFadeIn(m, 0.25)
                end
            end
        end
    end)

    mover:SetScript("OnShow", function()
        if not mover._original then
            local p, _, _, x, y = owner:GetPoint()
            mover._original = {p, Round(x), Round(y)}
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
    if fineTuningFrame then fineTuningFrame:Hide() end
end

function AW.HideMovers()
    if not moverParent then return end
    
    for _, g in pairs(movers) do
        for _, m in pairs(g) do
            m:Hide()
            m._original = nil
        end
    end
    moverParent:Hide()
    if fineTuningFrame then fineTuningFrame:Hide() end
end

function AW.UndoMovers()
    if not moverParent:IsShown() then return end

    for _, g in pairs(movers) do
        for _, m in pairs(g) do
            if m._original then
                UpdateAndSave(m.owner, m._original[1], m._original[2], m._original[3])
            end
        end
    end
    if fineTuningFrame then fineTuningFrame:Hide() end
end