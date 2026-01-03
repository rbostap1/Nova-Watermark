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
    -- Check ace permissions if enabled
    if Config.UseAcePermissions then
        if not IsPlayerAceAllowed(PlayerId(), Config.AcePermission) then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Watermark", "You don't have permission to use this command."}
            })
            return
        end
    end
    
    local success, err = pcall(function()
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
    end)
    
    if success then
        print('^2[Watermark] Watermark reloaded^7')
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Watermark", "Watermark refreshed successfully!"}
        })
    else
        print('^1[Watermark] Error reloading watermark: ' .. tostring(err) .. '^7')
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Watermark", "Error refreshing watermark. Please check console for details."}
        })
    end
end, false)

RegisterCommand('togglewatermark', function(source, args, rawCommand)
    -- Check ace permissions if enabled
    if Config.UseAcePermissions then
        if not IsPlayerAceAllowed(PlayerId(), Config.AcePermission) then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Watermark", "You don't have permission to use this command."}
            })
            return
        end
    end
    
    if nuiEnabled then
        SendNUIMessage({
            action = 'hideWatermark'
        })
        nuiEnabled = false
        print('^3[Watermark] Watermark hidden^7')
        TriggerEvent('chat:addMessage', {
            color = {255, 165, 0},
            multiline = true,
            args = {"Watermark", "Watermark hidden."}
        })
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
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Watermark", "Watermark shown."}
        })
    end
end, false)
