fx_version "cerulean"
game "rdr3"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
author 'Rayaan Uddin'
description 'Tebex donation system for RedM using VORP'
version '1.0.0'

server_script {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

client_script {
    'client.lua'
}

dependencies {
    'mysql-async',
    'vorp_core'
}
