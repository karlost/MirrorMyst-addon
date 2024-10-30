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

-- Function to export auctions
local function ExportAuctions()
    if not C_AuctionHouse then
        print("|cffff0000Error:|r Auction House API not available")
        return
    end

    -- Query owned auctions with default sort (by time remaining)
    local sorts = {
        {sortOrder = 0, reverseSort = false}
    }
    C_AuctionHouse.QueryOwnedAuctions(sorts)

    -- Create a list to store auction data
    local list = {}

    -- Wait for the OWNED_AUCTIONS_UPDATED event
    local function OnEvent(self, event)
        if event == "OWNED_AUCTIONS_UPDATED" then
            local ownedAuctions = C_AuctionHouse.GetOwnedAuctions()
            
            for _, auction in ipairs(ownedAuctions) do
                local status = auction.status -- 1 = active, 2 = sold
                if status ~= 1 then
                    local itemID = auction.itemKey.itemID
                    local quantity = auction.quantity
                    local buyoutAmount = auction.buyoutAmount
                    local timeLeft = auction.timeLeftSeconds
                    
                    -- Format the data as JSON
                    tinsert(list, string.format('{"item_id":"%d","quantity":"%d","buyout":"%d","time_left":"%d","status":"%d"}',
                        itemID, quantity, buyoutAmount, timeLeft, status))
                end
            end
            
            -- Join all entries with newlines
            local exportText = table.concat(list, ";\n")
            
            -- Display the results
            editBox:SetText(exportText)
            frame:Show()
            editBox:HighlightText()
            editBox:SetFocus(true)
            
            -- Unregister the event after processing
            frame:UnregisterEvent("OWNED_AUCTIONS_UPDATED")
        end
    end

    -- Register for the auction update event
    frame:RegisterEvent("OWNED_AUCTIONS_UPDATED")
    frame:SetScript("OnEvent", OnEvent)
end

-- Register slash command
SLASH_AUCTIONEXPORT1 = "/auctionexport"
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
    print("|cffff0000TMog-MarketPlace:|r Type |cffffff00/auctionexport|r to export your active auctions.")
end)
