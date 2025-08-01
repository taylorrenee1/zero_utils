local core = zutils.bridge_loader("core", "shared")
if not core then return end

zutils.core = {}

function zutils.core.getJobData(jobName)
    return core.getJobData(jobName)
end

function zutils.core.getGroupInfo(isJob)
    return core.getGroupInfo(isJob)
end

function zutils.core.getJob()
    return core.getJob()
end

function zutils.core.getPlayerData()
    return core.getPlayerData()
end

function zutils.core.getGender()
    return core.getGender()
end

function zutils.core.getVehicleProperties(vehicle)
    return core.getVehicleProperties(vehicle)
end

function zutils.core.setThirst(thirst)
    return core.setThirst(thirst)
end

function zutils.core.setHunger(hunger)
    return core.setHunger(hunger)
end

function zutils.core.getPlayersFromCoords(coords, distance)
    return core.getPlayersFromCoords(coords, distance)
end

return zutils.core