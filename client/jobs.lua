local core = zutils.bridge_loader("core", "client")
if not core then return end

zutils.cache.job = {
    name = "",
    onduty = false,
    grade = 0,
    isboss = false,
}
zutils.cache.onduty = false

core.onJobUpdate(function(job)
    zutils.cache.job = {
        name = job.name,
        onduty = job.onduty,
        grade = job.grade.level,
        isboss = job.grade.isboss or false,
    }
    zutils.cache.onduty = job.onduty
end)