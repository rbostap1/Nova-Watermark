fx_version 'cerulean'
game 'gta5'

author 'Ryan Bostaph'
description 'A configurable watermark script for FiveM'
version '1.0.0'

lua54 'yes'

server_scripts {
    'config.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'images/*'
}
