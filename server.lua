-- Watermark Server Script
-- Discord role-based permission gate for /watermark HUD

local function hasDiscordRole(src, allowed)
	if type(allowed) ~= 'table' or #allowed == 0 then return false end

	-- Badger_Discord_API only
	if GetResourceState('Badger_Discord_API') == 'started' then
		local ok, roles = pcall(function()
			return exports['Badger_Discord_API']:GetDiscordRoles(src)
		end)
		if ok and type(roles) == 'table' then
			for _, r in ipairs(roles) do
				for _, need in ipairs(allowed) do
					if tostring(r) == tostring(need) then
						return true
					end
				end
			end
		end
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
