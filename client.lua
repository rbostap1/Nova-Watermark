-- Watermark Client Script for FiveM
-- Displays a configurable watermark image using NUI

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

-- Initialize NUI watermark
Citizen.CreateThread(function()
    Wait(500)
    TriggerServerEvent('watermark:requestState')
end)

-- Helper functions to manage watermark
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
end

local function HideWatermark()
    SendNUIMessage({ action = 'hideWatermark' })
    nuiEnabled = false
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
    SendNUIMessage({ action = 'closeHUD' })
end
-- Discord role permission result
RegisterNetEvent('watermark:discordPermResult', function(allowed)
    if allowed then
        OpenHUD()
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Watermark", "You don't have permission to use /watermark."}
        })
    end
end)

-- Command to open HUD (permission checked server-side)
RegisterCommand('watermark', function()
    TriggerServerEvent('watermark:checkDiscordAccess')
end, false)

-- NUI callbacks from HUD
RegisterNUICallback('hud:close', function(_, cb)
    CloseHUD()
    cb({ success = true })
end)

RegisterNUICallback('hud:toggle', function(_, cb)
    local newState = not serverState.enabled
    serverState.enabled = newState
    nuiEnabled = newState
    TriggerServerEvent('watermark:setEnabled', { enabled = newState })
    TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', 'Toggling watermark server-wide...'} })
    cb({ enabled = newState })
end)

RegisterNUICallback('hud:toggleLocal', function(_, cb)
    localHidden = not localHidden
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
        TriggerEvent('chat:addMessage', { color = {0,255,0}, multiline = true, args = {"Watermark", "Watermark refreshed."} })
        cb({ success = true })
    else
        print('^1[Watermark] Error refreshing watermark: ' .. tostring(err) .. '^7')
        TriggerEvent('chat:addMessage', { color = {255,0,0}, multiline = true, args = {"Watermark", "Error refreshing watermark."} })
        cb({ success = false, error = tostring(err) })
    end
end)

RegisterNUICallback('hud:setOpacity', function(data, cb)
    local value = tonumber(data and data.opacity)
    if value then
        -- clamp between 0.0 and 1.0
        if value < 0.0 then value = 0.0 end
        if value > 1.0 then value = 1.0 end
        currentOpacity = value
        serverState.opacity = currentOpacity
        TriggerServerEvent('watermark:setOpacity', currentOpacity)
        SendNUIMessage({ action = 'updateOpacity', opacity = currentOpacity })
        TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', ('Setting opacity to %.2f server-wide...'):format(currentOpacity)} })
        cb({ success = true, opacity = currentOpacity })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback('hud:updatePosition', function(data, cb)
    local offsetX = tonumber(data and data.offsetX)
    local offsetY = tonumber(data and data.offsetY)
    
    if offsetX and offsetY then
        serverState.offsetX = offsetX
        serverState.offsetY = offsetY
        TriggerServerEvent('watermark:setPosition', offsetX, offsetY)
        TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', ('Updating position to X:%d Y:%d server-wide...'):format(offsetX, offsetY)} })
        cb({ success = true })
    else
        TriggerEvent('chat:addMessage', { color = {255,0,0}, multiline = true, args = {'Watermark', 'Invalid position values.'} })
        cb({ success = false })
    end
end)

RegisterNUICallback('hud:saveState', function(_, cb)
    TriggerServerEvent('watermark:saveState', {
        opacity = serverState.opacity,
        offsetX = serverState.offsetX,
        offsetY = serverState.offsetY
    })
    TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', 'Saving watermark state server-wide...'} })
    cb({ success = true })
end)

RegisterNUICallback('hud:resetDefaults', function(_, cb)
    TriggerServerEvent('watermark:resetState')
    TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', 'Resetting to config defaults server-wide...'} })
    cb({ success = true })
end)

RegisterNUICallback('hud:syncState', function(_, cb)
    TriggerServerEvent('watermark:requestState')
    TriggerEvent('chat:addMessage', { color = {255,255,255}, multiline = true, args = {'Watermark', 'Syncing watermark state from server...'} })
    cb({ success = true })
end)

-- State sync from server (initial + updates)
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
    end

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
end)

-- Action results from server (success/error)
RegisterNetEvent('watermark:actionResult', function(data)
    if type(data) ~= 'table' then return end
    local msg = data.message or 'Action complete.'
    local ok = data.success
    local color = ok and {0,255,0} or {255,0,0}
    TriggerEvent('chat:addMessage', { color = color, multiline = true, args = {'Watermark', msg} })
end)

