---@class BFI
local BFI = select(2, ...)
---@class AbstractWidgets
local AW = _G.AbstractWidgets

SLASH_BFI1 = "/bfi"
function SlashCmdList.BFI(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "mover" then
        AW.ToggleMovers()
    elseif command == "reset" then
        BFIConfig = nil
        ReloadUI()
    end
end