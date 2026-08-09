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
    ssAlwaysShowEnabled = false,
    passiveWarnEnabled = true,
    passiveShowIcon = true,
    passiveShowText = true,
    passiveCustomText = "PET IN PASSIVE STANCE",
    hsEnabled = true,
    hsShowIcon = true,
    hsShowText = true,
    hsCustomText = "OUT OF HEALTHSTONES",
    hsInCombatEnabled = false,
    warningPos = nil,
    optionsPos = nil,
    ssPos = nil,
    passivePos = nil,
    hsPos = nil,
    autoRepairEnabled = true,
    autoSellJunkEnabled = false,
    ahExpansionFilterEnabled = false,
    fontPath = "Friz Quadrata",
    fontSize = 42,
    lastVersion = ""
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
local fontDropdown
local UpdatePetWarning

-- Create the warning frame
local frame = CreateFrame("Frame", "JopsiAurasWarningFrame", UIParent)
frame:SetSize(600, 150)
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

    local fontSize = JopsiAurasDB and JopsiAurasDB.fontSize or 42
    local iconSize = math.floor(fontSize * 1.5)
    icon:SetSize(iconSize, iconSize)

    if showIcon then icon:Show() else icon:Hide() end
    if showText then 
        txt:Show() 
        txt:SetText(customText)
    else 
        txt:Hide() 
    end

    icon:ClearAllPoints()
    txt:ClearAllPoints()

    if showIcon and showText then
        -- Calculate total width for centering the group
        local txtWidth = txt:GetStringWidth()
        local iconWidth = icon:GetWidth()
        local spacing = 10
        local totalWidth = iconWidth + spacing + txtWidth
        
        -- Start position for the icon to center the whole group
        local startX = -(totalWidth / 2) + (iconWidth / 2)
        icon:SetPoint("CENTER", f, "CENTER", startX, 0)
        txt:SetPoint("LEFT", icon, "RIGHT", spacing, 0)
    elseif showIcon then
        icon:SetPoint("CENTER", f, "CENTER", 0, 0)
    elseif showText then
        txt:SetPoint("CENTER", f, "CENTER", 0, 0)
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

-- Create the Healthstone warning frame
local hsFrame = CreateFrame("Frame", "JopsiAurasHSFrame", UIParent)
hsFrame:SetSize(600, 150)
hsFrame:Hide()

local hsFrameBg = hsFrame:CreateTexture(nil, "BACKGROUND")
hsFrameBg:SetAllPoints()
hsFrameBg:SetColorTexture(0.2, 1, 0.2, 0.2) -- Green tint
hsFrameBg:Hide()

-- HS Icon (Healthstone texture)
local hsIcon = hsFrame:CreateTexture(nil, "OVERLAY")
hsIcon:SetSize(64, 64)
hsIcon:SetPoint("LEFT", hsFrame, "LEFT", 10, 0)
hsIcon:SetTexture(538745) -- Healthstone icon

local hsText = hsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
hsText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
hsText:SetPoint("LEFT", hsIcon, "RIGHT", 10, 0)
hsText:SetText("OUT OF HEALTHSTONES")
hsText:SetTextColor(0.2, 1, 0.2) -- Bright Green

hsFrame:SetFrameStrata("HIGH")
MakeMovable(hsFrame, "hsPos")

-- Animation for Healthstone (subtle pulsing)
local hsGroup = hsFrame:CreateAnimationGroup()
local hsAnim = hsGroup:CreateAnimation("Alpha")
hsAnim:SetFromAlpha(1)
hsAnim:SetToAlpha(0.6)
hsAnim:SetDuration(0.8)
hsAnim:SetOrder(1)
hsAnim:SetSmoothing("IN_OUT")

local hsAnim2 = hsGroup:CreateAnimation("Alpha")
hsAnim2:SetFromAlpha(0.6)
hsAnim2:SetToAlpha(1)
hsAnim2:SetDuration(0.8)
hsAnim2:SetOrder(2)
hsAnim2:SetSmoothing("IN_OUT")

hsGroup:SetLooping("REPEAT")

local function ComparePaths(p1, p2)
    if not p1 or not p2 then return p1 == p2 end
    return p1:lower():gsub("/", "\\") == p2:lower():gsub("/", "\\")
end

local function GetFontPath(name)
    if not name or name == "" then return "Fonts\\FRIZQT__.TTF" end
    
    -- Backward compatibility for saved paths
    if name:find("\\") or name:find("/") then
        return name
    end
    
    if name == "Friz Quadrata" then return "Fonts\\FRIZQT__.TTF" end
    if name == "Arial" then return "Fonts\\ARIALN.TTF" end
    if name == "Morpheus" then return "Fonts\\MORPHEUS.ttf" end
    if name == "Skurri" then return "Fonts\\skurri.ttf" end
    
    if LibStub then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local path = LSM:Fetch("font", name)
            if path then return path end
        end
    end
    return "Fonts\\FRIZQT__.TTF"
