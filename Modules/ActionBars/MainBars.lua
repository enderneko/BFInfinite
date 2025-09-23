---@class BFI
local BFI = select(2, ...)
local L = BFI.L
local AB = BFI.modules.ActionBars
---@type AbstractFramework
local AF = _G.AbstractFramework

local LAB = BFI.libs.LAB

local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick
local ClearOverrideBindings = ClearOverrideBindings
local GetVehicleBarIndex = GetVehicleBarIndex
local GetTempShapeshiftBarIndex = GetTempShapeshiftBarIndex
local GetOverrideBarIndex = GetOverrideBarIndex
local UnitExists = UnitExists
local VehicleExit = VehicleExit
local PetDismiss = PetDismiss
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS or 12

local BAR_MAPPINGS = {
    bar1 = 1,
    bar2 = 6,
    bar3 = 5,
    bar4 = 3,
    bar5 = 4,
    bar6 = 13,
    bar7 = 14,
    bar8 = 15,
    bar9 = 2, -- bonusbar
    classbar1 = 7,
    classbar2 = 8,
    classbar3 = 9,
    classbar4 = 10,
}

local BINDING_MAPPINGS = {
    bar1 = "ACTIONBUTTON%d",
    bar2 = "MULTIACTIONBAR1BUTTON%d",
    bar3 = "MULTIACTIONBAR2BUTTON%d",
    bar4 = "MULTIACTIONBAR3BUTTON%d",
    bar5 = "MULTIACTIONBAR4BUTTON%d",
    bar6 = "MULTIACTIONBAR5BUTTON%d",
    bar7 = "MULTIACTIONBAR6BUTTON%d",
    bar8 = "MULTIACTIONBAR7BUTTON%d",
    bar9 = "BFIACTIONBAR9BUTTON%d",
    classbar1 = "BFICLASSBAR1BUTTON%d",
    classbar2 = "BFICLASSBAR2BUTTON%d",
    classbar3 = "BFICLASSBAR3BUTTON%d",
    classbar4 = "BFICLASSBAR4BUTTON%d",
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
        AF.SetSize(b, AB.config.general.flyoutSize[1], AB.config.general.flyoutSize[2])
    end

    b.MasqueSkinned = true -- skip LAB styling
end


local function ActionBar_FlyoutSpells()
    if LAB.FlyoutButtons then
        for _, b in next, LAB.FlyoutButtons do
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
local function CreateBar(name, id)
    local moverName
    local global, index = name:match("(%a+)(%d+)")

    if global == "bar" then
        global = "BFI_ActionBar" .. index
        moverName = L["Action Bar %d"]:format(index)
    elseif global == "classbar" then
        global = "BFI_ClassBar" .. index
        moverName = L["Class Bar %d"]:format(index)
    end

    local bar = CreateFrame("Frame", global, AF.UIParent, "SecureHandlerStateTemplate")

    bar.id = id
    bar.name = name
    bar.buttons = {}

    AB.bars[name] = bar

    -- mover ----------------------------------------------------------------- --
    AF.CreateMover(bar, "BFI: " .. L["Action Bars"], moverName)

    -- preview rect ---------------------------------------------------------- --
    AB.CreatePreviewRect(bar)

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
        local b = AB.CreateButton(bar, i, global.."Button"..i)
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
    AF.AddToPixelUpdater_Auto(bar, nil, true)

    return bar
end

---------------------------------------------------------------------
-- bindings
---------------------------------------------------------------------
local function AssignBindings()
    if InCombatLockdown() then return end

    for barName in next, BINDING_MAPPINGS do
        local bar = AB.bars[barName]
        ClearOverrideBindings(bar)

        if bar.enabled then
            for _, b in next, bar.buttons do
                if b.keyBoundTarget then
                    for _, key in next, {GetBindingKey(b.keyBoundTarget)} do
                        if key and key ~= "" then
                            SetOverrideBindingClick(bar, false, key, b:GetName())
                        end
                    end
                end
            end
        end
    end
end

local function RemoveBindings()
    if InCombatLockdown() then return end

    for barName in next, BINDING_MAPPINGS do
        local bar = AB.bars[barName]
        ClearOverrideBindings(bar)
    end
end

---------------------------------------------------------------------
-- update button
---------------------------------------------------------------------
local customExitButton = {
    func = function(button)
        if UnitExists("vehicle") then
            VehicleExit()
        else
            PetDismiss()
        end
    end,
    texture = AF.GetTexture("Exit", BFI.name),
    tooltip = _G.LEAVE_VEHICLE,
}

local function UpdateButton(bar, config)
    if not bar.buttonConfig then
        bar.buttonConfig = {
            hideElements = {},
        }
    end

    -- assistant
    bar.buttonConfig.assistant = AB.config.assistant

    -- shared
    local shared = AB.config.sharedButtonConfig
    bar.buttonConfig.outOfRangeColoring = shared.outOfRangeColoring
    bar.buttonConfig.targetReticle = shared.targetReticle and bar.enabled
    bar.buttonConfig.interruptDisplay = shared.interruptDisplay and bar.enabled
    bar.buttonConfig.spellCastAnim = shared.spellCastAnim and bar.enabled
    bar.buttonConfig.clickOnDown = GetCVarBool("ActionButtonUseKeyDown")
    bar.buttonConfig.colors = shared.colors
    bar.buttonConfig.hideElements.equippedBorder = shared.hideElements.equippedBorder
    bar.buttonConfig.hideElements.macroBorder = shared.hideElements.macroBorder
    bar.buttonConfig.glow = shared.glow
    bar.buttonConfig.desaturateOnCooldown = shared.desaturateOnCooldown

    -- specific bar
    bar.buttonConfig.showGrid = config.showGrid
    bar.buttonConfig.flyoutDirection = config.flyoutDirection
    bar.buttonConfig.hideElements.count = config.hideElements.count
    bar.buttonConfig.hideElements.macro = config.hideElements.macro
    bar.buttonConfig.hideElements.hotkey = config.hideElements.hotkey

    -- text
    bar.buttonConfig.text = config.text

    -- apply
    for i, b in pairs(bar.buttons) do
        -- state
        for k = 1, 18 do
            b:SetState(k, "action", (k - 1) * NUM_ACTIONBAR_BUTTONS + i)
        end
        b:SetState(0, "action", (bar.id - 1) * NUM_ACTIONBAR_BUTTONS + i)

        if i == NUM_ACTIONBAR_BUTTONS then
            if AF.isRetail then
                b:SetState(GetVehicleBarIndex(), "custom", customExitButton) -- 16
                -- b:SetState(GetTempShapeshiftBarIndex(), "custom", customExitButton) -- 17
                -- b:SetState(GetOverrideBarIndex(), "custom", customExitButton) -- 18
            -- else
            --     b:SetState(11, "custom", customExitButton)
            --     b:SetState(12, "custom", customExitButton)
            end
        end

        -- bind
        bar.buttonConfig.keyBoundTarget = format(BINDING_MAPPINGS[bar.name], i)
        b.keyBoundTarget = bar.buttonConfig.keyBoundTarget

        -- lock
        b:SetAttribute("buttonlock", shared.lock)

        -- auto self cast
        if shared.cast.self then
            b:SetAttribute("checkselfcast", true)
            SetCVar("autoSelfCast", 1)
        else
            b:SetAttribute("checkselfcast", false)
            SetCVar("autoSelfCast", 0)
        end
        SetModifiedClick("SELFCAST", "NONE")

        -- mouseover cast
        if shared.cast.mouseover[1] then
            b:SetAttribute("checkmouseovercast", true)
            SetCVar("enableMouseoverCast", 1)
            SetModifiedClick("MOUSEOVERCAST", shared.cast.mouseover[2])
        else
            b:SetAttribute("checkmouseovercast", false)
            SetCVar("enableMouseoverCast", 0)
            SetModifiedClick("MOUSEOVERCAST", "NONE")
        end

        -- focus cast - FIXME: seems only CTRL works, ALT and SHIFT do not work
        if shared.cast.focus[1] then
            b:SetAttribute("checkfocuscast", true)
            SetModifiedClick("FOCUSCAST", shared.cast.focus[2])
        else
            b:SetAttribute("checkfocuscast", false)
            SetModifiedClick("FOCUSCAST", "NONE")
        end

        b:UpdateConfig(bar.buttonConfig)

        -- tooltip
        b.tooltip = AB.config.general.tooltip
    end
end

---------------------------------------------------------------------
-- update bar
---------------------------------------------------------------------
-- NOTE: no support for default page "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;"
local BAR1_PAGING_DEFAULT = format("[overridebar] %d; [vehicleui][possessbar] %d; [shapeshift] %d; [bonusbar:5] 11;", GetOverrideBarIndex(), GetVehicleBarIndex(), GetTempShapeshiftBarIndex())
-- 18, 16, 17

local function UpdateBar(bar, general, specific)
    bar.enabled = specific.enabled
    if not specific.enabled then
        UnregisterStateDriver(bar, "visibility")
        bar:Hide()
        return
    end

    RegisterStateDriver(bar, "visibility", specific.visibility)

    -- mover
    AF.UpdateMoverSave(bar, specific.position)

    -- bar
    AB.ReArrange(bar, specific.width, specific.height, specific.spacingX, specific.spacingY, specific.buttonsPerLine, specific.num, specific.orientation)
    AF.LoadPosition(bar, specific.position)

    bar:SetFrameStrata(general.frameStrata)
    bar:SetFrameLevel(general.frameLevel)

    bar.alpha = specific.alpha
    bar:SetAlpha(specific.alpha)

    -- paging
    local page
    if bar.id == 1 then
        page = BAR1_PAGING_DEFAULT.." "..(specific.paging[AF.player.class] or "1")
    else
        page = specific.paging[AF.player.class] or bar.id
    end
    RegisterStateDriver(bar, "page", page)

    -- button
    UpdateButton(bar, specific.buttonConfig)
end

local init
local function UpdateMainBars(_, module, which)
    if module and module ~= "actionBars" then return end
    if which and not (which == "main" or which:find("^bar") or which:find("^classbar")) then return end

    if not AB.config.general.enabled then
        LAB.UnregisterCallback(AB, "OnFlyoutSpells")
        AB:UnregisterEvent("UPDATE_BINDINGS", AssignBindings)
        if AF.isRetail then
            AB:UnregisterEvent("PET_BATTLE_CLOSE", AssignBindings)
            AB:UnregisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
        end

        for barName in next, BAR_MAPPINGS do
            local bar = AB.bars[barName]
            if bar then
                bar.enabled = false
                ClearOverrideBindings(bar)
                UnregisterStateDriver(bar, "visibility")
                bar:Hide()
            end
        end
        return
    end

    -- assistant
    SetCVar("assistedCombatHighlight", AB.config.assistant.highlight)

    -- shared
    local sharedConfig = AB.config.sharedButtonConfig
    SetModifiedClick("PICKUPACTION", sharedConfig.pickUpKey)
    SetCVar("lockActionBars", sharedConfig.lock)
    SetCVar("AutoPushSpellToActionBar", AB.config.general.disableAutoAddSpells and 0 or 1)

    if not init then
        init = true

        -- binding frame --------------------------------------------------------------------------
        _G.BINDING_HEADER_BFI = AF.WrapTextInColor(BFI.name, "BFI")

        -- bar9
        local text = L["Action Bar %d"]:format(9) .. " " .. L["Button"] .. " %d"
        for slot = 1, NUM_ACTIONBAR_BUTTONS do
            _G[format("BINDING_NAME_BFIACTIONBAR9BUTTON%d", slot)] = format(text, slot)
        end

        -- class bar
        text = L["Class Bar %d"] .. " " .. L["Button"] .. " %d"
        for bar = 1, 4 do
            for slot = 1, NUM_ACTIONBAR_BUTTONS do
                _G[format("BINDING_NAME_BFICLASSBAR%dBUTTON%d", bar, slot)] = format(text, bar, slot)
            end
        end
        -------------------------------------------------------------------------------------------

        for name, id in pairs(BAR_MAPPINGS) do
            CreateBar(name, id)
        end
    end

    LAB.RegisterCallback(AB, "OnFlyoutSpells", ActionBar_FlyoutSpells)
    -- LAB.RegisterCallback(AB, "OnFlyoutUpdate", ActionBar_FlyoutUpdate)
    -- LAB.RegisterCallback(AB, "OnFlyoutButtonCreated", ActionBar_FlyoutCreated)

    AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)
    if AF.isRetail then
        AB:RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
        AB:RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
    end

    if which and which ~= "main" then
        UpdateBar(AB.bars[which], AB.config.general, AB.config.barConfig[which])
    else
        for name in pairs(BAR_MAPPINGS) do
            UpdateBar(AB.bars[name], AB.config.general, AB.config.barConfig[name])
        end
    end

    if AF.isRetail and C_PetBattles.IsInBattle() then
        RemoveBindings()
    else
        AssignBindings()
    end
end
AF.RegisterCallback("BFI_UpdateModule", UpdateMainBars)

AF.RegisterCallback("BFI_UpdateModule", function(_, module, which)
    if module ~= "actionBars" then return end
    if which and which ~= "flyout" then return end
    ActionBar_FlyoutSpells()
end)