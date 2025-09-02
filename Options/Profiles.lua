---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local profilesPanel
local rolePane, specPane, characterPane, managementPane
local selectedProfile, selectedHighlight, assignmentFrame
local LoadAll

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateProfilesPanel()
    profilesPanel = AF.CreateFrame(BFIOptionsFrame_ContentPane, "BFIOptionsFrame_ProfilesPanel")
    profilesPanel:SetAllPoints()
    AF.ApplyCombatProtectionToFrame(profilesPanel)
end

---------------------------------------------------------------------
-- profile button
---------------------------------------------------------------------
local profileButtons = {}

local function ProfileButton_SetText(self, text)
    if text == "default" then
        text = _G.DEFAULT
    end
    self.text:SetText(text)
end

-- reset
local function ProfileButton_OnClick(self)
    if self.typeName == "role" then
        BFIConfig.profileAssignment.role[self.typeValue] = "default"
        self:SetText("default")
    elseif self.typeName == "spec" then
        BFIConfig.profileAssignment.spec[self.typeValue] = nil
        self:SetText("")
    elseif self.typeName == "character" then
        BFIConfig.profileAssignment.character[self.typeValue] = nil
        self:SetText("")
    end

    if BFI.vars.profileTypeValue == self.typeValue then
        F.LoadProfile()
        LoadAll()
    end
end

local function CreateProfileButton(parent, typeName, typeValue, icon)
    local button = AF.CreateButton(parent, nil, "BFI_hover", 155, 20)

    profileButtons[typeName] = profileButtons[typeName] or {}
    profileButtons[typeName][typeValue] = button

    button._isProfileReceiver = true
    button.typeName = typeName
    button.typeValue = typeValue
    button.SetText = ProfileButton_SetText

    button:EnablePushEffect(false)
    button:SetTextJustifyH("LEFT")

    if icon then
        button:SetTexture(icon, nil, {"LEFT", 2, 0}, nil, typeName ~= "role" and "border", "LEFT")
    end

    button:RegisterForClicks("RightButtonUp")
    button:SetOnClick(ProfileButton_OnClick)

    return button
end

---------------------------------------------------------------------
-- role pane
---------------------------------------------------------------------
local function CreateRolePane()
    rolePane = AF.CreateTitledPane(profilesPanel, L["Spec Role Profiles"], 340, 85)
    AF.SetPoint(rolePane, "TOPLEFT", profilesPanel, 15, -15)

    local tip = AF.CreateFontString(rolePane, L["lowest priority"], "tip")
    AF.SetPoint(tip, "BOTTOMRIGHT", rolePane.line, "TOPRIGHT", 0, 2)

    local tank = CreateProfileButton(rolePane, "role", "TANK", AF.GetIcon("Role_Blizzard_TANK"))
    AF.SetPoint(tank, "TOPLEFT", rolePane, 10, -27)

    local healer = CreateProfileButton(rolePane, "role", "HEALER", AF.GetIcon("Role_Blizzard_HEALER"))
    AF.SetPoint(healer, "TOPLEFT", tank, "TOPRIGHT", 10, 0)

    local damager = CreateProfileButton(rolePane, "role", "DAMAGER", AF.GetIcon("Role_Blizzard_DAMAGER"))
    AF.SetPoint(damager, "TOPLEFT", tank, "BOTTOMLEFT", 0, -10)

    function rolePane.Load()
        tank:SetText(BFIConfig.profileAssignment.role.TANK)
        healer:SetText(BFIConfig.profileAssignment.role.HEALER)
        damager:SetText(BFIConfig.profileAssignment.role.DAMAGER)
    end
end

