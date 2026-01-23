
-- Watermark Server Script
-- Discord role-based permission gate for /watermark HUD + shared watermark state

-- Shared watermark state (server-wide)
local state = {
	enabled = Config.Enabled,
	opacity = Config.Opacity,
	offsetX = Config.OffsetX,
	offsetY = Config.OffsetY,
	image = Config.Image,
	width = Config.Width,
	height = Config.Height
}

-- Forward declaration for role check
local hasDiscordRole

local function clamp(value, min, max)
	if type(value) ~= 'number' then return nil end
	if value < min then return min end
	if value > max then return max end
	return value
end

local function sendState(target)
	local payload = {
		enabled = state.enabled,
		opacity = state.opacity,
		offsetX = state.offsetX,
		offsetY = state.offsetY,
		image = state.image,
		width = state.width,
		height = state.height
	}

	if target then
		TriggerClientEvent('watermark:stateSync', target, payload)
	else
		TriggerClientEvent('watermark:stateSync', -1, payload)
	end
end

local function isAuthorized(src)
	if src == 0 then return true end -- allow console
	local allowedRoles = Config.DiscordRoleIds or {}
	if #allowedRoles == 0 then
		return true -- no roles configured means allow all
	end
	return hasDiscordRole(src, allowedRoles)
end

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
	if #allowedRoles == 0 then
		allowed = true
	else
		allowed = hasDiscordRole(src, allowedRoles)
	end

	if not allowed then
		-- If provider not available or role missing, log a helpful message
		if GetResourceState('Badger_Discord_API') ~= 'started' then
			print('^1[Watermark-Server] Badger_Discord_API not started. Install and ensure it for Discord role checks.^7')
		end
	end

	TriggerClientEvent('watermark:discordPermResult', src, allowed)
end)

-- Initial state sync for newly connecting clients
RegisterNetEvent('watermark:requestState', function()
	sendState(source)
end)

-- Server-wide opacity update
RegisterNetEvent('watermark:setOpacity', function(opacity)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized opacity update attempt from ' .. tostring(src) .. '^7')
		return
	end

	local value = clamp(tonumber(opacity), 0.0, 1.0)
	if not value then return end

	state.opacity = value
	sendState()
end)

-- Server-wide position update
RegisterNetEvent('watermark:setPosition', function(offsetX, offsetY)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized position update attempt from ' .. tostring(src) .. '^7')
		return
	end

	local x = clamp(tonumber(offsetX), 0, 10000)
	local y = clamp(tonumber(offsetY), 0, 10000)
	if not x or not y then return end

	state.offsetX = x
	state.offsetY = y
	sendState()
end)

-- Server-wide enabled toggle
RegisterNetEvent('watermark:setEnabled', function(payload)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized visibility toggle attempt from ' .. tostring(src) .. '^7')
		return
	end

	local desired
	if type(payload) == 'table' then
		desired = payload.enabled
	else
		desired = payload
	end

	if desired == nil then
		state.enabled = not state.enabled
	else
		state.enabled = desired and true or false
	end

	sendState()
end)

-- Save current state (re-broadcast to ensure everyone is in sync)
RegisterNetEvent('watermark:saveState', function(payload)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized save attempt from ' .. tostring(src) .. '^7')
		return
	end

	if type(payload) == 'table' then
		local val = clamp(tonumber(payload.opacity), 0.0, 1.0)
		local ox = clamp(tonumber(payload.offsetX), 0, 10000)
		local oy = clamp(tonumber(payload.offsetY), 0, 10000)

		if val then state.opacity = val end
		if ox then state.offsetX = ox end
		if oy then state.offsetY = oy end
	end

	sendState()
end)

-- Reset to configured defaults
RegisterNetEvent('watermark:resetState', function()
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized reset attempt from ' .. tostring(src) .. '^7')
		return
	end

	state.enabled = Config.Enabled
	state.opacity = Config.Opacity
	state.offsetX = Config.OffsetX
	state.offsetY = Config.OffsetY
	state.image = Config.Image
	state.width = Config.Width
	state.height = Config.Height

	sendState()
end)
