local addonName, ns = ...

-- Default Database
local defaultDB = {
    warnEnabled = true,
    warnShowIcon = true,
    warnShowText = true,
    warnCustomText = "SUMMON YOUR PET!",
    ssEnabled = true,
    ssShowIcon = true,
    ssShowText = true,
    ssCustomText = "SOULSTONE A HEALER!",
    passiveWarnEnabled = true,
    passiveShowIcon = true,
    passiveShowText = true,
    passiveCustomText = "PET IN PASSIVE STANCE",
    warningPos = nil,
    optionsPos = nil,
    ssPos = nil,
    passivePos = nil,
    autoRepairEnabled = true,
    firstRun = true
}
JopsiAurasDB = JopsiAurasDB or defaultDB

local function SaveFramePosition(frame, dbKey)
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    JopsiAurasDB[dbKey] = { point = point, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs }
end

local function LoadFramePosition(frame, dbKey, defaultPoint, defaultX, defaultY)
    local pos = JopsiAurasDB[dbKey]
    if pos and pos.point then
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        frame:ClearAllPoints()
        frame:SetPoint(defaultPoint, UIParent, defaultPoint, defaultX, defaultY)
    end
end

local function MakeMovable(frame, dbKey)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveFramePosition(self, dbKey)
    end)
end

-- Forward declaration for scope
local optionsFrame

-- Create the warning frame
local frame = CreateFrame("Frame", "JopsiAurasWarningFrame", UIParent)
frame:SetSize(400, 100)
frame:Hide()

-- Background for visibility during configuration
local frameBg = frame:CreateTexture(nil, "BACKGROUND")
frameBg:SetAllPoints()
frameBg:SetColorTexture(1, 1, 1, 0.1)
frameBg:Hide()

MakeMovable(frame, "warningPos")

-- Icon
local frameIcon = frame:CreateTexture(nil, "OVERLAY")
frameIcon:SetSize(64, 64)
frameIcon:SetPoint("LEFT", frame, "LEFT", 10, 0)
frameIcon:SetTexture(136082)

-- Warning text
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
text:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
text:SetPoint("LEFT", frameIcon, "RIGHT", 10, 0)
text:SetText("SUMMON YOUR PET!")
text:SetTextColor(1, 0, 0) -- Bright Red

frame:SetFrameStrata("HIGH")

-- Animation (subtle pulsing)
local group = frame:CreateAnimationGroup()
local anim = group:CreateAnimation("Alpha")
anim:SetFromAlpha(1)
anim:SetToAlpha(0.6)
anim:SetDuration(0.8)
anim:SetOrder(1)
anim:SetSmoothing("IN_OUT")

local anim2 = group:CreateAnimation("Alpha")
anim2:SetFromAlpha(0.6)
anim2:SetToAlpha(1)
anim2:SetDuration(0.8)
anim2:SetOrder(2)
anim2:SetSmoothing("IN_OUT")

group:SetLooping("REPEAT")

-- Create the Soulstone warning frame
local ssFrame = CreateFrame("Frame", "JopsiAurasSSFrame", UIParent)
ssFrame:SetSize(600, 150)
ssFrame:Hide()

local ssFrameBg = ssFrame:CreateTexture(nil, "BACKGROUND")
ssFrameBg:SetAllPoints()
ssFrameBg:SetColorTexture(0.7, 0.3, 1, 0.3)
ssFrameBg:Hide()

-- SS Icon
local ssIcon = ssFrame:CreateTexture(nil, "OVERLAY")
ssIcon:SetSize(64, 64)
ssIcon:SetPoint("LEFT", ssFrame, "LEFT", 10, 0)
ssIcon:SetTexture(136210) -- Soulstone Icon

local ssText = ssFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
ssText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
ssText:SetPoint("LEFT", ssIcon, "RIGHT", 10, 0)
ssText:SetText("SOULSTONE A HEALER!")
ssText:SetTextColor(0.7, 0.3, 1)

ssFrame:SetFrameStrata("HIGH")
MakeMovable(ssFrame, "ssPos")

-- Animation for Soulstone (subtle pulsing)
local ssGroup = ssFrame:CreateAnimationGroup()
local ssAnim = ssGroup:CreateAnimation("Alpha")
ssAnim:SetFromAlpha(1)
ssAnim:SetToAlpha(0.6)
ssAnim:SetDuration(0.8)
ssAnim:SetOrder(1)
ssAnim:SetSmoothing("IN_OUT")

