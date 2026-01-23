-- Watermark Server Script
-- Discord role-based permission gate for /watermark HUD + shared watermark state
-- Now includes config file persistence and improved logging

-- ==================== Configuration Loading ====================
local configFilePath = 'config.lua'

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

-- ==================== Utility Functions ====================
local function clamp(value, min, max)
	if type(value) ~= 'number' then return nil end
	if value < min then return min end
	if value > max then return max end
	return value
end

local function log(level, message)
	local levelMap = {
		['info'] = '^2',
		['success'] = '^2',
		['warning'] = '^3',
		['error'] = '^1'
	}
	local prefix = levelMap[level] or '^0'
	print(prefix .. '[Watermark-Server] ' .. message .. '^7')
end

-- ==================== Config Persistence ====================
local function saveStateToConfig()
	-- Read the current config file content
	local configContent = LoadResourceFile(GetCurrentResourceName(), configFilePath)
	if not configContent then
		log('error', 'Failed to read config file for saving')
		return false
	end

	-- Update config values using string replacement
	local updates = {
		['Enabled = .-,'] = 'Enabled = ' .. (state.enabled and 'true' or 'false') .. ',',
		['Opacity = .-,'] = 'Opacity = ' .. tostring(state.opacity) .. ',',
		['OffsetX = .-,'] = 'OffsetX = ' .. tostring(state.offsetX) .. ',',
		['OffsetY = .-,'] = 'OffsetY = ' .. tostring(state.offsetY) .. ',',
		['Image = \'.-\''] = 'Image = \'' .. tostring(state.image) .. '\'',
		['Width = .-,'] = 'Width = ' .. tostring(state.width) .. ',',
		['Height = .-,'] = 'Height = ' .. tostring(state.height) .. ','
	}

	for pattern, replacement in pairs(updates) do
		configContent = string.gsub(configContent, pattern, replacement)
	end

	-- Save to config file
	local success = SaveResourceFile(GetCurrentResourceName(), configFilePath, configContent, -1)
	if success then
		log('success', 'Configuration saved to ' .. configFilePath)
		return true
	else
		log('error', 'Failed to save configuration to file')
		return false
	end
end

-- ==================== State Synchronization ====================
local function notifyResult(src, action, ok, message)
	TriggerClientEvent('watermark:actionResult', src, {
		action = action,
		success = ok and true or false,
		message = message
	})
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

