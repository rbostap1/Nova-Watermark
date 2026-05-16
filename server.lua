local resourceName = GetCurrentResourceName()
local stateKey = 'watermark:state'

local defaults = {
    enabled = Config.Enabled ~= false,
    opacity = math.max(0.0, math.min(1.0, tonumber(Config.Opacity) or 0.5)),
    offsetX = math.floor(tonumber(Config.OffsetX) or 28),
    offsetY = math.floor(tonumber(Config.OffsetY) or 20),
    width = math.floor(tonumber(Config.Width) or 150),
    height = math.floor(tonumber(Config.Height) or 150),
    image = Config.Image or 'images/placeholder.jpg'
}

local state = {}

local function log(level, message)
    local prefixes = {
        info = '^2',
        success = '^2',
        warning = '^3',
        error = '^1'
    }

    local prefix = prefixes[level] or '^0'
    print(prefix .. '[Watermark-Server] ' .. message .. '^7')
end

local function clampNumber(value, minimum, maximum, integer)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end

    if numeric < minimum then
        numeric = minimum
    elseif numeric > maximum then
        numeric = maximum
    end

    if integer then
        numeric = math.floor(numeric)
    end

    return numeric
end

local function copyState(source)
    source = type(source) == 'table' and source or {}

    return {
        enabled = source.enabled ~= false,
        opacity = clampNumber(source.opacity, 0.0, 1.0, false) or defaults.opacity,
        offsetX = clampNumber(source.offsetX, 0, 10000, true) or defaults.offsetX,
        offsetY = clampNumber(source.offsetY, 0, 10000, true) or defaults.offsetY,
        width = clampNumber(source.width, 20, 2000, true) or defaults.width,
        height = clampNumber(source.height, 20, 2000, true) or defaults.height,
        image = type(source.image) == 'string' and source.image ~= '' and source.image or defaults.image
    }
end

local function persistState()
    SetResourceKvp(stateKey, json.encode(state))
end

local function loadState()
    local persisted = GetResourceKvpString(stateKey)

    if persisted and persisted ~= '' then
        local ok, decoded = pcall(json.decode, persisted)
        if ok and type(decoded) == 'table' then
            state = copyState(decoded)
            return
        end
    end

    state = copyState(defaults)
    persistState()
end

local function snapshotState()
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
    TriggerClientEvent('watermark:stateSync', target or -1, snapshotState())
end

local function notifyResult(sourceId, action, ok, message)
    TriggerClientEvent('watermark:actionResult', sourceId, {
        action = action,
        success = ok and true or false,
        message = message
    })
end

local function hasDiscordRole(sourceId, allowedRoles)
    if type(allowedRoles) ~= 'table' or #allowedRoles == 0 then
        return false
    end

    if GetResourceState('Badger_Discord_API') ~= 'started' then
        log('error', 'Badger_Discord_API is not started; Discord access checks cannot run')
        return false
    end

    local ok, roles = pcall(function()
        return exports['Badger_Discord_API']:GetDiscordRoles(sourceId)
    end)

    if not ok or type(roles) ~= 'table' then
        log('error', 'Failed to resolve Discord roles for player ' .. tostring(sourceId))
        return false
    end

    for _, roleId in ipairs(roles) do
        for _, allowedId in ipairs(allowedRoles) do
            if tostring(roleId) == tostring(allowedId) then
                return true
            end
        end
    end

    return false
end

local function isAuthorized(sourceId)
    if sourceId == 0 then
        return true
    end

    local allowedRoles = Config.DiscordRoleIds or {}
    if #allowedRoles == 0 then
        return true
    end

    return hasDiscordRole(sourceId, allowedRoles)
end

local function requireAuthorization(sourceId, action)
    if isAuthorized(sourceId) then
        return true
    end

    notifyResult(sourceId, action, false, 'Not authorized to modify watermark settings.')
    return false
end

loadState()

RegisterNetEvent('watermark:checkDiscordAccess', function()
    local sourceId = source
    TriggerClientEvent('watermark:discordPermResult', sourceId, isAuthorized(sourceId))
end)

RegisterNetEvent('watermark:requestState', function()
    sendState(source)
end)

RegisterNetEvent('watermark:setEnabled', function(payload)
    local sourceId = source

    if not requireAuthorization(sourceId, 'setEnabled') then
        return
    end

    local requested = nil
    if type(payload) == 'table' then
        requested = payload.enabled
    end

    if requested == nil then
        state.enabled = not state.enabled
    else
        state.enabled = requested and true or false
    end

    persistState()
    sendState()
    notifyResult(sourceId, 'setEnabled', true, ('Watermark %s.'):format(state.enabled and 'enabled' or 'disabled'))
end)

RegisterNetEvent('watermark:setOpacity', function(opacity)
    local sourceId = source

    if not requireAuthorization(sourceId, 'setOpacity') then
        return
    end

    local value = clampNumber(opacity, 0.0, 1.0, false)
    if value == nil then
        notifyResult(sourceId, 'setOpacity', false, 'Invalid opacity value.')
        return
    end

    state.opacity = value
    persistState()
    sendState()
    notifyResult(sourceId, 'setOpacity', true, ('Opacity updated to %.2f.'):format(state.opacity))
end)

RegisterNetEvent('watermark:setLayout', function(offsetX, offsetY, width, height)
    local sourceId = source

    if not requireAuthorization(sourceId, 'setLayout') then
        return
    end

    local nextOffsetX = clampNumber(offsetX, 0, 10000, true)
    local nextOffsetY = clampNumber(offsetY, 0, 10000, true)
    local nextWidth = clampNumber(width, 20, 2000, true)
    local nextHeight = clampNumber(height, 20, 2000, true)

    if nextOffsetX == nil or nextOffsetY == nil or nextWidth == nil or nextHeight == nil then
        notifyResult(sourceId, 'setLayout', false, 'Invalid layout values.')
        return
    end

    state.offsetX = nextOffsetX
    state.offsetY = nextOffsetY
    state.width = nextWidth
    state.height = nextHeight

    persistState()
    sendState()
    notifyResult(
        sourceId,
        'setLayout',
        true,
        ('Layout updated to X:%d Y:%d %dx%d.'):format(state.offsetX, state.offsetY, state.width, state.height)
    )
end)

RegisterNetEvent('watermark:resetState', function()
    local sourceId = source

    if not requireAuthorization(sourceId, 'resetState') then
        return
    end

    state = copyState(defaults)
    persistState()
    sendState()
    notifyResult(sourceId, 'resetState', true, 'Watermark reset to configured defaults.')
end)

AddEventHandler('onServerResourceStart', function(startedResource)
    if startedResource ~= resourceName then
        return
    end

    loadState()
    log('success', ('Loaded watermark state: enabled=%s opacity=%.2f position=%d,%d size=%dx%d'):format(
        tostring(state.enabled),
        state.opacity,
        state.offsetX,
        state.offsetY,
        state.width,
        state.height
    ))
end)