end

local function GetFontName(name)
    if not name or name == "" then return "Friz Quadrata" end
    
    -- Backward compatibility: resolve saved paths to names
    if name:find("\\") or name:find("/") then
        if name:lower():find("frizqt") then return "Friz Quadrata" end
        if name:lower():find("arialn") then return "Arial" end
        if name:lower():find("morpheus") then return "Morpheus" end
        if name:lower():find("skurri") then return "Skurri" end
        
        if LibStub then
            local LSM = LibStub("LibSharedMedia-3.0", true)
            if LSM then
                local fonts = LSM:List("font")
                for _, fName in ipairs(fonts) do
                    if ComparePaths(LSM:Fetch("font", fName), name) then
                        return fName
                    end
                end
            end
        end
        return name:match("([^\\/]+)%..+$") or name
    end
    
    return name
end

-- Hidden dummy FontString used to test if a font path is valid/loadable in WoW
local dummyFontString = frame:CreateFontString(nil, "OVERLAY")
dummyFontString:Hide()

local function IsFontValid(path)
    if not path or path == "" then return false end
    -- SetFont returns true/1 on success, nil/false if the font file is missing/broken
    return dummyFontString:SetFont(path, 12)
end

local function UpdateFont()
    local name = JopsiAurasDB and JopsiAurasDB.fontPath
    if not name or name == "" then
        name = "Friz Quadrata"
    end
    
    local path = GetFontPath(name)
    if not IsFontValid(path) then
        print(string.format("|cff9482c9JopsiAuras|r: Font '|cffff0000%s|r' could not be loaded (file missing or client needs restart). Falling back to default.", GetFontName(name)))
        name = "Friz Quadrata"
        path = "Fonts\\FRIZQT__.TTF"
        if JopsiAurasDB then
            JopsiAurasDB.fontPath = "Friz Quadrata"
        end
    end
    
    local size = JopsiAurasDB and JopsiAurasDB.fontSize or 42
    text:SetFont(path, size, "OUTLINE")
    ssText:SetFont(path, size, "OUTLINE")
    passiveText:SetFont(path, size, "OUTLINE")
    hsText:SetFont(path, size, "OUTLINE")
    if JopsiAurasFontDropdown then
        JopsiAurasFontDropdown:SetText(GetFontName(name))
    end
    
    -- Refresh layout centering and scale warning icons dynamically
    UpdatePetWarning("CONFIG")
end

local isSSPending = false
local isPassivePending = false
local isPetPending = false
local isHsPending = false

