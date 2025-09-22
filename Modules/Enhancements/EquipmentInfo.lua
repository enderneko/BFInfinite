---@class BFI
local BFI = select(2, ...)
---@class Enhancements
local E = BFI.modules.Enhancements
---@type AbstractFramework
local AF = _G.AbstractFramework

local _G = _G
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemDurability = GetInventoryItemDurability
local GetItemInfo = GetItemInfo
local GetTooltipData = C_TooltipInfo.GetHyperlink
local GetItemQualityColor = C_Item.GetItemQualityColor
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetItemStats = C_Item.GetItemStats
local EquipmentManager_GetLocationData = EquipmentManager_GetLocationData
local EquipmentFlyoutFrame = _G.EquipmentFlyoutFrame
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION

local strsplit = strsplit

local MIN_ITEM_LEVEL = 600 -- for enhancements check
local ITEM_LEVEL_PATTERN = "^" .. string.gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")
local ITEM_QUALITY_PATTERN = "^|cnIQ(%d):|Hitem.*"
local ITEM_STRING_PATTERN = "|cnIQ%d:|Hitem:(.+)|h.*|h|r"

local SLOTS = {
    [1] = "HeadSlot",
    [2] = "NeckSlot",
    [3] = "ShoulderSlot",
    [5] = "ChestSlot",
    [6] = "WaistSlot",
    [7] = "LegsSlot",
    [8] = "FeetSlot",
    [9] = "WristSlot",
    [10] = "HandsSlot",
    [11] = "Finger0Slot",
    [12] = "Finger1Slot",
    [13] = "Trinket0Slot",
    [14] = "Trinket1Slot",
    [15] = "BackSlot",
    [16] = "MainHandSlot",
    [17] = "SecondaryHandSlot"
}

local SOCKET_CHECK = {
    [2] = 2, -- neck
    [11] = 2, -- finger 0
    [12] = 2, -- finger 1
}

local ENCHANT_CHECK = {
    [5] = true, -- chest
    [7] = true, -- legs
    [8] = true, -- feet
    [9] = true, -- wrist
    [11] = true, -- finger 0
    [12] = true, -- finger 1
    [15] = true, -- back
    [16] = true, -- main hand
    -- [17] = true, -- off hand
}

---------------------------------------------------------------------
-- GetItemLevel
---------------------------------------------------------------------
function E.GetItemLevel(itemLink)
    if AF.IsBlank(itemLink) then return end

    local level, tooltipLevel, tooltipData

    level = select(4, GetItemInfo(itemLink))

    tooltipData = GetTooltipData(itemLink)
    if tooltipData and tooltipData.lines then
        for i = 2, #tooltipData.lines do
            local line = tooltipData.lines[i]
            if line.leftText and line.leftText:find(ITEM_LEVEL_PATTERN) then
                tooltipLevel = line.leftText:match(ITEM_LEVEL_PATTERN)
                tooltipLevel = tonumber(tooltipLevel)
                break
            end
        end
    end

    return tooltipLevel or level
end

---------------------------------------------------------------------
-- overlay
---------------------------------------------------------------------
local overlays = {}

local function Overlay_UpdateItemLevel(overlay, clear)
    if clear or not overlay.itemLink then
        overlay.itemLevel:SetText("")
        return
    end

    local level = E.GetItemLevel(overlay.itemLink)
    overlay.level = level
    overlay.itemLevel:SetText(level or "")

    local quality = overlay.itemLink:match(ITEM_QUALITY_PATTERN)
    local r, g, b
    if E.config.equipmentInfo.itemLevel.color.type == "quality_color" then
        r, g, b = GetItemQualityColor(quality)
    else
        r, g, b = AF.UnpackColor(E.config.equipmentInfo.itemLevel.color.rgb)
    end
    overlay.itemLevel:SetTextColor(r, g, b)
end

