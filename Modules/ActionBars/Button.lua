local _, BFI = ...
local AW = BFI.AW
local AB = BFI.M_AB

local eventFrame = CreateFrame("Frame")
local wrapFrame = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

function AB.CreateButton(parent, id, name)
    local b = CreateFrame("CheckButton", name, parent, "BackdropTemplate,SecureActionButtonTemplate")
    AW.StylizeFrame(b)

    -- mouseover highlight --------------------------------------------------- --
    b.mouseOverHighlight = AW.CreateTexture(b, nil, AW.GetColorTable("accent", 0.2), "HIGHLIGHT")
    b.mouseOverHighlight:SetAllPoints()

    b:SetAttribute("type", "action")
    b:SetAttribute("action", 2)
    b:SetAttribute("typerelease", "actionrelease");
    b:SetAttribute("checkselfcast", true);
    b:SetAttribute("checkfocuscast", true);
    b:SetAttribute("checkmouseovercast", true);
    b:SetAttribute("useparent-unit", true);
    b:SetAttribute("useparent-actionpage", true);
    b:RegisterForDrag("LeftButton", "RightButton");
    b:RegisterForClicks("AnyUp", "LeftButtonDown", "RightButtonDown");

    -- OnClick --------------------------------------------------------------- --
    wrapFrame:WrapScript(b, "OnClick", [[
        -- print("onclick", IsPressHoldReleaseSpell)
    ]])

    wrapFrame:WrapScript(b, "OnReceiveDrag", [[
        print(kind, value, ...)

        if kind == "spell" then
            local spellId = select(2, ...)
            
        elseif kind == "item" and value then

        end

        -- local type, value, subType, extra = ...
        -- print(type, value, subType, extra)
    ]])

    return b
end