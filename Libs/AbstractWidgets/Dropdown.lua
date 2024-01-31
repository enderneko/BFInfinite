local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- dropdown menu
---------------------------------------------------------------------
local list

local function CreateListFrame()
    list = AW.CreateScrollList(UIParent, 10, 1, 1, 10, 18, 0, "widget")
    list:SetClampedToScreen(true)
    list:Hide()

    -- adjust scrollBar points
    AW.SetPoint(list.scrollBar, "TOPRIGHT")
    AW.SetPoint(list.scrollBar, "BOTTOMRIGHT")

    -- make list closable by pressing ESC
    _G[ns.prefix.."DropdownList"] = list
    tinsert(UISpecialFrames, ns.prefix.."DropdownList")

    -- store created buttons
    list.buttons = {}
    
    -- highlight
    local highlight = AW.CreateBorderedFrame(list, nil, 100, 100, "none", "accent")
    highlight:Hide()

    function list:SetHighlightItem(i)
        if not i then
            highlight:ClearAllPoints()
            highlight:Hide()
        else
            highlight:SetParent(list.buttons[i]) -- NOTE: buttons show/hide automatically when scroll
            highlight:ClearAllPoints()
            highlight:SetAllPoints(list.buttons[i])
            highlight:Show()
        end
    end

    list:SetScript("OnHide", function() list:Hide() end)

    list:SetScript("OnShow", function()
        list:UpdatePixels()
        if list.menu.selected then
            list:SetScroll(list.menu.selected)
        end
    end)
end

-- close dropdown
function AW.RegisterForCloseDropdown(f)
    assert(f.OnMouseDown, "no OnMouseDown for this region!")
    f:HookScript("OnMouseDown", function()
        list:Hide()
    end)
end

