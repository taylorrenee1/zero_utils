local job = {}
local onDuty = false

function job.check(jobName)
    local data = zutils.core.getPlayerData()
    if not data or not data.job then return false end
    if data.job.name ~= jobName or not onDuty then
        return "You are not clocked in", false
    end
    return true
end

function job.toggle()
    TriggerServerEvent("QBCore:ToggleDuty") -- qbx uses same event
end

function job.getBossGrade(role)
    local boss = {}
    local data = Jobs and Jobs[role]
    if data then
        for grade, info in pairs(data.grades) do
            if info.isboss or info.isBoss then
                boss[role] = boss[role] and math.min(boss[role], tonumber(grade)) or tonumber(grade)
            end
        end
    end
    return boss[role]
end

RegisterNetEvent("qbx_core:client:onJobUpdate", function(jobName)
    onDuty = jobName.onduty
    TriggerEvent("zutils:Client:SetDuty", onDuty)
end)

return job