local ssAnim2 = ssGroup:CreateAnimation("Alpha")
ssAnim2:SetFromAlpha(0.6)
ssAnim2:SetToAlpha(1)
ssAnim2:SetDuration(0.8)
ssAnim2:SetOrder(2)
ssAnim2:SetSmoothing("IN_OUT")

ssGroup:SetLooping("REPEAT")

-- Helper to apply layout based on icon/text visibility
local function ApplyLayout(f, icon, txt, dbPrefix)
    local showIcon = JopsiAurasDB[dbPrefix .. "ShowIcon"]
    local showText = JopsiAurasDB[dbPrefix .. "ShowText"]
    local customText = JopsiAurasDB[dbPrefix .. "CustomText"] or ""

    if showIcon then icon:Show() else icon:Hide() end
    if showText then 
        txt:Show() 
        txt:SetText(customText)
    else 
        txt:Hide() 
    end
end

-- Create the Passive Pet warning frame
local passiveFrame = CreateFrame("Frame", "JopsiAurasPassiveFrame", UIParent)
passiveFrame:SetSize(600, 150)
passiveFrame:Hide()

local passiveFrameBg = passiveFrame:CreateTexture(nil, "BACKGROUND")
passiveFrameBg:SetAllPoints()
passiveFrameBg:SetColorTexture(0.3, 0.4, 1, 0.3) -- Warlock Blueish
passiveFrameBg:Hide()

-- Passive Icon
local passiveIcon = passiveFrame:CreateTexture(nil, "OVERLAY")
passiveIcon:SetSize(64, 64)
passiveIcon:SetPoint("LEFT", passiveFrame, "LEFT", 10, 0)
passiveIcon:SetTexture(132311) -- Passive Icon

local passiveText = passiveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
passiveText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
passiveText:SetPoint("LEFT", passiveIcon, "RIGHT", 10, 0)
passiveText:SetText("PET IN PASSIVE STANCE")
passiveText:SetTextColor(0.3, 0.4, 1)

passiveFrame:SetFrameStrata("HIGH")
MakeMovable(passiveFrame, "passivePos")

-- Animation for Passive Pet (subtle pulsing)
local passiveGroup = passiveFrame:CreateAnimationGroup()
local passiveAnim = passiveGroup:CreateAnimation("Alpha")
passiveAnim:SetFromAlpha(1)
passiveAnim:SetToAlpha(0.6)
passiveAnim:SetDuration(0.8)
passiveAnim:SetOrder(1)
passiveAnim:SetSmoothing("IN_OUT")

local passiveAnim2 = passiveGroup:CreateAnimation("Alpha")
passiveAnim2:SetFromAlpha(0.6)
passiveAnim2:SetToAlpha(1)
passiveAnim2:SetDuration(0.8)
passiveAnim2:SetOrder(2)
passiveAnim2:SetSmoothing("IN_OUT")

passiveGroup:SetLooping("REPEAT")

local isSSPending = false
local isPassivePending = false
local isPetPending = false