-- Logic to check pet status
UpdatePetWarning = function(event)
    local isConfigMode = optionsFrame and optionsFrame:IsShown()

    -- Apply visual layouts
    ApplyLayout(frame, frameIcon, text, "warn")
    ApplyLayout(ssFrame, ssIcon, ssText, "ss")
    ApplyLayout(passiveFrame, passiveIcon, passiveText, "passive")
    ApplyLayout(hsFrame, hsIcon, hsText, "hs")

    -- Swap pet warning icon based on spec (Demonology = Felguard)
    if GetSpecialization() == 2 then
        frameIcon:SetTexture(136216) -- Felguard (Demonology)
    else
        frameIcon:SetTexture(136082) -- Default
    end

    -- 1. Pet Warning Logic
    local showPet = false
    local showPetBg = false

    if JopsiAurasDB.warnEnabled then
        if isConfigMode then
            showPet = true
            showPetBg = true
        else
            local _, class = UnitClass("player")
            if class == "WARLOCK"
                and (not HasPetUI() or UnitIsDead("pet"))
                and (not UnitExists("pet") or UnitIsDead("pet"))
                and not IsMounted()
                and not UnitOnTaxi("player")
                and not UnitInVehicle("player")
                and not UnitIsDeadOrGhost("player") then
                showPet = true
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
                        if class == "WARLOCK"
                            and (not HasPetUI() or UnitIsDead("pet"))
                            and (not UnitExists("pet") or UnitIsDead("pet"))
                            and not IsMounted()
                            and not UnitOnTaxi("player")
                            and not UnitInVehicle("player")
                            and not UnitIsDeadOrGhost("player") then
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
    hsFrame:EnableMouse(isConfigMode)

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
            if class == "WARLOCK" and (instanceType == "raid" or JopsiAurasDB.ssAlwaysShowEnabled) then
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
                        if class == "WARLOCK" and (instanceType == "raid" or JopsiAurasDB.ssAlwaysShowEnabled) then
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
            if class == "WARLOCK"
                and UnitExists("pet")
                and not IsMounted()
                and not UnitOnTaxi("player")
                and not UnitInVehicle("player")
                and not UnitIsDeadOrGhost("player") then
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
            C_Timer.After(1.5, function()
                if not isPassivePending then return end
                isPassivePending = false

                local stillShow = false
                if JopsiAurasDB.passiveWarnEnabled then
                    if optionsFrame and optionsFrame:IsShown() then
                        stillShow = true
                    elseif UnitExists("pet")
                        and not IsMounted()
                        and not UnitOnTaxi("player")
                        and not UnitInVehicle("player")
                        and not UnitIsDeadOrGhost("player") then
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

    -- 4. Healthstone Warning Logic
    local showHS = false
    local showHSBg = false

    if JopsiAurasDB.hsEnabled then
        if isConfigMode then
            showHS = true
            showHSBg = true
        elseif not InCombatLockdown() or JopsiAurasDB.hsInCombatEnabled then
            local _, class = UnitClass("player")
            -- Item 5512 = Healthstone, 224464 = Demonic Healthstone (Pact of Gluttony)
            if class == "WARLOCK" and GetItemCount(5512) == 0 and GetItemCount(224464) == 0 then
                showHS = true
            end
        end
    end

    if showHS then
        if isConfigMode or hsFrame:IsShown() then
            hsFrame:Show()
            if not hsGroup:IsPlaying() then hsGroup:Play() end
            isHsPending = false
        elseif not isHsPending then
            isHsPending = true
            C_Timer.After(1.0, function()
                if not isHsPending then return end
                isHsPending = false

                local stillShow = false
                if JopsiAurasDB.hsEnabled then
                    if optionsFrame and optionsFrame:IsShown() then
                        stillShow = true
                    elseif not InCombatLockdown() or JopsiAurasDB.hsInCombatEnabled then
                        local _, class = UnitClass("player")
                        if class == "WARLOCK" and GetItemCount(5512) == 0 and GetItemCount(224464) == 0 then
                            stillShow = true
                        end
                    end
                end

                if stillShow then
                    hsFrame:Show()
                    if not hsGroup:IsPlaying() then hsGroup:Play() end
                end
            end)
        end
    else
        hsFrame:Hide()
        hsGroup:Stop()
        isHsPending = false
    end

    if showHSBg then hsFrameBg:Show() else hsFrameBg:Hide() end
end

-- Options UI
optionsFrame = CreateFrame("Frame", "JopsiAurasOptions", UIParent, "BackdropTemplate")
optionsFrame:SetSize(400, 800)
optionsFrame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16
})
optionsFrame:SetBackdropColor(0.06, 0.05, 0.08, 0.95) -- Deep dark purple-tinted gray
optionsFrame:Hide()

-- Custom Title Bar / Header
local header = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
header:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 0, 0)
header:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", 0, 0)
header:SetHeight(30)
header:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16
})
header:SetBackdropColor(0.18, 0.14, 0.25, 1.0) -- Dark warlock purple title bar

optionsFrame.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.title:SetPoint("LEFT", header, "LEFT", 10, 0)
optionsFrame.title:SetTextColor(0.9, 0.85, 1.0) -- Very light purple
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
optionsFrame.title:SetText("JopsiAuras Options v" .. addonVersion)

-- Custom Close Button
local closeButton = CreateFrame("Button", nil, header, "BackdropTemplate")
closeButton:SetSize(20, 20)
closeButton:SetPoint("RIGHT", header, "RIGHT", -5, 0)

local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
closeText:SetPoint("CENTER")
closeText:SetText("X")
closeText:SetTextColor(0.8, 0.3, 0.3) -- soft red

local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
closeBg:SetAllPoints()
closeBg:SetColorTexture(1, 0, 0, 0) -- transparent initially

closeButton:SetScript("OnClick", function()
    optionsFrame:Hide()
end)
closeButton:SetScript("OnEnter", function()
    closeText:SetTextColor(1, 0.3, 0.3)
    closeBg:SetColorTexture(1, 0, 0, 0.2)
end)
closeButton:SetScript("OnLeave", function()
    closeText:SetTextColor(0.8, 0.3, 0.3)
    closeBg:SetColorTexture(1, 0, 0, 0)
end)

-- Close on ESC
tinsert(UISpecialFrames, "JopsiAurasOptions")

MakeMovable(optionsFrame, "optionsPos")

local function StyleCheckbox(chk)
    local normal = chk:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end
    
    local pushed = chk:GetPushedTexture()
    if pushed then
        pushed:SetAlpha(0)
    end
    
    local highlight = chk:GetHighlightTexture()
    if highlight then
        highlight:SetColorTexture(1, 1, 1, 0.1)
        highlight:SetAllPoints()
    end
    
    -- Create a flat styled background/border frame behind the checkbutton
    local bg = CreateFrame("Frame", nil, chk, "BackdropTemplate")
    bg:SetAllPoints(chk)
    bg:SetFrameLevel(math.max(0, chk:GetFrameLevel() - 1))
    bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    bg:SetBackdropColor(0.04, 0.03, 0.05, 0.8)
    bg:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)
    
    chk.customBg = bg