local function Overlay_UpdateDurability(overlay)
    if not overlay.slot then
        overlay.durability:SetAlpha(0)
        overlay.durability:SetValue(0)
        return
    end

    local current, maximum =  GetInventoryItemDurability(overlay.slot)

    -- if not overlay.test then
    --     overlay.test = true
    --     current, maximum = 50, 100
    --     C_Timer.After(3, function()
    --         Overlay_UpdateDurability(overlay)
    --     end)
    -- else
    --     current, maximum =  100, 100
    -- end

    if current and maximum then
        overlay.durability:SetMinMaxSmoothedValue(0, maximum)
        overlay.durability:SetSmoothedValue(current)

        local color = E.config.equipmentInfo.durability.color

        local p = current / maximum
        local r, g, b = AF.ColorGradient(p,
            color.low[1], color.low[2], color.low[3],
            color.medium[1], color.medium[2], color.medium[3],
            color.high[1], color.high[2], color.high[3]
        )
        overlay.durability:SetStatusBarColor(r, g, b)

        if p <= E.config.equipmentInfo.durability.glowBelow then
            AF.ShowNormalGlow(overlay.durability, {r, g, b})
        else
            AF.HideNormalGlow(overlay.durability)
        end

        if current == maximum and E.config.equipmentInfo.durability.hideAtFull then
            C_Timer.After(0.5, function()
                AF.FrameFadeOut(overlay.durability)
            end)
        else
            AF.FrameFadeIn(overlay.durability)
        end
    else
        overlay.durability:SetAlpha(0)
        overlay.durability:SetValue(0)
    end
end

local function Overlay_UpdateMissingEnhance(overlay, clear)
    if clear or not overlay.itemLink or not overlay.level or overlay.level < MIN_ITEM_LEVEL then
        overlay.missingEnhance:SetAlpha(0)
        return
    end

    local missingEnchant, missingGem

    local itemStats = GetItemStats(overlay.itemLink)
    local itemString = overlay.itemLink:match(ITEM_STRING_PATTERN)
    -- itemID : enchantID : gemID1 : gemID2 : gemID3 : gemID4 : suffixID : uniqueID : linkLevel : specializationID : modifiersMask : itemContext
    -- : numBonusIDs[:bonusID1:bonusID2:...] : numModifiers[:modifierType1:modifierValue1:...]
    -- : relic1NumBonusIDs[:relicBonusID1:relicBonusID2:...] : relic2NumBonusIDs[...] : relic3NumBonusIDs[...]
    -- : crafterGUID : extraEnchantID
    local enchant

    overlay.gems = overlay.gems or {}
    enchant, overlay.gems[1], overlay.gems[2], overlay.gems[3], overlay.gems[4] = select(2, strsplit(":", itemString))

    if ENCHANT_CHECK[overlay.slot] and AF.IsBlank(enchant) then
        missingEnchant = true
    end

    if itemStats then
        local sockets = itemStats["EMPTY_SOCKET_PRISMATIC"]

        if SOCKET_CHECK[overlay.slot] and SOCKET_CHECK[overlay.slot] ~= sockets then
            -- missing socket
            missingGem = true
        elseif sockets then
            for i = 1, sockets do
                if AF.IsBlank(overlay.gems[i]) then
                    missingGem = true
                    break
                end
            end
        end
    end

    overlay.missingEnchant:SetShown(missingEnchant)
    overlay.missingGem:SetShown(missingGem)

    if missingEnchant or missingGem then
        local size = E.config.equipmentInfo.missingEnhance.size

        overlay.missingEnhance:SetAlpha(1)
        AF.ClearPoints(overlay.missingEnchant)
        AF.ClearPoints(overlay.missingGem)

        if missingEnchant and missingGem then
            AF.SetHeight(overlay.missingEnhance, size)
            AF.SetListWidth(overlay.missingEnhance, 2, size, 1)
            AF.SetPoint(overlay.missingEnchant, "BOTTOMLEFT")
            AF.SetPoint(overlay.missingGem, "BOTTOMLEFT", overlay.missingEnchant, "BOTTOMRIGHT", 1, 0)
        elseif missingEnchant then
            AF.SetSize(overlay.missingEnhance, size, size)
            AF.SetPoint(overlay.missingEnchant, "BOTTOMLEFT")
        elseif missingGem then
            AF.SetSize(overlay.missingEnhance, size, size)
            AF.SetPoint(overlay.missingGem, "BOTTOMLEFT")
        end
    else
        overlay.missingEnhance:SetAlpha(0)
    end
