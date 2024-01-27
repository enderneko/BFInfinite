local addonName, ns = ...
local AW = ns.AW

function AW.ShowDemo()
    if _G.AW_DEMO then
        _G.AW_DEMO:Show()
        return
    end

    local demo = AW.CreateHeaderedFrame(UIParent, "AW_DEMO", "Abstract Widgets Demo", 400, 500)
    AW.SetPoint(demo, "BOTTOMLEFT", 270, 270)
    demo:Show()

    -- button ---------------------------------------------------------------- --
    local b1 = AW.CreateButton(demo, "Button A", "accent", 100, 20)
    AW.SetPoint(b1, "TOPLEFT", 10, -10)
    AW.SetTooltips(b1, "ANCHOR_TOPLEFT", 0, 1, "Tooltip Title", "This is a tooltip")

    local b2 = AW.CreateButton(demo, "Button B", "green", 100, 20)
    AW.SetPoint(b2, "TOPLEFT", b1, "TOPRIGHT", 10, 0)
    b2:SetEnabled(false)
    
    local b3 = AW.CreateButton(demo, "Button C", "red", 100, 20)
    b3:SetTexture("classicon-"..strlower(PlayerUtil.GetClassFile()), {16, 16}, {"LEFT", 2, 0}, true)
    AW.SetPoint(b3, "TOPLEFT", b2, "TOPRIGHT", 10, 0)
    
    local b4 = AW.CreateButton(demo, nil, "accent", 20, 20)
    b4:SetTexture("classicon-"..strlower(PlayerUtil.GetClassFile()), {16, 16}, {"CENTER", 0, 0}, true, true)
    AW.SetPoint(b4, "TOPLEFT", b3, "TOPRIGHT", 10, 0)

    local b5 = AW.CreateButton(demo, nil, "accent", 20, 20)
    b5:SetTexture("classicon-"..strlower(PlayerUtil.GetClassFile()), {16, 16}, {"CENTER", 0, 0}, true, true)
    AW.SetPoint(b5, "TOPLEFT", b4, "TOPRIGHT", 10, 0)
    b5:SetEnabled(false)

    -- check button ---------------------------------------------------------- --
    local cb1 = AW.CreateCheckButton(demo, "Check boxes")
    AW.SetPoint(cb1, "TOPLEFT", b1, "BOTTOMLEFT", 0, -10)
    AW.SetTooltips(cb1, "ANCHOR_TOPLEFT", 0, 3, "Check Button", "The hit rectangle of these check buttons are different")
    
    local cb2 = AW.CreateCheckButton(demo, "With")
    AW.SetPoint(cb2, "TOPLEFT", cb1, "BOTTOMLEFT", 0, -7)
    cb2:SetEnabled(false)
    
    local cb3 = AW.CreateCheckButton(demo, "Different label length", function(checked)
        cb2:SetChecked(checked)
    end)
    AW.SetPoint(cb3, "TOPLEFT", cb2, "BOTTOMLEFT", 0, -7)

    -- edit box -------------------------------------------------------------- --
    local eb1 = AW.CreateEditBox(demo, "Edit Box", 200, 20)
    AW.SetPoint(eb1, "TOPLEFT", cb3, "BOTTOMLEFT", 0, -10)
    eb1:SetOnTextChanged(function(text)
        print("TextChanged:", text)
    end)
    eb1:SetText("Hello!")

    local eb2 = AW.CreateEditBox(demo, "Number Only", 200, 20, false, true)
    AW.SetPoint(eb2, "TOPLEFT", eb1, "BOTTOMLEFT", 0, -10)
    eb2:SetConfirmButton(function(text)
        print("ConfirmButtonClicked:", text)
    end)
    
    local eb3 = AW.CreateEditBox(demo, "Edit Box", 200, 20)
    AW.SetPoint(eb3, "TOPLEFT", eb2, "BOTTOMLEFT", 0, -10)
    eb3:SetText("Disabled Edit Box")
    eb3:SetEnabled(false)

    -- bordered frame -------------------------------------------------------- --
    local bf1 = AW.CreateBorderedFrame(demo, nil, 150, 150, nil, "accent")
    AW.SetPoint(bf1, "RIGHT", -10, 0)
    AW.SetPoint(bf1, "TOP", cb1)

    -- font string ----------------------------------------------------------- --
    local fs1 = AW.CreateFontString(bf1, "Bordered Frame", "gray")
    AW.SetPoint(fs1, "TOPLEFT", 5, -5)

    -- titled pane ----------------------------------------------------------- --
    local tp1 = AW.CreateTitledPane(demo, "Titled Pane", 140, 100)
    AW.SetPoint(tp1, "BOTTOMLEFT", bf1, 5, 5)

    -- button group ---------------------------------------------------------- --
    local bf2 = AW.CreateBorderedFrame(demo, "Button Group", 100, 60)
    AW.SetPoint(bf2, "TOPLEFT", eb3, "BOTTOMLEFT", 0, -27)
    AW.SetListHeight(bf2, 20, 3, -1)

    local b6 = AW.CreateButton(bf2, "Item A", "accent-transparent", 100, 20)
    b6.id = "b6"
    AW.SetPoint(b6, "TOPLEFT")
    AW.SetPoint(b6, "RIGHT")
    
    local b7 = AW.CreateButton(bf2, "Item B", "accent-transparent", 100, 20)
    b7.id = "b7"
    AW.SetPoint(b7, "TOPLEFT", b6, "BOTTOMLEFT", 0, 1)
    AW.SetPoint(b7, "RIGHT")
    AW.SetTooltips(b7, "LEFT", -2, 0, "Item B")
    
    local b8 = AW.CreateButton(bf2, "Item C", "accent-transparent", 100, 20)
    b8.id = "b8"
    AW.SetPoint(b8, "TOPLEFT", b7, "BOTTOMLEFT", 0, 1)
    AW.SetPoint(b8, "RIGHT")

    AW.CreateButtonGroup({b6, b7, b8}, function(id)
        print("selected", id)
    end)

    -- scroll frame ---------------------------------------------------------- --
    local sf1 = AW.CreateScrollFrame(demo, 150, 150)
    AW.SetPoint(sf1, "TOPLEFT", bf1, "BOTTOMLEFT", 0, -10)
    -- AW.SetPoint(sf1, "TOPRIGHT", bf1, "BOTTOMRIGHT", 0, -10)

    sf1.tex = AW.CreateGradientTexture(sf1.scrollContent, "VERTICAL", {0.96, 0.26, 0.41, 1}, {0.24, 0.23, 0.57, 1})
    AW.SetPoint(sf1.tex, "TOPLEFT", sf1.scrollContent, 1, -1)
    AW.SetPoint(sf1.tex, "BOTTOMRIGHT", sf1.scrollContent, -1, 1)

    sf1.b1 = AW.CreateButton(sf1.scrollContent, "Entry", "blue", 20, 20)
    AW.SetPoint(sf1.b1, "TOPLEFT")
    AW.SetPoint(sf1.b1, "RIGHT")

    sf1:SetContentHeight(20)

    -- switch ---------------------------------------------------------------- --
    local sw1 = AW.CreateSwitch(demo, 150, 20, {
        {
            ["text"] = "20",
            ["value"] = 20,
            ["onClick"] = function()
                sf1:SetContentHeight(20)
            end,
        },
        {
            ["text"] = "100",
            ["value"] = 100,
            ["onClick"] = function()
                sf1:SetContentHeight(100)
            end,
        },
        {
            ["text"] = "200",
            ["value"] = 200,
            ["onClick"] = function()
                sf1:SetContentHeight(200)
            end,
        },
        {
            ["text"] = "400",
            ["value"] = 400,
            ["onClick"] = function()
                sf1:SetContentHeight(400)
            end,
        }
    })
    AW.SetPoint(sw1, "TOPLEFT", sf1, "BOTTOMLEFT", 0, -10)
    sw1:SetSelectedValue(20)

    -- slider ---------------------------------------------------------------- --
    local sl1 = AW.CreateSlider(tp1, "Scale", 130, 0.5, 2, 0.1)
    AW.SetPoint(sl1, "TOPLEFT", 5, -40)
    sl1:SetValue(1)
    sl1:SetAfterValueChanged(function(value)
        demo:SetScale(value)
        AW.UpdatePixels()
    end)

    local sl2 = AW.CreateSlider(demo, "Enabled", 100, 50, 500, 10, true, true)
    AW.SetPoint(sl2, "TOPLEFT", bf2, "TOPRIGHT", 10, -25)
    sl2:SetValue(1 * 100) -- for percentage, set value * 100
    sl2:SetOnValueChanged(function(value)
        print("OnSliderValueChanged:", value / 100) -- for percentage, get value / 100
    end)
    sl2:SetAfterValueChanged(function(value)
        print("AfterSliderValueChanged:", value / 100) -- for percentage, get value / 100
    end)

    local cb4 = AW.CreateCheckButton(demo, nil, function(checked, self)
        sl2:SetEnabled(checked)
        sl2:SetLabel(checked and "Enabled" or "Disabled")
        AW.ShowNotificationText(checked and "Enabled" or "Disabled", "red", nil, nil, "BOTTOMLEFT", self, "TOPLEFT", 0, 3)
    end)
    AW.SetPoint(cb4, "BOTTOMLEFT", sl2, "TOPLEFT", 0, 1)
    cb4:SetChecked(true)

    local sl3 = AW.CreateVerticalSlider(demo, "Vertical Slider", 100, 0, 100, 1, true)
    AW.SetPoint(sl3, "TOPLEFT", bf2, "BOTTOMLEFT", 30, -10)
    sl3:UpdateWordWrap()
    sl3:SetValue(0 * 100) -- for percentage, set value * 100
    sl3:SetOnValueChanged(function(value)
        print("VERTICAL_OnSliderValueChanged:", value / 100) -- for percentage, get value / 100
    end)
    sl3:SetAfterValueChanged(function(value)
        print("VERTICAL_AfterSliderValueChanged:", value / 100) -- for percentage, get value / 100
    end)
end