end

local function CreateWarningSection(parent, dbPrefix, title, yOffset)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset + 10)
    box:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset + 10)
    box:SetHeight(90)
    box:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    box:SetBackdropColor(0.08, 0.07, 0.1, 0.6) -- Slightly lighter purple-tinted dark gray
    box:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8) -- Muted warlock purple border

    local sectionTitle = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOPLEFT", box, "TOPLEFT", 10, 8) -- Anchor to the box itself, position slightly above/on the top border
    sectionTitle:SetText(title)
    sectionTitle:SetTextColor(0.78, 0.71, 0.99) -- Bright warlock purple accent

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
    local enable = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "EnableBtn", box, "UICheckButtonTemplate")
    enable:SetSize(20, 20)
    enable:SetPoint("TOPLEFT", box, "TOPLEFT", 10, -17)
    enable.text = enable:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    enable.text:SetPoint("LEFT", enable, "RIGHT", 5, 0)
    enable.text:SetText("Enable")
    enable:SetScript("OnClick", function(self)
        local key = (dbPrefix == "warn") and "warnEnabled"
            or (dbPrefix == "ss" and "ssEnabled")
            or (dbPrefix == "hs" and "hsEnabled")
            or "passiveWarnEnabled"
        JopsiAurasDB[key] = self:GetChecked()
        ToggleSubItems(self:GetChecked())
        UpdatePetWarning("CONFIG")
    end)
    enable.SetLabelColor = function() end -- No-op for the main toggle
    StyleCheckbox(enable)

    -- Show Text Checkbox
    local showText = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "TextBtn", box, "UICheckButtonTemplate")
    showText:SetSize(20, 20)
    showText:SetPoint("LEFT", enable.text, "RIGHT", 20, 0)
    showText.text = showText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showText.text:SetPoint("LEFT", showText, "RIGHT", 5, 0)
    showText.text:SetText("Show Text")
    showText:SetScript("OnClick", function(self)
        JopsiAurasDB[dbPrefix .. "ShowText"] = self:GetChecked()
        UpdatePetWarning("CONFIG")
    end)
    showText.SetLabelColor = function(self, enabled)
        if enabled then self.text:SetTextColor(0.9, 0.9, 0.9) else self.text:SetTextColor(0.4, 0.4, 0.4) end
    end
    table.insert(subItems, showText)
    StyleCheckbox(showText)

    -- Show Icon Checkbox
    local showIcon = CreateFrame("CheckButton", "JopsiAuras" .. dbPrefix .. "IconBtn", box, "UICheckButtonTemplate")
    showIcon:SetSize(20, 20)
    showIcon:SetPoint("LEFT", showText.text, "RIGHT", 20, 0)
    showIcon.text = showIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showIcon.text:SetPoint("LEFT", showIcon, "RIGHT", 5, 0)
    showIcon.text:SetText("Show Icon")
    showIcon:SetScript("OnClick", function(self)
        JopsiAurasDB[dbPrefix .. "ShowIcon"] = self:GetChecked()
        UpdatePetWarning("CONFIG")
    end)
    showIcon.SetLabelColor = function(self, enabled)
        if enabled then self.text:SetTextColor(0.9, 0.9, 0.9) else self.text:SetTextColor(0.4, 0.4, 0.4) end
    end
    table.insert(subItems, showIcon)
    StyleCheckbox(showIcon)

    -- Custom Text EditBox
    local editBox = CreateFrame("EditBox", "JopsiAuras" .. dbPrefix .. "EditBox", box, "BackdropTemplate")
    editBox:SetHeight(22)
    editBox:SetPoint("TOPLEFT", box, "TOPLEFT", 10, -50)
    editBox:SetPoint("TOPRIGHT", box, "TOPRIGHT", -10, -50)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetTextInsets(5, 5, 0, 0)
    editBox:SetTextColor(0.9, 0.85, 1.0)
    
    editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    editBox:SetBackdropColor(0.04, 0.03, 0.05, 0.8)
    editBox:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)

    editBox:SetScript("OnTextChanged", function(self)
        JopsiAurasDB[dbPrefix .. "CustomText"] = self:GetText()
        UpdatePetWarning("CONFIG")
    end)
    editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editBox.SetLabelColor = function() end
    table.insert(subItems, editBox)

    enable.UpdateState = function() ToggleSubItems(enable:GetChecked()) end

    return enable, showText, showIcon, editBox, box
end

local warnEnable, warnText, warnIcon, warnEdit, warnBox = CreateWarningSection(optionsFrame, "warn", "Summon Pet Warning", -60)
local passiveEnable, passiveText, passiveIcon, passiveEdit, passiveBox = CreateWarningSection(optionsFrame, "passive", "Passive Pet Warning", -164)
local ssEnable, ssText, ssIcon, ssEdit, ssBox = CreateWarningSection(optionsFrame, "ss", "Soulstone Warning", -268)

