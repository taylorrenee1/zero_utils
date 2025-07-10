local target = {}

local activeTargets = {}

local function formatOptions(options)
    local distance
    if options.distance then
        distance = options.distance
        options = options.options or options[1]
    end
    for _, option in pairs(options) do
        option.distance = option.distance or distance
        option.onSelect = option.onSelect or option.action
        option.items = option.items or option.item
        option.name = option.name or option.label

        if option.job or option.gang then
            local group = {}
            for _, val in pairs(option.job or {}) do group[#group+1] = val end
            for _, val in pairs(option.gang or {}) do group[#group+1] = val end
            option.groups = group
        end
    end
    return options
end

target.addEntityTarget = function(entities, options)
    exports['qb-target']:AddTargetEntity(entities, {
        options = formatOptions(options),
        distance = options.distance or 2.5
    })
    activeTargets[entities] = {
        type = 'entity',
        entity = entities,
        invokingResource = GetInvokingResource()
    }
end

target.removeEntityTarget = function(entity)
    exports['qb-target']:RemoveTargetEntity(entity)
    activeTargets[entity] = nil
end

target.addModelTarget = function(model, options)
    exports['qb-target']:AddTargetModel(model, {
        options = formatOptions(options),
        distance = options.distance or 2.5
    })
    activeTargets[model] = {
        type = 'model',
        model = model,
        invokingResource = GetInvokingResource()
    }
end

target.removeModelTarget = function(model)
    exports['qb-target']:RemoveTargetModel(model)
    activeTargets[model] = nil
end

target.addBoxZone = function(name, coords, size, options)
    exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        heading = coords.w or 0.0,
        minZ = coords.z - 1,
        maxZ = coords.z + 1,
        debugPoly = false
    }, formatOptions(options))
    activeTargets[name] = {
        type = 'zone',
        id = name,
        invokingResource = GetInvokingResource()
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
