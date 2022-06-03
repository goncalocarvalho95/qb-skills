fx_version 'cerulean'
game 'gta5'

client_script'client.lua'
shared_script 'config.lua'
server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua',
}