ssBox:SetHeight(115)

local ssAlwaysShowCheckButton = CreateFrame("CheckButton", "JopsiAurasSSAlwaysShowCheckButton", ssBox, "UICheckButtonTemplate")
ssAlwaysShowCheckButton:SetSize(20, 20)
ssAlwaysShowCheckButton:SetPoint("TOPLEFT", ssBox, "TOPLEFT", 10, -85)
ssAlwaysShowCheckButton.text = ssAlwaysShowCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
ssAlwaysShowCheckButton.text:SetPoint("LEFT", ssAlwaysShowCheckButton, "RIGHT", 5, 0)
ssAlwaysShowCheckButton.text:SetText("Enable SS Warning Outside of Raids")
ssAlwaysShowCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.ssAlwaysShowEnabled = self:GetChecked()
    UpdatePetWarning("CONFIG")
end)
StyleCheckbox(ssAlwaysShowCheckButton)

ssEnable:HookScript("OnClick", function(self)
    local enabled = self:GetChecked()
    local alpha = enabled and 1 or 0.5
    ssAlwaysShowCheckButton:SetEnabled(enabled)
    ssAlwaysShowCheckButton:SetAlpha(alpha)
    if enabled then ssAlwaysShowCheckButton.text:SetTextColor(0.9, 0.9, 0.9) else ssAlwaysShowCheckButton.text:SetTextColor(0.4, 0.4, 0.4) end
end)

local hsEnable, hsOptText, hsOptIcon, hsEdit, hsBox = CreateWarningSection(optionsFrame, "hs", "Healthstone Warning", -397)

hsBox:SetHeight(115)

local hsInCombatCheckButton = CreateFrame("CheckButton", "JopsiAurasHSInCombatCheckButton", hsBox, "UICheckButtonTemplate")
hsInCombatCheckButton:SetSize(20, 20)
hsInCombatCheckButton:SetPoint("TOPLEFT", hsBox, "TOPLEFT", 10, -85)
hsInCombatCheckButton.text = hsInCombatCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hsInCombatCheckButton.text:SetPoint("LEFT", hsInCombatCheckButton, "RIGHT", 5, 0)
hsInCombatCheckButton.text:SetText("Enable HS Warning In Combat")
hsInCombatCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.hsInCombatEnabled = self:GetChecked()
    UpdatePetWarning("CONFIG")
end)
StyleCheckbox(hsInCombatCheckButton)

hsEnable:HookScript("OnClick", function(self)
    local enabled = self:GetChecked()
    local alpha = enabled and 1 or 0.5
    hsInCombatCheckButton:SetEnabled(enabled)
    hsInCombatCheckButton:SetAlpha(alpha)
    if enabled then hsInCombatCheckButton.text:SetTextColor(0.9, 0.9, 0.9) else hsInCombatCheckButton.text:SetTextColor(0.4, 0.4, 0.4) end
end)

local otherBox = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
otherBox:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -625)
otherBox:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -10, -625)
otherBox:SetHeight(115)
otherBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
otherBox:SetBackdropColor(0.08, 0.07, 0.1, 0.6)
otherBox:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)

-- Auto-Repair Checkbox
local repairTitle = otherBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
repairTitle:SetPoint("TOPLEFT", otherBox, "TOPLEFT", 10, 8)
repairTitle:SetText("Other Options")
repairTitle:SetTextColor(0.78, 0.71, 0.99)

local autoRepairCheckButton = CreateFrame("CheckButton", "JopsiAurasAutoRepairCheckButton", otherBox, "UICheckButtonTemplate")
autoRepairCheckButton:SetSize(20, 20)
autoRepairCheckButton:SetPoint("TOPLEFT", otherBox, "TOPLEFT", 10, -20)
autoRepairCheckButton.text = autoRepairCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
autoRepairCheckButton.text:SetPoint("LEFT", autoRepairCheckButton, "RIGHT", 5, 0)
autoRepairCheckButton.text:SetText("Enable Auto-Repair")
autoRepairCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.autoRepairEnabled = self:GetChecked()
end)
StyleCheckbox(autoRepairCheckButton)

local autoSellCheckButton = CreateFrame("CheckButton", "JopsiAurasAutoSellCheckButton", otherBox, "UICheckButtonTemplate")
autoSellCheckButton:SetSize(20, 20)
autoSellCheckButton:SetPoint("TOPLEFT", otherBox, "TOPLEFT", 10, -50)
autoSellCheckButton.text = autoSellCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
autoSellCheckButton.text:SetPoint("LEFT", autoSellCheckButton, "RIGHT", 5, 0)
autoSellCheckButton.text:SetText("Enable Auto-Sell Junk")
autoSellCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.autoSellJunkEnabled = self:GetChecked()
end)
StyleCheckbox(autoSellCheckButton)

