-- Watermark Server Script for FiveM
-- Handles permission checks for commands

-- Register the permission check event
RegisterNetEvent('watermark:checkPermission', function(permission)
    local source = source
    print('^3[Watermark-Server] Checking permission \'' .. permission .. '\' for player ' .. source .. '^7')
    
    local hasPermission = IsPlayerAceAllowed(source, permission)
    print('^2[Watermark-Server] Permission result: ' .. tostring(hasPermission) .. '^7')
    
    -- Send the result back to the client
    TriggerClientEvent('watermark:permissionResult', source, permission, hasPermission)
end)
