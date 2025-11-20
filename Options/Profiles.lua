---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local profilesPanel
local rolePane, specPane, characterPane, managementPane
local selectedProfile, selectedHighlight, assignmentFrame
local profileUpdateTime
local LoadAll

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function GetProfileItems()
    local t = {}
    for name in next, BFIProfile do
        if name ~= "default" then
            tinsert(t, {text = name})
        end
    end
    AF.Sort(t, "text", "ascending")
    tinsert(t, 1, {text = L["Default"], value = "default", id = "default"})
    return t
end

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
        text = L["Default"]
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
-- assignment frame
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
        assignmentFrame.label:SetText("")
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
    b:SilentClick()

    AF.AttachToCursor(assignmentFrame, "BOTTOMLEFT", 5, 0)
    RunNextFrame(function()
        AF.TruncateFontStringByWidth(assignmentFrame.label, 150, nil, true, b.text:GetText())
        AF.ResizeToFitText(assignmentFrame, assignmentFrame.label, 5)
    end)

    assignmentFrame.line:SetStartPoint("RIGHT", assignmentFrame)
    assignmentFrame.line:SetEndPoint("LEFT", b)

    assignmentFrame.profileName = b:GetText()
    assignmentFrame.profileID = b.id
end

---------------------------------------------------------------------
-- new profile
---------------------------------------------------------------------
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

            local items = GetProfileItems()
            tinsert(items, 1, {text = L["None"], value = "none"})
            inheritDropdown:SetItems(items)
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
            for _, module in next, F.GetProfileModuleClassNames() do
                local defaults = F.GetModuleDefaults(module)
                if defaults then
                    BFIProfile[name][F.GetModuleKey(module)] = defaults
                end
            end
        else
            BFIProfile[name] = AF.Copy(BFIProfile[inherit])
        end

        managementPane.Load()
    end)
end

---------------------------------------------------------------------
-- delete profile
---------------------------------------------------------------------
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

---------------------------------------------------------------------
-- rename profile
---------------------------------------------------------------------
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
            nameEditBox:SetText(selectedProfile)
            nameEditBox:SetCursorPosition(0)
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