-- ==================== Authorization ====================
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
		log('warning', 'No allowed roles configured in config.lua')
		return false 
	end

	-- Badger_Discord_API only
	if GetResourceState('Badger_Discord_API') == 'started' then
		log('info', 'Badger_Discord_API is running, checking roles for player ' .. src)
		local ok, roles = pcall(function()
			return exports['Badger_Discord_API']:GetDiscordRoles(src)
		end)
		
		if not ok then
			log('error', 'Error calling GetDiscordRoles: ' .. tostring(roles))
			return false
		end
		
		if type(roles) ~= 'table' then
			log('error', 'GetDiscordRoles did not return a table. Returned: ' .. tostring(roles))
			return false
		end
		
		log('info', 'Player ' .. src .. ' has ' .. #roles .. ' Discord roles')
		for _, r in ipairs(roles) do
			for _, need in ipairs(allowed) do
				if tostring(r) == tostring(need) then
					log('success', 'Access granted for player ' .. src .. ' - Role match found')
					return true
				end
			end
		end
		log('warning', 'Access denied for player ' .. src .. ' - No matching roles')
	else
		log('error', 'Badger_Discord_API is not started! Discord role checks will not work.')
	end

	return false
end

-- ==================== Events ====================
RegisterNetEvent('watermark:checkDiscordAccess', function()
	local src = source
	local allowed = false

	local allowedRoles = Config.DiscordRoleIds or {}
	if #allowedRoles == 0 then
		allowed = true
		log('info', 'Player ' .. src .. ' requested HUD access - No role restrictions, access granted')
	else
		allowed = hasDiscordRole(src, allowedRoles)
	end

	if not allowed and GetResourceState('Badger_Discord_API') ~= 'started' then
		log('error', 'Badger_Discord_API not started - Install and ensure it for Discord role checks')
	end

	TriggerClientEvent('watermark:discordPermResult', src, allowed)
end)

-- Initial state sync for newly connecting clients
RegisterNetEvent('watermark:requestState', function()
	local src = source
	sendState(src)
	log('info', 'State synced to player ' .. src)
end)

-- ==================== Server-Wide Changes (Only Logged When Saved) ====================
-- Server-wide opacity update
RegisterNetEvent('watermark:setOpacity', function(opacity)
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized opacity update attempt from ' .. tostring(src))
		notifyResult(src, 'setOpacity', false, 'Not authorized to change opacity.')
		return
	end

	local value = clamp(tonumber(opacity), 0.0, 1.0)
	if not value then
		notifyResult(src, 'setOpacity', false, 'Invalid opacity value.')
		return
	end

	state.opacity = value
	sendState()
	-- No server log here - only logged when saved
	notifyResult(src, 'setOpacity', true, ('Opacity set to %.2f (pending save).'):format(value))
end)

-- Server-wide position update
RegisterNetEvent('watermark:setPosition', function(offsetX, offsetY)
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized position update attempt from ' .. tostring(src))
		notifyResult(src, 'setPosition', false, 'Not authorized to change position.')
		return
	end

	local x = clamp(tonumber(offsetX), 0, 10000)
	local y = clamp(tonumber(offsetY), 0, 10000)
	if not x or not y then
		notifyResult(src, 'setPosition', false, 'Invalid position values.')
		return
	end

	state.offsetX = x
	state.offsetY = y
	sendState()
	-- No server log here - only logged when saved
	notifyResult(src, 'setPosition', true, ('Position set to X:%d Y:%d (pending save).'):format(x, y))
end)

-- Server-wide enabled toggle
RegisterNetEvent('watermark:setEnabled', function(payload)
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized visibility toggle attempt from ' .. tostring(src))
		notifyResult(src, 'setEnabled', false, 'Not authorized to toggle watermark.')
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
	-- No server log here - only logged when saved
	local action = state.enabled and 'shown' or 'hidden'
	notifyResult(src, 'setEnabled', true, 'Watermark queued to be ' .. action .. ' (pending save).')
end)

-- ==================== Save State to Config ====================
RegisterNetEvent('watermark:saveState', function(payload)
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized save attempt from ' .. tostring(src))
		notifyResult(src, 'saveState', false, 'Not authorized to save state.')
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

	-- Save to config file
	local savedSuccessfully = saveStateToConfig()

	if savedSuccessfully then
		log('success', 'Configuration saved by player ' .. src .. ' - Enabled: ' .. (state.enabled and 'true' or 'false') .. 
			', Opacity: ' .. string.format('%.2f', state.opacity) .. 
			', Position: X:' .. state.offsetX .. ' Y:' .. state.offsetY)
		sendState()
		notifyResult(src, 'saveState', true, 'Watermark configuration saved to config file and broadcast server-wide.')
	else
		log('error', 'Failed to save configuration from player ' .. src)
		notifyResult(src, 'saveState', false, 'Failed to save configuration.')
	end
end)

-- Reset to configured defaults
RegisterNetEvent('watermark:resetState', function()
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized reset attempt from ' .. tostring(src))
		notifyResult(src, 'resetState', false, 'Not authorized to reset state.')
		return
	end

	state.enabled = Config.Enabled
	state.opacity = Config.Opacity
	state.offsetX = Config.OffsetX
	state.offsetY = Config.OffsetY
	state.image = Config.Image
	state.width = Config.Width
	state.height = Config.Height

	-- Save reset state to config
	local savedSuccessfully = saveStateToConfig()

	if savedSuccessfully then
		log('success', 'Watermark reset to defaults by player ' .. src)
		sendState()
		notifyResult(src, 'resetState', true, 'Watermark reset to config defaults and saved.')
	else
		log('error', 'Failed to reset and save watermark from player ' .. src)
		notifyResult(src, 'resetState', false, 'Failed to reset watermark.')
	end
end)

-- ==================== Initial Startup ====================
AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		log('info', 'Watermark resource started')
		log('info', 'Initial state - Enabled: ' .. (state.enabled and 'true' or 'false') .. 
			', Opacity: ' .. string.format('%.2f', state.opacity) .. 
			', Position: X:' .. state.offsetX .. ' Y:' .. state.offsetY)
	end
end)

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
	notifyResult(source, 'sync', true, 'Watermark state synced from server.')
end)

-- Server-wide opacity update
RegisterNetEvent('watermark:setOpacity', function(opacity)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized opacity update attempt from ' .. tostring(src) .. '^7')
		notifyResult(src, 'setOpacity', false, 'Not authorized to change opacity.')
		return
	end

	local value = clamp(tonumber(opacity), 0.0, 1.0)
	if not value then
		notifyResult(src, 'setOpacity', false, 'Invalid opacity value.')
		return
	end

	state.opacity = value
	sendState()
	notifyResult(src, 'setOpacity', true, ('Opacity set to %.2f server-wide.'):format(value))
end)

-- Server-wide position update
RegisterNetEvent('watermark:setPosition', function(offsetX, offsetY)
	local src = source

	if not isAuthorized(src) then
		print('^1[Watermark-Server] Unauthorized position update attempt from ' .. tostring(src) .. '^7')
		notifyResult(src, 'setPosition', false, 'Not authorized to change position.')
		return
	end

	local x = clamp(tonumber(offsetX), 0, 10000)
	local y = clamp(tonumber(offsetY), 0, 10000)
	if not x or not y then
		notifyResult(src, 'setPosition', false, 'Invalid position values.')
		return
	end

	state.offsetX = x
	state.offsetY = y
	sendState()
	notifyResult(src, 'setPosition', true, ('Position set to X:%d Y:%d server-wide.'):format(x, y))
end)


