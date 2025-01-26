local addonName = "MirrorMyst"
local MirrorMyst = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

-- Výchozí hodnoty
local defaults = {
    profile = {
        bags = {
            [0] = true, -- Backpack
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true
        },
        tsmPrices = {
            enabled = false,
            source = "DBMarket"
        },
        bankBags = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [6] = true,
            [7] = true
        },
        bankMain = true
    }
}

function MirrorMyst:OnInitialize()
    -- Inicializace DB
    self.db = LibStub("AceDB-3.0"):New("MirrorMystDB", defaults)
    
    -- Konfigurace options
    local options = {
        type = "group",
        name = "MirrorMyst MarketPlace",
        args = {
            bags = {
                type = "multiselect",
                order = 1,
                name = "Bags",
                desc = "Select which bags to include in export",
                values = {
                    [0] = "Backpack",
                    [1] = "Bag 1",
                    [2] = "Bag 2",
                    [3] = "Bag 3",
                    [4] = "Bag 4"
                },
                get = function(info, key) return self.db.profile.bags[key] end,
                set = function(info, key, value) self.db.profile.bags[key] = value end
            },
            bank = {
                type = "group",
                order = 2,
                name = "Bank",
                args = {
                    main = {
                        type = "toggle",
                        order = 1,
                        name = "Main Bank",
                        desc = "Include main bank slots in export",
                        get = function(info) return self.db.profile.bankMain end,
                        set = function(info, value) self.db.profile.bankMain = value end
                    },
                    bags = {
                        type = "multiselect",
                        order = 2,
                        name = "Bank Bags",
                        desc = "Select which bank bags to include in export",
                        values = {
                            [1] = "Bank Bag 1",
                            [2] = "Bank Bag 2",
                            [3] = "Bank Bag 3",
                            [4] = "Bank Bag 4",
                            [5] = "Bank Bag 5",
                            [6] = "Bank Bag 6",
                            [7] = "Bank Bag 7"
                        },
                        get = function(info, key) return self.db.profile.bankBags[key] end,
                        set = function(info, key, value) self.db.profile.bankBags[key] = value end
                    }
                }
            }
        },
        tsm = {
            type = "group",
            order = 3,
            name = "TradeSkillMaster",
            args = {
                enabled = {
                    type = "toggle",
                    order = 1,
                    name = "Enable TSM Prices",
                    desc = "Include TSM prices in export",
                    get = function(info) return self.db.profile.tsmPrices.enabled end,
                    set = function(info, value) self.db.profile.tsmPrices.enabled = value end
                },
                source = {
                    type = "select",
                    order = 2,
                    name = "Price Source",
                    desc = "Select which TSM price source to use",
                    values = {
                        ["DBMarket"] = "Market Value",
                        ["DBMinBuyout"] = "Minimum Buyout",
                        ["DBRegionMarketAvg"] = "Region Market Average",
                        ["DBRegionSaleAvg"] = "Region Sale Average"
                    },
                    get = function(info) return self.db.profile.tsmPrices.source end,
                    set = function(info, value) self.db.profile.tsmPrices.source = value end,
                    disabled = function() return not self.db.profile.tsmPrices.enabled end
                }
            }
        }
    }
    
    -- Registrace options
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "MirrorMyst MarketPlace")
    
    -- Registrace slash commandu
    self:RegisterChatCommand("mm", function() 
        Settings.OpenToCategory("MirrorMyst MarketPlace")
    end)
end
