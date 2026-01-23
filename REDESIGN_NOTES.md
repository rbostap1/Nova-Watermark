# Watermark HUD Redesign - Complete Overhaul

## Overview
The entire Watermark HUD system has been completely redesigned with a modern interface, improved logging, and config file persistence.

## Key Changes

### 1. **Modern HUD Interface** (HTML/CSS/JS)

#### HTML (`html/index.html`)
- **Complete redesign** with a professional control center aesthetic
- New header section with icon and subtitle
- **Tab-based navigation** system:
  - **Visibility Tab**: Toggle watermark, adjust opacity
  - **Position Tab**: Manual position controls with drag-and-drop preview
  - **Advanced Tab**: Save to config, reset to defaults, utility functions
- Status badges showing current watermark state
- Better organized layout with semantic grouping
- Improved footer with prominent close button

#### CSS (`html/style.css`)
- **Modern dark theme** with blue accent colors
- Glassmorphism effects with backdrop blur
- Smooth animations and transitions
- Custom styled sliders, buttons, and inputs
- Color-coded buttons:
  - **Primary (Blue)**: Main actions
  - **Success (Green)**: Save operations
  - **Warning (Orange)**: Reset operations
  - **Secondary (Gray)**: Utility functions
- Responsive design for different screen sizes
- Enhanced scrollbar styling
- Professional shadow and border effects

#### JavaScript (`html/script.js`)
- **Completely refactored** event handling system
- Better state management with clear separation of concerns
- Improved drag-and-drop functionality for both HUD and watermark
- Tab system for organized interface navigation
- Better error handling and console logging
- Cleaner NUI communication
- Status display updates

### 2. **Server-Side Logging & Config Persistence** (`server.lua`)

#### New Features
- **Config File Persistence**: Changes are now saved to `config.lua` and persist across server restarts
- **Improved Logging System**: 
  - Color-coded log levels (info, success, warning, error)
  - Detailed operation logging with player IDs
  - Clear audit trail of all changes

#### Logging Behavior
- **Server-wide changes are ONLY logged when explicitly saved** with the "Save to Config" button
- Changes made through the HUD are previewed but not logged until saved
- This prevents console spam from every slider adjustment
- All saved changes log:
  - Player who made the change
  - Exact values applied
  - Previous and new state
  - Operation success/failure status

#### Key Events
1. `watermark:setOpacity` - Sets opacity (pending save)
2. `watermark:setPosition` - Updates position (pending save)
3. `watermark:setEnabled` - Toggles visibility (pending save)
4. `watermark:saveState` - **SAVES TO CONFIG** + broadcasts to all clients + logs
5. `watermark:resetState` - Resets to defaults + saves + logs
6. `watermark:checkDiscordAccess` - Permission validation
7. `watermark:requestState` - State sync for new players

#### Config Persistence Implementation
```lua
saveStateToConfig() -- Reads config.lua, updates values, saves back
```
Automatically updates these config values:
- `Enabled` - Server-wide visibility state
- `Opacity` - Watermark transparency
- `OffsetX` / `OffsetY` - Watermark position
- `Image` - Image file path
- `Width` / `Height` - Dimensions

### 3. **Client-Side Updates** (`client.lua`)

#### Improvements
- Better logging with consistent format
- Clearer state management
- Improved error handling
- All operations log client-side events
- Better chat notifications

#### Logging System
- Uses same color-coded system as server
- Logs HUD opening/closing
- Logs all setting changes (even if not saved)
- Logs permission results
- Logs sync operations

### 4. **User Experience Flow**

```
Player opens /watermark command
    ↓
Server checks Discord role permissions
    ↓
HUD opens with Visibility Tab active
    ↓
Player adjusts settings (opacity, position, visibility)
    ↓
Chat shows "pending save" messages
    ↓
Player clicks "Save to Config"
    ↓
Server:
  - Saves to config.lua
  - Broadcasts to all players
  - Logs complete audit trail
    ↓
Player receives confirmation in chat
```

## Benefits

### For Administrators
- **Persistent Configuration**: Changes survive server restarts
- **Audit Trail**: Complete logging of who changed what and when
- **Cleaner Console**: Only significant saves are logged, not every slider move
- **Easy Reset**: One-click reset to configured defaults
- **Modern Interface**: Intuitive tab-based design

### For Players
- **Professional UI**: Clean, modern control center
- **Clear Feedback**: Chat messages indicate pending changes
- **Drag and Drop**: Visual watermark positioning
- **Responsive Design**: Works on different screen sizes
- **Organized Controls**: Tab system groups related settings

## Technical Architecture

### State Management
```
Config File (persistent)
    ↓
Server State (in-memory, synced from config)
    ↓
Client State (synced from server)
    ↓
NUI State (displayed in HUD)
```

### Event Flow
```
Player Input (HUD)
    ↓
NUI Callback
    ↓
Client Event (TriggerServerEvent)
    ↓
Server Event Handler
    ↓
State Update (in-memory)
    ↓
Optional: Save to Config
    ↓
Broadcast to all clients (sendState)
    ↓
Client Update Display
```

## Configuration
No changes needed to `config.lua` - it works with existing structure:
```lua
Config = {
    Enabled = true,
    Opacity = 0.8,
    OffsetX = 20,
    OffsetY = 20,
    Image = 'images/placeholder.jpg',
    Width = 150,
    Height = 150,
    DiscordRoleIds = { -- optional for permissions
        -- '123456789012345678',
    },
}
```

## Commands
- `/watermark` - Opens the control center (permission checked)

## Chat Messages
- Green messages: Successful operations
- Red messages: Errors or permission denials
- White messages: Pending operations

## Future Enhancements Possible
- Image file browser in HUD
- Size adjustment sliders
- Multiple watermark profiles
- Scheduled enable/disable times
- Per-player visibility settings
- Server info display in HUD
