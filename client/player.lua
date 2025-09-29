AddStateBagChangeHandler('sv_health', '', function(bagName, _, value)
    if not value then return end
    local ped = zutils.await(function()
        local ped = GetEntityFromStateBagName(bagName)
        if DoesEntityExist(ped) then
            return ped
        end
    end, nil, 10000, true)
    print(ped)
    if not ped then return end
    printdb(true, "setting health to %s, %s, %s", value, ped, zutils.cache.ped)
    if ped ~= zutils.cache.ped then return end
    SetEntityHealth(ped, value)
    Entity(ped).state:set("sv_health", nil, true)
end)