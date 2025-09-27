local core = zutils.bridge_loader("core", "client")
if not core then return end

zutils.cache.job = {
    name = "",
    onduty = false,
    grade = 0,
    isboss = false,
}
zutils.cache.onduty = false

zutils.events.onPlayerLoaded(function()
    local job = zutils.player.getJob()
    local onduty = job.onduty
    if onduty == nil then onduty = job.onDuty end

    local gradeLevel, isboss
    if type(job.grade) == "table" then
        gradeLevel = job.grade.level or tonumber(job.grade) or 0
        isboss = job.grade.isboss or job.grade.isBoss or false
    else
        gradeLevel = tonumber(job.grade) or 0
        isboss = job.isboss or job.isBoss or (job.grade_name == "boss") or (job.grade_label == "Boss") or false
    end

    zutils.cache.job = {
        name   = job.name or job.job or job.id,
        onduty = onduty or false,
        grade  = gradeLevel,
        isboss = isboss,
        label  = job.label,
    }
    zutils.cache.onduty = zutils.cache.job.onduty
end)

core.onJobUpdate(function(job)
    local onduty = job.onduty
    if onduty == nil then onduty = job.onDuty end

    local gradeLevel, isboss
    if type(job.grade) == "table" then
        gradeLevel = job.grade.level or tonumber(job.grade) or 0
        isboss = job.grade.isboss or job.grade.isBoss or false
    else
        gradeLevel = tonumber(job.grade) or 0
        isboss = job.isboss or job.isBoss or (job.grade_name == "boss") or (job.grade_label == "Boss") or false
    end

    zutils.cache.job = {
        name   = job.name or job.job or job.id,
        onduty = onduty or false,
        grade  = gradeLevel,
        isboss = isboss,
        label  = job.label,
    }
    zutils.cache.onduty = zutils.cache.job.onduty
end)
