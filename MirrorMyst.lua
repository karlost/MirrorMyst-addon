local addonName = "MirrorMyst"
local MirrorMyst = LibStub("AceAddon-3.0"):GetAddon(addonName)

function MirrorMyst:OnEnable()
    self:Print("|cffff0000TMog-MarketPlace:|r Type |cffffff00/tmogmpexport|r to export to Transmog master or |cffffff00/mm|r for settings.")
end

function MirrorMyst:GetBagSettings()
    return self.db.profile
end

-- Base64 encoding/decoding functions
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Pomocná funkce pro kontrolu předmětu
local function canExportItem(itemID)
    -- Kontrola transmogrifikace
    if not C_Transmog.CanTransmogItem(itemID) then
        return false
    end
    
    -- Kontrola vazby předmětu
    local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemID)
    -- bindType: 0 = není vázaný, 1 = váže při sebrání, 2 = váže při nasazení, 3 = váže na účet
    if bindType == 1 then -- pouze předměty co nejsou BoP
        return false
    end
    
    return true
end

local function encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--
local frame = CreateFrame("Frame", "InventoryTMMOGexport", UIParent, "BackdropTemplate")
frame:SetSize(600, 600)
frame:SetPoint("CENTER")
frame:Hide()

-- Make frame movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Add a title bar
local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
titleBar:SetHeight(25)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

-- Add title text
local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("CENTER", titleBar, "CENTER")
title:SetText("TMog MarketPlace Export")

-- Add close button
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
closeButton:SetScript("OnClick", function() frame:Hide() end)

-- Add backdrop
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)

tinsert(UISpecialFrames, "InventoryTMMOGexport")

frame.scrollFrame = CreateFrame("ScrollFrame", "InventoryTMMOGexportScrollFrame", frame, "InputScrollFrameTemplate")
frame.scrollFrame:SetPoint("TOPLEFT", 8, -30)
frame.scrollFrame:SetPoint("BOTTOMRIGHT", -12, 10)

local editBox = frame.scrollFrame.EditBox 
editBox:SetFontObject("ChatFontNormal")
editBox:SetAllPoints(true)
editBox:SetWidth(frame.scrollFrame:GetWidth()) 
editBox:SetScript("OnEscapePressed", editBox.ClearFocus)


SLASH_TMOGMPEXPORT1 = "/tmogmpexport"

function SlashCmdList.TMOGMPEXPORT(msg)
    local settings = MirrorMyst:GetBagSettings()
    local list = {}
    
    -- Export from bags
    for i = 0, 4 do
        if settings.bags[i] then
            local slot_in_bag = C_Container.GetContainerNumSlots(i)
            for j = 1, slot_in_bag do
                local itemInfo = C_Container.GetContainerItemInfo(i, j)
                if itemInfo then
                    local itemID = itemInfo.itemID
                    if canExportItem(itemID) then
                        tinsert(list, string.format('{"item_id":"%s"}', itemID))
                    end
                end
            end
        end
    end

    -- Export from bank if it's open and selected
    if BankFrame and BankFrame:IsVisible() then
        -- Main bank (BANK_CONTAINER = -1)
        if settings.bankMain then
            local bankSlots = C_Container.GetContainerNumSlots(-1)
            for j = 1, bankSlots do
                local itemInfo = C_Container.GetContainerItemInfo(-1, j)
                if itemInfo then
                    local itemID = itemInfo.itemID
                    if canExportItem(itemID) then
                        tinsert(list, string.format('{"item_id":"%s"}', itemID))
                    end
                end
            end
        end

        -- Bank bags (5-11)
        for i = 1, 7 do
            if settings.bankBags[i] then
                local bagID = i + 4  -- Convert 1-7 to 5-11
                local slot_in_bag = C_Container.GetContainerNumSlots(bagID)
                for j = 1, slot_in_bag do
                    local itemInfo = C_Container.GetContainerItemInfo(bagID, j)
                    if itemInfo then
                        local itemID = itemInfo.itemID
                        if canExportItem(itemID) then
                            tinsert(list, string.format('{"item_id":"%s"}', itemID))
                        end
                    end
                end
            end
        end
    end
 
    local jsonData = "[\n" .. table.concat(list, ",\n") .. "\n]"
    editBox:SetText(encode(jsonData))
    frame:Show()
    editBox:HighlightText()
    editBox:SetFocus(true)
end
