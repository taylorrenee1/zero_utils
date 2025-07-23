local core = {}

function core.getPlayer(src)
    local player = exports.qbx_core:GetPlayerData(tonumber(src))
    if not player then return false, "Player not found" end
    return player
end

function core.getPlayerData(src)
    local player, err = exports.qbx_core:GetPlayerData(tonumber(src))
    if not player then return false, err end
    local player_data = player.PlayerData
    if not player_data then return false, "Player Data not found" end
    return player_data
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

return core