local ahFilterCheckButton = CreateFrame("CheckButton", "JopsiAurasAHFilterCheckButton", otherBox, "UICheckButtonTemplate")
ahFilterCheckButton:SetSize(20, 20)
ahFilterCheckButton:SetPoint("TOPLEFT", otherBox, "TOPLEFT", 10, -80)
ahFilterCheckButton.text = ahFilterCheckButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
ahFilterCheckButton.text:SetPoint("LEFT", ahFilterCheckButton, "RIGHT", 5, 0)
ahFilterCheckButton.text:SetText("Enable AH Auto-Filter for Current Expansion Only")
ahFilterCheckButton:SetScript("OnClick", function(self)
    JopsiAurasDB.ahExpansionFilterEnabled = self:GetChecked()
end)
StyleCheckbox(ahFilterCheckButton)

-- New Warning Text Settings Section
local fontBox = CreateFrame("Frame", nil, optionsFrame, "BackdropTemplate")
fontBox:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -516)
fontBox:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -10, -516)
fontBox:SetHeight(95)
fontBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
fontBox:SetBackdropColor(0.08, 0.07, 0.1, 0.6)
fontBox:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)

local fontBoxTitle = fontBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fontBoxTitle:SetPoint("TOPLEFT", fontBox, "TOPLEFT", 10, 8)
fontBoxTitle:SetText("Warning Text Settings")
fontBoxTitle:SetTextColor(0.78, 0.71, 0.99)

-- Custom Font Label & Dropdown Menu inside fontBox
local fontLabel = fontBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fontLabel:SetPoint("TOPLEFT", fontBox, "TOPLEFT", 10, -20)
fontLabel:SetText("Select Warning Font:")
fontLabel:SetTextColor(0.9, 0.9, 0.9)

fontDropdown = CreateFrame("DropdownButton", "JopsiAurasFontDropdown", fontBox, "WowStyle1DropdownTemplate")
fontDropdown:SetSize(180, 22)
fontDropdown:SetPoint("LEFT", fontLabel, "RIGHT", 10, 0)
fontDropdown:SetPoint("RIGHT", fontBox, "RIGHT", -10, 0)

-- Create a flat styled background/border frame behind the dropdown button to match the theme
local bg = CreateFrame("Frame", nil, fontDropdown, "BackdropTemplate")
bg:SetAllPoints(fontDropdown)
bg:SetFrameLevel(math.max(0, fontDropdown:GetFrameLevel() - 1))
bg:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
bg:SetBackdropColor(0.04, 0.03, 0.05, 0.8)
bg:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)

-- Hide default background/border textures of the template by setting their alpha to 0
local arrowTex = fontDropdown.Arrow or fontDropdown.ArrowTexture
local highlightTex = fontDropdown:GetHighlightTexture()
for _, region in ipairs({fontDropdown:GetRegions()}) do
    if region:IsObjectType("Texture") and region ~= arrowTex and region ~= highlightTex then
        region:SetAlpha(0)
    end
end

-- Align text cleanly on the left margin
local dropdownText = fontDropdown:GetFontString()
if dropdownText then
    dropdownText:SetTextColor(0.9, 0.85, 1.0)
    dropdownText:SetPoint("LEFT", fontDropdown, "LEFT", 8, 0)
end

-- Define the selection text callback for WowStyle1DropdownTemplate to draw the selected text
fontDropdown:SetSelectionText(function()
    return GetFontName(JopsiAurasDB and JopsiAurasDB.fontPath)
end)

-- Add hover feedback to our custom background frame
fontDropdown:HookScript("OnEnter", function()
    bg:SetBackdropColor(0.08, 0.06, 0.1, 0.9)
    bg:SetBackdropBorderColor(0.58, 0.51, 0.79, 1.0)
end)
fontDropdown:HookScript("OnLeave", function()
    bg:SetBackdropColor(0.04, 0.03, 0.05, 0.8)
    bg:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)
end)

fontDropdown:SetupMenu(function(dropdown, rootDescription)
    local standardFonts = {
        { name = "Friz Quadrata", key = "Friz Quadrata" },
        { name = "Arial", key = "Arial" },
        { name = "Morpheus", key = "Morpheus" },
        { name = "Skurri", key = "Skurri" }
    }
    
    for _, font in ipairs(standardFonts) do
        rootDescription:CreateRadio(font.name,
            function() return GetFontName(JopsiAurasDB.fontPath) == font.key end,
            function()
                JopsiAurasDB.fontPath = font.key
                UpdateFont()
            end
        )
    end
    
    if LibStub then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local fonts = LSM:List("font")
            if fonts and #fonts > 0 then
                rootDescription:CreateDivider()
                for _, fontName in ipairs(fonts) do
                    rootDescription:CreateRadio(fontName,
                        function() return GetFontName(JopsiAurasDB.fontPath) == fontName end,
                        function()
                            JopsiAurasDB.fontPath = fontName
                            UpdateFont()
                        end
                    )
                end
            end
        end
    end
end)