-- Logic to check pet status
local function UpdatePetWarning(event)
    local isConfigMode = optionsFrame and optionsFrame:IsShown()

    -- Apply visual layouts
    ApplyLayout(frame, frameIcon, text, "warn")
    ApplyLayout(ssFrame, ssIcon, ssText, "ss")
    ApplyLayout(passiveFrame, passiveIcon, passiveText, "passive")

    -- 1. Pet Warning Logic
    local showPet = false
    local showPetBg = false

    if JopsiAurasDB.warnEnabled then
        if isConfigMode then
            showPet = true
            showPetBg = true
        else
            local _, class = UnitClass("player")
            if class == "WARLOCK" then
                if not HasPetUI() and not UnitExists("pet") and not IsMounted() then
                    showPet = true
                end
            end
        end
    end

    if showPet then
        if isConfigMode or frame:IsShown() then
            frame:Show()
            if not group:IsPlaying() then group:Play() end
            isPetPending = false
        elseif not isPetPending then
            isPetPending = true
            C_Timer.After(1.0, function()
                if not isPetPending then return end -- Guard against rapid changes
                isPetPending = false
                
                -- Check if we still want to show it
                local stillShow = false
                if JopsiAurasDB.warnEnabled then
                    if optionsFrame and optionsFrame:IsShown() then
                        stillShow = true
                    else
                        local _, class = UnitClass("player")
                        if class == "WARLOCK" and not HasPetUI() and not UnitExists("pet") and not IsMounted() then
                            stillShow = true
                        end
                    end
                end

                if stillShow then
                    frame:Show()
                    if not group:IsPlaying() then group:Play() end
                end
            end)
        end
    else
        frame:Hide()
        group:Stop()
        isPetPending = false
    end

    if showPetBg then frameBg:Show() else frameBg:Hide() end

    -- Enable/Disable movement for both warnings based on options visibility
    frame:EnableMouse(isConfigMode)
    ssFrame:EnableMouse(isConfigMode)
    passiveFrame:EnableMouse(isConfigMode)

    -- 2. Soulstone Warning Logic
    local showSS = false
    local showSSBg = false

    if JopsiAurasDB.ssEnabled then
        if isConfigMode then
            showSS = true
            showSSBg = true
        elseif not (InCombatLockdown() or (event == "PLAYER_REGEN_DISABLED")) then
            local inInstance, instanceType = IsInInstance()
            local _, class = UnitClass("player")
            if class == "WARLOCK" and instanceType == "raid" then
                local spellID = 20707
                local cd = C_Spell.GetSpellCooldown(spellID)
                if cd and (cd.startTime == 0 or cd.duration <= 1.5) then
                    showSS = true
                end
            end
        end
    end

    if showSS then
        if isConfigMode or ssFrame:IsShown() then
            ssFrame:Show()
            if not ssGroup:IsPlaying() then ssGroup:Play() end
            isSSPending = false
        elseif not isSSPending then
            isSSPending = true
            C_Timer.After(1.0, function()
                if not isSSPending then return end
                isSSPending = false

                local stillShow = false
                if JopsiAurasDB.ssEnabled then
                    if optionsFrame and optionsFrame:IsShown() then
                        stillShow = true
                    elseif not InCombatLockdown() then
                        local inInstance, instanceType = IsInInstance()
                        local _, class = UnitClass("player")
                        if class == "WARLOCK" and instanceType == "raid" then
                            local cd = C_Spell.GetSpellCooldown(20707)
                            if cd and (cd.startTime == 0 or cd.duration <= 1.5) then
                                stillShow = true
                            end
                        end
                    end
                end

                if stillShow then
                    ssFrame:Show()
                    if not ssGroup:IsPlaying() then ssGroup:Play() end
                end
            end)
        end
    else
        ssFrame:Hide()
        ssGroup:Stop()
        isSSPending = false
    end

    if showSSBg then ssFrameBg:Show() else ssFrameBg:Hide() end

    -- 3. Passive Pet Warning Logic
    local showPassive = false
    local showPassiveBg = false

    if JopsiAurasDB.passiveWarnEnabled then
        if isConfigMode then
            showPassive = true
            showPassiveBg = true
        else
            local _, class = UnitClass("player")
            if class == "WARLOCK" and UnitExists("pet") and not IsMounted() then
                local GetInfoFunc = (C_PetBar and C_PetBar.GetPetActionInfo) or (C_ActionBar and C_ActionBar.GetPetActionInfo) or GetPetActionInfo
                if GetInfoFunc then
                    for i = 1, 10 do
                        local name, _, isToken, isActive = GetInfoFunc(i)
                        if type(name) == "table" then
                            isActive = name.isActive
                            name = name.name
                        end
                        if (name == "PET_MODE_PASSIVE" or name == "PET_ACTION_MODE_PASSIVE") and isActive then
                            showPassive = true
                            break
                        end
                    end
                end
            end
        end
    end

    if showPassive then
        if isConfigMode or passiveFrame:IsShown() then
            passiveFrame:Show()
            if not passiveGroup:IsPlaying() then passiveGroup:Play() end
            isPassivePending = false
        elseif not isPassivePending then
            isPassivePending = true
            C_Timer.After(0.5, function()
                if not isPassivePending then return end
                isPassivePending = false

                local stillShow = false
                if JopsiAurasDB.passiveWarnEnabled then
                    if optionsFrame and optionsFrame:IsShown() then
                        stillShow = true
                    elseif UnitExists("pet") and not IsMounted() then
                        local GetInfoFunc = (C_PetBar and C_PetBar.GetPetActionInfo) or (C_ActionBar and C_ActionBar.GetPetActionInfo) or GetPetActionInfo
                        if GetInfoFunc then
                            for i = 1, 10 do
                                local name, _, _, isActive = GetInfoFunc(i)
                                if type(name) == "table" then
                                    isActive = name.isActive
                                    name = name.name
                                end
                                if (name == "PET_MODE_PASSIVE" or name == "PET_ACTION_MODE_PASSIVE") and isActive then
                                    stillShow = true
                                    break
                                end
                            end
                        end
                    end
                end

                if stillShow then
                    passiveFrame:Show()
                    if not passiveGroup:IsPlaying() then passiveGroup:Play() end
                end
            end)
        end
    else
        passiveFrame:Hide()
        passiveGroup:Stop()
        isPassivePending = false
    end

    if showPassiveBg then passiveFrameBg:Show() else passiveFrameBg:Hide() end
