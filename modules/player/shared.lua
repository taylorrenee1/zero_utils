local player = zutils.bridge_loader("core", "shared")

zutils.player = {}

function zutils.player.getPlayerId(src)
    local player_data = player.getPlayerData(src)
    if not player_data then
        return false, "Player data not found"
    end
    return player_data.citizenid
end

function zutils.player.getPlayer(src)
    return player.getPlayer(src)
end

function zutils.player.getPlayerData(src)
    return player.getPlayerData(src)
end

function zutils.player.getJob(src)
    return player.getJob(src)
end

function zutils.player.getGang(src)
    return player.getGang(src)
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

function zutils.player.getMoney(moneyType, src)
    local player_data = player.getPlayerData(src)
    if not player_data then
        return 0
    end
    return player_data.money[moneyType] or 0
end

function zutils.player.setThirst(src, thirst)
    return player.setThirst(src, thirst)
end

function zutils.player.addThirst(src, thirst)
    return player.setThirst(src, thirst)
end

function zutils.player.setHunger(src, hunger)
    return player.setHunger(src, hunger)
end

function zutils.player.addHunger(src, hunger)
    return player.setHunger(src, hunger)
end

function zutils.player.setHealth(src, health)
    health = health + 100 -- gta hp starts at 100 so convert
    return player.setHealth(src, health)
end

function zutils.player.addHealth(src, health)
    printdb(true, "setting health %s for %s", health, src)
    return player.addHealth(src, health)
end
function zutils.player.removeHealth(src, health)
    health = health * -1
    return player.addHealth(src, health)
end

function zutils.player.addArmour(src, armour)
    return player.setArmour(src, armour)
end

function zutils.player.getPedArmour(src)
    return GetPedArmour(src)
end

function zutils.player.setArmour(src, armour)
    local plyr = GetPlayerPed(src)
    return SetPedArmour(plyr, (plyr + armour))
end

function zutils.player.setStress(src, stress)
    return player.setStress(src, stress)
end

function zutils.player.relieveStress(src, stress)
    return player.relieveStress(src, stress)
end

function zutils.player.addStress(src, stress)
    return player.setStress(src, stress)
end

function zutils.player.removeMoney(src, amount, payment_method, reason)
    if zutils.context == "client" then
        printwarn("zutils.player.removeMoney should not be called from the client!")
        return false
    end

    return player.removeMoney(src, amount, payment_method or "cash", reason)
end

function zutils.player.addMoney(src, amount, payment_method, reason)
    if zutils.context == "client" then
        printwarn("zutils.player.addMoney should not be called from the client!")
        return false
    end

    return player.addMoney(src, amount, payment_method or "cash", reason)
end

function zutils.player.toggleDuty(duty, src)
    return player.toggleDuty(duty, src)
end

return zutils.player