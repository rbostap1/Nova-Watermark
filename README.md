# FiveM Watermark Script - Complete Redesign v2.0

A professional, feature-rich watermark script for FiveM with a modern HUD interface, config file persistence, and comprehensive logging system.

## ✨ What's New in v2.0

### 🎨 Complete HUD Redesign
- **Modern Control Center**: Professional dark theme with blue accents
- **Tab-Based Interface**: Organized controls (Visibility → Position → Advanced)
- **Real-Time Feedback**: Status badges and instant preview updates
- **Drag & Drop**: Directly position watermark on screen
- **Responsive Design**: Works on all resolutions

### 💾 Auto-Save Configuration
- **Automatic Persistence**: Opacity and position changes auto-save to `config.lua`
- **Instant Sync**: All changes broadcast server-wide instantly
- **Clean Operation**: No manual save button needed
- **Audit Trail**: Complete logging of all configuration changes

### 📋 Improved Logging
- **Smart Logging**: Only logs position changes (not opacity adjustments)
- **Audit Trail**: Shows player ID, exact values, and state
- **Clean Chat**: No spam from slider movements
- **Color-Coded Output**: Visual distinction for info/success/warning/error

## Features

✅ **Display Features**
- 🖼️ High-quality image watermark on top-right corner
- 🎨 Real-time opacity adjustment (0-100%)
- 📏 Customizable watermark size
- 🎯 Precise positioning (drag in HUD or manual X/Y input)
- 🔄 Server-wide synchronization (all players see changes instantly)
- 🙈 Client-only hide toggle (personal view only)

✅ **Configuration Features**
- ⚙️ Fully configurable via `config.lua`
- 💾 Auto-save for opacity and position changes
- 🔄 Reset to Defaults button (OffsetX=28, OffsetY=20, opacity=0.5)
- 📊 Real-time preview while adjusting
- 📝 Automatic logging of position updates

✅ **Interface Features**
- 🎮 Professional in-game HUD (`/watermark`)
- 🔐 Discord role-based permissions (optional)
- ✨ Tab-based organization (Visibility/Position/Advanced)
- 🎯 Status indicators showing current state
- 💬 Clear chat feedback for all operations
- 🖱️ Drag HUD window for repositioning

✅ **Technical Features**
- ✅ Lua 5.4 compatible
- ✅ Backwards compatible with existing configs
- ✅ Comprehensive error handling
- ✅ Production-ready code
- ✅ Minimal performance impact

## Installation

1. Download or clone this resource into your resources folder
2. Ensure it's added to `server.cfg`: `ensure watermark`
3. Place your watermark image in the `images/` folder
4. (Optional) Configure Discord permissions in `config.lua`
5. Start the resource or restart the server

## Configuration

Edit `config.lua` to customize the watermark:

```lua
Config = {
    -- Enable/Disable the watermark on server start
    Enabled = true,

    -- Image file path (relative to resource root)
    Image = 'images/placeholder.jpg',

    -- Watermark opacity (0.0 = transparent, 1.0 = opaque)
    Opacity = 0.5,

    -- Watermark dimensions
    Width = 150,   -- Pixels
    Height = 150,  -- Pixels

    -- Position offsets from top-right corner
    OffsetX = 28,  -- Pixels from right edge
    OffsetY = 20,  -- Pixels from top edge
    
    -- Discord role-based permission (optional)
    -- Leave empty {} to allow everyone
    DiscordRoleIds = {
        -- Example: '123456789012345678',
    },
}
```

## Usage

### Open Control Center
```
/watermark
```

Opens the professional HUD interface where you can:

