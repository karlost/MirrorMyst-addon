-- Base64 encoding/decoding functions
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

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

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript(
   "OnEvent",
   function(self, event, ...)
      print("|cffff0000 TMog-MarketPlace: |r Type |cffffff00 /tmogmpexport |r to export to Transmog master.")
   end
)

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
    BagConfig.bag1CheckBox.text:SetText(C_Container.GetBagName(0) or "Backpack")
    BagConfig.bag1CheckBox:Show()
    BagConfig.bag1CheckBox:SetChecked(true)

    BagConfig.bag2CheckBox.text:SetText(C_Container.GetBagName(1) or "Bag 1")
    BagConfig.bag2CheckBox:Show()
    BagConfig.bag2CheckBox:SetChecked(true)

    BagConfig.bag3CheckBox.text:SetText(C_Container.GetBagName(2) or "Bag 2")
    BagConfig.bag3CheckBox:Show()
    BagConfig.bag3CheckBox:SetChecked(true)

    BagConfig.bag4CheckBox.text:SetText(C_Container.GetBagName(3) or "Bag 3")
    BagConfig.bag4CheckBox:Show()
    BagConfig.bag4CheckBox:SetChecked(true)

    BagConfig.bag5CheckBox.text:SetText(C_Container.GetBagName(4) or "Bag 4")
    BagConfig.bag5CheckBox:Show()
    BagConfig.bag5CheckBox:SetChecked(true)
 
    BagConfig:Show()
end

---------------Create Tab Config Frame-------------------------
--Tab Selection Frame
BagConfig = CreateFrame("Frame", "Bag Selection", UIParent, "BackdropTemplate")
BagConfig:SetSize(250, 500)
BagConfig:SetPoint("Center", UIParent, "Center")

-- Make frame movable
BagConfig:SetMovable(true)
BagConfig:EnableMouse(true)
BagConfig:RegisterForDrag("LeftButton")
BagConfig:SetScript("OnDragStart", BagConfig.StartMoving)
BagConfig:SetScript("OnDragStop", BagConfig.StopMovingOrSizing)

-- Add backdrop
BagConfig:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
BagConfig:SetBackdropColor(0, 0, 0, 0.8)

--Title
BagConfig.title = BagConfig:CreateFontString(nil, "OVERLAY")
BagConfig.title:SetFontObject("GameFontHighlight")
BagConfig.title:SetPoint("TOP", BagConfig, "TOP", 0, -10)
BagConfig.title:SetText("Bag Selection")

