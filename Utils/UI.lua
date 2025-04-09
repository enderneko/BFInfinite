---@class BFI
local BFI = select(2, ...)
---@class Utils
local U = BFI.utils
---@type AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- hide frame
---------------------------------------------------------------------
function U.Hide(region)
    if not region then return end
    if region.UnregisterAllEvents then
        region:UnregisterAllEvents()
        region:SetParent(AF.hiddenParent)
    else
        region.Show = region.Hide
    end
    region:Hide()
end

---------------------------------------------------------------------
-- remove texture
---------------------------------------------------------------------
function U.RemoveTexture(texture)
    texture:SetTexture(AF.GetEmptyTexture())
    texture:SetAtlas("")
end

---------------------------------------------------------------------
-- disable edit mode
---------------------------------------------------------------------
function U.DisableEditMode(region)
    region.HighlightSystem = AF.noop
    region.ClearHighlight = AF.noop
end

---------------------------------------------------------------------
-- skin
---------------------------------------------------------------------
local BLIZZARD_REGION_TEXTURES = {
    "Left",
    "FocusLeft",

    "Right",
    "FocusRight",

    "Middle",
    "Mid",
    "FocusMid",

    -- "LeftDisabled",
    -- "MiddleDisabled",
    -- "RightDisabled",
    -- "BorderBottom",
    -- "BorderBottomLeft",
    -- "BorderBottomRight",
    -- "BorderLeft",
    -- "BorderRight",
    -- "TopLeft",
    -- "TopRight",
    -- "BottomLeft",
    -- "BottomRight",
    -- "TopMiddle",
    -- "MiddleLeft",
    -- "MiddleRight",
    -- "BottomMiddle",
    -- "MiddleMiddle",
    -- "TabSpacer",
    -- "TabSpacer1",
    -- "TabSpacer2",
    -- "_RightSeparator",
    -- "_LeftSeparator",
    -- "Cover",
    -- "Border",
    -- "Background",
    -- "TopTex",
    -- "TopLeftTex",
    -- "TopRightTex",
    -- "LeftTex",
    -- "BottomTex",
    -- "BottomLeftTex",
    -- "BottomRightTex",
    -- "RightTex",
    -- "MiddleTex",
    -- "Center"
}

local function HideBlizzardTextures(frame)
    local name = frame:GetName()
    local tex
    for _, r in pairs(BLIZZARD_REGION_TEXTURES) do
        tex = name and _G[name .. r] or frame[r]
        if tex then
            tex:Hide()
            tex:SetAlpha(0)
        end
    end
end

function U.ReSkinEditBox(frame)
    HideBlizzardTextures(frame)
    AF.ApplyDefaultBackdrop(frame)
    frame:SetBackdropColor(AF.GetColorRGB("background"))
    frame:SetBackdropBorderColor(AF.GetColorRGB("border"))
end