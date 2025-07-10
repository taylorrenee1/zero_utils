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
        if option.action then
            option.onSelect = option.action
        end
        
        if option.item then
            option.items = option.item
        end
        if option.job or option.gang then
            local group = {}
            if type(option.job) == "string" then
                group[#group+1] = option.job
            else
                for key, v in pairs(option.job or {}) do
                    if type(v) =="string" then
                        group[#group+1] = v
                    else
                        group[key] = v
                    end
                end
            end
            
            if type(option.gang) == "string" then
                group[#group+1] = option.gang
            else
                for key, v in pairs(option.gang or {}) do
                    if type(v) =="string" then
                        group[#group+1] = v
                    else
                        group[key] = v
                    end
                end
            end
            option.groups = group
        end
    end
    return options
end

target.addEntityTarget = function(entities, options)
    exports.ox_target:addLocalEntity(entities, formatOptions(options))
    activeTargets[entities] = {
        type = "entity",
        entity = entities,
        invokingResource = GetInvokingResource()
    }
end

target.addNetIDTarget = function(netID, options)
    exports.ox_target:addEntity(netID, formatOptions(options))
end

target.removeNetIDTarget = function(netId)
    exports.ox_target:removeEntity(netId)
end

target.removeEntityTarget = function(entity)
    exports.ox_target:removeLocalEntity(entity)
end

target.addModelTarget = function(model, options)
    exports.ox_target:addModel(model, formatOptions(options))
end

target.removeModelTarget = function(model)
    exports.ox_target:removeModel(model)
end


target.addBoxZone = function(name, coords, size, options)
    local id = exports.ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = options.rotation or 0,
        debug = options.debug or false,
        options = formatOptions(options)
    })
    activeTargets[name] = {
        type = "zone",
        id = id,
        invokingResource = GetInvokingResource()
    }
end

target.removeZone = function(name)
    local zone = activeTargets[name]
    if zone and zone.id then
        exports.ox_target:removeZone(zone.id)
        activeTargets[name] = nil
    end
end

AddEventHandler("onResourceStop", function(resource)
    for key, data in pairs(activeTargets) do
        if data.invokingResource == resource then
            if data.type == "zone" then
                exports.ox_target:removeZone(data.id)
            elseif data.type == "entity" then
                exports.ox_target:removeLocalEntity(data.entity)
            elseif data.type == "globalPed" then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports.ox_target:removeGlobalPed(names)
            elseif data.type == "globalObject" then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports.ox_target:removeGlobalObject(names)
            elseif data.type == "globalVehicle" then
                local names = {}
                for _, v in ipairs(data.options) do names[#names+1] = v.name end
                exports.ox_target:removeGlobalVehicle(names)
            end
            activeTargets[key] = nil
        end
    end
end)

return target



