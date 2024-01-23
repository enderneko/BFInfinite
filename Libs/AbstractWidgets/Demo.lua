local addonName, ns = ...
local AW = ns.AW

function AW.ShowDemo()
    if _G.AW_DEMO then
        _G.AW_DEMO:Show()
        return
    end

    local demo = AW.CreateHeaderedFrame(UIParent, "AW_DEMO", "Test Frame", 400, 400)
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

    AW_B4 = b4

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
    
    local cb3 = AW.CreateCheckButton(demo, "Different lable length", function(checked)
        cb2:SetChecked(checked)
    end)
    AW.SetPoint(cb3, "TOPLEFT", cb2, "BOTTOMLEFT", 0, -7)

    -- edit box -------------------------------------------------------------- --
    local eb1 = AW.CreateEditBox(demo, "Edit Box", 200, 20)
    AW.SetPoint(eb1, "TOPLEFT", cb3, "BOTTOMLEFT", 0, -10)

    local eb2 = AW.CreateEditBox(demo, "Number Only", 200, 20, false, false, true)
    AW.SetPoint(eb2, "TOPLEFT", eb1, "BOTTOMLEFT", 0, -10)
    
    local eb3 = AW.CreateEditBox(demo, "Edit Box", 200, 20)
    AW.SetPoint(eb3, "TOPLEFT", eb2, "BOTTOMLEFT", 0, -10)
    eb3:SetText("Disabled Edit Box")
    eb3:SetEnabled(false)

    -- bordered frame -------------------------------------------------------- --
    local bf1 = AW.CreateBorderedFrame(demo, nil, 150, 150, nil, "accent")
    AW.SetPoint(bf1, "RIGHT", -10, 0)
    AW.SetPoint(bf1, "TOP", cb1)

    local bf2 = AW.CreateBorderedFrame(demo, "Button Group", 100, 60)
    AW.SetPoint(bf2, "TOPLEFT", eb3, "BOTTOMLEFT", 0, -27)

    -- font string ----------------------------------------------------------- --
    local fs1 = AW.CreateFontString(bf1, "Bordered Frame", "gray")
    AW.SetPoint(fs1, "TOPLEFT", 5, -5)

    -- titled pane ----------------------------------------------------------- --
    local tp1 = AW.CreateTitledPane(demo, "Titled Pane", 140, 100)
    AW.SetPoint(tp1, "BOTTOMLEFT", bf1, 5, 5)
end