-- Custom Font Size Label & EditBox inside fontBox
local fontSizeLabel = fontBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fontSizeLabel:SetPoint("TOPLEFT", fontBox, "TOPLEFT", 10, -55)
fontSizeLabel:SetText("Select Font Size:")
fontSizeLabel:SetTextColor(0.9, 0.9, 0.9)

local fontSizeEdit = CreateFrame("EditBox", "JopsiAurasFontSizeEdit", fontBox, "BackdropTemplate")
fontSizeEdit:SetSize(50, 22)
fontSizeEdit:SetPoint("LEFT", fontSizeLabel, "RIGHT", 10, 0)
fontSizeEdit:SetAutoFocus(false)
fontSizeEdit:SetFontObject("ChatFontNormal")
fontSizeEdit:SetTextInsets(5, 5, 0, 0)
fontSizeEdit:SetTextColor(0.9, 0.85, 1.0)
fontSizeEdit:SetNumeric(true)
fontSizeEdit:SetMaxLetters(3)

fontSizeEdit:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
fontSizeEdit:SetBackdropColor(0.04, 0.03, 0.05, 0.8)
fontSizeEdit:SetBackdropBorderColor(0.3, 0.25, 0.4, 0.8)

local originalSize

fontSizeEdit:SetScript("OnEditFocusGained", function(self)
    originalSize = tonumber(self:GetText()) or JopsiAurasDB.fontSize or 42
end)

fontSizeEdit:SetScript("OnTextChanged", function(self)
    local val = tonumber(self:GetText())
    if val and val >= 10 and val <= 100 then
        JopsiAurasDB.fontSize = val
        UpdateFont()
    end
end)

fontSizeEdit:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)

fontSizeEdit:SetScript("OnEditFocusLost", function(self)
    local val = tonumber(self:GetText())
    if not val or val < 10 or val > 100 then
        local fallback = originalSize or JopsiAurasDB.fontSize or 42
        JopsiAurasDB.fontSize = fallback
        self:SetText(tostring(fallback))
        UpdateFont()
    end
end)

fontSizeEdit:SetScript("OnEscapePressed", function(self)
    local fallback = originalSize or JopsiAurasDB.fontSize or 42
    JopsiAurasDB.fontSize = fallback
    self:SetText(tostring(fallback))
    UpdateFont()
    self:ClearFocus()
end)

-- Initialize states
optionsFrame:SetScript("OnShow", function()
    UpdateFont()
    if JopsiAurasFontSizeEdit then
        JopsiAurasFontSizeEdit:SetText(tostring(JopsiAurasDB.fontSize or 42))
    end
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

    ssAlwaysShowCheckButton:SetChecked(JopsiAurasDB.ssAlwaysShowEnabled)
    local ssEnabled = JopsiAurasDB.ssEnabled
    ssAlwaysShowCheckButton:SetEnabled(ssEnabled)
    ssAlwaysShowCheckButton:SetAlpha(ssEnabled and 1 or 0.5)
    if ssEnabled then ssAlwaysShowCheckButton.text:SetTextColor(0.9, 0.9, 0.9) else ssAlwaysShowCheckButton.text:SetTextColor(0.4, 0.4, 0.4) end

    hsEnable:SetChecked(JopsiAurasDB.hsEnabled)
    hsOptIcon:SetChecked(JopsiAurasDB.hsShowIcon)
    hsOptText:SetChecked(JopsiAurasDB.hsShowText)
    hsEdit:SetText(JopsiAurasDB.hsCustomText or "")
    hsEnable:UpdateState()

    hsInCombatCheckButton:SetChecked(JopsiAurasDB.hsInCombatEnabled)
    local hsEnabled = JopsiAurasDB.hsEnabled
    hsInCombatCheckButton:SetEnabled(hsEnabled)
    hsInCombatCheckButton:SetAlpha(hsEnabled and 1 or 0.5)
    if hsEnabled then hsInCombatCheckButton.text:SetTextColor(0.9, 0.9, 0.9) else hsInCombatCheckButton.text:SetTextColor(0.4, 0.4, 0.4) end

    autoRepairCheckButton:SetChecked(JopsiAurasDB.autoRepairEnabled)
    autoSellCheckButton:SetChecked(JopsiAurasDB.autoSellJunkEnabled)
    ahFilterCheckButton:SetChecked(JopsiAurasDB.ahExpansionFilterEnabled)
    UpdatePetWarning("CONFIG")
end)

-- Reset Defaults Button
local resetButton = CreateFrame("Button", "JopsiAurasResetButton", optionsFrame, "BackdropTemplate")
resetButton:SetSize(140, 26)
resetButton:SetPoint("BOTTOM", optionsFrame, "BOTTOM", 0, 15)

