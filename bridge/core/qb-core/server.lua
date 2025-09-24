local core = {}

function core.getPlayer(src)
    local player = QBCore.Functions.GetPlayer(tonumber(src))
    if not player then return false, "Player not found" end
    return player
end

function core.getPlayerData(src)
    local player, err = QBCore.Functions.GetPlayer(tonumber(src))
    if not player then return false, err end
    local player_data = player.PlayerData
    if not player_data then return false, "Player Data not found" end
    return player_data
end

function core.getGang(src)
    local player_data, err = core.getPlayerData(src)
    if not player_data then return false, err end
    local gang = player_data.gang
    if not gang then return false, "Gang not found" end
    return gang
end

function core.getJob(src)
    local player_data, err = core.getPlayerData(src)
    if not player_data then return false, err end
    local job = player_data.job
    if not job then return false, "Job not found" end
    return job
end

function core.getJobData(jobName)
    local job_data = QBCore.Shared.Jobs[jobName]
    if not job_data then return false, "Job not found" end
    return job_data
end

function core.setThirst(src, thirst)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("thirst", player.PlayerData.metadata["thirst"] + thirst)
    TriggerClientEvent("hud:client:UpdateNeeds", src, player.PlayerData.metadata.hunger, thirst)
    return true
end

function core.setHunger(src, hunger)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("hunger", player.PlayerData.metadata["hunger"] + hunger)
    TriggerClientEvent("hud:client:UpdateNeeds", src, hunger, player.PlayerData.metadata.thirst)
    return true
end

function core.removeMoney(src, amount, method, reason)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    return player.Functions.RemoveMoney(method, amount, reason)
end

function core.addMoney(src, amount, method, reason)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    return player.Functions.AddMoney(method, amount, reason)
end

return core
