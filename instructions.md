# Watermark HUD & Discord Permissions Guide

This guide explains how to use the in-game Watermark HUD and how to lock access behind Discord roles using Badger_Discord_API.

## Overview

- Command: `/watermark`
- HUD Controls:
- HUD Controls:
  - Hide/Show Logo: Server-wide visibility toggle
  - Hide/Show (Client Only): Affects only your view
  - Refresh Logo: Reload the watermark image and settings
  - Sync: Pull latest server state
  - Opacity: Adjust transparency live (0.0–1.0), server-wide
  - Drag watermark: Move it; new position is server-wide
  - Save: Broadcast current opacity/position/visibility to everyone
  - Reset Defaults: Restore config defaults server-wide
  - Cancel or ✕: Close HUD without saving
- Access Control: Only players with allowed Discord roles can open the HUD
- Server sync: visibility, opacity, and position changes are server-wide and apply instantly to all clients. The client-only hide toggle affects only the local player.
- Save broadcasts the current in-memory state; it does not write back to `config.lua`.
- Only HUD access is gated; watermark display on join still follows `Config.Enabled`.

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

- In-game, type `/watermark`
- If you have an allowed role, the HUD appears with:
  - Toggle Logo
  - Refresh Logo
  - Opacity slider (0–100, mapped to 0.0–1.0)
- Closing the HUD uses the ✕ button; controls instantly update the on-screen watermark.

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
