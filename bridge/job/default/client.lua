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
    onDuty = not onDuty
    TriggerEvent("zutils:Client:SetDuty", onDuty)
    return onDuty and "You are now clocked in" or "You are now clocked out"
end

function job.getBossGrade(role)
    local boss = {}
    local data = Jobs and Jobs[role]
    if data then
        for grade, info in pairs(data.grades) do
            if info.isboss then
                boss[role] = boss[role] and math.min(boss[role], tonumber(grade)) or tonumber(grade)
            end
        end
    end
    return boss[role]
end

return job
