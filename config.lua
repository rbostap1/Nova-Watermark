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
}
    -- Discord role-based permission for /watermark HUD
    -- Provide one or more Discord role IDs
    DiscordRoleIds = {
        -- Example: '123456789012345678',
    },

