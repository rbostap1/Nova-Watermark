-- Watermark Server Script for FiveM
-- Handles permission checks for commands

-- Register the permission check event
RegisterNetEvent('watermark:checkPermission', function(playerId, permission)
    local source = source
    local hasPermission = IsPlayerAceAllowed(source, permission)
    
    -- Send the result back to the client
    TriggerClientEvent('watermark:permissionResult', source, playerId, permission, hasPermission)
end)
