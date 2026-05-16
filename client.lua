local resourceName = GetCurrentResourceName()

local currentState = {
    enabled = true,
    opacity = 0.5,
    offsetX = 28,
    offsetY = 20,
    width = 150,
    height = 150,
    image = 'images/placeholder.jpg'
}

local hudOpen = false

local function log(level, message)
    local prefixes = {
        info = '^2',
        success = '^2',
        warning = '^3',
        error = '^1'
    }

    local prefix = prefixes[level] or '^0'
    print(prefix .. '[Watermark-Client] ' .. message .. '^7')
end

local function requestState()
    TriggerServerEvent('watermark:requestState')
end

local function showWatermark()
    SendNUIMessage({
        action = 'showWatermark',
        state = currentState
    })
end

local function hideWatermark()
    SendNUIMessage({ action = 'hideWatermark' })
end

local function pushStateToUi()
    if currentState.enabled then
        showWatermark()
    else
        hideWatermark()
    end

    if hudOpen then
        SendNUIMessage({
            action = 'syncState',
            state = currentState
        })
    end
end

local function openHud()
    hudOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = 'openHUD',
        state = currentState
    })
end

local function closeHud()
    hudOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'closeHUD' })
end

CreateThread(function()
    Wait(250)
    log('info', 'Requesting initial watermark state from server')
    requestState()
end)

RegisterCommand('watermark', function()
    log('info', 'Requesting HUD access check')
    TriggerServerEvent('watermark:checkDiscordAccess')
end, false)

RegisterNetEvent('watermark:discordPermResult', function(allowed)
    if allowed then
        log('success', 'HUD access granted')
        openHud()
        requestState()
    else
        log('warning', 'HUD access denied')
    end
end)

RegisterNetEvent('watermark:stateSync', function(nextState)
    if type(nextState) ~= 'table' then
        return
    end

    currentState.enabled = nextState.enabled ~= false
    currentState.opacity = tonumber(nextState.opacity) or currentState.opacity
    currentState.offsetX = tonumber(nextState.offsetX) or currentState.offsetX
    currentState.offsetY = tonumber(nextState.offsetY) or currentState.offsetY
    currentState.width = tonumber(nextState.width) or currentState.width
    currentState.height = tonumber(nextState.height) or currentState.height

    if type(nextState.image) == 'string' and nextState.image ~= '' then
        currentState.image = nextState.image
    end

    log('info', 'State synchronized from server')
    pushStateToUi()
end)

RegisterNetEvent('watermark:actionResult', function(data)
    if type(data) ~= 'table' then
        return
    end

    local level = data.success and 'success' or 'warning'
    log(level, ('Action %s: %s'):format(data.action or 'unknown', data.message or 'Completed'))
end)

RegisterNUICallback('hud:toggle', function(_, cb)
    TriggerServerEvent('watermark:setEnabled', { enabled = not currentState.enabled })
    cb({ success = true })
end)

RegisterNUICallback('hud:setOpacity', function(data, cb)
    TriggerServerEvent('watermark:setOpacity', data and data.opacity)
    cb({ success = true })
end)

RegisterNUICallback('hud:updateLayout', function(data, cb)
    if type(data) ~= 'table' then
        cb({ success = false })
        return
    end

    TriggerServerEvent(
        'watermark:setLayout',
        data.offsetX,
        data.offsetY,
        data.width,
        data.height
    )

    cb({ success = true })
end)

RegisterNUICallback('hud:resetDefaults', function(_, cb)
    TriggerServerEvent('watermark:resetState')
    cb({ success = true })
end)

RegisterNUICallback('hud:syncState', function(_, cb)
    requestState()
    cb({ success = true })
end)

RegisterNUICallback('hud:refresh', function(_, cb)
    requestState()
    cb({ success = true })
end)

RegisterNUICallback('hud:close', function(_, cb)
    closeHud()
    cb({ success = true })
end)

log('success', 'Watermark client relay loaded')