-- Watermark Server Script

local resourceName = GetCurrentResourceName()
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

local DEFAULTS = {
    opacity = Config.Opacity,
    offsetX = Config.OffsetX,
    offsetY = Config.OffsetY,
    width = Config.Width,
    height = Config.Height
}

local hasDiscordRole

local function log(level, message)
    local levelMap = {
        info = '^2',
        success = '^2',
        warning = '^3',
        error = '^1'
    }
    local prefix = levelMap[level] or '^0'
    print(prefix .. '[Watermark-Server] ' .. message .. '^7')
end

local function clamp(value, minValue, maxValue)
    if type(value) ~= 'number' then
        return nil
    end

    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

local function boolToLua(value)
    return value and 'true' or 'false'
end

local function saveStateToConfig()
    local configContent = LoadResourceFile(resourceName, configFilePath)
    if not configContent then
        log('error', 'Failed to read config.lua for persistence')
        return false
    end

    configContent = configContent:gsub('Enabled%s*=%s*%a+', 'Enabled = ' .. boolToLua(state.enabled))
    configContent = configContent:gsub('Opacity%s*=%s*[%d.]+', 'Opacity = ' .. tostring(state.opacity))
    configContent = configContent:gsub('OffsetX%s*=%s*%-?%d+', 'OffsetX = ' .. tostring(state.offsetX))
    configContent = configContent:gsub('OffsetY%s*=%s*%-?%d+', 'OffsetY = ' .. tostring(state.offsetY))
    configContent = configContent:gsub('Width%s*=%s*%d+', 'Width = ' .. tostring(state.width))
    configContent = configContent:gsub('Height%s*=%s*%d+', 'Height = ' .. tostring(state.height))

    local success = SaveResourceFile(resourceName, configFilePath, configContent, -1)
    if success then
        log('success', ('Config persisted (Enabled=%s Opacity=%.2f X=%d Y=%d)'):format(
            boolToLua(state.enabled),
            state.opacity,
            state.offsetX,
            state.offsetY
        ))
    else
        log('error', 'Failed to save updated config.lua')
    end

    return success
end

local function payloadState()
    return {
        enabled = state.enabled,
        opacity = state.opacity,
        offsetX = state.offsetX,
        offsetY = state.offsetY,
        image = state.image,
        width = state.width,
        height = state.height
    }
end

local function sendState(target)
    TriggerClientEvent('watermark:stateSync', target or -1, payloadState())
end

local function notifyResult(src, action, ok, message)
    TriggerClientEvent('watermark:actionResult', src, {
        action = action,
        success = ok and true or false,
        message = message
    })
end

hasDiscordRole = function(src, allowed)
    if type(allowed) ~= 'table' or #allowed == 0 then
        return false
    end

    if GetResourceState('Badger_Discord_API') ~= 'started' then
        log('error', 'Badger_Discord_API is not started; role checks cannot run')
        return false
    end

    local ok, roles = pcall(function()
        return exports['Badger_Discord_API']:GetDiscordRoles(src)
    end)

    if not ok or type(roles) ~= 'table' then
        log('error', 'Failed to resolve Discord roles for player ' .. tostring(src))
        return false
    end

    for _, role in ipairs(roles) do
        for _, need in ipairs(allowed) do
            if tostring(role) == tostring(need) then
                return true
            end
        end
    end

    return false
end

local function isAuthorized(src)
    if src == 0 then
        return true
    end

    local allowedRoles = Config.DiscordRoleIds or {}
    if #allowedRoles == 0 then
        return true
    end

    return hasDiscordRole(src, allowedRoles)
end

RegisterNetEvent('watermark:checkDiscordAccess', function()
    local src = source
    local allowed = isAuthorized(src)
    TriggerClientEvent('watermark:discordPermResult', src, allowed)
end)

RegisterNetEvent('watermark:requestState', function()
    local src = source
    sendState(src)
end)

RegisterNetEvent('watermark:setEnabled', function(payload)
    local src = source

    if not isAuthorized(src) then
        notifyResult(src, 'setEnabled', false, 'Not authorized to toggle watermark.')
        return
    end

    local desired = payload
    if type(payload) == 'table' then
        desired = payload.enabled
    end

    if desired == nil then
        state.enabled = not state.enabled
    else
        state.enabled = desired and true or false
    end

    sendState()
    if saveStateToConfig() then
        notifyResult(src, 'setEnabled', true, 'Watermark visibility updated.')
    else
        notifyResult(src, 'setEnabled', false, 'Visibility changed but config save failed.')
    end
end)

RegisterNetEvent('watermark:setOpacity', function(opacity)
    local src = source

    if not isAuthorized(src) then
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
        notifyResult(src, 'setOpacity', true, ('Opacity updated to %.2f.'):format(value))
    else
        notifyResult(src, 'setOpacity', false, 'Opacity updated but config save failed.')
    end
end)

RegisterNetEvent('watermark:setPosition', function(offsetX, offsetY)
    local src = source

    if not isAuthorized(src) then
        notifyResult(src, 'setPosition', false, 'Not authorized to change position.')
        return
    end

    local x = clamp(tonumber(offsetX), 0, 10000)
    local y = clamp(tonumber(offsetY), 0, 10000)

    if not x or not y then
        notifyResult(src, 'setPosition', false, 'Invalid position values.')
        return
    end

    state.offsetX = math.floor(x)
    state.offsetY = math.floor(y)
    sendState()

    if saveStateToConfig() then
        notifyResult(src, 'setPosition', true, ('Position updated to X:%d Y:%d.'):format(state.offsetX, state.offsetY))
    else
        notifyResult(src, 'setPosition', false, 'Position updated but config save failed.')
    end
end)

RegisterNetEvent('watermark:resetState', function()
    local src = source

    if not isAuthorized(src) then
        notifyResult(src, 'resetState', false, 'Not authorized to reset state.')
        return
    end

    state.enabled = Config.Enabled
    state.opacity = DEFAULTS.opacity
    state.offsetX = DEFAULTS.offsetX
    state.offsetY = DEFAULTS.offsetY
    state.width = DEFAULTS.width
    state.height = DEFAULTS.height
    state.image = Config.Image

    sendState()

    if saveStateToConfig() then
        notifyResult(src, 'resetState', true, 'Watermark reset to configured defaults.')
    else
        notifyResult(src, 'resetState', false, 'Reset applied but config save failed.')
    end
end)

AddEventHandler('onServerResourceStart', function(startedResource)
    if startedResource ~= resourceName then
        return
    end

    log('info', ('Started with Enabled=%s Opacity=%.2f Position=%d,%d Size=%dx%d'):format(
        boolToLua(state.enabled),
        state.opacity,
        state.offsetX,
        state.offsetY,
        state.width,
        state.height
    ))
end)
