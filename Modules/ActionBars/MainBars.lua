local _, BFI = ...
local AW = BFI.AW
local W = BFI.W
local AB = BFI.M_AB

local LAB = BFI.Libs.LAB

---------------------------------------------------------------------
-- defaults
---------------------------------------------------------------------
AB.defaults = {
    ["bar1"] = {["page"]=1, ["position"]="BOTTOM,0,200"},
}

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
function AB.CreateBar(id)
    local name = "BFI_ActionBar"..id
    local bar = CreateFrame("Frame", name, AW.UIParent, "SecureHandlerStateTemplate")
    
    AB.bars["bar"..id] = bar

    bar.buttons = {}

    RegisterStateDriver(bar, "page", "[mod:alt]2;1")
    bar:SetAttribute("_onstate-page", [[
        self:SetAttribute("state", newstate)
        control:ChildUpdate("state", newstate)
    ]])

    for i = 1, 12 do
        tinsert(bar.buttons, AB.CreateButton(bar, i, name.."_Button"..i))

        -- local b = LAB:CreateButton(i, name.."_Button"..i, bar)
        -- tinsert(bar.buttons, b)
        -- b:Show()
        -- b:SetState(1, "action", 1)
        -- b:SetState(2, "action", 2)
    end

    function bar:UpdatePixels()
        AW.ReSize(bar)
        AW.RePoint(bar)

        for _, b in pairs(bar.buttons) do
            AW.ReSize(b)
            AW.RePoint(b)
            AW.ReBorder(b)
        end 
    end

    AW.AddToPixelUpdater(bar)

    return bar
end

---------------------------------------------------------------------
-- set size
---------------------------------------------------------------------
function AB.ReArrange(bar, size, gap, buttonsPerLine, orientation)
    -- update buttons -------------------------------------------------------- --
    local p, rp, rp_new_line
    local x, y, x_new_line, y_new_line
    
    if orientation == "horizontal" then
        p, rp, rp_new_line = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
        x, y = gap, 0
        x_new_line, y_new_line = 0, -gap
    else
        p, rp, rp_new_line = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
        x, y = 0, -gap
        x_new_line, y_new_line = gap, 0
    end

    for i, b in ipairs(bar.buttons) do
        -- size
        AW.SetSize(b, size, size)

        -- point
        if i == 1 then
            AW.SetPoint(b, p)
        else
            if (i - 1) % buttonsPerLine == 0 then
                AW.SetPoint(b, p, bar.buttons[i-buttonsPerLine], rp_new_line, x_new_line, y_new_line)
            else
                AW.SetPoint(b, p, bar.buttons[i-1], rp, x, y)
            end
        end
    end

    -- update bar ------------------------------------------------------------ --
    if orientation == "horizontal" then
        AW.SetListWidth(bar, buttonsPerLine, size, gap)
        AW.SetListHeight(bar, ceil(12 / buttonsPerLine), size, gap)
    else
        AW.SetListWidth(bar, ceil(12 / buttonsPerLine), size, gap)
        AW.SetListHeight(bar, buttonsPerLine, size, gap)
    end
end

---------------------------------------------------------------------
-- onenter, onleave
---------------------------------------------------------------------
function AB.Bar_OnEnter(bar)
    print("Bar_OnEnter", bar)
end

function AB.Bar_OnLeave(bar)
    print("Bar_OnLeave", bar)
end

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitMainBars()
    for i = 1, 1 do
        local bar = AB.CreateBar(i)
        AB.ReArrange(bar, 45, 3, 12, "horizontal")
        AW.LoadPosition(bar, AB.defaults["bar"..i]["position"])
    end
end
BFI.RegisterCallback("InitModules", "MainBars_InitModules", InitMainBars)