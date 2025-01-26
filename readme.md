# MirrorMyst Exporter

A World of Warcraft addon that enables exporting inventory items for the MirrorMyst Marketplace.

## Features

- Export inventory items data from bags and bank
- Export active auctions from Auction House
- TradeSkillMaster (TSM) price integration
- Debug mode for troubleshooting
- User-friendly interface
- Customizable export options

## Installation

1. Download the latest version of MirrorMyst Exporter
2. Extract the folder into your World of Warcraft `Interface/AddOns` directory
3. Restart World of Warcraft if it's running
4. Enable the addon in the character selection screen

## Usage

### Commands
- `/mm` - Open settings interface
- `/mmbexport` - Export items from bags and bank
- `/mmaexport` - Export active auctions (requires open Auction House)

### Settings
Settings can be accessed through the `/mm` command or the game's Interface/AddOns menu:

1. Storage
   - Inventory - Configure which bags to include in export
   - Bank Slots - Configure bank and bank bag export options
2. TSM Integration
   - Enable/disable TSM price export
   - Select TSM price source (Market Value, Minimum Buyout, etc.)
3. Debug Mode
   - Enable/disable debug messages in chat

## Dependencies

This addon requires the following libraries (included in the package):
- Ace3 Framework
  - AceAddon-3.0
  - AceConsole-3.0
  - AceConfig-3.0
  - AceDB-3.0
  - AceGUI-3.0

Optional:
- TradeSkillMaster (TSM) - Required for price export functionality

## Author

Created by iChodec

## Version

Current version: 1.1
