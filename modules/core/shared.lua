local core = zutils.bridge_loader("core")
if not core then return end

zutils.core = {}

function zutils.core.getJobData(jobName)
    return core.getJobData(jobName)
end

return zutils.core