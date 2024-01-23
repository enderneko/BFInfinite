local addonName, ns = ...
local AW = ns.AW

---------------------------------------------------------------------
-- show / hide
---------------------------------------------------------------------
local function ShowTooltips(widget, anchor, x, y, content)
    local tooltip = _G[ns.prefix.."Tooltip"]

    if type(content) ~= "table" or #content == 0 then
        tooltip:Hide()
        return
    end

    tooltip:ClearLines()
    tooltip:SetOwner(widget, anchor or "ANCHOR_TOP", x or 0, y or 0)
    tooltip:AddLine(content[1], AW.GetColorRGB("accent"))
    for i = 2, #content do
        if content[i] then
            tooltip:AddLine(content[i], 1, 1, 1)
        end
    end
    tooltip:Show()
end

function AW.SetTooltips(widget, anchor, x, y, ...)
    widget.tooltips = {...}

    if not widget.tooltipsInited then
        widget._tooltipsInited = true

        widget:HookScript("OnEnter", function()
            ShowTooltips(widget, anchor, x, y, widget.tooltips)
        end)
        widget:HookScript("OnLeave", function()
            _G[ns.prefix.."Tooltip"]:Hide()
        end)
    end
end

function AW.ClearTooltips(widget)
    widget.tooltips = nil
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTooltip(name, hasIcon)
    local tooltip = CreateFrame("GameTooltip", name, UIParent, ns.prefix.."TooltipTemplate,BackdropTemplate")
    -- local tooltip = CreateFrame("GameTooltip", name, UIParent, "SharedTooltipTemplate,BackdropTemplate")
    tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    tooltip:SetBackdropBorderColor(AW.GetColorRGB("accent"))
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    if hasIcon then
        local iconBG = tooltip:CreateTexture(nil, "BACKGROUND")
        tooltip.iconBG = iconBG
        AW.SetSize(iconBG, 35, 35)
        AW.SetPoint(iconBG, "TOPRIGHT", tooltip, "TOPLEFT", -1, 0)
        iconBG:SetColorTexture(AW.GetColorRGB("accent"))
        iconBG:Hide()
        
        local icon = tooltip:CreateTexture(nil, "ARTWORK")
        tooltip.icon = icon
        AW.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
        AW.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:Hide()

        hooksecurefunc(tooltip, "SetSpellByID", function(self, id, tex)
            if tex then
                iconBG:Show()
                icon:SetTexture(tex)
                icon:Show()
            end
        end)
    end

    if AW.isRetail then
        tooltip:RegisterEvent("TOOLTIP_DATA_UPDATE")
        tooltip:SetScript("OnEvent", function()
            if tooltip:IsVisible() then
                -- Interface\FrameXML\GameTooltip.lua GameTooltipDataMixin:RefreshData()
                tooltip:RefreshData()
            end
        end)
    end

    -- tooltip:SetScript("OnTooltipSetItem", function()
    --     -- color border with item quality color
    --     tooltip:SetBackdropBorderColor(_G[name.."TextLeft1"]:GetTextColor())
    -- end)

    tooltip:SetScript("OnHide", function()
        tooltip:SetPadding(0, 0, 0, 0)

        -- reset border color
        tooltip:SetBackdropBorderColor(AW.GetColorRGB("accent"))

        -- SetX with invalid data may or may not clear the tooltip's contents.
        tooltip:ClearLines()

        if hasIcon then
            tooltip.iconBG:Hide()
            tooltip.icon:Hide()
        end
    end)

    function tooltip:UpdatePixels()
        AW.ReBorder(self)
        if hasIcon then
            AW.RePoint(self.iconBG)
            AW.RePoint(self.icon)
        end
    end

    AW.AddToPixelUpdater(tooltip)
end

CreateTooltip(ns.prefix.."Tooltip")
CreateTooltip(ns.prefix.."SpellTooltip", true)