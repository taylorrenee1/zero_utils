local qb_target = exports['qb-target']

local target = {}

local activeTargets = {}

local function formatOptions(options)
    if not options then
        return {}
    end

    for _, option in pairs(options) do
        if option.onSelect then
            option.action = option.onSelect
            option.onSelect = nil
        end

        if option.group and not option.job and not option.gang then
            option.job = {}
            option.gang = {}

            for key, v in pairs(option.group) do
                if type(v) == "string" then
                    option.job[#option.job + 1] = v
                    option.gang[#option.gang + 1] = v
                else
                    option.job[key] = v
                    option.gang[key] = v
                end
            end
        end
    end

    return {
        options = options,
        distance = options.distance or options[1] and options[1].distance or 2.5,
    }
end

target.addEntityTarget = function(entities, options)
    qb_target:AddTargetEntity(entities, formatOptions(options))
    activeTargets[entities] = {
        type = 'entity',
        entity = entities,
        invokingResource = GetInvokingResource()
    }
    return {
        remove = function()
            target.removeEntityTarget(entities, options)
        end
    }
end

target.addNetIDTarget = function(netID, options)
    qb_target:AddTargetEntity(netID, formatOptions(options))
    activeTargets[netID] = {
        type = 'model',
        model = options.model or netID,
        invokingResource = GetInvokingResource()
    }
    return {
        remove = function()
            target.removeNetIDTarget(netID, options)
        end
    }
end

target.addBoxZoneTarget = function(id, coords, size, options)
    printdb("Adding box zone target %s, %s, %s, %s", id, coords, size, options)
    qb_target:AddBoxZone(id, coords.xyz, size.y, size.x, {
        name = id,
        heading = coords.w or 0,
        debugPoly = options.debug or false,
        minZ = coords.z - (size.z / 2),
        maxZ = coords.z + (size.z / 2),
    }, formatOptions(options.options))
    activeTargets[id] = {
        type = 'zone',
        id = id,
        invokingResource = GetInvokingResource()
    }
    return {
        remove = function()
            target.removeZoneTarget(id)
        end
    }
end

target.removeZone = function(name)
    exports['qb-target']:RemoveZone(name)
    activeTargets[name] = nil
end

target.addGlobalPed = function(name, options)
    local formatted = formatOptions(options)
    exports['qb-target']:AddGlobalPed({ options = formatted, distance = options.distance or 2.5 })
    activeTargets[name] = {
        type = 'globalPed',
        id = name,
        options = formatted,
        invokingResource = GetInvokingResource()
    }
end

target.addModelTarget = function(model, options)
    qb_target:AddTargetModel(model, formatOptions(options))
end

target.removeGlobalPed = function(name)
    local data = activeTargets[name]
    if data and data.options then
        local names = {}
        for _, v in ipairs(data.options) do names[#names+1] = v.name end
        exports['qb-target']:RemoveGlobalType(1, names)
    end
    activeTargets[name] = nil
end

target.addGlobalObject = function(name, options)
    local formatted = formatOptions(options)
    exports['qb-target']:AddGlobalObject({ options = formatted, distance = options.distance or 2.5 })
    activeTargets[name] = {
        type = 'globalObject',
        id = name,
        options = formatted,
        invokingResource = GetInvokingResource()
    }
end

target.removeGlobalObject = function(name)
    local data = activeTargets[name]
    if data and data.options then
        local names = {}
        for _, v in ipairs(data.options) do names[#names+1] = v.name end
        exports['qb-target']:RemoveGlobalType(3, names)
    end
    activeTargets[name] = nil
end

target.addGlobalVehicle = function(name, options)
    local formatted = formatOptions(options)
    exports['qb-target']:AddGlobalVehicle({ options = formatted, distance = options.distance or 2.5 })
    activeTargets[name] = {
        type = 'globalVehicle',
        id = name,
        options = formatted,
        invokingResource = GetInvokingResource()
    }
end

target.removeGlobalVehicle = function(name)
    local data = activeTargets[name]
    if data and data.options then
        local names = {}
        for _, v in ipairs(data.options) do names[#names+1] = v.name end
        exports['qb-target']:RemoveGlobalVehicle(names)
    end
    activeTargets[name] = nil
end



target.removeNetIDTarget = function(netId, options)
    qb_target:RemoveTargetEntity(netId, options)
end

target.removeEntityTarget = function(entities, options)
    qb_target:RemoveTargetEntity(entities, options)
end


target.removeModelTarget = function(model, options)
    qb_target:RemoveTargetModel(model, options)
end

target.removeZoneTarget = function(id)
    qb_target:RemoveZone(id)
end

AddEventHandler("onResourceStop", function(resource)
    for key, data in pairs(activeTargets) do
        if data.invokingResource == resource then
            if data.type == 'entity' then
                exports['qb-target']:RemoveTargetEntity(data.entity)
            elseif data.type == 'model' then
                exports['qb-target']:RemoveTargetModel(data.model)
            elseif data.type == 'zone' then
                exports['qb-target']:RemoveZone(data.id)
            elseif data.type == 'globalPed' then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports['qb-target']:RemoveGlobalType(1, names)
            elseif data.type == 'globalObject' then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports['qb-target']:RemoveGlobalType(3, names)
            elseif data.type == 'globalVehicle' then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports['qb-target']:RemoveGlobalVehicle(names)
            end
            activeTargets[key] = nil
        end
    end
end)

return target