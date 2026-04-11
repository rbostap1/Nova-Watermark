fx_version 'cerulean'
game 'gta5'

author 'Ryan Bostaph'
description 'Server-authoritative watermark control for FiveM'
version '1.1.0'

lua54 'yes'

server_scripts {
    'config.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'images/*'
}
