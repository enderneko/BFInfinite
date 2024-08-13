local addonName, BFI = ...
local L = BFI.L
local AW = BFI.AW
local U = BFI.utils
local AB = BFI.ActionBars

local LAB = BFI.libs.LAB

local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local SetModifiedClick = SetModifiedClick

local ACTION_BAR_LIST = {
    [1] = "bar1",
    [2] = "bar2",
    [3] = "bar3",
    [4] = "bar4",
    [5] = "bar5",
    [6] = "bar6",
    [7] = "classbar1",
    [8] = "classbar2",
    [9] = "classbar3",
    [10] = "classbar4",
    [13] = "bar7",
    [14] = "bar8",
    [15] = "bar9",
}

local BINDING_MAPPINGS = {
    bar1 = "ACTIONBUTTON%d",
    bar2 = "BFIACTIONBAR2BUTTON%d",
    bar3 = "MULTIACTIONBAR3BUTTON%d",
    bar4 = "MULTIACTIONBAR4BUTTON%d",
    bar5 = "MULTIACTIONBAR2BUTTON%d",
    bar6 = "MULTIACTIONBAR1BUTTON%d",
    bar7 = "MULTIACTIONBAR5BUTTON%d",
    bar8 = "MULTIACTIONBAR6BUTTON%d",
    bar9 = "MULTIACTIONBAR7BUTTON%d",
    classbar1 = "BFIACTIONBAR7BUTTON%d",
    classbar2 = "BFIACTIONBAR8BUTTON%d",
    classbar3 = "BFIACTIONBAR9BUTTON%d",
    classbar4 = "BFIACTIONBAR10BUTTON%d",
}

---------------------------------------------------------------------
-- bar functions
---------------------------------------------------------------------
local handledFlyouts = {}

local function HandleFlyoutButton(b)
    if not handledFlyouts[b] then
        handledFlyouts[b] = true
        AB.StylizeButton(b)
    end

    if not InCombatLockdown() then
        AW.SetSize(b, AB.config.general.flyoutSize) -- TODO: use bar button size instead
    end

    b.MasqueSkinned = true -- skip LAB styling
end


local function ActionBar_FlyoutSpells()
    if LAB.FlyoutButtons then
        for _, b in pairs(LAB.FlyoutButtons) do
            HandleFlyoutButton(b)
        end
    end
end

-- local function ActionBar_FlyoutCreated(b)
--     print(b)
-- end

-- local function ActionBar_FlyoutUpdate(...)
--     print(...)
-- end