end

local function Overlay_LoadConfig(overlay)
    -- item level
    local config = E.config.equipmentInfo.itemLevel
    if config.enabled then
        overlay.itemLevel:Show()
        AF.LoadPosition(overlay.itemLevel, config.position)
        AF.SetFont(overlay.itemLevel, config.font)
        overlay:UpdateItemLevel()
    else
        overlay.itemLevel:Hide()
    end

    -- durability
    config = E.config.equipmentInfo.durability
    if overlay.durability and config.enabled then
        overlay.durability:Show()
        if config.position == "TOP" then
            AF.SetPoint(overlay.durability, "TOPLEFT", config.margin, -config.margin)
            AF.SetPoint(overlay.durability, "TOPRIGHT", -config.margin, -config.margin)
            overlay.durability:SetOrientation("HORIZONTAL")
            AF.SetHeight(overlay.durability, config.size)
        elseif config.position == "BOTTOM" then
            AF.SetPoint(overlay.durability, "BOTTOMLEFT", config.margin, config.margin)
            AF.SetPoint(overlay.durability, "BOTTOMRIGHT", -config.margin, config.margin)
            overlay.durability:SetOrientation("HORIZONTAL")
            AF.SetHeight(overlay.durability, config.size)
        elseif config.position == "LEFT" then
            AF.SetPoint(overlay.durability, "TOPLEFT", config.margin, -config.margin)
            AF.SetPoint(overlay.durability, "BOTTOMLEFT", config.margin, config.margin)
            overlay.durability:SetOrientation("VERTICAL")
            AF.SetWidth(overlay.durability, config.size)
        elseif config.position == "RIGHT" then
            AF.SetPoint(overlay.durability, "TOPRIGHT", -config.margin, -config.margin)
            AF.SetPoint(overlay.durability, "BOTTOMRIGHT", -config.margin, config.margin)
            overlay.durability:SetOrientation("VERTICAL")
            AF.SetHeight(overlay.durability, config.size)
        end
        overlay:UpdateDurability()
    elseif overlay.durability then
        overlay.durability:Hide()
    end

    -- missingEnhance
    config = E.config.equipmentInfo.missingEnhance
    if overlay.missingEnhance and config.enabled then
        overlay.missingEnhance:Show()
        AF.LoadPosition(overlay.missingEnhance, config.position)
        -- AF.SetSize(overlay.missingEnhance, config.size, config.size)
        AF.SetSize(overlay.missingEnchant, config.size, config.size)
        AF.SetSize(overlay.missingGem, config.size, config.size)
        overlay:UpdateMissingEnhance()
    elseif overlay.missingEnhance then
        overlay.missingEnhance:Hide()
    end
end

local function CreateOverlay(slot, isInspect, flyout)
    local overlay = CreateFrame("Frame", nil, slot)
    overlay:SetAllPoints()
    AF.SetFrameLevel(overlay, 5)

    overlay.itemLevel = AF.CreateFontString(overlay)

    if not (isInspect or flyout) then
        overlay.durability = AF.CreateBlizzardStatusBar(overlay)
        AF.ShowNormalGlow(overlay.durability, "red")
        AF.CreateBlinkAnimation(overlay.durability.normalGlow, 0.5, true)
        AF.HideNormalGlow(overlay.durability)
    end

    if not flyout then
        overlay.missingEnhance = AF.CreateFrame(overlay)

        overlay.missingEnchant = AF.CreateBorderedFrame(overlay.missingEnhance, nil, nil, nil, "background", "red")
        overlay.missingEnchant:Hide()
        AF.CreateBlinkAnimation(overlay.missingEnchant)
        overlay.missingEnchant.texture = AF.CreateTexture(overlay.missingEnchant, 463531) -- inv_misc_enchantedscroll
        AF.ApplyDefaultTexCoord(overlay.missingEnchant.texture)
        AF.SetOnePixelInside(overlay.missingEnchant.texture)

        overlay.missingGem = AF.CreateBorderedFrame(overlay.missingEnhance, nil, nil, nil, "background", "red")
        overlay.missingGem:Hide()
        AF.CreateBlinkAnimation(overlay.missingGem)
        overlay.missingGem.texture = AF.CreateTexture(overlay.missingGem, 531777) -- inv_misc_epicgem_uncut_01
        AF.ApplyDefaultTexCoord(overlay.missingGem.texture)
        AF.SetOnePixelInside(overlay.missingGem.texture)
    end

    overlay.UpdateItemLevel = Overlay_UpdateItemLevel
    overlay.UpdateDurability = Overlay_UpdateDurability
    overlay.UpdateMissingEnhance = Overlay_UpdateMissingEnhance
    overlay.LoadConfig = Overlay_LoadConfig

    return overlay