function AW.CreateDropdown(parent, width, dropdownType, isMini, isHorizontal)
    if not list then CreateListFrame() end
    
    local menu = AW.CreateBorderedFrame(parent, nil, width, 20, "widget")
    menu:EnableMouse(true)

    -- label
    function menu:SetLabel(label, color, font)
        menu.label = AW.CreateFontString(menu, label, color, font)
        AW.SetPoint(menu.label, "BOTTOMLEFT", menu, "TOPLEFT", 2, 2)
        menu.label:SetText(label)

        hooksecurefunc(menu, "SetEnabled", function(self, enabled)
            if enabled then
                menu.label:SetColor(color)
            else
                menu.label:SetColor("disabled")
            end
        end)
    end

    -- button: open/close menu list
    if isMini then
        menu.button = AW.CreateButton(menu, nil, "accent-transparent", 20, 20)
        menu.button:SetAllPoints(menu)
        -- selected item
        menu.text = AW.CreateFontString(menu.button)
        AW.SetPoint(menu.text, "LEFT", 1, 0)
        AW.SetPoint(menu.text, "RIGHT", -1, 0)
        menu.text:SetJustifyH("CENTER")
    else
        menu.button = AW.CreateButton(menu, nil, "accent-hover", 18, 20)
        menu.button:SetPoint("TOPRIGHT")
        menu.button:SetPoint("BOTTOMRIGHT")
        menu.button:SetTexture(AW.GetIcon("Dropdown"), {16, 16}, {"CENTER", 0, 0})
        -- menu.button:SetBackdropColor(AW.GetColorRGB("none"))
        -- menu.button._color = AW.GetColorTable("none")
        -- selected item
        menu.text = AW.CreateFontString(menu)
        AW.SetPoint(menu.text, "LEFT", 5, 0)
        AW.SetPoint(menu.text, "RIGHT", menu.button, "LEFT", -5, 0)
        menu.text:SetJustifyH("LEFT")
    end

    -- highlight
    -- menu.highlight = AW.CreateTexture(menu, nil, AW.GetColorTable("accent", 0.07))
    -- AW.SetPoint(menu.highlight, "TOPLEFT", 1, -1)
    -- AW.SetPoint(menu.highlight, "BOTTOMRIGHT", -1, 1)
    -- menu.highlight:Hide()

    -- hook for tooltips
    menu.button:HookScript("OnEnter", function()
        if menu._tooltips then
            menu:GetScript("OnEnter")()
        end
    end)
    menu.button:HookScript("OnLeave", function()
        if menu._tooltips then
            menu:GetScript("OnLeave")()
        end
    end)
    
    -- selected item
    menu.text:SetWordWrap(false)

    if dropdownType == "texture" then
        menu.texture = AW.CreateTexture(menu)
        AW.SetPoint(menu.texture, "TOPLEFT", 1, -1)
        if isMini then
            AW.SetPoint(menu.texture, "BOTTOMRIGHT", -1, 1)
        else
            AW.SetPoint(menu.texture, "BOTTOMRIGHT", menu.button, "BOTTOMLEFT", -1, 1)
        end
        menu.texture:SetVertexColor(AW.GetColorRGB("white", 0.7))
    end
    
    -- keep all menu item definitions
    menu.items = {
        -- {
        --     ["text"] = (string),
        --     ["value"] = (obj),
        --     ["texture"] = (string),
        --     ["font"] = (string),
            -- ["disabled"] = (boolean),
        --     ["onClick"] = (function)
        -- },
    }

    -- index in items
    -- menu.selected
    
    -- selection ----------------------------------------------------
    local function SetSelected(type, v)
        local valid
        for i, item in pairs(menu.items) do
            if item[type] == v then
                valid = true
                menu.selected = i
                menu.text:SetText(item.text)
                if dropdownType == "texture" then
                    menu.texture:SetTexture(item.texture)
                elseif dropdownType == "font" then
                    menu.text:SetFont(item.font, 13+AW.fontSizeOffset, "")
                end
                break
            end
        end
        if not valid then
            menu.selected = nil
            menu.text:SetText()
            list:SetHighlightItem()
        end
    end

    --- @deprecated
    function menu:SetSelected(text)
        SetSelected("text", text)
    end

    function menu:SetSelectedValue(value)
        SetSelected("value", value)
    end

    function menu:ClearSelected()
        menu.selected = nil
        menu.text:SetText()
        list:SetHighlightItem()
    end

    -- return value first, then text
    function menu:GetSelected()
        if menu.selected then
            return menu.items[menu.selected].value or menu.items[menu.selected].text
        end
        return nil
    end
    -----------------------------------------------------------------
    
    -- update items -------------------------------------------------
    function menu:SetItems(items)
        menu.items = items
        menu.reloadRequired = true
    end
    
    function menu:AddItem(item)
        tinsert(menu.items, item)
        menu.reloadRequired = true
    end
    
    function menu:RemoveCurrentItem()
        tremove(menu.items, menu.selected)
        menu.reloadRequired = true
    end
    
    function menu:ClearItems()
        wipe(menu.items)
        menu.selected = nil
        menu.text:SetText("")
        list:SetHighlightItem()
    end
    
    function menu:SetCurrentItem(item)
        menu.items[menu.selected] = item
        -- usually, update current item means to change its name (text) and func
        menu.text:SetText(item["text"])
        menu.reloadRequired = true
    end
    -----------------------------------------------------------------
    
    -- generic onClick ----------------------------------------------
    function menu:SetOnClick(fn)
        menu.onClick = fn
    end
    -----------------------------------------------------------------
    
    local buttons = {} -- current shown buttons

    local function LoadItems()
        wipe(buttons)
        menu.reloadRequired = nil
        -- hide highlight
        list:SetHighlightItem()
        -- hide all buttons
        list:Reset()

        -- load current dropdown
        for i, item in pairs(menu.items) do
            local b
            if not list.buttons[i] then
                -- create new button
                b = AW.CreateButton(list.slotFrame, item.text, "accent-transparent", 18 ,18, nil, true) --! width is not important
                table.insert(list.buttons, b)

                -- pre-create for texture type
                if dropdownType == "texture" then
                    b.texture = AW.CreateTexture(b)
                    AW.SetPoint(b.texture, "TOPLEFT", 1, -1)
                    AW.SetPoint(b.texture, "BOTTOMRIGHT", -1, 1)
                    b.texture:SetVertexColor(AW.GetColorRGB("white", 0.7))
                    b.texture:Hide()
                end
            else
                -- re-use button
                b = list.buttons[i]
                b:SetText(item.text)
            end

            local fs = b.text
            if isMini then
                fs:SetJustifyH("CENTER")
                AW.ClearPoints(fs)
                AW.SetPoint(fs, "LEFT", 1, 0)
                AW.SetPoint(fs, "RIGHT", -1, 0)
            else
                fs:SetJustifyH("LEFT")
                AW.ClearPoints(fs)
                AW.SetPoint(fs, "LEFT", 5, 0)
                AW.SetPoint(fs, "RIGHT", -5, 0)
            end

            -- texture
            if dropdownType == "texture" then
                if item.texture then
                    b.texture:SetTexture(item.texture)
                    b.texture:Show()
                else
                    b.texture:Hide()
                end
            end

            -- font
            local f, s = AW.GetFont("normal", false, true):GetFont()
            s = Round(s)
            if item.font then
                b.text:SetFont(item.font, s, "")
            else
                b.text:SetFont(f, s, "")
            end

            -- highlight
            if menu.selected == i then
                list:SetHighlightItem(i)
            end

            -- check item.value
            if not item.value then item.value = item.text end

            b:SetScript("OnClick", function()
                menu:SetSelectedValue(item.value)
                list:Hide()
                if item.onClick then
                    -- NOTE: item.onClick has higher priority
                    item.onClick(item.value, menu)
                elseif menu.onClick then
                    menu.onClick(item.value)
                end
            end)

            -- update point
            if isMini and isHorizontal then
                AW.SetWidth(b, width)
                if i == 1 then
                    AW.SetPoint(b, "TOPLEFT", 1, -1)
                else
                    AW.SetPoint(b, "TOPLEFT", list.buttons[i-1], "TOPRIGHT")
                end
            end

            tinsert(buttons, b)
            b:SetEnabled(not item.disabled)
            b:Show()
        end

        -- update list size / point
        list.menu = menu -- check for menu's OnHide -> list:Hide
        list:SetParent(menu)
        list:SetFrameLevel(menu:GetFrameLevel()+10)
        AW.ClearPoints(list)
        
        if isMini and isHorizontal then
            AW.SetPoint(list, "TOPLEFT", menu, "TOPRIGHT", 2, 0)
            if #menu.items == 0 then
                AW.SetSize(list, 5, 20)
            else
                AW.SetListWidth(list, #menu.items, width, 0, 2)
                AW.SetHeight(list, 20)
            end
            list:SetContentHeight(20)

        else -- using scroll list
            AW.SetPoint(list, "TOPLEFT", menu, "BOTTOMLEFT", 0, -2)
            AW.SetWidth(list, width)
            
            list:SetSlotNum(min(#buttons, 10))
            list:SetWidgets(buttons)

            -- if #menu.items == 0 then
            --     AW.SetSize(list, width, 5)
            -- elseif #menu.items <= 10 then
            --     AW.SetWidth(list, width)
            --     AW.SetListHeight(list, #menu.items, 18, 0, 2)
            --     list:SetContentHeight(18, #menu.items, 0, 2)
            -- else -- > 10
            --     AW.SetWidth(list, width)
            --     AW.SetListHeight(list, 18, 10, 0, 2)
            --     list:SetContentHeight(18, #menu.items, 0, 2)
            -- end
        end
    end

    function menu:SetEnabled(f)
        menu.button:SetEnabled(f)
        if f then
            menu.text:SetColor("white")
        else
            menu.text:SetColor("disabled")
            if list.menu == menu then
                list:Hide()
            end
        end
    end

    menu:SetScript("OnHide", function()
        if list.menu == menu then
            list:Hide()
        end
    end)
    
    -- scripts
    menu.button:HookScript("OnClick", function()
        if list.menu ~= menu then -- list shown by other dropdown
            LoadItems()
            list:Show()

        elseif list:IsShown() then -- list showing by this, hide it
            list:Hide()

        else
            if menu.reloadRequired then
                LoadItems()
            else
                -- update highlight
                if menu.selected then
                    list:SetHighlightItem(menu.selected)
                end
            end
            list:Show()
        end
    end)
    
    return menu
end