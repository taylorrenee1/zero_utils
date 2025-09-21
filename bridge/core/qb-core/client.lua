local core = {}

function core.getPlayerData()
    local player_data = QBCore.Functions.GetPlayerData()
    if not player_data then return false, "Player Data not found" end
    return player_data
end

function core.getJob()
    local player_data, err = core.getPlayerData()
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

function core.getGroupInfo(isJob)
    local data = core.getPlayerData()
    local group = isJob and data?.job or data?.gang
    return {
        name = group.name,
        grade = group.grade.level,
        label = group.label,
        isBoss = group.grade.isboss or false, -- Added isboss property
    }
end

function core.getGender()
    local data = core.getPlayerData()
    return (data.charinfo.gender or 0) + 1 -- 1 = Male, 2 = Female
end

function core.getGang()
    local player_data, err = core.getPlayerData()
    if not player_data then return false, err end
    local gang = player_data.gang
    if not gang then return false, "Gang not found" end
    return gang
end

function core.isDead()
    local data = core.getPlayerData()
    return data.metadata and data.metadata.isdead
end

function core.getVehicleProperties(vehicle)
    local properties = QBCore.Functions.GetVehicleProperties(vehicle)
    if not properties then return false, "Failed to get vehicle properties" end
    return properties
end

function core.setThirst(thirst)
    local Player = QBCore.Functions.GetPlayerData()
    Player.Functions.SetMetaData("thirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + thirst)
    TriggerEvent("hud:client:UpdateNeeds", Player.PlayerData.metadata.hunger, thirst)
    return true
end

function core.setHunger(hunger)
    local Player = QBCore.Functions.GetPlayerData()
    Player.Functions.SetMetaData("hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + hunger)
    TriggerEvent("hud:client:UpdateNeeds", hunger, Player.PlayerData.metadata.thirst)
    return true
end

function core.getPlayersFromCoords(coords, distance)
    local players = {}
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed and DoesEntityExist(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            if #(playerCoords - targetCoords) <= (distance or 5.0) then
                table.insert(players, playerId)
            end
        end
    end
    return players
end

function core.toggleDuty(duty, src)
    if not duty then
        TriggerServerEvent("QBCore:ToggleDuty")
    else
        local player = core.getPlayerData(src)
        if not player then return false, "Player Data not found" end
        player.Functions.SetJobDuty(duty)
    end
end

function core.event.OnJobUpdated(cb)
    RegisterNetEvent("QBCore:Client:OnJobUpdate", cb)
end

return core