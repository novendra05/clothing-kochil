fx_version 'cerulean'
game 'gta5'

author 'Antigravity'
description 'Bridge for clothing items with metadata support'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_inventory',
    'illenium-appearance',
    'ox_lib'
}
