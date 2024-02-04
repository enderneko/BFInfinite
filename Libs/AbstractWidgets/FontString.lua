local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- font string
---------------------------------------------------------------------
--- @param color string color name defined in Color.lua
--- @param font string color name defined in Font.lua
function AW.CreateFontString(parent, text, color, font, isDisabled)
    font = font or "normal"
    font = AW.GetFontName(font or "normal", isDisabled)

    local fs = parent:CreateFontString(nil, "OVERLAY", font)
    if color then AW.ColorFontString(fs, color) end
    fs:SetText(text)

    function fs:SetColor(color)
        AW.ColorFontString(fs, color)
    end

    function fs:UpdatePixels()
        AW.RePoint(fs)
    end

    AW.AddToPixelUpdater(fs)

    return fs
end

---------------------------------------------------------------------
-- notification text
---------------------------------------------------------------------
local pool

local function creationFunc()
    -- NOTE: do not use AW.CreateFontString, since we don't need UpdatePixels() for it
    local fs = UIParent:CreateFontString(nil, "OVERLAY", AW.GetFontName("normal"))
    fs:Hide()

    fs:SetWordWrap(true) -- multiline allowed

    local ag = fs:CreateAnimationGroup()

    -- in -------------------------------------------------------------------- --
    local in_a = ag:CreateAnimation("Alpha")
    in_a:SetOrder(1)
    in_a:SetFromAlpha(0)
    in_a:SetToAlpha(1)
    in_a:SetDuration(0.25)
    
    -- out ------------------------------------------------------------------- --
    local out_a = ag:CreateAnimation("Alpha")
    out_a:SetOrder(2)
    out_a:SetFromAlpha(1)
    out_a:SetToAlpha(0)
    out_a:SetStartDelay(2)
    out_a:SetDuration(0.25)

    function fs:ShowUp(parent, hideDelay)
        parent._notificationString = fs
        out_a:SetStartDelay(hideDelay or 2)
        fs:Show()
        ag:Play()
        ag:SetScript("OnFinished", function()
            parent._notificationString = nil
            pool:Release(fs)
        end)
    end

    function fs:HideOut(parent)
        parent._notificationString = nil
        pool:Release(fs)
        ag:Stop()
    end

    return fs
end

local function resetterFunc(_, f)
    f:Hide()
end

pool = CreateObjectPool(creationFunc, resetterFunc)

function AW.ShowNotificationText(text, color, width, hideDelay, point, relativeTo, relativePoint, offsetX, offsetY)
    assert(relativeTo, "parent can not be nil!")
    if relativeTo._notificationString then
        relativeTo._notificationString:HideOut(relativeTo)
    end

    local fs = pool:Acquire()
    fs:SetParent(relativeTo) --! IMPORTANT, if parent is nil, then game will crash (The memory could not be "read")
    fs:SetText(text)
    AW.ColorFontString(fs, color or "red")
    if width then fs:SetWidth(width) end
    
    -- alignment
    if strfind(point, "LEFT$") then
        fs:SetJustifyH("LEFT")
    elseif strfind(point, "RIGHT$") then
        fs:SetJustifyH("RIGHT")
    else
        fs:SetJustifyH("CENTER")
    end

    fs:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    fs:ShowUp(relativeTo, hideDelay)
end