-- Add close button
local closeButton = CreateFrame("Button", nil, BagConfig, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", BagConfig, "TOPRIGHT", 2, 2)
closeButton:SetScript("OnClick", function() BagConfig:Hide() end)

-- Bag 1 Checkbox
BagConfig.bag1CheckBox = CreateFrame("CheckButton", nil, BagConfig, "UICheckButtonTemplate")
BagConfig.bag1CheckBox:SetPoint("TOPLEFT", BagConfig, "TOPLEFT", 0, -30)
BagConfig.bag1CheckBox.text:SetText("Bag 1")
BagConfig.bag1CheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bag1CheckBox:SetSize(40, 40)
BagConfig.bag1CheckBox:SetChecked(false)

-- Bag 2 Checkbox
BagConfig.bag2CheckBox = CreateFrame("CheckButton", nil, BagConfig.bag1CheckBox, "UICheckButtonTemplate")
BagConfig.bag2CheckBox:SetPoint("TOPLEFT", BagConfig.bag1CheckBox, "TOPLEFT", 0, -30)
BagConfig.bag2CheckBox.text:SetText("Bag 2")
BagConfig.bag2CheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bag2CheckBox:SetSize(40, 40)
BagConfig.bag2CheckBox:SetChecked(false)

-- Bag 3 Checkbox
BagConfig.bag3CheckBox = CreateFrame("CheckButton", nil, BagConfig.bag2CheckBox, "UICheckButtonTemplate")
BagConfig.bag3CheckBox:SetPoint("TOPLEFT", BagConfig.bag2CheckBox, "TOPLEFT", 0, -30)
BagConfig.bag3CheckBox.text:SetText("Bag 3")
BagConfig.bag3CheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bag3CheckBox:SetSize(40, 40)
BagConfig.bag3CheckBox:SetChecked(false)

-- Bag 4 Checkbox
BagConfig.bag4CheckBox = CreateFrame("CheckButton", nil, BagConfig.bag3CheckBox, "UICheckButtonTemplate")
BagConfig.bag4CheckBox:SetPoint("TOPLEFT", BagConfig.bag3CheckBox, "TOPLEFT", 0, -30)
BagConfig.bag4CheckBox.text:SetText("Bag 4")
BagConfig.bag4CheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bag4CheckBox:SetSize(40, 40)
BagConfig.bag4CheckBox:SetChecked(false)

-- Bag 5 Checkbox
BagConfig.bag5CheckBox = CreateFrame("CheckButton", nil, BagConfig.bag4CheckBox, "UICheckButtonTemplate")
BagConfig.bag5CheckBox:SetPoint("TOPLEFT", BagConfig.bag4CheckBox, "TOPLEFT", 0, -30)
BagConfig.bag5CheckBox.text:SetText("Bag 5")
BagConfig.bag5CheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bag5CheckBox:SetSize(40, 40)
BagConfig.bag5CheckBox:SetChecked(false)

-- Bank Title
BagConfig.bankTitle = BagConfig:CreateFontString(nil, "OVERLAY")
BagConfig.bankTitle:SetFontObject("GameFontHighlight")
BagConfig.bankTitle:SetPoint("TOPLEFT", BagConfig.bag5CheckBox, "TOPLEFT", 0, -30)
BagConfig.bankTitle:SetText("Bank Bags")

-- Bank Main Checkbox
BagConfig.bankMainCheckBox = CreateFrame("CheckButton", nil, BagConfig.bag5CheckBox, "UICheckButtonTemplate")
BagConfig.bankMainCheckBox:SetPoint("TOPLEFT", BagConfig.bankTitle, "TOPLEFT", 0, -20)
BagConfig.bankMainCheckBox.text:SetText("Bank")
BagConfig.bankMainCheckBox.text:SetFontObject("GameFontNormalLarge")
BagConfig.bankMainCheckBox:SetSize(40, 40)
BagConfig.bankMainCheckBox:SetChecked(false)

-- Bank Bag Checkboxes (5-11)
BagConfig.bankBags = {}
local lastCheckbox = BagConfig.bankMainCheckBox

for i = 1, 7 do
    local checkbox = CreateFrame("CheckButton", nil, lastCheckbox, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", lastCheckbox, "TOPLEFT", 0, -30)
    checkbox.text:SetText("Bank Bag " .. i)
    checkbox.text:SetFontObject("GameFontNormalLarge")
    checkbox:SetSize(40, 40)
    checkbox:SetChecked(false)
    BagConfig.bankBags[i] = checkbox
    lastCheckbox = checkbox
end

local function runExport()
    BagConfig:Hide()
    local bags = {
        BagConfig.bag1CheckBox:GetChecked(),
        BagConfig.bag2CheckBox:GetChecked(),
        BagConfig.bag3CheckBox:GetChecked(),
        BagConfig.bag4CheckBox:GetChecked(),
        BagConfig.bag5CheckBox:GetChecked(),
        bankMain = BagConfig.bankMainCheckBox:GetChecked(),
        bankBags = {},
    }
    
    for i = 1, 7 do
        bags.bankBags[i] = BagConfig.bankBags[i]:GetChecked()
    end

    local list = {}
    
    -- Export from bags
    for i = 1, 5 do
        if bags[i] then
            local bagID = i - 1
            local slot_in_bag = C_Container.GetContainerNumSlots(bagID)
            for j = 1, slot_in_bag do
                local itemInfo = C_Container.GetContainerItemInfo(bagID, j)
                if itemInfo then
                    local itemID = itemInfo.itemID
                    local itemName = itemInfo.itemName or select(1, GetItemInfo(itemInfo.hyperlink))
                    local quantity = itemInfo.stackCount
                    tinsert(list, string.format('{"item_id":"%s","quantity":"%s"}', itemID, quantity))
                end
            end
        end
    end

    -- Export from bank if it's open and selected
    if BankFrame and BankFrame:IsVisible() then
        -- Main bank (BANK_CONTAINER = -1)
        if bags.bankMain then
            local bankSlots = C_Container.GetContainerNumSlots(-1)
            for j = 1, bankSlots do
                local itemInfo = C_Container.GetContainerItemInfo(-1, j)
                if itemInfo then
                    local itemID = itemInfo.itemID
                    local quantity = itemInfo.stackCount
                    tinsert(list, '{"item_id":"')
                    tinsert(list, itemID)
                    tinsert(list, '","quantity":"')
                    tinsert(list, quantity)
                    tinsert(list, '"}')
                    tinsert(list, ";\n")
                end
            end
        end

        -- Bank bags (5-11)
        for i = 1, 7 do
            if bags.bankBags[i] then
                local bagID = i + 4  -- Convert 1-7 to 5-11
                local slot_in_bag = C_Container.GetContainerNumSlots(bagID)
                for j = 1, slot_in_bag do
                    local itemInfo = C_Container.GetContainerItemInfo(bagID, j)
                    if itemInfo then
                        local itemID = itemInfo.itemID
                        local quantity = itemInfo.stackCount
                        tinsert(list, '{"item_id":"')
                        tinsert(list, itemID)
                        tinsert(list, '","quantity":"')
                        tinsert(list, quantity)
                        tinsert(list, '"}')
                        tinsert(list, ";\n")
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

BagConfig.OKButton = CreateFrame("Button", "Tmog MarketPlace Export", BagConfig, "UIPanelButtonTemplate")
BagConfig.OKButton:SetPoint("BOTTOMLEFT", BagConfig, "BOTTOMLEFT", 15, 10)
BagConfig.OKButton:SetSize(140, 40)
BagConfig.OKButton:SetText("Export")
BagConfig.OKButton:SetScript(
   "OnClick",
   function()
      runExport()
   end
)

BagConfig:Hide()
