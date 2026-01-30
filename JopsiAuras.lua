local addonName, ns = ...

-- Default Database
local defaultDB = {
    warnEnabled = true,
    ssEnabled = true,
    passiveWarnEnabled = true,
    warningPos = nil,
    optionsPos = nil,
    ssPos = nil,
    passivePos = nil,
    autoRepairEnabled = true
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

-- Warning text
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
text:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
text:SetPoint("CENTER", frame, "CENTER", 0, 0)
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

local ssText = ssFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
ssText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
ssText:SetPoint("CENTER", ssFrame, "CENTER", 0, 0)
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

-- Create the Passive Pet warning frame
local passiveFrame = CreateFrame("Frame", "JopsiAurasPassiveFrame", UIParent)
passiveFrame:SetSize(600, 150)
passiveFrame:Hide()

local passiveFrameBg = passiveFrame:CreateTexture(nil, "BACKGROUND")
passiveFrameBg:SetAllPoints()
passiveFrameBg:SetColorTexture(0.3, 0.4, 1, 0.3) -- Warlock Blueish
passiveFrameBg:Hide()

local passiveText = passiveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
passiveText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
passiveText:SetPoint("CENTER", passiveFrame, "CENTER", 0, 0)
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
    -- 1. Pet Warning Logic
    local showPet = false
    local showPetBg = false

    if JopsiAurasDB.warnEnabled then
        if optionsFrame and optionsFrame:IsShown() then
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
                isPetPending = false
                -- Re-check conditions after delay
                if JopsiAurasDB.warnEnabled then
                    local _, class = UnitClass("player")
                    if class == "WARLOCK" and not HasPetUI() and not UnitExists("pet") and not IsMounted() then
                        frame:Show()
                        if not group:IsPlaying() then group:Play() end
                    end
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
    local isConfigMode = optionsFrame and optionsFrame:IsShown()
    frame:EnableMouse(isConfigMode)
    ssFrame:EnableMouse(isConfigMode)
    passiveFrame:EnableMouse(isConfigMode)

    -- 2. Soulstone Warning Logic
    local showSS = false
    local showSSBg = false

    if JopsiAurasDB.ssEnabled then
        local inCombat = InCombatLockdown() or (event == "PLAYER_REGEN_DISABLED")
        if optionsFrame and optionsFrame:IsShown() then
            showSS = true
            showSSBg = true
        elseif not inCombat then
            local inInstance, instanceType = IsInInstance()
            local _, class = UnitClass("player")
            if class == "WARLOCK" and instanceType == "raid" then
                local spellID = 20707
                -- In 12.0 we use C_Spell exclusively
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
                isSSPending = false
                -- Re-check conditions after delay
                if JopsiAurasDB.ssEnabled and not InCombatLockdown() then
                    local inInstance, instanceType = IsInInstance()
                    local _, class = UnitClass("player")
                    if class == "WARLOCK" and instanceType == "raid" then
                        local cd = C_Spell.GetSpellCooldown(20707)
                        if cd and (cd.startTime == 0 or cd.duration <= 1.5) then
                            ssFrame:Show()
                            if not ssGroup:IsPlaying() then ssGroup:Play() end
                        end
                    end
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
        if optionsFrame and optionsFrame:IsShown() then
            showPassive = true
            showPassiveBg = true
        else
            local _, class = UnitClass("player")
            if class == "WARLOCK" and UnitExists("pet") and not IsMounted() then
                -- Check pet stance using the most appropriate API available in this build
                local GetInfoFunc = (C_PetBar and C_PetBar.GetPetActionInfo) or (C_ActionBar and C_ActionBar.GetPetActionInfo) or GetPetActionInfo
                
                if GetInfoFunc then
                    for i = 1, 10 do
                        local name, _, isToken, isActive = GetInfoFunc(i)
                        
                        -- 12.0 might return a table (like C_Spell.GetSpellCooldown)
                        if type(name) == "table" then
                            isActive = name.isActive
                            isToken = name.isToken
                            name = name.name
                        end
                        
                        -- Robust check for Passive mode across different API versions
                        if name == "PET_MODE_PASSIVE" or name == "PET_ACTION_MODE_PASSIVE" then
                            if isActive then
                                showPassive = true
                            end
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
            C_Timer.After(1.0, function()
                isPassivePending = false
                -- Re-check conditions after delay
                if JopsiAurasDB.passiveWarnEnabled and UnitExists("pet") and not IsMounted() then
                    local GetInfoFunc = (C_PetBar and C_PetBar.GetPetActionInfo) or (C_ActionBar and C_ActionBar.GetPetActionInfo) or GetPetActionInfo
                    if GetInfoFunc then
                        local foundPassive = false
                        for i = 1, 10 do
                            local name, _, _, isActive = GetInfoFunc(i)
                            if type(name) == "table" then
                                isActive = name.isActive
                                name = name.name
                            end
                            if (name == "PET_MODE_PASSIVE" or name == "PET_ACTION_MODE_PASSIVE") and isActive then
                                foundPassive = true
                                break
                            end
                        end
                        if foundPassive then
                            passiveFrame:Show()
                            if not passiveGroup:IsPlaying() then passiveGroup:Play() end
                        end
                    end
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
optionsFrame:SetSize(300, 260) -- Increased height for new checkbox
optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
optionsFrame.title:SetPoint("LEFT", optionsFrame.TitleBg, "LEFT", 5, 0)
optionsFrame.title:SetText("JopsiAuras Options")
optionsFrame:Hide()

MakeMovable(optionsFrame, "optionsPos")

-- Checkbox for enabling/disabling warning
local checkButton = CreateFrame("CheckButton", "JopsiAurasCheckButton", optionsFrame, "ChatConfigCheckButtonTemplate")
checkButton:SetPoint("TOPLEFT", 20, -40)
_G[checkButton:GetName() .. "Text"]:SetText("Enable Pet Warning")
checkButton:SetScript("OnClick", function(self)
    JopsiAurasDB.warnEnabled = self:GetChecked()
    UpdatePetWarning("CONFIG")
end)

-- Soulstone Checkbox
local ssCheckButton = CreateFrame("CheckButton", "JopsiAurasSSCheckButton", optionsFrame, "ChatConfigCheckButtonTemplate")
ssCheckButton:SetPoint("TOPLEFT", 20, -80)
_G[ssCheckButton:GetName() .. "Text"]:SetText("Enable Soulstone Warning")
ssCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.ssEnabled = self:GetChecked()
    UpdatePetWarning("CONFIG") -- This triggers Soulstone check too
end)

-- Passive Pet Checkbox
local passiveCheckButton = CreateFrame("CheckButton", "JopsiAurasPassiveCheckButton", optionsFrame, "ChatConfigCheckButtonTemplate")
passiveCheckButton:SetPoint("TOPLEFT", 20, -120)
_G[passiveCheckButton:GetName() .. "Text"]:SetText("Enable Passive Pet Warning")
passiveCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.passiveWarnEnabled = self:GetChecked()
    UpdatePetWarning("CONFIG")
end)

-- Auto-Repair Checkbox
local autoRepairCheckButton = CreateFrame("CheckButton", "JopsiAurasAutoRepairCheckButton", optionsFrame, "ChatConfigCheckButtonTemplate")
autoRepairCheckButton:SetPoint("TOPLEFT", 20, -160)
_G[autoRepairCheckButton:GetName() .. "Text"]:SetText("Enable Auto-Repair")
autoRepairCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.autoRepairEnabled = self:GetChecked()
end)

-- Initialize Checkbox states
optionsFrame:SetScript("OnShow", function()
    checkButton:SetChecked(JopsiAurasDB.warnEnabled)
    if ssCheckButton then ssCheckButton:SetChecked(JopsiAurasDB.ssEnabled) end
    if passiveCheckButton then passiveCheckButton:SetChecked(JopsiAurasDB.passiveWarnEnabled) end
    if autoRepairCheckButton then autoRepairCheckButton:SetChecked(JopsiAurasDB.autoRepairEnabled) end
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
