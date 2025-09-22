local peds = {}
zutils.ped = {}
function zutils.ped.createPed(model, coords, options, pedId)
    options = options or {}
    model = zutils.joaat(model)
    local id = pedId or #peds + 1
    if not peds[id] then
        peds[id] = {}
    end
    peds[id].id = id
    if (options.distance or options.usePoint)
        and not peds[id].pointID
        and not options.networked
        and not options.vehicle
    then
        options.distance = options.distance or 100.0
        options.usePoint = options.usePoint or true
        local pointID = zutils.points.addPoint(coords, {
            distance = options.distance,
            onEnter = function()
                if DoesEntityExist(peds[id].ped) then return end
                local newped = zutils.ped.createPed(model, coords, options, id)
                if options.onSpawn then options.onSpawn(newped, id) end
            end,
            onExit = function()
                if DoesEntityExist(peds[id].ped) then
                    DeleteEntity(peds[id].ped)
                    if options.onDespawn then options.onDespawn() end
                end
            end,
            onRemove = function()
                local ped = peds[id]
                if not ped then return end
                if DoesEntityExist(ped.ped) then
                    DeleteEntity(ped.ped)
                    if options.onDespawn then options.onDespawn() end
                end
            end
        })
        peds[id].pointID = pointID
        local playercoords = GetEntityCoords(PlayerPedId())
        if #(playercoords - coords.xyz) > (options.distance + 10) then
            return
        end
    end

    printdb("Creating ped %s at %s", model, coords)
    zutils.loadModel(model)
    local ped
    if options.vehicle then
        if not DoesEntityExist(options.vehicle.entity) then
            printerr("Vehicle does not exist for ped %s", id)
            return false, "vehicle did not exist"
        end
        ped = CreatePedInsideVehicle(options.vehicle.entity, options.pedtype or 26, model, options.vehicle.seat, true,
            true)
    else
        if not coords then
            printerr("No coords provided for ped %s", id)
        end

        local networked = false
        if options.networked ~= nil then
            networked = options.networked
        end

        ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w or 0, networked, networked)

        if not options.ignoreGroundCheck then
            local ground_coords = zutils.getGroundAt(coords)
            SetEntityCoords(ped, ground_coords.x, ground_coords.y, ground_coords.z, false, false, false, false)
        end
    end
    peds[id].ped = ped
    if options.freeze then
        FreezeEntityPosition(ped, true)
    end

    if options.targetOptions then
        zutils.target.addEntityTarget(ped, options.targetOptions)
    end

    if options.scenario then
        TaskStartScenarioInPlace(ped, options.scenario, 0, true)
    end

    if options.noCollision then
        SetEntityNoCollisionEntity(ped, PlayerPedId(), true)
    end
    if options.blockEvent then
        SetBlockingOfNonTemporaryEvents(ped, true)
    end

    if options.flags then
        for flag, active in pairs(options.flags) do
            local flag_num = tonumber(flag)
            if flag_num then
                SetPedConfigFlag(ped, flag_num, active)
            end
        end
    end

    if options.weapon then
        options.weapon = {
            model = zutils.joaat(options.weapon.model),
            sideWeaponModel = options.weapon.sideWeaponModel and zutils.joaat(options.weapon.sideWeaponModel) or nil,
            ammoCapacity = options.weapon.ammoCapacity or 100,
            hidden = options.weapon.hidden or false,
            forceInHand = options.weapon.forceInHand ~= false,
            canSwap = options.weapon.canSwap ~= false,
            dropWeapon = options.weapon.dropWeapon == true,
            accuracy = options.weapon.accuracy,
            infiniteAmmo = options.weapon.infiniteAmmo or false,
        }

        GiveWeaponToPed(ped, options.weapon.model, options.weapon.ammoCapacity, false, false)
        if options.weapon.sideWeaponModel then
            GiveWeaponToPed(ped, options.weapon.sideWeaponModel, options.weapon.ammoCapacity, options.weapon.hidden,
                options.weapon.forceInHand)
            SetPedInfiniteAmmo(ped, options.weapon.infiniteAmmo, options.weapon.sideWeaponModel)
            SetPedAmmo(ped, options.weapon.sideWeaponModel, options.weapon.ammoCapacity)
        end
        SetCurrentPedWeapon(ped, options.weapon.model, true)
        SetPedCanSwitchWeapon(ped, options.weapon.canSwap)
        SetPedDropsWeaponsWhenDead(ped, options.weapon.dropWeapon)
        SetPedAmmo(ped, options.weapon.model, options.weapon.ammoCapacity)
        SetPedInfiniteAmmo(ped, options.weapon.infiniteAmmo, options.weapon.model)
        if options.weapon.accuracy then
            SetPedAccuracy(ped, options.weapon.accuracy)
        end
    end

    if options.canSufferCrits ~= nil then
        SetPedSuffersCriticalHits(ped, options.canSufferCrits)
    end

    if options.relationshipGroup then
        SetPedRelationshipGroupHash(ped, zutils.joaat(options.relationshipGroup))
    end

    if options.canRagdoll ~= nil then
        SetPedCanRagdoll(ped, options.canRagdoll)
    end

    if options.health then
        SetEntityHealth(ped, options.health)
    end

    if options.armor then
        SetPedArmour(ped, options.armor)
    end

    if options.flee ~= nil then
        SetPedFleeAttributes(ped, 0, options.flee)
    end

    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, options.invincible or false)
    SetPedCanLosePropsOnDamage(ped, false, 0)

    if options.onSpawn then options.onSpawn(ped, id) end
    SetModelAsNoLongerNeeded(model)
    return ped, id
end

function zutils.ped.RemovePed(pedid)
    print("Removing ped with id", pedid)
    local ped = peds[pedid]
    if not ped then
        printerr("Ped not found for id %s", pedid)
        return
    end
    if ped.pointID then
        zutils.points.removePoint(ped.pointID)
    else
        if DoesEntityExist(ped.ped) then
            DeleteEntity(ped.ped)
        end
    end
    peds[pedid] = nil
end

function zutils.ped.turnTo(ped, target, duration)
    if not DoesEntityExist(ped) then return false, "ped does not exist" end
    local targetCoords
    if type(target) == "vector3" then
        targetCoords = target
    elseif type(target) == "number" then
        if not DoesEntityExist(target) then return false, "target entity does not exist" end
        targetCoords = GetEntityCoords(target)
    end

    TaskTurnPedToFaceCoord(ped, targetCoords.x, targetCoords.y, targetCoords.z, duration or -1)

    while not IsPedHeadingTowardsPosition(ped, targetCoords.x, targetCoords.y, targetCoords.z, 20.0) do
        Wait(100)
    end
    Wait(100)
    ClearPedTasks(ped)
    return true
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for _, data in pairs(peds) do
            if DoesEntityExist(data.ped) then
                DeleteEntity(data.ped)
            end
        end
    end
end)

return zutils.ped
