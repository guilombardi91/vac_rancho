fx_version 'cerulean'
game 'rdr3'

author 'rural_system'
description 'Sistema rural persistente para RedM / VORP'
version '0.1.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config/general.lua',
    'config/ranches.lua',
    'config/permissions.lua',
    'config/animals.lua',
    'shared/constants.lua',
    'shared/enums.lua',
    'shared/utils.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/adapters/vorp.lua',
    'server/cache.lua',
    'server/security.lua',
    'server/audit.lua',
    'server/repositories/ranch_repository.lua',
    'server/repositories/animal_repository.lua',
    'server/services/ranch.lua',
    'server/services/animals.lua',
    'server/simulation/animals.lua',
    'server/exports.lua',
    'server/main.lua'
}

client_scripts {
    'client/interaction.lua',
    'client/animals.lua',
    'client/ui.lua',
    'client/main.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'vorp_core'
}
