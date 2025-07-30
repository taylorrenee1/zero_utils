local player = zutils.bridge_loader("core", "shared")

zutils.player = {}

function zutils.player.getPlayer(src)
    return player.getPlayer(src)
end

function zutils.player.getPlayerData(src)
    return player.getPlayerData(src)
end

function zutils.player.getJob(src)
    return player.getJob(src)
end

function zutils.player.getJobData(src, jobName)
    return player.getJobData(src, jobName)
end

function zutils.player.getGroupInfo(src, isJob)
    return player.getPlayerData(src)
end

function zutils.player.getGender(src)
    return player.getGender(src)
end



return zutils.player