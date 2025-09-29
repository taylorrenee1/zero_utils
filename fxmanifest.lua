name "zero_utils"
author "Zero"
version "1.0.0"
description "Utility/Bridge for fivem scripts"
fx_version "cerulean"
game "gta5"
lua54 'yes'
use_experimental_fxv2_oal 'yes'

client_scripts {
    "init.lua",
    "client/*.lua",
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "init.lua",
    'bridge/inventory/ox_inventory/router.lua',
    "server/*.lua",
}

files {
    "init.lua",
    'modules/**/client.lua',
    'modules/**/shared.lua',
    'bridge/**/**/client.lua',
    'bridge/**/**/shared.lua',
    'shared/*.lua'
}

dependency '/assetpacks'

server_exports {
  'ox_useable',
  'ox_registerUseable',
}