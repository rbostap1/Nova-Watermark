-- Watermark Client Script for FiveM
-- Displays a configurable watermark image using NUI

local nuiEnabled = false
local permissionCallbacks = {}

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

-- Handle permission check responses from server
RegisterNetEvent('watermark:permissionResult', function(playerId, permission, hasPermission)
    if permissionCallbacks[playerId] and permissionCallbacks[playerId][permission] then
        permissionCallbacks[playerId][permission](hasPermission)
        permissionCallbacks[playerId][permission] = nil
    end
end)

-- Local function to check permissions
local function CheckPermissionAndExecute(permissionName, callback)
    if not Config.UseAcePermissions then
        callback(true)
        return
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    if not permissionCallbacks[playerId] then
        permissionCallbacks[playerId] = {}
    end
    
    permissionCallbacks[playerId][permissionName] = callback
    TriggerServerEvent('watermark:checkPermission', playerId, permissionName)
end

-- Reload command (useful for testing)
RegisterCommand('reloadwatermark', function(source, args, rawCommand)
    CheckPermissionAndExecute(Config.AcePermission, function(hasPermission)
        if not hasPermission then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Watermark", "You don't have permission to use this command."}
            })
            return
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
    end)
end, false)

RegisterCommand('togglewatermark', function(source, args, rawCommand)
    CheckPermissionAndExecute(Config.AcePermission, function(hasPermission)
        if not hasPermission then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Watermark", "You don't have permission to use this command."}
            })
            return
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
    end)
end, false)
