if not QBCore then QBCore = zutils.core_loader("QBCore") end

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
function core.getGender()
    local data = core.getPlayerData()
    return (data.charinfo.gender or 0) + 1 -- 1 = Male, 2 = Female
end

function core.getGang()
    local data, err = core.getPlayerData()
    return data and data.gang or false, err or "Gang not found"
end


return core