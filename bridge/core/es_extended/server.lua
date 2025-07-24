local core = {}

function core.getPlayer(src)
    local player = ESX.GetPlayerFromId(src)
    if not player then return false, "Player not found" end
    return player
end

function core.getPlayerData(src)
    local player, err = ESX.GetPlayerFromId(src)
    if not player then return false, err end
    local player_data = {
        name = player.getName(),
        cash = player.getMoney(),
        bank = player.getAccount("bank").money,

        firstname = player.variables.firstName,
        lastname = player.variables.lastName,

        source = player.source,
        job = player.job.name,
        onDuty = player.job.onDuty,
        citizenId = player.identifier,
    }
    if not player_data then return false, "Player Data not found" end
    return player_data
end

function core.getJob(src)
    local player_data, err = ESX.GetPlayerFromId(src)
    if not player_data then return false, err end
    local job = player_data.job
    if not job then return false, "Job not found" end
    return job
end

function core.setThirst(src, thirst)
    TriggerClientEvent('esx_status:add', src, 'thirst', thirst)
    return true
end

function core.setHunger(src, hunger)
   TriggerClientEvent('esx_status:add', src, 'hunger', hunger)
    return true
end

return core