---------------------------------------------------------------------
-- create bar
---------------------------------------------------------------------
local function CreateBar(id)
    local name = "BFI_ActionBar"..id
    local bar = CreateFrame("Frame", name, AW.UIParent, "SecureHandlerStateTemplate")

    bar.id = id
    bar.name = ACTION_BAR_LIST[id]
    bar.buttons = {}

    AB.bars[bar.name] = bar

    -- mover ----------------------------------------------------------------- --
    local moverName
    if strfind(bar.name, "^bar") then
        moverName = L["Action Bar"].." "..bar.name:match("%d")
    else
        moverName = L["Class Bar"].." "..bar.name:match("%d")
    end
    AW.CreateMover(bar, "ActionBars", moverName, function(p,x,y) print(moverName..":", p, x, y) end)

    -- page ------------------------------------------------------------------ --
    bar:SetAttribute("_onstate-page", [[
        if newstate == "possess" or newstate == "11" then
            if HasVehicleActionBar() then
                newstate = GetVehicleBarIndex()
            elseif HasOverrideActionBar() then
                newstate = GetOverrideBarIndex()
            elseif HasTempShapeshiftActionBar() then
                newstate = GetTempShapeshiftBarIndex()
            elseif HasBonusActionBar() then
                newstate = GetBonusBarIndex()
            else
                newstate = 12
            end
        end

        self:SetAttribute("state", newstate)
        control:ChildUpdate("state", newstate)
    ]])

    -- create buttons -------------------------------------------------------- --
    for i = 1, NUM_ACTIONBAR_BUTTONS do
        local b = AB.CreateButton(bar, i, name.."Button"..i)
        -- local b = LAB:CreateButton(i, name.."_Button"..i, bar)
        tinsert(bar.buttons, b)

        -- b:SetState(1, "action", i)
        -- b:SetState(2, "action", 2)

        b:HookScript("OnEnter", AB.ActionBar_OnEnter)
        b:HookScript("OnLeave", AB.ActionBar_OnLeave)
    end

    -- events ---------------------------------------------------------------- --
    bar:SetScript("OnEnter", AB.ActionBar_OnEnter)
    bar:SetScript("OnLeave", AB.ActionBar_OnLeave)

    -- update pixels --------------------------------------------------------- --
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
-- assign bindings
---------------------------------------------------------------------
local function AssignBindings()
    if InCombatLockdown() then return end

    for barName in pairs(BINDING_MAPPINGS) do
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
function AB.ReArrange(bar, size, spacing, buttonsPerLine, num, anchor, orientation)
    -- update buttons -------------------------------------------------------- --
    local p, rp, rp_new_line
    local x, y, x_new_line, y_new_line

    p = anchor

    if orientation == "horizontal" then
        if strfind(anchor, "^TOP") then
            rp = "TOP"
            rp_new_line = "BOTTOM"
            y_new_line = -spacing
        elseif strfind(anchor, "^BOTTOM") then
            rp = "BOTTOM"
            rp_new_line = "TOP"
            y_new_line = spacing
        end

        if strfind(anchor, "LEFT$") then
            rp = rp.."RIGHT"
            rp_new_line = rp_new_line.."LEFT"
            x = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp.."LEFT"
            rp_new_line = rp_new_line.."RIGHT"
            x = -spacing
        end

        y = 0
        x_new_line = 0
    else
        if strfind(anchor, "^TOP") then
            rp = "BOTTOM"
            rp_new_line = "TOP"
            y = -spacing
        elseif strfind(anchor, "^BOTTOM") then
            rp = "TOP"
            rp_new_line = "BOTTOM"
            y = spacing
        end

        if strfind(anchor, "LEFT$") then
            rp = rp.."LEFT"
            rp_new_line = rp_new_line.."RIGHT"
            x_new_line = spacing
        elseif strfind(anchor, "RIGHT$") then
            rp = rp.."RIGHT"
            rp_new_line = rp_new_line.."LEFT"
            x_new_line = -spacing
        end

        x = 0
        y_new_line = 0
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
    bar.buttonConfig.flyoutDirection = specific.flyoutDirection
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

        if i == 12 then
            if BFI.vars.isRetail then
                b:SetState(GetVehicleBarIndex(), "custom", customExitButton) -- 16
                b:SetState(GetTempShapeshiftBarIndex(), "custom", customExitButton) -- 17
                b:SetState(GetOverrideBarIndex(), "custom", customExitButton) -- 18
            else
                -- FIXME:
                b:SetState(11, "custom", customExitButton)
                b:SetState(12, "custom", customExitButton)
            end
        end

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
-- NOTE: no support for default page "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;"
-- TODO: no GetOverrideBarIndex and GetVehicleBarIndex on Vanilla
local BAR1_PAGING_DEFAULT = format("[overridebar] %d; [vehicleui][possessbar] %d; [shapeshift] %d; [bonusbar:5] 11;", GetOverrideBarIndex(), GetVehicleBarIndex(), GetTempShapeshiftBarIndex())

local function UpdateBar(bar, general, shared, specific)
    bar.enabled = specific.enabled
    if not specific.enabled then
        bar:Hide()
        UnregisterStateDriver(bar, "visibility")
        return
    end

    bar:Show()
    RegisterStateDriver(bar, "visibility", specific.visibility)

    -- bar
    AB.ReArrange(bar, specific.size, specific.spacing, specific.buttonsPerLine, specific.num, specific.anchor, specific.orientation)
    AW.LoadPosition(bar, specific.position)

    bar:SetFrameStrata(general.frameStrata)
    bar:SetFrameLevel(general.frameLevel)

    bar.alpha = specific.alpha
    bar:SetAlpha(specific.alpha)

    -- paging
    local page
    if bar.id == 1 then
        page = BAR1_PAGING_DEFAULT.." "..(specific.paging[BFI.vars.playerClass] or "1")
    else
        page = specific.paging[BFI.vars.playerClass] or bar.id
    end
    RegisterStateDriver(bar, "page", page)
    bar:SetAttribute("page", page)

    -- button
    UpdateButton(bar, shared, specific.buttonConfig)