resetButton:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
resetButton:SetBackdropColor(0.2, 0.15, 0.28, 1.0) -- Warlock purple background
resetButton:SetBackdropBorderColor(0.58, 0.51, 0.79, 1.0) -- Bright warlock purple border

local buttonText = resetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
buttonText:SetPoint("CENTER")
buttonText:SetText("Reset Defaults")
buttonText:SetTextColor(0.9, 0.85, 1.0)

resetButton:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.3, 0.22, 0.42, 1.0)
end)
resetButton:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.2, 0.15, 0.28, 1.0)
end)

resetButton:SetScript("OnClick", function()
    -- Restore default DB values (except options position, version, and 'Other Options' choices)
    for k, v in pairs(defaultDB) do
        if k ~= "optionsPos" 
            and k ~= "lastVersion" 
            and k ~= "autoRepairEnabled" 
            and k ~= "autoSellJunkEnabled" 
            and k ~= "ahExpansionFilterEnabled" then
            JopsiAurasDB[k] = v
        end
    end
    
    -- Explicitly reset font and size settings
    JopsiAurasDB.fontPath = "Friz Quadrata"
    JopsiAurasDB.fontSize = 42

    -- Manually reset warning frame positions to defaults instantly on screen
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
    
    ssFrame:ClearAllPoints()
    ssFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
    
    passiveFrame:ClearAllPoints()
    passiveFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 250)

    hsFrame:ClearAllPoints()
    hsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    
    -- Refresh UI by re-triggering OnShow
    optionsFrame:GetScript("OnShow")()
    UpdateFont()
    
    print("|cff9482c9JopsiAuras|r: All settings, font properties, and warning positions have been reset to defaults.")
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
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("AUCTION_HOUSE_SHOW")

local function SellJunkItems()
    local totalValue = 0
    local junkCount = 0
    if C_MerchantFrame.IsSellAllJunkEnabled() then
        for bag = 0, 5 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo and itemInfo.quality == 0 and itemInfo.hyperlink and not itemInfo.hasNoValue then
                    junkCount = junkCount + 1
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemInfo.hyperlink)
                    if sellPrice and sellPrice > 0 then
                        totalValue = totalValue + (sellPrice * itemInfo.stackCount)
                    end
                end
            end
        end

        if junkCount > 0 then
            C_MerchantFrame.SellAllJunkItems()

            if totalValue > 0 then
                local gold = math.floor(totalValue / 10000)
                local silver = math.floor((totalValue % 10000) / 100)
                local copper = totalValue % 100
                print(string.format("|cff9482c9JopsiAuras|r: Sold all junk items for |cffffd700%dg|r |cffc7c7c7%ds|r |cffeda55f%dc|r", gold, silver, copper))
            else
                print("|cff9482c9JopsiAuras|r: Sold all junk items.")
            end
        end
    end
end

local ahFilterHooked = false

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
        LoadFramePosition(frame, "warningPos", "CENTER", 0, 250)
        LoadFramePosition(ssFrame, "ssPos", "CENTER", 0, 150)
        LoadFramePosition(passiveFrame, "passivePos", "CENTER", 0, 250)
        LoadFramePosition(hsFrame, "hsPos", "CENTER", 0, 50)
        LoadFramePosition(optionsFrame, "optionsPos", "TOPLEFT", 150, -125)
        
        UpdateFont()
        
        local currentVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
        if JopsiAurasDB.lastVersion ~= currentVersion then
            print("|cff9482c9JopsiAuras|r updated to v" .. currentVersion .. "! You can customize settings in the |cff00ff00/ja|r options menu.")
            JopsiAurasDB.lastVersion = currentVersion
        end

        print("|cff9482c9JopsiAuras loaded|r - Type |cff00ff00/ja|r for options")
    elseif event == "MERCHANT_SHOW" then
        if JopsiAurasDB.autoSellJunkEnabled then
            SellJunkItems()
        end

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
    elseif event == "AUCTION_HOUSE_SHOW" then
        if not ahFilterHooked then
            if AuctionHouseFrame and AuctionHouseFrame.SearchBar then
                local searchBar = AuctionHouseFrame.SearchBar
                
                local function applyAHFilter()
                    if JopsiAurasDB.ahExpansionFilterEnabled and searchBar.FilterButton and searchBar.FilterButton.filters and Enum.AuctionHouseFilter and Enum.AuctionHouseFilter.CurrentExpansionOnly ~= nil then
                        searchBar.FilterButton.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly] = true
                        if searchBar.UpdateClearFiltersButton then
                            searchBar:UpdateClearFiltersButton()
                        end
                    end
                end

                searchBar:HookScript("OnShow", function()
                    C_Timer.After(0, applyAHFilter)
                end)
                
                ahFilterHooked = true
                -- Run it explicitly the first time as OnShow for the SearchBar might already have fired
                C_Timer.After(0, applyAHFilter)
            end
        end
    end

    UpdatePetWarning(event)
end)
