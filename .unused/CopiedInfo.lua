---@type BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local copiedInfoFrame
local info = {}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTextFrame(label)
    local frame = AF.CreateBorderedFrame(copiedInfoFrame, nil, nil, 20, "widget")

    frame.text = AF.CreateFontString(frame)
    frame.text:SetWordWrap(false)
    AF.SetPoint(frame.text, "RIGHT", -5, 0)

    if label then
        frame.label = AF.CreateFontString(frame, label, "darkgray")
        AF.SetPoint(frame.label, "LEFT", 5, 0)
        AF.SetPoint(frame.text, "LEFT", frame.label, "RIGHT", 10, 0)
        frame.text:SetJustifyH("RIGHT")
    else
        AF.SetPoint(frame.text, "LEFT", 5, 0)
        frame.text:SetJustifyH("LEFT")
    end

    return frame
end

local function CreateCopiedInfoFrame()
    copiedInfoFrame = AF.CreateHeaderedFrame(BFIOptionsFrame, "BFIOptionsFrame_CopiedInfoFrame", L["Copied"], 170, 200)
    copiedInfoFrame:SetMovable(false)
    copiedInfoFrame:SetTitleJustify("LEFT")
    AF.SetPoint(copiedInfoFrame, "TOPLEFT", BFIOptionsFrame_ContentPane, "TOPRIGHT", 7, 0)

    copiedInfoFrame.header.closeBtn:Hide()
    copiedInfoFrame.header.tex:Hide()
    copiedInfoFrame.header:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    AF.SetHeight(copiedInfoFrame.header, 21)

    local discard = AF.CreateButton(copiedInfoFrame.header, L["Discard"], "red", 55, 21)
    discard:SetPoint("TOPRIGHT")
    discard:SetOnClick(function()
        copiedInfoFrame:Hide()
        wipe(info)
    end)

    local source = CreateTextFrame()
    copiedInfoFrame.source = source
    AF.SetPoint(source, "TOPLEFT", copiedInfoFrame, 7, -7)
    AF.SetPoint(source, "TOPRIGHT", copiedInfoFrame, -7, -7)

    local config = CreateTextFrame()
    copiedInfoFrame.config = config
    AF.SetPoint(config, "TOPLEFT", source, "BOTTOMLEFT", 0, -7)
    AF.SetPoint(config, "TOPRIGHT", source, "BOTTOMRIGHT", 0, -7)

    local from = CreateTextFrame(L["From"])
    copiedInfoFrame.from = from
    AF.SetPoint(from, "TOPLEFT", config, "BOTTOMLEFT", 0, -17)
    AF.SetPoint(from, "TOPRIGHT", config, "BOTTOMRIGHT", 0, -17)

    local to = CreateTextFrame(L["To"])
    copiedInfoFrame.to = to
    AF.SetPoint(to, "TOPLEFT", from, "BOTTOMLEFT", 0, -7)
    AF.SetPoint(to, "TOPRIGHT", from, "BOTTOMRIGHT", 0, -7)

    local paste = AF.CreateButton(copiedInfoFrame, L["Paste"], "BFI_hover", nil, 20)
    copiedInfoFrame.paste = paste
    AF.SetPoint(paste, "BOTTOMLEFT", 7, 7)
    AF.SetPoint(paste, "BOTTOMRIGHT", -7, 7)
    paste:SetOnClick(function()
        texplore(info)
    end)
end

local function LoadCopiedInfo()
    copiedInfoFrame.source.text:SetText(L[info.id or info.module])
    copiedInfoFrame.config.text:SetText(L[info.subId or "All Configs"])
    copiedInfoFrame.from.text:SetText(info.from)
    copiedInfoFrame.to.text:SetText(info.to)

    copiedInfoFrame:Show()
end

---------------------------------------------------------------------
-- BFI_ShowCopiedInfo
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowCopiedInfo", function(_, module, id, subId, ownerName, time, config)
    if not copiedInfoFrame then
        CreateCopiedInfoFrame()
    end

    info.module = module
    info.id = id
    info.subId = subId
    info.time = time
    info.from = ownerName
    info.to = nil
    info.fromConfig = AF.Copy(config)
    info.toConfig = nil

    LoadCopiedInfo()

    -- check to enable paste button
    AF.Fire("BFI_CheckCopiedInfo", module, id, ownerName, config)
end)

---------------------------------------------------------------------
-- BFI_CheckCopiedInfo
---------------------------------------------------------------------
AF.RegisterCallback("BFI_CheckCopiedInfo", function(_, module, id, ownerName, config)
    if not copiedInfoFrame or AF.IsEmpty(info) then return end

    copiedInfoFrame:SetShown(module == info.module)
    info.to = ownerName
    info.toConfig = config

    if module == info.module and id == info.id then
        copiedInfoFrame.paste:SetEnabled(true)
    else
        copiedInfoFrame.paste:SetEnabled(false)
    end

    LoadCopiedInfo()
end)