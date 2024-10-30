---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@class AbstractFramework
local AF = _G.AbstractFramework
local U = BFI.utils
local AB = BFI.ActionBars

local LAB = BFI.libs.LAB

local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick

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
        AF.SetSize(b, AB.config.general.flyoutSize, AB.config.general.flyoutSize)
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
local function CreateBar(name, id)
    local moverName
    local global, index = name:match("(%a+)(%d+)")

    if global == "bar" then
        global = "BFI_ActionBar" .. index
        moverName = L["Action Bar"].." "..index
    elseif global == "classbar" then
        global = "BFI_ClassBar" .. index
        moverName = L["Class Bar"].." "..index
    end

    local bar = CreateFrame("Frame", global, AF.UIParent, "SecureHandlerStateTemplate")

    bar.id = id
    bar.name = name
    bar.buttons = {}

    AB.bars[name] = bar

    -- mover ----------------------------------------------------------------- --
    AF.CreateMover(bar, L["Action Bars"], moverName)

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
    AF.AddToPixelUpdater(bar)

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
                for _, key in pairs({GetBindingKey(b.keyBoundTarget)}) do
                    if key and key ~= "" then
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
-- update button
---------------------------------------------------------------------
local customExitButton = {
    func = function(button)
        VehicleExit()
    end,
    texture = AF.GetTexture("Exit", BFI.name),
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
    bar.buttonConfig.desaturateOnCooldown = shared.desaturateOnCooldown

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
            b:SetState(k, "action", (k - 1) * NUM_ACTIONBAR_BUTTONS + i)
        end
        b:SetState(0, "action", (bar.id - 1) * NUM_ACTIONBAR_BUTTONS + i)

        if i == NUM_ACTIONBAR_BUTTONS then
            if BFI.vars.isRetail then
                b:SetState(GetVehicleBarIndex(), "custom", customExitButton) -- 16
                b:SetState(GetTempShapeshiftBarIndex(), "custom", customExitButton) -- 17
                b:SetState(GetOverrideBarIndex(), "custom", customExitButton) -- 18
            -- else
            --     -- FIXME:
            --     b:SetState(11, "custom", customExitButton)
            --     b:SetState(12, "custom", customExitButton)
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
local BAR1_PAGING_DEFAULT = format("[overridebar] %d; [vehicleui][possessbar] %d; [shapeshift] %d; [bonusbar:5] 11;", GetOverrideBarIndex(), GetVehicleBarIndex(), GetTempShapeshiftBarIndex())
-- 18, 16, 17

local function UpdateBar(bar, general, shared, specific)
    bar.enabled = specific.enabled
    if not specific.enabled then
        bar:Hide()
        UnregisterStateDriver(bar, "visibility")
        return
    end

    RegisterStateDriver(bar, "visibility", specific.visibility)

    -- mover
    AF.UpdateMoverSave(bar, specific.position)

    -- bar
    AB.ReArrange(bar, specific.size, specific.spacing, specific.buttonsPerLine, specific.num, specific.anchor, specific.orientation)
    AF.LoadPosition(bar, specific.position)

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

    -- AutoPushSpellToActionBar
    SetCVar("AutoPushSpellToActionBar", AB.config.general.disableAutoAddSpells and 0 or 1)

    if not init then
        init = true

        -- binding frame --------------------------------------------------------------------------
        _G.BINDING_HEADER_BFI = AF.WrapTextInColor(BFI.name, "BFI")

        -- bar9
        local text = L["Action Bar"].." 9 "..L["Button"].." %d"
        for slot = 1, NUM_ACTIONBAR_BUTTONS do
            _G[format("BINDING_NAME_BFIACTIONBAR9BUTTON%d", slot)] = format(text, slot)
        end

        -- class bar
        text = L["Class Bar"].." %d "..L["Button"].." %d"
        for bar = 1, 4 do
            for slot = 1, NUM_ACTIONBAR_BUTTONS do
                _G[format("BINDING_NAME_BFICLASSBAR%dBUTTON%d", bar, slot)] = format(text, bar, slot)
            end
        end
        -------------------------------------------------------------------------------------------

        for name, id in pairs(BAR_MAPPINGS) do
            CreateBar(name, id)
        end

        LAB.RegisterCallback(AB, "OnFlyoutSpells", ActionBar_FlyoutSpells)
        -- LAB.RegisterCallback(AB, "OnFlyoutUpdate", ActionBar_FlyoutUpdate)
        -- LAB.RegisterCallback(AB, "OnFlyoutButtonCreated", ActionBar_FlyoutCreated)

        AB:RegisterEvent("UPDATE_BINDINGS", AssignBindings)
        if BFI.vars.isRetail then
            AB:RegisterEvent("PET_BATTLE_CLOSE", AssignBindings)
            AB:RegisterEvent("PET_BATTLE_OPENING_DONE", RemoveBindings)
        end
    end

    if barName then
        UpdateBar(AB.bars[barName], AB.config.general, AB.config.sharedButtonConfig, AB.config.barConfig[barName])
    else
        for name in pairs(BAR_MAPPINGS) do
            UpdateBar(AB.bars[name], AB.config.general, AB.config.sharedButtonConfig, AB.config.barConfig[name])
        end
    end

    if BFI.vars.isRetail and C_PetBattles.IsInBattle() then
        RemoveBindings()
    else
        AssignBindings()
    end
end
BFI.RegisterCallback("UpdateModules", "AB_MainBars", UpdateMainBars)