end

-- Options UI
optionsFrame = CreateFrame("Frame", "JopsiAurasOptions", UIParent, "BasicFrameTemplateWithInset")
optionsFrame:SetSize(400, 520)
optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
optionsFrame.title:SetPoint("LEFT", optionsFrame.TitleBg, "LEFT", 5, 0)
optionsFrame.title:SetText("JopsiAuras Options")
optionsFrame:Hide()

MakeMovable(optionsFrame, "optionsPos")

local function CreateWarningSection(parent, dbPrefix, title, yOffset)
    local sectionTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", 20, yOffset)
    sectionTitle:SetText(title)

    local subItems = {}
    local function ToggleSubItems(enabled)
        local alpha = enabled and 1 or 0.5
        for _, item in ipairs(subItems) do
            item:SetLabelColor(enabled)
            item:SetEnabled(enabled)
            item:SetAlpha(alpha)
        end
    end

    -- Enable Checkbox
    local enable = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "EnableBtn", parent, "UICheckButtonTemplate")
    enable:SetSize(24, 24)
    enable:SetPoint("TOPLEFT", 20, yOffset - 20)
    enable.text = enable:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    enable.text:SetPoint("LEFT", enable, "RIGHT", 5, 0)
    enable.text:SetText("Enable")
    enable:SetScript("OnClick", function(self)
        local key = (dbPrefix == "warn") and "warnEnabled" or (dbPrefix == "ss" and "ssEnabled" or "passiveWarnEnabled")
        JopsiAurasDB[key] = self:GetChecked()
        ToggleSubItems(self:GetChecked())
        UpdatePetWarning("CONFIG")
    end)
    enable.SetLabelColor = function() end -- No-op for the main toggle

    -- Show Text Checkbox (Now before icon)
    local showText = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "TextBtn", parent, "UICheckButtonTemplate")
    showText:SetSize(24, 24)
    showText:SetPoint("TOPLEFT", 120, yOffset - 20)
    showText.text = showText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showText.text:SetPoint("LEFT", showText, "RIGHT", 5, 0)
    showText.text:SetText("Show Text")
    showText:SetScript("OnClick", function(self)
        JopsiAurasDB[dbPrefix .. "ShowText"] = self:GetChecked()
        UpdatePetWarning("CONFIG")
    end)
    showText.SetLabelColor = function(self, enabled)
        if enabled then self.text:SetTextColor(1, 1, 1) else self.text:SetTextColor(0.5, 0.5, 0.5) end
    end
    table.insert(subItems, showText)

    -- Show Icon Checkbox (Now after text)
    local showIcon = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "IconBtn", parent, "UICheckButtonTemplate")
    showIcon:SetSize(24, 24)
    showIcon:SetPoint("TOPLEFT", 240, yOffset - 20)
    showIcon.text = showIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showIcon.text:SetPoint("LEFT", showIcon, "RIGHT", 5, 0)
    showIcon.text:SetText("Show Icon")
    showIcon:SetScript("OnClick", function(self)
        JopsiAurasDB[dbPrefix .. "ShowIcon"] = self:GetChecked()
        UpdatePetWarning("CONFIG")
    end)
    showIcon.SetLabelColor = function(self, enabled)
        if enabled then self.text:SetTextColor(1, 1, 1) else self.text:SetTextColor(0.5, 0.5, 0.5) end
    end
    table.insert(subItems, showIcon)

    -- Custom Text EditBox
    local editBox = CreateFrame("EditBox", "JopsiAuras" .. dbPrefix .. "EditBox", parent, "InputBoxTemplate")
    editBox:SetSize(300, 30)
    editBox:SetPoint("TOPLEFT", 30, yOffset - 50)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnTextChanged", function(self)
        JopsiAurasDB[dbPrefix .. "CustomText"] = self:GetText()
        UpdatePetWarning("CONFIG")
    end)
    editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editBox.SetLabelColor = function() end -- InputBox text color is handled differently, SetAlpha is enough
    table.insert(subItems, editBox)

    enable.UpdateState = function() ToggleSubItems(enable:GetChecked()) end

    return enable, showText, showIcon, editBox
end

