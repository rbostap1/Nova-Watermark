-- Watermark Client Script for FiveM
-- Displays a configurable watermark image using NUI

local nuiEnabled = false

-- Initialize NUI watermark
Citizen.CreateThread(function()
    if Config.Enabled then
        Wait(2000) -- Wait for UI to be ready
        
        SetNuiFocus(false, false) -- Ensure NUI is not blocking input
        SetNuiFocusKeepInput(false)
        
        SendNUIMessage({
            action = 'showWatermark',
            image = Config.Image,
            width = Config.Width,
            height = Config.Height,
            offsetX = Config.OffsetX,
            offsetY = Config.OffsetY,
            opacity = Config.Opacity
        })
        
        nuiEnabled = true
        print('^2[Watermark] Watermark loaded successfully^7')
        print('^3[Watermark] Image: ' .. Config.Image .. '^7')
    else
        print('^3[Watermark] Watermark is disabled in config^7')
    end
end)

-- Reload command (useful for testing)
RegisterCommand('reloadwatermark', function(source, args, rawCommand)
    SendNUIMessage({
        action = 'hideWatermark'
    })
    
    Wait(100)
    
    SendNUIMessage({
        action = 'showWatermark',
        image = Config.Image,
        width = Config.Width,
        height = Config.Height,
        offsetX = Config.OffsetX,
        offsetY = Config.OffsetY,
        opacity = Config.Opacity
    })
    
    print('^2[Watermark] Watermark reloaded^7')
end, false)

RegisterCommand('togglewatermark', function(source, args, rawCommand)
    if nuiEnabled then
        SendNUIMessage({
            action = 'hideWatermark'
        })
        nuiEnabled = false
        print('^3[Watermark] Watermark hidden^7')
    else
        SendNUIMessage({
            action = 'showWatermark',
            image = Config.Image,
            width = Config.Width,
            height = Config.Height,
            offsetX = Config.OffsetX,
            offsetY = Config.OffsetY,
            opacity = Config.Opacity
        })
        nuiEnabled = true
        print('^2[Watermark] Watermark shown^7')
    end
end, false)
