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

function core.setThirst(src, thirst)
    TriggerClientEvent('esx_status:add', src, 'thirst', thirst)
    return true
end

function core.setHunger(src, hunger)
   TriggerClientEvent('esx_status:add', src, 'hunger', hunger)
    return true
end

function core.registerUsableItem(itemName, cb)
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local item = xPlayer.getInventoryItem(itemName)
        cb(source, item)
    end)
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
