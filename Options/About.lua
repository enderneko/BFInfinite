---@class BFI
local BFI = select(2, ...)
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local aboutPanel

---------------------------------------------------------------------
-- about panel
---------------------------------------------------------------------
local function CreateAboutPanel()
    aboutPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_AboutPanel")
    aboutPanel:SetAllPoints()
end

---------------------------------------------------------------------
-- bfi pane
---------------------------------------------------------------------
local bfiPane
local function CreateBFIPane()
    bfiPane = AF.CreateTitledPane(aboutPanel, "BFI", nil, 200)
    aboutPanel.bfiPane = bfiPane
    AF.SetPoint(bfiPane, "TOPLEFT", aboutPanel, 15, -15)
    AF.SetPoint(bfiPane, "TOPRIGHT", generalPanel, -15, -15)

    -- changelogs
    local changelogs = AF.CreateButton(bfiPane, L["Changelogs"], "BFI", 127, 17)
    AF.SetPoint(changelogs, "BOTTOMRIGHT", bfiPane.line, "TOPRIGHT")
    changelogs:SetEnabled(false)

    -- version
    local ver = strlower(L["Version"])

    local bfiVersion = AF.CreateFontString(bfiPane)
    AF.SetPoint(bfiVersion, "TOPLEFT", 10, -30)
    bfiVersion:SetText(AF.WrapTextInColor("BFI ", "BFI") .. ver .. ": " .. BFI.version)

    local afVersion = AF.CreateFontString(bfiPane)
    AF.SetPoint(afVersion, "LEFT", bfiVersion, 260, 0)
    afVersion:SetText(AF.WrapTextInColor("AbstractFramework ", "accent") .. ver .. ": " .. AF.version)

    -- author
    local author = AF.CreateFontString(bfiPane, AF.WrapTextInColor(L["Author"], "BFI") .. ": enderneko")
    AF.SetPoint(author, "TOPLEFT", bfiVersion, "BOTTOMLEFT", 0, -15)

    local authorName = AF.CreateFontString(bfiPane, "篠崎-影之哀伤 (CN)", "gray")
    authorName:SetPoint("LEFT", author, "RIGHT", 5, 0)
    AF.SetFont(authorName, "BFI", 13 + AF.fontSizeDelta, "none", false)
    AF.AddToFontSizeUpdater(authorName, 13)

    -- about
    local about = AF.CreateFontString(bfiPane, L["ABOUT"], "sand")
    AF.SetPoint(about, "LEFT", 10, 0)
    AF.SetPoint(about, "RIGHT", -10, 0)
    AF.SetPoint(about, "TOP", author, "BOTTOM", 0, -15)
    about:SetJustifyH("LEFT")
    about:SetWordWrap(true)
    about:SetSpacing(5)
end

---------------------------------------------------------------------
-- links pane
---------------------------------------------------------------------
local linksPane
local function CreateLinksPane()
    linksPane = AF.CreateTitledPane(aboutPanel, "Links", 270, 85)
    aboutPanel.linksPane = linksPane
    AF.SetPoint(linksPane, "TOPLEFT", bfiPane, "BOTTOMLEFT", 0, -20)

    local switch = AF.CreateSwitch(linksPane, nil, 25)
    AF.SetPoint(switch, "TOPLEFT", 10, -25)
    AF.SetPoint(switch, "TOPRIGHT", -10, -25)
    switch:SetLabels({
        {text = "", value = "github", url = "https://github.com/enderneko/BFInfinite"},
        {text = "", value = "curseforge", url = "https://www.curseforge.com/wow/addons/bfinfinite"},
        {text = "", value = "wago", url = "https://addons.wago.io/addons/bfinfinite"},
        {text = "", value = "discord", url = "https://discord.gg/9PSe3fKQGJ"},
        {text = "", value = "kook", url = "https://kook.vip/SPg8bl"},
        {text = "", value = "bilibili", url = "https://space.bilibili.com/139815"},
        -- {text = "", value = "ko-fi", url = "https://ko-fi.com/enderneko"},
        -- {text = "", value = "afdian", url = "https://afdian.com/a/enderneko"},
    })

    for _, b in next, switch.buttons do
        b.highlight:SetColor(AF.GetColorTable("BFI", 0.9))
        b:SetTexture(AF.GetLogo(b.value), {32, 32})
        b:EnablePushEffect(false)
        AF.SetInside(b.texture, b, 2)
        b.texture:SetDrawLayer("OVERLAY", 7)
        b.texture:SetTexCoord(AF.CalcTexCoordPreCrop(nil, b:GetWidth() / b:GetHeight(), 1, nil, true))
    end

    local box = AF.CreateEditBox(linksPane)
    AF.SetPoint(box, "TOPLEFT", switch, "BOTTOMLEFT", 0, -2)
    AF.SetPoint(box, "TOPRIGHT", switch, "BOTTOMRIGHT", 0, -2)
    box:SetNotUserChangable(true)

    switch:SetOnSelect(function(_, data)
        box:SetText(data.url)
        box:SetCursorPosition(0)
    end)

    switch:SetSelectedValue("github")
end

---------------------------------------------------------------------
-- slash commands pane
---------------------------------------------------------------------
local slashPane
local function CreateSlashCommandsPane()
    slashPane = AF.CreateTitledPane(aboutPanel, L["Slash Commands"], 250, 85)
    aboutPanel.slashPane = slashPane
    AF.SetPoint(slashPane, "TOPRIGHT", bfiPane, "BOTTOMRIGHT", 0, -20)

    local text = AF.CreateFontString(slashPane)
    AF.SetPoint(text, "TOPLEFT", 10, -30)
    text:SetJustifyH("LEFT")
    text:SetSpacing(5)

    local cmds = {
        {cmd = "/bfi", desc = L["Toggle BFI options"]},
        {cmd = "/bfi reset", desc = L["Reset all settings"]},
    }

    for i, info in next, cmds do
        if i ~= 1 then
            text:AppendText("\n")
        end
        text:AppendText(AF.WrapTextInColor(info.cmd, "accent") .. " - " .. info.desc)
    end
end

---------------------------------------------------------------------
-- translators pane
---------------------------------------------------------------------
local translatorsPane
local function CreateTranslatorsPane()
    translatorsPane = AF.CreateTitledPane(aboutPanel, L["Translators"], 260, 210)
    aboutPanel.translatorsPane = translatorsPane
    AF.SetPoint(translatorsPane, "TOPLEFT", linksPane, "BOTTOMLEFT", 0, -20)
end

---------------------------------------------------------------------
-- contributors pane
---------------------------------------------------------------------
local contributorsPane
local function CreateContributorsPane()
    contributorsPane = AF.CreateTitledPane(aboutPanel, L["Contributors"], 260, 210)
    aboutPanel.contributorsPane = contributorsPane
    AF.SetPoint(contributorsPane, "TOPRIGHT", slashPane, "BOTTOMRIGHT", 0, -20)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "about" then
        if not aboutPanel then
            CreateAboutPanel()
            CreateBFIPane()
            CreateLinksPane()
            CreateSlashCommandsPane()
            CreateTranslatorsPane()
            CreateContributorsPane()
        end
        aboutPanel:Show()
    elseif aboutPanel then
        aboutPanel:Hide()
    end
end)