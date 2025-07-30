--just a wrapper for our logging prefix.
zutils.core_loader("ox_lib")

function zutils.logger(src, type, msg, ...)
    local tags = {}
    src = tonumber(src) or 0
    if src > 0 then
        local player_data = zutils.player.getPlayerData(src)
        if player_data then
            local character_name = ("%s %s"):format(player_data.charinfo.firstname, player_data.charinfo.lastname)
            tags[#tags+1] = ("character_name: %s"):format(character_name)
            tags[#tags+1] = ("citizenid: %s"):format(player_data.citizenid)
            local ped = GetPlayerPed(src)
            local coords = GetEntityCoords(ped)
            tags[#tags+1] = ("coords: vector3(%s, %s, %s)"):format(coords.x, coords.y, coords.z)
            msg = ("%s(src:%s cid:%s (%s)) %s"):format(GetPlayerName(src),src, player_data.citizenid, character_name , msg)
        end
    end
    local varArgs = {...}
    for i=1, #varArgs do
        tags[#tags+1] = varArgs[i]
    end
    printdb("src:%s type:%s msg:%s tags:%s ", src, type, msg, tags)
    lib.logger(src, type, msg, table.unpack(tags))
end

return zutils.logger
