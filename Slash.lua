---@class BFI
local BFI = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework

SLASH_BFI1 = "/bfi"
function SlashCmdList.BFI(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "mover" then
        AF.ToggleMovers()
    elseif command == "reset" then
        BFIConfig = nil
        BFIProfile = nil
        BFIPlayer = nil
        ReloadUI()
    else
        BFI.ToggleOptionsFrame()
    end
end