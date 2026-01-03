---------------------------------
--   Watermark Configuration   --  
---------------------------------

Config = {
    -- Enable/Disable the watermark
    Enabled = true,

    -- Image file path (should be in the 'images' folder)
    -- Example: 'images/watermark.png'
    Image = 'images/placeholder.jpg',

    -- Watermark opacity (0.0 to 1.0)
    -- 0.0 = fully transparent, 1.0 = fully opaque
    Opacity = 0.8,

    -- Watermark size
    Width = 150,   -- Width in pixels
    Height = 150,  -- Height in pixels

    -- Position offsets from top-right corner (in pixels)
    -- Positive values move left and down
    OffsetX = 20,  -- Distance from right edge
    OffsetY = 20,  -- Distance from top edge

    -- Command Permissions
    -- Set to false to allow everyone to use the reload command
    -- Set to true to require ace permission: 'watermark.reload'
    -- Add this to your server.cfg: add_ace group.admin watermark.reload allow
    UseAcePermissions = true,
    AcePermission = 'watermark.reload',  -- The ace permission required
}
