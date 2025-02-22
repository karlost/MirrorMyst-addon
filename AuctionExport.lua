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

local frame = CreateFrame("Frame", "AuctionExportFrame", UIParent, "BackdropTemplate")
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
title:SetText("Active Auctions Export")

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

-- Add to UISpecialFrames for Escape key closing
tinsert(UISpecialFrames, "AuctionExportFrame")

-- Create scroll frame and edit box
frame.scrollFrame = CreateFrame("ScrollFrame", "AuctionExportScrollFrame", frame, "InputScrollFrameTemplate")
frame.scrollFrame:SetPoint("TOPLEFT", 8, -30)
frame.scrollFrame:SetPoint("BOTTOMRIGHT", -12, 10)

local editBox = frame.scrollFrame.EditBox
editBox:SetFontObject("ChatFontNormal")
editBox:SetAllPoints(true)
editBox:SetWidth(frame.scrollFrame:GetWidth())
editBox:SetScript("OnEscapePressed", editBox.ClearFocus)

-- Kontrola dostupnosti TSM
local function IsTSMAvailable()
    return _G.TSM_API ~= nil
end

-- Získání TSM ceny pro předmět
local function GetTSMPrice(itemID)
    if not IsTSMAvailable() then 
        local MirrorMyst = LibStub("AceAddon-3.0"):GetAddon("MirrorMystExporter")
        if MirrorMyst.db.profile.debugMode then
            print("|cffff0000Debug:|r TSM API is not available")
        end
        return nil 
    end
    
    local MirrorMyst = LibStub("AceAddon-3.0"):GetAddon("MirrorMystExporter")
    if not MirrorMyst.db.profile.tsmPrices.enabled then 
        if MirrorMyst.db.profile.debugMode then
            print("|cffff0000Debug:|r TSM prices are disabled in settings")
        end
        return nil 
    end

    -- Získání item linku pro konverzi na TSM itemString
    local itemLink = select(2, GetItemInfo(itemID))
    if not itemLink then
        if MirrorMyst.db.profile.debugMode then
            print(string.format("|cffff0000Debug:|r Cannot get item link for ID %d", itemID))
        end
        return nil
    end

    -- Konverze na TSM itemString
    local itemString = TSM_API.ToItemString(itemLink)
    if not itemString then
        if MirrorMyst.db.profile.debugMode then
            print(string.format("|cffff0000Debug:|r Cannot convert item link to TSM itemString for ID %d", itemID))
        end
        return nil
    end
    
    local priceSource = MirrorMyst.db.profile.tsmPrices.source
    local price, errorMsg = TSM_API.GetCustomPriceValue(priceSource, itemString)
    
    if price then
        if MirrorMyst.db.profile.debugMode then
            print(string.format("|cffff0000Debug:|r Got TSM price for item %d: %d (%s)", itemID, price, priceSource))
        end
    else
        if MirrorMyst.db.profile.debugMode then
            print(string.format("|cffff0000Debug:|r TSM price is not available for item %d (%s): %s", itemID, priceSource, errorMsg or "unknown error"))
        end
    end
    
    return price
end

