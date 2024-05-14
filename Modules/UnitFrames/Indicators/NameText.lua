local _, BFI = ...
local U = BFI.utils
local AW = BFI.AW
local UF = BFI.M_UF

local function NameText_UpdateText(self, text)
    if self.length <= 1 then
        local width = self.relativeTo:GetWidth() - 2
        for i = string.utf8len(text), 0, -1 do
            self:_SetText(string.utf8sub(text, 1, i))
            if self:GetWidth() / width <= self.length then
                break
            end
        end
    end
end

local function NameText_SetName(self, unit, name, class)
    -- length
    if self.length <= 1 then
        local width = self.relativeTo:GetWidth() - 2
        for i = string.utf8len(name), 0, -1 do
            self:SetText(string.utf8sub(name, 1, i))
            if self:GetWidth() / width <= self.length then
                break
            end
        end
    end

    -- color
    local r, g, b
    if self.color.type == "class_color" then
        if U.UnitIsPlayer(unit) then
            r, g, b = AW.GetClassColor(class)
        else
            r, g, b = AW.GetReactionColor(unit)
        end
    else
        if U.UnitIsPlayer(unit) then
            if not UnitIsConnected(unit) then
                r, g, b = AW.GetClassColor(class)
            else
                r, g, b = unpack(self.color.rgb)
            end
        else
            r, g, b = unpack(self.color.rgb)
        end
    end
    self:SetTextColor(r, g, b)
end

local function NameText_SetFont(self, font, size, flags)

end

local function NameText_LoadConfig(self, config)
    local button = self:GetParent():GetParent()
    if config.anchorTo == "button" then
        AW.LoadWidgetPosition(self, config.position)
        self.relativeTo = button
    else
        if config.anchorTo == "healthBar" then
            AW.LoadWidgetPosition(self, config.position, button.indicators.healthBar)
            self.relativeTo = button.indicators.healthBar
        elseif config.anchorTo == "powerBar" then
            AW.LoadWidgetPosition(self, config.position, button.indicators.powerBar)
            self.relativeTo = button.indicators.powerBar
        end
    end

    self.length = config.length
    self.color = config.color
end

function UF.CreateNameText(parent)
    local text = parent.overlay:CreateFontString(nil, "OVERLAY", AW.GetFontName("normal"))

    text.SetName = NameText_SetName
    text.SetFont = NameText_SetFont
    text.LoadConfig = NameText_LoadConfig

    return text
end