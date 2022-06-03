local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-skills:fetchStatus', function(source, cb)
     local src = source
     local player = QBCore.Functions.GetPlayer(src)
     if player then
          MySQL.query.await('SELECT skills FROM players WHERE citizenid = ?', {
               player.PlayerData.citizenid
          }, function(status)
               if status then
                    cb(json.decode(status))
               else
                    cb(nil)
               end
          end)
     end
end)

RegisterNetEvent('qb-skills:server:update', function(data)
     local src = source
     local player = QBCore.Functions.GetPlayer(src)
     if player then
          MySQL.update('UPDATE players SET skills = ? WHERE citizenid = ?', {
               data,
               player.PlayerData.citizenid
          })
     end
end)