-- Function to export auctions
local function ExportAuctions()
    if not C_AuctionHouse then
        print("|cffff0000Error:|r Auction House API not available")
        return
    end

    -- Create a list to store auction data
    local list = {}

    -- Wait for the OWNED_AUCTIONS_UPDATED event
    local function OnEvent(self, event)
        if event == "OWNED_AUCTIONS_UPDATED" then
            local MirrorMyst = LibStub("AceAddon-3.0"):GetAddon("MirrorMystExporter")
            if MirrorMyst.db.profile.debugMode then
                print("|cffff0000Debug:|r Received OWNED_AUCTIONS_UPDATED event")
            end
            local ownedAuctions = C_AuctionHouse.GetOwnedAuctions()
            
            if not ownedAuctions then
                if MirrorMyst.db.profile.debugMode then
                    print("|cffff0000Debug:|r GetOwnedAuctions returned nil")
                end
                return
            end
            
            if MirrorMyst.db.profile.debugMode then
                print(string.format("|cffff0000Debug:|r Found %d auctions", #ownedAuctions))
            end
            
            for _, auction in ipairs(ownedAuctions) do
                local status = auction.status -- 0 = active, 2 = sold
                if MirrorMyst.db.profile.debugMode then
                    print(string.format("|cffff0000Debug:|r Auction status: %d (0=active, 2=sold)", status))
                end
                
                if status == 0 then
                    local itemID = auction.itemKey.itemID
                    if MirrorMyst.db.profile.debugMode then
                        print(string.format("|cffff0000Debug:|r Processing item ID: %d", itemID))
                    end
                    
                    if canExportItem(itemID) then
                        if MirrorMyst.db.profile.debugMode then
                            print(string.format("|cffff0000Debug:|r Item %d passed canExportItem check", itemID))
                        end
                        local tsmPrice = GetTSMPrice(itemID)
                        if tsmPrice then
                            local jsonEntry = string.format('{"item_id":"%d","item_price":"%d"}', itemID, tsmPrice)
                            if MirrorMyst.db.profile.debugMode then
                                print(string.format("|cffff0000Debug:|r Export JSON: %s", jsonEntry))
                            end
                            tinsert(list, jsonEntry)
                        else
                            local jsonEntry = string.format('{"item_id":"%d"}', itemID)
                            if MirrorMyst.db.profile.debugMode then
                                print(string.format("|cffff0000Debug:|r Export JSON: %s", jsonEntry))
                            end
                            tinsert(list, jsonEntry)
                        end
                    else
                        if MirrorMyst.db.profile.debugMode then
                            print(string.format("|cffff0000Debug:|r Item %d failed canExportItem check", itemID))
                        end
                    end
                end
            end
            
            if MirrorMyst.db.profile.debugMode then
                print(string.format("|cffff0000Debug:|r Exporting %d items", #list))
            end
            
            -- Join all entries into a JSON array and encode
            local jsonData = "[\n" .. table.concat(list, ",\n") .. "\n]"
            local encodedData = encode(jsonData)
            
            -- Display the results
            editBox:SetText(encodedData)
            frame:Show()
            editBox:HighlightText()
            editBox:SetFocus(true)
            
            -- Unregister the event after processing
            frame:UnregisterEvent("OWNED_AUCTIONS_UPDATED")
            frame:SetScript("OnEvent", nil)
        end
    end

    -- Set up event handling
    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("OWNED_AUCTIONS_UPDATED")
    
    -- Query owned auctions with default sort (by time remaining)
    local MirrorMyst = LibStub("AceAddon-3.0"):GetAddon("MirrorMystExporter")
    if MirrorMyst.db.profile.debugMode then
        print("|cffff0000Debug:|r Querying owned auctions...")
    end
    local sorts = {
        {sortOrder = 0, reverseSort = false}
    }
    C_AuctionHouse.QueryOwnedAuctions(sorts)

    -- Add timeout for event
    C_Timer.After(5, function()
        if frame:IsEventRegistered("OWNED_AUCTIONS_UPDATED") then
            if MirrorMyst.db.profile.debugMode then
                print("|cffff0000Debug:|r Timeout waiting for OWNED_AUCTIONS_UPDATED event")
            end
            frame:UnregisterEvent("OWNED_AUCTIONS_UPDATED")
            frame:SetScript("OnEvent", nil)
        end
    end)
end

-- Register slash command
SLASH_AUCTIONEXPORT1 = "/mmaexport"
SlashCmdList["AUCTIONEXPORT"] = function(msg)
    if AuctionHouseFrame and AuctionHouseFrame:IsVisible() then
        ExportAuctions()
    else
        print("|cffff0000Error:|r Please open the Auction House first to export your auctions.")
    end
end

-- Add login message
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cffff0000TMog-MarketPlace:|r Type |cffffff00/mmaexport|r to export your active auctions.")
    if IsTSMAvailable() then
        print("|cffff0000TMog-MarketPlace:|r TSM integration is available. You can enable TSM prices in the addon settings (/mm).")
    end
end)
