-------------------------------------------------------------------------------
--- Config
-------------------------------------------------------------------------------

local config = {
    updateInterval = 30,
    localtime = true,
    font = { STANDARD_TEXT_FONT, 12, "OUTLINE" },
    fontShadow = { 0, 0, 0, 0.35 },
    color = { 0, 1, 0 },
}

-------------------------------------------------------------------------------
--- Create Status Frame
-------------------------------------------------------------------------------

local statusFrame = CreateFrame("Frame", "ZStatus", UIParent)
statusFrame:SetSize(148, 64)
statusFrame:RegisterForDrag("LeftButton")
statusFrame:SetClampedToScreen(true)

statusFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

statusFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
    ZStatusDB.point = point
    ZStatusDB.relativePoint = relativePoint
    ZStatusDB.xOffset = xOffset
    ZStatusDB.yOffset = yOffset
end)

local texture = statusFrame:CreateTexture(nil, "OVERLAY")
texture:SetAllPoints()
texture:SetColorTexture(0, 0.8, 0, 0.6)
texture:Hide()

local statusString1 = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusString1:SetPoint("TOPLEFT", 0, 0)

local statusString2 = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusString2:SetPoint("TOPLEFT", 0, -12)

local statusString3 = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusString3:SetPoint("TOPLEFT", 0, -24)

local statusString4 = statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusString4:SetPoint("TOPLEFT", 0, -36)

for _, v in next, { statusString1, statusString2, statusString3, statusString4 } do
    v:SetFont(unpack(config.font))
    v:SetTextColor(unpack(config.color))
    v:SetShadowColor(unpack(config.fontShadow))
end

-------------------------------------------------------------------------------
--- Functions
-------------------------------------------------------------------------------

local function InitDB()
    if not ZStatusDB then
        ZStatusDB = {
            point = "TOPLEFT",
            relativePoint = "TOPLEFT",
            xOffset = 2,
            yOffset = -2,
        }
    end
end

local function SetPos()
    statusFrame:ClearAllPoints()
    statusFrame:SetPoint(ZStatusDB.point, UIParent, ZStatusDB.relativePoint, ZStatusDB.xOffset, ZStatusDB.yOffset)
end

local function SetStatusText()
    local cal = C_DateAndTime.GetCurrentCalendarTime()
    local epoch = time()

    local clock
    if config.localtime then
        --clock = date("%H:%M", epoch)
        clock = date("%I:%M", epoch)
    else
        clock = format("%02d:%02d", cal.hour, cal.minute)
    end

    local zone = GetMinimapZoneText()
    local slots = CalculateTotalNumberOfFreeBagSlots()
    local _, _, home, world = GetNetStats()

    local xp = UnitXP("player")
    local xpMax = UnitXPMax("player")
    local xpPerc = (xp / xpMax * 100)
    local xpRemaining = (xpMax - xp)
    local exhaustion = GetXPExhaustion() or 0

    statusString1:SetFormattedText("(%d) %s %s", slots, zone, clock)
    statusString2:SetFormattedText("%d/%d", home, world)
    statusString3:SetFormattedText("%d %d (%d%%)", xpRemaining, exhaustion, xpPerc)
    statusString4:SetText(nil)
end

local counter = 0
statusFrame:SetScript("OnUpdate", function(self, elapsed)
    counter = counter + elapsed
    if counter > config.updateInterval then
        SetStatusText()
        counter = 0
    end
end)

SLASH_ZSTATUS1 = "/zstatus"
SLASH_ZSTATUS2 = "/zst"
SlashCmdList["ZSTATUS"] = function(msg)
    if msg == "reset" then
        ZStatusDB = nil
        InitDB()
        SetPos()
    else
        if texture:IsShown() then
            statusFrame:SetMovable(false)
            statusFrame:EnableMouse(false)
            texture:Hide()
        else
            statusFrame:SetMovable(true)
            statusFrame:EnableMouse(true)
            texture:Show()
        end
    end
end

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_LOGIN")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
eventHandler:RegisterEvent("ZONE_CHANGED")
eventHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
eventHandler:RegisterEvent("BAG_UPDATE")
eventHandler:RegisterEvent("PLAYER_XP_UPDATE")
eventHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitDB()
        SetPos()
    else
        SetStatusText()
    end
end)
