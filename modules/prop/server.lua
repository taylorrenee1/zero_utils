local props = {}
zutils.prop = {}

function zutils.prop.deleteProp(id)
    local prop = props[id] and props[id].prop or id
    if not prop then return printwarn("Prop %s does not exist", id) end
    if DoesEntityExist(prop) then
        DeleteEntity(prop)
        props[id] = nil
        printdb("Prop %s deleted", id)
    else
        printwarn("Prop %s did not exist", id)
    end

    props[id] = nil
end

function zutils.prop.createProp(model, coords, options, propID)
    options = options or {}
    model = zutils.joaat(model)
    if not model then return false, nil, "Invalid model" end
    local id = propID or zutils.uuid()

    if props[id] then
        return false, nil, "Prop id already exists: " .. id
    end

    printdb("Creating prop %s at %s", model, coords)

    local prop = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(prop, coords.w or 0.0)
    local exists = zutils.await(function()
        Wait(100)
        return DoesEntityExist(prop)
    end, "", 5000, true)

    if not exists then
        return false, nil, "Failed to create prop: " .. id
    end

    if options.velocity then
        printdb("Setting velocity for prop %s to %s", id, options.velocity)
        SetEntityVelocity(prop, options.velocity.x, options.velocity.y, options.velocity.z)
    end

    if options.state then
        for key, value in pairs(options.state) do
            Entity(prop).state:set(key, value, true)
        end
    end

    FreezeEntityPosition(prop, options.freeze and true or false)

    SetEntityOrphanMode(prop, 2)

    props[id] = {
        id = id,
        prop = prop,
    }

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
