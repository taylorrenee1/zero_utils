-- bridge/callback/es_extended/client.lua
local ESX = zutils.core_loader('ESX')

local callback = {}

callback.trigger = function(name, _delay, cb, ...)
    printdb("Triggering Callback %s", name)
    ESX.TriggerServerCallback(name, function(...)
        cb(...)
    end, ...)
end


callback.register = function(name, func)
    printdb("Registering Client Callback %s", name)
    ESX.RegisterClientCallback(name, function(cb, ...)
        local result = { func(...) }
        cb(table.unpack(result))
    end)
end

callback.await = function(name, _delay, ...)
    printdb("Awaiting Callback %s", name)
    local p = promise.new()
    ESX.TriggerServerCallback(name, function(...)
        p:resolve({...})
    end, ...)
    local result = Citizen.Await(p)
    return table.unpack(result)
end

return callback
