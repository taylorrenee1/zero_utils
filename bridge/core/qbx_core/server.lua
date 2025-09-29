local core = {}

function core.getPlayer(src)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    if not player then return false, "Player not found" end
    return player
end

function core.getPlayerData(src)
    local player, err = core.getPlayer(tonumber(src))
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
    local player_data, err = exports.qbx_core:GetPlayerData(src)
    if not player_data then return false, err end
    local job = player_data.job
    if not job then return false, "Job not found" end
    return job
end

function core.getJobData(jobName)
    local Jobs = exports.qbx_core:GetJobs()
    local job_data = Jobs[jobName]
    if not job_data then return false, "Job not found" end
    return job_data
end

function core.addThirst(src, thirst)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("thirst", player.PlayerData.metadata["thirst"] + thirst)
    TriggerClientEvent("hud:client:UpdateNeeds", src, player.PlayerData.metadata.hunger, thirst)
    return true
end

function core.setThirst(src, thirst)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("thirst", thirst)
    TriggerClientEvent("hud:client:UpdateNeeds", src, player.PlayerData.metadata.hunger, thirst)
    return true
end

function core.addHunger(src, hunger)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("hunger", player.PlayerData.metadata["hunger"] + hunger)
    TriggerClientEvent("hud:client:UpdateNeeds", src, player.PlayerData.metadata.hunger, player.PlayerData.metadata.thirst)
    return true
end

function core.setHunger(src, hunger)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData("hunger", hunger)
    TriggerClientEvent("hud:client:UpdateNeeds", src, hunger, player.PlayerData.metadata.thirst)
    return true
end

function core.updateStress(src, stress)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData('stress', player.PlayerData.metadata["stress"] + stress)
    TriggerClientEvent('hud:client:UpdateStress', src, stress)
end

function core.relieveStress(src, stress)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData('stress', player.PlayerData.metadata["stress"] - stress)
    TriggerClientEvent('hud:client:UpdateStress', src, stress)
end

function core.setStress(src, stress)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    player.Functions.SetMetaData('stress', player.PlayerData.metadata["stress"] + stress)
    TriggerClientEvent('hud:client:UpdateStress', src, stress)
end

function core.addHealth(src, health)
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    local entity = GetPlayerPed(src)
    local max_health = GetEntityMaxHealth(entity)
    local current_health = GetEntityHealth(entity)
    if current_health <= 0 then return end
    local new_health = math.clamp(100, current_health + health, max_health)
    Entity(entity).state:set('sv_health', new_health, true)
end

function core.setHealth(src, health)
    if not src then return end
    local player, err = core.getPlayer(src)
    if not player then return false, err end
    local entity = GetPlayerPed(src)
    local max_health = GetEntityMaxHealth(entity)
    local new_health = math.clamp(100, health, max_health)
    Entity(entity).state:set('sv_health', new_health, true)
end

function core.addArmour(src, armour)
    local currArmour = GetPedArmour(src)
    if currArmour >= 100 then return end
    SetPedArmour(src, math.min(100, math.floor(currArmour + armour)))
end

function core.setArmour(src, armour)
    SetPedArmour(src, armour)
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
