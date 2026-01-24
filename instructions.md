# Watermark: HUD & Permissions Guide

How to use the in-game Watermark HUD and optionally gate access behind Discord roles.

## Overview

- Command: `/watermark`
- HUD Features:
  - Server-wide hide/show
  - Local-only hide/show
  - Opacity control (live preview)
  - Position control (drag or X/Y input)
  - Refresh and Sync
  - Reset to defaults
- Access Control: Optionally restrict HUD to specific Discord roles
- Sync: Changes broadcast to clients; key settings persist via config updates

## Prerequisites

- FiveM server with this resource ensured
- Place your image under `images/` and set `Config.Image` in `config.lua`
- Add to `server.cfg`:

```
ensure Watermark
```

## Configure Discord Roles (Optional)

Add allowed role IDs in `config.lua`:

```lua
DiscordRoleIds = {
    -- '123456789012345678',
}
```

Getting a role ID:
- Enable Developer Mode in Discord (User Settings → Advanced)
- In Server Settings → Roles, right‑click the role → Copy ID

## Badger_Discord_API Setup

Install and start Badger_Discord_API to enable Discord role checks:

```
ensure Badger_Discord_API
ensure Watermark
```

The server checks roles via `exports['Badger_Discord_API']:GetDiscordRoles(source)` and compares them to `DiscordRoleIds`.

## Usage

- Type `/watermark` to open the HUD.
- Tabs:
  - Visibility: toggle server visibility, local hide, adjust opacity.
  - Position: drag watermark or apply X/Y values.
  - Advanced: reset defaults, refresh display, sync from server.
- Close the HUD with the ✕ button or Cancel.

## Troubleshooting

- HUD doesn’t open:
  - Ensure `Badger_Discord_API` is installed and started (if using role gating).
  - Verify `DiscordRoleIds` and your role membership.
  - Check server console logs for permission messages.
- Image not showing:
  - Confirm `Config.Image` points to a file under `images/`.
  - Check client F8 console for errors.
- Settings not applying:
  - Use Refresh or Sync in Advanced tab.
  - Ensure the resource is ensured and running.

## Notes

- NUI uses the resource name (`nui://Watermark/...`). If renaming the folder, update references.
- HUD access gating affects who can open `/watermark`; the initial display still follows `Config.Enabled`.
