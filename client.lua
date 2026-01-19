-- Watermark Client Script for FiveM
-- Displays a configurable watermark image using NUI

local nuiEnabled = false
local hudOpen = false
local currentOpacity = Config.Opacity

-- Initialize NUI watermark
Citizen.CreateThread(function()
    if Config.Enabled then
        Wait(2000) -- Wait for UI to be ready
        
        SetNuiFocus(false, false) -- Ensure NUI is not blocking input
        SetNuiFocusKeepInput(false)
        
        SendNUIMessage({
            action = 'showWatermark',
            image = Config.Image,
            width = Config.Width,
            height = Config.Height,
            offsetX = Config.OffsetX,
            offsetY = Config.OffsetY,
            opacity = currentOpacity
        })
        
        nuiEnabled = true
        print('^2[Watermark] Watermark loaded successfully^7')
        print('^3[Watermark] Image: ' .. Config.Image .. '^7')
    else
        print('^3[Watermark] Watermark is disabled in config^7')
    end
end)

-- Helper functions to manage watermark
local function ShowWatermark()
    SendNUIMessage({
        action = 'showWatermark',
        image = Config.Image,
        width = Config.Width,
        height = Config.Height,
        offsetX = Config.OffsetX,
        offsetY = Config.OffsetY,
        opacity = currentOpacity
    })
    nuiEnabled = true
end

local function HideWatermark()
    SendNUIMessage({ action = 'hideWatermark' })
    nuiEnabled = false
end

local function OpenHUD()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    hudOpen = true
    SendNUIMessage({
        action = 'openHUD',
        state = {
            enabled = nuiEnabled,
            opacity = currentOpacity
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
    if nuiEnabled then
        HideWatermark()
        TriggerEvent('chat:addMessage', { color = {255,165,0}, multiline = true, args = {"Watermark", "Watermark hidden."} })
    else
        ShowWatermark()
        TriggerEvent('chat:addMessage', { color = {0,255,0}, multiline = true, args = {"Watermark", "Watermark shown."} })
    end
    cb({ enabled = nuiEnabled })
end)

RegisterNUICallback('hud:refresh', function(_, cb)
    local success, err = pcall(function()
        HideWatermark()
        Wait(100)
        ShowWatermark()
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
        SendNUIMessage({ action = 'updateOpacity', opacity = currentOpacity })
        cb({ success = true, opacity = currentOpacity })
    else
        cb({ success = false })
    end
end)

