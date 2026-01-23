# FiveM Watermark Script

A lightweight, configurable watermark script for FiveM that displays an image in the top-right corner of the screen with customizable opacity, size, and position.

## Features

- 🖼️ Displays an image watermark on the top-right corner
- ⚙️ Fully configurable via `config.lua`
- 🎨 Adjustable opacity (0-100%)
- 📏 Customizable watermark size
- 🎯 Adjustable position offsets
- ✅ Lua 5.4 compatible
- 🧭 In-game HUD to toggle/refresh and adjust opacity (`/watermark`)

## Installation

1. Download or clone this resource
2. Place it in your FiveM resources folder
3. Add `ensure watermark` to your `server.cfg`
4. Place your watermark image in the `images/` folder
5. Configure the settings in `config.lua`

## Configuration

Edit `config.lua` to customize the watermark:

```lua
Config = {
    -- Enable/Disable the watermark
    Enabled = true,

    -- Image file path (should be in the 'images' folder)
    Image = 'images/watermark.png',

    -- Watermark opacity (0.0 to 1.0)
    -- 0.0 = fully transparent, 1.0 = fully opaque
    Opacity = 0.8,

    -- Watermark size
    Width = 150,   -- Width in pixels
    Height = 150,  -- Height in pixels

    -- Position offsets from top-right corner (in pixels)
    OffsetX = 20,  -- Distance from right edge
    OffsetY = 20,  -- Distance from top edge

    -- Discord role-based permission for /watermark HUD
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
Open the HUD to toggle, refresh, and adjust opacity:

```
/watermark
```

Access can be restricted to specific Discord roles.

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
