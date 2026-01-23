-- Watermark Client Script for FiveM
-- Displays a configurable watermark image using NUI
-- Updated with redesigned HUD and improved state management

-- ==================== Local State ====================
local nuiEnabled = false
local hudOpen = false
local currentOpacity = Config.Opacity
local localHidden = false

local serverState = {
    enabled = Config.Enabled,
    opacity = Config.Opacity,
    offsetX = Config.OffsetX,
    offsetY = Config.OffsetY,
    image = Config.Image,
    width = Config.Width,
    height = Config.Height
}

-- ==================== Logging Helper ====================
local function log(level, message)
	local levelMap = {
		['info'] = '^2',
		['success'] = '^2',
		['warning'] = '^3',
		['error'] = '^1'
	}
	local prefix = levelMap[level] or '^0'
	print(prefix .. '[Watermark-Client] ' .. message .. '^7')
end

-- ==================== Initialization ====================
Citizen.CreateThread(function()
    Wait(500)
    log('info', 'Requesting initial state from server')
    TriggerServerEvent('watermark:requestState')
end)

-- ==================== Watermark Display Management ====================
local function ShowWatermark()
    local state = serverState or {}
    currentOpacity = state.opacity or currentOpacity

    SendNUIMessage({
        action = 'showWatermark',
        image = state.image or Config.Image,
        width = state.width or Config.Width,
        height = state.height or Config.Height,
        offsetX = state.offsetX or Config.OffsetX,
        offsetY = state.offsetY or Config.OffsetY,
        opacity = state.opacity or currentOpacity
    })
    nuiEnabled = true
    log('info', 'Watermark displayed')
end

local function HideWatermark()
    SendNUIMessage({ action = 'hideWatermark' })
    nuiEnabled = false
    log('info', 'Watermark hidden')
end

local function ApplyVisibility()
    if serverState.enabled and not localHidden then
        ShowWatermark()
    else
        HideWatermark()
    end
end

local function OpenHUD()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    hudOpen = true
    log('info', 'Opening HUD control center')
    SendNUIMessage({
        action = 'openHUD',
        state = {
            enabled = serverState.enabled,
            opacity = serverState.opacity,
            offsetX = serverState.offsetX,
            offsetY = serverState.offsetY,
            localHidden = localHidden
        }
    })
end

local function CloseHUD()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    hudOpen = false
    log('info', 'Closing HUD control center')
    SendNUIMessage({ action = 'closeHUD' })
end

-- ==================== Commands ====================
RegisterCommand('watermark', function()
    log('info', 'Player requested watermark HUD access')
    TriggerServerEvent('watermark:checkDiscordAccess')
end, false)

-- ==================== Server Events ====================
RegisterNetEvent('watermark:discordPermResult', function(allowed)
    if allowed then
        log('success', 'Player has permission to access HUD')
        OpenHUD()
    else
        log('warning', 'Player denied access to HUD - insufficient permissions')
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Watermark", "You don't have permission to use /watermark."}
        })
    end
end)

RegisterNetEvent('watermark:stateSync', function(newState)
    if type(newState) == 'table' then
        serverState.enabled = newState.enabled
        serverState.opacity = newState.opacity or serverState.opacity
        serverState.offsetX = newState.offsetX or serverState.offsetX
        serverState.offsetY = newState.offsetY or serverState.offsetY
        serverState.image = newState.image or serverState.image
        serverState.width = newState.width or serverState.width
        serverState.height = newState.height or serverState.height
        currentOpacity = serverState.opacity or currentOpacity
        
        log('info', 'State synchronized from server')
    end

    ApplyVisibility()

    if hudOpen then
        SendNUIMessage({
            action = 'syncState',
            state = {
                enabled = serverState.enabled,
                opacity = serverState.opacity,
                offsetX = serverState.offsetX,
                offsetY = serverState.offsetY,
                localHidden = localHidden
            }
        })
    end
end)

RegisterNetEvent('watermark:actionResult', function(data)
    if type(data) ~= 'table' then return end
    local msg = data.message or 'Action complete.'
    local ok = data.success
    local color = ok and {0, 255, 0} or {255, 0, 0}
    local level = ok and 'success' or 'warning'
    
    log(level, 'Action: ' .. (data.action or 'unknown') .. ' - ' .. msg)
    TriggerEvent('chat:addMessage', { color = color, multiline = true, args = {'Watermark', msg} })
end)

