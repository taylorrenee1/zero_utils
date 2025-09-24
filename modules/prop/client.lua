local props = {}
zutils.prop = {}

function zutils.prop.deleteProp(id)
    local prop = props[id] and props[id].prop or id
    if not prop then return printwarn("Prop %s does not exist", id) end
    if DoesEntityExist(prop) then
        DeleteEntity(prop)
        props[id] = nil
    else
        printwarn("Prop %s does not exist", id)
    end
end

function zutils.prop.createEntityProp(entity, model, bone, offset, rotation)
    offset = offset or vector3(0, 0, 0)
    rotation = rotation or vector3(0, 0, 0)
    model = zutils.joaat(model)
    local id = zutils.uuid()
    local prop = CreateObject(model, 0, 0, 0, true, true, false)
    AttachEntityToEntity(prop, entity, GetPedBoneIndex(entity, bone), offset.x, offset.y, offset.z, rotation.x,
        rotation.y, rotation.z, true, true, false, true, 1, true)
    props[id] = {
        id = id,
        prop = prop
    }
    return id, prop
end

function zutils.prop.createProp(model, coords, options, pedID)
    options = options or {}
    local id = pedID or zutils.uuid()
    if not props[id] then
        props[id] = {}
    end
    props[id].id = id
    printdb("Prop %s coords: %s", id, coords)
    if options.distance
        and not props[id].pointID
    then
        local pointID = zutils.points.addPoint(coords, {
            distance = options.distance,
            onEnter = function()
                if DoesEntityExist(props[id].prop) then return end
                local newprop = zutils.prop.createProp(model, coords, options, id)
                if options.onSpawn then options.onSpawn(newprop, id) end
            end,
            onExit = function()
                if DoesEntityExist(props[id].prop) then
                    printdb("Prop %s despawned at %s", id, coords)
                    DeleteEntity(props[id].prop)
                    if options.onDespawn then options.onDespawn() end
                end
            end,
            onRemove = function()
                local prop = props[id]
                if not prop then return end
                if DoesEntityExist(prop.prop) then
                    DeleteEntity(prop.prop)
                    if options.onDespawn then options.onDespawn() end
                end
            end
        })

        props[id].pointID = pointID
        local playercoords = GetEntityCoords(PlayerPedId())
        if #(playercoords - coords.xyz) > (options.distance + 10) then
            return
        end
    end

    printdb("Creating prop %s at %s", model, coords)
    zutils.loadModel(model)
    local prop = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)

    SetEntityHeading(prop, coords.w or 0)

    if not DoesEntityExist(prop) then
        return
    end

    if options.freeze then
        FreezeEntityPosition(prop, true)
    end

    if options.noCollision then
        SetEntityNoCollisionEntity(prop, PlayerPedId(), true)
    end

    if options.onSpawn then
        options.onSpawn(prop, id)
    end

    if options.targetOptions then
        zutils.target.addEntityTarget(prop, options.targetOptions)
    end

    SetModelAsNoLongerNeeded(model)

    props[id].prop = prop
    return prop, id
end

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, data in pairs(props) do
        if DoesEntityExist(data.prop) then
            printdb("Deleting prop %s", data.id)
            DeleteEntity(data.prop)
        else
            printdb("Prop(%s) %s does not exist, skipping deletion", data.prop, data.id)
        end

    end
end)

return zutils.prop