end

local function GetOverlay(id, isInspect, flyout)
    local slot
    if flyout then
        slot = flyout
    elseif isInspect then
        slot = _G["Inspect" .. SLOTS[id]]
    else
        slot = _G["Character" .. SLOTS[id]]
    end

    local overlay = overlays[slot]
    if not overlay then
        overlay = CreateOverlay(slot, isInspect, flyout)
        overlays[slot] = overlay
        overlay:LoadConfig()
    end

    if flyout then
        local flyoutSettings = EquipmentFlyoutFrame.button:GetParent().flyoutSettings
        if flyoutSettings.useItemLocation then -- type(flyout.location) == "table"
            -- flyout:GetItemLocation()
            if flyout.location:IsBagAndSlot() then
                local bag, slot = flyout.location:GetBagAndSlot()
                overlay.itemLink = GetContainerItemLink(bag, slot)
            elseif flyout.location:IsEquipmentSlot() then
                local slot = flyout.location:GetEquipmentSlot()
                overlay.itemLink = GetInventoryItemLink("player", slot)
            end
        else -- type(flyout.location) == "number"
            if flyout.location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
                overlay.itemLink = nil
            else
                local data = EquipmentManager_GetLocationData(flyout.location)
                if data.bag and data.slot then
                    overlay.itemLink = GetContainerItemLink(data.bag, data.slot)
                else
                    overlay.itemLink = GetInventoryItemLink("player", data.slot)
                end
            end
        end
    else
        overlay.itemLink = GetInventoryItemLink(isInspect and "target" or "player", id)
        overlay.slot = id
    end

    return overlay
end

---------------------------------------------------------------------
-- player
---------------------------------------------------------------------
local function UpdatePlayer(_, _, slot)
    local itemLevelEnabled = E.config.equipmentInfo.itemLevel.enabled
    local missingEnhanceEnabled = E.config.equipmentInfo.missingEnhance.enabled

    local overlay
    if slot then
        overlay = GetOverlay(slot)
        if itemLevelEnabled then overlay:UpdateItemLevel() end
        if missingEnhanceEnabled then overlay:UpdateMissingEnhance() end
    else
        for slot in next, SLOTS do
            overlay = GetOverlay(slot)
            if itemLevelEnabled then overlay:UpdateItemLevel() end
            if missingEnhanceEnabled then overlay:UpdateMissingEnhance() end
        end
    end
end

---------------------------------------------------------------------
-- inspect
---------------------------------------------------------------------
local function UpdateInspect()
    local itemLevelEnabled = E.config.equipmentInfo.itemLevel.enabled
    local missingEnhanceEnabled = E.config.equipmentInfo.missingEnhance.enabled

    for slot in next, SLOTS do
        local overlay = GetOverlay(slot, true)
        if itemLevelEnabled then overlay:UpdateItemLevel() end
        if missingEnhanceEnabled then overlay:UpdateMissingEnhance() end
    end
end

local function DelayedUpdateInspect()
    AF.DelayedInvoke(0.5, UpdateInspect)
end

local function ClearInspect()
    local itemLevelEnabled = E.config.equipmentInfo.itemLevel.enabled
    local missingEnhanceEnabled = E.config.equipmentInfo.missingEnhance.enabled

    for slot in next, SLOTS do
        local overlay = GetOverlay(slot, true)
        if itemLevelEnabled then overlay:UpdateItemLevel(true) end
        if missingEnhanceEnabled then overlay:UpdateMissingEnhance(true) end
    end
