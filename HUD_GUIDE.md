# Watermark HUD - Quick Reference Guide

## Installation & Usage

### Command
```
/watermark
```

Opens the Watermark Control Center (requires permission if configured).

## HUD Overview

### Header
- **Title**: "Watermark Control Center"
- **Subtitle**: "Server-wide Configuration"
- **Close Button** (✕): Closes the HUD without saving

### Tab System

#### 1. **Visibility Tab** (Default)
**Controls:**
- 🎨 **Status Badge**: Shows current state (Visible/Hidden)
- 👁️ **Hide Watermark**: Toggles server-wide visibility
- 🔍 **Hide Locally**: Client-only hiding (doesn't affect server)
- 📊 **Opacity Slider**: 0-100% transparency control
  - Visual feedback with percentage display
  - Adjusts watermark transparency in real-time

**What happens:**
- Changes are shown in chat as "pending save"
- Only take effect server-wide when saved

#### 2. **Position Tab**
**Controls:**
- 📍 **X Position**: Horizontal offset (0-10000px)
- 📍 **Y Position**: Vertical offset (0-10000px)
- ✓ **Apply Position**: Saves position changes
- **Position Readout**: Shows current coordinates

**Visual Positioning:**
- Drag the watermark directly on screen while HUD is open
- Input fields update in real-time
- Position changes sync with preview

#### 3. **Advanced Tab**
**Configuration Management:**
- 💾 **Save to Config**: Persists all changes to config.lua file
  - Creates server log entry
  - Broadcasts to all players
  - Changes survive server restart
- 🔄 **Reset to Defaults**: Reverts to config file defaults
  - Resets and saves automatically
  - Creates log entry

**Utility Functions:**
- 🔄 **Refresh Display**: Redraws watermark without changes
- 🔗 **Sync from Server**: Re-synchronizes with server state

## Workflow

### Making Changes
1. Open HUD with `/watermark`
2. Go to desired tab (Visibility/Position/Advanced)
3. Make adjustments
   - Use sliders for smooth changes
   - Use inputs for precise values
   - Drag watermark for visual positioning
4. See "pending" messages in chat
5. Click **"Save to Config"** to finalize
6. Confirmation appears in chat
7. Close HUD with ✕ or Cancel button

### Typical Tasks

#### Hide Watermark
1. `/watermark`
2. Click **"Hide Watermark"** button
3. Click **"Save to Config"**
4. ✓ Watermark hidden server-wide

#### Adjust Opacity
1. `/watermark` → Visibility Tab
2. Drag opacity slider to desired level
3. Watch watermark fade/brighten
4. Click **"Save to Config"** when satisfied
5. ✓ Opacity saved

#### Reposition Watermark
1. `/watermark` → Position Tab
2. Either:
   - **Drag directly**: Move watermark on screen
   - **Use inputs**: Enter X/Y values
   - **Apply Position** button
3. Watch position update in real-time
4. Click **"Save to Config"** when done
5. ✓ Position saved and persisted

#### Reset Everything
1. `/watermark` → Advanced Tab
2. Click **"Reset to Defaults"**
3. ✓ Back to original config values

## Chat Messages

### Green Messages ✓
- Settings saved successfully
- Operations completed

### White/Yellow Messages ⚠️
- Operation in progress
- Pending save notification

### Red Messages ✗
- Permission denied
- Invalid input
- Operation failed

## Behind the Scenes

### What Gets Saved to Config
- ✓ Enabled/Disabled state
- ✓ Opacity percentage
- ✓ X and Y position offsets
- ✓ Image path (if changed)
- ✓ Width and Height dimensions

### What's NOT Saved Until You Click Save
- Slider adjustments
- Position previews
- Visibility toggles

### Server Logging
Only logged when saved:
```
[Watermark-Server] Configuration saved by player X
  - Enabled: true/false
  - Opacity: 0.XX
  - Position: X:### Y:###
```

## Permissions

### Discord Role Restriction (Optional)
If configured in config.lua:
```lua
DiscordRoleIds = {
    '123456789012345678',  -- Only these roles can use /watermark
}
```

### Console Access
Console (src=0) always has full access regardless of config.

## Troubleshooting

### Watermark Not Showing
- Check if Enabled state is true
- Click "Refresh Display"
- Check if locally hidden with "Hide (Client Only)"
- Verify image path in config

### Changes Not Persisting
- Make sure to click **"Save to Config"** button
- Without saving, changes are temporary
- Verify you have proper permissions

### Can't Open HUD
- Check you have proper Discord role (if configured)
- Try running from console: `/watermark` in chat
- Check console for error messages

### Position/Opacity Not Updating
- Click **"Apply Position"** after changing X/Y values
- Slider changes apply in real-time
- Click **"Save to Config"** to persist

## Advanced

### Config File Location
`config.lua` in the resource root directory

### Backup Before Major Changes
Before using Reset or bulk changes, backup your config.lua

### Manual Config Editing
Can edit `config.lua` directly but changes require resource restart to apply:
```lua
Config = {
    Enabled = true,        -- true/false
    Opacity = 0.8,         -- 0.0 to 1.0
    OffsetX = 20,          -- pixels from right
    OffsetY = 20,          -- pixels from top
    Image = 'path/image',  -- relative to resource
    Width = 150,           -- pixels
    Height = 150,          -- pixels
    DiscordRoleIds = {}    -- role IDs for access
}
```

## File Structure
```
Watermark/
├── config.lua           # Configuration (auto-updated)
├── server.lua           # Server logic & config persistence
├── client.lua           # Client display & HUD logic
├── fxmanifest.lua       # FiveM manifest
└── html/
    ├── index.html       # HUD interface
    ├── style.css        # Styling (modern dark theme)
    └── script.js        # HUD interactions
```

---

**Version**: 2.0 (Complete Redesign)
**Last Updated**: January 2026
