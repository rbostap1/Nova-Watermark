# Watermark (FiveM Resource)

Configurable image watermark with an in-game HUD. Server admins can toggle visibility, adjust opacity, and reposition the watermark for all players. Optional Discord role gating for `/watermark` access via Badger_Discord_API.

**Version:** 1.0.0 (see fxmanifest.lua)

## Features

- Image watermark in top-right corner
- HUD Control Center (`/watermark`) with tabs: Visibility, Position, Advanced
- Server-wide visibility toggle and local-only hide
- Opacity control (0.0–1.0) with live preview
- Position control via drag or X/Y input
- Configurable size (`Width`, `Height`) and image path
- Optional Discord role-based access to HUD

## Requirements

- FiveM server
- Optional: Badger_Discord_API (for Discord role checks)

## Installation

1. Copy the `Watermark` folder into your server `resources`.
2. Add to `server.cfg`:

```
ensure Watermark
```

3. Place your watermark image under `images/` and set `Config.Image` in `config.lua`.
4. (Optional) Add allowed Discord role IDs in `config.lua` and ensure `Badger_Discord_API` is running.

## Usage

- Run `/watermark` to open the HUD.
- Visibility tab: toggle server-wide visibility, toggle local-only hide, adjust opacity.
- Position tab: drag the watermark or apply exact X/Y values.
- Advanced tab: reset to defaults, refresh display, sync from server.

## Configuration

Edit `config.lua`:

```lua
Config = {
    Enabled = true,
    Image = 'images/placeholder.jpg',
    Opacity = 0.5,
    Width = 150,
    Height = 150,
    OffsetX = 28,
    OffsetY = 20,
    DiscordRoleIds = {
        -- '123456789012345678',
    },
}
```

Notes:
- Leave `DiscordRoleIds` empty to allow all players to open the HUD.
- NUI uses the resource name (`nui://Watermark/...`). If you rename the folder, update references accordingly.

## Branches

- Production: stable releases and recommended for deployment.
- Development: latest changes under active development.

## File Structure

```
Watermark/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
├── README.md
├── instructions.md
├── BEFORE_AFTER.md
├── html/
│   ├── index.html
│   ├── script.js
│   └── style.css
└── images/
```

## Troubleshooting

- HUD doesn’t open: ensure `Badger_Discord_API` is installed and `DiscordRoleIds` are set correctly (if gating access). Check server console logs.
- Image not showing: verify `Config.Image` points to an existing file under `images/`.
- Position/opacity not updating: open HUD and try Refresh or Sync; confirm the resource is ensured in `server.cfg`.

## License

See LICENSE for terms.

## Credits

Author: Ryan Bostaph
