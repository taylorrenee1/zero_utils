local job = zutils.bridge_loader("job", "client")
if not job then return end

zutils.job = {}

zutils.job.onDuty = false

RegisterNetEvent("zutils:Client:SetDuty", function(state)
    zutils.job.onDuty = state
end)

function zutils.job.check(jobName)
    return job.check(jobName)
end

function zutils.job.toggle()
    return job.toggle()
end

function zutils.job.getBossGrade(jobName)
    return job.getBossGrade(jobName)
end

return zutils.job