end

local init
local function UpdateMainBars(module, which, barName)
    if module and module ~= "ActionBars" then return end
    if which and which ~= "main" then return end

    if not AB.config.general.enabled then
        LAB.UnregisterCallback(AB, "OnFlyoutSpells")
        AB:UnregisterEvent("UPDATE_BINDINGS", AssignBindings)
        if BFI.vars.isRetail then
            AB:UnregisterEvent("PET_BATTLE_CLOSE", AssignBindings)
            AB:UnregisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
        end
        return
    end

    if not init then
        init = true

        AB.DisableBlizzard()

        _G.BINDING_HEADER_BFI = AW.WrapTextInColor(addonName, "accent")

        local bars = {
            [2] = L["Action Bar"].." 2 "..L["Button"].." %d",
            [7] = L["Class Bar"].." 1 "..L["Button"].." %d",
            [8] = L["Class Bar"].." 2 "..L["Button"].." %d",
            [9] = L["Class Bar"].." 3 "..L["Button"].." %d",
            [10] = L["Class Bar"].." 4 "..L["Button"].." %d",
        }

        for bar, text in pairs(bars) do
            for slot = 1, 12 do
                _G[format("BINDING_NAME_BFIACTIONBAR%dBUTTON%d", bar, slot)] = format(text, slot)
            end
        end

        for i in pairs(ACTION_BAR_LIST) do
            CreateBar(i)
        end

        LAB.RegisterCallback(AB, "OnFlyoutSpells", ActionBar_FlyoutSpells)
        -- LAB.RegisterCallback(AB, "OnFlyoutUpdate", ActionBar_FlyoutUpdate)
        -- LAB.RegisterCallback(AB, "OnFlyoutButtonCreated", ActionBar_FlyoutCreated)

        -- AB:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
        AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)

        if BFI.vars.isRetail then
            AB:RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
            AB:RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
        end

        if BFI.vars.isRetail and C_PetBattles.IsInBattle() then
            RemoveBindings()
        else
            AssignBindings()
        end
    end

    if barName then
        UpdateBar(AB.bars[barName], AB.config.general, AB.config.sharedButtonConfig, AB.config.barConfig[barName])
    else
        for _, name in pairs(ACTION_BAR_LIST) do
            UpdateBar(AB.bars[name], AB.config.general, AB.config.sharedButtonConfig, AB.config.barConfig[name])
        end
    end
end
BFI.RegisterCallback("UpdateModules", "AB_MainBars", UpdateMainBars)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
-- local function InitMainBars()
--     AB.DisableBlizzard()

--     _G.BINDING_HEADER_BFI = AW.WrapTextInColor(addonName, "accent")

--     local bars = {
--         [2] = L["Action Bar"].." 2 "..L["Button"].." %d",
--         [7] = L["Class Bar"].." 1 "..L["Button"].." %d",
--         [8] = L["Class Bar"].." 2 "..L["Button"].." %d",
--         [9] = L["Class Bar"].." 3 "..L["Button"].." %d",
--         [10] = L["Class Bar"].." 4 "..L["Button"].." %d",
--     }

--     for bar, text in pairs(bars) do
--         for slot = 1, 12 do
--             _G[format("BINDING_NAME_BFIACTIONBAR%dBUTTON%d", bar, slot)] = format(text, slot)
--         end
--     end

--     for i in pairs(ACTION_BAR_LIST) do
--         CreateBar(i)
--     end
--     UpdateMainBars()

--     LAB.RegisterCallback(AB, "OnFlyoutSpells", ActionBar_FlyoutSpells)
--     -- LAB.RegisterCallback(AB, "OnFlyoutUpdate", ActionBar_FlyoutUpdate)
--     -- LAB.RegisterCallback(AB, "OnFlyoutButtonCreated", ActionBar_FlyoutCreated)

--     -- AB:RegisterEvent("PLAYER_REGEN_ENABLED", PLAYER_REGEN_ENABLED)
--     AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)

--     if BFI.vars.isRetail then
--         AB:RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
--         AB:RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
--     end

--     if BFI.vars.isRetail and C_PetBattles.IsInBattle() then
--         RemoveBindings()
--     else
--         AssignBindings()
--     end
-- end
-- BFI.RegisterCallback("InitModules", "AB_MainBars", InitMainBars)