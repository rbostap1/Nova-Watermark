# Watermark HUD Guide

This resource now runs as a server-owned watermark controller. The server stores and validates visibility, opacity, position, and size; the client only renders the HUD and watermark image.

## Workflow

- Run `/watermark` to open the HUD.
- Use Visibility to show or hide the watermark for everyone.
- Use Appearance to change opacity.
- Use Layout to update X/Y offsets and width/height together.
- Use Maintenance to sync the latest state or restore the configured defaults.

## Notes

- Discord role gating is optional and still uses `Badger_Discord_API` if configured.
- Runtime changes are stored in the resource KVP store so the config file is not rewritten.
- If the resource folder name changes, the NUI asset path updates automatically through the resource name.