---------------------------------------------------------------------
-- spec pane
---------------------------------------------------------------------
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local function CreateSpecWidget(classID)
    local classFile = AF.GetClassFile(classID)

    local widget = CreateFrame("Frame", nil, specPane)

    -- header
    local header = AF.CreateBorderedFrame(widget)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    AF.SetHeight(header, 20)

    -- local icon = AF.CreateIcon(widget, AF.GetClassIcon(classID))
    -- AF.SetPoint(icon, "TOPLEFT", 5, -5)

    local name = AF.CreateFontString(header, AF.GetLocalizedClassName(classID), classFile)
    AF.SetPoint(name, "LEFT", 5, 0)

    local icon = AF.CreateTexture(header, AF.GetClassIcon(classID))
    AF.SetSize(icon, 64, 64)
    AF.SetPoint(icon, "TOPRIGHT", -1, 15)
    -- icon:SetTexCoord(AF.CalcTexCoordPreCrop(0, 64 / 20, nil, "RIGHT", true))

    local mask = header:CreateMaskTexture()
    mask:SetTexture(AF.GetTexture("Gradient_Linear_Right"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    AF.SetWidth(mask, 64)
    AF.SetPoint(mask, "TOPRIGHT", -1, -1)
    AF.SetPoint(mask, "BOTTOMRIGHT", -1, 1)
    icon:AddMaskTexture(mask)

    -- bg
    local bg = AF.CreateTexture(widget, AF.GetTexture("Gradient_Linear_Top"), "black")
    bg:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    bg:SetPoint("BOTTOMRIGHT")

    -- specs
    widget.buttons = {}

    local last = header
    for i = 1, GetNumSpecializationsForClassID(classID) do
        local specID, specName, _, specIcon = GetSpecializationInfoForClassID(classID, i)
        local button = CreateProfileButton(widget, "spec", specID, specIcon)
        tinsert(widget.buttons, button)

        AF.SetPoint(button, "RIGHT")
        AF.SetPoint(button, "TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        last = button

        AF.SetTooltip(button, "LEFT", -2, 0, AF.WrapTextInColor(specName, classFile))
    end

    return widget
end

local function CreateSpecPane()
    specPane = AF.CreateTitledPane(profilesPanel, L["Spec Profiles"], 340, 350)
    AF.SetPoint(specPane, "TOPLEFT", rolePane, "BOTTOMLEFT", 0, -20)

    local tip = AF.CreateFontString(specPane, L["medium priority"], "tip")
    AF.SetPoint(tip, "BOTTOMRIGHT", specPane.line, "TOPRIGHT", 0, 2)

    local grid = AF.CreateScrollGrid(specPane, nil, 0, 10, 2, 3, nil, nil, 10, "none", "none")
    AF.SetPoint(grid, "TOPLEFT", specPane, 0, -27)
    AF.SetPoint(grid, "BOTTOMRIGHT", specPane, 0, 10)
    grid.scrollBar:SetBorderColor("border")

    local widgets = {}
    for _, classID in AF.IterateSortedClasses() do
        tinsert(widgets, CreateSpecWidget(classID))
    end
    grid:SetWidgets(widgets)

    function specPane.Load()
        for _, w in next, widgets do
            for _, b in next, w.buttons do
                b:SetText(BFIConfig.profileAssignment.spec[b.typeValue] or "")
            end
        end
    end
end

---------------------------------------------------------------------
-- character pane
---------------------------------------------------------------------
local function CreateCharacterPane()
    characterPane = AF.CreateTitledPane(profilesPanel, L["Character-Specific Profile"], 340, 60)
    AF.SetPoint(characterPane, "TOPLEFT", specPane, "BOTTOMLEFT", 0, -20)

    local tip = AF.CreateFontString(characterPane, L["highest priority"], "tip")
    AF.SetPoint(tip, "BOTTOMRIGHT", characterPane.line, "TOPRIGHT", 0, 2)

    local button = CreateProfileButton(characterPane, "character", AF.player.fullName, AF.GetPlainTexture())
    AF.SetPoint(button, "TOPLEFT", characterPane, 10, -27)
    AF.SetPoint(button, "RIGHT", -10, 0)
    button._isProfileReceiver = true

    button.realTexture:SetTexCoord(0.12, 0.88, 0.12, 0.88)

    function characterPane.Load()
        SetPortraitTexture(button.realTexture, "player")
        button:SetText(BFIConfig.profileAssignment.character[AF.player.fullName] or "")
    end
end

---------------------------------------------------------------------
-- profile management pane
---------------------------------------------------------------------
local function CreateAssignmentFrame()
    assignmentFrame = AF.CreateBorderedFrame(profilesPanel, "BFIProfileAssignmentFrame", 150, 20, nil, "BFI")
    assignmentFrame:Hide()
    assignmentFrame.label = AF.CreateFontString(assignmentFrame)
    assignmentFrame.label:SetJustifyH("LEFT")
    AF.SetFrameLevel(assignmentFrame, 50)
    AF.SetPoint(assignmentFrame.label, "LEFT", 5, 0)

    assignmentFrame.line = assignmentFrame:CreateLine(nil, "BACKGROUND", nil, -7)
    assignmentFrame.line:SetTexture(AF.GetTexture("Checkerboard"), "REPEAT", "REPEAT")
    assignmentFrame.line:SetHorizTile(true)
    assignmentFrame.line:SetVertTile(true)
    assignmentFrame.line:SetVertexColor(AF.GetColorRGB("darkgray", 0.5))
    assignmentFrame.line:SetThickness(AF.ConvertPixels(2))

    assignmentFrame:SetOnShow(function()
        assignmentFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)

    assignmentFrame:SetOnHide(function()
        assignmentFrame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
        assignmentFrame.line:ClearAllPoints() --! otherwise the option frame's points will be lost, why??
        assignmentFrame:Hide()
    end)

    assignmentFrame:SetScript("OnEvent", function()
        local b = GetMouseFoci()[1]
        if b and b._isProfileReceiver then
            BFIConfig.profileAssignment[b.typeName][b.typeValue] = assignmentFrame.profileID
            b:SetText(assignmentFrame.profileName)

            F.LoadProfile() -- let PreloadProfile decide whether to actually perform profile loading
            LoadAll()
        else
            assignmentFrame:Hide()
        end
    end)
end

local function Profile_ActiveAssignmentMode(b)
    if not assignmentFrame then
        CreateAssignmentFrame()
    end
    b = b:GetParent()

    AF.AttachToCursor(assignmentFrame, "BOTTOMLEFT", 5, 0)
    AF.TruncateFontStringByWidth(assignmentFrame.label, 150, nil, true, b.text:GetText())
    AF.ResizeToFitText(assignmentFrame, assignmentFrame.label, 5)

    assignmentFrame.line:SetStartPoint("RIGHT", assignmentFrame)
    assignmentFrame.line:SetEndPoint("LEFT", b)

    assignmentFrame.profileName = b:GetText()
    assignmentFrame.profileID = b.id
end

local newProfileFrame
local function ShowNewProfileDialog()
    if not newProfileFrame then
        newProfileFrame = AF.CreateFrame(profilesPanel)
        newProfileFrame:Hide()

        local nameEditBox = AF.CreateEditBox(newProfileFrame, nil, 160, 20, "trim")
        newProfileFrame.nameEditBox = nameEditBox
        AF.SetPoint(nameEditBox, "TOPLEFT", 60, 0)
        nameEditBox:SetMaxLetters(50)
        nameEditBox:SetOnTextChanged(function(name, userChanged)
            if not userChanged then return end
            newProfileFrame.dialog:EnableYes(not AF.IsBlank(name) and name ~= "default" and not BFIProfile[name])
        end)

        local nameText = AF.CreateFontString(newProfileFrame, L["Name"], "gray")
        AF.SetPoint(nameText, "RIGHT", nameEditBox, "LEFT", -5, 0)

        local inheritDropdown = AF.CreateDropdown(newProfileFrame, 160)
        newProfileFrame.inheritDropdown = inheritDropdown
        AF.SetPoint(inheritDropdown, "TOPLEFT", nameEditBox, "BOTTOMLEFT", 0, -10)

        local inheritText = AF.CreateFontString(newProfileFrame, L["Base"], "gray")
        AF.SetPoint(inheritText, "RIGHT", inheritDropdown, "LEFT", -5, 0)

        newProfileFrame:SetOnShow(function()
            nameEditBox:Clear()
            inheritDropdown:ClearItems()
            for name in next, BFIProfile do
                if name == "default" then
                    inheritDropdown:AddItem({text = L["Default"], value = name}, 1)
                else
                    inheritDropdown:AddItem({text = name, value = name})
                end
            end
            inheritDropdown:AddItem({text = L["None"], value = "none"}, 1)
            inheritDropdown:SetSelectedValue("none")
        end)
    end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["New Profile"], "BFI"), 270)
    dialog:SetToOkayCancel()
    AF.SetPoint(dialog, "CENTER", profilesPanel)
    dialog:EnableYes(false)
    dialog:SetContent(newProfileFrame, 55)
    dialog:SetOnConfirm(function()
        local name = newProfileFrame.nameEditBox:GetValue()
        local inherit = newProfileFrame.inheritDropdown:GetSelected()

        if inherit == "none" then
            BFIProfile[name] = {
                revision = BFI.versionNum,
            }
            for _, module in next, F.GetModuleNames() do
                local defaults = F.GetModuleDefaults(module)
                if defaults then
                    BFIProfile[name][AF.LowerFirst(module)] = defaults
                end
            end
        else
            BFIProfile[name] = AF.Copy(BFIProfile[inherit])
        end

        managementPane.Load()
    end)
end

local function ShowDeleteProfileDialog()
    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Delete Profile"], "BFI") .. "\n" .. selectedProfile, 270)
    AF.SetPoint(dialog, "CENTER", profilesPanel)

    dialog:SetOnConfirm(function()
        BFIProfile[selectedProfile] = nil

        if BFI.vars.profileName == selectedProfile then
            BFIConfig.profileAssignment[BFI.vars.profileTypeName][BFI.vars.profileTypeValue] = nil
            F.CheckProfileAssignments()
            F.LoadProfile()
        end

        managementPane.ClearProfileInfo()
        LoadAll()
    end)
end

local renameProfileFrame
local function ShowRenameProfileDialog()
    if not renameProfileFrame then
        renameProfileFrame = AF.CreateFrame(profilesPanel)
        renameProfileFrame:Hide()

        local nameEditBox = AF.CreateEditBox(renameProfileFrame, nil, 160, 20, "trim")
        renameProfileFrame.nameEditBox = nameEditBox
        AF.SetPoint(nameEditBox, "TOPLEFT", 60, 0)
        nameEditBox:SetMaxLetters(50)
        nameEditBox:SetOnTextChanged(function(name, userChanged)
            if not userChanged then return end
            renameProfileFrame.dialog:EnableYes(not AF.IsBlank(name) and name ~= "default" and not BFIProfile[name])
        end)

        local nameText = AF.CreateFontString(renameProfileFrame, L["Name"], "gray")
        AF.SetPoint(nameText, "RIGHT", nameEditBox, "LEFT", -5, 0)

        renameProfileFrame:SetOnShow(function()
            nameEditBox:Clear()
        end)
    end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Rename Profile"], "BFI") .. "\n" .. selectedProfile, 270)
    dialog:SetToOkayCancel()
    AF.SetPoint(dialog, "CENTER", profilesPanel)
    dialog:EnableYes(false)
    dialog:SetContent(renameProfileFrame, 25)
    dialog:SetOnConfirm(function()
        local name = renameProfileFrame.nameEditBox:GetValue()
        BFIProfile[name] = BFIProfile[selectedProfile]
        BFIProfile[selectedProfile] = nil

        -- update profileAssignment
        for type, t in next, BFIConfig.profileAssignment do
            for k, v in next, t do
                if v == selectedProfile then
                    t[k] = name
                end
            end
        end

        if BFI.vars.profileName == selectedProfile then
            BFI.vars.profileName = name
        end

        selectedProfile = name
        managementPane.list:Select(selectedProfile, true)
        LoadAll()
    end)
end

local importExportProfileFrame
local function CreateImportExportFrame()
    importExportProfileFrame = AF.CreateFrame(profilesPanel, nil, 340, 300)

    local data

    -- box
    local box = AF.CreateScrollEditBox(importExportProfileFrame, nil, L["Paste string here"], nil, 100)
    importExportProfileFrame.box = box
    box:SetPoint("TOPLEFT")
    box:SetPoint("TOPRIGHT")

    -- masks
    local importMask = AF.ShowMask(importExportProfileFrame)
    importMask:Hide()
    importMask:SetBackdropColor(AF.GetColorRGB("mask", 0.85))
    AF.ClearPoints(importMask)
    AF.SetPoint(importMask, "TOPLEFT", box, "BOTTOMLEFT", 0, -10)
    AF.SetPoint(importMask, "BOTTOMRIGHT")

    local exportMask = AF.ShowMask(box, L["Generating string..."], 0, 0, 0, 0)
    exportMask:SetAlpha(0)
    exportMask:Hide()

    exportMask.progress = AF.CreateBlizzardStatusBar(exportMask, 0, 2)
    AF.SetPoint(exportMask.progress, "BOTTOMLEFT")
    AF.SetPoint(exportMask.progress, "TOPRIGHT", exportMask, "BOTTOMRIGHT", 0, 5)
    exportMask.progress:SetOnUpdate(function(self, elapsed)
        self:SetValue(self:GetValue() + elapsed)
    end)

    -- editbox update & clear
    local function UpdateEditBoxes()
        if importExportProfileFrame.mode == "import" then
            importExportProfileFrame.name:SetText(data.name or "")
        else
            importExportProfileFrame.name:SetText(selectedProfile)
        end
        importExportProfileFrame.name:SetCursorPosition(0)
        importExportProfileFrame.author:SetText(data.profile.pAuthor or "")
        importExportProfileFrame.author:SetCursorPosition(0)
        importExportProfileFrame.version:SetText(data.profile.pVersion or "")
        importExportProfileFrame.version:SetCursorPosition(0)
        importExportProfileFrame.url:SetText(data.profile.pURL or "")
        importExportProfileFrame.url:SetCursorPosition(0)
        importExportProfileFrame.description:SetText(data.profile.pDescription or "")
        importExportProfileFrame.description:SetCursorPosition(0)
    end

    local function ClearEditBoxes()
        importExportProfileFrame.name:Clear()
        importExportProfileFrame.author:Clear()
        importExportProfileFrame.version:Clear()
        importExportProfileFrame.url:Clear()
        importExportProfileFrame.description:Clear()
    end

    -- import
    local function PrepareImportData()
        local version, rest = box:GetText():match("^!BFI:(%d+)!(.+)$")
        if not version or not rest then
            ClearEditBoxes()
            importExportProfileFrame.dialog:EnableYes(false)
            importMask.text:SetText(L["Invalid string"])
            importMask:Show()
            return
        end

        data = AF.Deserialize(rest)
        if not data then
            ClearEditBoxes()
            importExportProfileFrame.dialog:EnableYes(false)
            importMask.text:SetText(L["Error parsing string"])
            importMask:Show()
            return
        end

        importExportProfileFrame.dialog:EnableYes(true)
        importMask:Hide()

        UpdateEditBoxes()
        importExportProfileFrame.privateImport:SetEnabled(data.player and true or false)
    end

    box:SetOnTextChanged(function(value, userChanged)
        if importExportProfileFrame.mode == "export" or not userChanged then return end
        PrepareImportData()
    end)

    local function DoImport()
        local commonConfigImported

        if importExportProfileFrame.general:GetChecked() then
            BFIConfig.general = data.config.general
            commonConfigImported = true
        end
        -- TODO:
        -- if importExportProfileFrame.enhancements:GetChecked() then
        --     BFIConfig.enhancements = data.config.enhancements
        --     commonConfigImported = true
        -- end
        if importExportProfileFrame.colors:GetChecked() then
            BFIConfig.colors = data.config.colors
            -- AF.Fire("BFI_UpdateColor")
            commonConfigImported = true
        end
        if importExportProfileFrame.auras:GetChecked() then
            BFIConfig.auras = data.config.auras
            -- AF.Fire("BFI_UpdateAuras")
            commonConfigImported = true
        end
        if importExportProfileFrame.profileAssignment:GetChecked() then
            BFIConfig.profileAssignment = data.config.profileAssignment
            commonConfigImported = true
        end
        if importExportProfileFrame.privateImport:GetChecked() then
            BFIPlayer = data.player
            -- TODO: blacklist ...
        end
        if importExportProfileFrame.profileAssignment:GetChecked() and importExportProfileFrame.privateImport:GetChecked() then
            BFIConfig.profileAssignment.character = data.config.profileAssignment.character
            commonConfigImported = true
        end

        local i = 1
        while BFIProfile[data.name] do
            data.name = data.name .. " (" .. i .. ")"
            i = i + 1
        end
        BFIProfile[data.name] = data.profile

        LoadAll()

        if commonConfigImported then
            C_Timer.After(0.5, function()
                local dialog = AF.GetDialog(profilesPanel, L["A UI reload is required\nDo it now?"])
                dialog:SetPoint("CENTER")
                dialog:SetOnConfirm(ReloadUI)
            end)
        end
    end

    -- export
    local function PrepareExportData()
        data = {}
        data.name = selectedProfile
        data.profile = AF.Copy(BFIProfile[selectedProfile])
        data.config = AF.Copy(BFIConfig)
        wipe(data.config.profileAssignment.character)
    end


    local function UpdateExportString()
        box:SetText("!BFI:" .. BFI.versionNum .. "!" .. AF.Serialize(data))
        AF.FrameFadeOut(exportMask, nil, nil, nil, true)
    end

    local function DelayedUpdateExportString()
        if importExportProfileFrame.mode ~= "export" then return end
        AF.FrameFadeIn(exportMask)
        exportMask.progress:SetValue(0)
        AF.DelayedInvoke(2, UpdateExportString)
    end

    -- editboxes
    local name = AF.CreateEditBox(importExportProfileFrame, L["Name"], 160, 20, "trim")
    importExportProfileFrame.name = name
    AF.SetPoint(name, "TOPLEFT", box, "BOTTOMLEFT", 0, -15)
    name:SetOnTextChanged(function(value, userChanged)
        if not userChanged then return end
        if AF.IsBlank(value) then value = AF.FormatTime() end
        data.name = value
        DelayedUpdateExportString()
    end)

    local author = AF.CreateEditBox(importExportProfileFrame, L["Author"], 160, 20, "trim")
    importExportProfileFrame.author = author
    AF.SetPoint(author, "TOPRIGHT", box, "BOTTOMRIGHT", 0, -15)
    author:SetOnTextChanged(function(value, userChanged)
        if not userChanged then return end
        if AF.IsBlank(value) then value = nil end
        data.profile.pAuthor = value
        DelayedUpdateExportString()
    end)

    local version = AF.CreateEditBox(importExportProfileFrame, L["Version"], 160, 20, "trim")
    importExportProfileFrame.version = version
    AF.SetPoint(version, "TOPLEFT", name, "BOTTOMLEFT", 0, -5)
    version:SetOnTextChanged(function(value, userChanged)
        if not userChanged then return end
        if AF.IsBlank(value) then value = nil end
        data.profile.pVersion = value
        DelayedUpdateExportString()
    end)

    local url = AF.CreateEditBox(importExportProfileFrame, "URL", 160, 20, "trim")
    importExportProfileFrame.url = url
    AF.SetPoint(url, "TOPRIGHT", author, "BOTTOMRIGHT", 0, -5)
    url:SetOnTextChanged(function(value, userChanged)
        if not userChanged then return end
        if AF.IsBlank(value) then value = nil end
        data.profile.pURL = value
        DelayedUpdateExportString()
    end)

    local description = AF.CreateScrollEditBox(importExportProfileFrame, nil, L["Description"], nil, 60)
    importExportProfileFrame.description = description
    AF.SetPoint(description, "TOPLEFT", version, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(description, "TOPRIGHT", url, "BOTTOMRIGHT", 0, -5)
    description:SetOnTextChanged(function(value, userChanged)
        if not userChanged then return end
        if AF.IsBlank(value) then value = nil end
        data.profile.pDescription = value
        DelayedUpdateExportString()
    end)

    -- export check button
    local privateExport = AF.CreateCheckButton(importExportProfileFrame, L["Include Private Data"])
    importExportProfileFrame.privateExport = privateExport
    AF.SetPoint(privateExport, "TOPLEFT", description, "BOTTOMLEFT", 0, -15)
    privateExport:SetTooltip(L["Include Private Data"], L["Friends, blacklist, and other personal data"])
    privateExport:SetOnCheck(function(checked)
        if checked then
            data.player = AF.Copy(BFIPlayer)
            data.config.profileAssignment.character = AF.Copy(BFIConfig.profileAssignment.character)
        else
            data.player = nil
            wipe(data.config.profileAssignment.character)
        end
        DelayedUpdateExportString()
    end)

    -- import check buttons
    local importTip = AF.CreateFontString(importExportProfileFrame, L["The following options are global. If checked, the corresponding data will be immediately overwritten upon import and cannot be undone."], "firebrick")
    AF.SetPoint(importTip, "TOPLEFT", description, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(importTip, "TOPRIGHT", description, "BOTTOMRIGHT", 0, -15)
    importTip:SetJustifyH("LEFT")
    importTip:SetSpacing(5)

    local general = AF.CreateCheckButton(importExportProfileFrame, L["General"])
    importExportProfileFrame.general = general
    AF.SetPoint(general, "TOPLEFT", importTip, "BOTTOMLEFT", 0, -15)
    general:SetTooltip(L["General"], L["AbstractFramework settings are not included"])

    local enhancements = AF.CreateCheckButton(importExportProfileFrame, L["Enhancements"])
    importExportProfileFrame.enhancements = enhancements
    AF.SetPoint(enhancements, "TOPLEFT", importTip, "BOTTOMRIGHT", -160, -15)
    enhancements:SetEnabled(false)

    local colors = AF.CreateCheckButton(importExportProfileFrame, L["Colors"])
    importExportProfileFrame.colors = colors
    AF.SetPoint(colors, "TOPRIGHT", general, "BOTTOMRIGHT", 0, -7)

    local auras = AF.CreateCheckButton(importExportProfileFrame, L["Auras"])
    importExportProfileFrame.auras = auras
    AF.SetPoint(auras, "TOPLEFT", enhancements, "BOTTOMLEFT", 0, -7)

    local profileAssignment = AF.CreateCheckButton(importExportProfileFrame, L["Profile Assignment"])
    importExportProfileFrame.profileAssignment = profileAssignment
    AF.SetPoint(profileAssignment, "TOPLEFT", colors, "BOTTOMLEFT", 0, -7)

    local privateImport = AF.CreateCheckButton(importExportProfileFrame, L["Private Data"])
    importExportProfileFrame.privateImport = privateImport
    AF.SetPoint(privateImport, "TOPLEFT", auras, "BOTTOMLEFT", 0, -7)

    -- SetMode
    function importExportProfileFrame:SetMode(mode)
        data = {}

        self.mode = mode
        AF.HideMask(box)

        if mode == "export" then
            importMask:Hide()

            box:SetNotUserChangable(true)

            privateExport:Show()
            privateExport:SetChecked(false)
            AF.Hide(importTip, general, enhancements, colors, auras, profileAssignment, privateImport)

            PrepareExportData()
            UpdateExportString()
            UpdateEditBoxes()
            importExportProfileFrame.dialog:SetOnConfirm(nil)
        else
            importMask:Show()
            importMask.text:SetText("")

            box:SetNotUserChangable(false)
            box:Clear()

            privateExport:Hide()
            AF.Show(importTip, general, enhancements, colors, auras, profileAssignment, privateImport)
            AF.SetChecked(false, general, enhancements, colors, auras, profileAssignment, privateImport)

            ClearEditBoxes()
            importExportProfileFrame.dialog:SetOnConfirm(DoImport)
        end
    end
end

local function ShowImportProfileDialog()
    if not importExportProfileFrame then CreateImportExportFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Import Profile"], "BFI"), 353)
    dialog:SetToOkayCancel()
    dialog:SetContent(importExportProfileFrame, 375)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(false)

    importExportProfileFrame:SetMode("import")
end

local function ShowExportProfileDialog()
    if not importExportProfileFrame then CreateImportExportFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Export Profile"], "BFI"), 353)
    dialog:SetToOkayCancel()
    dialog:SetContent(importExportProfileFrame, 255)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(true)

    importExportProfileFrame:SetMode("export")
end

local function UpdateProfileInfo(value, userChanged, eb)
    if not userChanged then return end
    if AF.IsBlank(value) then value = nil end
    BFIProfile[selectedProfile][eb.key] = value
end

local function CreateManagementPane()
    managementPane = AF.CreateTitledPane(profilesPanel, L["Profile Management"], 180, 400)
    AF.SetPoint(managementPane, "TOPRIGHT", -15, -15)

    -- list
    local list = AF.CreateScrollList(managementPane, nil, 0, 0, 9, 20, -1)
    managementPane.list = list
    AF.SetPoint(list, "TOPLEFT", managementPane, 10, -27)
    AF.SetPoint(list, "TOPRIGHT", managementPane, -10, -27)

    list:SetupButtonGroup("BFI_transparent", function(b)
        managementPane.LoadProfileInfo(b)
    end, nil, nil, nil, function(b)
        -- onLoad
        if b._inited then return end
        b._inited = true

        b:RegisterForDrag("LeftButton")

        b.assignButton = AF.CreateIconButton(b, AF.GetIcon("Link", BFI.name), 16, 16, nil, "gray", nil, nil, true)
        b.assignButton:Hide()
        AF.SetPoint(b.assignButton, "RIGHT", -5, 0)
        b.assignButton:HookOnEnter(b:GetOnEnter())
        b.assignButton:HookOnLeave(b:GetOnLeave())
        b.assignButton:SetOnClick(Profile_ActiveAssignmentMode)

        b:HookOnEnter(function()
            b.assignButton:Show()
            AF.ClearPoints(b.text)
            AF.SetPoint(b.text, "LEFT", 5, 0)
            AF.SetPoint(b.text, "RIGHT", b.assignButton, "LEFT", -5, 0)

            if b.text:IsTruncated() then
                AF.ShowTooltip(b, "RIGHT", 2, 0, {b.text:GetText()})
            end
        end)

        b:HookOnLeave(function()
            b.assignButton:Hide()
            AF.ClearPoints(b.text)
            AF.SetPoint(b.text, "LEFT", 5, 0)
            AF.SetPoint(b.text, "RIGHT", -5, 0)

            AF.HideTooltip()
        end)
    end)

    -- info boxes
    local author = AF.CreateEditBox(managementPane, L["Author"], nil, 20)
    AF.SetPoint(author, "TOPLEFT", list, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(author, "RIGHT", list)
    author.key = "pAuthor"
    author:SetOnTextChanged(UpdateProfileInfo)
    author:SetEnabled(false)

    local version = AF.CreateEditBox(managementPane, L["Version"], nil, 20)
    AF.SetPoint(version, "TOPLEFT", author, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(version, "RIGHT", list)
    version.key = "pVersion"
    version:SetOnTextChanged(UpdateProfileInfo)
    version:SetEnabled(false)

    local url = AF.CreateEditBox(managementPane, "URL", nil, 20)
    AF.SetPoint(url, "TOPLEFT", version, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(url, "RIGHT", list)
    url.key = "pURL"
    url:SetOnTextChanged(UpdateProfileInfo)
    url:SetEnabled(false)

    local description = AF.CreateScrollEditBox(managementPane, nil, L["Description"], nil, 160)
    AF.SetPoint(description, "TOPLEFT", url, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(description, "RIGHT", list)
    description.eb.key = "pDescription"
    description:SetOnTextChanged(UpdateProfileInfo)
    description:SetEnabled(false)

    -- buttons
    local new = AF.CreateButton(managementPane, nil, "BFI_hover", 50, 20)
    AF.SetPoint(new, "TOPLEFT", description, "BOTTOMLEFT", 0, -15)
    new:SetTexture(AF.GetIcon("Create_Square"))
    new:SetTooltip(L["New"])
    new:SetOnClick(ShowNewProfileDialog)

    local delete = AF.CreateButton(managementPane, nil, "BFI_hover", 50, 20)
    AF.SetPoint(delete, "TOPRIGHT", description, "BOTTOMRIGHT", 0, -15)
    delete:SetTexture(AF.GetIcon("Trash"))
    delete:SetTooltip(L["Delete"])
    delete:SetEnabled(false)
    delete:SetOnClick(ShowDeleteProfileDialog)

    local rename = AF.CreateButton(managementPane, nil, "BFI_hover")
    AF.SetPoint(rename, "TOPLEFT", new, "TOPRIGHT", 5, 0)
    AF.SetPoint(rename, "BOTTOMRIGHT", delete, "BOTTOMLEFT", -5, 0)
    rename:SetTexture(AF.GetIcon("Rename"))
    rename:SetTooltip(L["Rename"])
    rename:SetEnabled(false)
    rename:SetOnClick(ShowRenameProfileDialog)

    local import = AF.CreateButton(managementPane, L["Import"], "BFI_hover", nil, 20)
    AF.SetPoint(import, "TOPLEFT", new, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(import, "TOPRIGHT", delete, "BOTTOMRIGHT", 0, -5)
    import:SetTexture(AF.GetIcon("Import1"), nil, {"LEFT", 5, 0})
    import:SetOnClick(ShowImportProfileDialog)

    local export = AF.CreateButton(managementPane, L["Export"], "BFI_hover", nil, 20)
    AF.SetPoint(export, "TOPLEFT", import, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(export, "TOPRIGHT", import, "BOTTOMRIGHT", 0, -5)
    export:SetTexture(AF.GetIcon("Export1"), nil, {"LEFT", 5, 0})
    export:SetEnabled(false)
    export:SetOnClick(ShowExportProfileDialog)

    -- load
    local profiles = {}

    function managementPane.Load()
        wipe(profiles)

        for name, t in next, BFIProfile do
            if name ~= "default" then
                tinsert(profiles, {
                    text = name,
                    -- pAuthor = t.pAuthor,
                    -- pVersion = t.pVersion,
                    -- pURL = t.pURL,
                    -- pDescription = t.pDescription
                })
            end
        end
        tinsert(profiles, 1, {text = _G.DEFAULT, id = "default"})

        list:SetData(profiles)
    end

    function managementPane.LoadProfileInfo(b)
        selectedProfile = b.id

        local profile = BFIProfile[selectedProfile]
        author:SetText(profile.pAuthor or "")
        version:SetText(profile.pVersion or "")
        url:SetText(profile.pURL or "")
        description:SetText(profile.pDescription or "")

        -- update buttons
        AF.SetEnabled(selectedProfile ~= "default", delete, rename)
        AF.SetEnabled(true, export, author, version, url, description)
    end

    function managementPane.ClearProfileInfo()
        selectedProfile = nil

        list:Select(nil, true)

        author:Clear()
        version:Clear()
        url:Clear()
        description:Clear()
        AF.SetEnabled(false, delete, rename, export, author, version, url, description)
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
LoadAll = function()
    rolePane.Load()
    specPane.Load()
    characterPane.Load()
    managementPane.Load()

    if not selectedHighlight then
        selectedHighlight = AF.CreateBorderedFrame(profilesPanel, nil, nil, nil, "none", "BFI")
        AF.SetFrameLevel(selectedHighlight, 30)
    end

    selectedHighlight:SetAllPoints(profileButtons[BFI.vars.profileTypeName][BFI.vars.profileTypeValue])
end

AF.RegisterCallback("BFI_UpdateProfile", function()
    if selectedHighlight then
        selectedHighlight:SetAllPoints(profileButtons[BFI.vars.profileTypeName][BFI.vars.profileTypeValue])
    end
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
AF.RegisterCallback("BFI_ShowOptionsPanel", function(_, id)
    if id == "Profiles" then
        if not profilesPanel then
            CreateProfilesPanel()
            CreateRolePane()
            CreateSpecPane()
            CreateCharacterPane()
            CreateManagementPane()
        end
        LoadAll()
        profilesPanel:Show()
    elseif profilesPanel then
        profilesPanel:Hide()
    end
end)