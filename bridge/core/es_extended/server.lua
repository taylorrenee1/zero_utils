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

function core.getJobData(jobName)
    local Jobs = ESX.GetJobs()
    while not next(Jobs) do
        Wait(100)
        Jobs = ESX.GetJobs()
    end
    for Role, Grades in pairs(Jobs) do
        -- Check for if user has added grades
        if Grades.grades == nil or not next(Grades.grades) then
            goto continue
        end
        for grade, info in pairs(Grades.grades) do
            if info.label and info.label:find("[Bb]oss") then
                Jobs[Role].grades[grade].isBoss = true
                goto continue
            end
        end
        local highestGrade = nil
        for k in pairs(Grades.grades) do
            local num = tonumber(k)
            if num and (not highestGrade or num > highestGrade) then
                highestGrade = num
            end
        end

        if highestGrade then
            Jobs[Role].grades[tostring(highestGrade)].isBoss = true
        end
        ::continue::
    end
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

if zutils.name == "zero_utils" then
    RegisterNetEvent("zero_utils:server:esx_toggleDuty", function()
        local src = source
        local player, err = core.getPlayer(src)
        if not player then
            printwarn(err)
            return
        end
        local job = player.job
        local grade = job.grade
        local onDuty = job.onDuty

        player.setJob(job.name, grade, not onDuty)
    end)
end

return core
