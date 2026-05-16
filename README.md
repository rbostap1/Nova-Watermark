# Watermark (FiveM Resource)

Server-authoritative watermark control for FiveM. The server owns visibility, opacity, position, size, and persistence; the client only renders the watermark and relays HUD actions.

## Features

- Global watermark image in the top-right corner
- Clean admin HUD at `/watermark`
- Server-owned visibility toggle
- Live opacity control
- Server-validated position and size updates
- Persisted state stored in resource KVP, not in `config.lua`
- Optional Discord role gate via `Badger_Discord_API`

## Requirements

- FiveM server
- Optional: `Badger_Discord_API` for Discord role checks

## Installation

1. Copy the `Watermark` folder into your server `resources` directory.
2. Add the resource to `server.cfg`:

```cfg
ensure Watermark
```

3. Put your watermark image in `images/` and update `Config.Image` in `config.lua`.
4. Optionally add Discord role IDs in `config.lua` and ensure `Badger_Discord_API` is running.

## Usage

- Run `/watermark` to open the HUD.
- Use the Visibility card to show or hide the watermark for everyone.
- Use the Appearance card to adjust opacity.
- Use the Layout card to update X/Y offsets and width/height in one server-synced action.
- Use Maintenance to refresh the state or restore defaults.

## Configuration

Edit `config.lua` for the default state:

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
- Leave `DiscordRoleIds` empty to allow everyone to open the HUD.
- Runtime edits are persisted in the resource KVP store, so the source config stays untouched.

## File Structure

```text
Watermark/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
├── README.md
├── instructions.md
├── html/
│   ├── index.html
│   ├── script.js
│   └── style.css
└── images/
```

## Troubleshooting

- HUD does not open: verify Discord role gating is configured correctly, or leave `DiscordRoleIds` empty for open access.
- Image missing: confirm `Config.Image` points to a valid file under `images/`.
- Changes are not sticking: ensure the resource has write access to its KVP store and restart the resource once after updating config defaults.

## License

See `LICENSE`.

## Credits

Author: Ryan Bostaph