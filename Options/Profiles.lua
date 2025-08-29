---@class BFI
local BFI = select(2, ...)
local F = BFI.funcs
local L = BFI.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local profilesPanel
local rolePane, specPane, characterPane, managementPane
local profilesChanged, assignmentFrame

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
    end
end

local function CreateProfileButton(parent, typeName, typeValue, icon)
    local button = AF.CreateButton(parent, nil, "BFI_hover", 155, 20)

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
    AF.SetPoint(assignmentFrame.label, "RIGHT", -5, 0)

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
        local f = GetMouseFoci()[1]
        if f and f._isProfileReceiver then

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
        local inherit = newProfileFrame.inheritDropdown:GetSelectedValue()
    end)
end

local function CreateManagementPane()
    managementPane = AF.CreateTitledPane(profilesPanel, L["Profile Management"], 180, 400)
    AF.SetPoint(managementPane, "TOPRIGHT", -15, -15)

    -- list
    local list = AF.CreateScrollList(managementPane, nil, 0, 0, 9, 20, -1)
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
        end)
        b:HookOnLeave(function()
            b.assignButton:Hide()
        end)

        AF.ClearPoints(b.text)
        AF.SetPoint(b.text, "LEFT", 5, 0)
        AF.SetPoint(b.text, "RIGHT", b.assignButton, "LEFT", -5, 0)
    end)

    -- info boxes
    local author = AF.CreateEditBox(managementPane, L["Author"], nil, 20)
    AF.SetPoint(author, "TOPLEFT", list, "BOTTOMLEFT", 0, -15)
    AF.SetPoint(author, "RIGHT", list)

    local version = AF.CreateEditBox(managementPane, L["Version"], nil, 20)
    AF.SetPoint(version, "TOPLEFT", author, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(version, "RIGHT", list)

    local url = AF.CreateEditBox(managementPane, "URL", nil, 20)
    AF.SetPoint(url, "TOPLEFT", version, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(url, "RIGHT", list)

    local description = AF.CreateScrollEditBox(managementPane, nil, L["Description"], nil, 160)
    AF.SetPoint(description, "TOPLEFT", url, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(description, "RIGHT", list)

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

    local rename = AF.CreateButton(managementPane, nil, "BFI_hover")
    AF.SetPoint(rename, "TOPLEFT", new, "TOPRIGHT", 5, 0)
    AF.SetPoint(rename, "BOTTOMRIGHT", delete, "BOTTOMLEFT", -5, 0)
    rename:SetTexture(AF.GetIcon("Rename"))
    rename:SetTooltip(L["Rename"])

    local import = AF.CreateButton(managementPane, L["Import"], "BFI_hover", nil, 20)
    AF.SetPoint(import, "TOPLEFT", new, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(import, "TOPRIGHT", delete, "BOTTOMRIGHT", 0, -5)
    import:SetTexture(AF.GetIcon("Import1"), nil, {"LEFT", 5, 0})

    local export = AF.CreateButton(managementPane, L["Export"], "BFI_hover", nil, 20)
    AF.SetPoint(export, "TOPLEFT", import, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(export, "TOPRIGHT", import, "BOTTOMRIGHT", 0, -5)
    export:SetTexture(AF.GetIcon("Export1"), nil, {"LEFT", 5, 0})

    -- load
    local profiles = {}
    profilesChanged = true

    function managementPane.Load()
        if not profilesChanged then return end
        profilesChanged = nil

        wipe(profiles)

        for name, t in next, BFIProfile do
            if name ~= "default" then
                tinsert(profiles, {
                    text = name,
                    pAuthor = t.pAuthor,
                    pVersion = t.pVersion,
                    pURL = t.pURL,
                    pDescription = t.pDescription
                })
            end
        end
        tinsert(profiles, 1, {text = _G.DEFAULT, id = "default"})

        list:SetData(profiles)
    end

    function managementPane.LoadProfileInfo(profile)
        author:SetText(profile.pAuthor or "")
        version:SetText(profile.pVersion or "")
        url:SetText(profile.pURL or "")
        description:SetText(profile.pDescription or "")
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
local function Load()
    rolePane.Load()
    specPane.Load()
    characterPane.Load()
    managementPane.Load()
end

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
        Load()
        profilesPanel:Show()
    elseif profilesPanel then
        profilesPanel:Hide()
    end
end)