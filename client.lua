-- Watermark Client Script for FiveM
-- Displays a configurable watermark image on the top-right corner

local watermarkDict = nil
local watermarkTxn = nil

-- Load the texture dictionary and texture
local function LoadWatermarkTexture()
    if Config.Image and Config.Image ~= '' then
        -- Extract dictionary and texture name from the path
        -- Expected format: 'images/watermark' (without extension)
        local imagePath = string.gsub(Config.Image, '%.png$', '')
        imagePath = string.gsub(imagePath, '%.jpg$', '')
        
        -- Split path to get dictionary and texture
        local parts = {}
        for part in string.gmatch(imagePath, '([^/]+)') do
            table.insert(parts, part)
        end
        
        if #parts >= 2 then
            watermarkDict = parts[1]
            watermarkTxn = parts[2]
            
            -- Load the texture dictionary
            RequestStreamedTextureDict(watermarkDict, false)
            
            local timeout = 0
            while not HasStreamedTextureDictLoaded(watermarkDict) and timeout < 100 do
                Wait(10)
                timeout = timeout + 1
            end
            
            if HasStreamedTextureDictLoaded(watermarkDict) then
                return true
            else
                print('^1[Watermark] Failed to load texture dictionary: ' .. watermarkDict .. '^7')
                return false
            end
        else
            print('^1[Watermark] Invalid image path format. Expected: images/imagename^7')
            return false
        end
    end
    return false
end

-- Draw the watermark on screen
local function DrawWatermark()
    if not watermarkDict or not watermarkTxn then
        return
    end
    
    if not HasStreamedTextureDictLoaded(watermarkDict) then
        return
    end
    
    -- Get screen resolution
    local screenWidth, screenHeight = GetScreenResolution()
    
    -- Convert pixel dimensions to normalized screen coordinates (0.0 to 1.0)
    local width = Config.Width / screenWidth
    local height = Config.Height / screenHeight
    
    -- Calculate position (top-right corner)
    -- X position: 1.0 is right edge, subtract width and offset
    local x = 1.0 - width - (Config.OffsetX / screenWidth)
    -- Y position: 0.0 is top edge, add offset
    local y = 0.0 + (Config.OffsetY / screenHeight)
    
    -- Draw the texture
    DrawSprite(watermarkDict, watermarkTxn, x, y, width, height, 0.0, 255, 255, 255, math.floor(Config.Opacity * 255))
end

-- Main thread
Citizen.CreateThread(function()
    -- Load watermark texture on script start
    if Config.Enabled then
        if LoadWatermarkTexture() then
            print('^2[Watermark] Watermark loaded successfully^7')
        else
            print('^1[Watermark] Failed to load watermark^7')
        end
    end
    
    -- Continuously draw the watermark
    while true do
        Wait(0)
        
        if Config.Enabled and watermarkDict and watermarkTxn then
            DrawWatermark()
        end
    end
end)

-- Reload command (useful for testing)
TriggerEvent('chat:addSuggestion', '/reloadwatermark', 'Reload the watermark script')
RegisterCommand('reloadwatermark', function(source, args, rawCommand)
    if watermarkDict then
        ReleaseStreamedTextureDictMemory(watermarkDict)
    end
    watermarkDict = nil
    watermarkTxn = nil
    
    if Config.Enabled then
        if LoadWatermarkTexture() then
            print('^2[Watermark] Watermark reloaded successfully^7')
        else
            print('^1[Watermark] Failed to reload watermark^7')
        end
    end
end, false)
