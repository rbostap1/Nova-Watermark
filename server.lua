-- Watermark Server Script
-- Discord role-based permission gate for /watermark HUD

local function hasDiscordRole(src, allowed)
	if type(allowed) ~= 'table' or #allowed == 0 then 
		print('^1[Watermark-Server] No allowed roles configured in config.lua^7')
		return false 
	end

	-- Badger_Discord_API only
	if GetResourceState('Badger_Discord_API') == 'started' then
		print('^2[Watermark-Server] Badger_Discord_API is running, checking roles...^7')
		local ok, roles = pcall(function()
			return exports['Badger_Discord_API']:GetDiscordRoles(src)
		end)
		
		if not ok then
			print('^1[Watermark-Server] Error calling GetDiscordRoles: ' .. tostring(roles) .. '^7')
			return false
		end
		
		if type(roles) ~= 'table' then
			print('^1[Watermark-Server] GetDiscordRoles did not return a table. Returned: ' .. tostring(roles) .. '^7')
			return false
		end
		
		print('^3[Watermark-Server] Player has ' .. #roles .. ' Discord roles^7')
		for _, r in ipairs(roles) do
			print('^3[Watermark-Server] Checking role: ' .. tostring(r) .. '^7')
			for _, need in ipairs(allowed) do
				if tostring(r) == tostring(need) then
					print('^2[Watermark-Server] Role match found! Granting access.^7')
					return true
				end
			end
		end
		print('^1[Watermark-Server] No matching roles found. Required roles: ' .. table.concat(allowed, ', ') .. '^7')
	else
		print('^1[Watermark-Server] Badger_Discord_API is not started!^7')
	end

	return false
end

RegisterNetEvent('watermark:checkDiscordAccess', function()
	local src = source
	local allowed = false

	local allowedRoles = Config.DiscordRoleIds or {}
	allowed = hasDiscordRole(src, allowedRoles)

	if not allowed then
		-- If provider not available or role missing, log a helpful message
		if GetResourceState('Badger_Discord_API') ~= 'started' then
			print('^1[Watermark-Server] Badger_Discord_API not started. Install and ensure it for Discord role checks.^7')
		end
	end

	TriggerClientEvent('watermark:discordPermResult', src, allowed)
end)
