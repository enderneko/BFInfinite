---@type BFI
local BFI = select(2, ...)
local L = BFI.L
---@class Funcs
local F = BFI.funcs
---@type AbstractFramework
local AF = _G.AbstractFramework

local changelogsFrame
local changelogs

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateChangelogsFrame()
    changelogsFrame = AF.CreateHeaderedFrame(AF.UIParent, "BFIChangelogsFrame", "BFI " .. L["Changelogs"], 400, 500, "HIGH", 999, true)
    changelogsFrame:SetPoint("CENTER")
    changelogsFrame:SetBackdropColor(AF.GetColorRGB("background", 0.9))
    changelogsFrame:Hide()

    --------------------------------------------------
    -- scroll
    --------------------------------------------------
    local scroll = AF.CreateScrollFrame(changelogsFrame, nil, nil, nil, "none", "none")
    scroll:SetAllPoints(changelogsFrame)

    --------------------------------------------------
    -- fonts
    --------------------------------------------------
    local h1Font = CreateFont("BFI_Changelogs_H1")
    h1Font:CopyFontObject(AF_FONT_TITLE)
    h1Font:SetTextColor(AF.GetColorRGB("BFI"))
    AF.AddToFontSizeUpdater(h1Font)

    local h2Font = CreateFont("BFI_Changelogs_H2")
    h2Font:CopyFontObject(AF_FONT_NORMAL)
    h2Font:SetTextColor(AF.GetColorRGB("BFI"))
    AF.AddToFontSizeUpdater(h2Font)

    local pFont = CreateFont("BFI_Changelogs_P")
    pFont:CopyFontObject(AF_FONT_NORMAL)
    AF.AddToFontSizeUpdater(pFont)

    --------------------------------------------------
    -- html
    --------------------------------------------------
    local html = CreateFrame("SimpleHTML", nil, scroll.scrollContent)
    AF.SetPoint(html, "TOP", 0, -15)
    AF.SetWidth(html, 370)

    html:SetFontObject("h1", h1Font)
    html:SetFontObject("h2", h2Font)
    html:SetFontObject("p", pFont)

    html:SetSpacing("h1", 9)
    html:SetSpacing("h2", 7)
    html:SetSpacing("p", 5)

    --------------------------------------------------
    -- load
    --------------------------------------------------
    function changelogsFrame:Load()
        changelogsFrame:Show()
        html:SetText("<html><body>" .. changelogs .. "</body></html>")
        RunNextFrame(function()
            html:SetHeight(html:GetContentHeight())
            scroll:SetContentHeight(html:GetHeight() + 30, true)
        end)
    end
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function F.ToggleChangelogsFrame()
    if not changelogsFrame then
        CreateChangelogsFrame()
    end

    if changelogsFrame:IsShown() then
        changelogsFrame:Hide()
    else
        changelogsFrame:Load()
    end
end

---------------------------------------------------------------------
-- changelogs
---------------------------------------------------------------------
if LOCALE_zhCN then
    changelogs = [[
<h1>r2-alpha (2025-10-14 17:30 GMT+8)</h1>
<p>- 新增职业强调色的支持</p>
<p>- 修复单位框体的预设问题</p>
<p>- 临时修复字体相关问题</p>
<p>- 更新增益与减益选项</p>
<p>- 更新字体选项</p>
<br/>

<h1>r1-alpha (2025-10-06 01:36 GMT+8)</h1>
<p>- 首次发布</p>
    ]]
else
    changelogs = [[
<h1>r2-alpha (2025-10-14 17:30 GMT+8)</h1>
<p>- Added class accent color support</p>
<p>- Fixed Unit Frames preset issues</p>
<p>- Temporary font fixes</p>
<p>- Updated Buffs &amp; Debuffs options</p>
<p>- Updated font options</p>
<br/>

<h1>r1-alpha (2025-10-06 01:36 GMT+8)</h1>
<p>- Initial release</p>
    ]]
end