---------------------------------------------------------------------
-- import / export
---------------------------------------------------------------------
local importExportProfileFrame
local function CreateImportExportFrame()
    importExportProfileFrame = AF.CreateFrame(profilesPanel, nil, 340, 300)

    local data

    -- box
    local box = AF.CreateScrollEditBox(importExportProfileFrame, nil, L["Paste string here"], nil, 109)
    importExportProfileFrame.box = box
    box:SetPoint("TOPLEFT")
    box:SetPoint("TOPRIGHT")
    box.eb:SetOnMouseUp(function()
        box.eb:HighlightText()
    end)

    -- mask
    local exportMask = AF.ShowMask(box, L["Generating string..."], 0, 0, 0, 0)
    exportMask:SetAlpha(0)
    exportMask:Hide()

    exportMask.progress = AF.CreateBlizzardStatusBar(exportMask, 0, 2)
    AF.SetPoint(exportMask.progress, "BOTTOMLEFT")
    AF.SetPoint(exportMask.progress, "TOPRIGHT", exportMask, "BOTTOMRIGHT", 0, 5)
    exportMask.progress:SetOnUpdate(function(self, elapsed)
        self:SetValue(self:GetValue() + elapsed)
    end)

    -- widget updates
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

    local function HideWidgets()
        AF.Hide(
            importExportProfileFrame.name,
            importExportProfileFrame.author,
            importExportProfileFrame.version,
            importExportProfileFrame.url,
            importExportProfileFrame.description,
            importExportProfileFrame.exportPrivate,
            importExportProfileFrame.errorText,
            importExportProfileFrame.importTip,
            importExportProfileFrame.general,
            importExportProfileFrame.enhancements,
            importExportProfileFrame.colors,
            importExportProfileFrame.auras,
            importExportProfileFrame.profileAssignment,
            importExportProfileFrame.importPrivate
        )
    end

    local function ShowProfileImportWidgets()
        AF.Show(
            importExportProfileFrame.name,
            importExportProfileFrame.author,
            importExportProfileFrame.version,
            importExportProfileFrame.url,
            importExportProfileFrame.description
        )
    end

    local function ShowCommonImportWidgets()
        AF.Show(
            importExportProfileFrame.importTip,
            importExportProfileFrame.general,
            importExportProfileFrame.enhancements,
            importExportProfileFrame.colors,
            importExportProfileFrame.auras,
            importExportProfileFrame.profileAssignment,
            importExportProfileFrame.importPrivate
        )
        AF.SetChecked(false,
            importExportProfileFrame.general,
            importExportProfileFrame.enhancements,
            importExportProfileFrame.colors,
            importExportProfileFrame.auras,
            importExportProfileFrame.profileAssignment,
            importExportProfileFrame.importPrivate
        )
    end

    -- import
    local errorText = AF.CreateFontString(importExportProfileFrame, nil, "firebrick")
    importExportProfileFrame.errorText = errorText
    AF.SetPoint(errorText, "TOP", box, "BOTTOM", 0, -5)

    local function ValidateCheckBoxes()
        importExportProfileFrame.dialog:EnableYes(
            importExportProfileFrame.general:GetChecked() or
            importExportProfileFrame.enhancements:GetChecked() or
            importExportProfileFrame.colors:GetChecked() or
            importExportProfileFrame.auras:GetChecked() or
            importExportProfileFrame.profileAssignment:GetChecked() or
            importExportProfileFrame.importPrivate:GetChecked()
        )
    end

    local function DoCommonImport()
        if importExportProfileFrame.general:GetChecked() then
            BFIConfig.general = data.config.general
            AFConfig.accentColor = data.afConfig.accentColor
            AFConfig.fontSizeDelta = data.afConfig.fontSizeDelta
            AFConfig.scale = data.afConfig.scale
        end
        if importExportProfileFrame.enhancements:GetChecked() then
            BFIConfig.enhancements = data.config.enhancements
        end
        if importExportProfileFrame.colors:GetChecked() then
            BFIConfig.colors = data.config.colors
        end
        if importExportProfileFrame.auras:GetChecked() then
            BFIConfig.auras = data.config.auras
        end
        if importExportProfileFrame.profileAssignment:GetChecked() then
            BFIConfig.profileAssignment = data.config.profileAssignment
        end
        if importExportProfileFrame.importPrivate:GetChecked() then
            BFIPlayer = data.player
            -- TODO: blacklist ...
        end
        if importExportProfileFrame.profileAssignment:GetChecked() and importExportProfileFrame.importPrivate:GetChecked() then
            BFIConfig.profileAssignment.character = data.config.profileAssignment.character
        end

        ReloadUI()
    end

    local function DoProfileImport()
        local i = 1
        while BFIProfile[data.name] do
            data.name = data.name .. " (" .. i .. ")"
            i = i + 1
        end
        BFIProfile[data.name] = data.profile

        LoadAll()
    end

    local function PrepareImportData()
        importExportProfileFrame.dialog._height = nil -- use GetHeight()

        local version, rest = box:GetText():match("^!BFI:(%d+)!(.+)$")
        if not version or not rest then
            importExportProfileFrame.dialog:EnableYes(false)
            HideWidgets()
            AF.AnimatedResize(importExportProfileFrame.dialog, nil, 190, nil, 3, nil, function()
                errorText:SetText(L["Invalid string"])
                errorText:Show()
            end)
            return
        end

        data = AF.Deserialize(rest)
        if not data then
            importExportProfileFrame.dialog:EnableYes(false)
            HideWidgets()
            AF.AnimatedResize(importExportProfileFrame.dialog, nil, 190, nil, 3, nil, function()
                errorText:SetText(L["Error parsing string"])
                errorText:Show()
            end)
            return
        end

        errorText:Hide()
        ClearEditBoxes()

        if data.config then -- common
            AF.AnimatedResize(importExportProfileFrame.dialog, nil, 330, nil, 5, nil, function()
                HideWidgets()
                ShowCommonImportWidgets()
                importExportProfileFrame.importPrivate:SetEnabled(data.player and true or false)
                importExportProfileFrame.dialog:SetOnConfirm(DoCommonImport)
                importExportProfileFrame.dialog:EnableYes(false)
            end)
        else -- profile
            AF.AnimatedResize(importExportProfileFrame.dialog, nil, 300, nil, 5, nil, function()
                HideWidgets()
                ShowProfileImportWidgets()
                UpdateEditBoxes()
                importExportProfileFrame.dialog:SetOnConfirm(DoProfileImport)
                importExportProfileFrame.dialog:EnableYes(true)
            end)
        end
    end

    box:SetOnTextChanged(function(value, userChanged)
        if importExportProfileFrame.mode == "import" and userChanged then
            PrepareImportData()
        end
    end)

    -- export
    local function PrepareProfileExportData()
        data = {}
        data.name = selectedProfile
        data.profile = AF.Copy(BFIProfile[selectedProfile])
    end

    local function PrepareCommonExportData()
        data = {}
        data.config = AF.Copy(BFIConfig)
        data.config.cvarInited = nil
        wipe(data.config.profileAssignment.character)
        data.afConfig = {
            accentColor = AF.Copy(AFConfig.accentColor),
            fontSizeDelta = AFConfig.fontSizeDelta,
            scale = AFConfig.scale
        }
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
    local exportPrivate = AF.CreateCheckButton(importExportProfileFrame, L["Include Private Data"])
    importExportProfileFrame.exportPrivate = exportPrivate
    AF.SetPoint(exportPrivate, "TOPLEFT", box, "BOTTOMLEFT", 0, -10)
    exportPrivate:SetTooltip(L["Include Private Data"], L["Friends, blacklist, and other personal data"])
    exportPrivate:SetOnCheck(function(checked)
        if checked then
            data.player = AF.Copy(BFIPlayer)
            data.config.profileAssignment.character = AF.Copy(BFIConfig.profileAssignment.character)
        else
            data.player = nil
            wipe(data.config.profileAssignment.character)
        end
        UpdateExportString()
    end)

    -- import check buttons
    local importTip = AF.CreateFontString(importExportProfileFrame, L["The following options are global. If checked, the corresponding data will be immediately overwritten upon import and cannot be undone (The UI will reload automatically)."], "firebrick")
    importExportProfileFrame.importTip = importTip
    AF.SetPoint(importTip, "TOPLEFT", box, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(importTip, "TOPRIGHT", box, "BOTTOMRIGHT", 0, -15)
    importTip:SetJustifyH("LEFT")
    importTip:SetSpacing(5)
    importTip:SetWordWrap(true)

    local general = AF.CreateCheckButton(importExportProfileFrame, L["General"], ValidateCheckBoxes)
    importExportProfileFrame.general = general
    AF.SetPoint(general, "TOPLEFT", importTip, "BOTTOMLEFT", 0, -15)
    general:SetTooltip(L["General"], L["CVar settings are not included"])

    local enhancements = AF.CreateCheckButton(importExportProfileFrame, L["Enhancements"], ValidateCheckBoxes)
    importExportProfileFrame.enhancements = enhancements
    AF.SetPoint(enhancements, "TOPLEFT", importTip, "BOTTOMRIGHT", -160, -15)

    local colors = AF.CreateCheckButton(importExportProfileFrame, L["Colors"], ValidateCheckBoxes)
    importExportProfileFrame.colors = colors
    AF.SetPoint(colors, "TOPRIGHT", general, "BOTTOMRIGHT", 0, -7)

    local auras = AF.CreateCheckButton(importExportProfileFrame, L["Auras"], ValidateCheckBoxes)
    importExportProfileFrame.auras = auras
    AF.SetPoint(auras, "TOPLEFT", enhancements, "BOTTOMLEFT", 0, -7)

    local profileAssignment = AF.CreateCheckButton(importExportProfileFrame, L["Profile Assignment"], ValidateCheckBoxes)
    importExportProfileFrame.profileAssignment = profileAssignment
    AF.SetPoint(profileAssignment, "TOPLEFT", colors, "BOTTOMLEFT", 0, -7)

    local importPrivate = AF.CreateCheckButton(importExportProfileFrame, L["Private Data"], ValidateCheckBoxes)
    importExportProfileFrame.importPrivate = importPrivate
    AF.SetPoint(importPrivate, "TOPLEFT", auras, "BOTTOMLEFT", 0, -7)

    -- SetMode
    function importExportProfileFrame:SetMode(mode)
        data = {}

        self.mode = mode
        AF.HideMask(box)

        if mode == "export" then
            box:SetNotUserChangable(true)

            HideWidgets()
            ShowProfileImportWidgets()

            PrepareProfileExportData()
            UpdateExportString()
            UpdateEditBoxes()
            importExportProfileFrame.dialog:SetOnConfirm(nil)
        elseif mode == "export_common" then
            box:SetNotUserChangable(true)

            HideWidgets()
            exportPrivate:Show()
            exportPrivate:SetChecked(false)

            PrepareCommonExportData()
            UpdateExportString()
            importExportProfileFrame.dialog:SetOnConfirm(nil)
        else
            box:SetNotUserChangable(false)
            box:Clear()

            HideWidgets()
            importExportProfileFrame.dialog:SetOnConfirm(nil)
        end
    end
end

local function ShowProfileImportDialog()
    if not importExportProfileFrame then CreateImportExportFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Import"], "BFI"), 353)
    dialog:SetToOkayCancel()
    dialog:SetContent(importExportProfileFrame, 120)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(false)

    importExportProfileFrame:SetMode("import")
end

local function ShowProfileExportDialog()
    if not importExportProfileFrame then CreateImportExportFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Export"], "BFI"), 353)
    dialog:SetToOkayCancel()
    dialog:SetContent(importExportProfileFrame, 245)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(true)

    importExportProfileFrame:SetMode("export")
end

local function ShowCommonExportDialog()
    if not importExportProfileFrame then CreateImportExportFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Export"], "BFI"), 353)
    dialog:SetToOkayCancel()
    dialog:SetContent(importExportProfileFrame, 135)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(true)

    importExportProfileFrame:SetMode("export_common")
end

---------------------------------------------------------------------
-- copy modules
---------------------------------------------------------------------
local moduleCopyFrame

local function CreateModuleCopyFrame()
    moduleCopyFrame = AF.CreateFrame(profilesPanel, nil, 340, 300)
    moduleCopyFrame:Hide()

    local fromDropdown = AF.CreateDropdown(moduleCopyFrame, 160)
    AF.SetPoint(fromDropdown, "TOPLEFT", 60, 0)

    local fromText = AF.CreateFontString(moduleCopyFrame, L["From"], "gray")
    AF.SetPoint(fromText, "RIGHT", fromDropdown, "LEFT", -5, 0)

    local toDropdown = AF.CreateDropdown(moduleCopyFrame, 160)
    AF.SetPoint(toDropdown, "TOPLEFT", fromDropdown, "BOTTOMLEFT", 0, -10)

    local toText = AF.CreateFontString(moduleCopyFrame, L["To"], "gray")
    AF.SetPoint(toText, "RIGHT", toDropdown, "LEFT", -5, 0)

    local list = AF.CreateScrollList(moduleCopyFrame, nil, 0, 0, 9, 20, -1)
    AF.SetPoint(list, "TOPLEFT", toDropdown, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(list, "TOPRIGHT", toDropdown, "BOTTOMRIGHT", 0, -15)

    local listText = AF.CreateFontString(moduleCopyFrame, L["Modules"], "gray")
    AF.SetPoint(listText, "TOPRIGHT", list, "TOPLEFT", -5, -2)

    local modules
    list:SetupButtonGroup("BFI_transparent", function()
        modules = AF.GetKeys(list:GetSelected())
        moduleCopyFrame.dialog:EnableYes(#modules ~= 0)
    end)
    list:SetMultiSelect(true)

    local from, to
    local data = {
        {text = L["Unit Frames"], id = "unitFrames"},
        {text = L["Nameplates"], id = "nameplates"},
        {text = L["Action Bars"], id = "actionBars"},
        {text = L["Buffs & Debuffs"], id = "buffsDebuffs"},
        {text = L["Tooltip"], id = "tooltip"},
        {text = L["UI Widgets"], id = "uiWidgets"},
        {text = L["Data Bars"], id = "dataBars"},
        {text = L["Maps"], id = "maps"},
        {text = L["Chat"], id = "chat"},
    }

    local function CheckFromTo()
        from = fromDropdown:GetSelected()
        to = toDropdown:GetSelected()

        if AF.IsBlank(from) or AF.IsBlank(to) or from == to then
            list:Reset()
        else
            list:SetData(data)
        end
        moduleCopyFrame.dialog:EnableYes(false)
    end

    fromDropdown:SetOnSelect(CheckFromTo)
    toDropdown:SetOnSelect(CheckFromTo)

    local function DoCopy()
        if from == "addon_default" then
            for _, module in next, modules do
                wipe(BFIProfile[to][module])
                AF.Merge(BFIProfile[to][module], F.GetModuleDefaults(F.GetModuleClassName(module)))
            end
        else
            for _, module in next, modules do
                AF.MergeExistingKeys(BFIProfile[to][module], BFIProfile[from][module])
            end
        end

        AF.Fire("BFI_UpdateModule")
    end

    local addon_default = {text = AF.GetGradientText(L["Addon Default"], "BFI", "white"), value = "addon_default"}

    moduleCopyFrame:SetOnShow(function()
        fromDropdown:ClearSelected()
        toDropdown:ClearSelected()
        list:Reset()

        local fromItems = GetProfileItems()
        tinsert(fromItems, 1, addon_default)
        fromDropdown:SetItems(fromItems)
        toDropdown:SetItems(GetProfileItems())

        moduleCopyFrame.dialog:SetOnConfirm(DoCopy)
    end)
end

local function ShowModuleCopyDialog()
    if not moduleCopyFrame then CreateModuleCopyFrame() end

    local dialog = AF.GetDialog(profilesPanel, AF.WrapTextInColor(L["Copy Module Settings"], "BFI"), 270)
    dialog:SetToOkayCancel()
    dialog:SetContent(moduleCopyFrame, 250)
    dialog:SetPoint("CENTER", profilesPanel)
    dialog:EnableYes(false)
end

---------------------------------------------------------------------
-- profile management pane
---------------------------------------------------------------------
local function UpdateProfileInfo(value, userChanged, eb)
    if not userChanged then return end
    if AF.IsBlank(value) then value = nil end
    BFIProfile[selectedProfile][eb.key] = value
end

local function CreateManagementPane()
    managementPane = AF.CreateTitledPane(profilesPanel, L["Profile Management"], 180, 400)
    AF.SetPoint(managementPane, "TOPRIGHT", -15, -15)
    managementPane:SetTips(
        L["Assignment Mode"],
        L["Click %s on the right side of a list item to enter assignment mode; click blank area to exit"]:format(AF.GetIconString("Link")),
        " ",
        AF.WrapTextInColor(L["Assignment Area (Left)"], "BFI"),
        AF.WrapTextInColor(L["Left-click: "], "tip") .. L["Assign profile"],
        AF.WrapTextInColor(L["Right-click: "], "tip") .. L["Remove profile"]
    )

    -- list
    local list = AF.CreateScrollList(managementPane, nil, 0, 0, 7, 20, -1)
    managementPane.list = list
    AF.SetPoint(list, "TOPLEFT", managementPane, 10, -27)
    AF.SetPoint(list, "TOPRIGHT", managementPane, -10, -27)

    list:SetupButtonGroup("BFI_transparent", function(b) -- onSelect
        managementPane.LoadProfileInfo(b)
    end, nil, function(b) -- onEnter
        b.assignButton:SetAlpha(1) --! NOTE: if use Show here will cause BIG problems!
        AF.ClearPoints(b.text)
        AF.SetPoint(b.text, "LEFT", 5, 0)
        AF.SetPoint(b.text, "RIGHT", b.assignButton, "LEFT", -5, 0)

        if b.text:IsTruncated() then
            AF.ShowTooltip(b, "RIGHT", 2, 0, {b.text:GetText()})
        end
    end, function(b) -- onLeave
        b.assignButton:SetAlpha(0) --! NOTE: if use Hide here will cause BIG problems!
        AF.ClearPoints(b.text)
        AF.SetPoint(b.text, "LEFT", 5, 0)
        AF.SetPoint(b.text, "RIGHT", -5, 0)
        AF.HideTooltip()
    end, function(b) -- onLoad
        if b._inited then return end
        b._inited = true

        b.assignButton = AF.CreateIconButton(b, AF.GetIcon("Link"), 16, 16, nil, "gray", nil, nil, true)
        b.assignButton:SetAlpha(0)
        AF.SetPoint(b.assignButton, "RIGHT", -2, 0)
        b.assignButton:HookOnEnter(b:GetOnEnter())
        b.assignButton:HookOnLeave(b:GetOnLeave())
        b.assignButton:SetOnClick(Profile_ActiveAssignmentMode)
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

    local description = AF.CreateScrollEditBox(managementPane, nil, L["Description"], nil, 140)
    AF.SetPoint(description, "TOPLEFT", url, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(description, "RIGHT", list)
    description.eb.key = "pDescription"
    description:SetOnTextChanged(UpdateProfileInfo)
    description:SetEnabled(false)

    -- buttons
    local new = AF.CreateButton(managementPane, L["New"], "BFI_hover", 78, 20)
    AF.SetPoint(new, "TOPLEFT", description, "BOTTOMLEFT", 0, -15)
    new:SetTexture(AF.GetIcon("Create_Square"), nil, {"LEFT", 2, 0})
    new:SetTextPadding(0)
    new:SetOnClick(ShowNewProfileDialog)

    local rename = AF.CreateButton(managementPane, L["Rename"], "BFI_hover", nil, 20)
    AF.SetPoint(rename, "TOPLEFT", new, "TOPRIGHT", 5, 0)
    AF.SetPoint(rename, "RIGHT", list)
    rename:SetTexture(AF.GetIcon("Rename"), nil, {"LEFT", 2, 0})
    rename:SetTextPadding(0)
    rename:SetEnabled(false)
    rename:SetOnClick(ShowRenameProfileDialog)

    local copy = AF.CreateButton(managementPane, L["Copy"], "BFI_hover", 78, 20)
    AF.SetPoint(copy, "TOPLEFT", new, "BOTTOMLEFT", 0, -5)
    copy:SetTexture(AF.GetIcon("Transfer"), nil, {"LEFT", 2, 0})
    copy:SetTextPadding(0)
    copy:SetOnClick(ShowModuleCopyDialog)

    local delete = AF.CreateButton(managementPane, L["Delete"], "red_hover", nil, 20)
    AF.SetPoint(delete, "TOPLEFT", copy, "TOPRIGHT", 5, 0)
    AF.SetPoint(delete, "RIGHT", list)
    delete:SetTexture(AF.GetIcon("Trash"), nil, {"LEFT", 2, 0})
    delete:SetTextPadding(0)
    delete:SetEnabled(false)
    delete:SetOnClick(ShowDeleteProfileDialog)

    local import = AF.CreateButton(managementPane, L["Import"], "BFI_hover", 68, 20)
    AF.SetPoint(import, "TOPLEFT", copy, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(import, "TOPRIGHT", delete, "BOTTOMRIGHT", 0, -5)
    import:SetTexture(AF.GetIcon("Import1"), nil, {"LEFT", 2, 0})
    import:SetOnClick(ShowProfileImportDialog)

    local export = AF.CreateButton(managementPane, L["Export Profile"], "BFI_hover", nil, 20)
    AF.SetPoint(export, "TOPLEFT", import, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(export, "TOPRIGHT", import, "BOTTOMRIGHT", 0, -5)
    export:SetTexture(AF.GetIcon("Export1"), nil, {"LEFT", 2, 0})
    export:SetEnabled(false)
    export:SetOnClick(ShowProfileExportDialog)

    local exportGlobal = AF.CreateButton(managementPane, L["Export Global"], "BFI_hover", nil, 20)
    AF.SetPoint(exportGlobal, "TOPLEFT", export, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(exportGlobal, "TOPRIGHT", export, "BOTTOMRIGHT", 0, -5)
    exportGlobal:SetTexture(AF.GetIcon("Export1"), nil, {"LEFT", 2, 0})
    exportGlobal:SetOnClick(ShowCommonExportDialog)

    -- load
    function managementPane.Load()
        list:SetData(GetProfileItems())
        list:ScrollToID(selectedProfile)
        list:Select(selectedProfile, true)
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
    if id == "profiles" then
        if not profilesPanel then
            CreateProfilesPanel()
            CreateRolePane()
            CreateSpecPane()
            CreateCharacterPane()
            CreateManagementPane()
            profileUpdateTime = GetTime()
        end
        LoadAll()
        profilesPanel:Show()
    elseif profilesPanel then
        profilesPanel:Hide()
    end
end)