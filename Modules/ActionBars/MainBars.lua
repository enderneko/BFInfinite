local _, BFI = ...
local AW = BFI.AW
local W = BFI.widgets
local U = BFI.utils
local AB = BFI.M_AB

local LAB = BFI.libs.LAB

local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local SetModifiedClick = SetModifiedClick

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
function AB.CreateBar(id)
    local name = "BFI_ActionBar"..id
    local bar = CreateFrame("Frame", name, AW.UIParent, "SecureHandlerStateTemplate")
    
    bar.id = id
    bar.name = "bar"..id
    bar.buttons = {}
    
    AB.bars[bar.name] = bar

    -- RegisterStateDriver(bar, "page", "[mod:alt]2;1")
    -- bar:SetAttribute("_onstate-page", [[
    --     self:SetAttribute("state", newstate)
    --     control:ChildUpdate("state", newstate)
    -- ]])

    -- bar:SetAttribute("actionpage", id)

    for i = 1, NUM_ACTIONBAR_BUTTONS do
        local b = AB.CreateButton(bar, i, name.."Button"..i)
        -- tinsert(bar.buttons, b)
        -- b:SetID(i)

        -- local b = LAB:CreateButton(i, name.."_Button"..i, bar)
        tinsert(bar.buttons, b)

        -- b:SetState(1, "action", i)
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
-- onenter, onleave
---------------------------------------------------------------------
-- function AB.Bar_OnEnter(bar)
--     print("Bar_OnEnter", bar)
-- end

-- function AB.Bar_OnLeave(bar)
--     print("Bar_OnLeave", bar)
-- end

---------------------------------------------------------------------
-- assign bindings
---------------------------------------------------------------------
local BINDING_MAPPINGS = {
    bar1 = "ACTIONBUTTON%d",
    bar2 = "MULTIACTIONBAR1BUTTON%d",
    bar3 = "MULTIACTIONBAR3BUTTON%d",
    bar4 = "MULTIACTIONBAR4BUTTON%d",
    bar5 = "MULTIACTIONBAR2BUTTON%d",
    bar6 = "MULTIACTIONBAR1BUTTON%d",
    bar7 = "BFIACTIONBAR7BUTTON%d",
    bar8 = "BFIACTIONBAR8BUTTON%d",
    bar9 = "BFIACTIONBAR9BUTTON%d",
    bar10 = "BFIACTIONBAR10BUTTON%d",
    -- [11] = "MULTIACTIONBAR5BUTTON%d",
    -- [12] = "MULTIACTIONBAR5BUTTON%d",
    bar13 = "MULTIACTIONBAR5BUTTON%d",
    bar14 = "MULTIACTIONBAR6BUTTON%d",
    bar15 = "MULTIACTIONBAR7BUTTON%d",
}

local function AssignBindings()
    if InCombatLockdown() then return end

    for barName, mapping in pairs(BINDING_MAPPINGS) do
        local bar = AB.bars[barName]
        ClearOverrideBindings(bar)

        for _, b in ipairs(bar.buttons) do
            if b.keyBoundTarget then
                for _, key in next, {GetBindingKey(b.keyBoundTarget)} do
                    if key ~= "" then
                        SetOverrideBindingClick(bar, false, key, b:GetName())
                    end
                end
            end
        end
    end
end

local function RemoveBindings()
    if InCombatLockdown() then return end

    for _, bar in pairs(AB.bars) do
        ClearOverrideBindings(bar)
    end
end

---------------------------------------------------------------------
-- arrangement
---------------------------------------------------------------------
local function ReArrange(bar, size, spacing, buttonsPerLine, num, orientation)
    -- update buttons -------------------------------------------------------- --
    local p, rp, rp_new_line
    local x, y, x_new_line, y_new_line
    
    if orientation == "horizontal" then
        p, rp, rp_new_line = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
        x, y = spacing, 0
        x_new_line, y_new_line = 0, -spacing
    else
        p, rp, rp_new_line = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT"
        x, y = 0, -spacing
        x_new_line, y_new_line = spacing, 0
    end

    -- shown
    for i = 1, num do
        local b = bar.buttons[i]

        b:Show()
        b:SetAttribute("statehidden", nil)

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

    -- hidden
    for i = num + 1, #bar.buttons do
        bar.buttons[i]:Hide()
        bar.buttons[i]:SetAttribute("statehidden", true)
    end

    -- update bar ------------------------------------------------------------ --
    if orientation == "horizontal" then
        AW.SetListWidth(bar, min(buttonsPerLine, num), size, spacing)
        AW.SetListHeight(bar, ceil(num / buttonsPerLine), size, spacing)
    else
        AW.SetListWidth(bar, ceil(num / buttonsPerLine), size, spacing)
        AW.SetListHeight(bar, min(buttonsPerLine, num), size, spacing)
    end
