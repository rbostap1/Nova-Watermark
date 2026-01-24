# Watermark HUD & Discord Permissions Guide

This guide explains how to use the in-game Watermark HUD and how to lock access behind Discord roles using Badger_Discord_API.

## Overview

- Command: `/watermark`
- **HUD Features**:
  - Hide/Show watermark server-wide
  - Hide/Show locally (client-only)
  - Adjust opacity (0-100%, auto-saves)
  - Reposition watermark via drag or manual input (auto-saves)
  - Refresh display
  - Sync with server
  - Reset to hardcoded defaults
- Access Control: Only players with allowed Discord roles can open the HUD
- **Server sync**: Opacity and position changes auto-save and sync instantly with all clients
- **Client-only hide**: Affects only the local player's view
- **Reset Defaults**: Restores hardcoded values (OffsetX=28, OffsetY=20, opacity=0.5)

## Prerequisites

- FiveM server running this resource
- Add your watermark image under `images/` and configure `Image` path in `config.lua`
- Ensure the resource is started in `server.cfg`:

```
ensure Watermark
```

## Configure Allowed Roles

Set your allowed role IDs in `config.lua`:

```lua
Config = {
    -- ... other settings ...
    DiscordRoleIds = {
        -- Replace with your Discord role IDs
        -- Example: '123456789012345678',
        --          '987654321098765432',
    },
}
```

How to get a role ID:
- In Discord, enable Developer Mode (User Settings → Advanced → Developer Mode)
- Right-click the role (in Server Settings → Roles) and choose "Copy ID"

## Choose a Role Provider

You need Badger_Discord_API installed and started to check Discord roles:

### Badger_Discord_API

1. Install `Badger_Discord_API` into your `resources` folder (follow the resource's README for details).
2. Configure the bot token and guild (server) ID per the resource's documentation.
3. Start it in `server.cfg`:
   
```
ensure Badger_Discord_API
ensure Watermark
```

What the script does:
- Server queries `exports['Badger_Discord_API']:GetDiscordRoles(playerSource)` and allows HUD if any role matches `Config.DiscordRoleIds`.


## Usage

- In-game, type `/watermark` to open the HUD
- If you have an allowed role, the HUD appears with:
  - **Visibility Tab**: Toggle server visibility, local hide, opacity control
  - **Position Tab**: Manual X/Y input or drag watermark to reposition
  - **Advanced Tab**: Reset to defaults, refresh display, sync with server
- All opacity and position changes auto-save to `config.lua`
- Closing the HUD uses the ✕ button; all changes persist

## Troubleshooting

- HUD doesn’t open:
  - Check server console logs for: `Badger_Discord_API not started. Install and ensure it for Discord role checks.`
  - Ensure `Badger_Discord_API` is installed and started.
  - Verify `DiscordRoleIds` in `config.lua` contains valid role IDs.
  - Confirm your Discord role membership and that the bot has required intents/permissions.
- Image doesn’t show:
  - Verify `Config.Image` points to a file under `images/` (e.g., `images/logo.png`).
  - Check client F8 console for errors.
- Opacity changes don’t apply:
  - Ensure the HUD is open and slider value changes; the client updates live via NUI.

## Notes

- The resource name is used by NUI (e.g., `nui://Watermark/...`). If you rename the folder, update references accordingly.
- Only HUD access is gated; watermark display on join still follows `Config.Enabled`.
