-- Watermark Server Script

local configFilePath = 'config.lua'

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
	local configContent = LoadResourceFile(GetCurrentResourceName(), configFilePath)
	if not configContent then
		log('error', 'Failed to read config file for saving')
		return false
	end

	configContent = string.gsub(configContent, 'Opacity%s*=%s*[%d.]+', 'Opacity = ' .. tostring(state.opacity))
	configContent = string.gsub(configContent, 'OffsetX%s*=%s*%d+', 'OffsetX = ' .. tostring(state.offsetX))
	configContent = string.gsub(configContent, 'OffsetY%s*=%s*%d+', 'OffsetY = ' .. tostring(state.offsetY))

	local success = SaveResourceFile(GetCurrentResourceName(), configFilePath, configContent, -1)
	if success then
		log('success', 'Configuration saved to ' .. configFilePath .. ' - Opacity: ' .. string.format('%.2f', state.opacity) .. ', OffsetX: ' .. state.offsetX .. ', OffsetY: ' .. state.offsetY)
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
	
	if saveStateToConfig() then
		log('success', 'Opacity updated and saved to config: ' .. string.format('%.2f', value))
		notifyResult(src, 'setOpacity', true, '')
	else
		log('error', 'Opacity updated but failed to save to config')
		notifyResult(src, 'setOpacity', false, 'Opacity updated but failed to save to config.')
	end
end)

RegisterNetEvent('watermark:setEnabled', function(payload)
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
	
	if saveStateToConfig() then
		log('success', 'Position updated and saved to config: X:' .. x .. ' Y:' .. y)
		notifyResult(src, 'setPosition', true, ('Position set to X:%d Y:%d and saved.'):format(x, y))
	else
		log('error', 'Position updated but failed to save to config')
		notifyResult(src, 'setPosition', false, 'Position updated but failed to save to config.')
	end
end)

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
	local action = state.enabled and 'shown' or 'hidden'
	notifyResult(src, 'setEnabled', true, 'Watermark queued to be ' .. action .. ' (pending save).')
end)

RegisterNetEvent('watermark:resetState', function()
	local src = source

	if not isAuthorized(src) then
		log('warning', 'Unauthorized reset attempt from ' .. tostring(src))
		notifyResult(src, 'resetState', false, 'Not authorized to reset state.')
		return
	end

	-- Reset to hardcoded defaults
	state.offsetX = 28
	state.offsetY = 20
	state.opacity = 0.5
	state.width = 150
	state.height = 150
	-- Keep other properties from config
	state.enabled = Config.Enabled
	state.image = Config.Image

	-- Save the defaults to config file
	local configContent = LoadResourceFile(GetCurrentResourceName(), configFilePath)
	if configContent then
		configContent = string.gsub(configContent, 'Opacity%s*=%s*[%d.]+', 'Opacity = 0.5')
		configContent = string.gsub(configContent, 'OffsetX%s*=%s*%d+', 'OffsetX = 28')
		configContent = string.gsub(configContent, 'OffsetY%s*=%s*%d+', 'OffsetY = 20')
		configContent = string.gsub(configContent, 'Width%s*=%s*%d+', 'Width = 150')
		configContent = string.gsub(configContent, 'Height%s*=%s*%d+', 'Height = 150')
		SaveResourceFile(GetCurrentResourceName(), configFilePath, configContent, -1)
	end

	log('success', 'Watermark reset to defaults by player ' .. src)
	sendState()
	notifyResult(src, 'resetState', true, 'Watermark reset to defaults (OffsetX=28, OffsetY=20, opacity=0.5, width=150, height=150).')
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