end

---------------------------------------------------------------------
-- update button
---------------------------------------------------------------------
local customExitButton = {
    func = function(button)
        VehicleExit()
    end,
    texture = "Interface\\AddOns\\Bartender4\\Artwork\\LeaveVehicle.tga", --"Interface\\Icons\\Spell_Shadow_SacrificialShield", TODO:
    tooltip = LEAVE_VEHICLE,
}

local function UpdateButton(bar, shared, specific)
    if not bar.buttonConfig then
        bar.buttonConfig = {
            hideElements = {},
        }
    end

    -- shared
    bar.buttonConfig.outOfRangeColoring = shared.outOfRangeColoring
    bar.buttonConfig.targetReticle = shared.targetReticle and bar.enabled
    bar.buttonConfig.interruptDisplay = shared.interruptDisplay and bar.enabled
    bar.buttonConfig.spellCastAnim = shared.spellCastAnim and bar.enabled
    bar.buttonConfig.clickOnDown = GetCVarBool("ActionButtonUseKeyDown")
    SetModifiedClick("PICKUPACTION", shared.pickUpKey)
    bar.buttonConfig.colors = shared.colors
    bar.buttonConfig.hideElements.equipped = shared.hideElements.equipped
    bar.buttonConfig.glow = shared.glow
    
    -- specific bar
    bar.buttonConfig.showGrid = specific.showGrid
    bar.buttonConfig.hideElements.count = specific.hideElements.count
    bar.buttonConfig.hideElements.macro = specific.hideElements.macro
    bar.buttonConfig.hideElements.hotkey = specific.hideElements.hotkey
    
    -- text
    bar.buttonConfig.text = specific.text

    -- apply
    for i, b in pairs(bar.buttons) do
        -- state
        for k = 1, 18 do
            b:SetState(k, "action", (k - 1) * 12 + i)
        end
        b:SetState(0, "action", (bar.id - 1) * 12 + i)

        -- bind
        bar.buttonConfig.keyBoundTarget = format(BINDING_MAPPINGS[bar.name], i)
        b.keyBoundTarget = bar.buttonConfig.keyBoundTarget

        -- attribute
        b:SetAttribute("buttonlock", shared.lock)
        b:SetAttribute("checkselfcast", shared.casting.self[1])
        b:SetAttribute("checkmouseovercast", shared.casting.mouseover[1])
        -- b:SetAttribute("checkfocuscast", true)

        b:UpdateConfig(bar.buttonConfig)
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
local function UpdateBar(bar, general, shared, specific)
    -- bar
    ReArrange(bar, specific.size, specific.spacing, specific.buttonsPerLine, specific.num, specific.orientation)
    AW.LoadPosition(bar, specific.position)
    bar:SetFrameStrata(general.frameStrata)
    bar:SetFrameLevel(general.frameLevel)

    bar.enabled = specific.enabled
    if specific.enabled then
        bar:Show()
    else
        bar:Hide()
        UnregisterStateDriver(bar, "visibility")
    end
    
    -- page
    RegisterStateDriver(bar, "page", bar.id)
    bar:SetAttribute("page", bar.id)

    -- button
    UpdateButton(bar, shared, specific.buttonConfig)
end

local function UpdateMainBars(module, barName)
    if module and module ~= "ActionBar" then return end

    local config = BFI.vars.currentConfigTable.actionBars

    if barName then
        UpdateBar(AB.bars[barName], config.general, config.sharedButtonConfig, config.barConfig[barName])
    else
        for name, bar in pairs(AB.bars) do
            UpdateBar(bar, config.general, config.sharedButtonConfig, config.barConfig[name])
        end
    end
end
BFI.RegisterCallback("UpdateModules", "MainBars", UpdateMainBars)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function InitMainBars()
    for i = 1, 10 do
        AB.CreateBar(i)
    end
    for i = 13, 15 do
        AB.CreateBar(i)
    end
    UpdateMainBars()

    AB.RegisterEvent("UPDATE_BINDINGS", AssignBindings)

    if BFI.vars.isRetail then
        AB.RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
        AB.RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
    end

    if BFI.vars.isRetail and C_PetBattles.IsInBattle() then
        RemoveBindings()
    else
        AssignBindings()
    end
end
BFI.RegisterCallback("InitModules", "MainBars", InitMainBars)