### Visibility Tab
- **Toggle Visibility**: Show/hide watermark server-wide
- **Local Hide**: Hide just for you (doesn't affect server)
- **Opacity Control**: Adjust transparency (0-100%)

### Position Tab
- **Manual Positioning**: Enter exact X/Y coordinates
- **Drag to Position**: Click and drag watermark on screen
- **Apply Position**: Confirm changes

### Advanced Tab
- **Reset to Defaults**: Restore hardcoded defaults (OffsetX=28, OffsetY=20, opacity=0.5)
- **Sync from Server**: Re-sync state
- **Refresh Display**: Redraw without changes

## Console Commands

```
/watermark       - Open the Watermark Control Center
```

## Permissions

### Discord Role-Based Access (Optional)
Configure Discord role IDs in `config.lua` to restrict HUD access:

```lua
DiscordRoleIds = {
    '123456789012345678',  -- Only these roles can use /watermark
    '987654321098765432',  -- Add multiple roles as needed
}
```

**Note**: Console always has full access regardless of config.

### Default Behavior
If `DiscordRoleIds` is empty `{}`, all players can access the HUD.

## Logging

### Server Logs (Only on Save)
```
[Watermark-Server] Configuration saved by player 42
  - Enabled: true
  - Opacity: 0.85
  - Position: X:100 Y:50
```

### Chat Feedback
- **Green**: ✓ Configuration change successful (position/reset)
- **White/Yellow**: ⚠️ Operation pending
- **Red**: ✗ Error or permission denied

**Note**: Opacity changes do not generate chat messages (silent update)

## File Structure

```
watermark/
├── config.lua           # Configuration (auto-updated)
├── server.lua           # Server logic & config persistence
├── client.lua           # Client display & HUD logic
├── fxmanifest.lua       # FiveM manifest
├── README.md            # This file
├── CHANGELOG.md         # What's new in v2.0
├── VALIDATION.md        # Implementation verification
├── BEFORE_AFTER.md      # Feature comparison
├── HUD_GUIDE.md         # User guide
├── REDESIGN_NOTES.md    # Technical overview
└── html/
    ├── index.html       # HUD interface
    ├── style.css        # Professional styling
    └── script.js        # Interaction logic
```

## Project Statistics

- **Total Lines of Code**: 2,120
- **Server Script**: 400 lines (includes config persistence)
- **Client Script**: 270 lines (improved logging)
- **HUD Interface**: 173 lines (modern redesign)
- **Styling**: 645 lines (professional theme)
- **Interactions**: 573 lines (tab system & drag)

## Backwards Compatibility

✅ **100% Compatible with existing configs**
- No changes needed to your current `config.lua`
- All existing commands work identically
- Permission system unchanged
- Drop-in replacement for older versions

## Recent Changes (v2.0)

### New Features
- 🎨 Modern redesigned HUD with tabs
- 💾 Config file persistence on save
- 📊 Clean, audit-trail logging
- 🎯 Visual position preview
- 📈 Better error handling

### Improvements
- ✅ Professional UI/UX
- ✅ Only logs significant saves
- ✅ Settings survive server restarts
- ✅ Better code organization
- ✅ Enhanced performance

### Fixed
- ✅ No more console spam
- ✅ Clearer user feedback
- ✅ Better permission handling
- ✅ Improved error messages

## Performance

- **Memory**: +~5KB additional
- **CPU**: Negligible overhead
- **Network**: No additional traffic
- **Disk I/O**: Only on explicit save

## Support

For issues, questions, or suggestions, refer to the documentation:
- `HUD_GUIDE.md` - User-friendly usage guide
- `REDESIGN_NOTES.md` - Technical documentation
- `BEFORE_AFTER.md` - Feature comparison
- `CHANGELOG.md` - Detailed changes

## Credits

**Version 2.0 - Complete Redesign**
- Modern HUD interface design
- Config file persistence system
- Improved logging architecture
- Professional styling
- Better code organization

## License

See LICENSE file for details

---

**Ready to use! Just install and configure.**
    -- Provide one or more Discord role IDs
    DiscordRoleIds = {
        -- Example: '123456789012345678',
    },
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Enabled` | boolean | `true` | Enable or disable the watermark |
| `Image` | string | `'images/watermark.png'` | Path to the watermark image (relative to resource folder) |
| `Opacity` | float | `0.8` | Watermark opacity: 0.0 (transparent) to 1.0 (opaque) |
| `Width` | integer | `150` | Watermark width in pixels |
| `Height` | integer | `150` | Watermark height in pixels |
| `OffsetX` | integer | `20` | Distance from the right edge in pixels |
| `OffsetY` | integer | `20` | Distance from the top edge in pixels |
| `DiscordRoleIds` | array<string> | `[]` | Allowed Discord role IDs for `/watermark` HUD |
 

## Image Requirements

- **Format**: PNG or JPG
- **Location**: Place your image file in the `images/` folder
- **Naming**: Update the `Image` config path to match your filename
  - Example: If you name it `logo.png`, set `Image = 'images/logo.png'`

 

## Commands

### Watermark HUD
Open the HUD to toggle, adjust opacity, and move the watermark:

```
/watermark
```

**HUD Controls**
- **Toggle Visibility**: Show/hide watermark server-wide
- **Local Hide**: Hide just for you (doesn't affect server)
- **Opacity Slider**: Adjust transparency (0-100%, auto-saves)
- **Position Controls**: Manual X/Y input or drag to position (auto-saves)
- **Reset Defaults**: Restore hardcoded defaults
- **Refresh Display**: Redraw without changes
- **Sync from Server**: Re-sync state

### Permissions via Discord Roles
This resource uses Badger_Discord_API for Discord role checks.

Add your allowed role IDs to `DiscordRoleIds` in `config.lua` and ensure Badger_Discord_API is installed and started.

If Badger_Discord_API is not installed or started, the command will be denied and a server log will advise installing it.

For a step-by-step setup guide, see [instructions.md](instructions.md).

## File Structure

```
watermark/
├── fxmanifest.lua      # FiveM manifest file
├── config.lua          # Configuration file
├── client.lua          # Client-side script
├── server.lua          # Server-side Discord role checks
├── images/             # Folder for watermark images
│   └── watermark.png   # Your watermark image (add this)
├── README.md           # This file
└── LICENSE             # License file
```

## Troubleshooting

### Watermark not showing
- Ensure `Enabled = true` in `config.lua`
- Check that the image file exists in the `images/` folder
- Verify the `Image` path is correct in `config.lua`
- Check the F8 console for error messages
 

### Watermark position is wrong
- Adjust `OffsetX` and `OffsetY` values
- Negative values move towards the corner, positive values move away

### Image appears too small/large
- Adjust the `Width` and `Height` values in pixels

## Example Configurations

### Small Watermark (Top-Right)
```lua
Config = {
    Enabled = true,
    Image = 'images/watermark.png',
    Opacity = 0.7,
    Width = 100,
    Height = 100,
    OffsetX = 15,
    OffsetY = 15,
}
```

### Large Watermark (Low Opacity)
```lua
Config = {
    Enabled = true,
    Image = 'images/watermark.png',
    Opacity = 0.4,
    Width = 250,
    Height = 250,
    OffsetX = 30,
    OffsetY = 30,
}
```

## Performance

This script is optimized for minimal performance impact:
- Draws at native frame rate with zero loop overhead
- Texture streamed efficiently
- Minimal CPU usage

## License

See LICENSE file for details.

## Support

For issues or feature requests, please open an issue on the repository.