-- ==================== NUI Callbacks ====================
RegisterNUICallback('hud:close', function(_, cb)
    CloseHUD()
    cb({ success = true })
end)

RegisterNUICallback('hud:toggle', function(_, cb)
    local newState = not serverState.enabled
    serverState.enabled = newState
    nuiEnabled = newState
    log('info', 'Toggling watermark visibility: ' .. (newState and 'SHOW' or 'HIDE'))
    TriggerServerEvent('watermark:setEnabled', { enabled = newState })
    TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', 'Toggling watermark visibility...'} })
    cb({ enabled = newState })
end)

RegisterNUICallback('hud:toggleLocal', function(_, cb)
    localHidden = not localHidden
    log('info', 'Local toggle: ' .. (localHidden and 'HIDDEN' or 'VISIBLE'))
    ApplyVisibility()
    SendNUIMessage({
        action = 'syncState',
        state = {
            enabled = serverState.enabled,
            opacity = serverState.opacity,
            offsetX = serverState.offsetX,
            offsetY = serverState.offsetY,
            localHidden = localHidden
        }
    })
    cb({ hidden = localHidden })
end)

RegisterNUICallback('hud:refresh', function(_, cb)
    local success, err = pcall(function()
        HideWatermark()
        Wait(100)
        ApplyVisibility()
    end)
    if success then
        log('success', 'Watermark display refreshed')
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, multiline = true, args = {"Watermark", "Watermark refreshed."} })
        cb({ success = true })
    else
        log('error', 'Error refreshing watermark: ' .. tostring(err))
        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, multiline = true, args = {"Watermark", "Error refreshing watermark."} })
        cb({ success = false, error = tostring(err) })
    end
end)

RegisterNUICallback('hud:setOpacity', function(data, cb)
    local value = tonumber(data and data.opacity)
    if value then
        value = math.max(0.0, math.min(1.0, value))
        currentOpacity = value
        serverState.opacity = currentOpacity
        log('info', 'Opacity adjusted to ' .. string.format('%.2f', currentOpacity))
        TriggerServerEvent('watermark:setOpacity', currentOpacity)
        SendNUIMessage({ action = 'updateOpacity', opacity = currentOpacity })
        TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', ('Opacity set to %.0f%%...'):format(currentOpacity * 100)} })
        cb({ success = true, opacity = currentOpacity })
    else
        log('error', 'Invalid opacity value provided')
        cb({ success = false })
    end
end)

RegisterNUICallback('hud:updatePosition', function(data, cb)
    local offsetX = tonumber(data and data.offsetX)
    local offsetY = tonumber(data and data.offsetY)
    
    if offsetX and offsetY then
        serverState.offsetX = offsetX
        serverState.offsetY = offsetY
        log('info', 'Position updated to X:' .. offsetX .. ' Y:' .. offsetY)
        TriggerServerEvent('watermark:setPosition', offsetX, offsetY)
        TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', ('Position updated to X:%d Y:%d...'):format(offsetX, offsetY)} })
        cb({ success = true })
    else
        log('error', 'Invalid position values')
        TriggerEvent('chat:addMessage', { color = {255, 0, 0}, multiline = true, args = {'Watermark', 'Invalid position values.'} })
        cb({ success = false })
    end
end)

RegisterNUICallback('hud:saveState', function(_, cb)
    log('info', 'Saving watermark state to config file')
    TriggerServerEvent('watermark:saveState', {
        opacity = serverState.opacity,
        offsetX = serverState.offsetX,
        offsetY = serverState.offsetY
    })
    TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', 'Saving configuration to file...'} })
    cb({ success = true })
end)

RegisterNUICallback('hud:resetDefaults', function(_, cb)
    log('info', 'Resetting to config defaults')
    TriggerServerEvent('watermark:resetState')
    TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', 'Resetting to defaults...'} })
    cb({ success = true })
end)

RegisterNUICallback('hud:syncState', function(_, cb)
    log('info', 'Syncing state from server')
    TriggerServerEvent('watermark:requestState')
    TriggerEvent('chat:addMessage', { color = {255, 255, 255}, multiline = true, args = {'Watermark', 'Syncing with server...'} })
    cb({ success = true })
end)

log('success', 'Watermark client script loaded')