end

---------------------------------------------------------------------
-- durability
---------------------------------------------------------------------
local function UpdateDurability(_, _, slot)
    if not E.config.equipmentInfo.durability.enabled then return end

    if slot then
        GetOverlay(slot):UpdateDurability()
    else
        for slot in next, SLOTS do
            GetOverlay(slot):UpdateDurability()
        end
    end
end

local function DelayedUpdateDurability()
    AF.DelayedInvoke(1, UpdateDurability)
end

---------------------------------------------------------------------
-- UpdateAll
---------------------------------------------------------------------
local function UpdateAll()
    UpdatePlayer()
    UpdateDurability()
end

local function DelayedUpdateAll()
    AF.DelayedInvoke(0.1, UpdateAll)
end

---------------------------------------------------------------------
-- UpdateFlyout
---------------------------------------------------------------------
local function UpdateFlyout(button, paperDollItemSlot)
    if not (E.config.equipmentInfo.enabled and E.config.equipmentInfo.itemLevel.enabled) then return end
    GetOverlay(nil, nil, button):UpdateItemLevel()
end

---------------------------------------------------------------------
-- BFI_UpdateConfig
---------------------------------------------------------------------
local function UpdateConfig(_, module, which)
    if module ~= "enhancements" and which ~= "equipmentInfo" then return end

    if not E.config.equipmentInfo.enabled then
        for _, overlay in pairs(overlays) do
            overlay:Hide()
        end
        return
    end

    for _, overlay in pairs(overlays) do
        overlay:Show()
        overlay:LoadConfig()
    end
end
AF.RegisterCallback("BFI_UpdateConfig", UpdateConfig)

---------------------------------------------------------------------
-- init
---------------------------------------------------------------------
local function Init()
    E:UnregisterEvent("PLAYER_ENTERING_WORLD", Init)
    -- if not E.config.equipmentInfo.enabled then return end

    _G.CharacterFrame:HookScript("OnShow", function()
        if not E.config.equipmentInfo.enabled then return end
        E:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", UpdateAll)
        E:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player", DelayedUpdateAll)
        E:RegisterEvent("UPDATE_INVENTORY_DURABILITY", DelayedUpdateDurability)
        DelayedUpdateAll()
    end)

    _G.CharacterFrame:HookScript("OnHide", function()
        if not E.config.equipmentInfo.enabled then return end
        E:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", UpdateAll)
        E:UnregisterEvent("UNIT_INVENTORY_CHANGED", DelayedUpdateAll) -- enchantments
        E:UnregisterEvent("UPDATE_INVENTORY_DURABILITY", DelayedUpdateDurability)
    end)

    -- Interface\AddOns\Blizzard_FrameXML\EquipmentFlyout.lua
    -- hooksecurefunc("EquipmentFlyout_DisplayButton", UpdateFlyout)
    hooksecurefunc("EquipmentFlyout_UpdateItems", function()
        for i, button in next, EquipmentFlyoutFrame.buttons do
            if button:IsShown() then
                UpdateFlyout(button)
            end
        end
    end)
end
E:RegisterEvent("PLAYER_ENTERING_WORLD", Init)

local function InspectLoaded()
    AF.UnregisterAddonLoaded("Blizzard_InspectUI", InspectLoaded)
    -- if not E.config.equipmentInfo.enabled then return end

    _G.InspectFrame:HookScript("OnShow", function()
        if not E.config.equipmentInfo.enabled then return end
        E:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "target", DelayedUpdateInspect)
        ClearInspect()
        DelayedUpdateInspect()
    end)

    _G.InspectFrame:HookScript("OnHide", function()
        if not E.config.equipmentInfo.enabled then return end
        E:UnregisterEvent("UNIT_INVENTORY_CHANGED", DelayedUpdateInspect)
    end)
end
AF.RegisterAddonLoaded("Blizzard_InspectUI", InspectLoaded)