local warnEnable, warnText, warnIcon, warnEdit = CreateWarningSection(optionsFrame, "warn", "Summon Pet Warning", -40)
local passiveEnable, passiveText, passiveIcon, passiveEdit = CreateWarningSection(optionsFrame, "passive", "Passive Pet Warning", -140)
local ssEnable, ssText, ssIcon, ssEdit = CreateWarningSection(optionsFrame, "ss", "Soulstone Warning", -240)

-- Auto-Repair Checkbox
local repairTitle = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
repairTitle:SetPoint("TOPLEFT", 20, -340)
repairTitle:SetText("Other Options")

local autoRepairCheckButton = CreateFrame("CheckButton", "JopsiAurasAutoRepairCheckButton", optionsFrame, "UICheckButtonTemplate")
autoRepairCheckButton:SetSize(24, 24)
autoRepairCheckButton:SetPoint("TOPLEFT", 20, -360)
autoRepairCheckButton.text = autoRepairCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
autoRepairCheckButton.text:SetPoint("LEFT", autoRepairCheckButton, "RIGHT", 5, 0)
autoRepairCheckButton.text:SetText("Enable Auto-Repair")
autoRepairCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.autoRepairEnabled = self:GetChecked()
end)

-- Initialize states
optionsFrame:SetScript("OnShow", function()
    warnEnable:SetChecked(JopsiAurasDB.warnEnabled)
    warnIcon:SetChecked(JopsiAurasDB.warnShowIcon)
    warnText:SetChecked(JopsiAurasDB.warnShowText)
    warnEdit:SetText(JopsiAurasDB.warnCustomText or "")
    warnEnable:UpdateState()

    passiveEnable:SetChecked(JopsiAurasDB.passiveWarnEnabled)
    passiveIcon:SetChecked(JopsiAurasDB.passiveShowIcon)
    passiveText:SetChecked(JopsiAurasDB.passiveShowText)
    passiveEdit:SetText(JopsiAurasDB.passiveCustomText or "")
    passiveEnable:UpdateState()

    ssEnable:SetChecked(JopsiAurasDB.ssEnabled)
    ssIcon:SetChecked(JopsiAurasDB.ssShowIcon)
    ssText:SetChecked(JopsiAurasDB.ssShowText)
    ssEdit:SetText(JopsiAurasDB.ssCustomText or "")
    ssEnable:UpdateState()

    autoRepairCheckButton:SetChecked(JopsiAurasDB.autoRepairEnabled)
    UpdatePetWarning("CONFIG")
end)

optionsFrame:SetScript("OnHide", function()
    UpdatePetWarning()
end)

-- Slash Command Handler
SLASH_JOPSIARAS1 = "/ja"
SlashCmdList["JOPSIARAS"] = function(msg)
    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end

-- Event handling
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Ensure DB is loaded
        if not JopsiAurasDB then
            JopsiAurasDB = defaultDB
        else
            -- Merge defaults
            for k, v in pairs(defaultDB) do
                if JopsiAurasDB[k] == nil then
                    JopsiAurasDB[k] = v
                end
            end
        end
        
        -- Load positions
        LoadFramePosition(frame, "warningPos", "CENTER", 0, 150)
        LoadFramePosition(ssFrame, "ssPos", "CENTER", 0, 50)
        LoadFramePosition(passiveFrame, "passivePos", "CENTER", 0, -50)
        LoadFramePosition(optionsFrame, "optionsPos", "TOPLEFT", 150, -150)
        
        if JopsiAurasDB.firstRun then
            print("|cff9482c9JopsiAuras|r - You can now customize warning icons and text in the |cff00ff00/ja|r options menu!")
            JopsiAurasDB.firstRun = false
        end

        print("|cff9482c9JopsiAuras loaded|r - Type |cff00ff00/ja|r for options")
    elseif event == "MERCHANT_SHOW" then
        if JopsiAurasDB.autoRepairEnabled and CanMerchantRepair() then
            local cost, canRepair = GetRepairAllCost()
            if canRepair and cost > 0 then
                if GetMoney() >= cost then
                    local RepairFunc = (C_Merchant and C_Merchant.RepairAllItems) or RepairAllItems
                    if RepairFunc then
                        RepairFunc()
                        local gold = floor(cost / 10000)
                        local silver = floor((cost % 10000) / 100)
                        local copper = cost % 100
                        print(string.format("|cff9482c9JopsiAuras|r: Repaired all items for |cffffd700%dg|r |cffc7c7c7%ds|r |cffeda55f%dc|r", gold, silver, copper))
                    end
                else
                    print("|cff9482c9JopsiAuras|r: |cffff0000Not enough gold to repair!|r")
                end
            end
        end
    end

    UpdatePetWarning(event)
end)
